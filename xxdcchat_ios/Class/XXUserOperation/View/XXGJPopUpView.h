//
//  XXGJPopUpView.h
//  xxdcchat_ios
//
//  Created by 刘朝龙 on 2017/4/7.
//  Copyright © 2017年 刘朝龙. All rights reserved.
//

#import <UIKit/UIKit.h>
@protocol XXGJPopUpViewDelegate;
typedef NS_ENUM(NSInteger, XXGJPopupItem) {
    XXGJPopupItemCreateGroup,
    XXGJPopupItemQR
};
/// 首页弹窗页面
@interface XXGJPopUpView : UIView

@property (nonatomic, assign)id <XXGJPopUpViewDelegate>delegate;
- (void)showView;

@end

@protocol XXGJPopUpViewDelegate <NSObject>

- (void)tapPopupItemView:(XXGJPopUpView *)popupView item:(XXGJPopupItem)popupItem;

@end
