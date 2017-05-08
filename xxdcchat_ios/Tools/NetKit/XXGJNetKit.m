//
//  XXGJNetKit.m
//  xxdcchat_ios
//
//  Created by 刘朝龙 on 2017/3/16.
//  Copyright © 2017年 刘朝龙. All rights reserved.
//

#import "XXGJNetKit.h"
#import "XXGJNetworkingKit.h"

@implementation XXGJNetKit
+ (NSString *)reqUrlWithpFile:(NSString *)pFile cFile:(NSString *)cFile
{
    return [NSString stringWithFormat:@"%@%@%@", XXGJ_N_BASE_URL, pFile, cFile];
}
/**
 业务登录请求
 
 @param param 登录参数 [1.user_name, 2.password]
 @param block 回调方法
 */
+ (void)login:(NSDictionary *)param rBlock:(rBlock)block
{
    // http://m.7xingyao.com/home/api/mobile/login
    // http://m.7xingyao.com/home/api/mobile/login
    NSString *reqUrl = [NSString stringWithFormat:@"%@%@", XXGJ_N_BASE_LOGIN_URL, XXGJ_N_CFILE_USER_LOGIN];
    
    [XXGJNetworkingKit RequestWithURL:reqUrl parameters:param contenttype:ContentTypesJson responseblock:^(id responseObj, BOOL success, NSError *error) {
        block(responseObj, success, error);
    }];
}
/**
 聊天登录请求
 
 @param param 登录参数 [1.user_id, 2.uuid, 3.session_key]
 @param block 回调方法
 */
+ (void)loginChat:(NSDictionary *)param  rBlock:(rBlock)block
{
    NSString *reqUrl = [XXGJNetKit reqUrlWithpFile:XXGJ_N_PFILE_USER cFile:XXGJ_N_CFILE_USER_LOGIN];
    [XXGJNetworkingKit RequestWithURL:reqUrl parameters:param responseblock:^(id responseObj, BOOL success, NSError *error) {
        block(responseObj, success, error);
    }];
}
/**
 退出登录请求
 
 @param param 退出登录参数 [1. session_key]
 @param block 回调方法
 */
+ (void)logout:(NSDictionary *)param rBlock:(rBlock)block
{
    NSString *reqUrl = [XXGJNetKit reqUrlWithpFile:XXGJ_N_PFILE_USER cFile:XXGJ_N_CFILE_USER_LOGOUT];
    [XXGJNetworkingKit RequestWithURL:reqUrl parameters:param responseblock:^(id responseObj, BOOL success, NSError *error) {
        block(responseObj, success, error);
    }];
}

/**
 退出业务登录
 
 @param param 参数
 @param block 回调
 */
+ (void)logoutBussines:(NSDictionary *)param rBlock:(rBlock)block
{
    
}

/**
 修改用户信息
 
 @param param 用户信息参数
 @param block 回调方法
 */
+ (void)updateUserInfo:(NSDictionary *)param rBlock:(rBlock)block
{
    NSString *reqUrl = [NSString stringWithFormat:@"%@%@", XXGJ_N_HOME_BASE_URL, XXGJ_N_HOME_UPDATEWEBUSER];
    
    //POST请求需要修改请求方法为POST，并把参数转换为二进制数据设置为请求体
    //1.创建会话对象
    NSURLSession *session = [NSURLSession sharedSession];
    
    //2.根据会话对象创建task
    NSURL *url = [NSURL URLWithString:reqUrl];
    
    //3.创建可变的请求对象
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc]initWithURL: url cachePolicy: NSURLRequestUseProtocolCachePolicy timeoutInterval: 10];
    [request setHTTPMethod: @"POST"];
    if (param) {
        if (![request valueForHTTPHeaderField:@"Content-Type"]) {
            [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
        }
        [request setHTTPBody:[NSJSONSerialization dataWithJSONObject:param options:NSJSONWritingPrettyPrinted error:nil]];
    }
    NSString *cookieStr = [[NSUserDefaults standardUserDefaults] objectForKey:@"cookie"];
    if (cookieStr)
    {
        [request setValue:cookieStr forHTTPHeaderField:@"Cookie"];
    }
    
    //6.根据会话对象创建一个Task(发送请求）
    /*
     第一个参数：请求对象
     第二个参数：completionHandler回调（请求完成【成功|失败】的回调）
     data：响应体信息（期望的数据）
     response：响应头信息，主要是对服务器端的描述
     error：错误信息，如果请求失败，则error有值
     */
    NSURLSessionDataTask *dataTask = [session dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        
        //8.解析数据
        NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:nil];
        block(dict, !error, error);
        
    }];
    
    //7.执行任务
    [dataTask resume];
}
/**
 上传用户的token信息
 
 @param param 上传token参数[1. userId 2. tocken]
 @param block 回调方法
 */
