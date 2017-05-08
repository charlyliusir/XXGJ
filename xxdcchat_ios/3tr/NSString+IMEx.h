//
//  NSString+IMEx.h
//  IMSocketClient
//
//  Created by 刘朝龙 on 2017/3/10.
//  Copyright © 2017年 刘朝龙. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreGraphics/CoreGraphics.h>

@interface NSString (IMEx)
- (NSString *) md5;
+ (NSString *)uuidString;
+ (NSString *)convertToJsonData:(NSDictionary *)dict;
- (BOOL)isEmpty;
-(CGFloat)changeStationWidthTxtt:(CGFloat)widthText anfont:(CGFloat)fontSize;
@end
