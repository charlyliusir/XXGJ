//
//  XXGJSelectGroupMemberViewController.m
//  xxdcchat_ios
//
//  Created by 刘朝龙 on 2017/4/4.
//  Copyright © 2017年 刘朝龙. All rights reserved.
//

#import "XXGJSelectGroupMemberViewController.h"
#import "XXGJChatItemTableViewCell.h"
#import "XXGJSearchMemberView.h"
#import "QXYChatViewController.h"
#import <Masonry.h>
#import "Group.h"

@interface XXGJSelectGroupMemberViewController ()<UITextFieldDelegate, UITableViewDelegate, UITableViewDataSource>
@property (strong, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) UITextField *searchTextField;
@property (nonatomic, strong)XXGJSearchMemberView *searchLeftScrollView;
@property (nonatomic, strong)NSMutableDictionary *userModels;
@property (nonatomic, strong)NSMutableArray *selectItemsArray;
@property (nonatomic,   copy)NSArray *keyArray;

@end

@implementation XXGJSelectGroupMemberViewController

+ (instancetype)selectGroupMemberViewController
{
    return [[NSBundle mainBundle] loadNibNamed:NSStringFromClass(self) owner:nil options:nil].lastObject;
}

- (void)setupUI
{
    self.searchLeftScrollView = [[XXGJSearchMemberView alloc] initWithFrame:CGRectZero];
    self.searchTextField = [[UITextField alloc] initWithFrame:CGRectZero];
    [self.searchTextField setPlaceholder:@"搜索"];
    [self.searchTextField setBorderStyle:UITextBorderStyleNone];
    [self.view addSubview:self.searchLeftScrollView];
    [self.view addSubview:self.searchTextField];
    
    [self.searchTextField mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.searchLeftScrollView);
        make.right.mas_equalTo(self.view);
        make.height.mas_offset(60);
        make.left.mas_equalTo(self.searchLeftScrollView.mas_right).mas_offset(5);
    }];
    
    [self.searchLeftScrollView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_offset(64);
        make.left.mas_equalTo(self.view);
        make.height.mas_offset(60);
        make.width.mas_offset(31);
        make.width.mas_lessThanOrEqualTo(300);
    }];
}

- (void)setupNavigationBarUI
{
    [self setNavigationBarTitle:@"选择好友"];
    
    self.navigationItem.leftBarButtonItem  = [[UIBarButtonItem alloc] initWithTitle:@"取消" style:UIBarButtonItemStyleDone target:self action:@selector(cancelAction:)];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"确定" style:UIBarButtonItemStyleDone target:self action:@selector(confirmAction:)];
    [self.navigationItem.rightBarButtonItem setEnabled:NO];
    
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    /** 注册观察者, 如果选择人数等于 1 不让执行网络请求*/
    [self addObserver:self forKeyPath:@"selectItemsArray" options:NSKeyValueObservingOptionNew|NSKeyValueObservingOptionOld context:nil];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    /** 移除观察者模式*/
    [self removeObserver:self forKeyPath:@"selectItemsArray"];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    /** 布局视图*/
    [self setupUI];
    /** 布局导航栏*/
    [self setupNavigationBarUI];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - setter and getter
- (void)setGroupMembersArr:(NSArray *)groupMembersArr
{
    _groupMembersArr = groupMembersArr;
    
    /** 处理数据*/
    [self handleFirstCharacter:_groupMembersArr];
    
    /** 刷新界面*/
    [self.tableView reloadData];
}

#pragma mark - lazy method
- (NSMutableArray *)selectItemsArray
{
    if (!_selectItemsArray)
    {
        _selectItemsArray = [NSMutableArray array];
    }
    return _selectItemsArray;
}

#pragma mark - private
/**
 取消事件
 
 @param leftBarItem 按钮
 */
- (void)cancelAction:(UIBarButtonItem *)leftBarItem
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

/**
 确定时间

 @param rightBarItem 按钮
 */
