//
//  LGPhotoPickerCustomToolBarView.m
//  LGPhotoBrowser
//
//  Created by ligang on 15/10/27.
//  Copyright (c) 2015年 L&G. All rights reserved.

#import "LGPhotoPickerCustomToolBarView.h"
#import "LGPhotoPickerBrowserPhoto.h"
#import "LGPhotoPickerCommon.h"
#import <Masonry.h>

@interface LGPhotoPickerCustomToolBarView()

@property (nonatomic, strong) UIView *toolBar;

@property (nonatomic, copy)  NSString *fileSize;

@property (nonatomic, strong) UIButton *isOriginalBtn;
@property (nonatomic, strong) UIButton *sendCountBtn;
@property (nonatomic, strong) UIButton *sendBtn;

@property (nonatomic , weak) UILabel *makeView;

@end

@implementation LGPhotoPickerCustomToolBarView


- (instancetype)initWithFrame:(CGRect)frame showType:(LGShowImageType)showType {
    self = [super initWithFrame:frame];
    if (self) {
        self.showType = showType;
        /* 底部toorbar条*/
        self.toolBar = [[UIView alloc] initWithFrame:CGRectZero];
        [self.toolBar setBackgroundColor:XX_RGBCOLOR_WITHOUTA(20, 20, 20)];
        [self addSubview:self.toolBar];
        /** 预览按钮*/
        self.isOriginalBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [self.isOriginalBtn setTitleColor:XX_RGBCOLOR_WITHOUTA(153, 153, 153) forState:UIControlStateNormal];
        [self.isOriginalBtn setTitleColor:[XX_RGBCOLOR_WITHOUTA(153, 153, 153) colorWithAlphaComponent:0.5] forState:UIControlStateDisabled];
        [self.isOriginalBtn setEnabled:YES];
        [self.isOriginalBtn.titleLabel setFont:[UIFont systemFontOfSize:15]];
        [self.isOriginalBtn setTitle:@"原图" forState:UIControlStateNormal];
        [self.isOriginalBtn addTarget:self action:@selector(originalAction) forControlEvents:UIControlEventTouchUpInside];
        [self.toolBar addSubview:self.isOriginalBtn];
        /** 图片按钮*/
        self.sendCountBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [self.sendCountBtn setBackgroundImage:[UIImage imageNamed:@"chat_photo_send_num_bg"] forState:UIControlStateNormal];
        [self.sendCountBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [self.sendCountBtn setHidden:YES];
        [self.sendCountBtn.titleLabel setFont:[UIFont systemFontOfSize:14]];
        [self.sendCountBtn addTarget:self action:@selector(sendAction) forControlEvents:UIControlEventTouchUpInside];
        [self.toolBar addSubview:self.sendCountBtn];
        /** 发送按钮*/
        self.sendBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [self.sendBtn setTitleColor:XX_NAVIGATIONBAR_TINTCOLOR forState:UIControlStateNormal];
        [self.sendBtn setTitleColor:[XX_NAVIGATIONBAR_TINTCOLOR colorWithAlphaComponent:0.5] forState:UIControlStateDisabled];
        [self.sendBtn setEnabled:YES];
        [self.sendBtn.titleLabel setFont:[UIFont systemFontOfSize:16]];
        [self.sendBtn setTitle:@"发送" forState:UIControlStateNormal];
        [self.sendBtn addTarget:self action:@selector(sendAction) forControlEvents:UIControlEventTouchUpInside];
        [self.toolBar addSubview:self.sendBtn];
        
        [self.toolBar mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.right.mas_equalTo(self);
            make.bottom.mas_equalTo(self);
            make.height.mas_offset(45);
        }];
        [self.isOriginalBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerY.mas_equalTo(self.toolBar);
            make.left.mas_equalTo(self.toolBar).mas_offset(10);
        }];
        [self.sendCountBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerY.mas_equalTo(self.sendBtn);
            make.right.mas_equalTo(self.sendBtn.mas_left).mas_offset(-5);
        }];
        [self.sendBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerY.mas_equalTo(self.toolBar);
            make.right.mas_equalTo(self.toolBar).mas_offset(-10);
        }];
        
        [self updateToolbarWithOriginal:NO currentPage:0 selectedCount:0];
    }
    return self;
}

- (void)sendAction {
    if ([self.delegate respondsToSelector:@selector(customToolBarSendBtnTouched)]) {
        [self.delegate customToolBarSendBtnTouched];
    }
}

- (void)updateToolbarWithOriginal:(BOOL)isOriginal
                      currentPage:(NSInteger)currentPage
                    selectedCount:(NSInteger)count {
    //左边原图按钮
    if (isOriginal) {
        if (self.getSizeBlock) {
            self.fileSize = self.getSizeBlock();
        }
        [self.isOriginalBtn setTitle:[NSString stringWithFormat:@"原图%@",self.fileSize] forState:UIControlStateNormal];
    } else
    {
        [self.isOriginalBtn setTitle:@"原图" forState:UIControlStateNormal];
    }
    
    self.sendCountBtn.hidden = !(count > 0);
    self.sendBtn.enabled = (count > 0);
    [self.sendCountBtn setTitle:[NSString stringWithFormat:@"%ld",(long)count] forState:UIControlStateNormal];
    
}

- (void)originalAction {
    if ([self.delegate respondsToSelector:@selector(customToolBarIsOriginalBtnTouched)]) {
        [self.delegate customToolBarIsOriginalBtnTouched];
    }
}

@end
