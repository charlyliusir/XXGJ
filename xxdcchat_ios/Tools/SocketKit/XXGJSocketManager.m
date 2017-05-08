//
//  XXGJSocketManager.m
//  XXGJSocketServer
//
//  Created by 刘朝龙 on 2017/3/9.
//  Copyright © 2017年 刘朝龙. All rights reserved.
//

#import "XXGJSocketManager.h"
#import "XXGJReSendMessageManager.h"
#import "XXGJSocket.h"
#import "XXGJMessage.h"
#import "AppDelegate.h"

#import "NewMessage.h"
#import "Message.h"
#import "Args.h"

@interface XXGJSocketManager()
{
    NSThread *heartbeatThread;
    NSThread *generalThread;
    dispatch_queue_t otherLoginQueue;
    dispatch_queue_t sendMessageQueue;
}

@property (nonatomic, strong)XXGJSocket *socket;
@property (nonatomic, strong)NSTimer *timerReConnect;
@property (nonatomic, weak) AppDelegate *appDelegate;

@end

@implementation XXGJSocketManager

singleton_implementation(XXGJSocketManager)

- (instancetype)init
{
    if ([super init])
    {
        heartbeatThread = [[NSThread alloc] initWithTarget:self selector:@selector(readHearBeat:) object:nil];
        generalThread   = [[NSThread alloc] initWithTarget:self selector:@selector(readGeneralData:) object:nil];
        [heartbeatThread start];
        [generalThread start];
        
        // appDelegate
        self.appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
        // 0. 创建一个socket
        self.socket = [XXGJSocket sharedXXGJSocket];
        __weak typeof(self)weakSelf = self;
        self.socket.redMessageBlock = ^(id data) {
            [weakSelf readChateMessage:data];
        };
        self.socket.stopReConnectedBlock = ^(){
            [weakSelf stopReConnectedThread];
        };
    }
    return self;
}

#pragma mark - getter and setter
- (BOOL)socketConnected
{
    return self.socket.socketIsConnected;
}

#pragma mark - lazy method
#pragma mark - open method
- (void)startOpenReConnectedThread
{
    // 2. 开启一个监听重连状态的线程队列
    [self performSelectorInBackground:@selector(reConnectedAsyncQueue) withObject:nil];
}
- (void)stopReConnectedThread
{
    [self.timerReConnect invalidate];
    [self setTimerReConnect:nil];
}
// 开启socket监听接收聊天信息
- (void)startListenChatMessage
{
    [self.socket socketConnectHost];
    [self startOpenReConnectedThread]; // 开启重连机制
}
// 停止socket监听接收聊天信息
- (void)stopListenChatMessage
{
    [self.socket cutOffSocket];
}
// 设置断开链接样式
-(void)setSocketOffline:(NSUInteger)offline
{
    [self.socket setSocketOffline:offline];
}
// 发送一条聊天消息
- (void)sendChatMessage:(id)chatMessage
{
    XXGJMessage *message = (XXGJMessage *)chatMessage;
    // 将发送的消息放入到需要重新发送的消息列表中
    [self updateNewMessage:message isSendMessage:YES];
    [self.appDelegate saveContext];
    [[XXGJReSendMessageManager sharedReSendMessageManger] addReSendMessageObject:message objectUuid:message.uuid];
    if (self.userIsLogin)
    {
        [self sendMessage:[chatMessage messageToString]];
    }
}
// 重发消息
- (void)reSendMessage
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [[XXGJReSendMessageManager sharedReSendMessageManger] copyReSendMessage];
        id firstObject = [[XXGJReSendMessageManager sharedReSendMessageManger] getFirstReSendMessageObject];
        while (firstObject!=nil)
        {
            [self sendMessage:[firstObject messageToString]];
            firstObject = [[XXGJReSendMessageManager sharedReSendMessageManger] getFirstReSendMessageObject];
            NSLog(@"重发消息...");
        }
    });
}

