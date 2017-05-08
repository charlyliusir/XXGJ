//
//  XXGJChatBaseTableViewCell.m
//  xxdcchat_ios
//
//  Created by 刘朝龙 on 2017/3/19.
//  Copyright © 2017年 刘朝龙. All rights reserved.
//

#import "XXGJChatBaseTableViewCell.h"
#import "XXGJReSendMessageManager.h"

@interface XXGJChatBaseTableViewCell()

@property (nonatomic, readwrite, strong)UIView *timeContentView;
@property (nonatomic, readwrite, strong)UILabel *timeLabel;
@property (nonatomic, readwrite, strong)UILabel *userName;
@property (nonatomic, readwrite, strong)UIButton *userIconImage;
@property (nonatomic, readwrite, strong)UIImageView *nodeBoardImage;
@property (nonatomic, readwrite, strong)UIActivityIndicatorView * activityIndicatorView;
@property (nonatomic, readwrite, strong)UIButton *reSendBtn;

@end

@implementation XXGJChatBaseTableViewCell

+ (instancetype)chatBaseCell:(UITableView *)tableView
{
    NSString *identifier = @"basecell";
    
    XXGJChatBaseTableViewCell *chatCell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if (!chatCell) {
        chatCell = [[XXGJChatBaseTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
    }
    
    [chatCell.userName setHidden:YES];
    [chatCell.userIconImage setHidden:YES];
    [chatCell.nodeBoardImage setHidden:YES];
    [chatCell.activityIndicatorView setHidden:YES];
    [chatCell.reSendBtn setHidden:YES];
    
    return chatCell;
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier])
    {
        [self setBackgroundColor:[UIColor clearColor]];
        [self setSelectionStyle:UITableViewCellSelectionStyleNone];
        // UI 布局
        /** 头部时间视图*/
        self.timeContentView = [[UIView alloc] initWithFrame:CGRectZero];
        [self.timeContentView setBackgroundColor:XX_RGBCOLOR_WITHOUTA(218, 218, 218)];
        [self.timeContentView.layer setCornerRadius:2];
        self.timeLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        [self.timeLabel setText:@"上午 9：30"];
        [self.timeLabel setTextColor:[UIColor whiteColor]];
        [self.timeLabel setFont:[UIFont systemFontOfSize:12]];
        [self.contentView addSubview:self.timeContentView];
        [self.timeContentView addSubview:self.timeLabel];
        
        /** 头像视图布局*/
        self.userIconImage = [UIButton buttonWithType:UIButtonTypeCustom];
        [self.userIconImage setBackgroundImage:[UIImage imageNamed:@"chat_icon_new_friend"] forState:UIControlStateNormal];
        [self.userIconImage.layer setCornerRadius:2];
        [self.userIconImage setUserInteractionEnabled:YES];
        [self.contentView addSubview:self.userIconImage];
        [self.userIconImage addTarget:self action:@selector(goUserInfo:) forControlEvents:UIControlEventTouchUpInside];
        
        /** 用户名布局*/
        self.userName = [[UILabel alloc] initWithFrame:CGRectZero];
        [self.userName setText:@"陶乐乐"];
        [self.userName setTextColor:XX_RGBCOLOR_WITHOUTA(188, 188, 188)];
        [self.userName setFont:[UIFont systemFontOfSize:12]];
        [self.contentView addSubview:self.userName];
        
        /** 聊天气泡布局*/
        self.nodeBoardImage = [[UIImageView alloc] initWithFrame:CGRectZero];
        [self.nodeBoardImage setUserInteractionEnabled:YES];
        [self.contentView addSubview:self.nodeBoardImage];
        
        /** 小菊花*/
        self.activityIndicatorView = [[UIActivityIndicatorView alloc] initWithFrame:CGRectZero];
        [self.activityIndicatorView setActivityIndicatorViewStyle:UIActivityIndicatorViewStyleGray];
        [self.contentView addSubview:self.activityIndicatorView];
        
        /** 重发按钮*/
        self.reSendBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [self.reSendBtn setBackgroundImage:[UIImage imageNamed:@"chat_icon_resend_message_btn"] forState:UIControlStateNormal];
        [self.reSendBtn addTarget:self action:@selector(reSendMessage:) forControlEvents:UIControlEventTouchUpInside];
        [self.contentView addSubview:self.reSendBtn];
        
        [self.timeContentView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_offset(25);
            make.centerX.mas_equalTo(self.contentView);
            make.width.mas_equalTo(self.timeLabel).multipliedBy(1.2);
            make.height.mas_equalTo(self.timeLabel).multipliedBy(1.2);
        }];
        [self.timeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.center.mas_equalTo(self.timeContentView);
        }];
        
        UILongPressGestureRecognizer *textLongPressGR = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(editTextMessage:)];
        [self.nodeBoardImage addGestureRecognizer:textLongPressGR];
    }
    
    return self;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)goUserInfo:(id)sender
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(chatTableViewCell:goUserInfo:)])
    {
        [self.delegate chatTableViewCell:self goUserInfo:self.chatMessage];
    }
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    
    // Configure the view for the selected state
}
#pragma mark - getter and setter
- (void)setMessage:(XXGJChatMessage *)msg
{
    _chatMessage = msg;
    /* 1, 判断用户的头像是否存在
     *      如果存在, 则通过sdwebimage加载图片
     *      如果不存在, 查看是否是系统用户, 如果不是则添加占位图片
     * 2, 用户名称显示格式, 自己的名字不显示, 群组中用户名字不显示
     * 3, 判断消息是否没有接收成功
     * 4, 判断消息是否需要重新发送
     */
    
    // 1, 判断用户的头像是否存在
    if (msg.userAvatar)
    {
        [self.userIconImage sd_setBackgroundImageWithURL:[NSURL URLWithString:[XXGJ_N_BASE_IMAGE_URL stringByAppendingString:msg.userAvatar]] forState:UIControlStateNormal placeholderImage:[UIImage imageNamed:@"placeholder_user_male_icon-98px"]];
    }else if(msg.businessType==XXGJBusinessSystem)
    {
        [self.userIconImage setBackgroundImage:[UIImage imageNamed:@"system_icon"] forState:UIControlStateNormal];
    }else
    {
        [self.userIconImage setBackgroundImage:[UIImage imageNamed:@"placeholder_user_male_icon-98px"] forState:UIControlStateNormal];
    }
    // 2, 用户名称显示格式, 自己的名字不显示, 群组中用户名字不显示
    if ([msg.isGroup boolValue])
    {
        [self.userName setText:msg.userName];
    }else
    {
        [self.userName setHidden:YES];
    }
    // 3, 判断消息是否为图片消息, 并判断上传图片的进度是否完毕
    
    // 4, 判断消息是否没有接收成功
    BOOL isReSendMessage = [[[XXGJReSendMessageManager sharedReSendMessageManger] reSendMessageObjectUuidArray] containsObject:self.chatMessage.msgUuid];
    BOOL isAck           = [msg.isAck boolValue];
    if (isReSendMessage && !isAck)
    {
        [self.activityIndicatorView startAnimating];
        [self.activityIndicatorView setHidden:NO];
        [self.reSendBtn setHidden:YES];
    }else if (!isReSendMessage && !isAck)
    {
        [self.activityIndicatorView stopAnimating];
        [self.activityIndicatorView setHidden:YES];
        [self.reSendBtn setHidden:NO];
    }else
    {
        [self.activityIndicatorView stopAnimating];
        [self.activityIndicatorView setHidden:YES];
        [self.reSendBtn setHidden:YES];
    }
}

