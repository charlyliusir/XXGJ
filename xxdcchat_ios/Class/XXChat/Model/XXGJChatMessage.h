//
//  XXGJChatMessage.h
//  xxdcchat_ios
//
//  Created by 刘朝龙 on 2017/3/22.
//  Copyright © 2017年 刘朝龙. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "XXGJMessageType.h"
#import "XXGJBusinessType.h"
@class Args;
typedef NS_ENUM(NSInteger, ChatCellStyle) {
    ChatCellStyleOther,
    ChatCellStyleMe
};
/// 这个 Model 是为了适配聊天 cell 的Model
@interface XXGJChatMessage : NSObject
@property (nonatomic, strong)NSNumber *created; /** 消息创建时间*/
@property (nonatomic, assign)BOOL ishiddenTimeView;       /** 隐藏时间控件*/
@property (nonatomic, strong)NSNumber *user_id;           /** 用户标识*/
@property (nonatomic, strong)NSNumber *relation_id;       /** 关系id*/
@property (nonatomic,   copy)NSString *msgUuid;           /** 信息唯一标示*/
@property (nonatomic, assign)XXGJTypeMessage messageType; /** 消息类型*/
@property (nonatomic, assign)XXGJTypeBusiness businessType; /** 消息业务类型*/
@property (nonatomic, assign)ChatCellStyle cellStyle;     /** 是否是消息发送者*/
@property (nonatomic, strong)NSNumber *isAck;             /** 消息是否有相应*/
@property (nonatomic, strong)NSNumber *isGroup;             /** 消息是否有相应*/
@property (nonatomic,   copy)NSString *chatContent;       /** 聊天内容*/
@property (nonatomic,   copy)NSString *userAvatar;        /** 用户头像地址*/
@property (nonatomic,   copy)NSString *userName;          /** 用户名字*/
@property (nonatomic, strong)NSNumber *chatTime;          /** 消息发送时间*/
@property (nonatomic, strong)NSNumber *cellHeight;        /** cell 的高度*/
@property (nonatomic, strong)Args *args;

@end
