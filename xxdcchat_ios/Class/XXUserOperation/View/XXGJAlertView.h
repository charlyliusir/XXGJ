//
//  XXGJAlertView.h
//  xxdcchat_ios
//
//  Created by 刘朝龙 on 2017/3/19.
//  Copyright © 2017年 刘朝龙. All rights reserved.
//

#import <UIKit/UIKit.h>
@protocol XXGJAlertViewDelegate;

typedef NS_ENUM(NSInteger, AlertViewIndex) {
    AlertViewIndexConfirm,
    AlertViewIndexCancel,
};

@interface XXGJAlertView : UIView

+ (instancetype)alertViewContent:(NSString *)content withDelegate:(id <XXGJAlertViewDelegate>)delegate withObject:(id)obj;

- (void)setContentName:(NSString *)name alertIndex:(AlertViewIndex)alertIndex;
- (void)showInView:(UIView *)view;
- (void)hidden;

@end

@protocol XXGJAlertViewDelegate <NSObject>

@optional
- (void)alertView:(XXGJAlertView *)alertView clickAtIndex:(AlertViewIndex)index object:(id)obj;

@end
