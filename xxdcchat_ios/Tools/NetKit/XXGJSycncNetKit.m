//
//  XXGJSycncNetKit.m
//  xxdcchat_ios
//
//  Created by 刘朝龙 on 2017/3/19.
//  Copyright © 2017年 刘朝龙. All rights reserved.
//

#import "XXGJSycncNetKit.h"
#import "AFHTTPSessionManager+Synchronous.h"

@interface XXGJSycncNetKit ()


@end

@implementation XXGJSycncNetKit

+ (NSString *)reqUrlWithpFile:(NSString *)pFile cFile:(NSString *)cFile
{
    return [NSString stringWithFormat:@"%@%@%@", XXGJ_N_BASE_URL, pFile, cFile];
}

+ (NSDictionary *)getCityFile
{
    NSString *reqUrl = @"http://api.7xingyao.com/mobile/common/areaTreeJosn";
    return [self postRequestWithUrl:reqUrl param:nil];
}

/**
 查找一个群组
 
 @param param 查找参数[1. group_id]
 */
+ (NSDictionary *)searchGroup:(NSDictionary *)param
{
    NSString *reqUrl = [self reqUrlWithpFile:XXGJ_N_PFILE_GROUP cFile:XXGJ_N_PFILE_GROUP_GET];
    return [self postRequestWithUrl:reqUrl param:param];
}

/**
 获取用户跟自己的关系
 
 @param param 获取关系参数 [1. user_id, 2. from_user_id]
 */
+ (NSDictionary *)getPersonRelation:(NSDictionary *)param
{
    NSString *reqUrl = [self reqUrlWithpFile:XXGJ_N_PFILE_USER cFile:XXGJ_N_CFILE_USER_RELATION];
    return [self postRequestWithUrl:reqUrl param:param];
}

/**
 获取好友信息
 
 @param param 好友信息参数 [1. user_id]
 */
+ (NSDictionary *)getFriend:(NSDictionary *)param
{
    NSString *reqUrl = [self reqUrlWithpFile:XXGJ_N_PFILE_FRIEND cFile:XXGJ_N_CFILE_FRIEND_GET];
    return [self postRequestWithUrl:reqUrl param:param];
}

/**
 获取好友列表
 
 @param param 获取好友列表参数 [1. user_id 2. relation_type 3. currentPage 4. pageSize 5. nick_name]
 ** 注意：relation_type 0-个人好友 1-群好友 *
 ** 注意：nick_name 为选填参数 *
 */
+ (NSDictionary *)getFriendList:(NSDictionary *)param
{
    NSString *reqUrl = [self reqUrlWithpFile:XXGJ_N_PFILE_FRIEND cFile:XXGJ_N_CFILE_FRIEND_LIST];
    return [self postRequestWithUrl:reqUrl param:param];
}

/**
 根据用户名查询全体用户列表
 
 @param param 查询参数 [1. nick_name 2. current_page 3. page_size]
 */
+ (NSDictionary *)searchUserList:(NSDictionary *)param
{
    NSString *reqUrl = [self reqUrlWithpFile:XXGJ_N_PFILE_USER cFile:XXGJ_N_CFILE_USER_GETALL];
    return [self postRequestWithUrl:reqUrl param:param];
}

/**
 获取当前消息免打扰设置
 
 @param param 获取设置参数[1. user_id，2. friend_id，3. type]
 ** 注意 user_id是当前用户id *
 ** 注意 friend_id是好友或群id *
 ** 注意 type：0好友  1群 *
 */
+ (NSDictionary *)getLocalSet:(NSDictionary *)param
{
    NSString *reqUrl = [self reqUrlWithpFile:XXGJ_N_PFILE_RELATION cFile:XXGJ_N_PFILE_RELATION_GETLOCALSET];
    return [self postRequestWithUrl:reqUrl param:param];
}

/**
 判断自己是否在该群组里
 
 @param param 判断参数[1. user_id 2. group_id]
 */
+ (NSDictionary *)checkInGroup:(NSDictionary *)param
{
    NSString *reqUrl = [self reqUrlWithpFile:XXGJ_N_PFILE_GROUP cFile:XXGJ_N_PFILE_GROUP_GETGROUPRELATION];
    return [self postRequestWithUrl:reqUrl param:param];
}


/**
 获取群组中成员信息

 @param param 参数
 @return 返回信息
 */
+ (NSDictionary *)getGroupUserList:(NSDictionary *)param
{
    NSString *reqUrl = [NSString stringWithFormat:@"%@%@%@", XXGJ_N_BASE_GROUP_URL, XXGJ_N_PFILE_FRIEND, XXGJ_N_PFILE_GROUP_LIST];
    return [self postRequestWithUrl:reqUrl param:param];
}

#pragma mark - 
+ (NSDictionary *)postRequestWithUrl:(NSString *)url param:(NSDictionary *)parameters
{
    
    // 创建网络请求管理器
    AFHTTPSessionManager *netManager = [AFHTTPSessionManager manager];
    netManager.requestSerializer.timeoutInterval = 10;
    // 判断返回样式
    netManager.requestSerializer  = [AFJSONRequestSerializer serializer];
    // 网络请求返回样式序列号
    netManager.responseSerializer = [AFJSONResponseSerializer serializer];
    // 网络请求返回数据的格式
    netManager.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"application/json", @"text/json", @"text/javascript", @"text/html",nil];
    
    NSError *error = nil;
    NSDictionary *dict = [netManager syncPOST:url parameters:parameters task:NULL error:&error];
    
    if (error) {
        NSLog(@"error -- %@", error);
        return nil;
    }
    
    return dict;
}


@end
