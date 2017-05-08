//
//  Args.m
//  xxdcchat_ios
//
//  Created by 刘朝龙 on 2017/3/22.
//  Copyright © 2017年 刘朝龙. All rights reserved.
//

#import "Args.h"
#import <objc/runtime.h>

@implementation Args

///通过运行时获取当前对象的所有属性的名称，以数组的形式返回
- (NSArray *) allPropertyNames
{
    ///存储所有的属性名称
    NSMutableArray *allNames = [[NSMutableArray alloc] init];
    
    ///存储属性的个数
    unsigned int propertyCount = 0;
    
    ///通过运行时获取当前类的属性
    objc_property_t *propertys = class_copyPropertyList([self class], &propertyCount);
    
    //把属性放到数组中
    for (int i = 0; i < propertyCount; i ++) {
        ///取出第一个属性
        objc_property_t property = propertys[i];
        
        const char * propertyName = property_getName(property);
        
        [allNames addObject:[NSString stringWithUTF8String:propertyName]];
    }
    
    ///释放
    free(propertys);
    
    return allNames;
}

@dynamic address;
@dynamic latitude;
@dynamic longitude;
@dynamic bitmapHeight;
@dynamic bitmapWidth;
@dynamic bitmapSize;
@dynamic bitmapTime;
@dynamic imgUrl;
@dynamic progress;
@dynamic message;
@dynamic redEnvelopeId;
@dynamic url;
@dynamic duration;
@dynamic updateTime;

@end
