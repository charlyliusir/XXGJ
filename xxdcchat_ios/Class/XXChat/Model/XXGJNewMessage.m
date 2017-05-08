//
//  XXGJNewMessage.m
//  xxdcchat_ios
//
//  Created by 刘朝龙 on 2017/3/25.
//  Copyright © 2017年 刘朝龙. All rights reserved.
//

#import "XXGJNewMessage.h"

@implementation XXGJNewMessage


- (instancetype)initWithObject:(id)msgObject newMessage:(NewMessage *)tNewMessage
{
    if (self = [super init]) {
        self.msgObject = msgObject;
        self.tNewMessage = tNewMessage;
    }
    
    return self;
}
+ (instancetype)newMessageWithObject:(id)msgObject newMessage:(NewMessage *)tNewMessage
{
    return [[XXGJNewMessage alloc] initWithObject:msgObject newMessage:tNewMessage];
}

@end
