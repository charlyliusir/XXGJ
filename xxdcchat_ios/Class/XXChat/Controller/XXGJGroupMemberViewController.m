//
//  XXGJGroupMemberViewController.m
//  xxdcchat_ios
//
//  Created by 刘朝龙 on 2017/4/3.
//  Copyright © 2017年 刘朝龙. All rights reserved.
//

#import "XXGJGroupMemberViewController.h"
#import "XXGJChatItemTableViewCell.h"
#import "XXGJUserInfoViewController.h"

@interface XXGJGroupMemberViewController () <UITableViewDelegate, UITableViewDataSource>
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic, strong)NSMutableDictionary *userModels;
@property (nonatomic,   copy)NSArray *keyArray;

@end

@implementation XXGJGroupMemberViewController

+ (instancetype)groupMemberViewController
{
    return [[NSBundle mainBundle] loadNibNamed:NSStringFromClass(self) owner:nil options:nil].lastObject;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    /** 设置导航栏标题*/
    [self setNavigationBarTitle:@"群人员"];
    
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

#pragma mark - private
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

#pragma mark - delegate
#pragma mark - table view delegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *key     = self.keyArray[indexPath.section];
    User *groupMember = self.userModels[key][indexPath.row];
    XXGJUserInfoViewController *userInfoVC = [XXGJUserInfoViewController userInfoViewController];
    userInfoVC.user_id = groupMember.user_id;
    [self.navigationController pushViewController:userInfoVC animated:YES];
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
    XXGJChatItemTableViewCell *cell = [XXGJChatItemTableViewCell chatItemCell:self.tableView hasSelectBtn:NO];
    NSString *key = self.keyArray[indexPath.section];
    User *user    = self.userModels[key][indexPath.row];
    cell.chatItem = [XXGJChatItem itemWithName:user.nick_name iconName:nil iconURL:user.avatar];
    
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
