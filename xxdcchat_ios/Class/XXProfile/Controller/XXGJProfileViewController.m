//
//  XXGJProfileViewController.m
//  xxdcchat_ios
//
//  Created by 刘朝龙 on 2017/3/15.
//  Copyright © 2017年 刘朝龙. All rights reserved.
//

#import "XXGJProfileViewController.h"
#import "XXGJProfileInfoViewController.h"
#import <UIImageView+WebCache.h>

@interface XXGJProfileViewController ()
@property (weak, nonatomic) IBOutlet UIView *footerView;
@property (weak, nonatomic) IBOutlet UIImageView *avartImageView;
@property (weak, nonatomic) IBOutlet UILabel *userNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *userIdLabel;
@property (weak, nonatomic) IBOutlet UILabel *phoeNumberLabel;

@end

@implementation XXGJProfileViewController

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self setNavigationBarTitle:@"我"];
    [self updateUserInfo];
    
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}


#pragma mark - private method
- (void)updateUserInfo
{
    [self.userNameLabel setText:self.appDelegate.user.nick_name];
    [self.userIdLabel setText:[NSString stringWithFormat:@"%@", self.appDelegate.user.user_id]];
    [self.phoeNumberLabel setText:self.appDelegate.user.mobile];
    if (self.appDelegate.user.avatar)
    {
        [self.avartImageView sd_setImageWithURL:[NSURL URLWithString:[XXGJ_N_BASE_IMAGE_URL stringByAppendingPathComponent:self.appDelegate.user.avatar]] placeholderImage:[UIImage imageNamed:@"placeholder_user_male_icon"]];
    }else{
        [self.avartImageView setImage:[UIImage imageNamed:@"placeholder_user_male_icon"]];
    }
    self.navigationItem.leftBarButtonItem = nil;
}
- (IBAction)goUserInfo:(id)sender {
    XXGJProfileInfoViewController *profileInfoVC = [XXGJProfileInfoViewController profileInfoViewController];
    [self.navigationController pushViewController:profileInfoVC animated:YES];
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    UITouch *touch = touches.anyObject;
    CGPoint point = [touch locationInView:self.view];
    if ([[self.view hitTest:point withEvent:UIEventTypeTouches] isEqual:self.footerView]) {
        /** 开始点击*/
        [self.footerView setBackgroundColor:XX_RGBCOLOR_WITHOUTA(224, 224, 224)];
    }
    
}

- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    /** 结束点击*/
    [self.footerView setBackgroundColor:[UIColor whiteColor]];
}

- (void)touchesCancelled:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    /** 取消点击*/
    [self.footerView setBackgroundColor:[UIColor whiteColor]];
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
