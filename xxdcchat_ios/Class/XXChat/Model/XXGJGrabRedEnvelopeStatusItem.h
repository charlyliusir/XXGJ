//
//  XXGJGrabRedEnvelopeStatusItem.h
//  xxdcchat_ios
//
//  Created by 刘朝龙 on 2017/4/26.
//  Copyright © 2017年 刘朝龙. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "XXGJGrabRedEnvelopeItem.h"
#import "XXGJGrapUserEntity.h"

@interface XXGJGrabRedEnvelopeStatusItem : NSObject
@property (nonatomic, strong)XXGJGrapDeliveryItem *grapDeliveryItem;
/** 抢的红包列表*/
@property (nonatomic, strong)NSMutableArray <XXGJGrabRedEnvelopeItem *> * grapUserItemArr;
/** 发红包人的个人信息*/
@property (nonatomic, strong)XXGJGrapUserEntity *grapUserEntity;
/** 红包总金额*/
@property (nonatomic, strong)NSNumber *amount;
/** 红包id，这里需要转换一下，服务器传递过来的是id*/
@property (nonatomic, strong)NSNumber *redEnvelopeId;
/** 此红包状态最新更新时间*/
@property (nonatomic, strong)NSNumber *updateTime;
/** 此红包创建时间*/
@property (nonatomic, strong)NSNumber *createTime;
/** 发红包人说的话*/
@property (nonatomic,   copy)NSString *content;
/** 是不是群组红包*/
@property (nonatomic, strong)NSNumber *isGroup;
/** 随机红包 or 平分红包*/
@property (nonatomic, strong)NSNumber *isRandom;
/** 还剩多少钱*/
@property (nonatomic, strong)NSNumber *leftAmount;
/** 还剩多少个*/
@property (nonatomic, strong)NSNumber *leftNum;
/** 总共多少个*/
@property (nonatomic, strong)NSNumber *num;
/** 发红包用户的id*/
@property (nonatomic, strong)NSNumber *userId;
/** 接收红包用户或者群组id*/
@property (nonatomic, strong) NSNumber *targetId;

@end
