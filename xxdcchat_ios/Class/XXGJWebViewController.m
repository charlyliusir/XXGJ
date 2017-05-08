//
//  XXGJWebViewController.m
//  xxdcchat_ios
//
//  Created by 刘朝龙 on 2017/4/7.
//  Copyright © 2017年 刘朝龙. All rights reserved.
//

#import "XXGJWebViewController.h"
#import <WebKit/WebKit.h>
#import <JavaScriptCore/JavaScriptCore.h>
#import "XXGJTabBarController.h"
#import "NJKWebViewProgressView.h"
#import "NJKWebViewProgress.h"
#import "XXGJCookieTools.h"
#import "WXApi.h"

@interface XXGJWebViewController () <UIWebViewDelegate,NJKWebViewProgressDelegate>

@property (nonatomic, strong)UIWebView *webView;
@property (nonatomic, strong)NJKWebViewProgressView *webViewProgressView;
@property (nonatomic, strong)NJKWebViewProgress *webViewProgress;
@property (nonatomic,   copy)NSString *vcFlag;

@end

@implementation XXGJWebViewController

- (void)setStatusBarBackgroundColor:(UIColor *)color {
    
    UIView *statusBar = [[[UIApplication sharedApplication] valueForKey:@"statusBarWindow"] valueForKey:@"statusBar"];
    if ([statusBar respondsToSelector:@selector(setBackgroundColor:)]) {
        statusBar.backgroundColor = color;
    }
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [self.navigationController.navigationBar setHidden:NO];
    [self setStatusBarBackgroundColor:[UIColor clearColor]];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self.navigationController.navigationBar setHidden:YES];
    [self setStatusBarBackgroundColor:[UIColor whiteColor]];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reloadWebView) name:XXGJ_NOTIFY_RELOAD_WEBVIEW object:nil];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self.view setBackgroundColor:[UIColor whiteColor]];
    
    self.webView = [[UIWebView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
    [self.view addSubview:self.webView];
    [self.webView.scrollView setBounces:NO];
    
    self.webViewProgress = [[NJKWebViewProgress alloc] init];
    self.webView.delegate = self.webViewProgress;
    self.webViewProgress.webViewProxyDelegate = self;
    self.webViewProgress.progressDelegate = self;
    
    CGRect barFrame = CGRectMake(0,20,self.view.frame.size.width,2);
    self.webViewProgressView = [[NJKWebViewProgressView alloc] initWithFrame:barFrame];
    self.webViewProgressView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin;
    [self.webViewProgressView setProgress:0.0 animated:YES];
    [self.view addSubview:self.webViewProgressView];
    
    [self reloadRequest];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - setter and getter
- (void)setRequestUrl:(NSString *)requestUrl
{
    _requestUrl = requestUrl;
    
}

#pragma mark - private method
- (void)reloadRequest
{
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:self.requestUrl]];
    
    NSArray * cookies = [[NSHTTPCookieStorage  sharedHTTPCookieStorage] cookies];
    NSDictionary * headers = [NSHTTPCookie requestHeaderFieldsWithCookies:cookies];
    [request setHTTPMethod:@"POST"];
    [request setHTTPShouldHandleCookies:YES];
    [request setAllHTTPHeaderFields:headers];
    [self.webView loadRequest:request];
}

/**
 重新刷新当前页面
 */
- (void)reloadWebView
{
    [self.webView reload];
}

#pragma mark - delegate
#pragma mark - NJKWebViewProgressDelegate
-(void)webViewProgress:(NJKWebViewProgress *)webViewProgress updateProgress:(float)progress
{
    [_webViewProgressView setProgress:progress animated:YES];
    self.title = [_webView stringByEvaluatingJavaScriptFromString:@"document.title"];
}
#pragma mark - web view delegate
- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{
    return YES;
}

- (void)webViewDidStartLoad:(UIWebView *)webView
{
    
}

- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    JSContext *context = [self.webView valueForKeyPath:@"documentView.webView.mainFrame.javaScriptContext"];
    context[@"isLogin"] = ^(){
        /** h5调用，判断是否登录*/
        NSLog(@"h5调用是否登录接口");
        return [self isLogin];
    };
    context[@"loginApp"] = ^(){
        /** 重新登录*/
        NSLog(@"重新登录接口调用了");
        [self loginApp];
    };
    context[@"pay"] = ^{
        /** 支付*/
        JSValue *payMainId = [[JSContext currentArguments] firstObject];
        dispatch_async(dispatch_get_main_queue(), ^{
            [self pay:payMainId];
        });
    };
    context[@"startChat"] = ^{
        /** 陌生人交流*/
        JSValue *userId = [[JSContext currentArguments] firstObject];
        dispatch_async(dispatch_get_main_queue(), ^{
            [self chatWithUser:userId];
        });
    };
    context[@"callPhone"] = ^(){
        /** 拨打电话*/
        JSValue *phoneNumber = [[JSContext currentArguments] firstObject];
        dispatch_async(dispatch_get_main_queue(), ^{
            [self callPhone:phoneNumber];
        });
    };
    context[@"startTalking"] = ^(){
        /** 点击tabbar选项*/
        JSValue *flag = [[JSContext currentArguments] firstObject];
        dispatch_async(dispatch_get_main_queue(), ^{
            [self startTalking:flag];
        });
    };
    context[@"backButton"] = ^(){
        /** 点击返回按钮*/
        dispatch_async(dispatch_get_main_queue(), ^{
            [self backButton];
        });
    };
    context[@"startNavigation"] = ^{
        NSLog(@"startNavigation...");
    };
    
    context[@"startAirlines"] = ^{
        NSLog(@"startAirlines");
    };
    
    
    [self.webView stringByEvaluatingJavaScriptFromString:@"androidFun('ios')"];
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error
{
    
}

