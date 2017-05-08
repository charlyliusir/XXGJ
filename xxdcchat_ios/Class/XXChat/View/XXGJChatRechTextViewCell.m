//
//  XXGJChatRechTextViewCell.m
//  xxdcchat_ios
//
//  Created by 刘朝龙 on 2017/4/5.
//  Copyright © 2017年 刘朝龙. All rights reserved.
//

#import "XXGJChatRechTextViewCell.h"
#import <MediaPlayer/MediaPlayer.h>

#import "DTCoreText.h"
#import "DTCSSStylesheet.h"

#import <DTCoreText/DTWebVideoView.h>
#import <DTFoundation/DTLog.h>
#import "Args.h"

@interface XXGJChatRechTextViewCell () <DTAttributedTextContentViewDelegate>

@property (nonatomic, strong)DTAttributedTextContentView *attributedTextContextView;
@property (nonatomic, strong)NSMutableSet *mediaPlayers;
@property (nonatomic, assign)CGFloat cHeight;
@property (nonatomic, assign)CGFloat cWidth;
@property (nonatomic, assign)CGFloat cNeedHeight;

@end

@implementation XXGJChatRechTextViewCell
{
    NSUInteger _htmlHash; // preserved hash to avoid relayouting for same HTML
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        /** 创建富文本视图*/
        _attributedTextContextView = [[DTAttributedTextContentView alloc] initWithFrame:CGRectZero];
        [_attributedTextContextView setBackgroundColor:[UIColor clearColor]];
        [_attributedTextContextView setDelegate:self];
        [self.contentView addSubview:_attributedTextContextView];
        
        UILongPressGestureRecognizer *longPressGestureRecognizer = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(editTextMessage:)];
        [_attributedTextContextView addGestureRecognizer:longPressGestureRecognizer];
    }
    
    return self;
}

+ (instancetype)chatRechTextCell:(UITableView *)tableView cellStyle:(ChatCellStyle)style
{
    NSString *identifier = @"chat_rech_left";
    if (style == ChatCellStyleMe) {
        identifier = @"chat_rech_right";
    }
    
    XXGJChatRechTextViewCell *chatImageCell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if (!chatImageCell) {
        chatImageCell = [[XXGJChatRechTextViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
    }
    /** 将cell中的各项参数清空*/
    chatImageCell.cWidth = 0.0f;
    chatImageCell.cHeight = 0.0f;
    chatImageCell.cNeedHeight = 0.0f;
    return chatImageCell;
}

#pragma mark -- setter and getter
- (void)setAttributedString:(NSAttributedString *)attributedString
{
    // passthrough
    self.attributedTextContextView.attributedString = attributedString;
}

- (NSAttributedString *)attributedString
{
    // passthrough
    return _attributedTextContextView.attributedString;
}

#pragma mark - lazy method
- (NSMutableSet *)mediaPlayers
{
    if (!_mediaPlayers)
    {
        _mediaPlayers = [[NSMutableSet alloc] init];
    }
    
    return _mediaPlayers;
}



- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
    
    // Configure the view for the selected state
}
#pragma mark - private method
- (CGFloat)requiredRowHeight
{
    CGFloat width = self.cWidth!=0?self.cWidth:LESS_WIDTH-6;
    
    /** 图片的宽度*/
    CGSize neededSize = [self.attributedTextContextView suggestedFrameSizeToFitEntireStringConstraintedToWidth:width];
    
    // note: non-integer row heights caused trouble < iOS 5.0
    return neededSize.height + self.cHeight;
}

- (void)setHTMLString:(NSString *)html
{
    [self setHTMLString:html options:nil];
}

- (void) setHTMLString:(NSString *)html options:(NSDictionary*) options {
    
    NSUInteger newHash = [html hash];
    
    if (newHash == _htmlHash)
    {
        return;
    }
    
    _htmlHash = newHash;
    
    NSData *data = [html dataUsingEncoding:NSUTF8StringEncoding];
    NSAttributedString *string = [[NSAttributedString alloc] initWithHTMLData:data options:options documentAttributes:NULL];
    self.attributedString = string;
    
}

#pragma mark - click method->cell delegate
- (void)linkPushed:(DTLinkButton *)btn
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(chatTableViewCell:checkLinkUrl:)])
    {
        [self.delegate chatTableViewCell:self checkLinkUrl:btn.URL];
    }
}

- (void)linkLongPressed:(DTLinkButton *)btn
{
    
}

