//
//  QXYChatViewController.h
//  QXYChatMessageUI
//
//  Created by 刘朝龙 on 2017/3/14.
//  Copyright © 2017年 刘朝龙. All rights reserved.
//

#import "XXGJViewController.h"
@class User, Group;

typedef NS_ENUM(NSInteger, ChatStyle) {
    ChatStyleSystem,
    ChatStyleGroup,
    ChatStyleFriend
};

@interface QXYChatViewController : XXGJViewController

@property (nonatomic, assign)ChatStyle chatStyle;
@property (nonatomic, strong)User *chatUser;
@property (nonatomic, strong)Group *chatGroup;

@end