/**
 判断用户是否登录

 @return 是否登录 flag
 */
- (BOOL)isLogin
{
    return YES;
}

/**
 移动端执行用户登录方法
 */
- (void)loginApp
{
    // 判断是否保存用户信息，如果没有用户信息，则跳转登录页面，否则执行登录操作
    NSDictionary *userinfo = [[NSUserDefaults standardUserDefaults] objectForKey:XX_USERDEFAULT_USER];
    [XXGJNetKit login:@{XXGJ_N_PARAM_USERNAME:userinfo[XXGJ_N_PARAM_USERNAME], XXGJ_N_PARAM_PASSWORD:userinfo[XXGJ_N_PARAM_PASSWORD]} rBlock:^(id obj, BOOL success, NSError *error) {
        [XXGJCookieTools setCookies];
        [self reloadRequest];
    }];
}

/**
 支付方法：充值、购买商品等

 @param payMainId 订单账号的 id
 */
- (void)pay:(JSValue *)payMainId
{
    [MBProgressHUD showLoadHUDIndeterminate:@"正在查询订单"];
    /** 网络请求订单详情信息*/
    [XXGJNetKit getPayInfoWithPayMainId:[payMainId toString] rBlock:^(id obj, BOOL success, NSError *error) {
        
        if (success && obj)
        {
            [MBProgressHUD hiddenHUD];
            NSDictionary *result = (NSDictionary *)obj;
            [MBProgressHUD showLoadHUDText:result[@"status"][@"msg"]];
            if (result && result[@"status"]&&[result[@"status"][@"msg"] isEqualToString:@"success"])
            {
                NSDictionary *data = result[@"data"][@"result"];
                /** 开始调用微信支付*/
                PayReq *payReq = [[PayReq alloc] init];
                payReq.partnerId = data[@"partnerid"];
                payReq.package   = data[@"package"];
                payReq.prepayId  = data[@"prepayid"];
                payReq.sign      = data[@"sign"];
                payReq.nonceStr  = data[@"noncestr"];
                payReq.timeStamp = [data[@"timestamp"] unsignedIntValue];
                dispatch_async(dispatch_get_main_queue(), ^{
                    [WXApi sendReq:payReq];
                });
            
            }else
            {
                [MBProgressHUD showLoadHUDText:@"订单查询失败" during:0.25];
            }
        }else
        {
            [MBProgressHUD showLoadHUDText:@"订单查询失败" during:0.25];
        }
    }];
}
/**
 从 h5 跳转 app 进行用户交互

 @param userId 用户id
 */
- (void)chatWithUser:(JSValue *)userId
{
    
}

/**
 从 h5 跳转 app 拨打电话

 @param phoneNumber 电话号码
 */
- (void)callPhone:(JSValue*) phoneNumber
{
    /** 电话号码*/
    NSString *pNumber = [phoneNumber toString];
    /** 拨打电话*/
    NSURL *telURL = [NSURL URLWithString:[NSString stringWithFormat:@"tel:%@", pNumber]];
    
    [self.webView loadRequest:[NSURLRequest requestWithURL:telURL]];
}

/**
 从 h5 跳转 app 专有功能界面

 @param flag 界面标记
 */
- (void)startTalking:(JSValue*) flag
{
    self.vcFlag = [flag toString]; /** 记录页面*/
    /** 交流界面、装修界面和我的界面需要跳回 App 操作*/
    if ([self.vcFlag isEqualToString:@"0"])
        /** 交流界面*/
    {
        [self.appDelegate.rootViewController setSelectedIndex:0];
    }else if ([self.vcFlag isEqualToString:@"2"])
        /** 装修界面*/
    {
        [self.appDelegate.rootViewController setSelectedIndex:3];
    }else if ([self.vcFlag isEqualToString:@"3"])
        /** 我的界面*/
    {
        [self.appDelegate.rootViewController setSelectedIndex:4];
    }
    [self backButton];
}

/**
 返回按钮被点击
 */
- (void)backButton
{
    /** 返回进入页面*/
    [self.navigationController popViewControllerAnimated:YES];
}
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
