//
//  XXGJUpdataSexViewController.m
//  xxdcchat_ios
//
//  Created by 刘朝龙 on 2017/4/28.
//  Copyright © 2017年 刘朝龙. All rights reserved.
//

#import "XXGJUpdataSexViewController.h"

@interface XXGJUpdataSexViewController ()
@property (weak, nonatomic) IBOutlet UIImageView *maleSelectedImageView;
@property (weak, nonatomic) IBOutlet UIImageView *femaleSelectedImageView;

@end

@implementation XXGJUpdataSexViewController

+ (instancetype)updateSexViewController
{
    return [[NSBundle mainBundle] loadNibNamed:NSStringFromClass(self) owner:nil options:nil].firstObject;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self setUserSex];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - open method
- (void)setUserSex
{
    if ([self.appDelegate.user.sex isEqualToString:@"男"])
    {
        [self.maleSelectedImageView setHidden:NO];
        [self.femaleSelectedImageView setHidden:YES];
    }else if ([self.appDelegate.user.sex isEqualToString:@"女"])
    {
        [self.maleSelectedImageView setHidden:YES];
        [self.femaleSelectedImageView setHidden:NO];
    }
}

#pragma mark - private
- (void)backMethod:(UIBarButtonItem *)barButtonItem
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (NSString *)sexStringWithType:(NSString *)sex
{
    if ([sex isEqualToString:@"男"])
    {
        return @"Sex-male";
    }else if([sex isEqualToString:@"女"])
    {
        return @"Sex-female";
    }else if([sex isEqualToString:@"Sex-male"])
    {
        return @"男";
    }else if ([sex isEqualToString:@"Sex-female"])
    {
        return @"女";
    }else
    {
        return sex;
    }
}
- (NSDictionary *)optionWithUserInfoSex:(NSString *)sexString
{
    NSString *trueName  = self.appDelegate.user.nick_name;
    NSString *headImg   = self.appDelegate.user.avatar;
    NSString *sex       = [self sexStringWithType:sexString];
    NSString *born      = self.appDelegate.user.birthday;
    NSString *area      = self.appDelegate.user.location;
    
    NSDictionary *options = @{@"trueName": trueName,
                                     @"headImg": headImg,
                                     @"sex": sex,
                                     @"born": born,
                                     @"area": area,
                                     @"nativePlaceCode": @""
                                     };
    
    return options;
}

- (void)updaUserInfoWithOption:(NSDictionary *)option
{
    [MBProgressHUD showLoadHUDIndeterminate:@"修改信息, 请稍等..."];
    [XXGJNetKit updateUserInfo:option rBlock:^(id obj, BOOL success, NSError *error) {
        if (success && obj)
        {
            NSDictionary *status = obj[@"status"];
            if (status && [status[@"msg"] isEqualToString:@"success"])
            {
                self.appDelegate.user.nick_name = option[@"trueName"];
                self.appDelegate.user.location  = option[@"area"];
                self.appDelegate.user.avatar    = option[@"headImg"];
                self.appDelegate.user.sex       = [self sexStringWithType:option[@"sex"]];
                self.appDelegate.user.birthday  = option[@"born"];
                [self.appDelegate saveContext];
                
                /** 更新当前页面*/
                [MBProgressHUD showLoadHUDCustomImage:successHUDName title:@"修改成功!"];
            }
            /** 添加未登录逻辑*/
            else if (status && [status[@"msg"] isEqualToString:@""])
            {
                [MBProgressHUD hiddenHUD];
                /** 添加用户登录方法*/
            }
            else
            {
                [MBProgressHUD showLoadHUDText:@"个人信息修改失败" during:0.25];
            }
            
        }else
        {
            [MBProgressHUD showLoadHUDText:@"个人信息修改失败" during:0.25];
        }
        
        [self setUserSex];
    }];
}

- (IBAction)tapSelecteSexItem:(id)sender
{
    UITapGestureRecognizer *tapGestureRecognizer = (UITapGestureRecognizer *)sender;
    if ([tapGestureRecognizer.view tag] == 1001)
    {
        [self.maleSelectedImageView setHidden:NO];
        [self.femaleSelectedImageView setHidden:YES];
        [self updaUserInfoWithOption:[self optionWithUserInfoSex:@"男"]];
    }else if ([tapGestureRecognizer.view tag] == 1002)
    {
        [self.maleSelectedImageView setHidden:YES];
        [self.femaleSelectedImageView setHidden:NO];
        [self updaUserInfoWithOption:[self optionWithUserInfoSex:@"女"]];
    }
}


@end
