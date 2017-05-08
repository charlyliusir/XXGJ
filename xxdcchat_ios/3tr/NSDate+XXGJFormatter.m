//
//  NSDate+XXGJFormatter.m
//  xxdcchat_ios
//
//  Created by 刘朝龙 on 2017/3/18.
//  Copyright © 2017年 刘朝龙. All rights reserved.
//

#import "NSDate+XXGJFormatter.h"

@implementation NSDate (XXGJFormatter)

+ (NSDate *)datesinceTimeInterval:(NSTimeInterval)timeInterval
{
    return [NSDate dateWithTimeIntervalSince1970:timeInterval/1000];
}

+ (BOOL)isOverDays:(NSInteger)day afterTime:(NSTimeInterval)timeInterval
{
    if ([NSDate timeIntervalSinceReferenceDate]-timeInterval>=day)
    {
        return YES;
    }
    else
    {
        return NO;
    }
}

+ (NSString *)dateForSpecString:(NSTimeInterval)timeInterval
{
////    当天的消息，以每5分钟为一个跨度的显示时间；
////    消息超过1天、小于1周，显示星期+收发消息的时间；
////    消息大于1周，显示手机收发时间的日期。
//    NSDate *nowDate = [NSDate date];
//    NSDate *beforeDate = [NSDate datesinceTimeInterval:timeInterval];
//    NSDateFormatter *formatter = [[NSDateFormatter alloc]init];
//    
//    NSTimeInterval differenceInterval = [nowDate timeIntervalSinceDate:beforeDate];
//    NSTimeInterval day              = 24*60*60*60;
//    NSTimeInterval yesterday        = day*2;
//    NSTimeInterval beforeYesterday  = day*3;
//    NSTimeInterval weakday          = day*7;
//    
//    [formatter setAMSymbol:@"上午"];
//    [formatter setPMSymbol:@"下午"];
//    [formatter setWeekdaySymbols:@[@"周日",@"周一",@"周二",@"周三",@"周四",@"周五",@"周六"]];
//    
//    if (differenceInterval <= day) {
//        [formatter setDateFormat:@"a hh:mm"]; /**  显示 上午/下午 时间*/
//    }else if (differenceInterval > day && differenceInterval <= yesterday){
//        [formatter setDateFormat:@"昨天 a hh:mm"]; /**  显示 上午/下午 时间*/
//    }else if (differenceInterval > yesterday && differenceInterval <= beforeYesterday)
//    {
//        [formatter setDateFormat:@"前天 a hh:mm"]; /**  显示 上午/下午 时间*/
//    }else if (differenceInterval > beforeYesterday && differenceInterval <= weakday){
//        [formatter setDateFormat:@"eeee"];
//    }else{
//        [formatter setDateFormat:@"yyyy年MM月dd日"];
//    }
//    
//    return [formatter stringFromDate:beforeDate];
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDate *currentDate = [NSDate date];
    
    // 获取当前时间的年、月、日
    NSDateComponents *components = [calendar components:NSCalendarUnitYear| NSCalendarUnitMonth|NSCalendarUnitDay fromDate:currentDate];
    NSInteger currentYear = components.year;
    NSInteger currentMonth = components.month;
    NSInteger currentDay = components.day;
    
    // 获取消息发送时间的年、月、日
    NSDate *msgDate = [NSDate dateWithTimeIntervalSince1970:timeInterval/1000.0];
    components = [calendar components:NSCalendarUnitYear| NSCalendarUnitMonth|NSCalendarUnitDay fromDate:msgDate];
    CGFloat msgYear = components.year;
    CGFloat msgMonth = components.month;
    CGFloat msgDay = components.day;
    
    // 判断
    NSDateFormatter *dateFmt = [[NSDateFormatter alloc] init];
    if (currentYear == msgYear && currentMonth == msgMonth && currentDay == msgDay) {
        //今天
        dateFmt.dateFormat = @"HH:mm";
    }else if (currentYear == msgYear && currentMonth == msgMonth && currentDay-1 == msgDay ){
        //昨天
        dateFmt.dateFormat = @"昨天 HH:mm";
    }else{
        //昨天以前
        dateFmt.dateFormat = @"yyyy-MM-dd HH:mm";
    }
    
    return [dateFmt stringFromDate:msgDate];
}

