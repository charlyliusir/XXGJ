//
//  XXGJChatListViewController.m
//  xxdcchat_ios
//
//  Created by 刘朝龙 on 2017/3/15.
//  Copyright © 2017年 刘朝龙. All rights reserved.
//

#import "XXGJChatListViewController.h"
#import "XXGJGroupViewController.h"
#import "XXGJUserInfoViewController.h"
#import "XXGJSelectGroupMemberViewController.h"
#import "XXGJNewViewController.h"
#import "QXYChatViewController.h"
#import "XXGJChatListTableViewCell.h"
#import "XXGJChatItemTableViewCell.h"
#import "XXGJPopUpView.h"
#import "XXGJNewMessage.h"
#import "NewMessage.h"
#import "Message.h"
#import "Group.h"

typedef NS_ENUM(NSInteger, XXGJChatType) {
    XXGJChatTypeMessage,
    XXGJChatTypeFriend
};

@interface XXGJChatListViewController () <UISearchBarDelegate, UITableViewDelegate, UITableViewDataSource, XXGJPopUpViewDelegate>
@property (weak, nonatomic) IBOutlet UISearchBar *findFriendSearchBar;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic, strong)XXGJPopUpView *popupView;
@property (nonatomic,   copy)NSArray *sourceArray;
@property (nonatomic, strong)NSMutableDictionary *userModels;
@property (nonatomic,   copy)NSArray *keyArray;

@property (nonatomic, assign)XXGJChatType chatType;

@property (nonatomic, assign)NSUInteger hasNewMessageCount;

@end

@implementation XXGJChatListViewController

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    /** 移除所有的通知*/
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    // 设置搜索视图中取消按钮样式
    [[UIBarButtonItem appearanceWhenContainedIn: [UISearchBar class], nil] setTintColor:XX_RGBCOLOR_WITHOUTA(188, 188, 188)];
    [[UIBarButtonItem appearanceWhenContainedIn: [UISearchBar class], nil] setTitle:@"取消"];
    /** 添加消息更新通知*/
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(readNewMessage:) name:XXGJ_SOCKET_REVE_NEW_MESSAGE object:nil];
    
    self.chatType = XXGJChatTypeMessage;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    /** 设置 tableview 样式*/
    [self.tableView setSectionIndexColor:XX_NAVIGATIONBAR_TITLECOLOR];
    [self.tableView setSectionIndexBackgroundColor:[UIColor clearColor]];
    [self.tableView setSectionIndexTrackingBackgroundColor:[UIColor clearColor]];
    /** 改变搜索框背景颜色*/
    [self.findFriendSearchBar chageTextFieldBgColor:[UIColor whiteColor]];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - lazy method
- (XXGJPopUpView *)popupView
{
    if (!_popupView)
    {
        _popupView = [[XXGJPopUpView alloc] initWithFrame:[UIScreen mainScreen].bounds];
        [_popupView setDelegate:self];
    }
    return _popupView;
}

#pragma mark - open method

#pragma mark - private method
- (IBAction)showPopUpView:(id)sender
{
    [self.popupView showView];
}

- (XXGJNewMessage *)groupMessagesInfo:(NewMessage *)newMessage
{
    XXGJNewMessage *message = nil;
    /** 第一步, 从数据库中读取群组*/
    Group *group = [self.appDelegate.dbModelManage excuteTable:TABLE_GROUP predicate:[NSString stringWithFormat:@"groupid==%@", newMessage.targetId] limit:1].lastObject;
    if (group && group.users.count <= 0)
        /** 没有成员的群组, 直接删除*/
    {
        if ([self.appDelegate.user.groups containsObject:group])
        {
            [self.appDelegate.user removeGroupsObject:group];
        }
        /** 删除群组消息*/
        NSArray *groupMsg = [self.appDelegate.dbModelManage excuteTable:TABLE_MESSAGE predicate:[NSString stringWithFormat:@"targetId==%@ and isGroup=='1'", newMessage.targetId]];
        for (Message *msg in groupMsg)
        {
            [self.appDelegate.managedObjectContext deleteObject:msg];
        }
        [self.appDelegate.managedObjectContext deleteObject:group];
        [self.appDelegate saveContext];
        return message;
    }
    if (group)
    {
        message = [XXGJNewMessage newMessageWithObject:group newMessage:newMessage];
    }
    /** 第三步、判断群组和好友的关系*/
//    if ([self.appDelegate.user.groups containsObject:group])
//    {
    /** 第四步、加载群组消息*/
    
    //    }
    
    return message;
}

