//
//  XXGJGrapuserEntity.h
//  xxdcchat_ios
//
//  Created by 刘朝龙 on 2017/4/26.
//  Copyright © 2017年 刘朝龙. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface XXGJGrapUserEntity : NSObject

@property (nonatomic,   copy)NSString *userIcon;
@property (nonatomic, strong)NSNumber *Created;
@property (nonatomic, strong)NSNumber *GroupID;
@property (nonatomic, strong)NSNumber *ID;
@property (nonatomic,   copy)NSString *NickName;
@property (nonatomic, strong)NSNumber *Updated;
@property (nonatomic,   copy)NSString *address;
@property (nonatomic,   copy)NSString *area;
@property (nonatomic, strong)NSNumber *distance;
@property (nonatomic, strong)NSNumber *isLogin;
@property (nonatomic, strong)NSNumber *isSysRelation;
@property (nonatomic, strong)NSNumber *latitude;
@property (nonatomic, strong)NSNumber *longitude;
@property (nonatomic,   copy)NSString *mobile;
@property (nonatomic, strong)NSNumber *onLine;
@property (nonatomic,   copy)NSString *sex;
@property (nonatomic,   copy)NSString *trueName;

@end
