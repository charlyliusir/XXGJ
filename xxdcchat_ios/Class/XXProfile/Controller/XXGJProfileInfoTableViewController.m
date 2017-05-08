//
//  XXGJProfileInfoTableViewController.m
//  xxdcchat_ios
//
//  Created by 刘朝龙 on 2017/4/10.
//  Copyright © 2017年 刘朝龙. All rights reserved.
//

#import "XXGJProfileInfoTableViewController.h"
#import "XXGJUpdateAddressViewController.h"
#import "XXGJUpdateBornViewController.h"
#import "XXGJUpdataSexViewController.h"
#import "LGPhotoPickerViewController.h"
#import "LGPhotoAssets.h"
#import "AppDelegate.h"
#import <UIImageView+WebCache.h>
#import "NSDate+XXGJFormatter.h"
#import "NSString+XXGJFileStore.h"

@interface XXGJProfileInfoTableViewController () <LGPhotoPickerViewControllerDelegate, UITextFieldDelegate>
@property (weak, nonatomic) IBOutlet UIImageView *userAvatarImageView;
@property (weak, nonatomic) IBOutlet UILabel *phoneNumberLabel;
@property (weak, nonatomic) IBOutlet UILabel *userIdLabel;
@property (weak, nonatomic) IBOutlet UILabel *userNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *userSexLabel;
@property (weak, nonatomic) IBOutlet UILabel *userBirthdayLabel;
@property (weak, nonatomic) IBOutlet UILabel *userAddressLabel;

@property (nonatomic, strong)AppDelegate *appDelegate;
@end

@implementation XXGJProfileInfoTableViewController

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self reloadData];
    [self setNavigationBarTitle:@"个人信息"];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - open method
- (void)reloadData
{
    if (self.appDelegate.user.avatar)
    {
        [self.userAvatarImageView sd_setImageWithURL:[NSURL URLWithString:[XXGJ_N_BASE_IMAGE_URL stringByAppendingPathComponent:self.appDelegate.user.avatar]] placeholderImage:[UIImage imageNamed:@"placeholder_user_male_icon"]];
    }else{
        [self.userAvatarImageView setImage:[UIImage imageNamed:@"placeholder_user_male_icon"]];
    }
    
    [self.userNameLabel setText:self.appDelegate.user.nick_name];
    [self.userIdLabel setText:[NSString stringWithFormat:@"%@", self.appDelegate.user.user_id]];
    [self.phoneNumberLabel setText:self.appDelegate.user.mobile];
    [self.userSexLabel setText:self.appDelegate.user.sex];
    /** 生日样式*/
    if (![self.appDelegate.user.birthday isEmpty] && self.appDelegate.user.birthday.length >= 8)
    {
        /** 19910101*/
        NSMutableString *userBorn = self.appDelegate.user.birthday.mutableCopy;
        /** 第一部分, 日*/
        [userBorn insertString:@"/" atIndex:userBorn.length-2];
        /** 第二部分, 月*/
        [userBorn insertString:@"/" atIndex:userBorn.length-5];
        /** 第三部分, 年*/
        [self.userBirthdayLabel setText:userBorn];
    }
    /** 地址样式*/
    if (self.appDelegate.user.location && self.appDelegate.user.location.length == 6)
    {
        NSString *userAddress  = self.appDelegate.user.location;
        NSString *provinceName = [NSString getProvinceName:userAddress];
        NSString *cityName     = [NSString getCityName:userAddress];
        if (provinceName && cityName)
        {
            [self.userAddressLabel setText:[NSString stringWithFormat:@"%@ %@", provinceName, cityName]];
        }
    }
    
}

#pragma mark - private
- (void)setNavigationBarTitle:(NSString *)title
{
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 0, 44)];
    [titleLabel setText:title];
    [titleLabel setTextColor:XX_NAVIGATIONBAR_TITLECOLOR];
    [titleLabel setFont:[UIFont systemFontOfSize:18]];
    
    self.navigationItem.titleView = titleLabel;
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
- (NSString *)bornWithBirthday:(NSDate *)birthday
{
    if (birthday)
    {
        return [birthday dateForDateFormatter:@"yyyyMMdd"];
    }else
    {
        return @"";
    }
}

