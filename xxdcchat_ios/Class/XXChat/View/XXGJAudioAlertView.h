//
//  XXGJAudioAlertView.h
//  xxdcchat_ios
//
//  Created by 刘朝龙 on 2017/4/12.
//  Copyright © 2017年 刘朝龙. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, AudioAlertViewStatus) {
    AudioAlertViewStatusRecord,
    AudioAlertViewStatusDefine = AudioAlertViewStatusRecord,
    AudioAlertViewStatusCancel,
    AudioAlertViewStatusShort
};

@interface XXGJAudioAlertView : UIView

/**
 创建语音提示视图

 @param alertViewStatus 根据状态创建
 @return 返回视图
 */
+ (instancetype)audioAlertViewWithStatus:(AudioAlertViewStatus)alertViewStatus;

/**
 改变提示视图样式

 @param alertViewStatus 改变样式
 */
- (void)setAudioAlertViewStatus:(AudioAlertViewStatus)alertViewStatus;

/**
 改变音量

 @param volume 音量
 */
- (void)changeVolumeValue:(float)volume;

@end
