//
//  XXGJUpdateBornViewController.h
//  xxdcchat_ios
//
//  Created by 刘朝龙 on 2017/5/2.
//  Copyright © 2017年 刘朝龙. All rights reserved.
//

#import "XXGJViewController.h"
typedef void(^UpdateBornConfirmBlock)(NSDate * born);

@interface XXGJUpdateBornViewController : XXGJViewController

+ (instancetype)updateBornViewController;

- (void)setConfirmBlock:(UpdateBornConfirmBlock)confirmBlock;

@end
