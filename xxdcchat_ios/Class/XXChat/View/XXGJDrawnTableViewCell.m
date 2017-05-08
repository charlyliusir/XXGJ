//
//  XXGJDrawnTableViewCell.m
//  xxdcchat_ios
//
//  Created by 刘朝龙 on 2017/3/20.
//  Copyright © 2017年 刘朝龙. All rights reserved.
//

#import "XXGJDrawnTableViewCell.h"
#import "Message.h"
#import "Group.h"
#import "User.h"

@interface XXGJDrawnTableViewCell ()

@property (nonatomic, readwrite, strong)UIView *drawnContentView;
@property (nonatomic, readwrite, strong)UILabel *drawnLabel;

@end

@implementation XXGJDrawnTableViewCell
+ (instancetype)chatDrawnCell:(UITableView *)tableView
{
    NSString *identifier = @"drawncell";
    
    XXGJDrawnTableViewCell *chatDrawnCell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if (!chatDrawnCell) {
        chatDrawnCell = [[XXGJDrawnTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
    }
    
    return chatDrawnCell;
}


- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        
        [self.userName setHidden:YES];
        [self.userIconImage setHidden:YES];
        [self.nodeBoardImage setHidden:YES];
        
        /** 撤销视图*/
        self.drawnContentView = [[UIView alloc] initWithFrame:CGRectZero];
        [self.drawnContentView setBackgroundColor:XX_RGBCOLOR_WITHOUTA(218, 218, 218)];
        [self.drawnContentView.layer setCornerRadius:2];
        
        self.drawnLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        [self.drawnLabel setText:@"你撤回了一条信息"];
        [self.drawnLabel setTextColor:[UIColor whiteColor]];
        [self.drawnLabel setFont:[UIFont systemFontOfSize:12]];
        
        [self.contentView addSubview:self.drawnContentView];
        [self.drawnContentView addSubview:self.drawnLabel];
        
        [self.drawnContentView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.mas_equalTo(self.timeContentView);
            make.top.mas_equalTo(self.timeContentView.mas_bottom).mas_offset(10);
            make.width.mas_equalTo(self.drawnLabel).multipliedBy(1.2);
            make.height.mas_equalTo(self.drawnLabel).multipliedBy(1.2);
        }];
        [self.drawnLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.center.mas_equalTo(self.drawnContentView);
        }];
        
    }
    
    return self;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

- (void)setMessage:(XXGJChatMessage *)msg
{
    [self.timeLabel setText:[NSDate dateForSpecString:[msg.chatTime longLongValue]]];
    
    if (msg.cellStyle == ChatCellStyleMe)
        /** 如果是用户撤销消息*/
    {
        [self.drawnLabel setText:@"你撤销了一条消息"];
    }
    else
        /** 群组成员撤销消息, */
    {
        [self.drawnLabel setText:msg.chatContent];
    }
}

- (CGFloat)height
{
    CGFloat maxY = CGRectGetMaxY(self.drawnContentView.frame) + 10;
    
    if (maxY <= 60) {
        maxY = 60;
    }
    
    return maxY;
}

@end