- (XXGJNewMessage *)userMessagesInfo:(NewMessage *)newMessage
{
    XXGJNewMessage *message = nil;
    if (newMessage.targetId&&newMessage.userId&&newMessage.uuid&&newMessage.content)
    {
        /** 第一步, 从数据库中读取群组*/
        User *friend = [self.appDelegate.dbModelManage excuteTable:TABLE_USER predicate:[NSString stringWithFormat:@"user_id==%@", newMessage.targetId] limit:1].lastObject;
        
        /** 第四步、加载群组消息*/
        message = [XXGJNewMessage newMessageWithObject:friend newMessage:newMessage];
        
    }else
    {
        [self.appDelegate.managedObjectContext deleteObject:newMessage];
        [self.appDelegate saveContext];
    }
    
    
    return message;
}

- (void)reloadData
{
    /** 注意：数据库操作使用同步请求，否则容易出现Crash*/
    /** 注意：网络请求放到异步操作，否则一定会出现Crash*/
    self.sourceArray = [NSArray array];
    self.keyArray    = [NSArray array];
    self.userModels  = [NSMutableDictionary dictionary];
    
    if (_chatType == XXGJChatTypeFriend)
    {
        self.sourceArray = [self.appDelegate.user getUserFriends];
        [self handleFirstCharacter:self.sourceArray];
    }
    else if (_chatType == XXGJChatTypeMessage)
    {
        NSMutableArray *msgSourceArray = [NSMutableArray array];
        /** 当前用户的用户id*/
        NSNumber *userId       = self.appDelegate.user.user_id;
        /** 第一步:获取所有信息分组*/
        NSArray *newMessagesArray = [self.appDelegate.dbModelManage excuteTable:TABLE_NEW_MESSAGE predicate:[NSString stringWithFormat:@"userId==%@",userId] offset:0 limit:0 order:@"update" ascending:NO];
        /** 第二步:获取所有群组和用户列表消息*/
        for (NewMessage *newMessage in newMessagesArray)
        {
            if ([newMessage.isGroup isEqualToNumber:@(YES)])
            {
                // 获取消息所属对象、最新一条消息以及多条未读消息
                XXGJNewMessage *message = [self groupMessagesInfo:newMessage];
                if (message)
                {
                    [msgSourceArray addObject:message];
                }
            }
            else
            {
                XXGJNewMessage *message = [self userMessagesInfo:newMessage];
                if (message)
                {
                    [msgSourceArray addObject:message];
                }
            }
        }
        
        self.sourceArray = msgSourceArray.copy;
    }
    dispatch_async(dispatch_get_main_queue(), ^{
        if (self.hasNewMessageCount > 1)
        {
            [self reloadData];
        }
        else
        {
            [self.tableView reloadData];
        }
    });
    
}

- (void)setChatType:(XXGJChatType)chatType
{
    _chatType = chatType;
    
    if (_chatType == XXGJChatTypeMessage)
    {
        [self setNavigationBarTitle:@"交流"];
        // 修改 navigation bar 按钮的图片
        [self.navigationItem.leftBarButtonItem setImage:[UIImage imageNamed:@"navigationbar_btn_friend_list"]];
    }
    else if(_chatType == XXGJChatTypeFriend)
    {
        [self setNavigationBarTitle:@"通讯录"];
        // 修改 navigation bar 按钮的图片
        [self.navigationItem.leftBarButtonItem setImage:[UIImage imageNamed:@"btn_back_icon"]];
    }
    
    [self reloadData];
}

- (void)backMethod:(UIBarButtonItem *)barButtonItem {
    
    [self.findFriendSearchBar resignFirstResponder];
    
    if (self.chatType == XXGJChatTypeMessage) {
        self.chatType = XXGJChatTypeFriend;
    }else if(self.chatType == XXGJChatTypeFriend){
        self.chatType = XXGJChatTypeMessage;
    }
    
}

- (void)handleFirstCharacter:(NSArray *)userArray
{
    self.userModels = [NSMutableDictionary dictionary];
    for (User *user in userArray) {
        NSString *key = nil;
        if (user.nick_name) {
            key = [self firstCharactor:user.nick_name];
        }else {
            key = @"#";
        }
        NSMutableArray *value = self.userModels[key];
        if (value.count > 0) {
            [value addObject:user];
            [value sortUsingComparator:^NSComparisonResult(id  _Nonnull obj1, id  _Nonnull obj2) {
                User *user1 = (User *)obj1;
                User *user2 = (User *)obj2;
                NSString *name1 = user1.nick_name;
                NSString *name2 = user2.nick_name;
                return [name1 compare:name2];
            }];
        }else {
            NSMutableArray *tmpArr = [NSMutableArray array];
            [tmpArr addObject:user];
            [self.userModels setValue:tmpArr forKey:key];
        }
    }
    self.keyArray = [self.userModels allKeys].mutableCopy;
    if (self.keyArray.count>1) {
        self.keyArray = [self.keyArray sortedArrayUsingComparator:^NSComparisonResult(NSString* key1, NSString* key2) {
            return [key1 compare:key2];
        }];
    }
    
}

