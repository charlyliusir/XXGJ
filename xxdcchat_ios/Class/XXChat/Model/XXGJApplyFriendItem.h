//
//  XXGJApplyFriendItem.h
//  xxdcchat_ios
//
//  Created by 刘朝龙 on 2017/4/24.
//  Copyright © 2017年 刘朝龙. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface XXGJApplyFriendItem : NSObject

/** 用户头像地址*/
@property (nonatomic, copy)NSString *userIconUrl;
/** 用户名称*/
@property (nonatomic, copy)NSString *userNickName;
/** 用户请求的信息*/
@property (nonatomic, copy)NSString *userApplyContent;
/** 用户是否在好友列表中*/
@property (nonatomic, assign)BOOL isMyFriend;

- (instancetype)initWithUserIconUrl:(NSString *)userIconUrl userNickName:(NSString *)nickName userApplyContent:(NSString *)content isMyFriend:(BOOL)isMyFriend;
+ (instancetype)applyFriendItemWithUserIconUrl:(NSString *)userIconUrl userNickName:(NSString *)nickName userApplyContent:(NSString *)content isMyFriend:(BOOL)isMyFriend;

@end
