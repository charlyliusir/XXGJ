//
//  VIPhotoView.m
//  VIPhotoViewDemo
//
//  Created by Vito on 1/7/15.
//  Copyright (c) 2015 vito. All rights reserved.
//

#import "VIPhotoView.h"
#import "UIImageView+WebCache.h"

@interface UIImage (VIUtil)

- (CGSize)sizeThatFits:(CGSize)size;

@end

@implementation UIImage (VIUtil)

- (CGSize)sizeThatFits:(CGSize)size
{
    CGSize imageSize = CGSizeMake(self.size.width / self.scale,
                                  self.size.height / self.scale);
    
    CGFloat widthRatio = imageSize.width / size.width;
    CGFloat heightRatio = imageSize.height / size.height;
    
    if (widthRatio > heightRatio) {
        imageSize = CGSizeMake(imageSize.width / widthRatio, imageSize.height / widthRatio);
    } else {
        imageSize = CGSizeMake(imageSize.width / heightRatio, imageSize.height / heightRatio);
    }
    
    return imageSize;
}

@end

@interface UIImageView (VIUtil)

- (CGSize)contentSize;

@end

@implementation UIImageView (VIUtil)

- (CGSize)contentSize
{
    return [self.image sizeThatFits:self.bounds.size];
}

@end

@interface VIPhotoView () <UIScrollViewDelegate>

@property (nonatomic, strong) UIView *containerView;
@property (nonatomic, strong) UIImageView *imageView;
@property (nonatomic, strong) NSTimer *dismissTimer;

@property (nonatomic) BOOL rotating;
@property (nonatomic) CGSize minSize;

@property (nonatomic) BOOL zoomAction;

@end

@implementation VIPhotoView

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        self.delegate = self;
        self.bouncesZoom = YES;
        
        // Add container view
        UIView *containerView = [[UIView alloc] initWithFrame:self.bounds];
        containerView.backgroundColor = [UIColor clearColor];
        [self addSubview:containerView];
        _containerView = containerView;
        
        // Add image view
        UIImageView *imageView = [[UIImageView alloc] initWithFrame:_containerView.bounds];
        imageView.frame = containerView.bounds;
        imageView.contentMode = UIViewContentModeScaleAspectFit;
        [containerView addSubview:imageView];
        _imageView = imageView;
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(changeDevice:) name:UIDeviceOrientationDidChangeNotification object:nil];
    }
    
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame andImage:(UIImage *)image
{
    self = [super initWithFrame:frame];
    if (self) {
        self.delegate = self;
        self.bouncesZoom = YES;
        
        // Add container view
        UIView *containerView = [[UIView alloc] initWithFrame:self.bounds];
        containerView.backgroundColor = [UIColor clearColor];
        [self addSubview:containerView];
        _containerView = containerView;
        
        // Add image view
        UIImageView *imageView = [[UIImageView alloc] initWithImage:image];
        imageView.frame = containerView.bounds;
        imageView.contentMode = UIViewContentModeScaleAspectFit;
        [containerView addSubview:imageView];
        _imageView = imageView;
        
        // Fit container view's size to image size
        CGSize imageSize = imageView.contentSize;
        self.containerView.frame = CGRectMake(0, 0, imageSize.width, imageSize.height);
        imageView.bounds = CGRectMake(0, 0, imageSize.width, imageSize.height);
        imageView.center = CGPointMake(imageSize.width / 2, imageSize.height / 2);
        
        self.contentSize = imageSize;
        self.minSize = imageSize;
        
        
        [self setMaxMinZoomScale];
        
        // Center containerView by set insets
        [self centerContent];
        
        // Setup other events
        [self setupGestureRecognizer];
        [self setupRotationNotification];
    }
    
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame andNetWorkString:(NSURL *)fileUrl
{
    if (self = [super initWithFrame:frame]) {
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(changeUIImageView:)
                                                     name:@"stopLoadingNotification" object:nil];
        
        self.delegate = self;
        self.bouncesZoom = YES;
        
        // Add container view
        UIView *containerView = [[UIView alloc] initWithFrame:self.bounds];
        containerView.backgroundColor = [UIColor clearColor];
        [self addSubview:containerView];
        _containerView = containerView;
        
        // Add image view
        UIImageView *imageView = [[UIImageView alloc] initWithFrame:containerView.bounds];
        imageView.tag   = 101020;
        imageView.image = [UIImage imageNamed:@"bg_drivingrecord_photo_loding"];
        imageView.contentMode = UIViewContentModeScaleAspectFit;
        [containerView addSubview:imageView];
        [imageView sd_setImageWithURL:fileUrl placeholderImage:[UIImage imageNamed:@"bg_drivingrecord_photo_loding"]];
        _imageView = imageView;
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(changeDevice:) name:UIDeviceOrientationDidChangeNotification object:nil];
    }
    return self;
}

