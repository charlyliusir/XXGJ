//
//  XXGJNetworkingKit.m
//  xxdcchat_ios
//
//  Created by apple on 16/6/27.
//  Copyright © 2016年 刘朝龙. All rights reserved.
//

#import "XXGJNetworkingKit.h"
#import "XXGJCookieTools.h"
#import <AFNetworking.h>

@implementation XXGJNetworkingKit

/**
 *  网络请求
 *
 *  @param URL       网络请求地址
 *  @param parameters 网络请求参数
 *  @param responses 网络请求返回 block
 */
+ (void)RequestWithURL:(NSString *)URL parameters:(id)parameters responseblock:(ResponseBlock)responses
{
    
    [self RequestWithURL:URL parameters:parameters requestmethod:RequestMethodPost contenttype:ContentTypesJson progress:NULL responseblock:responses];
    
}


+ (void)RequestWithURL:(NSString *)URL parameters:(id)parameters progress:(RequestProgress)progress responseblock:(ResponseBlock)responses
{
    
    [self RequestWithURL:URL parameters:parameters requestmethod:RequestMethodPost contenttype:ContentTypesJson progress:progress responseblock:responses];
    
}


/**
 *  网络请求
 *
 *  @param URL       网络请求地址
 *  @param parameters 网络请求参数
 *  @param method    网络请求方式
 *  @param responses 网络请求返回 block
 */
+ (void)RequestWithURL:(NSString *)URL parameters:(id)parameters requestmethod:(RequestMethod)method responseblock:(ResponseBlock)responses
{
    
    [self RequestWithURL:URL parameters:parameters requestmethod:method contenttype:ContentTypesJson progress:NULL responseblock:responses];
    
}


+ (void)RequestWithURL:(NSString *)URL parameters:(id)parameters requestmethod:(RequestMethod)method progress:(RequestProgress)progress responseblock:(ResponseBlock)responses
{
    
    [self RequestWithURL:URL parameters:parameters requestmethod:method contenttype:ContentTypesJson progress:progress responseblock:responses];
    
}


/**
 *  网络请求
 *
 *  @param URL       网络请求地址
 *  @param parameters 网络请求参数
 *  @param content   网络请求返回类型
 *  @param responses 网络请求返回 block
 */
+ (void)RequestWithURL:(NSString *)URL parameters:(id)parameters contenttype:(ContentTypes)content responseblock:(ResponseBlock)responses
{
    
    [self RequestWithURL:URL parameters:parameters requestmethod:RequestMethodPost contenttype:content progress:NULL responseblock:responses];
    
}


+ (void)RequestWithURL:(NSString *)URL parameters:(id)parameters contenttype:(ContentTypes)content progress:(RequestProgress)progress responseblock:(ResponseBlock)responses
{
    
    [self RequestWithURL:URL parameters:parameters requestmethod:RequestMethodPost contenttype:content progress:progress responseblock:responses];
    
}


/**
 *  网络请求
 *
 *  @param URL       网络请求地址
 *  @param parameters 网络请求参数
 *  @param method    网络请求方式
 *  @param content   网络请求返回类型
 *  @param responses 网络请求返回 block
 */
+ (void)RequestWithURL:(NSString *)URL parameters:(id)parameters requestmethod:(RequestMethod)method contenttype:(ContentTypes)content responseblock:(ResponseBlock)responses
{
    
    [self RequestWithURL:URL parameters:parameters requestmethod:method contenttype:content progress:NULL responseblock:responses];
    
}


+ (void)RequestWithURL:(NSString *)URL parameters:(id)parameters requestmethod:(RequestMethod)method contenttype:(ContentTypes)content progress:(RequestProgress)progress responseblock:(ResponseBlock)responses
{
    
    // 创建网络请求管理器
    AFHTTPSessionManager *netManager = [AFHTTPSessionManager manager];
    netManager.requestSerializer.timeoutInterval = 10;
    
    NSString *cookieStr = [[NSUserDefaults standardUserDefaults] objectForKey:@"cookie"];
    if (cookieStr)
    {
        [netManager.requestSerializer setValue:cookieStr forHTTPHeaderField:@"Cookie"];
    }
    
    // 判断返回样式
    if (content == ContentTypesJson) {
        netManager.requestSerializer  = [AFJSONRequestSerializer serializer];
        // 网络请求返回样式序列号
        netManager.responseSerializer = [AFJSONResponseSerializer serializer];
        // 网络请求返回数据的格式
        netManager.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"application/json", @"text/json", @"text/javascript", @"text/html",nil];
        
    } else if (content == ContentTypesText || content == ContentTypesData) {
        netManager.requestSerializer  = [AFHTTPRequestSerializer serializer];
        // 网络请求返回样式序列号
        netManager.responseSerializer = [AFHTTPResponseSerializer serializer];
        // 网络请求返回数据的格式
        netManager.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"application/json", @"text/json", @"text/javascript", @"text/html",nil];
        
    } 
    
    // 判断网络请求方式
    if (method == RequestMethodGet) {
        
        [self HTTPSessionManager:netManager getMethodWithURL:URL parameters:parameters contenttype:content progress:progress responseblock:responses];
        
    } else if (method == RequestMethodPost) {
        
        [self HTTPSessionManager:netManager postMethodWithURL:URL parameters:parameters contenttype:content progress:progress responseblock:responses];
        
    }
    
}


