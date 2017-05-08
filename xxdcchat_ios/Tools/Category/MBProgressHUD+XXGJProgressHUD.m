//
//  MBProgressHUD+XXGJProgressHUD.m
//  xxdcchat_ios
//
//  Created by 刘朝龙 on 2017/3/18.
//  Copyright © 2017年 刘朝龙. All rights reserved.
//

#import "MBProgressHUD+XXGJProgressHUD.h"

@implementation MBProgressHUD (XXGJProgressHUD)

+ (instancetype)mbProgressHUD
{
    MBProgressHUD *hud = [self HUDForView:[UIApplication sharedApplication].keyWindow];
    if (!hud) {
        hud = [MBProgressHUD showHUDAddedTo:[UIApplication sharedApplication].keyWindow animated:YES];
    }
    
    [hud setContentColor:[UIColor whiteColor]];
    [hud.bezelView setColor:[[UIColor blackColor] colorWithAlphaComponent:0.7]];
    return hud;
}

+ (void)showLoadHUDIndeterminate:(NSString *)title
{
    dispatch_async(dispatch_get_main_queue(), ^{
        MBProgressHUD *hud = [self mbProgressHUD];
        [hud.label setText:title];
        dispatch_time_t time=dispatch_time(DISPATCH_TIME_NOW, 10*NSEC_PER_SEC);
        dispatch_after(time,dispatch_get_main_queue(), ^{
            [MBProgressHUD hiddenHUD];
        });
    });
}/** 只显示小菊花*/
+ (void)showLoadHUDIndeterminate:(NSString *)title during:(CGFloat)during
{
    dispatch_async(dispatch_get_main_queue(), ^{
        MBProgressHUD *hud = [self mbProgressHUD];
        [hud.label setText:title];
        dispatch_time_t time=dispatch_time(DISPATCH_TIME_NOW, during*NSEC_PER_SEC);
        dispatch_after(time,dispatch_get_main_queue(), ^{
            [MBProgressHUD hiddenHUD];
        });
    });
    
}/** 只显示小菊花*/

+ (void)showLoadHUDDeterminate
{
    dispatch_async(dispatch_get_main_queue(), ^{
        MBProgressHUD *hud = [self mbProgressHUD];
        hud.mode = MBProgressHUDModeIndeterminate;
        dispatch_time_t time=dispatch_time(DISPATCH_TIME_NOW, 10*NSEC_PER_SEC);
        dispatch_after(time,dispatch_get_main_queue(), ^{
            [MBProgressHUD hiddenHUD];
        });
    });
}/** 显示饼状图进度条*/
+ (void)showLoadHUDDeterminateHorizontalBar
{
    
}/** 显示水平进度条*/
+ (void)showLoadHUDAnnularDeterminate
{
    
}/** 显示环形进度条*/
+ (void)showLoadHUDCustomImage:(NSString *)image title:(NSString *)title
{
    dispatch_async(dispatch_get_main_queue(), ^{
        MBProgressHUD *hud = [self mbProgressHUD];
        [hud setMode:MBProgressHUDModeCustomView];
        [hud.label setText:title];
        
        UIImageView *imgView = [[UIImageView alloc] initWithImage:[[UIImage imageNamed:image] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate]];
        hud.customView = imgView;
        
        dispatch_time_t time=dispatch_time(DISPATCH_TIME_NOW, 1.5*NSEC_PER_SEC);
        dispatch_after(time,dispatch_get_main_queue(), ^{
            [MBProgressHUD hiddenHUD];
        });

    });
}
/** 显示饼状图进度条*/
+ (void)showLoadHUDText:(NSString *)msg
{
    dispatch_async(dispatch_get_main_queue(), ^{
        MBProgressHUD *hud = [self mbProgressHUD];
        [hud setMode:MBProgressHUDModeText];
        [hud.label setText:msg];
        [hud setOffset:CGPointMake(0, 180)];
        dispatch_time_t time=dispatch_time(DISPATCH_TIME_NOW, 10*NSEC_PER_SEC);
        dispatch_after(time,dispatch_get_main_queue(), ^{
            [MBProgressHUD hiddenHUD];
        });
    });
    
}/** 只显示文字*/
+ (void)showLoadHUDText:(NSString *)msg during:(CGFloat)during
{
    dispatch_async(dispatch_get_main_queue(), ^{
        MBProgressHUD *hud = [self mbProgressHUD];
        [hud setMode:MBProgressHUDModeText];
        [hud.label setText:msg];
        [hud setOffset:CGPointMake(0, 180)];
        dispatch_time_t time=dispatch_time(DISPATCH_TIME_NOW, during*NSEC_PER_SEC);
        dispatch_after(time,dispatch_get_main_queue(), ^{
            [MBProgressHUD hiddenHUD];
        });
    });
}/** 显示文字, 并带时间*/
+ (void)showLoadHUDText:(NSString *)msg during:(CGFloat)during originX:(CGFloat)originX
{
    dispatch_async(dispatch_get_main_queue(), ^{
        MBProgressHUD *hud = [self mbProgressHUD];
        [hud setMode:MBProgressHUDModeText];
        [hud.label setText:msg];
        [hud setOffset:CGPointMake(0, originX)];
        dispatch_time_t time=dispatch_time(DISPATCH_TIME_NOW, during*NSEC_PER_SEC);
        dispatch_after(time,dispatch_get_main_queue(), ^{
            [MBProgressHUD hiddenHUD];
        });
    });
}/** 显示文字, 并带时间*/

+ (void)hiddenHUD
{
    [MBProgressHUD hideHUDForView:[UIApplication sharedApplication].keyWindow animated:YES];
}

@end