- (void)setLocalImage:(UIImage *)localImage
{
//#define SELF_FRAME_SIZE_WIDTH [UIScreen mainScreen].bounds.size.width
//#define SELF_FRAME_SIZE_HEIGHT [UIScreen mainScreen].bounds.size.height
    _imageView.image = localImage;
    CGSize imageSize = CGSizeMake([UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height);
    if ([UIDevice currentDevice].orientation == UIDeviceOrientationPortrait) {
        imageSize = CGSizeMake([UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height-64);
    }
    self.containerView.frame = CGRectMake(0, 0, imageSize.width, imageSize.height);
    _imageView.bounds = CGRectMake(0, 0, imageSize.width, imageSize.height);
    _imageView.center = CGPointMake(imageSize.width / 2, imageSize.height / 2);
    
    self.contentSize = imageSize;
    self.minSize = imageSize;
    
    
    [self setMaxMinZoomScale];
    
    // Center containerView by set insets
    [self centerContent];
    
    // Setup other events
    [self setupGestureRecognizer];
    [self setupRotationNotification];

}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    if (self.rotating) {
        self.rotating = NO;
        
        // update container view frame
        CGSize containerSize = self.containerView.frame.size;
        BOOL containerSmallerThanSelf = (containerSize.width < CGRectGetWidth(self.bounds)) && (containerSize.height < CGRectGetHeight(self.bounds));
        
        CGSize imageSize = [self.imageView.image sizeThatFits:self.bounds.size];
        CGFloat minZoomScale = imageSize.width / self.minSize.width;
        self.minimumZoomScale = minZoomScale;
        if (containerSmallerThanSelf || self.zoomScale == self.minimumZoomScale) { // 宽度或高度 都小于 self 的宽度和高度
            self.zoomScale = minZoomScale;
        }
        
        // Center container view
        [self centerContent];
    }
}

#pragma mark - Setup

- (void)setupRotationNotification
{
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(orientationChanged:)
                                                 name:UIApplicationDidChangeStatusBarOrientationNotification
                                               object:nil];
}

- (void)setupGestureRecognizer
{
    UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapHandler:)]; 
    tapGestureRecognizer.numberOfTapsRequired = 2;
    [_containerView addGestureRecognizer:tapGestureRecognizer];
    
#warning 注册点击事件
    /** 注册点击事件*/
    UITapGestureRecognizer *dismissTapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismissAction:)];
    [_containerView addGestureRecognizer:dismissTapGestureRecognizer];
    
}

- (void)stopTimer
{
    [self.dismissTimer invalidate];
    [self setDismissTimer:nil];
}

#pragma mark - UIScrollViewDelegate

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView
{
    return self.containerView;
}

- (void)scrollViewDidZoom:(UIScrollView *)scrollView
{
    [self centerContent];
}

#pragma mark - GestureRecognizer

- (void)tapHandler:(UITapGestureRecognizer *)recognizer
{
    self.zoomAction = YES;
    if (self.zoomScale > self.minimumZoomScale) {
        [self setZoomScale:self.minimumZoomScale animated:YES];
    } else if (self.zoomScale < self.maximumZoomScale) {
        CGPoint location = [recognizer locationInView:recognizer.view];
        CGRect zoomToRect = CGRectMake(0, 0, 50, 50);
        zoomToRect.origin = CGPointMake(location.x - CGRectGetWidth(zoomToRect)/2, location.y - CGRectGetHeight(zoomToRect)/2);
        [self zoomToRect:zoomToRect animated:YES];
    }
}

- (void)dismissAction:(UITapGestureRecognizer *)recognizer
{
    self.dismissTimer = [NSTimer timerWithTimeInterval:0.5 repeats:NO block:^(NSTimer * _Nonnull timer) {
        if (!self.zoomAction)
        {
            if (self.tapDelegate && [self.tapDelegate respondsToSelector:@selector(tapHandler)]) {
                [self.tapDelegate tapHandler];
            }
        }
        self.zoomAction = NO;
    }];
    [[NSRunLoop mainRunLoop] addTimer:self.dismissTimer forMode:NSRunLoopCommonModes];
}