/**
 *  HTTP Get 请求 + Progress
 *
 *  @param sessionManager 网络请求管理器
 *  @param URL            请求地址
 *  @param parameters     请求参数
 *  @param progress       请求进度
 *  @param responses      返回 block
 */
+ (void)HTTPSessionManager:(AFHTTPSessionManager *)sessionManager getMethodWithURL:(NSString *)URL parameters:(id)parameters contenttype:(ContentTypes)content progress:(RequestProgress)progress responseblock:(ResponseBlock)responses
{
    
    [sessionManager GET:URL parameters:parameters progress:progress success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        
        if(content == ContentTypesText){
            
            responseObject = [[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding];
            
            responses(responseObject, YES, NULL);
            
        } else {
            
            responses(responseObject, YES, NULL);
            
        }
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        
        responses(NULL, NO, error);
        
    }];
    
}


/**
 *  HTTP Post 请求  +  Progress
 *
 *  @param sessionManager 网络请求管理器
 *  @param URL            请求地址
 *  @param parameters     请求参数
 *  @param progress       请求进度
 *  @param responses      返回 block
 */
+ (void)HTTPSessionManager:(AFHTTPSessionManager *)sessionManager postMethodWithURL:(NSString *)URL parameters:(id)parameters contenttype:(ContentTypes)content progress:(RequestProgress)progress responseblock:(ResponseBlock)responses
{    
    [sessionManager POST:URL parameters:parameters progress:progress success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        
        if ([URL isEqualToString:@"http://m.7xingyao.com/home/api/mobile/login"])
        {
            NSMutableDictionary *cookiesDict = [[[NSUserDefaults standardUserDefaults] objectForKey:@"user_cookies"] mutableCopy];
            if (!cookiesDict) {
                cookiesDict = [NSMutableDictionary dictionary];
            }
            
            NSDictionary *fields = ((NSHTTPURLResponse*)task.response).allHeaderFields;
            NSString *cookies = fields[@"Set-Cookie"];
            [self userCookie:cookies];
            
        }
        
        responses(responseObject, YES, NULL);
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        
        responses(NULL, NO, error);
        
    }];
    
}


#pragma mark -- 网络上传
/**
 *  上传文件
 *
 *  @param URL        上传地址
 *  @param uploadparameters NSDictionary 字典
 *                    1.MimeType 上传文件类型 2.FileName 文件名 3.FileData 上传数据
 *  @param progress   上传进度
 *  @param responses  成功或失败回调
 */
+ (NSURLSessionUploadTask *)UploadWithURL:(NSString *)URL uploadparameters:(id)uploadparameters progress:(RequestProgress)progress responseblock:(ResponseBlock)responses
{
 
    return [self UploadWithURL:URL method:RequestMethodPost parameters:NULL uploadparameters:uploadparameters progress:progress responseblock:responses];
}

/**
 *  上传文件 + Method
 *
 *  @param URL              上传地址
 *  @param method           上传方法
 *  @param parameters       上传URL参数
 *  @param uploadparameters NSDictionary 字典
 *                          1.MimeType 上传文件类型 2.FileName 文件名 3.FileData 上传数据
 *  @param progress   上传进度
 *  @param responses  成功或失败回调
 */
