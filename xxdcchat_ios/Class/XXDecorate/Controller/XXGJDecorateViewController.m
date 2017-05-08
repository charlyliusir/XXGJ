//
//  XXGJDecorateViewController.m
//  xxdcchat_ios
//
//  Created by 刘朝龙 on 2017/3/15.
//  Copyright © 2017年 刘朝龙. All rights reserved.
//

#import "XXGJDecorateViewController.h"
#import "XXGJWebViewController.h"

@interface XXGJDecorateViewController () <UITableViewDelegate, UITableViewDataSource>
@property (weak, nonatomic) IBOutlet UITableView *tableView;

@end

@implementation XXGJDecorateViewController

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self setNavigationBarTitle:@"装修"];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self.tableView setTableFooterView:[UIView new]];
    
}

- (IBAction)clickItemAction:(UITapGestureRecognizer *)sender
{
    /** 页面中被点击时间*/
    UIView *clickItem = sender.view;
    switch (clickItem.tag)
    {
        case 1001:
        {
            XXGJWebViewController *webView = [[XXGJWebViewController alloc] init];
            [webView setRequestUrl:[NSString stringWithFormat:@"%@%@", XXGJ_WBEVIEW_REQUEST_BASE_URL, XXGJ_WBEVIEW_REQUEST_URL_NEED_DEMAND]];
            [webView setHidesBottomBarWhenPushed:YES];
            [self.navigationController pushViewController:webView animated:YES];
        }
            break;
        case 1002:
        {
            XXGJWebViewController *webView = [[XXGJWebViewController alloc] init];
            [webView setRequestUrl:[NSString stringWithFormat:@"%@%@", XXGJ_WBEVIEW_REQUEST_BASE_URL, XXGJ_WBEVIEW_REQUEST_URL_NEED_DECORATION]];
            [webView setHidesBottomBarWhenPushed:YES];
            [self.navigationController pushViewController:webView animated:YES];
        }
            break;
        case 1003:
        {
            XXGJWebViewController *webView = [[XXGJWebViewController alloc] init];
            [webView setRequestUrl:[NSString stringWithFormat:@"%@%@", XXGJ_WBEVIEW_REQUEST_BASE_URL, XXGJ_WBEVIEW_REQUEST_URL_NEED_DECORATION]];
            [webView setHidesBottomBarWhenPushed:YES];
            [self.navigationController pushViewController:webView animated:YES];
        }
            break;
        case 3001:
        {
            XXGJWebViewController *webView = [[XXGJWebViewController alloc] init];
            [webView setRequestUrl:[NSString stringWithFormat:@"%@%@", XXGJ_WBEVIEW_REQUEST_BASE_URL, XXGJ_WBEVIEW_REQUEST_URL_DESIGNER_LIST]];
            [webView setHidesBottomBarWhenPushed:YES];
            [self.navigationController pushViewController:webView animated:YES];
        }
            break;
        case 3002:
        {
            XXGJWebViewController *webView = [[XXGJWebViewController alloc] init];
            [webView setRequestUrl:[NSString stringWithFormat:@"%@%@", XXGJ_WBEVIEW_REQUEST_BASE_URL, XXGJ_WBEVIEW_REQUEST_URL_WORKER_LIST]];
            [webView setHidesBottomBarWhenPushed:YES];
            [self.navigationController pushViewController:webView animated:YES];
        }
            break;
        case 3003:
        {
            XXGJWebViewController *webView = [[XXGJWebViewController alloc] init];
            [webView setRequestUrl:[NSString stringWithFormat:@"%@%@", XXGJ_WBEVIEW_REQUEST_BASE_URL, XXGJ_WBEVIEW_REQUEST_URL_KEPPER_LIST]];
            [webView setHidesBottomBarWhenPushed:YES];
            [self.navigationController pushViewController:webView animated:YES];
        }
            break;
        case 3004:
        {
            XXGJWebViewController *webView = [[XXGJWebViewController alloc] init];
            [webView setRequestUrl:[NSString stringWithFormat:@"%@%@", XXGJ_WBEVIEW_REQUEST_BASE_URL, XXGJ_WBEVIEW_REQUEST_URL_CONSULTANT_LIST]];
            [webView setHidesBottomBarWhenPushed:YES];
            [self.navigationController pushViewController:webView animated:YES];
        }
            break;
        default:
            break;
    }
}


/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

#pragma mark - delegate
#pragma mark - table view delegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 44;
}

#pragma mark - table view datasource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *tableViewCell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    if (!tableViewCell)
    {
        tableViewCell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cell"];
    }
    [tableViewCell.textLabel setText:@"helllo"];
    return tableViewCell;
}

@end