- (void)remake
{
    [self setZoomScale:self.minimumZoomScale animated:YES];
}

#pragma mark - Notification

- (void)orientationChanged:(NSNotification *)notification
{
    self.rotating = YES;
}

#pragma mark - Helper

- (void)setMaxMinZoomScale
{
    CGSize imageSize = self.imageView.image.size;
    CGSize imagePresentationSize = self.imageView.contentSize;
    CGFloat maxScale = MAX(imageSize.height / imagePresentationSize.height, imageSize.width / imagePresentationSize.width);
    self.maximumZoomScale = MAX(1, maxScale); // Should not less than 1
    self.minimumZoomScale = 1.0;
}

- (void)centerContent
{
    CGRect frame = self.containerView.frame;
    
    CGFloat top = 0, left = 0;
    if (self.contentSize.width < self.bounds.size.width) {
        left = (self.bounds.size.width - self.contentSize.width) * 0.5f;
    }
    if (self.contentSize.height < self.bounds.size.height) {
        top = (self.bounds.size.height - self.contentSize.height) * 0.5f;
    }
    
    top -= frame.origin.y;
    left -= frame.origin.x;
    
    self.contentInset = UIEdgeInsetsMake(top, left, top, left);
}

#pragma mark - notification method
- (void)changeUIImageView:(NSNotification *)notification
{
    UIImageView *imageView = (UIImageView *)notification.object;
    dispatch_async(dispatch_get_main_queue(), ^{
        if (imageView == _imageView) {
            // Fit container view's size to image size
            
            CGSize imageSize = imageView.contentSize;
            self.containerView.frame = CGRectMake(0, 0, imageSize.width, imageSize.height);
            imageView.bounds = CGRectMake(0, 0, imageSize.width, imageSize.height);
            imageView.center = CGPointMake(imageSize.width / 2, imageSize.height / 2);
            
            self.contentSize = imageSize;
            self.minSize = imageSize;
            
            
            [self setMaxMinZoomScale];
            
            // Center containerView by set insets
            [self centerContent];
            
            // Setup other events
            [self setupGestureRecognizer];
            [self setupRotationNotification];
        }
    });
}


- (void)changeDevice:(NSNotification *)notification
{
    UIDevice *device = (UIDevice *)notification.object;
    
    switch (device.orientation) {
        case UIDeviceOrientationFaceDown:
            
            break;
        case UIDeviceOrientationFaceUp:
            break;
        case UIDeviceOrientationLandscapeLeft:
        case UIDeviceOrientationLandscapeRight:{
            
            CGSize imageSize = CGSizeMake([UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height);
            self.frame = CGRectMake(0, 0, imageSize.width, imageSize.height);
            self.bounds= CGRectMake(0, 0, imageSize.width, imageSize.height);
            self.containerView.frame = self.bounds;
            self.imageView.bounds    = CGRectMake(0, 0, self.containerView.frame.size.width, self.containerView.frame.size.height);
            self.imageView.center    = CGPointMake(self.containerView.frame.size.width/2, self.containerView.frame.size.height/2);
            
            self.contentSize = self.bounds.size;
            self.minSize = self.bounds.size;
            
            
            [self setMaxMinZoomScale];
            
            // Center containerView by set insets
            [self centerContent];
            
            // Setup other events
            [self setupGestureRecognizer];
            [self setupRotationNotification];
        }
            break;
        case UIDeviceOrientationPortrait:{
            CGSize imageSize = CGSizeMake([UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height);
            if ([UIDevice currentDevice].orientation == UIDeviceOrientationPortrait) {
                imageSize = CGSizeMake([UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height-64);
            }
            self.frame = CGRectMake(0, 0, imageSize.width, imageSize.height);
            self.bounds= CGRectMake(0, 0, imageSize.width, imageSize.height);
            self.containerView.frame = self.bounds;
            self.imageView.bounds    = CGRectMake(0, 0, self.containerView.frame.size.width, self.containerView.frame.size.height);
            self.imageView.center    = CGPointMake(self.containerView.frame.size.width/2, self.containerView.frame.size.height/2);
            
            self.contentSize = self.bounds.size;
            self.minSize = self.bounds.size;
            [self setMaxMinZoomScale];
            // Center containerView by set insets
            [self centerContent];
            
            // Setup other events
            [self setupGestureRecognizer];
            [self setupRotationNotification];
        }
            break;
        case UIDeviceOrientationPortraitUpsideDown:
            break;
        case UIDeviceOrientationUnknown:
            break;
        default:
            break;
    }
}

@end
