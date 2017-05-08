//
//  XXGJLocationViewController.h
//  xxdcchat_ios
//
//  Created by 刘朝龙 on 2017/4/11.
//  Copyright © 2017年 刘朝龙. All rights reserved.
//

#import "XXGJViewController.h"
@class XXGJMessage;

typedef void(^LocationCompeleteBlock) (XXGJMessage *);

@protocol XXGJLocationViewControllerDelegate <NSObject>

/**
 发送定位消息

 @param message 定位消息
 */
- (void)sendLocationMessage:(XXGJMessage *)message;

@end

@interface XXGJLocationViewController : XXGJViewController

@property (nonatomic, assign)id <XXGJLocationViewControllerDelegate> delegate;

+ (instancetype)locationViewControllerComeBackBlock:(LocationCompeleteBlock)dismissBlock;

@end
