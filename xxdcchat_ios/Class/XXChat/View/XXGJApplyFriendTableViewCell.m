//
//  XXGJApplyFriendTableViewCell.m
//  xxdcchat_ios
//
//  Created by 刘朝龙 on 2017/4/24.
//  Copyright © 2017年 刘朝龙. All rights reserved.
//

#import "XXGJApplyFriendTableViewCell.h"
#import <UIImageView+WebCache.h>

static NSString *applyFriendIdentify = @"applyFriendCell";

@interface XXGJApplyFriendTableViewCell ()
@property (weak, nonatomic) IBOutlet UIImageView *userIconImageView;
@property (weak, nonatomic) IBOutlet UILabel *userNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *userContentLabel;
@property (weak, nonatomic) IBOutlet UIButton *applyFriendBtn;
@property (weak, nonatomic) IBOutlet UIView *bottomLineView;

@end

@implementation XXGJApplyFriendTableViewCell

+ (instancetype)applyFriendTableViewCell:(UITableView *)tableView
{
    XXGJApplyFriendTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:applyFriendIdentify];
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

- (void)setApplyFriendItem:(XXGJApplyFriendItem *)applyFriendItem
{
    _applyFriendItem = applyFriendItem;
    NSString *userIcon = applyFriendItem.userIconUrl;
    if (userIcon)
    {
        [self.userIconImageView sd_setImageWithURL:[NSURL URLWithString:applyFriendItem.userIconUrl] placeholderImage:[UIImage imageNamed:@"placeholder_user_male_icon-98px"]];
    }else
    {
        [self.userIconImageView setImage:[UIImage imageNamed:@"placeholder_user_male_icon-98px"]];
    }
    
    [self.userNameLabel setText:applyFriendItem.userNickName];
    [self.userContentLabel setText:applyFriendItem.userApplyContent];
    [self.applyFriendBtn setEnabled:!applyFriendItem.isMyFriend];
}

- (void)setLastCell:(BOOL)lastCell
{
    _lastCell = lastCell;
    
    [self.bottomLineView setHidden:!lastCell];
}

#pragma mark - private
- (IBAction)applyUserFriend:(id)sender
{
    /** 同意添加好友*/
    if (self.delegate && [self.delegate respondsToSelector:@selector(agreeApplyFriendMessage:)])
    {
        [self.delegate agreeApplyFriendMessage:self.applyMessage];
    }
}

@end
