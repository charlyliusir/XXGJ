//
//  NewMessage.m
//  xxdcchat_ios
//
//  Created by 刘朝龙 on 2017/4/20.
//  Copyright © 2017年 刘朝龙. All rights reserved.
//

#import "NewMessage.h"

@implementation NewMessage
+ (NSFetchRequest<NewMessage *> *)fetchRequest
{
    return [[NSFetchRequest alloc] initWithEntityName:@"NewMessage"];
}

@dynamic content;
@dynamic isGroup;
@dynamic targetId;
@dynamic userId;
@dynamic update;
@dynamic uuid;
@dynamic reveCount;

@end
