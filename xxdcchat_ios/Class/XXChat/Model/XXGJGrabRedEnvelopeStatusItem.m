//
//  XXGJGrabRedEnvelopeStatusItem.m
//  xxdcchat_ios
//
//  Created by 刘朝龙 on 2017/4/26.
//  Copyright © 2017年 刘朝龙. All rights reserved.
//

#import "XXGJGrabRedEnvelopeStatusItem.h"
#define Grab_Status_Key_Delivery @"delivery"
#define Grab_Status_Key_GrabList @"grabList"
#define Grab_Status_Key_RedEnvelope @"redEnvelope"
#define Grab_Status_Key_UserEntity @"userEntity"
#define Grab_Status_Key_RedEnvelope_Id @"id"

@implementation XXGJGrabRedEnvelopeStatusItem

- (void)setValue:(id)value forUndefinedKey:(NSString *)key
{
    if ([key isEqualToString:Grab_Status_Key_Delivery])
    {
        [self.grapDeliveryItem setValuesForKeysWithDictionary:value];
    }
    else if ([key isEqualToString:Grab_Status_Key_GrabList])
    {
        [self.grapUserItemArr removeAllObjects];
        NSArray *grabList = (NSArray *)value;
        for (NSDictionary *grabListItem in grabList)
        {
            XXGJGrabRedEnvelopeItem *grabItem = [[XXGJGrabRedEnvelopeItem alloc] init];
            [grabItem setValuesForKeysWithDictionary:grabListItem];
            [self.grapUserItemArr addObject:grabItem];
        }
    }
    else if ([key isEqualToString:Grab_Status_Key_RedEnvelope])
    {
        [self setValuesForKeysWithDictionary:value];
    }
    else if ([key isEqualToString:Grab_Status_Key_UserEntity])
    {
        [self.grapUserEntity setValuesForKeysWithDictionary:value];
    }
    else if ([key isEqualToString:Grab_Status_Key_RedEnvelope_Id])
    {
        self.redEnvelopeId = value;
    }
}

#pragma mark - lazy method
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

- (NSMutableArray<XXGJGrabRedEnvelopeItem *> *)grapUserItemArr
{
    if (!_grapUserItemArr)
    {
        _grapUserItemArr = [NSMutableArray array];
    }
    return _grapUserItemArr;
}

@end
