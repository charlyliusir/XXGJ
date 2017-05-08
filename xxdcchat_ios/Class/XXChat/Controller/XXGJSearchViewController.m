//
//  XXGJSearchViewController.m
//  xxdcchat_ios
//
//  Created by 刘朝龙 on 2017/3/29.
//  Copyright © 2017年 刘朝龙. All rights reserved.
//

#import "XXGJSearchViewController.h"
#import "XXGJUserInfoViewController.h"
#import <MJRefreshFooter.h>
#import <Masonry.h>
#import "UISearchBar+XXGJChangeStyle.h"
#import "XXGJChatItemTableViewCell.h"
#import "XXGJChatItem.h"
#import "User.h"



@interface XXGJSearchViewController () <UISearchBarDelegate, UITableViewDelegate, UITableViewDataSource>
@property (weak, nonatomic) IBOutlet UILabel *noUserLabel;
@property (weak, nonatomic) IBOutlet UISearchBar *searchBar;
@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property (nonatomic, strong)NSMutableArray *usersArray;

@property (nonatomic, assign)BOOL isRunning;
@property (nonatomic, assign)NSUInteger currentPage;
@property (nonatomic, assign)NSUInteger totalCount;

@end

@implementation XXGJSearchViewController

+ (instancetype)searchViewController
{
    return [[NSBundle mainBundle] loadNibNamed:NSStringFromClass(self) owner:nil options:nil].lastObject;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:YES];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    //找到取消按钮
    UIButton *cancleBtn = [self.searchBar valueForKey:@"cancelButton"];
    //修改标题和标题颜色
    [cancleBtn setTitle:@"取消" forState:UIControlStateNormal];
    [cancleBtn setTitleColor:XX_RGBCOLOR_WITHOUTA(14, 170, 159) forState:UIControlStateNormal];
    /** 修改SearchBar内容颜色*/
    UITextField *textField = [self.searchBar getContentTextField];
    [textField setTextColor:XX_NAVIGATIONBAR_TITLECOLOR];
    [textField setFont:[UIFont systemFontOfSize:14]];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    [self.searchBar becomeFirstResponder];
    [self.tableView setTableFooterView:[UIView new]];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - lazy method
- (NSMutableArray *)usersArray
{
    if (!_usersArray) {
        _usersArray = [NSMutableArray array];
    }
    
    return _usersArray;
}

#pragma mark - private
- (void)loadUserList:(NSUInteger)currentPage
{
    NSDictionary *dict = @{XXGJ_N_PARAM_NICKNAEM:self.searchBar.text, XXGJ_N_PARAM_CURRENTPAGE:@(currentPage), XXGJ_N_PARAM_PAGESIZE:@(20)};
    [XXGJNetKit searchUserList:dict rBlock:^(id obj, BOOL success, NSError *error) {
        NSLog(@"请求到了数据:%@", obj);
        if (obj && [obj[@"statusText"] isEqualToString:@"ok"])
        {
            NSDictionary *result = obj[@"result"];
            NSNumber *totalCount = result[@"totalCount"];
            if ([totalCount isEqualToNumber:@0])
            {
                [self.noUserLabel setHidden:NO];
                self.isRunning = NO;
                return ;
            }else
            {
                [self.noUserLabel setHidden:YES];
            }
            self.totalCount = [totalCount unsignedIntegerValue];
            /** 加载用户*/
            NSArray *list = result[@"list"];
            for (NSDictionary *userDict in list)
            {
                /** 添加过滤, 如果是自己, 则将昵称改为自己*/
                User *user = [NSEntityDescription insertNewObjectForEntityForName:TABLE_USER inManagedObjectContext:self.appDelegate.managedObjectContext];
                user.avatar  = userDict[@"Avatar"];
                user.user_id = userDict[@"ID"];
                if ([user.user_id isEqualToNumber:self.appDelegate.user.user_id])
                {
                    user.nick_name = @"自己";
                }else
                {
                    user.nick_name = userDict[@"NickName"];
                }
                
                [self.usersArray addObject:user];
            }
            
            if (self.totalCount > self.currentPage * 20)
            {
                self.tableView.mj_footer = [MJRefreshFooter footerWithRefreshingBlock:^{
                    self.currentPage ++ ;
                    [self loadUserList:self.currentPage];
                    [self.tableView.mj_footer endRefreshing];
                }];

            }else
            {
                self.tableView.mj_footer = nil;
            }
            
            /** 刷新 tableView*/
            dispatch_async(dispatch_get_main_queue(), ^{
                self.isRunning = NO;
                [self.tableView reloadData];
            });
        }
    }];
}

- (void)loadDataWithMust:(BOOL)mustRequest
{
    /** 如果正在网络请求, 等待下次*/
    if (self.isRunning && !mustRequest) return;
    
    /** 设置正在请求的表示*/
    self.isRunning = YES;
    
    /** 设置当前页数*/
    [self setCurrentPage:1];
    
    /** 清空上一次请求*/
    [self.usersArray removeAllObjects];
    
    /** 请求第一页用户数据*/
    [self loadUserList:1];
}

#pragma mark - delegate
#pragma mark - search bar delegate
- (BOOL)searchBarShouldBeginEditing:(UISearchBar *)searchBar
{
    
    return YES;
}

- (BOOL)searchBarShouldEndEditing:(UISearchBar *)searchBar
{
    NSLog(@"should end editing");
    return YES;
}

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText
{
    if ([searchBar.text isEqualToString:@""])
    {
        [self.noUserLabel setHidden:NO];
        [self.usersArray removeAllObjects];
        [self.tableView reloadData];
        return;
    }
    /** 网络请求*/
    [self loadDataWithMust:NO];
}

/**
 搜索按钮被点击
 
 @param searchBar 搜索视图
 */
- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
    if ([searchBar.text isEqualToString:@""])
    {
        [self.noUserLabel setHidden:NO];
        [self.usersArray removeAllObjects];
        [self.tableView reloadData];
        return;
    }
    /** 网络请求*/
    [self loadDataWithMust:YES];
}

/**
 取消按钮被点击
 
 @param searchBar 搜索视图
 */
- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar
{
    [self dismissViewControllerAnimated:YES completion:nil];
}
#pragma mark - table view delegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 70;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    User *user = self.usersArray[indexPath.row];
    XXGJUserInfoViewController *userInfo = [XXGJUserInfoViewController userInfoViewController];
    userInfo.user_id = user.user_id;
    [self.navigationController pushViewController:userInfo animated:YES];
    
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
}

#pragma mark - table view datasource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.usersArray.count;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    XXGJChatItemTableViewCell *cell = [XXGJChatItemTableViewCell chatItemCell:self.tableView hasSelectBtn:NO];
    User *user = self.usersArray[indexPath.row];
    cell.chatItem = [XXGJChatItem itemWithName:user.nick_name iconName:nil iconURL:user.avatar];
    
    return cell;
}

#pragma mark - table view scroll method
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    [self.searchBar resignFirstResponder];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
