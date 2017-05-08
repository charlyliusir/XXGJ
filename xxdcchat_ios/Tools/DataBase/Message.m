//
//  Message.m
//  xxdcchat_ios
//
//  Created by 刘朝龙 on 2017/3/17.
//  Copyright © 2017年 刘朝龙. All rights reserved.
//

#import "Message.h"

@implementation Message
+ (NSFetchRequest<Message *> *)fetchRequest
{
    return [[NSFetchRequest alloc] initWithEntityName:@"Message"];
}

@dynamic businessType;
@dynamic content;
@dynamic create;
@dynamic isAck;
@dynamic isGroup;
@dynamic isSender;
@dynamic senderId;
@dynamic isReSend;
@dynamic message_id;
@dynamic relationId;
@dynamic messageType;
@dynamic sentCount;
@dynamic status;
@dynamic targetId;
@dynamic update;
@dynamic userId;
@dynamic uuid;
@dynamic args;

@end
