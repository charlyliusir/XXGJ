//
//  XXGJChatGroupTableViewCell.m
//  xxdcchat_ios
//
//  Created by 刘朝龙 on 2017/3/18.
//  Copyright © 2017年 刘朝龙. All rights reserved.
//

#import "XXGJChatGroupTableViewCell.h"
#import <UIImageView+WebCache.h>

@interface XXGJChatGroupTableViewCell()
@property (weak, nonatomic) IBOutlet UIImageView *iconImageView;
@property (weak, nonatomic) IBOutlet UILabel *groupNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *groupIdLabel;


@end

@implementation XXGJChatGroupTableViewCell
+ (instancetype)chatGroupItemListCell:(UITableView *)tableView
{
    NSString *identifier = @"chatgroup";
    XXGJChatGroupTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if (!cell) {
        cell = [[[NSBundle mainBundle] loadNibNamed:NSStringFromClass(self) owner:nil options:nil] lastObject];
    }
    return cell;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setChatGroupItem:(XXGJChatGroupItem *)chatGroupItem
{
    _chatGroupItem = chatGroupItem;
    
    if (_chatGroupItem.iconURL)
    {
        [_iconImageView sd_setImageWithURL:[NSURL URLWithString:[XXGJ_N_BASE_IMAGE_URL  stringByAppendingString:_chatGroupItem.iconURL]] placeholderImage:[UIImage imageNamed:@"chat_icon_new_friend"]];
    }
    [_groupNameLabel setText:_chatGroupItem.groupName];
    [_groupIdLabel setText:[NSString stringWithFormat:@"%@", _chatGroupItem.groupId]];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