+ (NSURLSessionUploadTask *)uploadWithURL:(NSString *)URL method:(RequestMethod)method parameters:(id)parameters uploadparameters:(id)uploadparameters progress:(RequestProgress)progress responseblock:(ResponseBlock)responses
{
    //AFN3.0+基于封住HTPPSession的句柄
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    
    AFHTTPResponseSerializer *serializer = [AFHTTPResponseSerializer serializer];
    serializer.acceptableContentTypes = [NSSet setWithObjects:@"text/javascript", @"text/html",nil];
    manager.responseSerializer = serializer;
    
    //formData: 专门用于拼接需要上传的数据,在此位置生成一个要上传的数据体
    [manager POST:URL parameters:nil constructingBodyWithBlock:^(id<AFMultipartFormData>  _Nonnull formData) {
        
        
        // 在网络开发中，上传文件时，是文件不允许被覆盖，文件重名
        // 要解决此问题，
        // 可以在上传时使用当前的系统事件作为文件名
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        // 设置时间格式
        formatter.dateFormat = @"yyyyMMddHHmmss";
        NSString *str = [formatter stringFromDate:[NSDate date]];
        NSString *fileName = [NSString stringWithFormat:@"%@.png", str];
        
        //上传
        /*
         此方法参数
         1. 要上传的[二进制数据]
         2. 对应网站上[upload.php中]处理文件的[字段"file"]
         3. 要保存在服务器上的[文件名]
         4. 上传文件的[mimeType]
         */
        [formData appendPartWithFileData:uploadparameters[UPLOAD_PARAMETERS_FILEDATA] name:@"file" fileName:fileName mimeType:[self getMimeType:(MimeType)[uploadparameters[UPLOAD_PARAMETERS_MIME] integerValue]]];
        
    } progress:^(NSProgress * _Nonnull uploadProgress) {
        
        //上传进度
        // @property int64_t totalUnitCount;     需要下载文件的总大小
        // @property int64_t completedUnitCount; 当前已经下载的大小
        //
        // 给Progress添加监听 KVO
        NSLog(@"%f",1.0 * uploadProgress.completedUnitCount / uploadProgress.totalUnitCount);
        
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSLog(@"上传成功 %@", responseObject);
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        
        NSLog(@"上传失败 %@", error);
    }];
    
    return nil;
}

/**
 *  上传文件 + Method
 *
 *  @param URL              上传地址
 *  @param method           上传方法
 *  @param parameters       上传URL参数
 *  @param uploadparameters NSDictionary 字典
 *                          1.MimeType 上传文件类型 2.FileName 文件名 3.FileData 上传数据
 *  @param progress   上传进度
 *  @param responses  成功或失败回调
 */
+ (NSURLSessionUploadTask *)UploadWithURL:(NSString *)URL method:(RequestMethod)method parameters:(id)parameters uploadparameters:(id)uploadparameters progress:(RequestProgress)progress responseblock:(ResponseBlock)responses
{
    
    NSURLSessionUploadTask *uploadTask;
    
    AFURLSessionManager *manager = [[AFURLSessionManager alloc] initWithSessionConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]];
    AFJSONResponseSerializer *serializer = [AFJSONResponseSerializer serializer];
    serializer.acceptableContentTypes = [NSSet setWithObjects:@"application/json", @"text/json", @"text/javascript", @"text/html",nil];
    manager.responseSerializer = serializer;
    
    NSMutableURLRequest *request = [[AFJSONRequestSerializer serializer] multipartFormRequestWithMethod:@"POST" URLString:URL parameters:parameters constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
        
        [formData appendPartWithFileData:uploadparameters[UPLOAD_PARAMETERS_FILEDATA] name:UPLOAD_PARAMETERS_NAME fileName:uploadparameters[UPLOAD_PARAMETERS_FILENAME] mimeType:[self getMimeType:(MimeType)[uploadparameters[UPLOAD_PARAMETERS_MIME] integerValue]]];
        
    } error:nil];
    
    uploadTask = [manager
                  uploadTaskWithStreamedRequest:request
                  progress:progress
                  completionHandler:^(NSURLResponse * _Nonnull response, id  _Nullable responseObject, NSError * _Nullable error) {
                      
                      BOOL success = (error == NULL);
                      responses(responseObject, success, error);
                      
                  }];
    
    [uploadTask resume];
    
    return uploadTask;
    
}

+ (NSString *)getFilePath:(NSString *)floder fileName:(NSString *)fileName
{
    /** 将图片缓存到本地*/
    NSString *imagefloder = [[NSString cacheStore] appendFileStore:floder];
    /** 创建文件夹*/
    if ([NSString createFilePath:imagefloder])
    {
        return [imagefloder stringByAppendingPathComponent:fileName];
    }
    
    return nil;
}
#pragma mark -- 网络下载
/**
 *  网络文件下载方法
 *
 *  @param URL       下载文件地址
 *  @param path      下载文件保存地址
 *  @param progress  下载进度
 *  @param responses 下载结束返回回调 block
 */
