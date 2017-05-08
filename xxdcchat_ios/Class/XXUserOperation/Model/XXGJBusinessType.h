//
//  XXGJBusinessType.h
//  IMSocketClient
//
//  Created by 刘朝龙 on 2017/3/12.
//  Copyright © 2017年 刘朝龙. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger, XXGJTypeBusiness) {
    XXGJBusinessNotFind     = -1,   // 没有关系
    XXGJBusinessRegisster   = 0,    // 注册
    XXGJBusinessLogin,        // 登录
    XXGJBusinessLoginOut,     // 登出
    XXGJBusinessChatP2P,      // 聊天
    XXGJBusinessChatRoom,     // 群聊
    XXGJBusinessOffline,      // 下线
    XXGJBusinessSuccess,      // 成功
    XXGJBusinessBuddyList,    // 好友
    XXGJBusinessFriendApply,  // 添加好友
    XXGJBusinessFriendDel,    // 删除好友
    XXGJBusinessGroupApply,   // 加群
    XXGJBusinessFailure,      // 失败
    XXGJBusinessHeart,        // 心跳
    XXGJBusinessOtherLogin,   // 异地登录
    XXGJBusinessNotLogin,     // 未登录
    XXGJBusinessNotConnect,   // 未连接
    XXGJBusinessSystem,       // 系统消息
    XXGJBusinessRedEnvelope,  // 红包
    XXGJBusinessPhoneRequesttalk, // 发起电话请求
    XXGJBusinessPhoneRefusetalk,  // 拒绝电话请求
    XXGJBusinessPhonePromisetalk, // 同意通话请求
    XXGJBusinessPhoneStoptalk,    // 结束电话谈话
    XXGJBusinessPhoneVoicepacket, // 普通电话数据包
};

@interface XXGJBusinessType : NSObject

+ (XXGJTypeBusiness)getTypeWithBusiness:(NSString *)business;
+ (NSString *)typeBusinessToString:(XXGJTypeBusiness)typeBusiness;
+ (NSString *)businessByType:(XXGJTypeBusiness)typeBusiness;
@end
