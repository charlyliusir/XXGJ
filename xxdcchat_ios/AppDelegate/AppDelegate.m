//
//  AppDelegate.m
//  xxdcchat_ios
//
//  Created by 刘朝龙 on 2017/3/15.
//  Copyright © 2017年 刘朝龙. All rights reserved.
//

#import "AppDelegate.h"
#import <UserNotifications/UserNotifications.h>
#import <UMMobClick/MobClick.h>
#import "XXGJLoginViewController.h"
#import "XXGJCookieTools.h"
#import "XXGJSocket.h"
#import "WXApi.h"
#import "Message.h"
#import "Args.h"

#define XXGJ_BAIDU_MAP_KEY @"5M0FivA0SQC9C4ZN1KWlX9VmQPmrGSh3"
#define XXGJ_WEIXIN_PALY_KEY @"wx6e28c684c2043e52"
#define XXGJ_UMENG_KEY @"590c40f5717c190564001614"

@interface AppDelegate () <UNUserNotificationCenterDelegate , WXApiDelegate>
@property (nonatomic, copy)NSString *tokenId;
@end

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    // set navigation bar style
    //  友盟的方法本身是异步执行，所以不需要再异步调用
    [self umengTrack];
    // 设置 百度地图 相关参数
    [self setBMKMapOption];
    // 设置 微信 相关参数
    [self setWeiXinOption];
    // 注册远程通知
    [self registerRemoteNotificationsForAlliOSSystemVersion];
    
    // 创建聊天管理器
    self.socketManage = [XXGJSocketManager sharedXXGJSocketManager];
    // 创建数据库管理器
    self.dbModelManage = [XXGJDBModelManager dbModelManager];
    [self.dbModelManage setContext:self.managedObjectContext];
    // 将图片消息同意处理一遍
    [self updateImageMessage];
    
    // 设置统一样式
    [[UINavigationBar appearance] setBarTintColor:XX_NAVIGATIONBAR_BARTINTCOLOR];
    [[UINavigationBar appearance] setTintColor:XX_NAVIGATIONBAR_TINTCOLOR];
    // set tabbar style
    [[UITabBar appearance] setBarTintColor:XX_TABBAR_TINTCOLOR];
    [[UITabBar appearance] setUnselectedItemTintColor:XX_TABBAR_UNSELECTED_TINTCOLOR];
    [[UITabBar appearance] setTintColor:XX_TABBAR_SELECTED_TINTCOLOR];
    [[UIBarButtonItem appearanceWhenContainedIn: [UISearchBar class], nil] setTitle:@"取消"];
    
    /** 0.35秒后再执行surveyNetworkConcatenate:方法. */
    [self performSelector:@selector(surveyNetworkConcatenate:) withObject:nil afterDelay:0.35f];
    [self performSelectorInBackground:@selector(listenSocketStatus:) withObject:nil];
    
    // 判断是否保存用户信息，如果没有用户信息，则跳转登录页面，否则执行登录操作
    NSDictionary *userinfo = [[NSUserDefaults standardUserDefaults] objectForKey:XX_USERDEFAULT_USER];
    
    /** 用户不存在，跳转登录界面 */
    if (!userinfo[XXGJ_N_PARAM_USERID])
    {
        [self exchangeRootViewControllerWithStoryBoard:XXGJ_STORY_NAME_LOGIN];
    }
    /** 用户已存在，调用登录方法 */
    else
    {
        // 此处保持用户信息, 通过Coredata查询
        self.user = [self.dbModelManage excuteTable:TABLE_USER predicate:[NSString stringWithFormat:@"user_id==%@", userinfo[XXGJ_N_PARAM_USERID]] limit:1].lastObject;
        [self.socketManage setIsAutoLogin:NO];
        
        [XXGJNetKit login:@{XXGJ_N_PARAM_USERNAME:userinfo[XXGJ_N_PARAM_USERNAME], XXGJ_N_PARAM_PASSWORD:userinfo[XXGJ_N_PARAM_PASSWORD]} rBlock:^(id obj, BOOL success, NSError *error) {
            /** 如果登录成功*/
            if (success)
            {
                NSDictionary *dict = (NSDictionary *)obj;
                NSDictionary *status = dict[@"status"];
                if (status && [status[@"msg"] isEqualToString:@"登录成功"])
                {
                    /** 更新用户最新数据*/
                    NSDictionary *data = dict[@"data"];
                    NSDictionary *webUser = data[@"webUser"];
                    self.user.nick_name = webUser[@"trueName"];
                    self.user.avatar    = webUser[@"img"];
                    self.user.sex       = [webUser[@"sex"] isEqualToString:@"Sex-male"] ? @"男" : @"女";
                    self.user.location  = webUser[@"area"];
                    self.user.mobile    = webUser[@"mobile"];
                    self.user.company   = webUser[@"company"];
                    self.user.birthday  = webUser[@"born"];
                    
                    [self saveContext];
                    // 重新更新 cookies
                    [XXGJCookieTools setCookies];
                }
            }
            
        }];
    }
    
    return YES;
}

- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken
{
    //获取终端设备标识，这个标识需要通过接口发送到服务器端，服务器端推送消息到APNS时需要知道终端的标识，APNS通过注册的终端标识找到终端设备。
    NSString *token = [deviceToken description]; //获取
    token =  [token stringByReplacingOccurrencesOfString:@" " withString:@""];
    token =  [token stringByReplacingOccurrencesOfString:@"<" withString:@""];
    self.tokenId =  [token stringByReplacingOccurrencesOfString:@">" withString:@""];
    NSLog(@"request notificatoin token success. %@",self.tokenId);
    // 添加判断-只有用户存在才可以上传
    if (self.user)
    {
        [self uploadUserToken:self.tokenId];
    }
}

- (void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error
{
    NSLog(@"request notification Token fail. %@",error.localizedDescription);
}

#pragma mark iOS 10 之前 获取通知的信息
- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo fetchCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler
{
    //静默推送 显示蓝色Label
//    [self showLabelWithUserInfo:userInfo color:[UIColor blueColor]];
    completionHandler(UIBackgroundFetchResultNewData);
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo
{
    NSLog(@"iOS 10 before Notification message。\n  %@",userInfo);
}

#pragma mark  iOS 10 获取推送信息 UNUserNotificationCenter---Delegate

//APP在前台的时候收到推送的回调
- (void)userNotificationCenter:(UNUserNotificationCenter *)center willPresentNotification:(UNNotification *)notification withCompletionHandler:(void (^)(UNNotificationPresentationOptions))completionHandler
{
    UNNotificationContent *content =  notification.request.content;
    NSDictionary *userInfo = content.userInfo;
    [self handleRemoteNotificationContent:userInfo];
    //前台运行推送 显示红色Label
//    [self showLabelWithUserInfo:userInfo color:[UIColor redColor]];
    //可以设置当收到通知后, 有哪些效果呈现(提醒/声音/数字角标)
    //可以执行设置 弹窗提醒 和 声音
    completionHandler(UNNotificationPresentationOptionAlert | UNNotificationPresentationOptionSound|UNNotificationPresentationOptionBadge);
}

//APP在后台，点击推送信息，进入APP后执行的回调
- (void)userNotificationCenter:(UNUserNotificationCenter *)center didReceiveNotificationResponse:(UNNotificationResponse *)response withCompletionHandler:(void (^)())completionHandler

{
    UNNotificationContent *content  = response.notification.request.content;
    NSDictionary *userInfo = content.userInfo;
    [self handleRemoteNotificationContent:userInfo];
    //后台及退出推送 显示绿色Label
//    [self showLabelWithUserInfo:userInfo color:[UIColor greenColor]];
    completionHandler();
}

- (void)handleRemoteNotificationContent:(NSDictionary *)userInfo

{
    NSLog(@" iOS 10 after Notificatoin message:\n %@",userInfo);
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    
    // 判断是否由远程消息通知触发应用程序启动
    [UIApplication sharedApplication].applicationIconBadgeNumber = 0;
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
//    [self.socketManage disconnect];
    self.socketManage.userIsLogin = NO;
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    // 开始连接服务器
//    if ((!self.socketManage || !self.socketManage.socketConnected)&&(self.reachabiltyStatus==AFNetworkReachabilityStatusReachableViaWWAN
//                                                                     ||self.reachabiltyStatus==AFNetworkReachabilityStatusReachableViaWiFi))
//    {
//        NSLog(@"####Text autoconnect socket### do re connect!");
//        dispatch_async(dispatch_get_main_queue(), ^{
//            self.socketManage = [XXGJSocketManager sharedXXGJSocketManager];
//            [self.socketManage setDelegate:self];
//            [self.socketManage connect];
//        });
//    }else
//    {
//        NSLog(@"####Text autoconnect socket### error no network!");
//    }
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    
    [[NSHTTPCookieStorage sharedHTTPCookieStorage] setCookieAcceptPolicy:NSHTTPCookieAcceptPolicyAlways];
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    // Saves changes in the application's managed object context before the application terminates.
    [self saveContext];
}

- (BOOL)application:(UIApplication *)application handleOpenURL:(NSURL *)url
{
    if ([url.scheme isEqualToString:XXGJ_WEIXIN_PALY_KEY]) {
        return [WXApi handleOpenURL:url delegate:self];
    }else
    {
        return YES;
    }
}

- (BOOL)application:(UIApplication *)app openURL:(NSURL *)url options:(NSDictionary<UIApplicationOpenURLOptionsKey,id> *)options
{
    if ([url.scheme isEqualToString:XXGJ_WEIXIN_PALY_KEY]) {
        return [WXApi handleOpenURL:url delegate:self];
    }else
    {
        return YES;
    }
}

- (NSMutableDictionary *)drawnMessageUuidDict
{
    if (!_drawnMessageUuidDict)
    {
        _drawnMessageUuidDict = [NSMutableDictionary dictionary];
    }
    return _drawnMessageUuidDict;
}


#pragma mark - open method

/**
 是否允许发送消息
 
 @return 是否允许结果
 */
- (BOOL)canSendMessage
{
    if (self.socketManage.userIsLogin && self.socketManage.session_key)
    /** 判断 socket 是否接到第一个心跳包, 并且聊天服务器已经登录*/
    {
        if (self.reachabiltyStatus != AFNetworkReachabilityStatusUnknown && self.reachabiltyStatus != AFNetworkReachabilityStatusNotReachable)
        /** 判断当前的网络状态, 如果有网络可以发消息, 如果没有网络不能发消息*/
        {
            return YES;
        }else
        {
            return NO;
        }
    } else
    {
        return NO;
    }
}
/**
 切换主控制器
 
 @param storyBoardName storyBoard 文件的名称
 */
- (void)exchangeRootViewControllerWithStoryBoard:(NSString *)storyBoardName
{
    if (self.user && self.tokenId)
    {
        [self uploadUserToken:self.tokenId];
    }
    UIStoryboard *storyBoard = [UIStoryboard storyboardWithName:storyBoardName bundle:[NSBundle mainBundle]];
    self.window.rootViewController = [storyBoard instantiateViewControllerWithIdentifier:storyBoardName];
}
/** 获取跟视图的导航控制器*/
- (UINavigationController *)rootViewControllerNavi
{
    if ([self.window.rootViewController isKindOfClass:[XXGJTabBarController class]])
    {
        XXGJTabBarController *tabBarController = (XXGJTabBarController *)self.window.rootViewController;
        return tabBarController.selectedViewController;
    }
    return nil;
}
/** 获取跟视图的控制器*/
- (XXGJTabBarController *)rootViewController
{
    return (XXGJTabBarController *)self.window.rootViewController;
}

#pragma mark - private method
- (void)uploadUserToken:(NSString *)token
{
    NSDictionary *dict = @{@"userId":self.user.user_id, @"tocken":token};
    [XXGJNetKit uploadToken:dict rBlock:^(id obj, BOOL success, NSError *error) {
        NSLog(@"token upload : %@", obj);
        NSLog(@"token upload error : %@", error);
    }];
}
/**
 注册远程推送和本地通知，适配至最新系统，目前是 iOS10
 */
-(void)registerRemoteNotificationsForAlliOSSystemVersion
{
    //导入文件 #import <UserNotifications/UserNotifications.h>
    //去capabilities(功能)设置这边打开 pushNotifications，并且打开  backgroundModes 中的backgroundFentch，Remote Notifications
    CGFloat version = [[[UIDevice currentDevice] systemVersion] floatValue];
    if (version >= 10.0)
    {
        //10.0及其以上
        UNUserNotificationCenter *center = [UNUserNotificationCenter currentNotificationCenter];
        // 请求通知权限, 本地和远程共用
        // 设定通知可选提示类型
        [center requestAuthorizationWithOptions:UNAuthorizationOptionCarPlay | UNAuthorizationOptionSound | UNAuthorizationOptionBadge | UNAuthorizationOptionAlert completionHandler:^(BOOL granted, NSError * _Nullable error) {
            if (error)
            {
                NSLog(@"iOS10请求 接受远程和本地通知 授权失败:<%@>",[error description]);
            }
            if (granted)
            {
                NSLog(@" iOS 10 request notification success");
                NSLog(@"请求成功");
            }else
            {
                NSLog(@" iOS 10 request notification fail");
                NSLog(@"请求失败");
            }
        }];
        //设置通知的代理
        center.delegate = self;//1.遵守UNUserNotificationCenterDelegate协议，2.成为代理；3.实现代理回调方法
    }else if (version>=8.0)
    {
        //8.0--->10.0
        //请求用户授权授权收到推送时有哪些提醒方式可以选
        // 声音、角标、弹窗
        UIUserNotificationSettings *setting = [UIUserNotificationSettings settingsForTypes:UIUserNotificationTypeSound | UIUserNotificationTypeBadge | UIUserNotificationTypeAlert categories:nil];
        [[UIApplication sharedApplication] registerUserNotificationSettings:setting];
    }else
    {
        //8.0以下
        UIRemoteNotificationType type =  UIRemoteNotificationTypeSound| UIRemoteNotificationTypeAlert | UIRemoteNotificationTypeBadge;
        [[UIApplication sharedApplication] registerForRemoteNotificationTypes:type];
    }
    //注册通知
    [[UIApplication sharedApplication] registerForRemoteNotifications];
}

// 模拟接收通知操作
- (void)showLabelWithUserInfo:(NSDictionary *)userInfo color:(UIColor *)color

{
    
    UILabel *label = [UILabel new];
    
    label.backgroundColor = color;
    
    label.frame = CGRectMake(0, 250, [UIScreen mainScreen].bounds.size.width, 300);
    
    label.text = userInfo.description;
    
    label.numberOfLines = 0;
    
    [[UIApplication sharedApplication].keyWindow addSubview:label];
    
}

/**
 友盟统计配置
 */
- (void)umengTrack
{
    //    [MobClick setAppVersion:XcodeAppVersion]; //参数为NSString * 类型,自定义app版本信息，如果不设置，默认从CFBundleVersion里取
    [MobClick setLogEnabled:YES];
    UMConfigInstance.appKey = XXGJ_UMENG_KEY;
    UMConfigInstance.secret = @"secretstringaldfkals";
    [MobClick startWithConfigure:UMConfigInstance];
}

/**
 百度地图配置信息
 */
- (void)setBMKMapOption
{
    self.mapManager = [[BMKMapManager alloc] init];
    [self.mapManager start:XXGJ_BAIDU_MAP_KEY generalDelegate:nil];
}

/**
 微信配置信息
 */
-(void)setWeiXinOption
{
    // 注册微信 APPID
    [WXApi registerApp:XXGJ_WEIXIN_PALY_KEY];
}

/**
 监听聊天控制器状态
 
 @param sender 参数
 */
- (void)listenSocketStatus:(id)sender
{
    // 首先必须是登录状态才可以这样添加判断
    // 1, 创建一个计时器, 每次经过15s观察一次聊天控制器是否存在
    //    如果存在, 说明了解正常
    //    如果不存在, 表示已经与聊天服务器断开链接
    // 2, 同时, 监听消息重发管理器,先判断是否链接, 如果链接在判断消息管理器
    //    如果消息重发管理器中有需要重发的消息, 则将第一条消息发送出去
    //    如果不存在需要重发的消息, 则不需要进行操作.
    
//    NSTimer *listenTimer = [NSTimer timerWithTimeInterval:10 repeats:YES block:^(NSTimer * _Nonnull timer) {
//        if (self.user)
//        {
//            NSLog(@"####Text autoconnect socket### has user!");
//            if (self.socketManage)
//            {
////                // 1, 首先检查是否有需要重发的消息
////                // 2, 如果有, 发送第一条消息
////                NSLog(@"####Text autoconnect socket### has socket manage!");
////                XXGJReSendMessageManager *reSendMessageManager = [XXGJReSendMessageManager sharedReSendMessageManger];
////                if ([reSendMessageManager checkUpdateTime])
////                {
////                    dispatch_async(dispatch_get_main_queue(), ^{
////                        [self.socketManage sendChatMessage:[reSendMessageManager getFirstReSendMessageObject]];
////                    });
////                    NSLog(@"####Text autoconnect socket### has resendMessage!");
////                    [MBProgressHUD showLoadHUDText:@"socket--发送消息" during:2.0f];
////                    
////                }else
////                {
////                    NSLog(@"####Text autoconnect socket### error no resendMessage!");
////                }
//            }else
//            {
//                // 1, 判断当前网络状态, 如果网络状态是 4G 或者 WiFi 就重新连接
//                //    其他状态, 暂不考虑连接
//                NSLog(@"####Text autoconnect socket### error no socektmanger!");
//                if (self.reachabiltyStatus==AFNetworkReachabilityStatusReachableViaWWAN
//                    ||self.reachabiltyStatus==AFNetworkReachabilityStatusReachableViaWiFi)
//                {
//                    NSLog(@"####Text autoconnect socket### do re connect!");
//                    dispatch_async(dispatch_get_main_queue(), ^{
//                        self.socketManage = [XXGJSocketManager sharedXXGJSocketManager];
//                        [self.socketManage connect];
//                    });
//                }else
//                {
//                    NSLog(@"####Text autoconnect socket### error no network!");
//                }
//            }
//        }else if (self.socketManage)
//        {
//            [self.socketManage disconnect];
//            NSLog(@"####Text autoconnect socket### error no user but socket connect!");
//        }else
//        {
//            NSLog(@"####Text autoconnect socket### error no user!");
//        }
//    }];
    
//    [[NSRunLoop currentRunLoop] addTimer:listenTimer forMode:NSRunLoopCommonModes];
//    [[NSRunLoop currentRunLoop] run];
}

- (void)surveyNetworkConcatenate:(id)sender
{
    /* 函数调用返回的枚举值 */
    /**
     AFNetworkReachabilityStatusUnknown          = -1,  // 未知
     AFNetworkReachabilityStatusNotReachable     = 0,   // 无连接
     AFNetworkReachabilityStatusReachableViaWWAN = 1,   // 3G 花钱
     AFNetworkReachabilityStatusReachableViaWiFi = 2,   // 局域网络,
     */
    [[AFNetworkReachabilityManager sharedManager] setReachabilityStatusChangeBlock:^(AFNetworkReachabilityStatus status)
    {
        self.reachabiltyStatus = status;
    }];
    
    [[AFNetworkReachabilityManager sharedManager] startMonitoring];
}

- (void)updateImageMessage
{
    // 1. 读取所有的图片消息
    // 2. 将所有图片消息的Arg.progress置空
    NSArray *imageMessageArray = [self.dbModelManage excuteTable:TABLE_MESSAGE predicate:[NSString stringWithFormat:@"messageType=='1'"]];
    for (Message *imageMessage in imageMessageArray)
    {
        imageMessage.args.progress = nil;
    }
    [self saveContext];
}

#pragma mark - Core Data stack

// Returns the managed object context for the application.
// If the context doesn't already exist, it is created and bound to the persistent store coordinator for the application.
- (NSManagedObjectContext *)managedObjectContext
{
    if (_managedObjectContext != nil) {
        return _managedObjectContext;
    }
    
    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    if (coordinator != nil) {
        _managedObjectContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSMainQueueConcurrencyType];
        [_managedObjectContext setPersistentStoreCoordinator:coordinator];
    }
    return _managedObjectContext;
}

// Returns the managed object context for the application.
// If the context doesn't already exist, it is created and bound to the persistent store coordinator for the application.
- (NSManagedObjectContext *)bkmanagedObjectContext
{
    if (_bkmanagedObjectContext != nil) {
        return _bkmanagedObjectContext;
    }
    
    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    if (coordinator != nil) {
        _bkmanagedObjectContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSPrivateQueueConcurrencyType];
        [_bkmanagedObjectContext setPersistentStoreCoordinator:coordinator];
    }
    return _bkmanagedObjectContext;
}

