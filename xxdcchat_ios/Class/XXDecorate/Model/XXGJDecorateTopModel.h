//
//  XXGJDecorateTopModel.h
//  xxdcchat_ios
//
//  Created by 刘朝龙 on 2017/4/13.
//  Copyright © 2017年 刘朝龙. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface XXGJDecorateTopModel : NSObject

@property (nonatomic,   copy)NSString *iconName;
@property (nonatomic,   copy)NSString *title;
@property (nonatomic,   copy)NSString *subtitle;

- (instancetype)initWithTitle:(NSString *)title subTitle:(NSString *)subtitle iconName:(NSString *)iconName;
+ (instancetype)decorateTopModelWithTitle:(NSString *)title subTitle:(NSString *)subtitle iconName:(NSString *)iconName;

@end
