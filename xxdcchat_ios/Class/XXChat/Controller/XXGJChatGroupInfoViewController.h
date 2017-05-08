//
//  XXGJChatGroupInfoViewController.h
//  xxdcchat_ios
//
//  Created by 刘朝龙 on 2017/3/31.
//  Copyright © 2017年 刘朝龙. All rights reserved.
//

#import "XXGJViewController.h"
@class Group;

typedef void(^ClearBlock)();

@interface XXGJChatGroupInfoViewController : XXGJViewController

@property (nonatomic, strong)Group *group;

+ (instancetype)chatGroupInfoViewController;
- (void)setClearBlock:(ClearBlock)clearBlock;

@end
