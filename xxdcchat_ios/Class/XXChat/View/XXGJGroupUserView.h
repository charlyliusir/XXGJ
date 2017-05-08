//
//  XXGJGroupUserView.h
//  xxdcchat_ios
//
//  Created by 刘朝龙 on 2017/3/31.
//  Copyright © 2017年 刘朝龙. All rights reserved.
//

#import <UIKit/UIKit.h>
@class User;

@protocol XXGJGropUserViewDelegat <NSObject>

- (void)clickAvatarBtn:(id)groupUserView userInfo:(User *)user;

@end

@interface XXGJGroupUserView : UIView

@property (nonatomic, assign)id <XXGJGropUserViewDelegat>delegate;
@property (nonatomic, assign)BOOL isGroupOwener; /** 是不是群主*/
@property (nonatomic, strong)User *user;

+ (instancetype)groupUserView:(User *)user isGroupOwener:(BOOL)isGroupOwener;

@end