- (NSMutableDictionary *)optionWithUserInfo
{
    NSString *trueName  = self.appDelegate.user.nick_name;
    NSString *headImg   = self.appDelegate.user.avatar;
    NSString *sex       = [self sexStringWithType:self.appDelegate.user.sex];
    NSString *born      = self.appDelegate.user.birthday==nil ? @"" : self.appDelegate.user.birthday;
    NSString *area      = self.appDelegate.user.location;
    
    NSMutableDictionary *options = @{@"trueName": trueName,
                                     @"headImg": headImg,
                                     @"sex": sex,
                                     @"born": born,
                                     @"area": area,
                                     @"nativePlaceCode": @""
                                     }.mutableCopy;
    
    return options;
}

- (void)updaUserInfoWithOption:(NSDictionary *)option
{
    [MBProgressHUD showLoadHUDIndeterminate:@"修改信息, 请稍等..."];
    [XXGJNetKit updateUserInfo:option rBlock:^(id obj, BOOL success, NSError *error) {
        if (success && obj)
        {
            NSDictionary *status = obj[@"status"];
            NSLog(@"%@", status[@"msg"]);
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
        dispatch_async(dispatch_get_main_queue(), ^{
            /** 更新界面信息*/
            [self reloadData];
        });
    }];
}

/**
 更新用户头像
 */
- (void)updateUserIcon
{
    // 1. 打开系统相册
    LGPhotoPickerViewController *pickerVc = [[LGPhotoPickerViewController alloc] initWithShowType:LGShowImageTypeImagePicker];
    pickerVc.status = PickerViewShowStatusCameraRoll;
    pickerVc.maxCount = 1;   // 最多能选9张图片
    pickerVc.delegate = self;
    [pickerVc showPickerVc:self];
}

/**
 更新用户昵称
 */
- (void)updateUserNickName
{
    // 弹出一个可编辑Alert
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"" message:@"请输入您要修改的新昵称" preferredStyle:UIAlertControllerStyleAlert];
    [alertController addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
        textField.delegate = self;
        [textField setTag:1001];
    }];
    [alertController addAction:[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil]];
    [alertController addAction:[UIAlertAction actionWithTitle:@"修改" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        UITextField *textField = [alertController.textFields firstObject];
        // 修改昵称
        NSString *newName = textField.text;
        if (![self.appDelegate.user.nick_name isEqualToString:newName])
        {
            NSMutableDictionary *dict = [self optionWithUserInfo];
            [dict setObject:newName forKey:@"trueName"];
            [self updaUserInfoWithOption:dict.copy];
        }
    }]];
    [self presentViewController:alertController animated:YES completion:nil];
}

/**
 更新用户性别
 */
- (void)updateUserSex
{
    XXGJUpdataSexViewController *updateSexVC = [XXGJUpdataSexViewController updateSexViewController];
    [self.navigationController pushViewController:updateSexVC animated:YES];
}

/**
 更新用户出生日期
 */
- (void)updateUserBirthday
{
    XXGJUpdateBornViewController *updateBornVC = [XXGJUpdateBornViewController updateBornViewController];
    // 2. 添加确认按钮点击时间, 用以更新用户地址
    [updateBornVC setConfirmBlock:^(NSDate *born) {
        // 更新信息...
        NSString *userBorn = [self bornWithBirthday:born];
        if (![self.appDelegate.user.birthday isEqualToString:userBorn])
        {
            NSMutableDictionary *dict = [self optionWithUserInfo];
            [dict setObject:userBorn forKey:@"born"];
            [self updaUserInfoWithOption:dict.copy];
        }
    }];
    // 3. 使用present方式把更新界面弹出来
    [updateBornVC setModalPresentationStyle:UIModalPresentationOverCurrentContext];
    //必要配置
    self.modalPresentationStyle = UIModalPresentationCurrentContext;
    self.providesPresentationContextTransitionStyle = YES;
    self.definesPresentationContext = YES;
    [self presentViewController:updateBornVC animated:YES completion:nil];
}

