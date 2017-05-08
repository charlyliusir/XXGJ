//
//  XXGJDBModelManager.m
//  xxdcchat_ios
//
//  Created by 刘朝龙 on 2017/3/18.
//  Copyright © 2017年 刘朝龙. All rights reserved.
//

#import "XXGJDBModelManager.h"

@implementation XXGJDBModelManager

+ (instancetype)dbModelManager
{
    static XXGJDBModelManager *manager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [[XXGJDBModelManager alloc] init];
    });
    return manager;
}

- (NSArray *)excuteTable:(NSString *)table
{
    return [self excuteTable:table predicate:nil];
}
- (NSArray *)excuteTable:(NSString *)table predicate:(NSString *)predicate
{
    return [self excuteTable:table predicate:predicate limit:0];
}
- (NSArray *)excuteTable:(NSString *)table predicate:(NSString *)predicate limit:(NSInteger)limit
{
    return [self excuteTable:table predicate:predicate limit:limit order:nil];
}
- (NSArray *)excuteTable:(NSString *)table predicate:(NSString *)predicate limit:(NSInteger)limit order:(NSString *)order
{
    return [self excuteTable:table predicate:predicate offset:0 limit:limit order:order ascending:YES];
}

/**
 查询数据

 @param table 表
 @param predicate 条件
 @param offset 起始位置
 @param limit 查询数量
 @param order 排序
 @return 查询数据
 */
- (NSArray *)excuteTable:(NSString *)table predicate:(NSString *)predicate offset:(NSInteger)offset limit:(NSInteger)limit order:(NSString *)order ascending:(BOOL)ascending
{
    NSEntityDescription *entity = [NSEntityDescription entityForName:table inManagedObjectContext:self.context];
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    [fetchRequest setEntity:entity];
    
    NSMutableArray *sortDescriptors = [NSMutableArray array];    //排序用
    
    if (order) {
        [sortDescriptors addObject:[[NSSortDescriptor alloc] initWithKey:order ascending:ascending] ];  //排序用
        [fetchRequest setSortDescriptors:sortDescriptors];  //排序
    }
    if (limit>0) {
        [fetchRequest setFetchLimit:limit];
    }else{
        [fetchRequest setFetchLimit:0];
    }
    if (offset>0) {
        [fetchRequest setFetchOffset:offset];
    }else{
        [fetchRequest setFetchOffset:0];
    }
    
    if (predicate) {
        NSPredicate *pre = [NSPredicate predicateWithFormat:predicate];//查询条件
        [fetchRequest setPredicate:pre];  //查询条件
    }
    
    [fetchRequest setReturnsObjectsAsFaults:NO];
    NSError *error = nil;
    NSArray *fetchedItems = [self.context executeFetchRequest:fetchRequest error:&error];
    
    if (error)
    {
        NSLog(@"error %@", error);
        return nil;
    }
    
    return fetchedItems;
}

/**
 根据分组查询数据
 
 @param table 表名
 @param properties 查询字段
 @param groupby 分组依据
 @return 查询数据
 */
- (NSArray *)excuteTable:(NSString *)table properties:(NSArray *)properties groupby:(NSArray *)groupby
{
    NSFetchRequest * request = [NSFetchRequest fetchRequestWithEntityName:table];
    [request setResultType:NSDictionaryResultType]; //必须是这个
    
    //构造并加入Group By
    NSEntityDescription *entity = [NSEntityDescription entityForName:table inManagedObjectContext:self.context];
    NSMutableArray *groupArray = [NSMutableArray array];
    for (NSString *group in groupby) {
        NSAttributeDescription* adultNumGroupBy = [entity.attributesByName objectForKey:group];
        [groupArray addObject:adultNumGroupBy];
    }
    
    [request setPropertiesToGroupBy:groupArray];
    [request setPropertiesToFetch:properties];
    
    NSError* error;
    id result = [self.context executeFetchRequest:request error:&error];
    
    return result;
}

/**
 查询表中此字段数据个数
 
 @param table 表名
 @param predicate 查询条件
 @return 返回个数
 */
- (NSInteger)excuteTable:(NSString *)table propertie:(NSString *)propertie countPredicate:(NSString *)predicate
{
    NSFetchRequest * request = [NSFetchRequest fetchRequestWithEntityName:table];
    [request setResultType:NSDictionaryResultType]; //必须设置为这个类型
    
    //构造用于sum的ExpressionDescription（稍微有点繁琐啊）
    NSExpression *theCountExpression = [NSExpression expressionForFunction:@"count:" arguments:[NSArray arrayWithObject:[NSExpression expressionForKeyPath:propertie]]];
    NSExpressionDescription *expressionDescription = [[NSExpressionDescription alloc] init];
    [expressionDescription setName:@"count"];
    [expressionDescription setExpression:theCountExpression];
    [expressionDescription setExpressionResultType:NSInteger32AttributeType];
    
    if (predicate) {
        NSPredicate *pre = [NSPredicate predicateWithFormat:predicate];//查询条件
        [request setPredicate:pre];
    }
    
    //加入Request
    [request setPropertiesToFetch:[NSArray arrayWithObjects:expressionDescription,nil]];
    
    NSError* error;
    id result = [self.context executeFetchRequest:request error:&error];
    //返回的对象是一个字典的数组，取数组第一个元素，再用我们前面指定的key（也就是"maxAge"）去获取我们想要的值
    
    return [[[result objectAtIndex:0] objectForKey:@"count"] integerValue];
}

@end