+ (void)uploadToken:(NSDictionary *)param rBlock:(rBlock)block
{
    NSString *reqUrl = [XXGJNetKit reqUrlWithpFile:XXGJ_N_PFILE_USER cFile:XXGJ_N_CFILE_USER_UPLOAD_TOKEN];
    [XXGJNetworkingKit RequestWithURL:reqUrl parameters:param responseblock:^(id responseObj, BOOL success, NSError *error) {
        block(responseObj, success, error);
    }];
}
/**
 根据用户名查询全体用户列表
 
 @param param 查询参数 [1. nick_name(模糊查找)/user_id(精准查找) 2. current_page 3. page_size]
 @param block 回调方法
 */
+ (void)searchUserList:(NSDictionary *)param rBlock:(rBlock)block
{
    NSString *reqUrl = [XXGJNetKit reqUrlWithpFile:XXGJ_N_PFILE_USER cFile:XXGJ_N_CFILE_USER_GETALL];
    [XXGJNetworkingKit RequestWithURL:reqUrl parameters:param responseblock:^(id responseObj, BOOL success, NSError *error) {
        block(responseObj, success, error);
    }];
}
/**
 设置消息免打扰
 
 @param param 免打扰参数[1. user_id  2. friend_id  3. type  4. status]
 ** 注意: user_id是当前用户id *
 ** 注意: friend_id是好友或群id *
 ** 注意: type：0好友  1群 *
 ** 注意: status：1开启消息免打扰 *
 ** 注意: 0：关闭消息免打扰 *
 @param block 回调方法
 */
+ (void)setAvoidRemind:(NSDictionary *)param rBlock:(rBlock)block
{
    NSString *reqUrl = [XXGJNetKit reqUrlWithpFile:XXGJ_N_PFILE_USER cFile:XXGJ_N_CFILE_USER_REMIND];
    [XXGJNetworkingKit RequestWithURL:reqUrl parameters:param responseblock:^(id responseObj, BOOL success, NSError *error) {
        block(responseObj, success, error);
    }];
}
/**
 获取用户跟自己的关系
 
 @param param 获取关系参数 [1. user_id, 2. from_user_id]
 @param block 回调方法
 */
+ (void)getPersonRelation:(NSDictionary *)param rBlock:(rBlock)block
{
    NSString *reqUrl = [XXGJNetKit reqUrlWithpFile:XXGJ_N_PFILE_USER cFile:XXGJ_N_CFILE_USER_RELATION];
    [XXGJNetworkingKit RequestWithURL:reqUrl parameters:param responseblock:^(id responseObj, BOOL success, NSError *error) {
        block(responseObj, success, error);
    }];

}
/**
 获取好友列表
 
 @param param 获取好友列表参数 [1. user_id 2. relation_type 3. currentPage 4. pageSize 5. nick_name]
 ** 注意：relation_type 0-个人好友 1-群好友 *
 ** 注意：nick_name 为选填参数 *
 @param block 回调方法
 */
