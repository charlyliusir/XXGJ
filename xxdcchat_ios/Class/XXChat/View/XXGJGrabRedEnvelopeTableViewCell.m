//
//  XXGJGrabRedEnvelopeTableViewCell.m
//  xxdcchat_ios
//
//  Created by 刘朝龙 on 2017/4/26.
//  Copyright © 2017年 刘朝龙. All rights reserved.
//

#import "XXGJGrabRedEnvelopeTableViewCell.h"
#import <UIImageView+WebCache.h>
#import "AppDelegate.h"
#import "NSDate+XXGJFormatter.h"

@interface XXGJGrabRedEnvelopeTableViewCell ()
@property (weak, nonatomic) IBOutlet UIImageView *userIconImageView;
@property (weak, nonatomic) IBOutlet UILabel *userNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *userGrabTimeLabel;
@property (weak, nonatomic) IBOutlet UIImageView *userGrabImageView;
@property (weak, nonatomic) IBOutlet UILabel *userGrabMoneyLabel;

@end

@implementation XXGJGrabRedEnvelopeTableViewCell

+ (instancetype)grabRedEnvelopeCell:(UITableView *)tableView
{
    NSString *identifier = @"grabRedEnvelope";
    XXGJGrabRedEnvelopeTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if (!cell)
    {
        cell = [[[NSBundle mainBundle] loadNibNamed:NSStringFromClass(self) owner:nil options:nil] lastObject];
    }
    return cell;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

#pragma mark - setter and getter
- (void)setGrapRedEnvelopeItem:(XXGJGrabRedEnvelopeItem *)grapRedEnvelopeItem
{
    _grapRedEnvelopeItem = grapRedEnvelopeItem;
    // 设置用户头像
    [self.userIconImageView sd_setImageWithURL:[NSURL URLWithString:grapRedEnvelopeItem.grapUserEntity.userIcon]
                              placeholderImage:[UIImage imageNamed:@"placeholder_user_male_icon-98"]];
    // 设置用户名称
    [self.userNameLabel setText:grapRedEnvelopeItem.grapUserEntity.NickName];
    // 设置用户抢红包的时间
    NSString *dateTimeString = [[NSDate datesinceTimeInterval:[grapRedEnvelopeItem.grapDeliveryItem.updateTime longLongValue]] dateForDateFormatter:@"MM-dd HH:mm"];
    [self.userGrabTimeLabel setText:dateTimeString];
    // 设置抢夺金钱数量
    [self.userGrabMoneyLabel setText:[NSString stringWithFormat:@"%.2f元", [grapRedEnvelopeItem.grapDeliveryItem.amout floatValue]]];
    
    // 判断是否是自己抢的红包
    AppDelegate *appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    [self.userGrabImageView setHidden:![appDelegate.user.user_id isEqualToNumber:grapRedEnvelopeItem.grapUserEntity.ID]];
    
}

#pragma mark - private

@end
