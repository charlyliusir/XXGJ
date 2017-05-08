//
//  UISearchBar+XXGJChangeStyle.h
//  xxdcchat_ios
//
//  Created by 刘朝龙 on 2017/3/16.
//  Copyright © 2017年 刘朝龙. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UISearchBar (XXGJChangeStyle)
- (UITextField *)getContentTextField;
- (void)chageTextFieldBgColor:(UIColor *)bgColor;
@end
