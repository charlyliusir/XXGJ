//
//  XXGJChatItemTableViewCell.m
//  xxdcchat_ios
//
//  Created by 刘朝龙 on 2017/3/16.
//  Copyright © 2017年 刘朝龙. All rights reserved.
//

#import "XXGJChatItemTableViewCell.h"
#import "User.h"

@interface XXGJChatItemTableViewCell ()
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *iconConstraint;
@property (weak, nonatomic) IBOutlet UIImageView *iconImageView;
@property (weak, nonatomic) IBOutlet UILabel *titleNameLabel;
@property (weak, nonatomic) IBOutlet UIButton *selectedBtn;

@end

@implementation XXGJChatItemTableViewCell

+ (instancetype)chatItemCell:(UITableView *)tableView hasSelectBtn:(BOOL)hasSelectBtn
{
    NSString *identifier = @"chatitem";
    XXGJChatItemTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if (!cell) {
        cell = [[[NSBundle mainBundle] loadNibNamed:NSStringFromClass(self) owner:nil options:nil] lastObject];
    }
    if (hasSelectBtn)
    {
        [cell.selectedBtn setHidden:NO];
        [cell.iconConstraint setConstant:42.0f];
    }else
    {
        [cell.selectedBtn setHidden:YES];
        [cell.iconConstraint setConstant:10.0f];
    }
    return cell;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    
}

#pragma mark - property setter

- (void)setChatItem:(XXGJChatItem *)chatItem
{
    _chatItem = chatItem;
    
    if (_chatItem.iconName)
    {
        [_iconImageView setImage:[UIImage imageNamed:_chatItem.iconName]];
    }
    if (_chatItem.iconURL)
    {
        [_iconImageView sd_setImageWithURL:[NSURL URLWithString:[XXGJ_N_BASE_IMAGE_URL  stringByAppendingString:_chatItem.iconURL]] placeholderImage:[UIImage imageNamed:@"placeholder_user_male_icon-98"]];
    }
    [_selectedBtn setSelected:_chatItem.isSelected];
    [_titleNameLabel  setText:_chatItem.titleName];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
