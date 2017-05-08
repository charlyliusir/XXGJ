//
//  XXGJTabBarController.m
//  xxdcchat_ios
//
//  Created by 刘朝龙 on 2017/3/15.
//  Copyright © 2017年 刘朝龙. All rights reserved.
//

#import "XXGJTabBarController.h"
#import "XXGJChatListViewController.h"
#import "XXGJWebViewController.h"
#import "AppDelegate.h"
#import "XXGJAlertView.h"
#import "Group.h"
#import "Message.h"

@interface XXGJTabBarController () <UITabBarControllerDelegate>
@property (nonatomic, strong)AppDelegate *appDelegate;
@end

@implementation XXGJTabBarController

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    self.appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    /** 1.添加网络监听*/
//    NSNumber *time = self.appDelegate.user.update;
    
//    if (!time||[NSDate isOverDays:7*24*60*60 afterTime:[time doubleValue]]) {
        /** 2.获取好友信息*/
        [[XXGJUserRequestManager sharedRequestMananger] updateFriend];
        /** 3.获取群组信息*/
        [[XXGJUserRequestManager sharedRequestMananger] updateGroup];
//    }
    
    // 注册通知[用户登录通知]
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(login) name:XXGJ_SOCKET_CONNECT_HEART object:nil];
    // 注册通知[异地登录通知]
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(outLoginNotification) name:XXGJ_SOCKET_OTHER_LOGIN_MESSAGE object:nil];
    
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self setDelegate:self];
    self.appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    [self.appDelegate.socketManage startListenChatMessage];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - open method

#pragma mark - private method
- (void)tabBarController:(UITabBarController *)tabBarController didSelectViewController:(UIViewController *)viewController
{
    UINavigationController *navigationController = (UINavigationController *)viewController;
    if (tabBarController.selectedIndex==1)
        /** 跳转到商城界面*/
    {
        XXGJWebViewController *webView = [[XXGJWebViewController alloc] init];
        [webView setRequestUrl:[NSString stringWithFormat:@"%@%@", XXGJ_WBEVIEW_REQUEST_BASE_URL, XXGJ_WBEVIEW_REQUEST_URL_MALL]];
        [webView setHidesBottomBarWhenPushed:YES];
        [navigationController pushViewController:webView animated:YES];
    }else if(tabBarController.selectedIndex==2)
        /** 跳转到案例界面*/
    {
        XXGJWebViewController *webView = [[XXGJWebViewController alloc] init];
        [webView setRequestUrl:[NSString stringWithFormat:@"%@%@", XXGJ_WBEVIEW_REQUEST_BASE_URL, XXGJ_WBEVIEW_REQUEST_URL_CASE]];
        [webView setHidesBottomBarWhenPushed:YES];
        [navigationController pushViewController:webView animated:YES];
    }
}
#pragma mark - notify
/**
 登录
 */
- (void)login
{
    if (self.appDelegate.socketManage.session_key)
    {
        NSString *userId = [[NSUserDefaults standardUserDefaults] objectForKey:XX_USERDEFAULT_USER][XXGJ_N_PARAM_USERID];
        NSString *session_key = self.appDelegate.socketManage.session_key;
        NSString *uuid = [[[[UIDevice currentDevice] identifierForVendor] UUIDString] md5];
        NSNumber *isAutoLogin = @(self.appDelegate.socketManage.isAutoLogin);
        
        NSDictionary *params = @{XXGJ_N_PARAM_USERID:userId, XXGJ_N_PARAM_SESSIONKEY:session_key, XXGJ_N_PARAM_TERMINALINFO:uuid,@"isAutoLogin":isAutoLogin};
        NSLog(@"聊天服务器登录----isAutoLogin:%@", isAutoLogin);
        [XXGJNetKit loginChat:params rBlock:^(id obj, BOOL success, NSError *error) {
            NSDictionary *dict = (NSDictionary *)obj;
            if ([dict[@"status"] boolValue]&&[dict[@"statusText"] isEqualToString:@"login success"])
            {
                // 登录成功进行处理
                [self.appDelegate.socketManage reSendMessage];
                [self.appDelegate.socketManage setIsAutoLogin:YES];
            }else
            {
                // 登录失败,进行处理
            }
        }];
    }
}

- (void)outLoginNotification
{
    self.appDelegate.user = nil;
    [self.appDelegate.socketManage setSocketOffline:1];
    [self.appDelegate.socketManage stopReConnectedThread];
    /** 退出登录成功, 移除Cookies数据*/
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"user_cookies"];
    NSMutableDictionary *userinfo = [[[NSUserDefaults standardUserDefaults] objectForKey:XX_USERDEFAULT_USER] mutableCopy];
    [userinfo removeObjectForKey:XXGJ_N_PARAM_USERID];
    [[NSUserDefaults standardUserDefaults] setObject:userinfo.copy forKey:XX_USERDEFAULT_USER];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"异地登录" message:@"该账号在其他设备登录, 请退出登录！" preferredStyle:UIAlertControllerStyleAlert];
    [alertController addAction:[UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        /** 退到登录界面*/
        dispatch_time_t time=dispatch_time(DISPATCH_TIME_NOW, 0.25*NSEC_PER_SEC);
        dispatch_after(time,dispatch_get_main_queue(), ^{
            [MBProgressHUD hiddenHUD];
            [self.appDelegate exchangeRootViewControllerWithStoryBoard:XXGJ_STORY_NAME_LOGIN];
            NSLog(@"outlog success");
        });
        
    }]];
    [self presentViewController:alertController animated:YES completion:nil];
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
