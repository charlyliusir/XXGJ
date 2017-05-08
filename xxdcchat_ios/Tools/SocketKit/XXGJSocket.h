//
//  XXGJSocket.h
//  xxdcchat_ios
//
//  Created by 刘朝龙 on 2017/5/3.
//  Copyright © 2017年 刘朝龙. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSUInteger, SocketOffline){
    SocketOfflineByOther = -1, // 没有设置
    SocketOfflineByServer= 0,// 服务器掉线，默认为0
    SocketOfflineByUser,  // 用户主动cut
};

typedef void(^ReadMessageBlock)(id data);
typedef void(^StopReConnectedBlock)();

@interface XXGJSocket : NSObject
// 心跳计时,在特定3个心跳内如果没有读取到数据,开启重连机制
@property (nonatomic, assign)NSUInteger timeHeartBeat;
// 读取到消息的回调
@property (nonatomic, copy)ReadMessageBlock redMessageBlock;
// 停止重连回调
@property (nonatomic, copy)StopReConnectedBlock stopReConnectedBlock;
// socket 连接状态
@property (nonatomic, assign)BOOL socketIsConnected;
#pragma mark -- 实例方法
singleton_interface(XXGJSocket)

-(void)socketConnectHost;   // socket连接
-(void)cutOffSocket;        // 断开socket连接
-(void)setSocketOffline:(SocketOffline)offline; // 设置断开链接样式
-(SocketOffline)getSocketOffline; // 获取断开链接样式

- (void)sendChatMessage:(id)message; // 发送聊天信息

@end
