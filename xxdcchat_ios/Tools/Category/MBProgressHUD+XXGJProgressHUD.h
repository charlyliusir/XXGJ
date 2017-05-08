//
//  MBProgressHUD+XXGJProgressHUD.h
//  xxdcchat_ios
//
//  Created by 刘朝龙 on 2017/3/18.
//  Copyright © 2017年 刘朝龙. All rights reserved.
//

#import <MBProgressHUD/MBProgressHUD.h>

static NSString *successHUDName = @"alert_success_icon";

@interface MBProgressHUD (XXGJProgressHUD)

+ (void)showLoadHUDIndeterminate:(NSString *)title;           /** 只显示小菊花*/
+ (void)showLoadHUDIndeterminate:(NSString *)title during:(CGFloat)during;
+ (void)showLoadHUDDeterminate;             /** 显示饼状图进度条*/
+ (void)showLoadHUDDeterminateHorizontalBar;/** 显示水平进度条*/
+ (void)showLoadHUDAnnularDeterminate;      /** 显示环形进度条*/
+ (void)showLoadHUDCustomImage:(NSString *)image title:(NSString *)title;             /** 显示饼状图进度条*/
+ (void)showLoadHUDText:(NSString *)msg;    /** 只显示文字*/
+ (void)showLoadHUDText:(NSString *)msg during:(CGFloat)during;/** 显示文字, 并带时间*/
+ (void)showLoadHUDText:(NSString *)msg during:(CGFloat)during originX:(CGFloat)originX;


+ (void)hiddenHUD;

@end
