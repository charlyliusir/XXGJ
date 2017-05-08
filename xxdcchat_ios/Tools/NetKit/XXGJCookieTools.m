//
//  XXGJCookieTools.m
//  xxdcchat_ios
//
//  Created by 刘朝龙 on 2017/3/24.
//  Copyright © 2017年 刘朝龙. All rights reserved.
//

#import "XXGJCookieTools.h"

@implementation XXGJCookieTools

+ (void)setCookies
{
    NSDictionary *cookieProperties = [[NSUserDefaults standardUserDefaults] objectForKey:@"user_cookies"];
    NSHTTPCookie * userCookie = [NSHTTPCookie cookieWithProperties:cookieProperties];
    [[NSHTTPCookieStorage sharedHTTPCookieStorage]setCookie:userCookie];
}

+ (void)saveCookies:(NSDictionary *)cookieProperties
{
    [[NSUserDefaults standardUserDefaults] setObject:cookieProperties forKey:@"user_cookies"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

@end
