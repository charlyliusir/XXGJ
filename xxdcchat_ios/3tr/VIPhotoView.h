//
//  VIPhotoView.h
//  VIPhotoViewDemo
//
//  Created by Vito on 1/7/15.
//  Copyright (c) 2015 vito. All rights reserved.
//
#import <UIKit/UIKit.h>

@protocol VIPhotoViewDelegate <NSObject>

- (void)tapHandler;

@end

@interface VIPhotoView : UIScrollView <UIActionSheetDelegate>
@property (nonatomic, assign)id <VIPhotoViewDelegate> tapDelegate;
@property (nonatomic, strong)UIImage *localImage; // 设置本地图片
- (instancetype)initWithFrame:(CGRect)frame andImage:(UIImage *)image;
- (instancetype)initWithFrame:(CGRect)frame andNetWorkString:(NSURL *)fileUrl;
- (void)remake;
- (void)stopTimer;

@end
