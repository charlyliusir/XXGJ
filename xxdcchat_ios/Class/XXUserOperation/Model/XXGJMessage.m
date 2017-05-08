//
//  XXGJMessage.m
//  IMSocketClient
//
//  Created by 刘朝龙 on 2017/3/9.
//  Copyright © 2017年 刘朝龙. All rights reserved.
//

#import "XXGJMessage.h"
#import "NSString+IMEx.h"
#import "Message.h"
#import "Args.h"

@interface XXGJMessage()
@property (nonatomic, readwrite, copy)NSDictionary *Args;          // 多参数
//@property (nonatomic, strong)NSNumber *Created;         // 创建时间
@property (nonatomic, readwrite, strong)NSNumber *ID;              // 事件ID
@property (nonatomic, readwrite, strong)NSNumber *isClosingCost;   // 是已经结算信息咨询费
@property (nonatomic, readwrite, strong)NSNumber *sentCount;       // 消息发送次数
@property (nonatomic, readwrite, copy)NSString *uuid;              // 消息唯一标识

@end

@implementation XXGJMessage
- (instancetype)initWithDataBaseMessage:(Message *)message
{
    if (self = [super init])
    {
        self.ID     = message.message_id;
        self.Created= message.create;
        self.UserId = message.userId;
        self.TargetId     = message.targetId;
        self.BusinessType = [XXGJBusinessType businessByType:[message.businessType intValue]];
        self.MessageType  = message.messageType;
        self.Content = message.content;
        self.IsGroup = message.isGroup;
        self.isAck   = message.isAck;
        self.isClosingCost = @(false);
        self.Status    = message.status;
        self.sentCount = message.sentCount;
        self.uuid      = message.uuid;
        if ([self.IsGroup boolValue])
        {
            [self setArgsObject:message.targetId forKey:XXGJ_ARGS_PARAM_GROUPID];
        }
        
        // Args
        if (message.args.imgUrl)
        {
            [self setArgsObject:message.args.imgUrl forKey:XXGJ_ARGS_PARAM_IMAGEURL];
        }
        if (message.args.bitmapHeight)
        {
            [self setArgsObject:message.args.bitmapHeight forKey:XXGJ_ARGS_PARAM_BITMPHEIGHT];
        }
        if (message.args.bitmapWidth)
        {
            [self setArgsObject:message.args.bitmapWidth forKey:XXGJ_ARGS_PARAM_BITMPWIDTH];
        }
        if (message.args.bitmapSize)
        {
            [self setArgsObject:message.args.bitmapSize forKey:XXGJ_ARGS_PARAM_BITMPSIZE];
        }
        if (message.args.bitmapTime)
        {
            [self setArgsObject:message.args.bitmapTime forKey:XXGJ_ARGS_PARAM_BITMPTIME];
        }
        if (message.args.address)
        {
            [self setArgsObject:message.args.address forKey:XXGJ_ARGS_PARAM_ADDRESS];
        }
        if (message.args.longitude)
        {
            [self setArgsObject:message.args.longitude forKey:XXGJ_ARGS_PARAM_LONGITUDE];
        }
        if (message.args.latitude)
        {
            [self setArgsObject:message.args.latitude forKey:XXGJ_ARGS_PARAM_LATITUDE];
        }
        if (message.args.duration)
        {
            [self setArgsObject:message.args.duration forKey:XXGJ_ARGS_PARAM_DURATION];
        }
        if (message.args.url)
        {
            [self setArgsObject:message.args.url forKey:XXGJ_ARGS_PARAM_URL];
        }
        if (message.args.redEnvelopeId)
        {
            [self setArgsObject:message.args.redEnvelopeId forKey:XXGJ_ARGS_PARAM_REDENVELOPE_ID];
        }
        if (message.args.updateTime)
        {
            [self setArgsObject:message.args.updateTime forKey:XXGJ_ARGS_PARAM_UPDATETIME];
        }
    }
    
    return self;
}

+ (instancetype)messageWithDataBaseMessage:(Message *)message
{
    return [[XXGJMessage alloc] initWithDataBaseMessage:message];
}

- (void)setValue:(id)value forUndefinedKey:(NSString *)key
{
    
}

- (void)setArgsObject:(id)object forKey:(NSString *)key
{
    NSMutableDictionary *muArgsDict = [NSMutableDictionary dictionaryWithDictionary:self.Args];
    [muArgsDict setObject:object forKey:key];
    self.Args = muArgsDict.copy;
}

- (void)removeArgsObject:(NSDictionary *)argObject
{
    NSMutableDictionary *muArgsDict = [NSMutableDictionary dictionaryWithDictionary:self.Args];
    [muArgsDict removeObjectForKey:[argObject.allKeys lastObject]];
    
    self.Args = muArgsDict.copy;
}

- (void)addArgsObject:(NSDictionary *)argObject
{
    NSMutableDictionary *muArgsDict = [NSMutableDictionary dictionaryWithDictionary:self.Args];
    [muArgsDict addEntriesFromDictionary:argObject];
    
    self.Args = muArgsDict.copy;
}

