//
//  XXGJApplyFriendItem.m
//  xxdcchat_ios
//
//  Created by 刘朝龙 on 2017/4/24.
//  Copyright © 2017年 刘朝龙. All rights reserved.
//

#import "XXGJApplyFriendItem.h"

@implementation XXGJApplyFriendItem
- (instancetype)initWithUserIconUrl:(NSString *)userIconUrl userNickName:(NSString *)nickName userApplyContent:(NSString *)content isMyFriend:(BOOL)isMyFriend
{
    if (self = [super init])
    {
        /** 重新拼接userIcon地址*/
        self.userIconUrl  = [XXGJ_N_BASE_IMAGE_URL stringByAppendingString:userIconUrl];
        self.userNickName = nickName;
        self.userApplyContent = content;
        self.isMyFriend = isMyFriend;
    }
    
    return self;
}

+ (instancetype)applyFriendItemWithUserIconUrl:(NSString *)userIconUrl userNickName:(NSString *)nickName userApplyContent:(NSString *)content isMyFriend:(BOOL)isMyFriend
{
    return [[XXGJApplyFriendItem alloc] initWithUserIconUrl:userIconUrl userNickName:nickName userApplyContent:content isMyFriend:isMyFriend];
}

@end