//获取拼音首字母(传入汉字字符串, 返回大写拼音首字母)
- (NSString *)firstCharactor:(NSString *)aString
{
    //转成了可变字符串
    NSMutableString *str = [NSMutableString stringWithString:aString];
    //先转换为带声调的拼音
    CFStringTransform((CFMutableStringRef)str,NULL, kCFStringTransformMandarinLatin,NO);
    //再转换为不带声调的拼音
    CFStringTransform((CFMutableStringRef)str,NULL, kCFStringTransformStripDiacritics,NO);
    //转化为大写拼音
    NSString *pinYin = [str capitalizedString];
    //获取并返回首字母
    return [pinYin substringToIndex:1];
}

- (UITableViewCell *)cellForFriendUIAtIndexPath:(NSIndexPath *)indexPath
{
    XXGJChatItemTableViewCell *cell = [XXGJChatItemTableViewCell chatItemCell:self.tableView hasSelectBtn:NO];
    NSString *key = self.keyArray[indexPath.section];
    User *user    = self.userModels[key][indexPath.row];
    cell.chatItem = [XXGJChatItem itemWithName:user.nick_name iconName:nil iconURL:user.avatar];
    
    return cell;
}

- (UITableViewCell *)cellForMessageUIAtIndexPath:(NSIndexPath *)indexPath
{
    /** section 0 添加默认两个 cell-- 新朋友 和 群聊*/
    if (indexPath.section == 0)
    {
        XXGJChatItemTableViewCell *cell = [XXGJChatItemTableViewCell chatItemCell:self.tableView hasSelectBtn:NO];
        
        if (indexPath.row == 0) {
            cell.chatItem = [XXGJChatItem itemWithName:@"新的朋友" iconName:@"chat_icon_new_friend" iconURL:nil];
        }else if (indexPath.row == 1){
            cell.chatItem = [XXGJChatItem itemWithName:@"群聊" iconName:@"chat_icon_group_friend" iconURL:nil];
        }
        
        return cell;
        
    }else
    {
        NSString *chatItemName = nil; /** cell 中用户或群组的名字*/
        NSString *chatItemIcon = nil; /** cell 中用户或群组的头像*/
        NSString *chatItemContent = nil; /** cell 中用户或群组的聊天信息*/
        NSString *chatItemTime = nil; /** cell 中时间的显示*/
        NSNumber *newMessageCount = 0; /** 聊天中最新消息数量*/
        NSNumber *avoidRemind = @(NO);
    
        /** 获取对应 cell 的数据*/
        XXGJNewMessage *newMessage = self.sourceArray[indexPath.row];
        /** 获取数据对应的对象 */
        chatItemContent  = newMessage.tNewMessage.content;
        chatItemTime     = [NSDate dateForSpecString:[newMessage.tNewMessage.update longLongValue]];
        newMessageCount  = newMessage.tNewMessage.reveCount;
        if ([newMessage.tNewMessage.isGroup isEqualToNumber:@(YES)])
        {
            Group *msgGroup = newMessage.msgObject;
            chatItemName    = msgGroup.name;
            chatItemIcon    = msgGroup.pic;
            avoidRemind     = msgGroup.avoidRemind;
        }else
        {
            User *msgUser = newMessage.msgObject;
            chatItemName  = msgUser.nick_name;
            chatItemIcon  = msgUser.avatar;
            avoidRemind     = msgUser.avoidRemind;
        }
        
        XXGJChatListTableViewCell *cell = [XXGJChatListTableViewCell chatItemListCell:self.tableView];
        
        cell.chatItemList = [XXGJChatItemList chatItemListWithName:chatItemName icon:chatItemIcon info:chatItemContent time:chatItemTime newMessageCount:[newMessageCount integerValue] avoidRemind:[avoidRemind boolValue]];
        
        return cell;
        
    }
    
    return nil;
}

- (void)didSelectMessageRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section==0&&indexPath.row==0) {
        XXGJNewViewController *newFriendVC = [XXGJNewViewController newFriendViewController];
        newFriendVC.hidesBottomBarWhenPushed = YES;
        [self.navigationController pushViewController:newFriendVC animated:YES];
        self.hidesBottomBarWhenPushed = NO;
    }else if (indexPath.section==0&&indexPath.row==1){
        XXGJGroupViewController *groupVC = [XXGJGroupViewController groupViewController];
        [groupVC setHidesBottomBarWhenPushed:YES];
        [self.navigationController pushViewController:groupVC animated:YES];
        [self setHidesBottomBarWhenPushed:NO];
    }else{
        
        /** 先获取 cell 的信息*/
        XXGJNewMessage *newMessage = self.sourceArray[indexPath.row];
        
        QXYChatViewController *chatVC = [[QXYChatViewController alloc] init];
        [chatVC setHidesBottomBarWhenPushed:YES];
        if ([newMessage.tNewMessage.isGroup isEqualToNumber:@(YES)]) {
            [chatVC setChatGroup:newMessage.msgObject];
        }
        else
        {
            [chatVC setChatUser:newMessage.msgObject];
        }
        [self.navigationController pushViewController:chatVC animated:YES];
        [self setHidesBottomBarWhenPushed:NO];
    }
    
}

