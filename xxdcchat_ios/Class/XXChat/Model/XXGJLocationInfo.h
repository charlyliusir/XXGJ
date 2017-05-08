//
//  XXGJLocationInfo.h
//  xxdcchat_ios
//
//  Created by 刘朝龙 on 2017/4/11.
//  Copyright © 2017年 刘朝龙. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

@interface XXGJLocationInfo : NSObject

@property (nonatomic,   copy)NSString *name;
@property (nonatomic,   copy)NSString *address;
@property (nonatomic,   copy)NSString *city;
@property (nonatomic,   assign)CLLocationCoordinate2D location;

- (instancetype)initWithName:(NSString *)name address:(NSString *)address city:(NSString *)city location:(CLLocationCoordinate2D)location;
+ (instancetype)locationInfoWithName:(NSString *)name address:(NSString *)address city:(NSString *)city location:(CLLocationCoordinate2D)location;
@end
