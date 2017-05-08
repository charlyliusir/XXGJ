//
//  XXGJProfileTableViewController.m
//  xxdcchat_ios
//
//  Created by 刘朝龙 on 2017/4/7.
//  Copyright © 2017年 刘朝龙. All rights reserved.
//

#import "XXGJProfileTableViewController.h"
#import "XXGJWebViewController.h"
#import "MBProgressHUD+XXGJProgressHUD.h"
#import "AppDelegate.h"

@interface XXGJProfileTableViewController ()
@property (nonatomic, strong)AppDelegate *appDelegate;
@end

@implementation XXGJProfileTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    [self.tableView setBackgroundColor:[UIColor clearColor]];
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.tableView.frame.size.width, 20)];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - private method
- (void)outLogin
{
    /** 此处添加 loading 菊花效果*/
    [MBProgressHUD showLoadHUDIndeterminate:@"正在退出登录..."];
    if (self.appDelegate.socketManage.socketConnected && self.appDelegate.socketManage.session_key)
    {
        [self.appDelegate.socketManage setSocketOffline:1];
        [XXGJNetKit logout:@{XXGJ_N_PARAM_SESSIONKEY:self.appDelegate.socketManage.session_key} rBlock:^(id obj, BOOL success, NSError *error) {
            if (success && [obj[@"statusText"] isEqualToString:@"logout success"])
            {
                /** 清空当前的用户*/
                self.appDelegate.user = nil;
                /** 更新最后更新时间*/
                [self.appDelegate.user setUpdate:nil];
                [self.appDelegate saveContext];
                /** 修改用户的本地缓存数据*/
                NSMutableDictionary *userinfo = [[[NSUserDefaults standardUserDefaults] objectForKey:XX_USERDEFAULT_USER] mutableCopy];
                [userinfo removeObjectForKey:XXGJ_N_PARAM_USERID];
                
                [[NSUserDefaults standardUserDefaults] setObject:userinfo.copy forKey:XX_USERDEFAULT_USER];
                [[NSUserDefaults standardUserDefaults] synchronize];
                
                /** 退出登录成功, 移除Cookies数据*/
                [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"user_cookies"];
                
                /** 退到登录界面*/
                /** 跳转首页控制器, 由于是 UI 操作, 需要放入主线程*/
                [MBProgressHUD showLoadHUDText:@"退出登录成功"];
                dispatch_time_t time=dispatch_time(DISPATCH_TIME_NOW, 0.25*NSEC_PER_SEC);
                dispatch_after(time,dispatch_get_main_queue(), ^{
                    [MBProgressHUD hiddenHUD];
                    [self.appDelegate exchangeRootViewControllerWithStoryBoard:XXGJ_STORY_NAME_LOGIN];
                    NSLog(@"outlog success");
                });
            }
            else if([obj[@"statusText"] isEqualToString:@"user not connect"])
            {
                [self.appDelegate.socketManage setSocketOffline:0];
                [MBProgressHUD showLoadHUDText:@"正在连接服务器,请稍后再试..." during:0.25];
            }else
            {
                [self.appDelegate.socketManage setSocketOffline:0];
                [MBProgressHUD showLoadHUDText:@"退出登录失败, 请检查网络连接是否正常！" during:0.5];
            }
        }];
    }else
    {
        self.appDelegate.user = nil;
        [self.appDelegate.socketManage setSocketOffline:1];
        [self.appDelegate.socketManage stopReConnectedThread];
        /** 退出登录成功, 移除Cookies数据*/
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"user_cookies"];
        
        NSMutableDictionary *userinfo = [[[NSUserDefaults standardUserDefaults] objectForKey:XX_USERDEFAULT_USER] mutableCopy];
        [userinfo removeObjectForKey:XXGJ_N_PARAM_USERID];
        [[NSUserDefaults standardUserDefaults] setObject:userinfo.copy forKey:XX_USERDEFAULT_USER];
        [[NSUserDefaults standardUserDefaults] synchronize];
        /** 退到登录界面*/
        /** 跳转首页控制器, 由于是 UI 操作, 需要放入主线程*/
        [MBProgressHUD showLoadHUDText:@"退出登录成功"];
        dispatch_time_t time=dispatch_time(DISPATCH_TIME_NOW, 0.25*NSEC_PER_SEC);
        dispatch_after(time,dispatch_get_main_queue(), ^{
            [MBProgressHUD hiddenHUD];
            [self.appDelegate exchangeRootViewControllerWithStoryBoard:XXGJ_STORY_NAME_LOGIN];
            NSLog(@"outlog success");
        });
    }
    
    // 退出业务登录
    
    
}

#pragma mark - Table view delegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    /** 处理点击事件*/
    if (indexPath.section == 0)
    {
        /** 创建参数列表*/
        NSArray *webUrlListArray = @[XXGJ_WBEVIEW_REQUEST_URL_USER_WALLET,XXGJ_WBEVIEW_REQUEST_URL_USER_CALENDAR,
            [XXGJ_WBEVIEW_REQUEST_URL_USER_DESINGERID stringByAppendingFormat:@"%@", self.appDelegate.user.user_id]];
        /** 都是跳转到web页面*/
        NSMutableString *requestUrl = [NSMutableString stringWithString:XXGJ_WBEVIEW_REQUEST_BASE_URL];
        XXGJWebViewController *webView = [[XXGJWebViewController alloc] init];
        /** 拼接完整的请求链接*/
        [requestUrl appendString:webUrlListArray[indexPath.row]];
        /** 跳转到web页面*/
        [webView setRequestUrl:requestUrl];
        [webView setHidesBottomBarWhenPushed:YES];
        [[self.appDelegate rootViewControllerNavi] pushViewController:webView animated:YES];

    }else if (indexPath.section == 1)
    {
        /** 创建参数列表*/
        NSArray *webUrlListArray = @[XXGJ_WBEVIEW_REQUEST_URL_USER_TOMEAPPLY,XXGJ_WBEVIEW_REQUEST_URL_TOFINDPARTNER];
        NSMutableString *requestUrl = [NSMutableString stringWithString:XXGJ_WBEVIEW_REQUEST_BASE_URL];
        /** 都是跳转到web页面*/
        XXGJWebViewController *webView = [[XXGJWebViewController alloc] init];
        [requestUrl appendString:webUrlListArray[indexPath.row]];
        /** 跳转到web页面*/
        [webView setRequestUrl:requestUrl];
        [webView setHidesBottomBarWhenPushed:YES];
        [[self.appDelegate rootViewControllerNavi] pushViewController:webView animated:YES];
        
    } else if (indexPath.section == 4)
        /** 退出登录*/
    {
        [self outLogin];
    } else
    {
        /** 暂时不支持该操作*/
        [MBProgressHUD showLoadHUDText:@"暂时不支持该操作" during:0.25];
    }
    
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if (section == 4)
    {
        return 20;
    }
    return 15;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    //标题背景
    UIView *contentView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 30)];
    [contentView setBackgroundColor:XX_TABBAR_TINTCOLOR];
    return contentView;
}
#pragma mark - Table view data source

/*
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:<#@"reuseIdentifier"#> forIndexPath:indexPath];
    
    // Configure the cell...
    
    return cell;
}
*/

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
