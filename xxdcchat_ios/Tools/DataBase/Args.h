//
//  Args.h
//  xxdcchat_ios
//
//  Created by 刘朝龙 on 2017/3/22.
//  Copyright © 2017年 刘朝龙. All rights reserved.
//

#import <CoreData/CoreData.h>
@class Message;

@interface Args : NSManagedObject


@property (nonatomic,   copy) NSString *redEnvelopeId;  /** 红包id*/
@property (nonatomic,   copy) NSString *address;        /** 定位名称*/
@property (nonatomic, strong) NSNumber *latitude;       /** 经度*/
@property (nonatomic, strong) NSNumber *longitude;      /** 纬度*/
@property (nonatomic, strong) NSNumber *bitmapHeight;   /** 图片真是高度*/
@property (nonatomic, strong) NSNumber *bitmapWidth;    /** 图片真是宽度*/
@property (nonatomic, strong) NSNumber *bitmapSize;     /** 不太确定*/
@property (nonatomic,   copy) NSString *bitmapTime;     /** 一般为空*/
@property (nonatomic,   copy) NSString *progress;       /** 图片上传进度*/
@property (nonatomic,   copy) NSString *imgUrl;         /** 图片地址*/
@property (nonatomic,   copy) NSString *url;            /** 音频地址*/
@property (nonatomic, strong) NSNumber *duration;       /** 音频时长*/
@property (nonatomic,   copy) NSString *updateTime;     /** 更新时间*/
@property (nonatomic, strong) Message  *message;

- (NSArray *) allPropertyNames;

@end
