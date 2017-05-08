//
//  NSString+XXGJFileStore.m
//  xxdcchat_ios
//
//  Created by 刘朝龙 on 2017/3/27.
//  Copyright © 2017年 刘朝龙. All rights reserved.
//

#import "NSString+XXGJFileStore.h"

@implementation NSString (XXGJFileStore)

/**
 沙盒 Document 目录

 @return 目录
 */
+ (NSString *)documentStore
{
    return NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask,YES).lastObject;
}

/**
 沙盒 Library 目录

 @return 目录
 */
+ (NSString *)libraryStore
{
    return NSSearchPathForDirectoriesInDomains(NSLibraryDirectory,NSUserDomainMask,YES).lastObject;
}


/**
 沙盒 缓存 目录

 @return 目录
 */
+ (NSString *)cacheStore
{
    return NSSearchPathForDirectoriesInDomains(NSCachesDirectory,NSUserDomainMask,YES).lastObject;
}


/**
 目录拼接文件地址

 @param fileStore 文件夹名
 @return 地址
 */
- (NSString *)appendFileStore:(NSString *)fileStore
{
    return [self stringByAppendingPathComponent:fileStore];
}



/**
 文件地址

 @param fileName 文件名
 @return 地址
 */
+ (NSString *)fileStore:(NSString *)fileName
{
    NSString *baseStore = [self documentStore];
    return [baseStore stringByAppendingPathComponent:fileName];
}


/**
 创建文件目录中的文件夹

 @param filePath 文件目录
 @return 是否创建成功
 */
+ (BOOL)createFilePath:(NSString *)filePath
{
    NSFileManager *fileMananger = [NSFileManager defaultManager];
    if (![fileMananger fileExistsAtPath:filePath]) {
        NSError *error = nil;
        [fileMananger createDirectoryAtPath:filePath withIntermediateDirectories:YES attributes:nil error:&error];
        if (error)
        {
            NSLog(@"create file path : %@ failed!\n failed error: %@", filePath, error);
            return NO;
        }
    }
    return YES;
}

+ (NSDictionary *)getCityDictonary
{
    NSString *cityPath = [[NSBundle mainBundle] pathForResource:@"city" ofType:@"json"];
    NSData *cityData = [NSData dataWithContentsOfURL:[NSURL fileURLWithPath:cityPath]];
    return [NSJSONSerialization JSONObjectWithData:cityData options:NSJSONReadingAllowFragments error:nil];
}

+ (NSString *)getProvinceName:(id)provinceKey
{
    NSMutableString *provinceName = (NSMutableString *)[provinceKey mutableCopy];
    [provinceName replaceCharactersInRange:NSMakeRange(2, provinceName.length-2) withString:@"0000"];
    NSDictionary *provinceDict = [[self getCityDictonary] objectForKey:@"provinces"];
    return [provinceDict objectForKey:provinceName];
}

+ (NSString *)getCityName:(id)cityKey
{
    NSMutableString *cityName = (NSMutableString *)[cityKey mutableCopy];
    [cityName replaceCharactersInRange:NSMakeRange(2, cityName.length-2) withString:@"0000"];
    NSDictionary *cityDict = [[self getCityDictonary] objectForKey:@"cities"];
    
    NSArray *cityArray = cityDict[cityName];
    
    for (NSArray *nameArray in cityArray)
    {
        if ([nameArray.firstObject isEqualToString:cityKey])
        {
            cityName = [nameArray.lastObject mutableCopy];
            break;
        }
    }
    
    return cityName.copy;
}

@end
