//
//  XXGJGroupViewController.m
//  xxdcchat_ios
//
//  Created by 刘朝龙 on 2017/3/18.
//  Copyright © 2017年 刘朝龙. All rights reserved.
//

#import "XXGJGroupViewController.h"
#import "XXGJChatGroupTableViewCell.h"
#import "QXYChatViewController.h"
#import "Group.h"

@interface XXGJGroupViewController () <UISearchBarDelegate, UITableViewDelegate, UITableViewDataSource>
@property (weak, nonatomic) IBOutlet UISearchBar *findGroupSearchBar;
@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property (nonatomic, strong)NSArray *sourceArray;
@end

@implementation XXGJGroupViewController

+ (instancetype)groupViewController
{
    XXGJGroupViewController *groupVC = [[XXGJGroupViewController alloc] initWithNibName:NSStringFromClass(self) bundle:[NSBundle mainBundle]];
    return groupVC;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self setNavigationBarTitle:@"群聊"];
    
    [self reloadData];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    [self.tableView setSectionIndexColor:XX_NAVIGATIONBAR_TITLECOLOR];
    [self.tableView setSectionIndexBackgroundColor:[UIColor clearColor]];
    [self.tableView setSectionIndexTrackingBackgroundColor:[UIColor clearColor]];
    [self.findGroupSearchBar chageTextFieldBgColor:[UIColor whiteColor]];
    
}

- (void)viewWillLayoutSubviews
{
    [super viewWillLayoutSubviews];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - lazy method
- (NSArray *)sourceArray
{
    if (!_sourceArray) {
        _sourceArray = [NSArray array];
    }
    
    return _sourceArray;
}

#pragma mark - open method

#pragma mark - private method

- (void)reloadData
{
    self.sourceArray = [self.appDelegate.user getUserGroups];
    [self.tableView reloadData];
}

#pragma mark - notify method

#pragma mark - delegate
#pragma mark - search bar delegate
- (BOOL)searchBarShouldBeginEditing:(UISearchBar *)searchBar
{
    [self.findGroupSearchBar setShowsCancelButton:YES];
    
    return YES;
}

- (BOOL)searchBarShouldEndEditing:(UISearchBar *)searchBar
{
    [self.findGroupSearchBar setShowsCancelButton:NO];
    return YES;
}

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText
{
    NSLog(@"text Did change");
}

- (BOOL)searchBar:(UISearchBar *)searchBar shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
    NSLog(@"Should change in range");
    return YES;
}

/**
 搜索按钮被点击
 
 @param searchBar 搜索视图
 */
- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
    [self.findGroupSearchBar resignFirstResponder];
}

/**
 取消按钮被点击
 
 @param searchBar 搜索视图
 */
- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar
{
    NSLog(@"cancel button clicked");
}

#pragma mark - table view delegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 70;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    QXYChatViewController *chatVC = [[QXYChatViewController alloc] init];
    [chatVC setHidesBottomBarWhenPushed:YES];
    [chatVC setChatGroup:self.sourceArray[indexPath.row]];
    [self.navigationController pushViewController:chatVC animated:YES];
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
}

#pragma mark - table view datasource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.sourceArray.count;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    Group *group = self.sourceArray[indexPath.row];
    
    
    XXGJChatGroupTableViewCell *cell = [XXGJChatGroupTableViewCell chatGroupItemListCell:tableView];
    cell.chatGroupItem = [XXGJChatGroupItem itemWithName:group.name iconURL:group.pic groupId:group.groupid];
    
    return cell;
}

#pragma mark - scroll delegate
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    [self.findGroupSearchBar resignFirstResponder];
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
