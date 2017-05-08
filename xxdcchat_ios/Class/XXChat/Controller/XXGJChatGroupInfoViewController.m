//
//  XXGJChatGroupInfoViewController.m
//  xxdcchat_ios
//
//  Created by 刘朝龙 on 2017/3/31.
//  Copyright © 2017年 刘朝龙. All rights reserved.
//

#import "XXGJChatGroupInfoViewController.h"
#import <Masonry.h>
#import "XXGJUserInfoViewController.h"
#import "XXGJGroupItemTableViewCell.h"
#import "XXGJGroupMemberViewController.h"
#import "XXGJSelectGroupMemberViewController.h"
#import "XXGJGroupUserView.h"
#import "Group.h"
#import "Message.h"

@interface XXGJChatGroupInfoViewController ()<UITableViewDelegate, UITableViewDataSource, XXGJGropUserViewDelegat>
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *userContentWidthConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *allMemberConstraint;
@property (weak, nonatomic) IBOutlet UIView *userContentView;
@property (weak, nonatomic) IBOutlet UIButton *memberNumberBtn;
@property (weak, nonatomic) IBOutlet UIButton *addMemberBtn;
@property (weak, nonatomic) IBOutlet UIButton *deleteMemberBtn;
@property (nonatomic, copy) ClearBlock clearBlock;
@property (nonatomic, strong) NSArray *groupMembers;
@end

@implementation XXGJChatGroupInfoViewController

+ (instancetype)chatGroupInfoViewController
{
    return [[NSBundle mainBundle] loadNibNamed:NSStringFromClass(self) owner:nil options:nil].lastObject;
}

