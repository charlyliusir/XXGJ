//
//  XXGJSearchMemberView.m
//  xxdcchat_ios
//
//  Created by 刘朝龙 on 2017/4/4.
//  Copyright © 2017年 刘朝龙. All rights reserved.
//

#import "XXGJSearchMemberView.h"
#import <Masonry.h>

@interface XXGJSearchMemberView ()
@property (nonatomic, strong)UIScrollView *scrollView;
@property (nonatomic, strong)UIView *contentView;
@property (nonatomic, strong)NSMutableArray *searchItemArray;

@end

@implementation XXGJSearchMemberView

- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame])
    {
        self.searchItemArray = [NSMutableArray array];
        self.scrollView = [[UIScrollView alloc] initWithFrame:CGRectZero];
        self.contentView = [[UIView alloc] initWithFrame:CGRectZero];
        [self addSubview:self.scrollView];
        [self.scrollView addSubview:self.contentView];
        [self.scrollView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.mas_equalTo(self);
        }];
        [self.contentView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.mas_equalTo(self.scrollView);
            make.height.mas_equalTo(self.scrollView);
        }];
        
        [self setupUI];
    }
    
    return self;
}

- (void)setupUI
{
    UIImageView *img = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"group_icon_search"]];
    [self.contentView addSubview:img];
    
    [img mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(self.contentView);
        make.left.mas_offset(10);
    }];
    [self.contentView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(img);
    }];
}

- (void)removeChildView
{
    
}

- (void)addChildView
{
    
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