+ (void)getFriendList:(NSDictionary *)param rBlock:(rBlock)block
{
    NSString *reqUrl = [XXGJNetKit reqUrlWithpFile:XXGJ_N_PFILE_FRIEND cFile:XXGJ_N_CFILE_FRIEND_LIST];
    [XXGJNetworkingKit RequestWithURL:reqUrl parameters:param responseblock:^(id responseObj, BOOL success, NSError *error) {
        block(responseObj, success, error);
    }];
}
/**
 获取好友信息
 
 @param param 好友信息参数 [1. user_id]
 @param block 回调方法
 */
+ (void)getFriend:(NSDictionary *)param rBlock:(rBlock)block
{
    NSString *reqUrl = [XXGJNetKit reqUrlWithpFile:XXGJ_N_PFILE_FRIEND cFile:XXGJ_N_CFILE_FRIEND_GET];
    [XXGJNetworkingKit RequestWithURL:reqUrl parameters:param responseblock:^(id responseObj, BOOL success, NSError *error) {
        block(responseObj, success, error);
    }];
}
/**
 添加好友
 
 @param param 添加好友参数 [1. user_id 2. target_id]
 @param block 回调方法
 */
+ (void)addFriend:(NSDictionary *)param rBlock:(rBlock)block
{
    NSString *reqUrl = [XXGJNetKit reqUrlWithpFile:XXGJ_N_PFILE_FRIEND cFile:XXGJ_N_CFILE_FRIEND_ADD];
    [XXGJNetworkingKit RequestWithURL:reqUrl parameters:param responseblock:^(id responseObj, BOOL success, NSError *error) {
        block(responseObj, success, error);
    }];
}
/**
 是否同意添加好友
 
 @param param 选择参数[1.relation_id 2. relation_status]
 @param block 回调方法
 */
+ (void)confirmFriend:(NSDictionary *)param rBlock:(rBlock)block
{
    NSString *reqUrl = [XXGJNetKit reqUrlWithpFile:XXGJ_N_PFILE_FRIEND cFile:XXGJ_N_CFILE_FRIEND_CONFIRM];
    [XXGJNetworkingKit RequestWithURL:reqUrl parameters:param responseblock:^(id responseObj, BOOL success, NSError *error) {
        block(responseObj, success, error);
    }];
}
/**
 删除好友
 
 @param param 删除参数 [1.user_id 2.target_id]
 @param block 回调方法
 */
+ (void)deleteFriend:(NSDictionary *)param rBlock:(rBlock)block
{
    NSString *reqUrl = [XXGJNetKit reqUrlWithpFile:XXGJ_N_PFILE_FRIEND cFile:XXGJ_N_CFILE_FRIEND_DELETE];
    [XXGJNetworkingKit RequestWithURL:reqUrl parameters:param responseblock:^(id responseObj, BOOL success, NSError *error) {
        block(responseObj, success, error);
    }];
}

/**
 创建一个群聊
 
 @param param 创建参数[1.create_id 2.group_name 3. group_desc 4. users]
 ** 注意：create_id 为必填参数 *
 ** 注意：users、group_desc 为选填参数 *
 ** 注意：users 是一个用户数组格式为 users:[{user_id:1},{user_id:2}] *
 @param block 回调方法
 */
+ (void)createGroup:(NSDictionary *)param rBlock:(rBlock)block
{
    NSString *reqUrl = [XXGJNetKit reqUrlWithpFile:XXGJ_N_PFILE_GROUP cFile:XXGJ_N_PFILE_GROUP_CREATE];
    [XXGJNetworkingKit RequestWithURL:reqUrl parameters:param responseblock:^(id responseObj, BOOL success, NSError *error) {
        block(responseObj, success, error);
    }];
}

/**
 添加群友
 
 @param param 添加参数[1.user_id 2. friend_id 3. group_id 4. is_system]
 ** 注意：friend_id 是被邀请好友id，逗号分隔 "friend_id":"123,234" *
 @param block 回调方法
 */
