//
//  XXGJNewViewController.m
//  xxdcchat_ios
//
//  Created by 刘朝龙 on 2017/3/29.
//  Copyright © 2017年 刘朝龙. All rights reserved.
//

#import "XXGJNewViewController.h"
#import "XXGJSearchViewController.h"
#import "XXGJApplyFriendTableViewCell.h"
#import "Message.h"

@interface XXGJNewViewController ()<UISearchBarDelegate, UITableViewDelegate, UITableViewDataSource, XXGJApplyFriendTableViewCellDelegate>
@property (nonatomic, strong)NSMutableArray *applyFriendArr;
@property (nonatomic, strong)NSMutableArray *applyContentArr;
@property (weak, nonatomic) IBOutlet UIView *maskView;
@property (weak, nonatomic) IBOutlet UISearchBar *searchBar;
@property (weak, nonatomic) IBOutlet UITableView *tableView;

@end

@implementation XXGJNewViewController

+ (instancetype)newFriendViewController
{
    return [[NSBundle mainBundle] loadNibNamed:NSStringFromClass(self) owner:nil options:nil].lastObject;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapAction:)];
    [self.maskView addGestureRecognizer:tapGestureRecognizer];
    
    [self setNavigationBarTitle:@"新的朋友"];
    
    [self loadData];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - lazy method
- (NSMutableArray *)applyFriendArr
{
    if (!_applyFriendArr)
    {
        _applyFriendArr = [NSMutableArray array];
    }
    return _applyFriendArr;
}
- (NSMutableArray *)applyContentArr
{
    if (!_applyContentArr)
    {
        _applyContentArr = [NSMutableArray array];
    }
    return _applyContentArr;
}

#pragma mark - private method
- (void)tapAction:(id)sender
{
    
    XXGJSearchViewController *searchVC = [XXGJSearchViewController searchViewController];
    UINavigationController *navigation = [[UINavigationController alloc] initWithRootViewController:searchVC];
    [self presentViewController:navigation animated:YES completion:nil];
}

- (void)loadData
{
    /** 先进行消息去重*/
    NSArray *friendApplyMessageArray = [self.appDelegate.dbModelManage excuteTable:TABLE_MESSAGE predicate:[NSString stringWithFormat:@"businessType=='8'"]];
    for (Message *message in friendApplyMessageArray)
    {
        User *user = [self.appDelegate.dbModelManage excuteTable:TABLE_USER predicate:[NSString stringWithFormat:@"user_id==%@", message.senderId] limit:1].lastObject;
        if (user && ![self.applyFriendArr containsObject:user])
        {
            [self.applyFriendArr addObject:user];
            [self.applyContentArr addObject:message];
        }
    }
    
    [self.tableView reloadData];
}


#pragma mark - delegate
#pragma mark - cell delegate
/**
 同意添加好友
 
 @param applyFriendMessage 添加好友请求信息
 */
- (void)agreeApplyFriendMessage:(Message *)applyFriendMessage
{
    [MBProgressHUD showLoadHUDIndeterminate:@"添加好友"];
    [XXGJNetKit confirmFriend:@{XXGJ_N_PARAM_RELATIONSID:applyFriendMessage.relationId, XXGJ_N_PARAM_RELATIONSTATUS:@(0)} rBlock:^(id obj, BOOL success, NSError *error) {
        // 重新加载好友列表, 以及好友信息
        if (obj && [obj[@"statusText"] isEqualToString:@"ok"])
        {
            /* 第一步, 获取对应的用户*/
            NSInteger index = [self.applyContentArr indexOfObject:applyFriendMessage];
            User *applyUser = [self.applyFriendArr objectAtIndex:index];
            [self.appDelegate.user addFriendsObject:applyUser];
            [self.appDelegate saveContext];
            
            /** 第二步, 重新刷新界面*/
            dispatch_async(dispatch_get_main_queue(), ^{
                [MBProgressHUD showLoadHUDCustomImage:successHUDName title:@"已添加好友"];
                [self.tableView reloadData];
            });
        }else
        {
            [MBProgressHUD showLoadHUDText:@"添加失败,请重新尝试！" during:0.25];
        }
    }];
}

#pragma mark - search bar delegate
- (BOOL)searchBarShouldBeginEditing:(UISearchBar *)searchBar
{
    [self.searchBar resignFirstResponder];
    
    return YES;
}

#pragma mark - table view delegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 70;
}

#pragma mark - table view datasource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.applyFriendArr.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    XXGJApplyFriendTableViewCell *applyFriendCell = [XXGJApplyFriendTableViewCell applyFriendTableViewCell:tableView];
    /** 传递数据*/
    User *applyUser = self.applyFriendArr[indexPath.row];
    Message *applyMessage = self.applyContentArr[indexPath.row];
    XXGJApplyFriendItem *applyFriendItem = [XXGJApplyFriendItem applyFriendItemWithUserIconUrl:applyUser.avatar userNickName:applyUser.nick_name userApplyContent:applyMessage.content isMyFriend:[self.appDelegate.user.friends containsObject:applyUser]];
    applyFriendCell.delegate = self;
    applyFriendCell.applyFriendItem = applyFriendItem;
    applyFriendCell.applyMessage    = applyMessage;
    return applyFriendCell;
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
