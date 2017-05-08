//
//  XXGJChatTextTableViewCell.m
//  xxdcchat_ios
//
//  Created by 刘朝龙 on 2017/3/19.
//  Copyright © 2017年 刘朝龙. All rights reserved.
//

#import "XXGJChatTextTableViewCell.h"
#import "NSString+IMEx.h"
#import "Group.h"
#import "User.h"

@interface XXGJChatTextTableViewCell ()

@property (nonatomic, strong)UILabel *messageLabel;

@end

@implementation XXGJChatTextTableViewCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        self.messageLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        [self.messageLabel setFont:[UIFont systemFontOfSize:16]];
        [self.messageLabel setText:@"这是一条测试消息"];
        [self.messageLabel setTextColor:XX_NAVIGATIONBAR_TITLECOLOR];
        [self.messageLabel setNumberOfLines:0];
        [self.messageLabel setLineBreakMode:NSLineBreakByWordWrapping];
        [self.nodeBoardImage addSubview:self.messageLabel];
        [self.nodeBoardImage setUserInteractionEnabled:YES];

    }
    
    return self;
}

+ (instancetype)chatTextCell:(UITableView *)tableView cellStyle:(ChatCellStyle)style
{
    NSString *identifier = @"chat_text_left";
    if (style == ChatCellStyleMe) {
        identifier = @"chat_text_right";
    }
    
    XXGJChatTextTableViewCell *chatTextCell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if (!chatTextCell) {
        chatTextCell = [[XXGJChatTextTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
    }
    
    return chatTextCell;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    
    // Configure the view for the selected state
}

- (void)editTextMessage:(UILongPressGestureRecognizer *)longPressGR
{
    [super editTextMessage:longPressGR];
    
    if (longPressGR.state == UIGestureRecognizerStateBegan)
    {
        UIMenuItem *itCopy = [[UIMenuItem alloc] initWithTitle:@"复制" action:@selector(copyItemClicked:)];
        [self.menuItemArray addObject:itCopy];
        
        UIMenuController *menu = [UIMenuController sharedMenuController];
        [menu setMenuItems:self.menuItemArray];
        [menu setTargetRect:self.nodeBoardImage.frame inView:self];
        [menu setMenuVisible:YES animated:YES];
    }
}

#pragma mark -
- (void)setMessage:(XXGJChatMessage *)msg
{
    [super setMessage:msg];
    /** 开始设置内容*/
        
    [self.messageLabel setText:msg.chatContent];
    
    self.chatCellStyle = msg.cellStyle;
    
    [self layoutIfNeeded];
    msg.cellHeight = @(self.height);
}

- (void)layoutOtherUI
{
    [super layoutOtherUI];
    
    /** 设置气泡*/
    UIImage *image = [UIImage imageNamed:@"receiver_image_node_border"];
    CGFloat top = 35; // 顶端盖高度
    CGFloat bottom = 35 ; // 底端盖高度
    CGFloat left = 10; // 左端盖宽度
    CGFloat right = 10; // 右端盖宽度
    UIEdgeInsets insets = UIEdgeInsetsMake(top, left, bottom, right);
    // 指定为拉伸模式，伸缩后重新赋值
    image = [image resizableImageWithCapInsets:insets resizingMode:UIImageResizingModeStretch];
    [self.nodeBoardImage setImage:image];
    
    CGFloat height = [self.chatMessage.chatContent changeStationWidthTxtt:LESS_WIDTH-36.5 anfont:16];
    
    [self.nodeBoardImage mas_remakeConstraints:^(MASConstraintMaker *make) {
        if ([self.chatMessage.isGroup boolValue])
        {
            make.top.mas_equalTo(self.userName.mas_bottom).mas_offset(3);
        }else
        {
            make.top.mas_equalTo(self.userIconImage);
        }
        make.left.mas_equalTo(self.userIconImage.mas_right).mas_offset(5);
        make.right.mas_equalTo(self.messageLabel).offset(15);
        make.width.mas_lessThanOrEqualTo(LESS_WIDTH);
        make.bottom.mas_equalTo(self.messageLabel).mas_offset(14);
    }];
    
    [self.messageLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.nodeBoardImage).mas_offset(20);
        make.top.mas_equalTo(self.nodeBoardImage).mas_equalTo(10);
        make.height.mas_equalTo(height);
    }];
    if (self.chatMessage.ishiddenTimeView)
    {
        [self.timeContentView setHidden:YES];
        [self.userIconImage mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(self.contentView);
            make.left.mas_offset(10);
            make.height.mas_equalTo(CHAT_USERICON_HEIGHT);
            make.width.mas_equalTo(CHAT_USERICON_WIDTH);
        }];
    }else
    {
        [self.timeContentView setHidden:NO];
        [self.userIconImage mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(self.timeContentView.mas_bottom).mas_offset(25);
            make.left.mas_offset(10);
            make.height.mas_equalTo(CHAT_USERICON_HEIGHT);
            make.width.mas_equalTo(CHAT_USERICON_WIDTH);
        }];
        [self.timeLabel setText:[NSDate dateForSpecString:[self.chatMessage.chatTime longLongValue]]];
    }
}

- (void)layoutMeUI
{
    [super layoutMeUI];
    
    /** 设置气泡*/
    UIImage *image = [UIImage imageNamed:@"sender_image_node_border"];
    CGFloat top = 35; // 顶端盖高度
    CGFloat bottom = 35 ; // 底端盖高度
    CGFloat left = 10; // 左端盖宽度
    CGFloat right = 10; // 右端盖宽度
    UIEdgeInsets insets = UIEdgeInsetsMake(top, left, bottom, right);
    // 指定为拉伸模式，伸缩后重新赋值
    image = [image resizableImageWithCapInsets:insets resizingMode:UIImageResizingModeStretch];
    [self.nodeBoardImage setImage:image];
    CGFloat height = [self.chatMessage.chatContent changeStationWidthTxtt:LESS_WIDTH-36.5 anfont:16];
    
    [self.nodeBoardImage mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.userIconImage);
        make.right.mas_equalTo(self.userIconImage.mas_left).mas_offset(-5);
        make.left.mas_equalTo(self.messageLabel).offset(-15);
        make.width.mas_lessThanOrEqualTo(LESS_WIDTH);
        make.bottom.mas_equalTo(self.messageLabel).mas_offset(14);
    }];
    
    [self.messageLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.nodeBoardImage).offset(10);
        make.right.mas_equalTo(self.nodeBoardImage).offset(-20);
//        make.height.mas_equalTo(height);
    }];
    if (self.chatMessage.ishiddenTimeView)
    {
        [self.timeContentView setHidden:YES];
        [self.userIconImage mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(self.contentView);
            make.right.mas_offset(-10);
            make.height.mas_equalTo(CHAT_USERICON_HEIGHT);
            make.width.mas_equalTo(CHAT_USERICON_WIDTH);
        }];
    }else
    {
        [self.timeContentView setHidden:NO];
        [self.userIconImage mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(self.timeContentView.mas_bottom).mas_offset(25);
            make.right.mas_offset(-10);
            make.height.mas_equalTo(CHAT_USERICON_HEIGHT);
            make.width.mas_equalTo(CHAT_USERICON_WIDTH);
        }];
        [self.timeLabel setText:[NSDate dateForSpecString:[self.chatMessage.chatTime longLongValue]]];
    }
}

@end
