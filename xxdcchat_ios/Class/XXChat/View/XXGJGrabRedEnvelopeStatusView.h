//
//  XXGJGrabRedEnvelopeStatusView.h
//  xxdcchat_ios
//
//  Created by 刘朝龙 on 2017/4/26.
//  Copyright © 2017年 刘朝龙. All rights reserved.
//

#import <UIKit/UIKit.h>
/** 自定义回调方法*/
typedef void(^DisOverBlock)(BOOL goGrabInfo, id grabInfo);

@interface XXGJGrabRedEnvelopeStatusView : UIView

+ (instancetype)grabRedEnvelopeStatusViewWithOption:(NSDictionary *)options;

- (void)showInWindom;

- (void)setOverBlock:(DisOverBlock)overBlock;

@end
