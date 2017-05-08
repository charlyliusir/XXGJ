//
//  Relation.h
//  xxdcchat_ios
//
//  Created by 刘朝龙 on 2017/3/17.
//  Copyright © 2017年 刘朝龙. All rights reserved.
//

#import <CoreData/CoreData.h>
#import <CoreData/CoreData.h>

@interface Relation : NSManagedObject
+ (NSFetchRequest<Relation *> *)fetchRequest;

@property (nonatomic, strong)NSNumber *created;         /** 关系创建时间*/
@property (nonatomic, strong)NSNumber *isSysRelation;   /** 是否是系统关系*/
@property (nonatomic,   copy)NSString *relation_id;     /** 关系唯一标示*/
@property (nonatomic, strong)NSNumber *smsgFlag;        /** */
@property (nonatomic,   copy)NSString *target_id;       /** 目标对象 id*/
@property (nonatomic, strong)NSNumber *targetagree;     /** 目标对象是否同意建立关系*/
@property (nonatomic, strong)NSNumber *tmsgFlag;        /** */
@property (nonatomic, strong)NSNumber *type;            /** 关系类型 好友 or 群组*/
@property (nonatomic, strong)NSNumber *update;          /** 关系最后更新时间*/
@property (nonatomic,   copy)NSString *user_id;         /** 用户对象 id*/
@property (nonatomic, strong)NSNumber *useragree;       /** 用户是否同意建立关系*/
@end
