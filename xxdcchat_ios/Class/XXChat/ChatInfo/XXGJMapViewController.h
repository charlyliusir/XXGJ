//
//  XXGJMapViewController.h
//  xxdcchat_ios
//
//  Created by 刘朝龙 on 2017/4/11.
//  Copyright © 2017年 刘朝龙. All rights reserved.
//

#import "XXGJViewController.h"
#import "XXGJLocationInfo.h"
@interface XXGJMapViewController : XXGJViewController

@property (nonatomic, strong)XXGJLocationInfo *locationInfo;
+ (instancetype)mapViewController;

@end
