//
//  XXGJUserRequestManager.h
//  xxdcchat_ios
//
//  Created by 刘朝龙 on 2017/3/31.
//  Copyright © 2017年 刘朝龙. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface XXGJUserRequestManager : NSObject

+ (instancetype)sharedRequestMananger;
- (void)updateFriend;
- (void)updateGroup;

@end
