//
//  XXGJGrabRedEnvelopeStatusView.m
//  xxdcchat_ios
//
//  Created by 刘朝龙 on 2017/4/26.
//  Copyright © 2017年 刘朝龙. All rights reserved.
//

#import "XXGJGrabRedEnvelopeStatusView.h"
#import "XXGJGrabRedEnvelopeStatusItem.h"
#import "XXGJGrabRedEnvelopeViewController.h"
#import "NSDate+XXGJFormatter.h"
#import "AppDelegate.h"
#import "XXGJMessage.h"
#import <UIImageView+WebCache.h>
@interface XXGJGrabRedEnvelopeStatusView ()

@property (nonatomic, copy)DisOverBlock overBlock;
@property (nonatomic, strong)XXGJGrabRedEnvelopeStatusItem *grabStatusItem;

@property (weak, nonatomic) IBOutlet UIImageView *userIconImageView;
@property (weak, nonatomic) IBOutlet UILabel *userNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *subTitleLabel;
@property (weak, nonatomic) IBOutlet UILabel *redEnvelopeRemarkLabel;
@property (weak, nonatomic) IBOutlet UIView *showInfoView;
@property (weak, nonatomic) IBOutlet UIButton *grabRedEnvelopeBtn;

@end

@implementation XXGJGrabRedEnvelopeStatusView

+ (instancetype)grabRedEnvelopeStatusViewWithOption:(NSDictionary *)options
{
    /** 获取视图对象*/
    XXGJGrabRedEnvelopeStatusView *grabStatusView = [[NSBundle mainBundle] loadNibNamed:NSStringFromClass(self) owner:nil options:nil].lastObject;
    /** 获取红包状态信息*/
    XXGJGrabRedEnvelopeStatusItem *grabStatusItem = [[XXGJGrabRedEnvelopeStatusItem alloc] init];
    [grabStatusItem setValuesForKeysWithDictionary:options];
    grabStatusView.grabStatusItem = grabStatusItem;
    
    return grabStatusView;
}


/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

#pragma mark - setter and getter
- (void)setGrabStatusItem:(XXGJGrabRedEnvelopeStatusItem *)grabStatusItem
{
    _grabStatusItem = grabStatusItem;
    [self reloadUIData];
}

- (void)reloadUIData
{
    // 设置用户头像
    if (self.grabStatusItem.grapUserEntity.userIcon) {
        [self.userIconImageView sd_setImageWithURL:[NSURL URLWithString:self.grabStatusItem.grapUserEntity.userIcon]
                                  placeholderImage:[UIImage imageNamed:@"placeholder_user_male_icon-98"]];
    }else
    {
        [self.userIconImageView setImage:[UIImage imageNamed:@"placeholder_user_male_icon-98"]];
    }
    
    // 设置用户名称
    [self.userNameLabel setText:self.grabStatusItem.grapUserEntity.NickName];
    
    // 添加逻辑判断
    NSString *redEnvelopeRemarkString = self.grabStatusItem.content;
    if ([self senderAndNoGroup]){ }
    else if ([self redEnvelopeOverTime])
    {
        redEnvelopeRemarkString = @"红包已超过24小时, 余额自动返还钱包！";
    }
    else if ([self grabRedEnvelopeEmpty])
    {
        redEnvelopeRemarkString = @"手慢了，没有抢到哦";
    }
    else if ([self isSender] && ![self senderAndNoGroup])
    {
        [self.grabRedEnvelopeBtn setHidden:NO];
    }
    else
    {
        [self.grabRedEnvelopeBtn setHidden:NO];
        [self.showInfoView setHidden:YES];
    }
    // 设置用户备注语
    [self.redEnvelopeRemarkLabel setText:redEnvelopeRemarkString];
}

- (void)setOverBlock:(DisOverBlock)overBlock
{
    _overBlock = overBlock;
}

#pragma mark - open method
- (void)showInWindom
{
    /** 判断是否已经抢过了, 如果抢过了就跳转到详情页*/
    if ([self grabRedEnvelopeOver] || [self senderAndNoGroup])
    {
        self.overBlock(YES, self.grabStatusItem);
    }
    else
    {
        UIWindow *kewWindom = [UIApplication sharedApplication].keyWindow;
        [self setFrame:kewWindom.bounds];
        [self setAlpha:0.0f];
        [kewWindom addSubview:self];
        [kewWindom bringSubviewToFront:self];
        
        [UIView animateWithDuration:0.15 animations:^{
            [self setAlpha:1.0f];
        }];
    }
}

#pragma mark - private method
- (void)dimissInWindom:(BOOL)goGrabInfo
{
    [UIView animateWithDuration:0.15 animations:^{
        [self setAlpha:0.0f];
    } completion:^(BOOL finished) {
        [self removeFromSuperview];
        // 然后block告诉上级页面丢弃了
        self.overBlock(goGrabInfo, self.grabStatusItem);
    }];
}
/**
 红包超过二十四小时

 @return 是否超时
 */
