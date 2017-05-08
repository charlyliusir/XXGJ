//
//  XXGJChatFriendInfoViewController.m
//  xxdcchat_ios
//
//  Created by 刘朝龙 on 2017/3/31.
//  Copyright © 2017年 刘朝龙. All rights reserved.
//

#import "XXGJChatFriendInfoViewController.h"
#import "XXGJSelectGroupMemberViewController.h"
#import "XXGJUserInfoViewController.h"
#import <UIButton+WebCache.h>
#import <Masonry.h>
#import "Message.h"

@interface XXGJChatFriendInfoViewController () <UITableViewDelegate, UITableViewDataSource>
@property (weak, nonatomic) IBOutlet UIButton *userAvatarImageView;
@property (weak, nonatomic) IBOutlet UILabel *userNameLabel;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic, copy) ClearBlock clearBlock;
@end

@implementation XXGJChatFriendInfoViewController
+ (instancetype)chatFriendInfoViewController
{
    return [[NSBundle mainBundle] loadNibNamed:NSStringFromClass(self) owner:nil options:nil].lastObject;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self.tableView setTableFooterView:[UIView new]];
    [self.tableView setScrollEnabled:NO];
    [self setNavigationBarTitle:@"聊天设置"];
}

- (void)setUser:(User *)user
{
    _user = user;
    
    NSString *placeholderString = @"placeholder_user_female_icon";
    if ([_user.sex isEqualToString:@"男"]) {
        placeholderString = @"placeholder_user_female_icon";
    }
    NSString *userIcon = _user.avatar;
    if (userIcon) {
        [self.userAvatarImageView sd_setImageWithURL:[NSURL URLWithString:[XXGJ_N_BASE_IMAGE_URL stringByAppendingPathComponent:_user.avatar]] forState:UIControlStateNormal placeholderImage:[UIImage imageNamed:placeholderString]];
    }else{
        [self.userAvatarImageView setImage:[UIImage imageNamed:placeholderString] forState:UIControlStateNormal];
    }
    
    
    [self.userNameLabel setText:_user.nick_name];
}

- (void)setClearBlock:(ClearBlock)clearBlock
{
    _clearBlock = clearBlock;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - private method
- (IBAction)goUserInfoAction:(id)sender {
    
    XXGJUserInfoViewController *userInfoVC = [XXGJUserInfoViewController userInfoViewController];
    userInfoVC.user_id = self.user.user_id;
    [self.navigationController pushViewController:userInfoVC animated:YES];
    
}

/**
 创建新群组

 @param sender btn
 */
- (IBAction)creatNewGroup:(id)sender
{
    XXGJSelectGroupMemberViewController *selectGroupMemberVC = [XXGJSelectGroupMemberViewController selectGroupMemberViewController];
    selectGroupMemberVC.groupMembersArr = self.appDelegate.user.getUserFriends;
    selectGroupMemberVC.type = XXGJSelectTypeCreateGroup;
    UINavigationController *navigation = [[UINavigationController alloc] initWithRootViewController:selectGroupMemberVC];
    [self presentViewController:navigation animated:YES completion:nil];
}

/**
 设置消息免打扰

 @param audioRemind 是否开启消息免打扰
 */
- (void)switchAction:(UISwitch *)audioRemind
{
    NSDictionary *dict = @{XXGJ_N_PARAM_USERID:self.appDelegate.user.user_id, XXGJ_N_PARAM_FRIENDID:self.user.user_id, XXGJ_N_PARAM_TYPE:@(0), XXGJ_N_PARAM_STATUS:[NSString stringWithFormat:@"%d", audioRemind.on]};
    [MBProgressHUD showLoadHUDIndeterminate:@"设置消息免打扰"];
    [XXGJNetKit setAvoidRemind:dict rBlock:^(id obj, BOOL success, NSError *error) {
        NSLog(@"set audio remind .. %@", obj);
        NSDictionary *result = (NSDictionary *)obj;
        if ([result[@"statusText"] isEqualToString:@"avoidRemind success"])
        {
            self.user.avoidRemind = result[@"status"];
            [self.appDelegate saveContext];
            [MBProgressHUD showLoadHUDText:@"消息免打扰设置成功" during:0.25];
        }else
        {
            [MBProgressHUD showLoadHUDText:[NSString stringWithFormat:@"消息免打扰设置失败"] during:0.25];
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
        NSArray *messageArray = [self.appDelegate.dbModelManage excuteTable:TABLE_MESSAGE predicate:[NSString stringWithFormat:@"targetId==%@", self.user.user_id]];
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
    
    [alertView hidden];
}
#pragma mark - table view delegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 1)
    {
        /** 清空聊天记录*/
        XXGJAlertView *alertView = [XXGJAlertView alertViewContent:@"确认清空当前好友的聊天记录?" withDelegate:self withObject:nil];
        [alertView setTag:1001];
        [alertView showInView:self.view];
    }
    
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
}
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 44;
}
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 10;
}

#pragma mark - table view datasource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 1;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cell"];
        [cell.textLabel setTextColor:XX_RGBCOLOR_WITHOUTA(51, 51, 51)];
        [cell.textLabel setFont:[UIFont systemFontOfSize:15]];
        /** 添加上下边线*/
        UIView *topLineView = [[UIView alloc] initWithFrame:CGRectZero];
        UIView *bottomLineView = [[UIView alloc] initWithFrame:CGRectZero];
        [topLineView setBackgroundColor:XX_RGBCOLOR_WITHOUTA(224,224,224)];
        [bottomLineView setBackgroundColor:XX_RGBCOLOR_WITHOUTA(224,224,224)];
        [cell.contentView addSubview:topLineView];
        [cell.contentView addSubview:bottomLineView];
        [topLineView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(cell.contentView);
            make.left.right.mas_equalTo(cell.contentView);
            make.height.mas_equalTo(1);
        }];
        [bottomLineView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.bottom.mas_equalTo(cell.contentView);
            make.left.right.mas_equalTo(cell.contentView);
            make.height.mas_equalTo(1);
        }];
    }
    if (indexPath.section == 0)
    {
        [cell.textLabel setText:@"开启消息免打扰"];
        UISwitch *audioRemind = [[UISwitch alloc] initWithFrame:CGRectZero];
        [audioRemind addTarget:self action:@selector(switchAction:) forControlEvents:UIControlEventValueChanged];
        [audioRemind setOn:[self.user.avoidRemind boolValue] animated:YES];
        [cell.contentView addSubview:audioRemind];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        [audioRemind mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerY.mas_equalTo(cell.contentView);
            make.right.mas_equalTo(cell.contentView).mas_offset(-10);
        }];
    }
    else if(indexPath.section == 1)
    {
        [cell.textLabel setText:@"清空聊天记录"];
        cell.accessoryView = nil;
        cell.selectionStyle = UITableViewCellSelectionStyleDefault;
    }
    
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