- (void)confirmAction:(UIBarButtonItem *)rightBarItem
{
    /** 确定事件分三种，创建群组，邀请群友，踢出群成员*/
    NSString *alertMsg = @"确定创建群组?";
    NSString *confirmBtnName = @"创建";
    if (self.type==XXGJSelectTypeAddGroupMemeber)
    {
        alertMsg = @"确定邀请好友入群？";
        confirmBtnName = @"邀请";
    }else if (self.type==XXGJSelectTypeDeleteGroupMemeber)
    {
        alertMsg = @"确定将成员踢出群组？";
        confirmBtnName = @"踢出群组";
    }
    XXGJAlertView *alertView = [XXGJAlertView alertViewContent:alertMsg withDelegate:self withObject:nil];
    [alertView setContentName:confirmBtnName alertIndex:AlertViewIndexConfirm];
    [alertView setTag:1001];
    [alertView showInView:self.view];
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

#pragma mark - addObserver method
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context
{
    if ([keyPath isEqualToString:@"selectItemsArray"])
    {
        User *changValue = nil;
        if ([change[NSKeyValueChangeKindKey] intValue]==2)
            /** 有新值变化, 添加*/
        {
            changValue = [change[NSKeyValueChangeNewKey] lastObject];
            
        }else
            /** 有旧值变化, 删除*/
        {
            changValue = [change[NSKeyValueChangeOldKey] lastObject];
        }
        if (changValue)
        {
            /** 刷新列表*/
            /** 获取用户所在分组*/
            NSString *key = [self firstCharactor:changValue.nick_name];
            NSUInteger section = [self.keyArray indexOfObject:key];
            NSUInteger row     = [self.userModels[key] indexOfObject:changValue];
            NSIndexPath *indexPath = [NSIndexPath indexPathForRow:row inSection:section];
            [self.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
        }
        [self.navigationItem.rightBarButtonItem setEnabled:self.selectItemsArray.count>0];
    }
}

- (NSString *)userIdString
{
    NSMutableString *userIdString = [NSMutableString string];
    for (User *selectUserItem in self.selectItemsArray)
    /** 遍历被选中的数组, 将成员添加到我们需要的数组中*/
    {
        [userIdString appendFormat:@",%@", selectUserItem.user_id];
    }
    [userIdString deleteCharactersInRange:NSMakeRange(0, 1)];
    return userIdString.copy;
}

- (NSArray *)userIdArray
{
    NSMutableArray *userIdArray = @[].mutableCopy; /** 初始化数组*/
    for (User *selectUserItem in self.selectItemsArray)
        /** 遍历被选中的数组, 将成员添加到我们需要的数组中*/
    {
        NSDictionary *dictionary = @{XXGJ_N_PARAM_USERID:selectUserItem.user_id};
        [userIdArray addObject:dictionary];
    }
    
    return userIdArray.copy;
}

/**
 创建群组
 */
- (void)createGroup
{
    [MBProgressHUD showLoadHUDIndeterminate:@"正在加载..."];
    NSDictionary *dict = @{
                           /** 创建人的 user_id*/
                           XXGJ_N_PARAM_CREATEID:self.appDelegate.user.user_id,
                           /** 邀请好友入群, 好友的 user_id*/
                           XXGJ_N_PARAM_GROUPUSERS:[self userIdArray]
                           };
    [XXGJNetKit createGroup:dict rBlock:^(id obj, BOOL success, NSError *error) {
        NSLog(@"创建群操作完毕...:%@", obj);
        NSLog(@"...");
        NSDictionary *result = (NSDictionary *)obj;
        if ([result[@"statusText"] isEqualToString:@"ok"])
        {
            NSDictionary *groupDict = result[@"result"];
            Group *group = [NSEntityDescription insertNewObjectForEntityForName:TABLE_GROUP inManagedObjectContext:self.appDelegate.managedObjectContext];
            group.create  = groupDict[@"created"];
            group.creator = groupDict[@"creator"];
            group.groupid = groupDict[@"iD"];
            group.maxJoin = groupDict[@"maxJoin"];
            group.joinCount = groupDict[@"joinCount"];
            group.name    = groupDict[@"name"];
            group.pic     = groupDict[@"pic"];
            group.introduction = groupDict[@"introduction"];
            group.avoidRemind = @(NO);
            [self.appDelegate.user addGroupsObject:group];
            [self.appDelegate saveContext];
            [MBProgressHUD showLoadHUDText:@"开始群聊" during:0.25];
            dispatch_async(dispatch_get_main_queue(), ^{
               [self dismissViewControllerAnimated:YES completion:^{
                   QXYChatViewController *chatVC = [[QXYChatViewController alloc] init];
                   [chatVC setChatStyle:ChatStyleGroup];
                   [chatVC setChatGroup:group];
                   [self.appDelegate.window.rootViewController.navigationController pushViewController:chatVC animated:YES];
               }];
            });
        }else
        {
            [MBProgressHUD showLoadHUDText:@"建群操作失败,请确定网络正常连接后,重新操作!" during:0.5];
        }
    }];
}

/**
 邀请好友入群
 */
- (void)addGroupMember
{
    [MBProgressHUD showLoadHUDIndeterminate:@"正在加载..."];
    NSDictionary *dict = @{
                           /** 操作邀请好友用户的 user_id*/
                           XXGJ_N_PARAM_USERID:self.appDelegate.user.user_id,
                           /** 邀请进入群的群id*/
                           XXGJ_N_PARAM_GROUPID:self.group.groupid,
                           /** 邀请好友入群, 好友的 user_id*/
                           XXGJ_N_PARAM_FRIENDID:[self userIdString],
                           XXGJ_N_PARAM_ISSYSTEM:@(NO)
                           };
    [XXGJNetKit addGroupMember:dict rBlock:^(id obj, BOOL success, NSError *error) {
        NSLog(@"邀请好友入群操作完毕...:%@", obj);
        NSLog(@"...");
        NSDictionary *result = (NSDictionary *)obj;
        if ([result[@"statusText"] isEqualToString:@"ok"])
        /** 踢人操作成功*/
        {
            for (User *removeUsers in self.selectItemsArray)
            {
                [self.group addUsersObject:removeUsers];
            }
            
            [self.appDelegate saveContext];
            [MBProgressHUD showLoadHUDText:@"已成功邀请选中群成员" during:0.25];
            
            dispatch_async(dispatch_get_main_queue(), ^{
                /** 返回上一页*/
                [self cancelAction:nil];
            });
        }else
        {
            [MBProgressHUD showLoadHUDText:@"邀请操作失败,请确定网络正常连接后,重新操作!" during:0.5];
        }
    }];
}

/**
 踢出群成员
 */
- (void)deleteGroupMember
{
    [MBProgressHUD showLoadHUDIndeterminate:@"正在加载..."];
    NSDictionary *dict = @{
                           /** 操作踢出群组用户的 user_id*/
                           XXGJ_N_PARAM_USERID:self.appDelegate.user.user_id,
                           /** 踢出群的群id*/
                           XXGJ_N_PARAM_GROUPID:self.group.groupid,
                           /** 踢出群组成员, 成员的 user_id*/
                           XXGJ_N_PARAM_FRIENDID:[self userIdString],
                           };
    [XXGJNetKit removeGroupMember:dict rBlock:^(id obj, BOOL success, NSError *error) {
        
        NSDictionary *result = (NSDictionary *)obj;
        if ([result[@"statusText"] isEqualToString:@"remove success"])
            /** 踢人操作成功*/
        {
            for (User *removeUsers in self.selectItemsArray)
            {
                [self.group removeUsersObject:removeUsers];
            }
            
            [self.appDelegate saveContext];
            [MBProgressHUD showLoadHUDText:@"已成功踢出选中群成员" during:0.25];
            
            dispatch_async(dispatch_get_main_queue(), ^{
                /** 返回上一页*/
                [self cancelAction:nil];
            });
        }else
        {
            [MBProgressHUD showLoadHUDText:@"踢出操作失败,请确定网络正常连接后,重新操作!" during:0.5];
        }
        
    }];
}

#pragma mark - delegate
#pragma mark - alert view delegate
- (void)alertView:(XXGJAlertView *)alertView clickAtIndex:(AlertViewIndex)index object:(id)obj
{
    if (alertView.tag==1001&&index==AlertViewIndexConfirm)
        /** 创建，添加，删除操作*/
    {
        if (self.type==XXGJSelectTypeCreateGroup)
        {
            [self createGroup];
        }else if (self.type==XXGJSelectTypeAddGroupMemeber)
        {
            [self addGroupMember];
        }else if (self.type==XXGJSelectTypeDeleteGroupMemeber)
        {
            [self deleteGroupMember];
        }
    }
    
    [alertView hidden];
}

#pragma mark - table view delegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *key = self.keyArray[indexPath.section];
    User *user    = self.userModels[key][indexPath.row];
    if ([self.selectItemsArray containsObject:user])
    {
        [[self mutableArrayValueForKey:@"selectItemsArray"] removeObject:user];
    }else
    {
        [[self mutableArrayValueForKey:@"selectItemsArray"] addObject:user];
    }
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 70;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 20;
}

#pragma makk - table view datasource
- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
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

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return self.keyArray.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSString *key = self.keyArray[section];
    return [self.userModels[key] count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    XXGJChatItemTableViewCell *cell = [XXGJChatItemTableViewCell chatItemCell:self.tableView hasSelectBtn:YES];
    NSString *key = self.keyArray[indexPath.section];
    User *user    = self.userModels[key][indexPath.row];
    cell.itemUser = user;
    cell.chatItem = [XXGJChatItem itemWithName:user.nick_name iconURL:user.avatar isSelected:[self.selectItemsArray containsObject:user]];
    
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