+ (NSURLSessionDownloadTask *)DownloadWithURL:(NSString *)URL cachepath:(NSString *)path progress:(RequestProgress)progress responseblock:(ResponseBlock)responses
{
    
    NSURLSessionDownloadTask *downloadTask;
    
    AFURLSessionManager *manager = [[AFURLSessionManager alloc] initWithSessionConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]];
    AFJSONResponseSerializer *serializer = [AFJSONResponseSerializer serializer];
    serializer.acceptableContentTypes    = [NSSet setWithObjects:ContentTypes_TextHtml, ContentTypes_Json, nil];
    manager.responseSerializer = serializer;
    
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:URL]];
    
    // 缓存地址
    NSString *target = [self getFilePath:@"audio" fileName:path];
    
    downloadTask = [manager downloadTaskWithRequest:request progress:progress destination:^NSURL * _Nonnull(NSURL * _Nonnull targetPath, NSURLResponse * _Nonnull response) {
        
        return [NSURL fileURLWithPath:target];
        
    } completionHandler:^(NSURLResponse * _Nonnull response, NSURL * _Nullable filePath, NSError * _Nullable error) {
        
        BOOL success = error == NULL;
        
        responses(path,success, error);
        
    }];
    
    [downloadTask resume];
    
    return downloadTask;
    
}

#pragma mark -- private tools method

/**
 *  获取请求的方式的字符串
 *
 *  @param method 请求方式
 *
 *  @return 请求方式字符串
 */
+ (NSString *)getRequestMethod:(RequestMethod)method
{
    switch (method) {
        case RequestMethodPost:
            
            return @"Post";
            
            break;
        case RequestMethodGet:
            
            return @"GET";
            break;
            
        default:
            return NULL;
            break;
    }
}


/**
 *  获取上传的mime类型
 *
 *  @param mime mime类型
 *
 *  @return mime类型字符串
 */
+ (NSString *)getMimeType:(MimeType)mime
{
    
    switch (mime) {
            
        case MimeTypeJPG:
            
            return NULL;
            
            break;
        case MimeTypeMOV:
            
            return MIMETYPES_AUDIO_MOV;
            
            break;
        case MimeTypeMP4:
            
            return MIMETYPES_AUDIO_MP4;
            
            break;
        case MimeTypePNG:
            
            return MIMETYPES_IMAGE_PNG;
            
            break;
        default:
            
            return NULL;
            
            break;
    }
    
}

+ (void)userCookie:(NSString *)theCookie
{
    NSMutableArray *cookisArray=[NSMutableArray arrayWithCapacity:20];
    NSMutableDictionary *cookieProperties = [NSMutableDictionary dictionary];
    
    NSArray *theArray = [theCookie componentsSeparatedByString:@"; "];
    for (int i =0 ; i<[theArray count]; i++) {
        NSString *val=theArray[i];
        if ([val rangeOfString:@"="].length>0)
        {
            NSArray *subArray = [val componentsSeparatedByString:@"="];
            for (int i =0 ; i<[subArray count]; i++) {
                NSString *subVal=subArray[i];
                if ([subVal rangeOfString:@", "].length>0)
                {
                    NSArray *subArray2 = [subVal componentsSeparatedByString:@", "];
                    for (int i =0 ; i<[subArray2 count]; i++) {
                        NSString *subVal2=subArray2[i];
                        [cookisArray addObject:subVal2];
                    }
                }
                else
                {
                    [cookisArray addObject:subVal];
                }
            }
        }
        else
        {
            [cookisArray addObject:val];
        }
    }
    for (int idx=0; idx<cookisArray.count; idx+=2) {
        NSString *key=cookisArray[idx];
        NSString *value;
        if ([key isEqualToString:@"Expires"])
        {
            value=[NSString stringWithFormat:@"%@, %@",cookisArray[idx+1],cookisArray[idx+2]];
            idx+=1;
        }
        else
        {
            value=cookisArray[idx+1];
        }
        [cookieProperties setObject:value forKey:key];
    }
    if (cookieProperties[@"JSESSIONID"])
    {
        [[NSUserDefaults standardUserDefaults] setValue:theCookie forKey:@"cookie"];
    }
    
    [cookieProperties setObject:@"name" forKey:NSHTTPCookieName];
    [cookieProperties setObject:@"value" forKey:NSHTTPCookieValue];
    //关键在这里，要设置好domain的值，这样webview发起请求的时候就会带上我们设置好的cookies
    [cookieProperties setObject:@"http://m.7xingyao.com/" forKey:NSHTTPCookieDomain];
    [cookieProperties setObject:@"http://m.7xingyao.com/" forKey:NSHTTPCookieOriginURL];
    [cookieProperties setObject:@"/" forKey:NSHTTPCookiePath];
    [cookieProperties setObject:@"0" forKey:NSHTTPCookieVersion];
    //[cookieProperties setObject:@"gtergr" forKey:@"Device-Model"]; //使用cookie传递参数
    
    [XXGJCookieTools saveCookies:cookieProperties];
    [XXGJCookieTools setCookies];
    
}

@end
