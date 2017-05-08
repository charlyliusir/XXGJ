//
//  XXGJLocationInfo.m
//  xxdcchat_ios
//
//  Created by 刘朝龙 on 2017/4/11.
//  Copyright © 2017年 刘朝龙. All rights reserved.
//

#import "XXGJLocationInfo.h"

@implementation XXGJLocationInfo

- (instancetype)initWithName:(NSString *)name address:(NSString *)address city:(NSString *)city location:(CLLocationCoordinate2D)location
{
    if (self = [super init])
    {
        self.name = name;
        self.address = address;
        self.city = city;
        self.location = location;
    }
    return self;
}
+ (instancetype)locationInfoWithName:(NSString *)name address:(NSString *)address city:(NSString *)city location:(CLLocationCoordinate2D)location
{
    return [[XXGJLocationInfo alloc] initWithName:name address:address city:city location:location];
}

@end