- (BOOL)redEnvelopeOverTime
{
    NSTimeInterval dayTimeInterval= 24*60*60;
    NSDate *currentDateTime       = [NSDate date];
    NSDate *redEnvelopeCreateTime = [NSDate datesinceTimeInterval:[self.grabStatusItem.createTime longLongValue]];
    return [currentDateTime timeIntervalSinceDate:redEnvelopeCreateTime] > dayTimeInterval;
}

/**
 判断红包是否已经抢空

 @return 是否已经抢空
 */
- (BOOL)grabRedEnvelopeEmpty
{
    // 获取红包剩余的状况
    NSUInteger leftNum    = [self.grabStatusItem.leftNum unsignedIntegerValue];
    NSUInteger leftAmount = [self.grabStatusItem.leftAmount unsignedIntegerValue];
    
    return (leftAmount==0&&leftNum==0);
}

/**
 判断用户是否抢过红包

 @return 是否抢过红包
 */
- (BOOL)grabRedEnvelopeOver
{
    // 用户的UserID
    AppDelegate *appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    NSNumber *userId    = appDelegate.user.user_id;
    // 是否抢过红包
    BOOL grabOver    = NO;
    // 判断你是否有抢过红包
    for (XXGJGrabRedEnvelopeItem *grabRedEnvelopeItem in self.grabStatusItem.grapUserItemArr)
    {
        if ([grabRedEnvelopeItem.grapDeliveryItem.userId isEqualToNumber:userId])
        {
            grabOver = YES;
            break;
        }
    }
    
    return grabOver;
}

/**
 非群组红包，自己不能抢

 @return 是否能抢
 */
- (BOOL)senderAndNoGroup
{
    // 用户的UserID
    AppDelegate *appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    NSNumber *userId    = appDelegate.user.user_id;
    // 红包用户UserId
    NSNumber *redUserId = self.grabStatusItem.grapUserEntity.ID;
    // 是否是群组红包
    BOOL isGroup   = [self.grabStatusItem.isGroup boolValue];
    
    return (!isGroup && [userId isEqualToNumber:redUserId]);
}

/**
 是否是你发的红包

 @return BOOL
 */
- (BOOL)isSender
{
    // 用户的UserID
    AppDelegate *appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    NSNumber *userId    = appDelegate.user.user_id;
    // 红包用户UserId
    NSNumber *redUserId = self.grabStatusItem.grapUserEntity.ID;
    
    return [userId isEqualToNumber:redUserId];
}

/**
 退出事件

 @param sender 按钮
 */
- (IBAction)dismissGrabRedEnvelopeStatusView:(id)sender
{
    [self dimissInWindom:NO];
}

/**
 抢红包接口

 @param sender 按钮
 */
- (IBAction)grabRedEnvelope:(id)sender
{
    // 本页抢红包, 红包抢成功后进入详情页, 前提判断是否抢成功
    /** 点开红包界面*/
    AppDelegate *appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    NSString *session_key = appDelegate.socketManage.session_key;
    NSNumber *user_id     = appDelegate.user.user_id;
    NSMutableDictionary *dict = @{}.mutableCopy;
    // sessionKey
    if (!session_key)
    {
        [MBProgressHUD showLoadHUDCustomImage:successHUDName title:@"服务器开小差了"];
        return;
    }
    [dict setObject:session_key forKey:XXGJ_N_PARAM_RED_SESSIONKEY];
    [dict setObject:user_id forKey:XXGJ_N_PARAM_RED_USERID];
    [dict setObject:self.grabStatusItem.redEnvelopeId forKey:XXGJ_ARGS_PARAM_REDENVELOPE_ID];
    [MBProgressHUD showLoadHUDIndeterminate:@"开启红包"];
    [XXGJNetKit grabRedEnvelope:dict rBlock:^(id obj, BOOL success, NSError *error) {
        [MBProgressHUD hiddenHUD];
        if (success && obj)
        {
            NSDictionary *data = (NSDictionary *)obj;
            if (data && [data[@"statusText"] isEqualToString:@"success"])
            {
                NSDictionary *result = data[@"result"];

                [self.grabStatusItem setValuesForKeysWithDictionary:result];
                // 添加判断, 是否抢夺成功
                if ([self.grabStatusItem.grapDeliveryItem.amout floatValue] <= 0.0f)
                    /** 没抢到红包*/
                {
                    [self reloadUIData];
                } else
                {
                    [self turnGrapRedEnvelopeViewController];
                }
            }else
            {
                [MBProgressHUD showLoadHUDCustomImage:successHUDName title:@"服务器开小差了"];
            }
        }else
        {
            [MBProgressHUD showLoadHUDCustomImage:successHUDName title:@"服务器开小差了"];
        }
    }];
}

/**
 显示详情信息

 @param sender 按钮
 */
- (IBAction)showGrabRedEnvelopeInfo:(id)sender
{
    // 跳转详情信息页面
    [self turnGrapRedEnvelopeViewController];
}

- (void)turnGrapRedEnvelopeViewController
{
    [self dimissInWindom:YES];
}


@end
