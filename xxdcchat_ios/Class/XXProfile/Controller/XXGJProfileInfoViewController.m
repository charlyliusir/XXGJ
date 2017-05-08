//
//  XXGJProfileInfoViewController.m
//  xxdcchat_ios
//
//  Created by 刘朝龙 on 2017/4/10.
//  Copyright © 2017年 刘朝龙. All rights reserved.
//

#import "XXGJProfileInfoViewController.h"

@interface XXGJProfileInfoViewController ()

@end

@implementation XXGJProfileInfoViewController

+ (instancetype)profileInfoViewController
{
    UIStoryboard *storyBoard = [UIStoryboard storyboardWithName:@"Profile" bundle:[NSBundle mainBundle]];
    return [storyBoard instantiateViewControllerWithIdentifier:@"profileInfo"];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