+ (void)addGroupMember:(NSDictionary *)param rBlock:(rBlock)block
{
    NSString *reqUrl = [XXGJNetKit reqUrlWithpFile:XXGJ_N_PFILE_GROUP cFile:XXGJ_N_PFILE_GROUP_ADDMB];
    [XXGJNetworkingKit RequestWithURL:reqUrl parameters:param responseblock:^(id responseObj, BOOL success, NSError *error) {
        block(responseObj, success, error);
    }];
}

/**
 群主踢人
 
 @param param 踢人参数[1. user_id 2. group_id 3. friend_id]
 ** 注意：friend_id 是被踢人的id，逗号分隔 "friend_id":"123,234" *
 @param block 回调方法
 */
+ (void)removeGroupMember:(NSDictionary *)param rBlock:(rBlock)block
{
    NSString *reqUrl = [XXGJNetKit reqUrlWithpFile:XXGJ_N_PFILE_GROUP cFile:XXGJ_N_PFILE_GROUP_REMOVEMB];
    [XXGJNetworkingKit RequestWithURL:reqUrl parameters:param responseblock:^(id responseObj, BOOL success, NSError *error) {
        block(responseObj, success, error);
    }];
}

/**
 退群
 
 @param param 退群参数 [1. user_id 2. group_id]
 @param block 回调方法
 */
+ (void)leaveGroup:(NSDictionary *)param rBlock:(rBlock)block
{
    NSString *reqUrl = [XXGJNetKit reqUrlWithpFile:XXGJ_N_PFILE_GROUP cFile:XXGJ_N_PFILE_GROUP_LEAVE];
    [XXGJNetworkingKit RequestWithURL:reqUrl parameters:param responseblock:^(id responseObj, BOOL success, NSError *error) {
        block(responseObj, success, error);
    }];
}

/**
 编辑群信息
 
 @param param 编辑参数[1. group_id 2. group_name 3. group_desc]
 @param block 回调方法
 */
+ (void)editGroup:(NSDictionary *)param rBlock:(rBlock)block
{
    NSString *reqUrl = [XXGJNetKit reqUrlWithpFile:XXGJ_N_PFILE_GROUP cFile:XXGJ_N_PFILE_GROUP_EDIT];
    [XXGJNetworkingKit RequestWithURL:reqUrl parameters:param responseblock:^(id responseObj, BOOL success, NSError *error) {
        block(responseObj, success, error);
    }];
}

/**
 获取我的群组信息
 
 @param param 获取参数[1. user_id 2. currentPage 3. pageSize 4. group_name]
 ** 注意：此处 group_name 需要进一步了解功能 *
 @param block 回调方法
 */
+ (void)getMyGroups:(NSDictionary *)param rBlock:(rBlock)block
{
    NSString *reqUrl = [XXGJNetKit reqUrlWithpFile:XXGJ_N_PFILE_GROUP cFile:XXGJ_N_PFILE_GROUP_MYLIST];
    [XXGJNetworkingKit RequestWithURL:reqUrl parameters:param responseblock:^(id responseObj, BOOL success, NSError *error) {
        block(responseObj, success, error);
    }];
}

/**
 判断自己是否在该群组里
 
 @param param 判断参数[1. user_id 2. group_id]
 @param block 回调方法
 */
+ (void)checkInGroup:(NSDictionary *)param rBlock:(rBlock)block
{
    NSString *reqUrl = [XXGJNetKit reqUrlWithpFile:XXGJ_N_PFILE_GROUP cFile:XXGJ_N_PFILE_GROUP_GETGROUPRELATION];
    [XXGJNetworkingKit RequestWithURL:reqUrl parameters:param responseblock:^(id responseObj, BOOL success, NSError *error) {
        block(responseObj, success, error);
    }];
}

/**
 查找一个群组
 
 @param param 查找参数[1. group_id]
 @param block 回调方法
 */
