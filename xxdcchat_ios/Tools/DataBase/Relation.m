//
//  Relation.m
//  xxdcchat_ios
//
//  Created by 刘朝龙 on 2017/3/17.
//  Copyright © 2017年 刘朝龙. All rights reserved.
//

#import "Relation.h"

@implementation Relation

+ (NSFetchRequest<Relation *> *)fetchRequest
{
    return [[NSFetchRequest alloc] initWithEntityName:@"Relation"];
}

@dynamic created;
@dynamic isSysRelation;
@dynamic relation_id;
@dynamic smsgFlag;
@dynamic target_id;
@dynamic targetagree;
@dynamic tmsgFlag;
@dynamic type;
@dynamic update;
@dynamic user_id;
@dynamic useragree;

@end
