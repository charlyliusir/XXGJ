//
//  AppDelegate.h
//  xxdcchat_ios
//
//  Created by 刘朝龙 on 2017/3/15.
//  Copyright © 2017年 刘朝龙. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AFNetworkReachabilityManager.h>
#import <BaiduMapAPI_Base/BMKMapManager.h>
#import "XXGJSocketManager.h"
#import "XXGJDBModelManager.h"
#import "XXGJTabBarController.h"
#import "User.h"

#define XXGJ_STORY_NAME_MAIN  @"Main"
#define XXGJ_STORY_NAME_LOGIN @"Login"
#define XXGJ_NOTIFY_RELOAD_WEBVIEW @"reloadWebView"

@interface AppDelegate : UIResponder <UIApplicationDelegate, NSFetchedResultsControllerDelegate>

@property (strong, nonatomic) UIWindow *window;
@property (nonatomic, strong) XXGJSocketManager *socketManage;      /** socket 管理器*/
@property (nonatomic, strong) XXGJDBModelManager *dbModelManage;    /** 数据库管理 管理器*/
@property (nonatomic, strong) BMKMapManager *mapManager;            /** 百度地图 管理器*/
@property (nonatomic, strong) User *user;                           /** 当前登录用户*/
@property (nonatomic, strong) NSMutableDictionary *drawnMessageUuidDict;/** 撤销消息的uuid*/
@property (nonatomic, assign) BOOL isRunning;
@property (nonatomic, assign) AFNetworkReachabilityStatus reachabiltyStatus;

- (void)exchangeRootViewControllerWithStoryBoard:(NSString *)storyBoardName;  /** 切换主控制器*/
- (BOOL)canSendMessage;
- (UINavigationController *)rootViewControllerNavi;
- (XXGJTabBarController *)rootViewController;
#pragma mark - coredata
@property (readwrite, strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (readwrite, strong, nonatomic) NSManagedObjectContext *bkmanagedObjectContext;
@property (readwrite, strong, nonatomic) NSManagedObjectModel *managedObjectModel;
@property (readwrite, strong, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;

- (void)saveContext;

@end

