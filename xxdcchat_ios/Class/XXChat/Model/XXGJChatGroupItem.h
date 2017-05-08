//
//  XXGJChatGroupItem.h
//  xxdcchat_ios
//
//  Created by 刘朝龙 on 2017/3/18.
//  Copyright © 2017年 刘朝龙. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface XXGJChatGroupItem : NSObject

@property (nonatomic, strong)NSString *iconURL;
@property (nonatomic, strong)NSString *groupName;
@property (nonatomic, strong)NSNumber *groupId;

- (instancetype)initWithName:(NSString *)name iconURL:(NSString *)url groupId:(NSNumber *)groupid;
+ (instancetype)itemWithName:(NSString *)name iconURL:(NSString *)url groupId:(NSNumber *)groupid;

@end