+ (void)searchGroup:(NSDictionary *)param rBlock:(rBlock)block
{
    NSString *reqUrl = [XXGJNetKit reqUrlWithpFile:XXGJ_N_PFILE_GROUP cFile:XXGJ_N_PFILE_GROUP_GET];
    [XXGJNetworkingKit RequestWithURL:reqUrl parameters:param responseblock:^(id responseObj, BOOL success, NSError *error) {
        block(responseObj, success, error);
    }];
}

/**
 查找群组列表
 
 @param param 查找参数[1.group_name 2. currentPage 3. pageSize]
 @param block 回调方法
 */
+ (void)searchGroupList:(NSDictionary *)param rBlock:(rBlock)block
{
    NSString *reqUrl = [XXGJNetKit reqUrlWithpFile:XXGJ_N_PFILE_GROUP cFile:XXGJ_N_PFILE_GROUP_LIST];
    [XXGJNetworkingKit RequestWithURL:reqUrl parameters:param responseblock:^(id responseObj, BOOL success, NSError *error) {
        block(responseObj, success, error);
    }];
}

/**
 获取当前消息免打扰设置
 
 @param param 获取设置参数[1. user_id，2. friend_id，3. type]
 ** 注意 user_id是当前用户id *
 ** 注意 friend_id是好友或群id *
 ** 注意 type：0好友  1群 *
 @param block 回调方法
 */
+ (void)getLocalSet:(NSDictionary *)param rBlock:(rBlock)block
{
    NSString *reqUrl = [XXGJNetKit reqUrlWithpFile:XXGJ_N_PFILE_RELATION cFile:XXGJ_N_PFILE_RELATION_GETLOCALSET];
    [XXGJNetworkingKit RequestWithURL:reqUrl parameters:param responseblock:^(id responseObj, BOOL success, NSError *error) {
        block(responseObj, success, error);
    }];
}

/**
 发红包
 
 @param param 发红包参数[1. sessionKey: 2. userId 3. isGroup: 4. num: 5. targetId 6. isRandom 7. amount]
 @param block 回调方法
 */
+ (void)sendRedEnvelope:(NSDictionary *)param rBlock:(rBlock)block
{
    NSString *reqUrl = [XXGJNetKit reqUrlWithpFile:XXGJ_N_PFILE_REDENVELOPE cFile:XXGJ_N_PFILE_REDENVELOPE_SAVE];
    [XXGJNetworkingKit RequestWithURL:reqUrl parameters:param responseblock:^(id responseObj, BOOL success, NSError *error) {
        block(responseObj, success, error);
    }];
}



/**
 抢红包接口
 
 @param param 抢红包参数[1. sessionKey 2. userId 3. redEnvelopeId]
 @param block 回调方法
 */
+ (void)grabRedEnvelope:(NSDictionary *)param rBlock:(rBlock)block
{
    NSString *reqUrl = [XXGJNetKit reqUrlWithpFile:XXGJ_N_PFILE_REDENVELOPE cFile:XXGJ_N_PFILE_REDENVELOPE_GRAB];
    [XXGJNetworkingKit RequestWithURL:reqUrl parameters:param responseblock:^(id responseObj, BOOL success, NSError *error) {
        block(responseObj, success, error);
    }];
}
/**
 红包详情接口
 
 @param param 抢红包参数[1. sessionKey 2. userId 3. redEnvelopeId]
 @param block 回调方法
 */
+ (void)grabRedEnvelopeStatus:(NSDictionary *)param rBlock:(rBlock)block
{
    NSString *reqUrl = [XXGJNetKit reqUrlWithpFile:XXGJ_N_PFILE_REDENVELOPE cFile:XXGJ_N_PFILE_REDENVELOPE_GRAB_Status];
    [XXGJNetworkingKit RequestWithURL:reqUrl parameters:param responseblock:^(id responseObj, BOOL success, NSError *error) {
        block(responseObj, success, error);
    }];
}