- (void)updateGroupMemeberUI
{
    /** 获取群成员*/
    self.groupMembers = _group.groupMember;
    /** 设置title信息*/
    [self setNavigationBarTitle:self.group.name];
    /** 全部成员人数*/
    [self.memberNumberBtn setTitle:[NSString stringWithFormat:@"%ld成员 >", self.groupMembers.count] forState:UIControlStateNormal];
    /** 如果不是群🐖不允许踢成员*/

    if ([self.appDelegate.user.user_id isEqualToNumber:self.group.creator]) {
        [self.deleteMemberBtn setHidden:NO];
        [self.allMemberConstraint setConstant:15];
    }else
    {
        [self.deleteMemberBtn setHidden:YES];
        [self.allMemberConstraint setConstant:-45];
    }
    
    /** 将视图全部移除再说*/
    for (UIView *view in self.userContentView.subviews)
    {
        [view removeFromSuperview];
    }
    NSUInteger viewCount = self.groupMembers.count;
    if (self.groupMembers.count > 3) viewCount = 3;
    
    XXGJGroupUserView *lastGroupUserView = nil;
    /** 布局*/
    for (int i = 0; i < viewCount; i ++)
    {
        User *user = self.groupMembers[i];
        /** 创建后一个视图*/
        lastGroupUserView = [XXGJGroupUserView groupUserView:self.groupMembers[i] isGroupOwener:[user.user_id isEqualToNumber:self.group.creator]];
        lastGroupUserView.delegate = self;
        [self.userContentView addSubview:lastGroupUserView];
        
        [lastGroupUserView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.bottom.mas_equalTo(self.userContentView);
            make.left.mas_equalTo(self.userContentView).mas_offset((20+40)*i);
            make.width.mas_equalTo(40);
        }];
    }
    
    self.userContentWidthConstraint.constant = (20+40)*viewCount;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self updateGroupMemeberUI];
    
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    /** 设置 tableView 的footerView*/
    UIView *footerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.tableView.frame.size.width, 80)];
    [footerView setBackgroundColor:[UIColor clearColor]];
    UIButton *deleteBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    /** 设圆角*/
    [deleteBtn.layer setCornerRadius:3];
    [deleteBtn setTitle:@"退出并删除" forState:UIControlStateNormal];
    [deleteBtn setTintColor:[UIColor whiteColor]];
    [deleteBtn setBackgroundImage:[UIImage imageNamed:@"group_btn_delete_normal"] forState:UIControlStateNormal];
    [deleteBtn.titleLabel setFont:[UIFont systemFontOfSize:16]];
    [deleteBtn setBackgroundImage:[UIImage imageNamed:@"group_btn_delete_selected"] forState:UIControlStateSelected];
    [deleteBtn addTarget:self action:@selector(outAndDelGroup:) forControlEvents:UIControlEventTouchUpInside];
    [footerView addSubview:deleteBtn];
    
    [self.tableView setTableFooterView:footerView];
    
    /** 设置退出群组并删除按钮的位置*/
    [deleteBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.mas_equalTo(footerView);
    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - setter and getter
- (void)setGroup:(Group *)group
{
    _group = group;
    /** 设置群成员视图样式*/
    [self updateGroupMemeberUI];
    /** 刷新群组用户信息*/
    [self updateGroupInfo];
    [self updateGroupMemeberInfo:1];
}

- (void)setClearBlock:(ClearBlock)clearBlock
{
    _clearBlock = clearBlock;
}

#pragma mark - lazy method

#pragma mark - open method

#pragma mark - private method
#warning 待完善模块
/**
 重新处理群成员数组，将群管理员剔除

 @return 新生成的数组
 */
- (NSArray *)groupMemberArray
{
    NSMutableArray *groupMemberArray = self.groupMembers.mutableCopy;
    for (User *memberUserItem in self.groupMembers)
    {
        if ([memberUserItem.user_id isEqualToNumber:self.group.creator])
        {
            [groupMemberArray removeObject:memberUserItem];
            break;
        }
    }
    return groupMemberArray.copy;
}

- (IBAction)addMember:(id)sender
{
    XXGJSelectGroupMemberViewController *selectGroupMemberVC = [XXGJSelectGroupMemberViewController selectGroupMemberViewController];
    selectGroupMemberVC.group = self.group;
    selectGroupMemberVC.groupMembersArr = [self.appDelegate.user getUserFriends];
    selectGroupMemberVC.type = XXGJSelectTypeAddGroupMemeber;
    UINavigationController *navigation = [[UINavigationController alloc] initWithRootViewController:selectGroupMemberVC];
    [self presentViewController:navigation animated:YES completion:nil];
}

- (IBAction)removeMember:(id)sender
{
    XXGJSelectGroupMemberViewController *selectGroupMemberVC = [XXGJSelectGroupMemberViewController selectGroupMemberViewController];
    selectGroupMemberVC.group = self.group;
    selectGroupMemberVC.groupMembersArr = [self groupMemberArray];
    selectGroupMemberVC.type = XXGJSelectTypeDeleteGroupMemeber;
    UINavigationController *navigation = [[UINavigationController alloc] initWithRootViewController:selectGroupMemberVC];
    [self presentViewController:navigation animated:YES completion:nil];
}

/**
 群成员列表

 @param sender 按钮
 */
- (IBAction)allMember:(id)sender
{
    XXGJGroupMemberViewController *groupMemberVC = [XXGJGroupMemberViewController groupMemberViewController];
    groupMemberVC.groupMembersArr = self.group.groupMember;
    [self.navigationController pushViewController:groupMemberVC animated:YES];
}
/**
 开启或关闭消息免打扰
 
 @param audioRemind 开关
 */
- (void)switchAction:(UISwitch *)audioRemind
{
    NSDictionary *dict = @{XXGJ_N_PARAM_USERID:self.appDelegate.user.user_id, XXGJ_N_PARAM_FRIENDID:self.group.groupid, XXGJ_N_PARAM_TYPE:@(1), XXGJ_N_PARAM_STATUS:[NSString stringWithFormat:@"%d", audioRemind.on]};
    [MBProgressHUD showLoadHUDIndeterminate:@"设置消息免打扰"];
    [XXGJNetKit setAvoidRemind:dict rBlock:^(id obj, BOOL success, NSError *error) {
        NSDictionary *result = (NSDictionary *)obj;
        if ([result[@"statusText"] isEqualToString:@"avoidRemind success"])
        {
            self.group.avoidRemind = result[@"status"];
            [self.appDelegate saveContext];
            [MBProgressHUD showLoadHUDText:@"消息免打扰设置成功" during:0.25];
        }else
        {
            [MBProgressHUD showLoadHUDText:[NSString stringWithFormat:@"消息免打扰设置失败"] during:0.25];
        }
    }];
}

/**
 退出并删除群组
 
 @param deleteBtn 按钮
 */
- (void)outAndDelGroup:(UIButton *)deleteBtn
{
    XXGJAlertView *alertView = [XXGJAlertView alertViewContent:@"确认退出该群组?" withDelegate:self withObject:nil];
    [alertView setContentName:@"退出" alertIndex:AlertViewIndexConfirm];
    [alertView setTag:1002];
    [alertView showInView:self.view];
}

- (void)updateGroupInfo
{
    NSDictionary *dict = @{XXGJ_N_PARAM_GROUPID:self.group.groupid};
    [XXGJNetKit searchGroup:dict rBlock:^(id obj, BOOL success, NSError *error) {
        /** 更新群组信息*/
        if (obj && [obj[@"statusText"] isEqualToString:@"ok"])
        {
            NSDictionary *groupDict = obj[@"result"];
            self.group.pic    = groupDict[@"pic"];
            self.group.name   = groupDict[@"name"];
            self.group.joinCount    = groupDict[@"joinCount"];
            self.group.introduction = groupDict[@"introduction"];
            
            dispatch_async(dispatch_get_main_queue(), ^{
                [self setNavigationBarTitle:self.group.name];
            });
        }
        
    }];
}

- (void)updateGroupMemeberInfo:(NSUInteger)page
{
    NSLog(@"update group users ....");
    NSDictionary *dict = @{XXGJ_N_PARAM_USERID:self.group.groupid, XXGJ_N_PARAM_RELATIONTYPE:@(1), XXGJ_N_PARAM_CURRENTPAGE:@(page), XXGJ_N_PARAM_PAGESIZE:@(20)};
    /** 获取群成员列表*/
    [XXGJNetKit getFriendList:dict rBlock:^(id obj, BOOL success, NSError *error) {
        if (obj && [obj[@"statusText"] isEqualToString:@"ok"])
        {
            NSDictionary *result = obj[@"result"];
            NSDictionary *list   = result[@"list"];
            NSNumber *totalCount = result[@"totalCount"];
            NSNumber *nextPage   = result[@"nextPage"];
            
            /** 保持群成员*/
            for (NSDictionary *userDict in list)
            {
                /** 首先判断数据库中是否存在*/
                User *groupUser = [self.appDelegate.dbModelManage excuteTable:TABLE_USER predicate:[NSString stringWithFormat:@"user_id==%@", userDict[@"ID"]] limit:1].lastObject;
                if (!groupUser)
                /** 不存在, 就创建*/
                {
                    groupUser = [NSEntityDescription insertNewObjectForEntityForName:TABLE_USER inManagedObjectContext:self.appDelegate.managedObjectContext];
                    groupUser.user_id = userDict[@"ID"];
                    groupUser.avatar  = userDict[@"Avatar"];
                    groupUser.nick_name = userDict[@"NickName"];
                    groupUser.create = userDict[@"Created"];
                }
                
                if(![self.group.users containsObject:groupUser])
                {
                    [self.group addUsersObject:groupUser];
                }
            }
            [self.appDelegate saveContext];
            
            if ([totalCount unsignedIntegerValue] > page * 20 && [nextPage unsignedIntegerValue] != page) {
                [self updateGroupMemeberInfo:[nextPage unsignedIntegerValue]];
            }else
            {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self updateGroupMemeberUI];
                });
            }
        }
    }];
    
}