/**
 更新用户地址
 */
- (void)updateUserAddress
{
    XXGJUpdateAddressViewController *updateAddressVC = [XXGJUpdateAddressViewController updateAddressViewController];
    // 1. 将用户的地址信息交递给更新页面
    [updateAddressVC setUserCityInfo:self.appDelegate.user.location];
    // 2. 添加确认按钮点击时间, 用以更新用户地址
    [updateAddressVC setConfirmBlock:^(NSString *address) {
        // 更新信息...
        if (![self.appDelegate.user.location isEqualToString:address])
        {
            NSMutableDictionary *dict = [self optionWithUserInfo];
            [dict setObject:address forKey:@"area"];
            [self updaUserInfoWithOption:dict.copy];
        }
    }];
    // 3. 使用present方式把更新界面弹出来
    [updateAddressVC setModalPresentationStyle:UIModalPresentationOverCurrentContext];
    //必要配置
    self.modalPresentationStyle = UIModalPresentationCurrentContext;
    self.providesPresentationContextTransitionStyle = YES;
    self.definesPresentationContext = YES;
    [self presentViewController:updateAddressVC animated:YES completion:nil];
}
#pragma mark - photo delegate
/**
 *  返回所有的Asstes对象
 */
- (void)pickerViewControllerDoneAsstes:(NSArray *)assets isOriginal:(BOOL)original
{
    // 2. 获取图片, 并上传到服务器
    LGPhotoAssets *photoAsset = assets[0];
    // 压缩图片
    NSData *fileData = UIImageJPEGRepresentation(photoAsset.compressionImage, 1.0f);
    NSString *imageString = [fileData base64EncodedStringWithOptions:0];
    [MBProgressHUD showLoadHUDDeterminate];
    [XXGJNetKit uploadAvatarImageWithData:@{@"img":imageString} rBlock:^(id obj, BOOL success, NSError *error) {
        if (success && obj && obj[@"status"])
        {
            NSString *msg = obj[@"status"][@"msg"];
            if ([msg isEqualToString:@"success"])
            {
                NSDictionary *data   = obj[@"data"];
                // 3. 获取上传成功后的图片地址
                NSMutableDictionary *dict = [self optionWithUserInfo];
                [dict setObject:data[@"filePath"] forKey:@"headImg"];
                [self updaUserInfoWithOption:dict.copy];
            }
        }
    }];
    
}
#pragma mark - text field delegate
- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    if (textField.tag == 1001)
    {
        // 修改昵称
        NSString *newName = textField.text;
        if (![self.appDelegate.user.nick_name isEqualToString:newName])
        {
            NSMutableDictionary *dict = [self optionWithUserInfo];
            [dict setObject:newName forKey:@"trueName"];
            [self updaUserInfoWithOption:dict.copy];
        }
    }
    return YES;
}
#pragma mark - Table view delegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // 1. indexPath 0-0 修改头像
    // 2. indexPath 2-0 修改昵称
    // 3. indexPath 2-1 修改性别
    // 4. indexPath 2-2 修改出生年月日
    // 5. indexPath 2-3 修改地址
    if (indexPath.section == 0)
    {
        [self updateUserIcon];
    }else if (indexPath.section == 2)
    {
        if (indexPath.row == 0)
        {
            [self updateUserNickName];
        }else if (indexPath.row == 1)
        {
            [self updateUserSex];
        }else if (indexPath.row == 2)
        {
            [self updateUserBirthday];
        }else if (indexPath.row == 3)
        {
            [self updateUserAddress];
        }
    }
    
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
}

#pragma mark - Table view data source

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 15;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    //标题背景
    UIView *contentView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 30)];
    [contentView setBackgroundColor:XX_TABBAR_TINTCOLOR];
    return contentView;
}



@end