/**
 上传头像接口
 
 @param param 图片数据
 @param block 回调方法
 */
+ (void)uploadAvatarImageWithData:(NSDictionary *)param  rBlock:(rBlock)block
{
    NSString *reqUrl = XXGJ_N_AVATAR_UPLOAD_URL;
    
    //POST请求需要修改请求方法为POST，并把参数转换为二进制数据设置为请求体
    //1.创建会话对象
    NSURLSession *session = [NSURLSession sharedSession];
    
    //2.根据会话对象创建task
    NSURL *url = [NSURL URLWithString:reqUrl];
    
    //3.创建可变的请求对象
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc]initWithURL: url cachePolicy: NSURLRequestUseProtocolCachePolicy timeoutInterval: 10];
    [request setHTTPMethod: @"POST"];
    if (param) {
        if (![request valueForHTTPHeaderField:@"Content-Type"]) {
            [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
        }
        [request setHTTPBody:[NSJSONSerialization dataWithJSONObject:param options:NSJSONWritingPrettyPrinted error:nil]];
    }
    NSString *cookieStr = [[NSUserDefaults standardUserDefaults] objectForKey:@"cookie"];
    if (cookieStr)
    {
        [request setValue:cookieStr forHTTPHeaderField:@"Cookie"];
    }
    
    //6.根据会话对象创建一个Task(发送请求）
    /*
     第一个参数：请求对象
     第二个参数：completionHandler回调（请求完成【成功|失败】的回调）
     data：响应体信息（期望的数据）
     response：响应头信息，主要是对服务器端的描述
     error：错误信息，如果请求失败，则error有值
     */
    NSURLSessionDataTask *dataTask = [session dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        
        //8.解析数据
        NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:nil];
        block(dict, !error, error);
        
    }];
    
    //7.执行任务
    [dataTask resume];
}

/**
 上传图片接口
 
 @param imageData 图片数据
 @param block 回调方法
 */
+ (void)uploadImageWithData:(NSData *)imageData rProgress:(rProgress)progress  rBlock:(rBlock)block
{
    NSString *fileName = [[NSDate dateForDateFormatter:@"yyyy-MM-ddHH:mm:ss"].md5 stringByAppendingString:@".jpg"];
    NSDictionary *dict = @{UPLOAD_PARAMETERS_FILEDATA:imageData, UPLOAD_PARAMETERS_MIME:MIMETYPES_MULTIPART_DATA,UPLOAD_PARAMETERS_FILENAME:fileName};
    [XXGJNetworkingKit UploadWithURL:XXGJ_N_UPLOAD_URL uploadparameters:dict progress:progress responseblock:^(id responseObj, BOOL success, NSError *error) {
        block(responseObj, success, error);
    }];
}

/**
 异步下载语音数据
 
 @param audioUrl 语音地址
 @param fileName 本地保持地址
 @param block block 回调
 */
+ (void)downloadAudio:(NSString *)audioUrl withFileName:(NSString *)fileName rBlock:(rBlock)block
{
    [XXGJNetworkingKit DownloadWithURL:audioUrl cachepath:fileName progress:nil responseblock:^(id responseObj, BOOL success, NSError *error) {
        block(responseObj, success, error);
    }];
}

/**
 请求支付账单信息
 
 @param payMainId 支付账单编号
 @param block 回调
 */
+ (void)getPayInfoWithPayMainId:(NSString *)payMainId rBlock:(rBlock)block
{
    NSString *reqUrl = [XXGJ_N_WECHATPAY_URL stringByAppendingString:payMainId];
    [XXGJNetworkingKit RequestWithURL:reqUrl parameters:nil requestmethod:RequestMethodGet contenttype:ContentTypesJson responseblock:^(id responseObj, BOOL success, NSError *error) {
        block(responseObj, success, error);
    }];
}

@end