#pragma mark - delegate
#pragma mark - alert view delegate
- (void)alertView:(XXGJAlertView *)alertView clickAtIndex:(AlertViewIndex)index object:(id)obj
{
    if (alertView.tag==1001 && index==AlertViewIndexConfirm)
    /** 确定删除聊天记录*/
    {
        /** 第一步, 查询用户和好友的聊天记录*/
        NSArray *messageArray = [self.appDelegate.dbModelManage excuteTable:TABLE_MESSAGE predicate:[NSString stringWithFormat:@"targetId==%@", self.group.groupid]];
        /** 遍历删除聊天记录*/
        for (Message *msg in messageArray)
        {
            [self.appDelegate.managedObjectContext deleteObject:msg];
        }
        
        [self.appDelegate saveContext];
        /** 通知刷新界面*/
        if (self.clearBlock) self.clearBlock();
        [MBProgressHUD showLoadHUDText:@"成功清空聊天记录" during:0.25];
    }
    else if (alertView.tag == 1002 && index == AlertViewIndexConfirm)
        /** 退出群组*/
    {
        NSDictionary *dict = @{XXGJ_N_PARAM_USERID:self.appDelegate.user.user_id, XXGJ_N_PARAM_GROUPID:self.group.groupid};
        [MBProgressHUD showLoadHUDIndeterminate:@"退出该群组..."];
        [XXGJNetKit leaveGroup:dict rBlock:^(id obj, BOOL success, NSError *error) {
            NSLog(@"成功退出群组...%@", obj);
            NSDictionary *result = (NSDictionary *)obj;
            if ([result[@"statusText"] isEqualToString:@"leave success"])
                /** 成功退出群组*/
            {
                [self.appDelegate.user removeGroupsObject:self.group];
                [MBProgressHUD showLoadHUDText:@"你已成功退出该群组" during:0.25];
                dispatch_async(dispatch_get_main_queue(), ^{
                   /** 返回到聊天信息列表页面*/
                    [self.navigationController popToRootViewControllerAnimated:YES];
                });
            }else
            {
                NSLog(@"%@", result[@"statusText"]);
                [MBProgressHUD showLoadHUDText:@"退出群组失败,请保证网络正常连接,重新操作" during:0.5];
            }
        }];
    }
    
    [alertView hidden];
}

