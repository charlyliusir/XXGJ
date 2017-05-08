//
//  XXGJChatGroupItem.m
//  xxdcchat_ios
//
//  Created by 刘朝龙 on 2017/3/18.
//  Copyright © 2017年 刘朝龙. All rights reserved.
//

#import "XXGJChatGroupItem.h"

@implementation XXGJChatGroupItem

- (instancetype)initWithName:(NSString *)name iconURL:(NSString *)url groupId:(NSNumber *)groupid
{
    if (self = [super init])
    {
        self.groupName= name;
        self.iconURL  = url;
        self.groupId = groupid;
    }
    
    return self;
}
+ (instancetype)itemWithName:(NSString *)name iconURL:(NSString *)url groupId:(NSNumber *)groupid
{
    return [[XXGJChatGroupItem alloc] initWithName:name iconURL:url groupId:groupid];
}

@end
