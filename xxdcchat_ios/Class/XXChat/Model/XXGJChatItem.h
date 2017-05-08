//
//  XXGJChatItem.h
//  xxdcchat_ios
//
//  Created by 刘朝龙 on 2017/3/16.
//  Copyright © 2017年 刘朝龙. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface XXGJChatItem : NSObject

@property (nonatomic, assign)BOOL isSelected;
@property (nonatomic, strong)NSString *iconName;
@property (nonatomic, strong)NSString *iconURL;
@property (nonatomic, strong)NSString *titleName;

- (instancetype)initWithName:(NSString *)name iconName:(NSString *)iconName iconURL:(NSString *)url;
+ (instancetype)itemWithName:(NSString *)name iconName:(NSString *)iconName iconURL:(NSString *)url;
+ (instancetype)itemWithName:(NSString *)name iconURL:(NSString *)url isSelected:(BOOL)isSelected;
@end
