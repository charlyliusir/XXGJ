//
//  XXGJChatItemList.h
//  xxdcchat_ios
//
//  Created by 刘朝龙 on 2017/3/16.
//  Copyright © 2017年 刘朝龙. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface XXGJChatItemList : NSObject

@property (nonatomic, strong)NSString *iconName;
@property (nonatomic, strong)NSString *iconURL;
@property (nonatomic, strong)NSString *nameTitle;
@property (nonatomic, strong)NSString *infoTitle;
@property (nonatomic, strong)NSString *timeTitle;
@property (nonatomic, assign)NSInteger newMessageCount;
@property (nonatomic, assign)BOOL avoidRemind;

- (instancetype)initChatItemListWithName:(NSString *)name icon:(NSString *)icon info:(NSString *)info time:(NSString *)time newMessageCount:(NSInteger)count avoidRemind:(BOOL)avoidRemind;
+ (instancetype)chatItemListWithName:(NSString *)name icon:(NSString *)icon info:(NSString *)info time:(NSString *)time  newMessageCount:(NSInteger)count avoidRemind:(BOOL)avoidRemind;

@end
