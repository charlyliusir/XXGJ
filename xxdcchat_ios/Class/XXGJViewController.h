//
//  XXGJViewController.h
//  xxdcchat_ios
//
//  Created by 刘朝龙 on 2017/3/15.
//  Copyright © 2017年 刘朝龙. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MBProgressHUD+XXGJProgressHUD.h"
#import "AppDelegate.h"
#import "UITextField+XXGJPlaceholder.h"
#import "NSDate+XXGJFormatter.h"
#import "XXGJAlertView.h"

#define NOTIFY_MESSAGE_RELOAD_MESSAGE @"reloadMsg"

@interface XXGJViewController : UIViewController <XXGJAlertViewDelegate>

@property (nonatomic, strong)AppDelegate *appDelegate;

- (void)setNavigationBarTitle:(NSString *)title;

- (void)backMethod:(UIBarButtonItem *)barButtonItem;

@end
