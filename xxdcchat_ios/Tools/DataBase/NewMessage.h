//
//  NewMessage.h
//  xxdcchat_ios
//
//  Created by 刘朝龙 on 2017/4/20.
//  Copyright © 2017年 刘朝龙. All rights reserved.
//

#import <CoreData/CoreData.h>

@interface NewMessage : NSManagedObject
+ (NSFetchRequest<NewMessage *> *)fetchRequest;

@property (nonatomic,   copy) NSString *content;        /** 消息主体信息*/
@property (nonatomic, strong) NSNumber *isGroup;        /** 是否是群消息*/
@property (nonatomic, strong) NSNumber *targetId;       /** 接收消息对象的 id*/
@property (nonatomic, strong) NSNumber *userId;         /** 发送消息对象的 id*/
@property (nonatomic, strong) NSNumber *update;         /** 消息最后更新时间*/
@property (nonatomic,   copy) NSString *uuid;           /** 消息的唯一标示*/
@property (nonatomic, strong) NSNumber *reveCount;      /** 最新未处理信息量*/

@end
