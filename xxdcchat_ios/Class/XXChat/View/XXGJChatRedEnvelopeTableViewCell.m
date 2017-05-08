//
//  XXGJChatRedEnvelopeTableViewCell.m
//  xxdcchat_ios
//
//  Created by 刘朝龙 on 2017/4/18.
//  Copyright © 2017年 刘朝龙. All rights reserved.
//

#import "XXGJChatRedEnvelopeTableViewCell.h"
#import "Args.h"

@interface XXGJChatRedEnvelopeTableViewCell ()

@property (nonatomic, strong)UIImageView *imageContentView;
@property (nonatomic, strong)UIImageView *redIconImageView;
@property (nonatomic, strong)UILabel *rTitleLabel;
@property (nonatomic, strong)UILabel *rSubTitleLabel;
@property (nonatomic, strong)UILabel *rRedOwnerLabel;

@end

@implementation XXGJChatRedEnvelopeTableViewCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        /** 创建图片*/
        self.imageContentView = [[UIImageView alloc] initWithFrame:CGRectZero];
        [self.imageContentView setImage:[UIImage imageNamed:@"red_envelope_icon_bg_02"]];
        [self.imageContentView setContentMode:UIViewContentModeScaleToFill];
        [self.contentView addSubview:self.imageContentView];
        /** */
        self.redIconImageView = [[UIImageView alloc] initWithFrame:CGRectZero];
        [self.redIconImageView setImage:[UIImage imageNamed:@"red_envelope_icon_open_img"]];
        [self.redIconImageView setContentMode:UIViewContentModeScaleToFill];
        [self.contentView addSubview:self.redIconImageView];
        /** title*/
        self.rTitleLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        [self.rTitleLabel setText:@"恭喜发财，万事大吉"];
        [self.rTitleLabel setTextColor:[UIColor whiteColor]];
        [self.rTitleLabel setFont:[UIFont systemFontOfSize:15]];
        [self.contentView addSubview:self.rTitleLabel];
        /** sub title*/
        self.rSubTitleLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        [self.rSubTitleLabel setText:@"领取红包"];
        [self.rSubTitleLabel setTextColor:XX_RGBCOLOR_WITHOUTA(255, 233, 233)];
        [self.rSubTitleLabel setFont:[UIFont systemFontOfSize:12]];
        [self.contentView addSubview:self.rSubTitleLabel];
        /** red owner*/
        self.rRedOwnerLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        [self.rRedOwnerLabel setText:@"领取红包"];
        [self.rRedOwnerLabel setTextColor:XX_RGBCOLOR_WITHOUTA(153, 153, 153)];
        [self.rRedOwnerLabel setFont:[UIFont systemFontOfSize:11]];
        [self.contentView addSubview:self.rRedOwnerLabel];
        
        /** 添加图片的点击事件*/
        [self.imageContentView setUserInteractionEnabled:YES];
        UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(openRedEnvelope:)];
        [self.imageContentView addGestureRecognizer:tapGestureRecognizer];
        
        [self.redIconImageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(self.imageContentView).mas_offset(12);
            make.top.mas_equalTo(self.imageContentView).mas_equalTo(12);
        }];
        [self.rTitleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(self.redIconImageView);
            make.left.mas_equalTo(self.redIconImageView.mas_right).mas_offset(12);
        }];
        [self.rSubTitleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(self.rTitleLabel);
            make.top.mas_equalTo(self.rTitleLabel.mas_bottom).mas_offset(9);
        }];
        [self.rRedOwnerLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(self.redIconImageView);
            make.bottom.mas_equalTo(self.imageContentView).mas_offset(-4);
        }];
    }
    
    return self;
}