#pragma mark - private method
- (void)readHearBeat:(id)sender
{
    [[NSRunLoop currentRunLoop] addPort:[NSPort port] forMode:NSDefaultRunLoopMode];
    [[NSRunLoop currentRunLoop] run];
}
- (void)readGeneralData:(id)sender
{
    [[NSRunLoop currentRunLoop] addPort:[NSPort port] forMode:NSDefaultRunLoopMode];
    [[NSRunLoop currentRunLoop] run];
}
// 开启一个监听重连状态的线程队列
- (void)reConnectedAsyncQueue
{
    self.timerReConnect = [NSTimer timerWithTimeInterval:5 repeats:YES block:^(NSTimer * _Nonnull timer) {
        NSLog(@"断连执行");
        // 添加判断, 如果socket没有连接 并且 当前链接状态是服务器断开
        if (![self socketConnected] && [self.socket getSocketOffline] == SocketOfflineByServer && self.appDelegate.user)
        {
            NSLog(@"重连 socket 。。。");
            [self setSocketOffline:SocketOfflineByServer];
            [self.socket socketConnectHost];
        }else {
            [[XXGJReSendMessageManager sharedReSendMessageManger] checkUpdateTime];
            [self reSendMessage];
        }
    }];
    [[NSRunLoop currentRunLoop] addTimer:self.timerReConnect forMode:NSRunLoopCommonModes];
    [[NSRunLoop currentRunLoop] run];
}
// socket 读取到聊天消息
- (void)readChateMessage:(id)data
{
    /** 根据读取数据, 创建新消息对象*/
    XXGJMessage *sHeart = [[XXGJMessage alloc] init];
    [sHeart setValuesForKeysWithDictionary:data];
    
    /** 获取消息的业务类型和消息类型*/
    XXGJTypeMessage messagetType  = [sHeart.MessageType unsignedIntegerValue];
    XXGJTypeBusiness businessType = [XXGJBusinessType getTypeWithBusiness:sHeart.BusinessType];
    
    /** 打印接收消息日志*/
    [sHeart logMessageString];
    [self unPackMessage:sHeart checkMessageType:messagetType bufinessType:businessType];
    
}

- (void)convertDelAndApplyMessage:(NSDictionary *)argsDictionary
{
    NSArray *oldDeleteFriendMessages = [self.appDelegate.dbModelManage excuteTable:TABLE_MESSAGE predicate:[NSString stringWithFormat:@"userId==%@ and senderId==%@ and businessType=='9'", self.appDelegate.user.user_id, argsDictionary[@"ID"]]];
    NSArray *oldApplyFriendMessages = [self.appDelegate.dbModelManage excuteTable:TABLE_MESSAGE predicate:[NSString stringWithFormat:@"userId==%@ and senderId==%@ and businessType=='8'", self.appDelegate.user.user_id, argsDictionary[@"ID"]]];
    for (Message *oldMessage in oldDeleteFriendMessages)
    {
        [self.appDelegate.managedObjectContext deleteObject:oldMessage];
    }
    for (Message *oldMessage in oldApplyFriendMessages)
    {
        [self.appDelegate.managedObjectContext deleteObject:oldMessage];
    }
}
/**
 发送心跳包
 
 @param message 心跳包数据
 */
- (void)sendHeartBeat:(XXGJMessage *)message
{
    self.userIsLogin = [message.Args[@"isLogin"] boolValue];
    self.session_key = message.Args[@"session_key"];
    NSLog(@"收到心跳包, 用户当前状态:%@", self.userIsLogin ? @"登录":@"离线");
    if (self.userIsLogin == NO)
    {
        NSLog(@"收到心跳包, 用户未登录, 通知登录");
        [[NSNotificationCenter defaultCenter] postNotificationName:XXGJ_SOCKET_CONNECT_HEART object:nil];
    }
    message.Content = [message.Content stringByReplacingOccurrencesOfString:@"server" withString:@"client"];
    [self sendMessage:[message messageToString]];
}

