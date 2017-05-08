//
//  XXGJBusinessType.m
//  IMSocketClient
//
//  Created by 刘朝龙 on 2017/3/12.
//  Copyright © 2017年 刘朝龙. All rights reserved.
//

#import "XXGJBusinessType.h"

@implementation XXGJBusinessType

+ (XXGJTypeBusiness)getTypeWithBusiness:(NSString *)business
{
    if ([business isEmpty])
    {
        return XXGJBusinessNotFind;
    }
    NSArray *businessArr = @[@{@"register":@"注册"},
                             @{@"login":@"登录"},
                             @{@"loginout":@"登出"},
                             @{@"chatp2p":@"聊天"},
                             @{@"chatroom":@"群聊"},
                             @{@"offline":@"下线"},
                             @{@"success":@"成功"},
                             @{@"buddylist":@"好友"},
                             @{@"friendApply":@"添加好友"},
                             @{@"friendDel":@"删除好友"},
                             @{@"groupApply":@"加群"},
                             @{@"failure":@"失败"},
                             @{@"heart":@"心跳"},
                             @{@"other_login":@"异地登录"},
                             @{@"notLogin":@"未登录"},
                             @{@"notConnect":@"未连接"},
                             @{@"sysMsg":@"系统通知"},
                             @{@"redEnvelope":@"红包"},
                             @{@"phoneRequestTalk":@"发起电话请求"},
                             @{@"phoneRefuseTalk":@"拒绝电话请求"},
                             @{@"phonePromiseTalk":@"同意通话请求"},
                             @{@"phoneStopTalk":@"结束电话谈话"},
                             @{@"phoneVoicePacket":@"普通电话数据包"},
                             @{@"":@"没有业务逻辑"}];
    
    int index = 0;
    for (NSDictionary *dict in businessArr) {
        if ([[[dict allKeys] firstObject] isEqualToString:business]) {
            break;
        }
        index ++;
    }
    
    return (XXGJTypeBusiness)index;
}

+ (NSString *)typeBusinessToString:(XXGJTypeBusiness)typeBusiness
{
    if (typeBusiness == XXGJBusinessNotFind)
    {
        return @"";
    }
    NSArray *businessArr = @[@{@"register":@"注册"},
                             @{@"login":@"登录"},
                             @{@"loginout":@"登出"},
                             @{@"chatp2p":@"聊天"},
                             @{@"chatroom":@"群聊"},
                             @{@"offline":@"下线"},
                             @{@"success":@"成功"},
                             @{@"buddylist":@"好友"},
                             @{@"friendApply":@"添加好友"},
                             @{@"friendDel":@"删除好友"},
                             @{@"groupApply":@"加群"},
                             @{@"failure":@"失败"},
                             @{@"heart":@"心跳"},
                             @{@"other_login":@"异地登录"},
                             @{@"notLogin":@"未登录"},
                             @{@"notConnect":@"未连接"},
                             @{@"sysMsg":@"系统通知"},
                             @{@"redEnvelope":@"红包"},
                             @{@"phoneRequestTalk":@"发起电话请求"},
                             @{@"phoneRefuseTalk":@"拒绝电话请求"},
                             @{@"phonePromiseTalk":@"同意通话请求"},
                             @{@"phoneStopTalk":@"结束电话谈话"},
                             @{@"phoneVoicePacket":@"普通电话数据包"},
                             @{@"":@"没有业务逻辑"}];
    
    NSDictionary *businessDic = businessArr[typeBusiness];
    
    return businessDic[[[businessDic allKeys] firstObject]];
}

+ (NSString *)businessByType:(XXGJTypeBusiness)typeBusiness
{
    
    if (typeBusiness == XXGJBusinessNotFind)
    {
        return @"没有业务逻辑";
    }
    
    NSArray *businessArr = @[@{@"register":@"注册"},
                             @{@"login":@"登录"},
                             @{@"loginout":@"登出"},
                             @{@"chatp2p":@"聊天"},
                             @{@"chatroom":@"群聊"},
                             @{@"offline":@"下线"},
                             @{@"success":@"成功"},
                             @{@"buddylist":@"好友"},
                             @{@"friendApply":@"添加好友"},
                             @{@"friendDel":@"删除好友"},
                             @{@"groupApply":@"加群"},
                             @{@"failure":@"失败"},
                             @{@"heart":@"心跳"},
                             @{@"other_login":@"异地登录"},
                             @{@"notLogin":@"未登录"},
                             @{@"notConnect":@"未连接"},
                             @{@"sysMsg":@"系统通知"},
                             @{@"redEnvelope":@"红包"},
                             @{@"phoneRequestTalk":@"发起电话请求"},
                             @{@"phoneRefuseTalk":@"拒绝电话请求"},
                             @{@"phonePromiseTalk":@"同意通话请求"},
                             @{@"phoneStopTalk":@"结束电话谈话"},
                             @{@"phoneVoicePacket":@"普通电话数据包"},
                             @{@"":@"没有业务逻辑"}];
    NSDictionary *businessDic = businessArr[typeBusiness];
    
    return [[businessDic allKeys] firstObject];
}
@end