- (void)didSelectFriendRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *key = self.keyArray[indexPath.section];
    User *uFriend    = self.userModels[key][indexPath.row];
    XXGJUserInfoViewController *userInfoVC = [XXGJUserInfoViewController userInfoViewController];
    userInfoVC.user_id = uFriend.user_id;
    userInfoVC.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:userInfoVC animated:YES];
    self.hidesBottomBarWhenPushed = NO;
}

#pragma mark - notify method
- (void)readNewMessage:(NSNotification *)notify
{
    if (_chatType==XXGJChatTypeMessage)
    {
        [self reloadData];
    }
    
    return;
}


#pragma mark - delegate
#pragma mark - delegate pop up view delegate
- (void)tapPopupItemView:(XXGJPopUpView *)popupView item:(XXGJPopupItem)popupItem
{
    if (popupItem==XXGJPopupItemCreateGroup)
    {
        XXGJSelectGroupMemberViewController *selectGroupMemberVC = [XXGJSelectGroupMemberViewController selectGroupMemberViewController];
        selectGroupMemberVC.groupMembersArr = self.appDelegate.user.getUserFriends;
        selectGroupMemberVC.type = XXGJSelectTypeCreateGroup;
        UINavigationController *navigation = [[UINavigationController alloc] initWithRootViewController:selectGroupMemberVC];
        [self presentViewController:navigation animated:YES completion:nil];
    }
}

#pragma mark - search bar delegate
- (BOOL)searchBarShouldBeginEditing:(UISearchBar *)searchBar
{
    [self.findFriendSearchBar setShowsCancelButton:YES];
    
    return YES;
}

- (BOOL)searchBarShouldEndEditing:(UISearchBar *)searchBar
{
    [self.findFriendSearchBar setShowsCancelButton:NO];
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
    [self.findFriendSearchBar resignFirstResponder];
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

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if (_chatType==XXGJChatTypeMessage&&section==0) {
        return 0;
    }
    return 20;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (_chatType==XXGJChatTypeMessage) {
        [self didSelectMessageRowAtIndexPath:indexPath];
    }else{
        [self didSelectFriendRowAtIndexPath:indexPath];
    }
    /** 取消选中状态*/
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
}

#pragma mark - table view datasource
- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    if (_chatType == XXGJChatTypeFriend) {
        //标题背景
        UIView *contentView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 30)];
        [contentView setBackgroundColor:XX_TABBAR_TINTCOLOR];
        UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(15, 3.5, 200, 15)];
        [titleLabel setText:self.keyArray[section]];
        [titleLabel setTextColor:XX_NAVIGATIONBAR_TITLECOLOR];
        [titleLabel setFont:[UIFont systemFontOfSize:14]];
        [contentView addSubview:titleLabel];
        return contentView;
    }
    
    return nil;
}

//- (nullable NSArray<NSString *> *)sectionIndexTitlesForTableView:(UITableView *)tableView
//{
//    if (_chatType == XXGJChatTypeFriend) {
//        return self.keyArray;
//    }
//
//    return nil;
//}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    if (_chatType == XXGJChatTypeFriend) {
        return self.keyArray.count;
    }else{
        return self.sourceArray.count > 0 ? 2 : 1;
    }
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (_chatType == XXGJChatTypeFriend) {
        NSString *key = self.keyArray[section];
        return [self.userModels[key] count];
    }
    
    return section == 0 ? 2 : self.sourceArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    if (_chatType == XXGJChatTypeFriend)
    {
        return [self cellForFriendUIAtIndexPath:indexPath];
    }
    else if (_chatType == XXGJChatTypeMessage)
    {
        return [self cellForMessageUIAtIndexPath:indexPath];
    }
    
    return nil;
}

//索引列点击事件

-(NSInteger)tableView:(UITableView *)tableView sectionForSectionIndexTitle:(NSString *)title atIndex:(NSInteger)index

{
    //点击索引，列表跳转到对应索引的行
    [tableView
     scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:index]
     atScrollPosition:UITableViewScrollPositionTop animated:YES];
    
    return index;
}

#pragma mark - scroll delegate
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    [self.findFriendSearchBar resignFirstResponder];
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
