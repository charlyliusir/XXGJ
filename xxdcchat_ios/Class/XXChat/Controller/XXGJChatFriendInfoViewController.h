//
//  XXGJChatFriendInfoViewController.h
//  xxdcchat_ios
//
//  Created by 刘朝龙 on 2017/3/31.
//  Copyright © 2017年 刘朝龙. All rights reserved.
//

#import "XXGJViewController.h"

typedef void(^ClearBlock)();

@interface XXGJChatFriendInfoViewController : XXGJViewController

@property (nonatomic, strong)User *user;

+ (instancetype)chatFriendInfoViewController;
- (void)setClearBlock:(ClearBlock)clearBlock;

@end
