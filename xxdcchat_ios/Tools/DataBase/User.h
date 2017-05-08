//
//  User.h
//  xxdcchat_ios
//
//  Created by 刘朝龙 on 2017/3/17.
//  Copyright © 2017年 刘朝龙. All rights reserved.
//
#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Group, Message;

@interface User : NSManagedObject
+ (NSFetchRequest<User *> *)fetchRequest;

@property (nonatomic,   copy) NSString *avatar;         /** 用户头像*/
@property (nonatomic, strong) NSNumber *create;           /** 用户创建时间*/
@property (nonatomic,   copy) NSString *introduction;   /** 用户介绍*/
@property (nonatomic,   copy) NSString *nick_name;      /** 用户昵称*/
@property (nonatomic,   copy) NSString *mobile;         /** 用户手机*/
@property (nonatomic,   copy) NSString *email;          /** 用户邮箱*/
@property (nonatomic,   copy) NSString *company;        /** 用户职业*/
@property (nonatomic,   copy) NSString *terminalInfo;   /** 用户客户端信息*/
@property (nonatomic, strong) NSNumber *update;           /** 用户更新时间*/
@property (nonatomic,   copy) NSNumber *user_id;        /** 用户的 id*/
@property (nonatomic,   copy) NSString *location;       /** 用户现居地*/
@property (nonatomic,   copy) NSString *address;        /** 用户现居地*/
@property (nonatomic,   copy) NSString *sex;            /** 用户的性别*/
@property (nonatomic,   copy) NSString *hometown;       /** 用户的 家乡*/
@property (nonatomic, strong) NSNumber *avoidRemind;    /** 消息免打扰*/
@property (nonatomic, strong) NSNumber *reveCount;      /** 最新未处理信息量*/
@property (nonatomic, copy) NSString *birthday;         /** 用户的生日*/
@property (nonatomic, strong) NSSet<User *> *friends;   /** 用户朋友列表*/
@property (nonatomic, strong) NSSet<Group *> *groups;   /** 用户的群组列表*/

- (NSArray *)getUserFriends;
- (NSArray *)getUserGroups;

@end

@interface User (CoreDataGeneratedAccessors)

- (void)addFriendsObject:(User *)value;
- (void)removeFriendsObject:(User *)value;
- (void)addFriends:(NSSet<User *> *)values;
- (void)removeFriends:(NSSet<User *> *)values;

- (void)addGroupsObject:(Group *)value;
- (void)removeGroupsObject:(Group *)value;
- (void)addGroups:(NSSet<Group *> *)values;
- (void)removeGroups:(NSSet<Group *> *)values;

@end
