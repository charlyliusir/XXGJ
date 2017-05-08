//
//  LGPickerGroup.m
//  LGPhotoBrowser
//
//  Created by ligang on 15/10/27.
//  Copyright (c) 2015年 L&G. All rights reserved.

#import "LGPhotoPickerGroup.h"

@implementation LGPhotoPickerGroup

- (void)setGroupName:(NSString *)groupName
{
    if([groupName isEqualToString:@"Camera Roll"])
    {
        _groupName = @"相机胶卷";
    }else if ([groupName isEqualToString:@"Saved Photos"])
    {
        _groupName = @"保存相册";
    }else if ([groupName isEqualToString:@"My Photo Stream"])
    {
        _groupName = @"我的照片流";
    }else
    {
        _groupName = groupName;
    }
}

@end
