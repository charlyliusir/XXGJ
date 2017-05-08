//
//  XXGJViewController.m
//  xxdcchat_ios
//
//  Created by 刘朝龙 on 2017/3/15.
//  Copyright © 2017年 刘朝龙. All rights reserved.
//

#import "XXGJViewController.h"

@interface XXGJViewController ()

@end

@implementation XXGJViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    
    /** 添加左按钮样式*/
    UIBarButtonItem *leftButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"btn_back_icon"] style:UIBarButtonItemStylePlain target:self action:@selector(backMethod:)];
    
    self.navigationItem.leftBarButtonItem  = leftButtonItem;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma open method
- (void)setNavigationBarTitle:(NSString *)title
{
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 0, 44)];
    [titleLabel setText:title];
    [titleLabel setTextColor:XX_NAVIGATIONBAR_TITLECOLOR];
    [titleLabel setFont:[UIFont systemFontOfSize:18]];
    
    self.navigationItem.titleView = titleLabel;
}

- (void)backMethod:(UIBarButtonItem *)barButtonItem
{
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
