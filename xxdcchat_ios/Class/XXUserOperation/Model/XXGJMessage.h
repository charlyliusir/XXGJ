//
//  XXGJMessage.h
//  IMSocketClient
//
//  Created by 刘朝龙 on 2017/3/9.
//  Copyright © 2017年 刘朝龙. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "XXGJMessageType.h"
#import "XXGJBusinessType.h"
@class Message, Args;

#define XXGJ_ARGS_PARAM_GROUPID @"groupId"

#define XXGJ_ARGS_PARAM_IMAGEURL    @"imgUrl"
#define XXGJ_ARGS_PARAM_PROGRESS    @"progress"
#define XXGJ_ARGS_PARAM_BITMPTIME   @"bitmapTime"
#define XXGJ_ARGS_PARAM_BITMPHEIGHT @"bitmapHeight"
#define XXGJ_ARGS_PARAM_BITMPWIDTH  @"bitmapWidth"
#define XXGJ_ARGS_PARAM_BITMPSIZE   @"bitmapSize"
#define XXGJ_ARGS_PARAM_UPDATETIME  @"updateTime"
#define XXGJ_ARGS_PARAM_ADDRESS     @"address"
#define XXGJ_ARGS_PARAM_LONGITUDE   @"longitude"
#define XXGJ_ARGS_PARAM_LATITUDE    @"latitude"
#define XXGJ_ARGS_PARAM_DURATION    @"duration"
#define XXGJ_ARGS_PARAM_URL    @"url"
#define XXGJ_ARGS_PARAM_REDENVELOPE_ID    @"redEnvelopeId"

@interface XXGJMessage : NSObject

@property (nonatomic, readonly, copy)NSDictionary *Args;// 多参数
@property (nonatomic,   copy)NSString *BusinessType;    // 业务类型
@property (nonatomic,   copy)NSString *Content;         // 内容
@property (nonatomic, strong)NSNumber *Created;         // 创建时间
@property (nonatomic, readonly, strong)NSNumber *ID;    // 事件ID
@property (nonatomic, strong)NSNumber *IsGroup;         // 是否群发  0：否  1：是
@property (nonatomic, strong)NSNumber *MessageType;     // 消息类型
@property (nonatomic, strong)NSNumber *Status;          // 0：已发送  1：未发送
@property (nonatomic, strong)NSNumber *TargetId;        // 目标对象 ID
@property (nonatomic, strong)NSNumber *UserId;          // 发消息人 ID
@property (nonatomic, strong)NSNumber *isAck;           // 是否收到应答
@property (nonatomic, readonly, strong)NSNumber *isClosingCost;   // 是已经结算信息咨询费
@property (nonatomic, readonly, strong)NSNumber *sentCount;       // 消息发送次数
@property (nonatomic, readonly,   copy)NSString *uuid;          // 消息唯一标识

- (instancetype)initWithDataBaseMessage:(Message *)message;
+ (instancetype)messageWithDataBaseMessage:(Message *)message;

- (NSString *)messageToString;
- (NSString *)messageToAckString;
- (void)setArgsObject:(id)object forKey:(NSString *)key;
- (void)addArgsObject:(NSDictionary *)argObject;
- (void)removeArgsObject:(NSDictionary *)argObject;
- (void)createArgsObject:(NSDictionary *)argObject;
- (void)logMessageString;
- (void)convertToMessage:(Message *)msg userId:(NSNumber *)userId;
- (BOOL)getMessageArgsObject:(Args *)args;
@end
