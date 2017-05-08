//
//  XXGJSocketManager.h
//  XXGJSocketServer
//
//  Created by 刘朝龙 on 2017/3/9.
//  Copyright © 2017年 刘朝龙. All rights reserved.
//

#import <Foundation/Foundation.h>

#define XXGJ_SOCKET_CONNECT_HEART @"connect"
#define XXGJ_SOCKET_REVE_NEW_MESSAGE @"reveMessage"
#define XXGJ_SOCKET_OTHER_LOGIN_MESSAGE @"otherLoginMessage"
#define XXGJ_SOCKET_DEAWN_MESSAGE @"drawnMessage"
#define XXGJ_SOCKET_UPDATE_FRIEND @"updateFriend"
#define XXGJ_SOCKET_UPDATE_GROUP  @"updateGroup"

@interface XXGJSocketManager : NSObject

@property (nonatomic, assign)BOOL socketConnected; // socket 连接
@property (nonatomic, assign)BOOL userIsLogin; // 用户登录
@property (nonatomic, strong)NSString *session_key; // sessionKey
@property (nonatomic, assign)BOOL isAutoLogin;

#pragma mark - method
singleton_interface(XXGJSocketManager) // 单例方法

- (void)startListenChatMessage; // 开启socket监听接收聊天信息
- (void)stopListenChatMessage;  // 停止socket监听接收聊天信息
- (void)setSocketOffline:(NSUInteger)offline; // 设置断开链接样式

- (void)startOpenReConnectedThread;
- (void)stopReConnectedThread;

- (void)sendChatMessage:(id)chatMessage; // 发送一条聊天消息
- (void)reSendMessage; // 重发消息
@end
