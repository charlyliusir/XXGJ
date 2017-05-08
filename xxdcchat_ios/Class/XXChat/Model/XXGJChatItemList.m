//
//  XXGJChatItemList.m
//  xxdcchat_ios
//
//  Created by 刘朝龙 on 2017/3/16.
//  Copyright © 2017年 刘朝龙. All rights reserved.
//

#import "XXGJChatItemList.h"

@implementation XXGJChatItemList

- (instancetype)initChatItemListWithName:(NSString *)name icon:(NSString *)icon info:(NSString *)info time:(NSString *)time  newMessageCount:(NSInteger)count avoidRemind:(BOOL)avoidRemind
{
    if (self = [super init]) {
        self.nameTitle = name;
        self.iconURL   = icon;
        self.infoTitle = info;
        self.timeTitle = time;
        self.newMessageCount = count;
        self.avoidRemind     = avoidRemind;
    }
    
    return self;
}

+ (instancetype)chatItemListWithName:(NSString *)name icon:(NSString *)icon info:(NSString *)info time:(NSString *)time  newMessageCount:(NSInteger)count avoidRemind:(BOOL)avoidRemind
{
    return [[XXGJChatItemList alloc] initChatItemListWithName:name icon:icon info:info time:time newMessageCount:count avoidRemind:avoidRemind];
}

@end
