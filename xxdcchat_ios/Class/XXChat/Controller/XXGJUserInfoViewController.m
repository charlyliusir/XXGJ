//
//  XXGJUserInfoViewController.m
//  xxdcchat_ios
//
//  Created by 刘朝龙 on 2017/3/27.
//  Copyright © 2017年 刘朝龙. All rights reserved.
//

#import "XXGJUserInfoViewController.h"
#import "XXGJAddMessageViewController.h"
#import "QXYChatViewController.h"
#import "XXGJAlertView.h"
#import <UIImageView+WebCache.h>
#import <Masonry.h>

@interface XXGJUserInfoViewController () <XXGJAlertViewDelegate>
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *deleteBtnHeightConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *lineHeightConstraint;
@property (weak, nonatomic) IBOutlet UIImageView *avatarImageView;
@property (weak, nonatomic) IBOutlet UILabel *userNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *mobileNumberLabel;
@property (weak, nonatomic) IBOutlet UILabel *nickNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *userLocation;
@property (weak, nonatomic) IBOutlet UILabel *userSexLabel;
@property (weak, nonatomic) IBOutlet UIButton *operationBtn;
@property (weak, nonatomic) IBOutlet UILabel *reMarkLabel;
@property (weak, nonatomic) IBOutlet UIView *deleteBtn;
@property (nonatomic, strong)User *user;

@end

@implementation XXGJUserInfoViewController
+ (instancetype)userInfoViewController
{
    return [[[NSBundle mainBundle] loadNibNamed:NSStringFromClass(self) owner:nil options:nil] lastObject];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    /** 显示 Navigation Bar*/
    [self.navigationController setNavigationBarHidden:NO];
    
    self.user = [self.appDelegate.dbModelManage excuteTable:TABLE_USER predicate:[NSString stringWithFormat:@"user_id==%@", self.user_id] limit:1].lastObject;
    if (self.user) [self updateUI];
    
    /** 网络请求用户新数据, 然后更新*/
    [self updateUserInfo];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - lazy method

#pragma mark - setter and getter

#pragma mark - private method

- (void)updateUI
{
    /** 更新界面*/
    if (_user.avatar)
    {
        [self.avatarImageView sd_setImageWithURL:[NSURL URLWithString:[XXGJ_N_BASE_IMAGE_URL stringByAppendingString:_user.avatar]] placeholderImage:[UIImage imageNamed:@""]];
    }
    
    [self.userNameLabel setText:_user.nick_name];
    [self.reMarkLabel setText:_user.nick_name];
    [self.nickNameLabel setText:[NSString stringWithFormat:@"%@", _user.user_id]];
    if (_user.mobile)
    {
        [self.mobileNumberLabel setText:_user.mobile];
    }
    if (_user.address)
    {
        [self.userLocation setText:_user.address];/** 需要进行转换*/
    } else if (_user.location)
    {
        [self.userLocation setText:[NSString getCityName:_user.location]];
    }
    if (_user.sex)
    {
        [self.userSexLabel setText:_user.sex];
    }
    
    if ([self.appDelegate.user.friends containsObject:_user])
    {
        [self.operationBtn setTitle:@"发送消息" forState:UIControlStateNormal];
        [self.operationBtn setSelected:YES];
        self.deleteBtnHeightConstraint.constant = 44.0f;
        self.lineHeightConstraint.constant = 1.0f;
        [self.deleteBtn setHidden:NO];
    }
    else
    {
        [self.operationBtn setTitle:@"添加到通讯录" forState:UIControlStateNormal];
        [self.operationBtn setSelected:NO];
        self.deleteBtnHeightConstraint.constant = 0.0f;
        self.lineHeightConstraint.constant = 0.0f;
        [self.deleteBtn setHidden:YES];
    }
    [self setNavigationBarTitle:self.user.nick_name];
}

- (void)updateUserInfo
{
    NSDictionary *dict = @{XXGJ_N_PARAM_USERID:self.user_id};
    [XXGJNetKit getFriend:dict rBlock:^(id obj, BOOL success, NSError *error) {
        NSDictionary *res = (NSDictionary *)obj;
        if (success && [res[@"statusText"] isEqualToString:@"ok"])
        {
            NSDictionary *result = res[@"result"];
            self.user.avatar = result[@"Avatar"];
            self.user.nick_name = result[@"NickName"];
            self.user.location  = result[@"area"];
            self.user.address   = result[@"address"];
            self.user.mobile    = result[@"mobile"];
            self.user.sex       = [result[@"sex"] isEqualToString:@"Sex-male"] ? @"男" : @"女";
            NSLog(@"address:%@", result[@"address"]);
            
            [self.appDelegate saveContext];
            
            [self updateUI];
        }
    }];
}
- (IBAction)deleteFriend:(id)sender {
    
    NSString *addMessage = [NSString stringWithFormat:@"是否删除好友 %@!", self.user.nick_name];
    /** MAKE-DO:设置是否添加操作*/
    XXGJAlertView *alertView = [XXGJAlertView alertViewContent:addMessage withDelegate:self withObject:nil];
    [alertView setContentName:@"删除" alertIndex:AlertViewIndexConfirm];
    alertView.tag = 1002;
    [alertView showInView:self.view];
    
}

- (IBAction)operateAction:(id)sender {
    
    if (self.operationBtn.selected)
        /** 操作按钮如果是点击状态, 进入聊天界面*/
    {
        QXYChatViewController *chatVC = [[QXYChatViewController alloc] init];
        [chatVC setChatUser:self.user];
        [self.navigationController pushViewController:chatVC animated:YES];
    }
    else
        /** 操作按钮如果是未点击状态, 添加对方为好友, 发送添加好友命令*/
    {
        /** MAKE-DO:*/
        if ([self.user.user_id isEqualToNumber:self.appDelegate.user.user_id])
        {
            [MBProgressHUD showLoadHUDText:@"不能添加自己为好友" during:0.5];
            
            return;
        }
        else
        {
            XXGJAddMessageViewController *addMessageVC = [XXGJAddMessageViewController addMessageViewController];
            addMessageVC.nFriend = self.user;
            [self.navigationController pushViewController:addMessageVC animated:YES];
        }
        
    }
    
}

#pragma mark - delegate
#pragma mark - alert delegate
- (void)alertView:(XXGJAlertView *)alertView clickAtIndex:(AlertViewIndex)index object:(id)obj
{
    if (index == AlertViewIndexConfirm) {
        if (alertView.tag == 1001)
            /** 添加好友*/
        {

        }
        else if (alertView.tag == 1002)
            /** 删除好友*/
        {
            NSDictionary *dict = @{XXGJ_N_PARAM_USERID:self.appDelegate.user.user_id, XXGJ_N_PARAM_TARGETID:self.user.user_id};
            [XXGJNetKit deleteFriend:dict rBlock:^(id obj, BOOL success, NSError *error) {
                NSLog(@".. %@", obj);
                if (obj && [obj[@"statusText"] isEqualToString:@"ok"])
                {
                    [self.appDelegate.user removeFriendsObject:self.user];
                    [self updateUI];
                    /** 解除本地关系*/
                    [MBProgressHUD showLoadHUDCustomImage:successHUDName title:@"成功删除该好友"];
                }
                else
                {
                    [MBProgressHUD showLoadHUDText:@"删除好友命令发送失败, 请检查当前网络状态" during:0.25];
                }
            }];
        }
    }
    
    [alertView hidden];
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
