//
//  UISearchBar+XXGJChangeStyle.m
//  xxdcchat_ios
//
//  Created by 刘朝龙 on 2017/3/16.
//  Copyright © 2017年 刘朝龙. All rights reserved.
//

#import "UISearchBar+XXGJChangeStyle.h"

@implementation UISearchBar (XXGJChangeStyle)
- (UITextField *)getContentTextField
{
    
    return [self valueForKey:@"_searchField"];
}

- (void)chageTextFieldBgColor:(UIColor *)bgColor
{
    UITextField *searchField = [self getContentTextField];
    //改变searcher的textcolor
    searchField.backgroundColor = bgColor;
}


@end
