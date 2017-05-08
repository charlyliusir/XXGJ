//
//  XGCameraImageView.m
//  XinGe
//
//  Created by ligang on 15/11/5.
//  Copyright © 2015年 Tomy. All rights reserved.
//

#import "LGCameraImageView.h"
#import <Masonry.h>

static CGFloat BOTTOM_HEIGHT = 83;

@interface LGCameraImageView()

@property (nonatomic, strong) UIImageView *photoDisplayView;

@end
@implementation LGCameraImageView


- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.userInteractionEnabled = YES;
        self.backgroundColor = [UIColor blackColor];
        [self setupBottomView];
    }
    return self;
}

- (void)setupBottomView {
    CGFloat width = 80;
    CGFloat margin = 20;
    
    // 显示照片的view   在imageToDisplay的set方法中设置frame和image
    UIImageView *photoDisplayView = [[UIImageView alloc] init];
    [self addSubview:photoDisplayView];
    _photoDisplayView = photoDisplayView;
    
    // 底部View
    UIView *controlView = [[UIView alloc] initWithFrame:CGRectZero];
    controlView.backgroundColor = XX_RGBCOLOR_WITHOUTA(20, 20, 20);
    [self addSubview:controlView];
    
    //‘重拍’按钮
    UIButton *cancalBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [cancalBtn.titleLabel setFont:[UIFont systemFontOfSize:16]];
    [cancalBtn setTitle:@"重拍" forState:UIControlStateNormal];
    [cancalBtn addTarget:self action:@selector(cancel1) forControlEvents:UIControlEventTouchUpInside];
    [controlView addSubview:cancalBtn];
    
    //‘使用照片’按钮
    UIButton *doneBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [doneBtn.titleLabel setFont:[UIFont systemFontOfSize:16]];
    [doneBtn setTitle:@"使用照片" forState:UIControlStateNormal];
    [doneBtn addTarget:self action:@selector(doneAction) forControlEvents:UIControlEventTouchUpInside];
    [controlView addSubview:doneBtn];
    
    [controlView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.left.right.mas_equalTo(self);
        make.height.mas_equalTo(83);
    }];
    [cancalBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(controlView);
        make.left.mas_equalTo(controlView).mas_offset(20);
    }];
    [doneBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(controlView);
        make.right.mas_equalTo(controlView).mas_equalTo(-20);
    }];
}

//setter
- (void)setImageToDisplay:(UIImage *)imageToDisplay {
    _imageToDisplay = imageToDisplay;
    
    if (imageToDisplay == nil) {
        return;
    }
    
    CGSize size;
    size.width = [UIScreen mainScreen].bounds.size.width;
    size.height = ([UIScreen mainScreen].bounds.size.width / imageToDisplay.size.width) * imageToDisplay.size.height;
    NSLog(@"%@",NSStringFromCGSize(size));
    CGFloat x = (self.frame.size.width - size.width) / 2;
    CGFloat y = (self.frame.size.height - size.height) / 2;
    _photoDisplayView.frame = CGRectMake(x, y, size.width, size.height);
    [_photoDisplayView setImage:imageToDisplay];
}

- (void)cancel1 {
    if ([_delegate respondsToSelector:@selector(xgCameraImageViewCancleBtnTouched)]) {
        [_delegate xgCameraImageViewCancleBtnTouched];
    }
    [self removeFromSuperview];
}

- (void)doneAction {
    if ([_delegate respondsToSelector:@selector(xgCameraImageViewSendBtnTouched)]) {
        [_delegate xgCameraImageViewSendBtnTouched];
    }
}

@end
