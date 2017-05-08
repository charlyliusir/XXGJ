//
//  XXGJPopUpView.m
//  xxdcchat_ios
//
//  Created by 刘朝龙 on 2017/4/7.
//  Copyright © 2017年 刘朝龙. All rights reserved.
//

#import "XXGJPopUpView.h"
#import <Masonry.h>

@interface XXGJPopUpView ()

@property (nonatomic, strong)UIImageView *popupBackgroundImageView; /** 弹窗背景视图*/

@end

@implementation XXGJPopUpView

- (instancetype)init
{
    if (self = [super init])
    {
        
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame])
    {
        [self setBackgroundColor:[UIColor clearColor]];
        /** 弹窗背景*/
        CGFloat top = 25; // 顶端盖高度
        CGFloat bottom = 25 ; // 底端盖高度
        CGFloat left = 5; // 左端盖宽度
        CGFloat right = 5; // 右端盖宽度
        UIEdgeInsets insets = UIEdgeInsetsMake(top, left, bottom, right);
        self.popupBackgroundImageView = [[UIImageView alloc] initWithImage:[[UIImage imageNamed:@"chat_icon_popupview_bg"] resizableImageWithCapInsets:insets resizingMode:UIImageResizingModeStretch]];
        [self.popupBackgroundImageView setUserInteractionEnabled:YES];
        [self addSubview:self.popupBackgroundImageView];
        /** 添加发起群聊Item视图*/
        UIButton *createGroupItemButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [createGroupItemButton setTag:1001];
        [createGroupItemButton setImage:[UIImage imageNamed:@"chat_icon_popupview_item_creatgroup"] forState:UIControlStateNormal];
        [createGroupItemButton setTitle:@"发起群聊" forState:UIControlStateNormal];
        [createGroupItemButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [createGroupItemButton.titleLabel setFont:[UIFont systemFontOfSize:14]];
        [createGroupItemButton addTarget:self action:@selector(tapPopupItemAction:) forControlEvents:UIControlEventTouchUpInside];
        [self.popupBackgroundImageView addSubview:createGroupItemButton];
        /** 分割线*/
        UIView *lineView = [[UIView alloc] initWithFrame:CGRectZero];
        [lineView setBackgroundColor:XX_RGBCOLOR_WITHOUTA(101, 101, 101)];
        [self.popupBackgroundImageView addSubview:lineView];
        /** 添加扫一扫Item视图*/
        UIButton *qrItemButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [qrItemButton setTag:1002];
        [qrItemButton setImage:[UIImage imageNamed:@"chat_icon_popupview_item_qrCode"] forState:UIControlStateNormal];
        [qrItemButton setTitle:@"扫一扫" forState:UIControlStateNormal];
        [qrItemButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [qrItemButton.titleLabel setFont:[UIFont systemFontOfSize:14]];
        [createGroupItemButton addTarget:self action:@selector(tapPopupItemAction:) forControlEvents:UIControlEventTouchUpInside];
        [self.popupBackgroundImageView addSubview:qrItemButton];
        /** 视图添加消失代码*/
        UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismissShow:)];
        [self addGestureRecognizer:tapGestureRecognizer];
        /** 布局代码*/
        [self.popupBackgroundImageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.right.mas_offset(-14);
            make.top.mas_offset(64);
            make.bottom.mas_equalTo(qrItemButton);
        }];
        [createGroupItemButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(self.popupBackgroundImageView).mas_offset(5);
            make.left.mas_equalTo(self.popupBackgroundImageView).mas_offset(15);
            make.height.mas_equalTo(40);
        }];
        [lineView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.bottom.mas_equalTo(createGroupItemButton);
            make.height.mas_equalTo(1);
            make.left.mas_equalTo(self.popupBackgroundImageView).mas_offset(5);
            make.right.mas_equalTo(self.popupBackgroundImageView).mas_offset(-5);
        }];
        [qrItemButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(lineView.mas_bottom);
            make.left.mas_equalTo(createGroupItemButton);
            make.height.mas_equalTo(40);
        }];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
    if (self = [super initWithCoder:aDecoder]) {
        
    }
    return self;
}

- (void)showView
{
    /** 将视图显示到窗体上*/
    [[UIApplication sharedApplication].keyWindow addSubview:self];
    [[UIApplication sharedApplication].keyWindow bringSubviewToFront:self];
}

- (void)dismissShow:(id)sender
{
    [self removeFromSuperview];
}

- (void)tapPopupItemAction:(UIButton *)btn
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(tapPopupItemView:item:)])
    {
        [self.delegate tapPopupItemView:self
                                   item:(XXGJPopupItem)(btn.tag-1001)];
    }
    [self dismissShow:nil];
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