- (void)createArgsObject:(NSDictionary *)argObject
{
    self.Args = argObject;
}

- (instancetype)init
{
    if (self = [super init]) {
        self.Args = @{};
        self.ID   = @(0);
        self.IsGroup = @(0);
        self.Status  = @(0);
        self.isAck   = @(false);
        self.isClosingCost = @(false);
        self.sentCount     = @(0);
        self.MessageType   = @(XXGJNotFindMessage);
        self.BusinessType  = @"";
        self.uuid = [NSString uuidString];
        self.Created = [NSDate currentDuringTime];;
    }
    
    return self;
}

- (NSString *)messageToString
{
    if (!self.uuid)
    {
        self.uuid = [NSString uuidString];
    }
    if (!self.Created)
    {
        self.Created = [NSDate currentDuringTime];
    }
    
    NSDictionary *dict = @{@"Args":self.Args,
                           @"BusinessType":self.BusinessType,
                           @"Content":self.Content==nil?@"":self.Content,
                           @"Created":self.Created,
                           @"ID":self.ID,
                           @"IsGroup":self.IsGroup,
                           @"MessageType":self.MessageType,
                           @"Status":self.Status,
                           @"TargetId":self.TargetId,
                           @"UserId":self.UserId,
                           @"isAck":self.isAck,
                           @"isClosingCost":self.isClosingCost,
                           @"sentCount":self.sentCount,
                           @"uuid":self.uuid};
    
    return [NSString convertToJsonData:dict];
}

- (NSString *)messageToAckString
{
    if (!self.uuid)
    {
        self.uuid = [NSString uuidString];
    }
    if (!self.Created)
    {
        self.Created = [NSDate currentDuringTime];
    }
    
    NSDictionary *dict = @{@"Args":self.Args,
                           @"Content":self.Content==nil?@"":self.Content,
                           @"Created":self.Created,
                           @"ID":self.ID,
                           @"IsGroup":self.IsGroup,
                           @"MessageType":self.MessageType,
                           @"Status":self.Status,
                           @"TargetId":self.TargetId,
                           @"UserId":self.UserId,
                           @"isAck":@(true),
                           @"isClosingCost":self.isClosingCost,
                           @"sentCount":@(0),
                           @"uuid":self.uuid};
    
    return [NSString convertToJsonData:dict];
}

- (void)convertToMessage:(Message *)msg userId:(NSNumber *)userId
{
    msg.message_id = self.ID;
    msg.isGroup    = self.IsGroup;
    msg.isAck      = self.isAck;
    msg.sentCount  = self.sentCount;
    msg.uuid       = self.uuid;
    msg.businessType = @([XXGJBusinessType getTypeWithBusiness:self.BusinessType]);
    msg.messageType  = self.MessageType;
    msg.create       = self.Created;
    msg.content      = self.Content;
    msg.status       = @(1);
    msg.relationId   = self.Args[@"RelationId"];
    msg.targetId = self.TargetId;
    msg.userId   = userId;
    msg.isSender = @([self.UserId isEqualToNumber:userId]);
    if ([msg.businessType isEqualToNumber:@(XXGJBusinessFriendApply)] || [msg.businessType isEqualToNumber:@(XXGJBusinessFriendDel)] )
    {
        msg.senderId = self.Args[@"user"][@"ID"];
    }
    if ([msg.isGroup isEqualToNumber:@(YES)])
    {
        msg.targetId =  @([self.Args[@"groupId"] integerValue]);
        msg.senderId = self.UserId;
    }else
    {
        msg.targetId  = [msg.isSender boolValue]? self.TargetId: self.UserId;
    }
}

- (BOOL)getMessageArgsObject:(Args *)args
{
    if (self.Args)
    {
        for (NSString *propertyName in [args allPropertyNames])
        {
            if (self.Args[propertyName])
            {
                id propertyObj = self.Args[propertyName];
                if ([propertyName isEqualToString:@"redEnvelopeId"])
                {
                    [args setValue:[NSString stringWithFormat:@"%@", propertyObj] forKey:propertyName];
                }else{
                    [args setValue:self.Args[propertyName] forKey:propertyName];
                }
            }
        }
        return YES;
    }
    
    return NO;
}

- (void)logMessageString
{
    XXGJTypeMessage msgTpye  = (XXGJTypeMessage)[self.MessageType unsignedIntegerValue];
    XXGJTypeBusiness bsnType = [XXGJBusinessType getTypeWithBusiness:self.BusinessType];

    NSLog(@"------one message log------");
    NSString *logMS = [NSString stringWithFormat:@"%@  %@  %@  %@  %@  %@", self.ID, [XXGJMessageType messageToString:msgTpye], [XXGJBusinessType businessByType:bsnType], self.Content, self.UserId, self.TargetId];
    NSLog(@"%@", logMS);
}

@end
