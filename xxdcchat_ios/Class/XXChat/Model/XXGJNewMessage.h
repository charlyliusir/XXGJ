//
//  XXGJNewMessage.h
//  xxdcchat_ios
//
//  Created by 刘朝龙 on 2017/3/25.
//  Copyright © 2017年 刘朝龙. All rights reserved.
//

#import <Foundation/Foundation.h>
@class NewMessage;

@interface XXGJNewMessage : NSObject

@property (nonatomic, strong)id msgObject;          /** 消息所属对象*/
@property (nonatomic, strong)NewMessage *tNewMessage;   /** 最新消息*/

- (instancetype)initWithObject:(id)msgObject newMessage:(NewMessage *)tNewMessage;
+ (instancetype)newMessageWithObject:(id)msgObject newMessage:(NewMessage *)tNewMessage;

@end