// Returns the managed object model for the application.
// If the model doesn't already exist, it is created from the application's model.
- (NSManagedObjectModel *)managedObjectModel
{
    if (_managedObjectModel != nil) {
        return _managedObjectModel;
    }
    NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"xxdcchat_ios" withExtension:@"momd"];
    _managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
    
    return _managedObjectModel;
}

// Returns the persistent store coordinator for the application.
// If the coordinator doesn't already exist, it is created and the application's store added to it.
- (NSPersistentStoreCoordinator *)persistentStoreCoordinator
{
    if (_persistentStoreCoordinator != nil) {
        return _persistentStoreCoordinator;
    }
    
    NSURL *storeURL = [[self applicationDocumentsDirectory] URLByAppendingPathComponent:@"xxdcchat_ios.sqlite"];
    NSLog(@"%@", storeURL);
    NSError *error = nil;
    _persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];
    NSDictionary *optionsDictionary = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithBool:YES],
                                       NSMigratePersistentStoresAutomaticallyOption, [NSNumber numberWithBool:YES],
                                       NSInferMappingModelAutomaticallyOption, nil];
    
    
    if (![_persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:optionsDictionary error:&error]) {
        /*
         Replace this implementation with code to handle the error appropriately.
         
         abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
         
         Typical reasons for an error here include:
         * The persistent store is not accessible;
         * The schema for the persistent store is incompatible with current managed object model.
         Check the error message to determine what the actual problem was.
         
         
         If the persistent store is not accessible, there is typically something wrong with the file path. Often, a file URL is pointing into the application's resources directory instead of a writeable directory.
         
         If you encounter schema incompatibility errors during development, you can reduce their frequency by:
         * Simply deleting the existing store:
         [[NSFileManager defaultManager] removeItemAtURL:storeURL error:nil]
         
         * Performing automatic lightweight migration by passing the following dictionary as the options parameter:
         @{NSMigratePersistentStoresAutomaticallyOption:@YES, NSInferMappingModelAutomaticallyOption:@YES}
         
         Lightweight migration will only work for a limited set of schema changes; consult "Core Data Model Versioning and Data Migration Programming Guide" for details.
         
         */
        
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }
    
    return _persistentStoreCoordinator;
}