- (void)unPackGeneralMessage:(XXGJMessage *)generalMessage
{
    /** 获取消息的业务类型和消息类型*/
    XXGJTypeMessage messageType  = [generalMessage.MessageType unsignedIntegerValue];
    XXGJTypeBusiness businessType = [XXGJBusinessType getTypeWithBusiness:generalMessage.BusinessType];
    /** ACK 包信息*/
    if (messageType == XXGJAckMessage)
    {
        [self updateAckMessage:generalMessage];
    }
    /** 撤回消息*/
    else if (messageType == XXGJWithdrawnMessage)
    {
        [self drawnMessage:generalMessage];
    }
    /** 图片信息、富文本、语音消息、红包消息*/
    else if (messageType == XXGJImageMessage
             || messageType == XXGJRichText
             || messageType == XXGJAudioMessage
             || messageType == XXGJRedEnvelope)
    {
        [self receiveSeniorMessage:generalMessage];
    }
    /** 删除好友*/
    else if (businessType == XXGJBusinessFriendDel)
    {
        [self deleteFriend:generalMessage];
    }
    /** 添加好友*/
    else if (businessType == XXGJBusinessFriendApply)
    {
        [self applyFriend:generalMessage];
    }
    /** 系统消息*/
    else if (businessType == XXGJBusinessSystem)
    {
        [self systemMessage:generalMessage];
    }
    /** 账号异地登录*/
    else if (businessType == XXGJBusinessOtherLogin)
    {
        [self otherLogin:generalMessage];
    }
    /** 添加好友*/ /** 添加群*/ /** 用户聊天数据*/ /** 登录登出*/
    else
    {
        [self updateMessage:generalMessage reContent:nil args:nil];
    }
}

/**
 更新数据的 ACK 信息
 
 @param message ACK 包数据
 */
- (void)updateAckMessage:(XXGJMessage *)message
{
    NSLog(@"ack -- message...");
    NSString *targetUUID = message.Args[@"targetUuid"];
    
    [[XXGJReSendMessageManager sharedReSendMessageManger] removeReSendMessageObject:targetUUID];
    
    if ([self.appDelegate.drawnMessageUuidDict.allKeys containsObject:targetUUID])
    {
        /** 将撤销的信息, 从数据库删除*/
        XXGJMessage *drawnMessage = self.appDelegate.drawnMessageUuidDict[targetUUID];
        NSString *drawnMessageUUID= drawnMessage.Args[@"targetUuid"];
        Message *msg = [self.appDelegate.dbModelManage excuteTable:TABLE_MESSAGE predicate:[NSString stringWithFormat:@"uuid=='%@'", drawnMessageUUID] limit:1].lastObject;
        
        if (msg)
        {
            /** 发送通知*/
            [[NSNotificationCenter defaultCenter] postNotificationName:XXGJ_SOCKET_DEAWN_MESSAGE object:msg];
            [self updateMessage:drawnMessage reContent:nil args:nil];
        }
        [self.appDelegate.drawnMessageUuidDict removeObjectForKey:targetUUID];
    }else
    {
        Message *msg = [self.appDelegate.dbModelManage excuteTable:TABLE_MESSAGE predicate:[NSString stringWithFormat:@"uuid=='%@'", targetUUID] limit:1].lastObject;
        
        if (msg)
        {
            msg.isAck = @(YES);
            msg.isReSend = @(NO);
            [self.appDelegate saveContext];
        }
        /** 发送通知*/
        [[NSNotificationCenter defaultCenter] postNotificationName:XXGJ_SOCKET_REVE_NEW_MESSAGE object:msg];
    }
}

- (void)drawnMessage:(XXGJMessage *)message
{
    /** 将撤销的信息, 从数据库删除*/
    NSString *targetUUID = message.Args[@"targetUuid"];
    Message *msg = [self.appDelegate.dbModelManage excuteTable:TABLE_MESSAGE predicate:[NSString stringWithFormat:@"uuid=='%@'", targetUUID] limit:1].lastObject;
    
    if (msg)
    {
        /** 发送通知*/
        [[NSNotificationCenter defaultCenter] postNotificationName:XXGJ_SOCKET_DEAWN_MESSAGE object:msg];
        [self updateMessage:message reContent:@"有一条信息被撤回" args:nil];
    }
    [self sendAckMsg:message];
    
}

/**
 删除好友
 
 @param message 删除信息
 */
- (void)deleteFriend:(XXGJMessage *)message
{
    /** 从删除信息中提取被删除用户的信息*/
    NSDictionary *user = message.Args[@"user"];
    /** 解除好友关系*/
    User *delUser = [self.appDelegate.dbModelManage excuteTable:TABLE_USER predicate:[NSString stringWithFormat:@"user_id==%@", user[@"ID"]] limit:1].lastObject;
    if (delUser && [self.appDelegate.user.friends containsObject:delUser])
    /** 如果好友中存在该用户,删除该用户以及该用户持有的数据*/
    {
        /** 删除用户的好友*/
        [self.appDelegate.user removeFriendsObject:delUser];
    }
    
    /** 注意需要先更新啊，才能在数据库中读取到数据*/
    [self convertDelAndApplyMessage:user];
    /** 更新数据库数据*/
    [self.appDelegate saveContext];
    [self updateMessage:message reContent:nil args:nil];
    /** 发送通知*/
    [[NSNotificationCenter defaultCenter] postNotificationName:XXGJ_SOCKET_REVE_NEW_MESSAGE object:message];
    
    /** 表示已经成功接收数据*/
    [self sendAckMsg:message];
}