- (void)openImage:(UITapGestureRecognizer *)tapGestureRecognizer
{
    if (self.chatMessage.args.latitude&&self.chatMessage.args.longitude)
    {
        if (self.delegate && [self.delegate respondsToSelector:@selector(chatTableViewCell:openMapLocation:)])
        {
            [self.delegate chatTableViewCell:self openMapLocation:self.chatMessage.args];
        }
    }
    else
    {
        if (self.delegate && [self.delegate respondsToSelector:@selector(chatTableViewCell:openImageUrl:image:)])
        {
            UIImageView *imgView = (UIImageView *)tapGestureRecognizer.view;
            [self.delegate chatTableViewCell:self openImageUrl:nil image:imgView.image];
        }
    }
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
    if (msg.args.bitmapWidth&&msg.args.bitmapHeight)
    {
        /** 宽度缩小3倍*/
        CGFloat width  = [msg.args.bitmapWidth floatValue]/3.0f;
        CGFloat height = [msg.args.bitmapHeight floatValue]/3.0f;
        if (width <= LESS_WIDTH - 35)
        {
            self.cWidth  = width;
            self.cHeight = height;
        }
        else
        {
            self.cWidth  = LESS_WIDTH-35;
            self.cHeight = (LESS_WIDTH-35) /width * height;
        }
    }
    
    [self setHTMLString:msg.chatContent options:@{DTDefaultFontSize:@(16), DTDefaultLinkColor:XX_NAVIGATIONBAR_TITLECOLOR}];
    
    /** 需要的高度*/
    if (self.cNeedHeight==0)
    {
        self.cNeedHeight = [self requiredRowHeight];
    }
    
    self.chatCellStyle = msg.cellStyle;
    
    [self layoutIfNeeded];
    
    self.chatMessage.cellHeight = @(self.height);
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
    
    [self.nodeBoardImage mas_remakeConstraints:^(MASConstraintMaker *make) {
        if ([self.chatMessage.isGroup boolValue]&&self.chatMessage.businessType!=XXGJBusinessSystem)
        {
            make.top.mas_equalTo(self.userName.mas_bottom).mas_offset(3);
        }else
        {
            make.top.mas_equalTo(self.userIconImage);
        }
        make.left.mas_equalTo(self.userIconImage.mas_right).mas_offset(5);
        make.width.mas_lessThanOrEqualTo(LESS_WIDTH);
        make.right.mas_equalTo(_attributedTextContextView).offset(15);
        make.height.mas_equalTo(_cNeedHeight+20);
    }];
    
    [_attributedTextContextView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.height.mas_equalTo(self.cNeedHeight);
        make.width.mas_equalTo(self.cWidth);
        make.top.mas_equalTo(self.nodeBoardImage).mas_offset(10);
        make.left.mas_equalTo(self.nodeBoardImage).mas_offset(20);
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
    
    [self.nodeBoardImage mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.userIconImage);
        make.right.mas_equalTo(self.userIconImage.mas_left).mas_offset(-5);
        make.left.mas_equalTo(_attributedTextContextView).offset(-15);
        make.width.mas_lessThanOrEqualTo(LESS_WIDTH);
        make.height.mas_equalTo(_cNeedHeight+20);
    }];
    
    [_attributedTextContextView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.height.mas_equalTo(self.cNeedHeight);
        make.width.mas_equalTo(self.cWidth);
        make.top.mas_equalTo(self.nodeBoardImage).mas_offset(10);
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

#pragma mark - delegate
#pragma mark - attributedTextContextView delegate

- (UIView *)attributedTextContentView:(DTAttributedTextContentView *)attributedTextContentView viewForAttributedString:(NSAttributedString *)string frame:(CGRect)frame
{
    NSDictionary *attributes = [string attributesAtIndex:0 effectiveRange:NULL];
    
    NSURL *URL = [attributes objectForKey:DTLinkAttribute];
    NSString *identifier = [attributes objectForKey:DTGUIDAttribute];
    
    
    DTLinkButton *button = [[DTLinkButton alloc] initWithFrame:frame];
    button.URL = URL;
    button.minimumHitSize = CGSizeMake(25, 25); // adjusts it's bounds so that button is always large enough
    button.GUID = identifier;
    
    // get image with normal link text
    UIImage *normalImage = [attributedTextContentView contentImageWithBounds:frame options:DTCoreTextLayoutFrameDrawingDefault];
    [button setImage:normalImage forState:UIControlStateNormal];
    
    // get image for highlighted link text
    UIImage *highlightImage = [attributedTextContentView contentImageWithBounds:frame options:DTCoreTextLayoutFrameDrawingDrawLinksHighlighted];
    [button setImage:highlightImage forState:UIControlStateHighlighted];
    
    // use normal push action for opening URL
    [button addTarget:self action:@selector(linkPushed:) forControlEvents:UIControlEventTouchUpInside];
    
    // demonstrate combination with long press
    UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(linkLongPressed:)];
    [button addGestureRecognizer:longPress];
    
    return button;
}