#pragma mark - Core Data Saving support
- (void)saveContext
{
    NSError *error = nil;
    NSManagedObjectContext *managedObjectContext = self.managedObjectContext;
    if (managedObjectContext != nil) {
        [managedObjectContext setMergePolicy:NSMergeByPropertyObjectTrumpMergePolicy];
        if ([managedObjectContext hasChanges] && ![managedObjectContext save:&error]) {
            // Replace this implementation with code to handle the error appropriately.
            // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            abort();
        }
    }
}

#pragma mark - Application's Documents directory

// Returns the URL to the application's Documents directory.
- (NSURL *)applicationDocumentsDirectory
{
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
}

#pragma mark - socket delegate
/**
 socket 自动断开链接
 
 @param err 断开链接错误信息
 */
- (void)didDisconnectError:(NSError *)err
{
    self.socketManage = nil;
}

#pragma mark - wxapi delegate
/*! @brief 收到一个来自微信的请求，处理完后调用sendResp
 *
 * 收到一个来自微信的请求，异步处理完成后必须调用sendResp发送处理结果给微信。
 * 可能收到的请求有GetMessageFromWXReq、ShowMessageFromWXReq等。
 * @param req 具体请求内容，是自动释放的
 */
-(void) onReq:(BaseReq*)req
{
    NSLog(@",..");
}