/**
 添加好友请求
 
 @param message 添加信息
 */
- (void)applyFriend:(XXGJMessage *)message
{
    /** 从添加信息中提取申请添加用户的信息*/
    NSDictionary *user = message.Args[@"user"];
    /** 过滤错误信息*/
    if (!user)
    {
        /** 表示已经成功接收数据*/
        [self sendAckMsg:message];
        return;
    }
    /** 解除好友关系*/
    User *addUser = [self.appDelegate.dbModelManage excuteTable:TABLE_USER predicate:[NSString stringWithFormat:@"user_id==%@", user[@"ID"]] limit:1].lastObject;
    if (!addUser)
    /** 如果申请添加好友用户不在数据库中, 创建一个新用户*/
    {
        addUser = [NSEntityDescription insertNewObjectForEntityForName:TABLE_USER inManagedObjectContext:self.appDelegate.managedObjectContext];
        addUser.user_id = user[@"ID"];
        addUser.mobile  = user[@"mobile"];
    }
    addUser.address = user[@"address"];
    addUser.avatar  = user[@"Avatar"];
    addUser.nick_name = user[@"NickName"];
    addUser.location  = user[@"area"];
    addUser.sex       = [user[@"sex"] isEqualToString:@"Sex-male"] ? @"男" : @"女";
    
    /** 注意需要先更新啊，才能在数据库中读取到数据*/
    [self convertDelAndApplyMessage:user];
    /** 更新数据库数据*/
    [self.appDelegate saveContext];
    [self updateMessage:message reContent:nil args:nil];
    /** 发送通知*/
    [[NSNotificationCenter defaultCenter] postNotificationName:XXGJ_SOCKET_REVE_NEW_MESSAGE object:message];
    
    /** 表示已经成功接收数据*/
    [self sendAckMsg:message];
}

- (void)systemMessage:(XXGJMessage *)message
{
    /** 发送通知*/
    [[XXGJUserRequestManager sharedRequestMananger] updateFriend];
    [self updateMessage:message reContent:nil args:nil];
}

/**
 用户账号在其他设备登录, 将现在账号踢下线
 
 @param message 消息
 */
- (void)otherLogin:(XXGJMessage *)message
{
    // 第一步, 解析数据并返回 ack 标记
    [self updateMessage:message reContent:nil args:nil];
    // 第二步, 发送异地登录通知
    [[NSNotificationCenter defaultCenter] postNotificationName:XXGJ_SOCKET_OTHER_LOGIN_MESSAGE object:nil];
}

- (void)receiveSeniorMessage:(XXGJMessage *)message
{
    Args *args = [NSEntityDescription insertNewObjectForEntityForName:TABLE_ARGS inManagedObjectContext:self.appDelegate.managedObjectContext];
    if (![message getMessageArgsObject:args])
    {
        args = nil;
    }
    if (args && args.url)
    {
        [XXGJNetKit downloadAudio:args.url withFileName:[NSString stringWithFormat:@"%@.spx", message.Created] rBlock:^(id obj, BOOL success, NSError *error) {
            args.url = (NSString *)obj;
            dispatch_async(dispatch_get_main_queue(), ^{
                [self updateMessage:message reContent:nil args:args];
            });
        }];
    }else
    {
        [self updateMessage:message reContent:nil args:args];
    }
}

/**
 更新群组包信息
 
 @param message 信息数据
 */
