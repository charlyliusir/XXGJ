//
//  Message.h
//  xxdcchat_ios
//
//  Created by 刘朝龙 on 2017/3/17.
//  Copyright © 2017年 刘朝龙. All rights reserved.
//

#import <CoreData/CoreData.h>
#import <CoreData/CoreData.h>

@class User, Group, Relation, Args;

@interface Message : NSManagedObject

+ (NSFetchRequest<Message *> *)fetchRequest;

@property (nonatomic, strong) NSNumber *businessType;   /** 消息业务类型*/
@property (nonatomic,   copy) NSString *content;        /** 消息主体信息*/
@property (nonatomic, strong) NSNumber *create;         /** 消息创建时间*/
@property (nonatomic, strong) NSNumber *isAck;          /** 消息是否发生/接收成功*/
@property (nonatomic, strong) NSNumber *senderId;       /** 群消息发送者*/
@property (nonatomic, strong) NSNumber *isReSend;       /** 是否需要重新发送*/
@property (nonatomic, strong) NSNumber *isGroup;        /** 是否是群消息*/
@property (nonatomic, strong) NSNumber *message_id;     /** 消息 id 唯一标示*/
@property (nonatomic, strong) NSNumber *relationId;     /** 关系 id 唯一标示*/
@property (nonatomic, strong) NSNumber *messageType;    /** 消息类型*/
@property (nonatomic, strong) NSNumber *sentCount;      /** 发送消息数量*/
@property (nonatomic, strong) NSNumber *status;         /** 消息发送状态*/
@property (nonatomic, strong) NSNumber *targetId;       /** 接收消息对象的 id*/
@property (nonatomic, strong) NSNumber *update;         /** 消息最后更新时间*/
@property (nonatomic, strong) NSNumber *userId;         /** 发送消息对象的 id*/
@property (nonatomic, strong) NSNumber *isSender;       /** 用户是否是发送消息的主体*/
@property (nonatomic,   copy) NSString *uuid;           /** 消息的唯一标示*/
@property (nonatomic, strong) Args * args;

@end
