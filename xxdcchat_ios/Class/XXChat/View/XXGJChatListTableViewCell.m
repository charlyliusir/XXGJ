//
//  XXGJChatListTableViewCell.m
//  xxdcchat_ios
//
//  Created by 刘朝龙 on 2017/3/16.
//  Copyright © 2017年 刘朝龙. All rights reserved.
//

#import "XXGJChatListTableViewCell.h"

@interface XXGJChatListTableViewCell ()
@property (weak, nonatomic) IBOutlet UIImageView *iconImageView;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *messageLabel;
@property (weak, nonatomic) IBOutlet UILabel *timeLabel;
@property (weak, nonatomic) IBOutlet UIImageView *chatNotPushImageView;
@property (weak, nonatomic) IBOutlet UIImageView *chatRedPointViewImage;
@property (weak, nonatomic)IBOutlet UILabel *countLabel;
@end

@implementation XXGJChatListTableViewCell

+ (instancetype)chatItemListCell:(UITableView *)tableView
{
    NSString *identifier = @"chatlist";
    XXGJChatListTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if (!cell) {
        cell = [[[NSBundle mainBundle] loadNibNamed:NSStringFromClass(self) owner:nil options:nil] lastObject];
    }
    return cell;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

#pragma mark - property setter
- (void)setChatItemList:(XXGJChatItemList *)chatItemList
{
    _chatItemList = chatItemList;
    
    if (_chatItemList.iconName)
    {
        [_iconImageView setImage:[UIImage imageNamed:_chatItemList.iconName]];
    }
    if (_chatItemList.iconURL)
    {
        [_iconImageView sd_setImageWithURL:[NSURL URLWithString:[XXGJ_N_BASE_IMAGE_URL  stringByAppendingString:_chatItemList.iconURL]] placeholderImage:[UIImage imageNamed:@"placeholder_user_male_icon-98"]];
    }else
    {
        [_iconImageView setImage:[UIImage imageNamed:@"system_icon"]];
    }
    [_titleLabel setText:_chatItemList.nameTitle];
    [_messageLabel setText:_chatItemList.infoTitle];
    [_timeLabel setText:_chatItemList.timeTitle];
    
    [_chatNotPushImageView setHidden:!_chatItemList.avoidRemind];
    
    if (_chatItemList.newMessageCount>0) {
        [self setNewMessageUI:_chatItemList.newMessageCount];
    }else{
        [self.countLabel setHidden:YES];
        [self.chatRedPointViewImage setHidden:YES];
    }
    
}

- (void)setNewMessageUI:(NSInteger)count
{
    [self.countLabel setHidden:NO];
    [self.chatRedPointViewImage setHidden:NO];
    
    if (count>999) {
        [self.countLabel setText:[NSString stringWithFormat:@"999+"]];
    }else{
        [self.countLabel setText:[NSString stringWithFormat:@"%ld", count]];
    }
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