/*! @brief 发送一个sendReq后，收到微信的回应
 *
 * 收到一个来自微信的处理结果。调用一次sendReq后会收到onResp。
 * 可能收到的处理结果有SendMessageToWXResp、SendAuthResp等。
 * @param resp 具体的回应内容，是自动释放的
 */
-(void) onResp:(BaseResp*)resp
{
    if ([resp isKindOfClass:[PayResp class]]){
        PayResp*response=(PayResp*)resp;
        switch(response.errCode){
            case WXSuccess:
                //服务器端查询支付通知或查询API返回的结果再提示成功
                NSLog(@"支付成功");
                [MBProgressHUD showLoadHUDCustomImage:successHUDName title:@"支付成功"];
                [[NSNotificationCenter defaultCenter] postNotificationName:XXGJ_NOTIFY_RELOAD_WEBVIEW object:nil];
                break;
            case WXErrCodeUserCancel:
                NSLog(@"用户取消交易");
                [MBProgressHUD showLoadHUDCustomImage:successHUDName title:@"支付取消"];
                break;
            case WXErrCodeSentFail:
                NSLog(@"交易发起失败");
                [MBProgressHUD showLoadHUDCustomImage:successHUDName title:@"发起支付失败"];
                break;
            default:
                NSLog(@"支付失败，retcode=%d",resp.errCode);
                [MBProgressHUD showLoadHUDText:[NSString stringWithFormat:@"支付失败，retcode=%d",resp.errCode]];
                break;
        }
    }
}

@end