+ (BOOL)didShowTimeView:(NSTimeInterval)timeInterval beforeTime:(NSTimeInterval)beforeTimeInterval;
{
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDate *currentDate = [NSDate date];
    
    // 获取当前时间的年、月、日
    NSDateComponents *components = [calendar components:NSCalendarUnitYear| NSCalendarUnitMonth|NSCalendarUnitDay fromDate:currentDate];
    NSInteger currentYear = components.year;
    NSInteger currentMonth = components.month;
    NSInteger currentDay = components.day;
    
    // 获取消息发送时间的年、月、日
    NSDate *msgDate = [NSDate dateWithTimeIntervalSince1970:timeInterval/1000.0];
    components = [calendar components:NSCalendarUnitYear| NSCalendarUnitMonth|NSCalendarUnitDay | NSCalendarUnitHour | NSCalendarUnitMinute fromDate:msgDate];
    NSInteger msgYear  = components.year;
    NSInteger msgMonth = components.month;
    NSInteger msgDay   = components.day;
    NSInteger msgHour= components.hour;
    NSInteger msgMins= components.minute;
    
    // 获取下一条消息发送时间的年、月、日
    NSDate *nMsgDate = [NSDate dateWithTimeIntervalSince1970:beforeTimeInterval/1000.0];
    components = [calendar components:NSCalendarUnitYear| NSCalendarUnitMonth|NSCalendarUnitDay | NSCalendarUnitHour | NSCalendarUnitMinute fromDate:nMsgDate];
    NSInteger nMsgYear  = components.year;
    NSInteger nMsgMonth = components.month;
    NSInteger nMmsgDay  = components.day;
    NSInteger nMsgHour= components.hour;
    NSInteger nMsgMins= components.minute;
    
    // 判断
    if (currentYear == msgYear && currentMonth == msgMonth && currentDay == msgDay) {
        /** 今天 每个5分钟进行显示*/
        if (nMsgHour == msgHour && nMsgMins - msgMins <= 5)
        {
            return NO;
        }else if(nMsgMins == msgHour + 1 && (nMsgMins + 60 - msgMins) <= 5)
        {
            return NO;
        }
        return YES;
    }else if(msgYear == nMsgYear && msgMonth == nMsgMonth && msgDay == nMmsgDay){
        /** 昨天以前都是一天的消息 按天显示*/
        return NO;
    }else{
        return YES;
    }
}

+ (BOOL)canDrawnMessageWithTimeInterval:(NSTimeInterval)timeInterval
{
    return [[NSDate date] timeIntervalSinceDate:[self datesinceTimeInterval:timeInterval]] <= 60*3;
}

+ (NSString *)dateForDateFormatter:(NSString *)dateFormatter
{
    NSDate *date = [NSDate date];
    NSDateFormatter *formatter = [[NSDateFormatter alloc]init];
    [formatter setDateFormat:dateFormatter];
    
    return [formatter stringFromDate:date];
}

- (NSString *)dateForDateFormatter:(NSString *)dateFormatter
{
    NSDateFormatter *formatter = [[NSDateFormatter alloc]init];
    [formatter setDateFormat:dateFormatter];
    
    return [formatter stringFromDate:self];
}

+ (NSNumber *)currentDuringTime
{
    NSTimeInterval time = [[NSDate date] timeIntervalSince1970]*1000;
    NSString *timeStr = [NSString stringWithFormat:@"%.0f", time];
    return @([timeStr longLongValue]);
}
@end