- (void)updateMessage:(XXGJMessage *)message reContent:(NSString *)content args:(Args *)args
{
    /** 创建消息对象*/
    Message *msg  = [self.appDelegate.dbModelManage excuteTable:TABLE_MESSAGE predicate:[NSString stringWithFormat:@"uuid=='%@'", message.uuid] limit:1].lastObject;
    if (!msg)
    {
        msg = [NSEntityDescription insertNewObjectForEntityForName:TABLE_MESSAGE inManagedObjectContext:self.appDelegate.managedObjectContext];
        /** 将消息数据更新到消息对象中*/
        [message convertToMessage:msg userId:self.appDelegate.user.user_id];
        /** 更新 ACK 标识*/
        [msg setIsAck:@(YES)];
        [msg setIsReSend:@(NO)];
        /** 是否需要重新设置内容*/
        if (content)
        {
            [msg setContent:content];
        }
        if (args)
        {
            args.message = msg;
            msg.args     = args;
        }
        /** 更新最新消息*/
        [self updateNewMessage:message isSendMessage:NO];
        /** 更新数据库数据*/
        [self.appDelegate saveContext];
        /** 注意需要先更新啊，才能在数据库中读取到数据*/
        /** 发送通知*/
        [[NSNotificationCenter defaultCenter] postNotificationName:XXGJ_SOCKET_REVE_NEW_MESSAGE object:msg];
    }
    
    [self sendAckMsg:message];
}

- (void)updateNewMessage:(XXGJMessage *)message isSendMessage:(BOOL)isSended
{
    NSNumber *userId   = self.appDelegate.user.user_id;
    NSNumber *targetId = isSended ? message.TargetId : message.UserId;
    if ([message.IsGroup isEqualToNumber:@(YES)])
    {
        targetId = @([message.Args[@"groupId"] integerValue]);
    }
    NewMessage *newMessage = [self.appDelegate.dbModelManage excuteTable:TABLE_NEW_MESSAGE predicate:[NSString stringWithFormat:@"userId==%@ AND targetId==%@",userId, targetId] limit:1].lastObject;
    if (!newMessage)
    {
        newMessage = [NSEntityDescription insertNewObjectForEntityForName:TABLE_NEW_MESSAGE inManagedObjectContext:self.appDelegate.managedObjectContext];
        newMessage.isGroup  = message.IsGroup;
        newMessage.userId   = userId;
        newMessage.targetId = targetId;
    }
    if (!isSended)
    /** 是否收到新消息*/
    {
        newMessage.reveCount = @(newMessage.reveCount == nil ? 1 : ([newMessage.reveCount integerValue] + 1));
    }
    // 被重发的旧消息过滤
    if (newMessage.update && [message.Created longLongValue] < [newMessage.update longLongValue])
    {
        return;
    }
    // 已经保存过的消息过滤
    if (newMessage.uuid&&[newMessage.uuid isEqualToString:message.uuid])
    {
        return;
    }
    
    /** 赋值*/
    newMessage.uuid   = message.uuid;
    newMessage.update = message.Created;
    
    switch ([message.MessageType integerValue])
    {
        case XXGJTextMessage:
            newMessage.content = message.Content;
            break;
        case XXGJImageMessage:
            newMessage.content = @"[图片消息]";
            break;
        case XXGJAudioMessage:
            newMessage.content = @"[语音消息]";
            break;
        case XXGJRichText:
            newMessage.content = @"[富文本消息]";
            break;
        case XXGJRedEnvelope:
            newMessage.content = @"[红包消息]";
            break;
        case XXGJWithdrawnMessage:
            newMessage.content = @"[撤销消息]";
            break;
        default:
            break;
    }
}

/**
 发送已经接受到消息命令
 
 @param message 接受到的消息
 */
- (void)sendAckMsg:(XXGJMessage *)message
{
    
    /** 创建 ACK 消息对象*/
    XXGJMessage *ackMessage = message;
    ackMessage.MessageType  = @(XXGJAckMessage);
    /** 修改 ACK 的 Args 参数*/
    [ackMessage addArgsObject:@{@"targetUuid":message.uuid}];
    /** 发送消息*/
    [self sendMessage:[ackMessage messageToAckString]];
}

#pragma mark - 交互处理方法
- (void)sendMessage:(NSString *)message
{
    message = [message stringByAppendingString:@"\r\n"];
    [self.socket sendChatMessage:message];
}

#pragma mark - 解包处理
- (void)unPackMessage:(XXGJMessage *)message checkMessageType:(XXGJTypeMessage)messageType bufinessType:(XXGJTypeBusiness)businessType
{
    /** 心跳包信息*/
    if (messageType == XXGJHeartBeat)
    {
        [self performSelector:@selector(sendHeartBeat:) onThread:heartbeatThread withObject:message waitUntilDone:YES];
    }else
    {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self unPackGeneralMessage:message];
        });
//        [self performSelector:@selector() onThread:heartbeatThread withObject:message waitUntilDone:YES];
    }
}

@end
