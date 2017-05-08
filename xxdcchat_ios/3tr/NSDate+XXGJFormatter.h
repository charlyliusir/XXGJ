//
//  NSDate+XXGJFormatter.h
//  xxdcchat_ios
//
//  Created by 刘朝龙 on 2017/3/18.
//  Copyright © 2017年 刘朝龙. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSDate (XXGJFormatter)

+ (NSDate *)datesinceTimeInterval:(NSTimeInterval)timeInterval;
+ (BOOL)isOverDays:(NSInteger)day afterTime:(NSTimeInterval)timeInterval;
+ (NSString *)dateForSpecString:(NSTimeInterval)timeInterval;
+ (NSString *)dateForDateFormatter:(NSString *)dateFormatter;
+ (NSNumber *)currentDuringTime;
+ (BOOL)didShowTimeView:(NSTimeInterval)timeInterval beforeTime:(NSTimeInterval)beforeTimeInterval;
+ (BOOL)canDrawnMessageWithTimeInterval:(NSTimeInterval)timeInterval;

- (NSString *)dateForDateFormatter:(NSString *)dateFormatter;

@end
