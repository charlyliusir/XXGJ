//
//  XXGJDBModelManager.h
//  xxdcchat_ios
//
//  Created by 刘朝龙 on 2017/3/18.
//  Copyright © 2017年 刘朝龙. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

#define TABLE_USER     @"User"
#define TABLE_GROUP    @"Group"
#define TABLE_MESSAGE  @"Message"
#define TABLE_NEW_MESSAGE  @"NewMessage"
#define TABLE_RELATION @"Relation"
#define TABLE_ARGS     @"Args"

@interface XXGJDBModelManager : NSObject

@property (nonatomic, strong)NSManagedObjectContext *context;

+ (instancetype)dbModelManager;

- (NSArray *)excuteTable:(NSString *)table;
- (NSArray *)excuteTable:(NSString *)table predicate:(NSString *)predicate;
- (NSArray *)excuteTable:(NSString *)table predicate:(NSString *)predicate limit:(NSInteger)limit;
- (NSArray *)excuteTable:(NSString *)table predicate:(NSString *)predicate limit:(NSInteger)limit order:(NSString *)order;
- (NSArray *)excuteTable:(NSString *)table predicate:(NSString *)predicate offset:(NSInteger)offset limit:(NSInteger)limit order:(NSString *)order ascending:(BOOL)ascending;

/**
 根据分组查询数据

 @param table 表名
 @param properties 查询字段
 @param groupby 分组依据
 @return 查询数据
 */
- (NSArray *)excuteTable:(NSString *)table properties:(NSArray *)properties groupby:(NSArray *)groupby;

/**
 查询表中此字段数据个数

 @param table 表名
 @param predicate 查询条件
 @return 返回个数
 */
- (NSInteger)excuteTable:(NSString *)table propertie:(NSString *)propertie countPredicate:(NSString *)predicate;


@end
