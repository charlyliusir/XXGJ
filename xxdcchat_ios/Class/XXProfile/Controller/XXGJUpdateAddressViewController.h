//
//  XXGJUpdateAddressViewController.h
//  xxdcchat_ios
//
//  Created by 刘朝龙 on 2017/4/28.
//  Copyright © 2017年 刘朝龙. All rights reserved.
//

#import "XXGJViewController.h"

typedef void(^UpdateAddressConfirmBlock)(NSString * address);

@interface XXGJUpdateAddressViewController : XXGJViewController

+ (instancetype)updateAddressViewController;

- (void)setUserCityInfo:(NSString *)cityInfo;
- (void)setConfirmBlock:(UpdateAddressConfirmBlock)confirmBlock;

@end
