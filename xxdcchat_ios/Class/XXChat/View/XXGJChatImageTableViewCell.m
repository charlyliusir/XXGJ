//
//  XXGJChatImageTableViewCell.m
//  xxdcchat_ios
//
//  Created by 刘朝龙 on 2017/3/22.
//  Copyright © 2017年 刘朝龙. All rights reserved.
//

#import "XXGJChatImageTableViewCell.h"
#import "Args.h"

@interface XXGJChatImageTableViewCell ()

@property (nonatomic, strong)UIImageView *imageContentView;
@property (nonatomic, strong)UIView  *maskView;
@property (nonatomic, strong)UILabel *maskProgressLabel;
@property (nonatomic, assign)CGFloat cHeight;
@property (nonatomic, assign)CGFloat cWidth;

@end

@implementation XXGJChatImageTableViewCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        /** 创建图片*/
        self.imageContentView = [[UIImageView alloc] initWithFrame:CGRectZero];
        [self.imageContentView setContentMode:UIViewContentModeScaleToFill];
        [self.contentView addSubview:self.imageContentView];
        [self.imageContentView setUserInteractionEnabled:YES];
        /** 创建遮罩和进度*/
        self.maskView = [[UIView alloc] initWithFrame:CGRectZero];
        [self.maskView setBackgroundColor:[[UIColor blackColor] colorWithAlphaComponent:0.5]];
        
        self.maskProgressLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        [self.maskProgressLabel setText:@"0.0 %"];
        [self.maskProgressLabel setTextColor:[UIColor whiteColor]];
        [self.maskProgressLabel setFont:[UIFont systemFontOfSize:20]];
        
        [self.imageContentView addSubview:self.maskView];
        [self.maskView addSubview:self.maskProgressLabel];
        
        /** 添加图片的点击事件*/
        UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(openImage:)];
        [self.imageContentView addGestureRecognizer:tapGestureRecognizer];
        
        UILongPressGestureRecognizer *longPressGestureRecognizer = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(editTextMessage:)];
        [self.imageContentView addGestureRecognizer:longPressGestureRecognizer];
    }
    
    return self;
}

+ (instancetype)chatImageCell:(UITableView *)tableView cellStyle:(ChatCellStyle)style
{
    NSString *identifier = @"chat_image_left";
    if (style == ChatCellStyleMe) {
        identifier = @"chat_image_right";
    }
    
    XXGJChatImageTableViewCell *chatImageCell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if (!chatImageCell) {
        chatImageCell = [[XXGJChatImageTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
    }
    
    return chatImageCell;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

- (NSString *)getFilePath:(NSString *)floder fileName:(NSString *)fileName
{
    /** 将图片缓存到本地*/
    NSString *imagefloder = [[NSString cacheStore] appendFileStore:floder];
    return [imagefloder stringByAppendingPathComponent:fileName];
}

/**
 点击图片进入大图模式

 @param tapGestureRecognizer 点击事件
 */
- (void)openImage:(UITapGestureRecognizer *)tapGestureRecognizer
{
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(chatTableViewCell:openImageUrl:image:)])
    {
        [self.delegate chatTableViewCell:self openImageUrl:[NSURL URLWithString:self.chatMessage.chatContent] image:self.imageContentView.image];
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
    /** 开始设置内容*/
    if ([msg.chatContent containsString:@"http://"])
    {
        [self.imageContentView sd_setImageWithURL:[NSURL URLWithString:msg.chatContent] placeholderImage:[UIImage imageNamed:@"placeholder_user_male_icon-98px"]];
    }else
    {
        NSString *fileName = [[msg.chatContent componentsSeparatedByString:@"/"] lastObject];
        [self.imageContentView setImage:[UIImage imageWithContentsOfFile:[self getFilePath:@"xx_caches_image" fileName:fileName]]];
    }
    /** 宽度缩小3倍*/
    CGFloat width  = [msg.args.bitmapWidth floatValue]/3.0f;
    CGFloat height = [msg.args.bitmapHeight floatValue]/3.0f;
    if (width <= LESS_WIDTH - 6)
    {
        self.cWidth  = width;
        self.cHeight = height;
    }
    else
    {
        self.cWidth  = LESS_WIDTH-6;
        self.cHeight = (LESS_WIDTH-6) /width * height;
        msg.cellHeight = @((LESS_WIDTH-6) /width * height);
    }
    
    /** 判断图片是否上传成功*/
    if (!msg.args.progress)
    {
        [self.maskView setHidden:YES];
    }
    else
    {
        [self.maskView setHidden:NO];
        [self.maskProgressLabel setText:[NSString stringWithFormat:@"%@ %%", msg.args.progress]];
        [self.activityIndicatorView startAnimating];
        [self.activityIndicatorView setHidden:NO];
        [self.reSendBtn setHidden:YES];
    }
    /** MARK:- 需要添加判断, 超时未上传成功*/
    
    self.chatCellStyle = msg.cellStyle;
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
//        make.width.mas_lessThanOrEqualTo(LESS_WIDTH);
        make.right.mas_equalTo(self.imageContentView).offset(1);
        make.bottom.mas_equalTo(self.imageContentView).mas_offset(1);
    }];
    
    [self.imageContentView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.height.mas_equalTo(self.cHeight);
        make.width.mas_equalTo(self.cWidth);
        make.top.mas_equalTo(self.nodeBoardImage).mas_offset(1);
        make.left.mas_equalTo(self.nodeBoardImage).mas_offset(6);
    }];
    
    [self.maskView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(self.imageContentView);
    }];
    [self.maskProgressLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.mas_equalTo(self.maskView);
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
//        make.width.mas_lessThanOrEqualTo(LESS_WIDTH);
        make.bottom.mas_equalTo(self.imageContentView).mas_offset(1);
    }];
    [self.imageContentView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.height.mas_equalTo(self.cHeight);
        make.width.mas_equalTo(self.cWidth);
        make.top.mas_equalTo(self.nodeBoardImage).mas_offset(1);
        make.right.mas_equalTo(self.nodeBoardImage).mas_offset(-6);
    }];
    
    [self.maskView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(self.imageContentView);
    }];
    [self.maskProgressLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.mas_equalTo(self.maskView);
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
