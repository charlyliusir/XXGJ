//
//  XXGJUpdateBornViewController.m
//  xxdcchat_ios
//
//  Created by 刘朝龙 on 2017/5/2.
//  Copyright © 2017年 刘朝龙. All rights reserved.
//

#import "XXGJUpdateBornViewController.h"
#import "NSDate+XXGJFormatter.h"

@interface XXGJUpdateBornViewController ()
@property (weak, nonatomic) IBOutlet UIDatePicker *datePicker;
@property (nonatomic, copy)UpdateBornConfirmBlock confirmBlock; // 确定按钮被点击后执行回调
@end

@implementation XXGJUpdateBornViewController

+ (instancetype)updateBornViewController
{
    return [[NSBundle mainBundle] loadNibNamed:NSStringFromClass(self) owner:nil options:nil].firstObject;
}


- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self.datePicker setBackgroundColor:[UIColor whiteColor]];
    [self.datePicker setMaximumDate:[NSDate date]];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)setConfirmBlock:(UpdateBornConfirmBlock)confirmBlock
{
    _confirmBlock = confirmBlock;
}

#pragma mark - private
- (IBAction)confirmAction:(id)sender
{
    /** 读取用户选择后的时间*/
    NSDate *bornDate   = [self.datePicker date];
    /** 将日期返还给上一个页面*/
    self.confirmBlock(bornDate);
    // 退到上一级页面
    [self dismissViewControllerAnimated:YES completion:nil];
}
- (IBAction)cancelAction:(id)sender
{
    // 直接退出，不进行修改
    [self dismissViewControllerAnimated:YES completion:nil];
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
