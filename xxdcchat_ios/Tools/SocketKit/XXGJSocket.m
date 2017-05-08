//
//  XXGJSocket.m
//  xxdcchat_ios
//
//  Created by 刘朝龙 on 2017/5/3.
//  Copyright © 2017年 刘朝龙. All rights reserved.
//

#import "XXGJSocket.h"
#import <GCDAsyncSocket.h>
#import "XXGJSocketHeader.h"

@interface XXGJSocket ()<GCDAsyncSocketDelegate>

@property (nonatomic, strong)GCDAsyncSocket *socket; // socket
@property (nonatomic, strong)NSTimer *timerHeartBeat; // 连接成功, 记录心跳计时, 如果超过3个心跳时间没有接受到消息, 开启重连机制
@property (nonatomic, assign)SocketOffline socketOffline;
@property (nonatomic, strong)NSDate *lastConnectedDate;

@end

@implementation XXGJSocket

singleton_implementation(XXGJSocket)

#pragma mark - 开发方法
// socket连接
-(void)socketConnectHost
{
    NSDate *nowDate = [NSDate date];
    // 避免重复创建连接
    if (_lastConnectedDate && [nowDate timeIntervalSinceDate:_lastConnectedDate] <= 4)
    {
        return;
    }
    // 0. 清空重连标识
    self.timeHeartBeat = 0;
    // 1. 创建 socket 对象
    dispatch_queue_t socketQueue = dispatch_get_global_queue(0, 0);
    self.socket = [[GCDAsyncSocket alloc] initWithDelegate:self delegateQueue:socketQueue];
    _socketOffline = SocketOfflineByServer;
    // 2. 判断是否连接成功
    NSError *error = nil;
    if (![self.socket connectToHost:XXGJ_IP onPort:XXGJ_PORT withTimeout:XXGJ_TIMEOUT error:&error])
    {
        [self.socket setDelegate:nil];
        NSLog(@"连接失败!");
    }
    // 3. 如果连接成功,开始接收数据
    [self.socket readDataWithTimeout:XXGJ_TIMEOUT tag:0];
}

// 断开socket连接
-(void)cutOffSocket
{
    NSLog(@"收到心跳包, 用户主动断开链接");
    _socketOffline = SocketOfflineByUser;
    [self.socket disconnect];
}

// 设置断开链接样式
-(void)setSocketOffline:(SocketOffline)offline
{
    _socketOffline = offline;
}
// 获取断开链接样式
-(SocketOffline)getSocketOffline
{
    return _socketOffline;
}

- (BOOL)socketIsConnected
{
    return self.socket.isConnected;
}

// 发送聊天信息
- (void)sendChatMessage:(id)message
{
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.socket writeData:[message dataUsingEncoding:NSUTF8StringEncoding] withTimeout:XXGJ_TIMEOUT tag:0];
    });
    
    [self.socket readDataWithTimeout:XXGJ_TIMEOUT tag:0];
    
}

#pragma mark - 私有方法
// 特定超时
- (void)bearkHeartBeat
{
    NSLog(@"收到心跳包, 超时响应, 断开链接");
    _socketOffline = SocketOfflineByServer;
    [self.socket disconnect];
}

- (void)listenHeartAck:(id)sender
{
    // 开启监听心跳监听器
    self.timerHeartBeat = [NSTimer timerWithTimeInterval:3 repeats:YES block:^(NSTimer * _Nonnull timer) {
        if (++ self.timeHeartBeat >= 3)
        {
            [self bearkHeartBeat];
        }
    }];
    [[NSRunLoop currentRunLoop] addTimer:self.timerHeartBeat forMode:NSRunLoopCommonModes];
    [[NSRunLoop currentRunLoop] run];
}

#pragma mark - GCDAsyncSocket 代理方法
- (void)socket:(GCDAsyncSocket *)sock didReadData:(NSData *)data withTag:(long)tag
{
    // 收到消息, 归零计时器数据, 防止被断开重连
    self.timeHeartBeat = 0;
    // 1. 将数据转换成 NSString 形式
    NSDictionary *dict = (NSDictionary *)[NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableLeaves error:nil];
    
    if (!dict) return; /** 过滤脏数据*/
    
    if (self.redMessageBlock)
    {
        self.redMessageBlock(dict);
    }
    /** 继续接收数据*/
    [self.socket readDataWithTimeout:XXGJ_TIMEOUT tag:0];
}

- (void)socket:(GCDAsyncSocket *)sock didConnectToHost:(NSString *)host port:(uint16_t)port
{
    NSLog(@"socket connect host : %@", host);
    NSLog(@"socket connect port : %d", port);
    [self performSelectorInBackground:@selector(listenHeartAck:) withObject:nil];
}

- (void)socketDidDisconnect:(GCDAsyncSocket *)sock withError:(NSError *)err
{
    NSLog(@"socketDidDisconnect:withError:%@", err);
    [self.timerHeartBeat invalidate]; // 停止计时器
    [self.socket setDelegate:nil];
    [self setSocket:nil];
    
    if (self.socketOffline == SocketOfflineByUser && self.stopReConnectedBlock)
    {
        self.stopReConnectedBlock();
    }
}

@end
