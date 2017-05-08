//
//  XXGJGrabRedEnvelopeViewController.m
//  xxdcchat_ios
//
//  Created by 刘朝龙 on 2017/4/26.
//  Copyright © 2017年 刘朝龙. All rights reserved.
//

#import "XXGJGrabRedEnvelopeViewController.h"
#import "XXGJGrabRedEnvelopeTableViewCell.h"
#import <UIImageView+WebCache.h>

@interface XXGJGrabRedEnvelopeViewController () <UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong)XXGJGrabRedEnvelopeStatusItem *grabStatusItem;

@property (weak, nonatomic) IBOutlet UIImageView *userIconImageView;
@property (weak, nonatomic) IBOutlet UILabel *userNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *userGrabRemarkLabel;
@property (weak, nonatomic) IBOutlet UILabel *userGrabMoneyLabel;
@property (weak, nonatomic) IBOutlet UIView *friendBottomUIView;
@property (weak, nonatomic) IBOutlet UIView *groupBottomUIView;
@property (weak, nonatomic) IBOutlet UILabel *groupGrabInfoLabel;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *topViewAllLayoutConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *topViewShortLayoutConstraint;
@property (weak, nonatomic) IBOutlet UIView *grabMoneyView;
@property (weak, nonatomic) IBOutlet UILabel *alertLabel;

@end

@implementation XXGJGrabRedEnvelopeViewController

+ (instancetype)grabRedEnvelopeViewControllerWithStatus:(XXGJGrabRedEnvelopeStatusItem *)grabStatusItem
{
    XXGJGrabRedEnvelopeViewController *grabRedEnvelopeVC = [[NSBundle mainBundle] loadNibNamed:NSStringFromClass(self) owner:nil options:nil].lastObject;
    grabRedEnvelopeVC.grabStatusItem = grabStatusItem;
    return grabRedEnvelopeVC;
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [self.navigationController.navigationBar setHidden:NO];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.navigationController.navigationBar setHidden:YES];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - getter and setter
- (void)setGrabStatusItem:(XXGJGrabRedEnvelopeStatusItem *)grabStatusItem
{
    _grabStatusItem = grabStatusItem;
    // 判断页面数据显示
    NSNumber *userId = self.appDelegate.user.user_id;
    BOOL isGroup     = [grabStatusItem.isGroup boolValue];
    // 设置用户头像
    if (self.grabStatusItem.grapUserEntity.userIcon) {
        [self.userIconImageView sd_setImageWithURL:[NSURL URLWithString:self.grabStatusItem.grapUserEntity.userIcon]
                                  placeholderImage:[UIImage imageNamed:@"placeholder_user_male_icon-98"]];
    }else
    {
        [self.userIconImageView setImage:[UIImage imageNamed:@"placeholder_user_male_icon-98"]];
    }
    // 设置用户名称
    [self.userNameLabel setText:[NSString stringWithFormat:@"%@的红包", grabStatusItem.grapUserEntity.NickName]];
    // 红包用户发送的备注
    [self.userGrabRemarkLabel setText:grabStatusItem.content];
    // 判断, 如果抢到红包为空, 则隐藏金额部分UI
    if ([grabStatusItem.grapDeliveryItem.amout floatValue] <= 0.0f)
    {
        self.topViewShortLayoutConstraint.priority = UILayoutPriorityRequired;
        self.topViewAllLayoutConstraint.priority = UILayoutPriorityDefaultLow;
        [self.grabMoneyView setHidden:YES];
        [self.alertLabel setHidden:YES];
    } else
    {
        self.topViewShortLayoutConstraint.priority = UILayoutPriorityDefaultLow;
        self.topViewAllLayoutConstraint.priority = UILayoutPriorityRequired;
        [self.grabMoneyView setHidden:NO];
        [self.alertLabel setHidden:NO];
        // 抢到红包的金额
        [self.userGrabMoneyLabel setText:[NSString stringWithFormat:@"%.2f", [grabStatusItem.grapDeliveryItem.amout floatValue]]];
    }
    // 判断显示的视图
    if (isGroup || (!isGroup && [grabStatusItem.grapUserEntity.ID isEqualToNumber:userId]))
    {
        // 显示几个红包, 多长时间被抢完
        NSUInteger totalNum = [grabStatusItem.num unsignedIntegerValue];
        NSUInteger leftNum  = [grabStatusItem.leftNum unsignedIntegerValue];
        CGFloat amount      = [grabStatusItem.amount floatValue];
        CGFloat leftAmount  = [grabStatusItem.leftAmount floatValue];
        
        if (leftNum > 0)
        {
            [self.groupGrabInfoLabel setText:[NSString stringWithFormat:@"红包数量%ld/%ld, 金额%.2f/%.2f", leftNum, totalNum, leftAmount, amount]];
        }else
        {
            [self.groupGrabInfoLabel setText:[NSString stringWithFormat:@"%ld个红包, 已被抢完",  totalNum]];
        }
        
        [self.groupBottomUIView setHidden:NO];
        [self.tableView reloadData];
    }else
    {
        [self.friendBottomUIView setHidden:NO];
    }
}

#pragma mark - lazy method

#pragma mark - open method

#pragma mark - private method
- (IBAction)closeDrabRedEnvelopeViewController:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

/**
 好友答谢方法

 @param sender 按钮
 */
- (IBAction)acknowledgeAction:(id)sender
{
}

#pragma mark - delegate
#pragma mark - table view delegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 60;
}

#pragma mark - table view datasource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.grabStatusItem.grapUserItemArr.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    XXGJGrabRedEnvelopeTableViewCell *grabRedEnvelopeCell = [XXGJGrabRedEnvelopeTableViewCell grabRedEnvelopeCell:tableView];
    [grabRedEnvelopeCell setGrapRedEnvelopeItem:self.grabStatusItem.grapUserItemArr[indexPath.row]];
    return grabRedEnvelopeCell;
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
