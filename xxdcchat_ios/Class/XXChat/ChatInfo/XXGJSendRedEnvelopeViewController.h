//
//  XXGJSendRedEnvelopeViewController.h
//  xxdcchat_ios
//
//  Created by 刘朝龙 on 2017/4/18.
//  Copyright © 2017年 刘朝龙. All rights reserved.
//

#import "XXGJViewController.h"
#import "XXGJMessage.h"

typedef NS_ENUM(NSUInteger, SendRedEnvelopeMethod) {
    SendRedEnvelopeMethodFriend,
    SendRedEnvelopeMethodGroup
};

@protocol XXGJSendRedEnvelopeViewControllerDelegate <NSObject>

- (void)sendRedEnvelopeMessage:(XXGJMessage *)redEnvelopeMessage;

@end

@interface XXGJSendRedEnvelopeViewController : XXGJViewController

@property (nonatomic, assign)id <XXGJSendRedEnvelopeViewControllerDelegate> delegate;
@property (nonatomic, assign)SendRedEnvelopeMethod method;
@property (nonatomic, strong)NSNumber *targetId;

+ (instancetype)sendRedEnvelopeViewControllerWithMethod:(SendRedEnvelopeMethod)method;

@end