#pragma mark - group user view delegate
- (void)clickAvatarBtn:(id)groupUserView userInfo:(User *)user
{
    /** 点击, 进入用户详情页*/
    XXGJUserInfoViewController *userInfoVC = [XXGJUserInfoViewController userInfoViewController];
    userInfoVC.user_id = user.user_id;
    [self.navigationController pushViewController:userInfoVC animated:YES];
}

#pragma mark - table view delegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section==2)
    {
        /** 清空聊天记录*/
        XXGJAlertView *alertView = [XXGJAlertView alertViewContent:@"确认清空当前群组的聊天记录?" withDelegate:self withObject:nil];
        [alertView setTag:1001];
        [alertView showInView:self.view];
    }
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 44;
}
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 10;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 3;
}

#pragma makk - table view datasource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section == 1) return 2;
    
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    XXGJGroupItemTableViewCell *cell = [XXGJGroupItemTableViewCell groupItemCell:tableView];
    /** 这里布局群组页面*/
    switch (indexPath.section) {
        case 0:
        {
            [cell setItemTitle:@"消息免打扰"];
            [cell setItemInfo:@""];
            [cell setHiddenBottomLine:NO];
            [cell setItemStyle:GroupItemStyleTitleInfo];
            UISwitch *audioRemind = [[UISwitch alloc] initWithFrame:CGRectZero];
            [audioRemind addTarget:self action:@selector(switchAction:) forControlEvents:UIControlEventValueChanged];
            [audioRemind setOn:[self.group.avoidRemind boolValue] animated:YES];
            [cell.contentView addSubview:audioRemind];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            [audioRemind mas_makeConstraints:^(MASConstraintMaker *make) {
                make.centerY.mas_equalTo(cell.contentView);
                make.right.mas_equalTo(cell.contentView).mas_offset(-10);
            }];
        }
            break;
        case 1:
        {
            if (indexPath.row==0)
                /** 群组名称*/
            {
                [cell setItemTitle:@"群名称"];
                [cell setItemInfo:self.group.name];
                [cell setItemStyle:GroupItemStyleAll];
                [cell setHiddenBottomLine:YES];
                cell.selectionStyle = UITableViewCellSelectionStyleDefault;
            }
            else if (indexPath.row==1)
                /** 群组创建时间*/
            {
                NSDate *createdTime = [NSDate datesinceTimeInterval:[self.group.create longLongValue]];
                NSDateFormatter *formatter = [[NSDateFormatter alloc]init];
                [formatter setDateFormat:@"yyyy/MM/dd"];
                [cell setItemTitle:@"建立时间"];
                [cell setItemInfo:[formatter stringFromDate:createdTime]];
                [cell setItemStyle:GroupItemStyleTitleInfo];
                [cell setHiddenBottomLine:NO];
                cell.selectionStyle = UITableViewCellSelectionStyleNone;
            }
        }
            break;
        case 2:
        {
            [cell setItemTitle:@"清空聊天记录"];
            [cell setItemStyle:GroupItemStyleOnlyTitle];
            [cell setHiddenBottomLine:NO];
            cell.selectionStyle = UITableViewCellSelectionStyleDefault;
        }
            break;
        default:
            break;
    }
    
    [cell setStyle];
    
    return cell;
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
