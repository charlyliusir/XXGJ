//
//  XXGJGrapuserEntity.m
//  xxdcchat_ios
//
//  Created by 刘朝龙 on 2017/4/26.
//  Copyright © 2017年 刘朝龙. All rights reserved.
//

#import "XXGJGrapUserEntity.h"
#define Grab_Status_Key_Avatar @"Avatar"
@implementation XXGJGrapUserEntity

- (void)setValue:(id)value forUndefinedKey:(NSString *)key
{
    if ([key isEqualToString:Grab_Status_Key_Avatar])
    {
        self.userIcon = [XXGJ_N_BASE_IMAGE_URL stringByAppendingString:value];
    }
}

@end
