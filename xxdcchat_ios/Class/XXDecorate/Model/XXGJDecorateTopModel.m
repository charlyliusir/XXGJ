//
//  XXGJDecorateTopModel.m
//  xxdcchat_ios
//
//  Created by 刘朝龙 on 2017/4/13.
//  Copyright © 2017年 刘朝龙. All rights reserved.
//

#import "XXGJDecorateTopModel.h"

@implementation XXGJDecorateTopModel

- (instancetype)initWithTitle:(NSString *)title subTitle:(NSString *)subtitle iconName:(NSString *)iconName
{
    if (self = [super init])
    {
        self.title = title;
        self.subtitle = subtitle;
        self.iconName = iconName;
    }
    
    return self;
}
+ (instancetype)decorateTopModelWithTitle:(NSString *)title subTitle:(NSString *)subtitle iconName:(NSString *)iconName
{
    return [[XXGJDecorateTopModel alloc] initWithTitle:title subTitle:subtitle iconName:iconName];
}

@end
