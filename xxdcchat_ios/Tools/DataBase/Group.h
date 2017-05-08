//
//  Group.h
//  xxdcchat_ios
//
//  Created by 刘朝龙 on 2017/3/17.
//  Copyright © 2017年 刘朝龙. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class User, Message;

@interface Group : NSManagedObject

+ (NSFetchRequest<Group *> *)fetchRequest;

@property (nonatomic, strong) NSNumber *create;         /** 创建时间*/
@property (nonatomic, strong) NSNumber *creator;        /** 创建人*/
@property (nonatomic, strong) NSNumber * groupid;       /** 群组 id*/
@property (nonatomic, strong) NSNumber * groupType;     /** 群组类型*/
@property (nonatomic,   copy) NSString *introduction;   /** 群组描述*/
@property (nonatomic, strong) NSNumber * maxJoin;       /** 最大人数上限*/
@property (nonatomic, strong) NSNumber * joinCount;     /** 当前群组人数*/
@property (nonatomic,   copy) NSString *name;           /** 群组名称*/
@property (nonatomic,   copy) NSString *pic;            /** 群组图像地址*/
@property (nonatomic, strong) NSNumber *update;           /** 更新时间*/
@property (nonatomic, strong) NSNumber *avoidRemind;    /** 消息免打扰*/
@property (nonatomic, strong) NSNumber *reveCount;      /** 最新未处理信息量*/
@property (nonatomic, strong) NSSet<User *> *users;       /** 群组中的用户*/

- (NSArray *)groupMember;

@end

@interface Group (CoreDataGeneratedAccessors)

- (void)addUsersObject:(User *)value;
- (void)removeUsersObject:(User *)value;
- (void)addUsers:(NSSet<User *> *)values;
- (void)removeUsers:(NSSet<User *> *)values;

@end
