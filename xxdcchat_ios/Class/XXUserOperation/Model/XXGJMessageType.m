//
//  XXGJMessageType.m
//  IMSocketClient
//
//  Created by 刘朝龙 on 2017/3/12.
//  Copyright © 2017年 刘朝龙. All rights reserved.
//

#import "XXGJMessageType.h"

@implementation XXGJMessageType

+ (NSString *)messageToString:(XXGJTypeMessage)typeMessage
{
    NSArray *messagesArr = @[@"文本消息",@"图片消息",@"语音消息",@"心跳检测",@"富文本",@"红包",@"电话",@"应答消息",@"撤回消息"];
    return messagesArr[typeMessage];
}
@end