+ (instancetype)chatRedEnvelopeCell:(UITableView *)tableView cellStyle:(ChatCellStyle)style
{
    NSString *identifier = @"chat_red_left";
    if (style == ChatCellStyleMe) {
        identifier = @"chat_red_right";
    }
    
    XXGJChatRedEnvelopeTableViewCell *chatRedEnvelopeCell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if (!chatRedEnvelopeCell) {
        chatRedEnvelopeCell = [[XXGJChatRedEnvelopeTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
    }
    
    return chatRedEnvelopeCell;
}

/*
 // Only override drawRect: if you perform custom drawing.
 // An empty implementation adversely affects performance during animation.
 - (void)drawRect:(CGRect)rect {
 // Drawing code
 }
 */

/**
 点击抢红包
 
 @param tapGestureRecognizer 点击事件
 */
- (void)openRedEnvelope:(UITapGestureRecognizer *)tapGestureRecognizer
{
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(chatTableViewCell:openRedEnvelope:)])
    {
        [self.delegate chatTableViewCell:self openRedEnvelope:self.chatMessage];
    }
}

#pragma mark -
- (void)setMessage:(XXGJChatMessage *)msg
{
    [super setMessage:msg];
    /** 开始设置内容*/
    [self.rRedOwnerLabel setText:[NSString stringWithFormat:@"%@的红包",msg.userName]];
    
    self.chatCellStyle = msg.cellStyle;
    
    [self layoutIfNeeded];
    
    msg.cellHeight = @(self.height);
}

- (void)layoutOtherUI
{
    [super layoutOtherUI];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        /** 设置气泡*/
        CAShapeLayer *layer = [CAShapeLayer layer];
        
        layer.frame = self.imageContentView.bounds;
        layer.contents = (id)[UIImage imageNamed:@"receiver_image_node_border"].CGImage;
        layer.contentsCenter = CGRectMake(0.5, 0.7, 0.1, 0.1);
        layer.contentsScale = [UIScreen mainScreen].scale;
        
        self.imageContentView.layer.mask = layer;
        self.imageContentView.layer.frame = self.imageContentView.frame;
    });
    
    [self.nodeBoardImage mas_remakeConstraints:^(MASConstraintMaker *make) {
        if ([self.chatMessage.isGroup boolValue])
        {
            make.top.mas_equalTo(self.userName.mas_bottom).mas_offset(3);
        }else
        {
            make.top.mas_equalTo(self.userIconImage);
        }
        make.left.mas_equalTo(self.userIconImage.mas_right).mas_offset(5);
        make.right.mas_equalTo(self.imageContentView).offset(1);
        make.bottom.mas_equalTo(self.imageContentView).mas_offset(1);
    }];
    
    [self.imageContentView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.nodeBoardImage).mas_offset(1);
        make.left.mas_equalTo(self.nodeBoardImage).mas_offset(6);
    }];
    [self.redIconImageView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.imageContentView).mas_offset(17);
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
    
    dispatch_async(dispatch_get_main_queue(), ^{
        /** 设置气泡*/
        CAShapeLayer *layer = [CAShapeLayer layer];
        
        layer.frame = self.imageContentView.bounds;
        layer.contents = (id)[UIImage imageNamed:@"sender_image_node_border"].CGImage;
        layer.contentsCenter = CGRectMake(0.5, 0.7, 0.1, 0.1);
        layer.contentsScale = [UIScreen mainScreen].scale;
        
        self.imageContentView.layer.mask = layer;
        self.imageContentView.layer.frame = self.imageContentView.frame;
    });
    
    [self.nodeBoardImage mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.userIconImage);
        make.right.mas_equalTo(self.userIconImage.mas_left).mas_offset(-1);
        make.left.mas_equalTo(self.imageContentView).offset(-1);
        make.bottom.mas_equalTo(self.imageContentView).mas_offset(1);
    }];
    [self.imageContentView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.nodeBoardImage).mas_offset(1);
        make.right.mas_equalTo(self.nodeBoardImage).mas_offset(-6);
    }];
    [self.redIconImageView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.imageContentView).mas_offset(12);
    }];
    
    [self.maskView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(self.imageContentView);
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