- (UIView *)attributedTextContentView:(DTAttributedTextContentView *)attributedTextContentView viewForAttachment:(DTTextAttachment *)attachment frame:(CGRect)frame
{
    if ([attachment isKindOfClass:[DTVideoTextAttachment class]])
    {
        NSURL *url = (id)attachment.contentURL;
        
        // we could customize the view that shows before playback starts
        UIView *grayView = [[UIView alloc] initWithFrame:frame];
        grayView.backgroundColor = [DTColor blackColor];
        
        // find a player for this URL if we already got one
        MPMoviePlayerController *player = nil;
        for (player in self.mediaPlayers)
        {
            if ([player.contentURL isEqual:url])
            {
                break;
            }
        }
        
        if (!player)
        {
            player = [[MPMoviePlayerController alloc] initWithContentURL:url];
            [self.mediaPlayers addObject:player];
        }
        
#if __IPHONE_OS_VERSION_MAX_ALLOWED > __IPHONE_4_2
        NSString *airplayAttr = [attachment.attributes objectForKey:@"x-webkit-airplay"];
        if ([airplayAttr isEqualToString:@"allow"])
        {
            if ([player respondsToSelector:@selector(setAllowsAirPlay:)])
            {
                player.allowsAirPlay = YES;
            }
        }
#endif
        
        NSString *controlsAttr = [attachment.attributes objectForKey:@"controls"];
        if (controlsAttr)
        {
            player.controlStyle = MPMovieControlStyleEmbedded;
        }
        else
        {
            player.controlStyle = MPMovieControlStyleNone;
        }
        
        NSString *loopAttr = [attachment.attributes objectForKey:@"loop"];
        if (loopAttr)
        {
            player.repeatMode = MPMovieRepeatModeOne;
        }
        else
        {
            player.repeatMode = MPMovieRepeatModeNone;
        }
        
        NSString *autoplayAttr = [attachment.attributes objectForKey:@"autoplay"];
        if (autoplayAttr)
        {
            player.shouldAutoplay = YES;
        }
        else
        {
            player.shouldAutoplay = NO;
        }
        
        [player prepareToPlay];
        
        player.view.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        player.view.frame = grayView.bounds;
        [grayView addSubview:player.view];
        
        return grayView;
    }
    else if ([attachment isKindOfClass:[DTImageTextAttachment class]])
    {
        CGRect rect = frame;
        rect.size.width = self.cWidth;
        rect.size.height = self.cHeight;
        
        UIView *View = [[UIView alloc] initWithFrame:rect];
        
        UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0,0,self.cWidth,self.cHeight)];
        [imageView sd_setImageWithURL:attachment.contentURL placeholderImage:[UIImage imageNamed:@""]];
        imageView.contentMode = UIViewContentModeScaleAspectFit;
        
        [View addSubview:imageView];
        
        // NOTE: this is a hack, you probably want to use your own image view and touch handling
        // also, this treats an image with a hyperlink by itself because we don't have the GUID of the link parts
        imageView.userInteractionEnabled = YES;
        
        // if there is a hyperlink then add a link button on top of this image
        if (attachment.hyperLinkURL)
        {
            DTLinkButton *button = [[DTLinkButton alloc] initWithFrame:imageView.bounds];
            button.URL = attachment.hyperLinkURL;
            button.minimumHitSize = CGSizeMake(25, 25); // adjusts it's bounds so that button is always large enough
            button.GUID = attachment.hyperLinkGUID;
            
            // use normal push action for opening URL
            [button addTarget:self action:@selector(linkPushed:) forControlEvents:UIControlEventTouchUpInside];
            
            // demonstrate combination with long press
            UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(linkLongPressed:)];
            [button addGestureRecognizer:longPress];
            
            [imageView addSubview:button];
        }else
        {
            /** 图片添加点击事件*/
            UITapGestureRecognizer *tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(openImage:)];
            [attributedTextContentView addGestureRecognizer:tapRecognizer];
        }
        
        return View;
    }
    else if ([attachment isKindOfClass:[DTIframeTextAttachment class]])
    {
        DTWebVideoView *videoView = [[DTWebVideoView alloc] initWithFrame:frame];
        videoView.attachment = attachment;
        
        return videoView;
    }
    else if ([attachment isKindOfClass:[DTObjectTextAttachment class]])
    {
        // somecolorparameter has a HTML color
        NSString *colorName = [attachment.attributes objectForKey:@"somecolorparameter"];
        UIColor *someColor = DTColorCreateWithHTMLName(colorName);
        
        UIView *someView = [[UIView alloc] initWithFrame:frame];
        someView.backgroundColor = someColor;
        someView.layer.borderWidth = 1;
        someView.layer.borderColor = [UIColor blackColor].CGColor;
        
        someView.accessibilityLabel = colorName;
        someView.isAccessibilityElement = YES;
        
        return someView;
    }
    
    return nil;
}

- (BOOL)attributedTextContentView:(DTAttributedTextContentView *)attributedTextContentView shouldDrawBackgroundForTextBlock:(DTTextBlock *)textBlock frame:(CGRect)frame context:(CGContextRef)context forLayoutFrame:(DTCoreTextLayoutFrame *)layoutFrame
{
    UIBezierPath *roundedRect = [UIBezierPath bezierPathWithRoundedRect:CGRectInset(frame,1,1) cornerRadius:10];
    
    CGColorRef color = [textBlock.backgroundColor CGColor];
    if (color)
    {
        CGContextSetFillColorWithColor(context, color);
        CGContextAddPath(context, [roundedRect CGPath]);
        CGContextFillPath(context);
        
        CGContextAddPath(context, [roundedRect CGPath]);
        CGContextSetRGBStrokeColor(context, 0, 0, 0, 1);
        CGContextStrokePath(context);
        return NO;
    }
    
    return YES; // draw standard background
}

@end
