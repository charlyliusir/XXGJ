//
//  XXGJGrapDeliveryItem.m
//  xxdcchat_ios
//
//  Created by 刘朝龙 on 2017/4/26.
//  Copyright © 2017年 刘朝龙. All rights reserved.
//

#import "XXGJGrapDeliveryItem.h"

#define Grab_Status_Key_RedEnvelope_Id @"id"

@implementation XXGJGrapDeliveryItem

- (void)setValue:(id)value forUndefinedKey:(NSString *)key
{
    if ([key isEqualToString:Grab_Status_Key_RedEnvelope_Id])
    {
        self.grapid = value;
    }
}

@end
