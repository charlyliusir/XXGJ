//
//  XXGJReSendMessageManager.h
//  xxdcchat_ios
//
//  Created by 刘朝龙 on 2017/4/27.
//  Copyright © 2017年 刘朝龙. All rights reserved.
//

#import <Foundation/Foundation.h>

#define NOTIFY_RESENDMESSAGE_RELOAD @"resendMessageReload"

@interface XXGJReSendMessageManager : NSObject

/** 重发消息uuid列表*/
@property (nonatomic, readonly, strong)NSMutableArray *reSendMessageObjectUuidArray;
/** 重发消息列表*/
@property (nonatomic, readonly, strong)NSMutableArray *reSendMessageObjectArray;
/** 重发消息copy数组*/
@property (nonatomic, readonly, strong)NSMutableArray *reSendMessageCopyObjectArray;


// 开发方法，包括添加重发消息和移除重发消息

/**
 重发消息管理器的单例方法

 @return 重发消息管理器
 */
+ (instancetype)sharedReSendMessageManger;

/**
 获取第一个重发消息

 @return 重发消息
 */
- (id)getFirstReSendMessageObject;


/**
 将需要重发的消息放入到重发队列
 */
- (void)copyReSendMessage;

/**
 添加重发消息

 @param object 重发消息
 @param objectUuid 重发消息的 uuid
 */
- (void)addReSendMessageObject:(id)object objectUuid:(NSString *)objectUuid;

/**
 移除重发消息

 @param objectUuid 重发消息 uuid
 */
- (void)removeReSendMessageObject:(NSString *)objectUuid;


/**
 检查添加重发消息的最新更新时间
 如果超过指定时间，则丢弃所有的重发消息
 同时发送通知，告知聊天界面重新刷新页面
 
 @return 是否有需要重发的消息
 */
- (BOOL)checkUpdateTime;

@end
