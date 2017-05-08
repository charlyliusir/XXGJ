//
//  XXGJLoginViewController.m
//  xxdcchat_ios
//
//  Created by 刘朝龙 on 2017/3/17.
//  Copyright © 2017年 刘朝龙. All rights reserved.
//

#import "XXGJLoginViewController.h"
#import "XXGJCookieTools.h"
#import "NewMessage.h"

@interface XXGJLoginViewController () <UITextFieldDelegate>
@property (weak, nonatomic) IBOutlet UITextField *userNameTextField;
@property (weak, nonatomic) IBOutlet UITextField *passwordTextField;

@end

@implementation XXGJLoginViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    [self.userNameTextField changePlaceHolderColor:[UIColor whiteColor]];
    [self.passwordTextField changePlaceHolderColor:[UIColor whiteColor]];
    
    /** 添加默认用户登录信息*/
    NSDictionary *userInfo = [[NSUserDefaults standardUserDefaults] objectForKey:XX_USERDEFAULT_USER];
    if (userInfo == nil)
    {
        [self.userNameTextField setText:@""];
        [self.passwordTextField setText:@""];
    }else
    {
        [self.userNameTextField setText:userInfo[XXGJ_N_PARAM_USERNAME]];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - lazy method

#pragma mark - open method

#pragma mark - private method
- (void)getCityList
{
    /** 下载城市文件*/
    NSDictionary *res = [XXGJSycncNetKit getCityFile];
    if (res)
    {
//        NSDictionary *result = res[@"data"][@"result"];
//        /** 创建 JSON 文件夹*/
//        NSString *cityFileFolder = [[NSString documentStore] appendFileStore:XXGJ_STRING_JSON_FOLDER];
//        [NSString createFilePath:cityFileFolder];
//        NSData *jsonData = [NSJSONSerialization dataWithJSONObject:result options:NSJSONWritingPrettyPrinted error:nil];
//        [jsonData writeToFile:[NSString cityJsonPath] options:NSDataWritingAtomic error:nil];
    }
}
- (IBAction)login:(id)sender {
    
    // 此处执行登录方法
    NSString *userName = self.userNameTextField.text;
    NSString *password = self.passwordTextField.text;
    
    if (![userName isEmpty] && ![password isEmpty])
    {
        NSDictionary *dict = @{XXGJ_N_PARAM_USERNAME:userName, XXGJ_N_PARAM_PASSWORD:password};
#warning 此处代码需要完善
        /** 此处添加 loading 菊花效果*/
        [MBProgressHUD showLoadHUDIndeterminate:@"正在登录..."];
        [XXGJNetKit login:dict rBlock:^(id obj, BOOL success, NSError *error) {
            
            /** 如果登录成功*/
            if (success)
            {
                NSDictionary *dict = (NSDictionary *)obj;
                NSDictionary *status = dict[@"status"];
                NSDictionary *data = dict[@"data"];
                NSLog(@"%@", data[@"errorMsgs"][@"username"]);
                if (status && [status[@"msg"] isEqualToString:@"登录成功"])
                {
                    NSDictionary *data = dict[@"data"];
                    NSDictionary *webUser = data[@"webUser"];
                    /** 查询本地是否有该用户信息*/
                    User *user = [self.appDelegate.dbModelManage excuteTable:TABLE_USER predicate:[NSString stringWithFormat:@"user_id==%@", webUser[@"id"]] limit:1].lastObject;
                    if (!user)
                        /** 如果该用户不存在*/
                    {
                        /** 第一步、使用 CoreData 创建一个用户信息*/
                        user = [NSEntityDescription insertNewObjectForEntityForName:TABLE_USER inManagedObjectContext:self.appDelegate.managedObjectContext];
                        user.user_id   = webUser[@"id"];
                        user.create    = webUser[@"createDate"];
                    }
                    user.nick_name = webUser[@"trueName"];
                    user.avatar    = webUser[@"img"];
                    user.sex       = [webUser[@"sex"] isEqualToString:@"Sex-male"] ? @"男" : @"女";
                    user.location  = webUser[@"area"];
                    user.mobile    = webUser[@"mobile"];
                    user.company   = webUser[@"company"];
                    user.birthday  = webUser[@"born"];
                    
                    if (webUser[@"email"])
                    {
                        user.email = webUser[@"email"];
                    }
                    User *sysUser = [self.appDelegate.dbModelManage excuteTable:TABLE_USER predicate:@"user_id=='-10000'" limit:1].lastObject;
                    if (!sysUser)
                    {
                        /** 创建系统用户*/
                        sysUser = [NSEntityDescription insertNewObjectForEntityForName:@"User" inManagedObjectContext:self.appDelegate.managedObjectContext];
                        sysUser.nick_name = @"系统消息";
                        sysUser.user_id   = @(-10000);
                    }
                    /** 最新消息列表计数清空*/
                    NSArray *newMessageArr = [self.appDelegate.dbModelManage excuteTable:TABLE_NEW_MESSAGE];
                    for (NewMessage *newMessage in newMessageArr)
                    {
                        newMessage.reveCount = @(0);
                    }
                    
                    [self.appDelegate saveContext];
                    self.appDelegate.user = user;
                    [XXGJCookieTools setCookies];
                    
                    /** 本地存储用户信息,用来自动登录*/
                    [[NSUserDefaults standardUserDefaults] setObject:@{XXGJ_N_PARAM_USERNAME:userName, XXGJ_N_PARAM_PASSWORD:password, XXGJ_N_PARAM_USERID:self.appDelegate.user.user_id}forKey:XX_USERDEFAULT_USER];
                    [[NSUserDefaults standardUserDefaults] synchronize];
                    
                    /** 跳转首页控制器, 由于是 UI 操作, 需要放入主线程*/
                    [MBProgressHUD showLoadHUDText:@"登录成功"];
                    dispatch_time_t time=dispatch_time(DISPATCH_TIME_NOW, 0.25*NSEC_PER_SEC);
                    dispatch_after(time,dispatch_get_main_queue(), ^{
                        [MBProgressHUD hiddenHUD];
                        if (self.appDelegate.socketManage==nil)
                        {
                            self.appDelegate.socketManage = [XXGJSocketManager sharedXXGJSocketManager];
                        }
                        [self.appDelegate.socketManage setIsAutoLogin:NO];
                        [self.appDelegate exchangeRootViewControllerWithStoryBoard:XXGJ_STORY_NAME_MAIN];
                    });
                }
                else
                {
                    [MBProgressHUD showLoadHUDText:@"登录失败,用户名或密码不正确"];
                    dispatch_time_t time=dispatch_time(DISPATCH_TIME_NOW, 0.25*NSEC_PER_SEC);
                    dispatch_after(time,dispatch_get_main_queue(), ^{
                        [MBProgressHUD hiddenHUD];
                    });
                }
            }
            /** 登录失败*/
            else
            {
                [MBProgressHUD showLoadHUDText:@"登录失败,请检查网络是否连接"];
                dispatch_time_t time=dispatch_time(DISPATCH_TIME_NOW, 0.25*NSEC_PER_SEC);
                dispatch_after(time,dispatch_get_main_queue(), ^{
                    [MBProgressHUD hiddenHUD];
                });
            }
            
        }];
    }
    else
    {
        // 提示用户信息和密码不能为空
        [MBProgressHUD showLoadHUDText:@"用户名或密码不能为空"];
        dispatch_time_t time=dispatch_time(DISPATCH_TIME_NOW, 0.25*NSEC_PER_SEC);
        dispatch_after(time,dispatch_get_main_queue(), ^{
            [MBProgressHUD hiddenHUD];
        });
    }
}
- (IBAction)loiter:(id)sender {
}
- (IBAction)registe:(id)sender {
}
- (IBAction)forgetPassword:(id)sender {
}

#pragma mark - gesture recognizer method
- (IBAction)cancelAction:(id)sender {
    [self.userNameTextField resignFirstResponder];
    [self.passwordTextField resignFirstResponder];
}

#pragma mark - delegate
#pragma mark - text field delegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    
    if ([textField isEqual:self.userNameTextField])
    {
        [self.userNameTextField resignFirstResponder];
        [self.passwordTextField becomeFirstResponder];
    }
    else
    {
        [self.passwordTextField resignFirstResponder];
        [self login:nil];
    }
    
    return YES;
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
