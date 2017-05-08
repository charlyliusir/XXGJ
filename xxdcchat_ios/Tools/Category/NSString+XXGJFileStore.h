//
//  NSString+XXGJFileStore.h
//  xxdcchat_ios
//
//  Created by 刘朝龙 on 2017/3/27.
//  Copyright © 2017年 刘朝龙. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (XXGJFileStore)

+ (NSString *)documentStore;
+ (NSString *)libraryStore;
+ (NSString *)cacheStore;
+ (NSString *)fileStore:(NSString *)fileName;
- (NSString *)appendFileStore:(NSString *)fileStore;
+ (BOOL)createFilePath:(NSString *)filePath;

+ (NSDictionary *)getCityDictonary;
+ (NSString *)getProvinceName:(id)provinceKey;
+ (NSString *)getCityName:(id)cityKey;

@end
