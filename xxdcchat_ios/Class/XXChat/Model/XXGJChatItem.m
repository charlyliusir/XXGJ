//
//  XXGJChatItem.m
//  xxdcchat_ios
//
//  Created by 刘朝龙 on 2017/3/16.
//  Copyright © 2017年 刘朝龙. All rights reserved.
//

#import "XXGJChatItem.h"

@implementation XXGJChatItem

- (instancetype)initWithName:(NSString *)name iconName:(NSString *)iconName iconURL:(NSString *)url
{
    if (self = [super init])
    {
        self.titleName= name;
        self.iconURL  = url;
        self.iconName = iconName;
    }
    
    return self;
}

+ (instancetype)itemWithName:(NSString *)name iconName:(NSString *)iconName iconURL:(NSString *)url
{
    return [[self alloc] initWithName:name iconName:iconName iconURL:url];
}

+ (instancetype)itemWithName:(NSString *)name iconURL:(NSString *)url isSelected:(BOOL)isSelected
{
    XXGJChatItem *chatItem = [[self alloc] initWithName:name iconName:nil iconURL:url];
    chatItem.isSelected = isSelected;
    return chatItem;
}

@end
