//
//  XXGJReSendMessageManager.m
//  xxdcchat_ios
//
//  Created by 刘朝龙 on 2017/4/27.
//  Copyright © 2017年 刘朝龙. All rights reserved.
//

#import "XXGJReSendMessageManager.h"

@interface XXGJReSendMessageManager ()

/** 最新重发消息更新时间*/
@property (nonatomic, readwrite, strong)NSDate *updateTime;
/** 重发消息列表*/
@property (nonatomic, readwrite, strong)NSMutableArray *reSendMessageObjectArray;
/** 重发消息列表*/
@property (nonatomic, readwrite, strong)NSMutableArray *reSendMessageCopyObjectArray;
/** 重发消息uuid列表*/
@property (nonatomic, readwrite, strong)NSMutableArray *reSendMessageObjectUuidArray;

@end

@implementation XXGJReSendMessageManager

/**
 重发消息管理器的单例方法
 
 @return 重发消息管理器
 */
+ (instancetype)sharedReSendMessageManger
{
    static XXGJReSendMessageManager *reSendMessageManager = nil;
    static dispatch_once_t t;
    dispatch_once(&t, ^{
        reSendMessageManager = [[XXGJReSendMessageManager alloc] init];
    });
    return reSendMessageManager;
}

#pragma mark - lazy method
- (NSMutableArray *)reSendMessageObjectArray
{
    if (!_reSendMessageObjectArray)
    {
        _reSendMessageObjectArray = [NSMutableArray array];
    }
    return _reSendMessageObjectArray;
}
- (NSMutableArray *)reSendMessageCopyObjectArray
{
    if (!_reSendMessageCopyObjectArray)
    {
        _reSendMessageCopyObjectArray = [NSMutableArray array];
    }
    return _reSendMessageCopyObjectArray;
}
- (NSMutableArray *)reSendMessageObjectUuidArray
{
    if (!_reSendMessageObjectUuidArray)
    {
        _reSendMessageObjectUuidArray = [NSMutableArray array];
    }
    return _reSendMessageObjectUuidArray;
}

#pragma mark - open method
/**
 获取第一个重发消息
 
 @return 重发消息
 */
- (id)getFirstReSendMessageObject
{
    if (self.reSendMessageCopyObjectArray.count > 0)
    {
        id firstReSendObject = self.reSendMessageCopyObjectArray.firstObject;
        if ([firstReSendObject isKindOfClass:[NSClassFromString(@"XXGJMessage") class]])
        {
            [self.reSendMessageCopyObjectArray removeObjectAtIndex:0];
            
            return firstReSendObject;
        }else
        {
            [self.reSendMessageCopyObjectArray removeObjectAtIndex:0];
            return nil;
        }
        
    }else
    {
        return nil;
    }
    
}

/**
 将需要重发的消息放入到重发队列
 */
- (void)copyReSendMessage
{
    [self.reSendMessageCopyObjectArray addObjectsFromArray:self.reSendMessageObjectArray];
}

/**
 添加重发消息
 
 @param object 重发消息
 @param objectUuid 重发消息的 uuid
 */
- (void)addReSendMessageObject:(id)object objectUuid:(NSString *)objectUuid
{
    // 1, 判断重发消息是否已经在重发队列中
    // 2, 如果不在队列中, 加入重发队列, 否则不用处理
    // 3, 将重发消息加入重发队列后, 通知聊天页面发生变化
    if (![self.reSendMessageObjectUuidArray containsObject:objectUuid])
    {
        // 0, 更新最新更新时间
        // 1, 重发消息列表添加重发消息
        // 2, 重发消息uuid列表添加重发消息uuid
        // 3, 通知聊天页面发生变化
        self.updateTime = [NSDate date];
        
        [self.reSendMessageObjectArray addObject:object];
        [self.reSendMessageObjectUuidArray addObject:objectUuid];
        
        [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFY_RESENDMESSAGE_RELOAD object:nil];
    } else
    {
        NSUInteger index = [self.reSendMessageObjectUuidArray indexOfObject:objectUuid];
        [self.reSendMessageObjectArray replaceObjectAtIndex:index withObject:object];
    }
}

/**
 移除重发消息
 
 @param objectUuid 重发消息 uuid
 */
- (void)removeReSendMessageObject:(NSString *)objectUuid
{
    // 1, 获取这条标识对应的index
    // 2, 根据index从重发消息列表中移除重发消息
    // 3, 从重发消息uuid列表中移除objectUuid
    if ([self.reSendMessageObjectUuidArray containsObject:objectUuid])
    {
        NSUInteger uuidIndex = [self.reSendMessageObjectUuidArray indexOfObject:objectUuid];
        [self.reSendMessageObjectArray removeObjectAtIndex:uuidIndex];
        [self.reSendMessageObjectUuidArray removeObject:objectUuid];
    }
    
    if (self.reSendMessageObjectArray.count <= 0)
    {
        [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFY_RESENDMESSAGE_RELOAD object:nil];
        self.updateTime = nil;
    }
}


/**
 检查添加重发消息的最新更新时间
 如果超过指定时间，则丢弃所有的重发消息
 同时发送通知，告知聊天界面重新刷新页面
 最后返回调用者，是否需要重新发送第一条消息
 @return 是否有需要重发的消息
 */
- (BOOL)checkUpdateTime
{
    // 1, 如果最新更新时间是空的, 则不处理
    // 2, 最新更新时间不是空的, 且当前时间距离最新更新时间超过了5分钟, 则放弃重新发送信息, 并给聊天界面发送通知
    // 3, 最新更新时间不是空的, 且当前时间距离最新更新时间不超过了30s, 则不用发送消息, 避免造成重复发送
    // 4, 其他情况同样不做处理
    // 5, 如果没有重发消息或者第二种情况存在, 标识不用重新发送消息
    
    if (self.updateTime &&
        [[NSDate date] timeIntervalSinceDate:self.updateTime] > 1*60)
    {
        // 1, 清空重发消息对象
        // 2, 清空重发消息uuid对象
        // 3, 通知聊天界面, 进行重新加载
        [self.reSendMessageObjectArray removeAllObjects];
        [self.reSendMessageCopyObjectArray removeAllObjects];
        [self.reSendMessageObjectUuidArray removeAllObjects];
        [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFY_RESENDMESSAGE_RELOAD object:nil];
        self.updateTime = nil;
        return NO;
    }
    else if (self.reSendMessageObjectArray.count <= 0)
    {
        return NO;
    }else
    {
        return YES;
    }
}

@end
