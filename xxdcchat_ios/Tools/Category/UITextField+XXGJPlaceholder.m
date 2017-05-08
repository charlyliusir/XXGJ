//
//  UITextField+XXGJPlaceholder.m
//  xxdcchat_ios
//
//  Created by 刘朝龙 on 2017/3/16.
//  Copyright © 2017年 刘朝龙. All rights reserved.
//

#import "UITextField+XXGJPlaceholder.h"

@implementation UITextField (XXGJPlaceholder)
- (UILabel *)getPlaceholderLabel
{
    return [self valueForKey:@"_placeholderLabel"];
}
- (void)changePlaceHolderColor:(UIColor *)color
{
    [self setValue:color
         forKeyPath:@"_placeholderLabel.textColor"];
}
@end
