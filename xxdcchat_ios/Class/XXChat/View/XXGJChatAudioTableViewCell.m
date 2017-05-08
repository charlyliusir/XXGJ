//
//  XXGJChatAudioTableViewCell.m
//  xxdcchat_ios
//
//  Created by 刘朝龙 on 2017/4/12.
//  Copyright © 2017年 刘朝龙. All rights reserved.
//

#import "XXGJChatAudioTableViewCell.h"
#import "Args.h"

@interface XXGJChatAudioTableViewCell ()

@property (nonatomic, strong)UIImageView *audioIconImageView;
@property (nonatomic, strong)UILabel *audioTimeLabel;

@property (nonatomic, strong)NSTimer *animationTimer;
@property (nonatomic, assign)NSInteger flag;

@end

@implementation XXGJChatAudioTableViewCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier])
    {
        /** 图标*/
        self.audioIconImageView = [[UIImageView alloc] initWithFrame:CGRectZero];
        [self.nodeBoardImage addSubview:self.audioIconImageView];
        /** 时间长度*/
        self.audioTimeLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        [self.audioTimeLabel setText:@""];
        [self.audioTimeLabel setFont:[UIFont systemFontOfSize:14]];
        [self.contentView addSubview:self.audioTimeLabel];
        
        [self.nodeBoardImage setUserInteractionEnabled:YES];
        [self.audioIconImageView setUserInteractionEnabled:YES];
        
        /** 添加点击手势*/
        UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapAction:)];
        [self.nodeBoardImage addGestureRecognizer:tapGestureRecognizer];
    }
    
    return self;
}

+ (instancetype)chatAudioCell:(UITableView *)tableView cellStyle:(ChatCellStyle)style
{
    NSString *identifier = @"chat_audio_left";
    
    if (style == ChatCellStyleMe)
    {
        identifier = @"chat_audio_right";
    }
    
    XXGJChatAudioTableViewCell *chatAudioCell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if (!chatAudioCell) {
        chatAudioCell = [[XXGJChatAudioTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
    }
    return chatAudioCell;
}

#pragma mark - lazy method
- (NSTimer *)animationTimer
{
    if (!_animationTimer)
    {
        __weak typeof(self)weakSelf = self;
        _animationTimer = [NSTimer timerWithTimeInterval:1.0 repeats:YES block:^(NSTimer * _Nonnull timer) {
            __strong typeof(weakSelf)strongSelf = weakSelf;
            strongSelf.flag ++;
            if (strongSelf.chatCellStyle == ChatCellStyleMe)
            {
                [strongSelf.audioIconImageView setImage:[UIImage imageNamed:[self audioIconImageViewName:@"SenderVoiceNodePlaying" flag:strongSelf.flag]]];
            }else
            {
                [strongSelf.audioIconImageView setImage:[UIImage imageNamed:[self audioIconImageViewName:@"ReceiverVoiceNodePlaying" flag:strongSelf.flag]]];
            }
        }];
    }
    return _animationTimer;
}

#pragma mark - open method
- (void)startPlayAnimation
{
    if (_animationTimer)
    {
        [_animationTimer invalidate];
        _animationTimer = nil;
    }
    
    _flag = 0;
    
    [[NSRunLoop currentRunLoop] addTimer:self.animationTimer forMode:NSRunLoopCommonModes];
}

- (void)stopPlayAnimation
{
    if (_animationTimer)
    {
        [_animationTimer invalidate];
        _animationTimer = nil;
    }
    
    _flag = 0;
    
    if (self.chatCellStyle == ChatCellStyleMe)
    {
        [self.audioIconImageView setImage:[UIImage imageNamed:@"SenderVoiceNodePlaying"]];
    }else
    {
        [self.audioIconImageView setImage:[UIImage imageNamed:@"ReceiverVoiceNodePlaying"]];
    }
}

- (NSString *)audioIconImageViewName:(NSString *)imageName flag:(NSInteger)flag
{
    NSMutableString *audioIconName = imageName.mutableCopy;
    NSInteger residue = flag % 3;
    if (residue != 0)
    {
        [audioIconName appendFormat:@"00%ld", (long)residue];
    }
    return audioIconName.copy;
}

#pragma mark - tap action
- (void)tapAction:(UITapGestureRecognizer *)tapGestureRecognizer
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(chatTableViewCell:checkAudioRecord:)])
    {
        [self.delegate chatTableViewCell:self checkAudioRecord:self.chatMessage];
    }
}

- (void)editTextMessage:(UILongPressGestureRecognizer *)longPressGR
{
    [super editTextMessage:longPressGR];
    
    if (longPressGR.state == UIGestureRecognizerStateBegan)
    {
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

    [self.audioTimeLabel setText:[NSString stringWithFormat:@"%@\"", msg.args.duration]];
    
    self.chatCellStyle = msg.cellStyle;
}

- (void)layoutOtherUI
{
    [super layoutOtherUI];
    CGFloat widht = [self.chatMessage.args.duration floatValue]*2 + 48;
    if (widht > LESS_WIDTH-50)
    {
        widht = LESS_WIDTH-50;
    } else if (widht <= 100)
    {
        widht = 100;
    }
    [self.audioTimeLabel setTextColor:XX_RGBCOLOR_WITHOUTA(14,170,159)];
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
    [self.audioIconImageView setImage:[UIImage imageNamed:@"ReceiverVoiceNodePlaying"]];
    
    [self.nodeBoardImage mas_remakeConstraints:^(MASConstraintMaker *make) {
        if ([self.chatMessage.isGroup boolValue])
        {
            make.top.mas_equalTo(self.userName.mas_bottom).mas_offset(3);
        }else
        {
            make.top.mas_equalTo(self.userIconImage);
        }
        make.left.mas_equalTo(self.userIconImage.mas_right).mas_offset(5);
        make.right.mas_equalTo(self.userIconImage.mas_right).mas_offset(widht);
        make.height.mas_equalTo(40);
    }];
    [self.audioIconImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(self.nodeBoardImage);
        make.left.mas_equalTo(self.nodeBoardImage).mas_offset(20);
    }];
    
    [self.audioTimeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(self.nodeBoardImage);
        make.left.mas_equalTo(self.audioIconImageView.mas_right).mas_offset(10);
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
    
    CGFloat widht = [self.chatMessage.args.duration floatValue]*2 + 48;
    if (widht > LESS_WIDTH-50)
    {
        widht = LESS_WIDTH-50;
    }else if (widht <= 100)
    {
        widht = 100;
    }
    [self.audioTimeLabel setTextColor:XX_RGBCOLOR_WITHOUTA(43,122,117)];
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
    [self.audioIconImageView setImage:[UIImage imageNamed:@"SenderVoiceNodePlaying"]];
    
    [self.nodeBoardImage mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.userIconImage);
        make.right.mas_equalTo(self.userIconImage.mas_left).mas_offset(-5);
        make.left.mas_equalTo(self.userIconImage.mas_left).mas_offset(-widht);
        make.height.mas_equalTo(40);
    }];
    
    [self.audioTimeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(self.nodeBoardImage);
        make.right.mas_equalTo(self.audioIconImageView.mas_left).mas_offset(-10);
    }];
    
    [self.audioIconImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(self.nodeBoardImage);
        make.right.mas_equalTo(self.nodeBoardImage).mas_offset(-20);
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
/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
