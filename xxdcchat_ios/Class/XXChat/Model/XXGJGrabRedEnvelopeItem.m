//
//  XXGJGrabRedEnvelopeItem.m
//  xxdcchat_ios
//
//  Created by 刘朝龙 on 2017/4/26.
//  Copyright © 2017年 刘朝龙. All rights reserved.
//

#import "XXGJGrabRedEnvelopeItem.h"
#define Grab_Status_Key_UserEntity @"userEntity"

@implementation XXGJGrabRedEnvelopeItem

- (void)setValuesForKeysWithDictionary:(NSDictionary<NSString *,id> *)keyedValues
{
    NSMutableDictionary *mutableKeyedValues = keyedValues.mutableCopy;
    [self.grapUserEntity setValuesForKeysWithDictionary:[mutableKeyedValues[Grab_Status_Key_UserEntity] mutableCopy]];
    [mutableKeyedValues removeObjectForKey:Grab_Status_Key_UserEntity];
    [self.grapDeliveryItem setValuesForKeysWithDictionary:mutableKeyedValues.mutableCopy];
}

- (void)setValue:(id)value forUndefinedKey:(NSString *)key
{
    
}

- (XXGJGrapUserEntity *)grapUserEntity
{
    if (!_grapUserEntity)
    {
        _grapUserEntity = [[XXGJGrapUserEntity alloc] init];
    }
    return _grapUserEntity;
}

- (XXGJGrapDeliveryItem *)grapDeliveryItem
{
    if (!_grapDeliveryItem)
    {
        _grapDeliveryItem = [[XXGJGrapDeliveryItem alloc] init];
    }
    return _grapDeliveryItem;
}

@end