- (void)setChatCellStyle:(ChatCellStyle)chatCellStyle
{
    _chatCellStyle = chatCellStyle;
    
    if (_chatCellStyle == ChatCellStyleMe) {
        [self layoutMeUI];
    }else{
        [self layoutOtherUI];
    }
    
}

#pragma mark - open method
- (void)layoutOtherUI
{
    [self.userName mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.userIconImage);
        make.left.mas_equalTo(self.userIconImage.mas_right).mas_offset(20);
    }];
    [self.activityIndicatorView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(self.nodeBoardImage);
        make.left.mas_equalTo(self.nodeBoardImage.mas_right).mas_offset(10);
    }];
    [self.reSendBtn mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(self.nodeBoardImage);
        make.left.mas_equalTo(self.nodeBoardImage.mas_right).mas_offset(10);
    }];
}

- (void)layoutMeUI
{
    [self.userName mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.userIconImage);
        make.right.mas_equalTo(self.userIconImage.mas_left).mas_offset(-20);
    }];
    [self.activityIndicatorView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(self.nodeBoardImage);
        make.right.mas_equalTo(self.nodeBoardImage.mas_left).mas_offset(-10);
    }];
    [self.reSendBtn mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(self.nodeBoardImage);
        make.right.mas_equalTo(self.nodeBoardImage.mas_left).mas_offset(-10);
    }];
}

- (CGFloat)height
{
    CGFloat maxY = CGRectGetMaxY(self.nodeBoardImage.frame) + 10;
    
    if (maxY <= 60) {
        maxY = 60;
    }
    
    return maxY;
}

#pragma mark - private method
/**
 重新发送消息方法

 @param resendBtn 按钮
 */
- (void)reSendMessage:(UIButton *)resendBtn
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(chatTableViewCell:editTextMessage:editType:)])
    {
        [self.delegate chatTableViewCell:self editTextMessage:self.chatMessage editType:ChatCellEditStyleReSend];
    }
}
#pragma mark 处理action事件
-(BOOL)canPerformAction:(SEL)action withSender:(id)sender{
    if(action ==@selector(copyItemClicked:)){
        return YES;
    }else if (action==@selector(deleteItemClicked:)){
        return YES;
    }else if (action==@selector(drawnMessageClicked:)){
        return YES;
    }
    return [super canPerformAction:action withSender:sender];
}

#pragma mark  实现成为第一响应者方法
-(BOOL)canBecomeFirstResponder
{
    return YES;
}
#pragma mark - 菜单选项方法
-(void)deleteItemClicked:(id)sender
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(chatTableViewCell:editTextMessage:editType:)])
    {
        [self.delegate chatTableViewCell:self editTextMessage:self.chatMessage editType:ChatCellEditStyleDel];
    }
}

-(void)copyItemClicked:(id)sender
{
    //将自己的文字复制到粘贴板
    UIPasteboard *board = [UIPasteboard generalPasteboard];
    board.string = self.chatMessage.chatContent;
}

- (void)drawnMessageClicked:(id)sender
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(chatTableViewCell:editTextMessage:editType:)])
    {
        [self.delegate chatTableViewCell:self editTextMessage:self.chatMessage editType:ChatCellEditStyleDrawn];
    }
}
#pragma mark - 点击弹出菜单
- (void)editTextMessage:(UILongPressGestureRecognizer *)longPressGR
{
    /** 初始化菜单项数组*/
    self.menuItemArray = @[].mutableCopy;
    if (longPressGR.state == UIGestureRecognizerStateBegan)
    {
        //这里把cell做为第一响应(cell默认是无法成为responder,需要重写canBecomeFirstResponder方法)
        [self becomeFirstResponder];
        
        /** 创建一个可变数组, 放入操作*/
        if (self.chatMessage.cellStyle == ChatCellStyleMe&&[NSDate canDrawnMessageWithTimeInterval:[self.chatMessage.created longLongValue]])
        {
            UIMenuItem *itDrawn = [[UIMenuItem alloc] initWithTitle:@"撤销消息" action:@selector(drawnMessageClicked:)];
            [self.menuItemArray addObject:itDrawn];
        }
        
        UIMenuItem *itDelete = [[UIMenuItem alloc] initWithTitle:@"删除" action:@selector(deleteItemClicked:)];
        [self.menuItemArray addObject:itDelete];
    }
}

@end
