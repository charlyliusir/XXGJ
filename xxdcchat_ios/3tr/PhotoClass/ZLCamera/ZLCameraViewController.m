//
//  BQCamera.m
//  BQCommunity
//
//  Created by ZL on 14-9-11.
//  Copyright (c) 2014年 beiqing. All rights reserved.
//

#import <AVFoundation/AVFoundation.h>
#import <ImageIO/ImageIO.h>
#import <objc/message.h>
#import "ZLCameraViewController.h"
#import "ZLCameraImageView.h"
#import "ZLCameraView.h"
#import "LGPhoto.h"
#import "LGCameraImageView.h"
#import <Masonry.h>

typedef void(^codeBlock)();
static CGFloat ZLCameraColletionViewW = 80;
static CGFloat ZLCameraColletionViewPadding = 20;
static CGFloat BOTTOM_HEIGHT = 120;

@interface ZLCameraViewController () <UIActionSheetDelegate,UICollectionViewDataSource,UICollectionViewDelegate,AVCaptureMetadataOutputObjectsDelegate,ZLCameraImageViewDelegate,ZLCameraViewDelegate,LGPhotoPickerBrowserViewControllerDataSource,LGPhotoPickerBrowserViewControllerDelegate,LGCameraImageViewDelegate>

@property (weak,nonatomic) ZLCameraView *caramView;
@property (strong, nonatomic) UICollectionView *collectionView;
@property (strong, nonatomic) UIViewController *currentViewController;

// Datas
@property (strong, nonatomic) NSMutableArray *images;
@property (strong, nonatomic) NSMutableDictionary *dictM;

// AVFoundation
@property (strong, nonatomic) AVCaptureSession *session;
@property (strong, nonatomic) AVCaptureStillImageOutput *captureOutput;
@property (strong, nonatomic) AVCaptureDevice *device;

@property (strong,nonatomic)AVCaptureDeviceInput * input;
@property (strong,nonatomic)AVCaptureMetadataOutput * output;
@property (strong,nonatomic)AVCaptureVideoPreviewLayer * preview;

@property (nonatomic, assign) XGImageOrientation imageOrientation;
@property (nonatomic, assign) NSInteger flashCameraState;

@property (nonatomic, strong) UIImageView *flashImageView;
@end

@implementation ZLCameraViewController

#pragma mark - Getter
#pragma mark Data
- (NSMutableArray *)images{
    if (!_images) {
        _images = [NSMutableArray array];
    }
    return _images;
}

- (NSMutableDictionary *)dictM{
    if (!_dictM) {
        _dictM = [NSMutableDictionary dictionary];
    }
    return _dictM;
}

#pragma mark View
- (UICollectionView *)collectionView{
    if (!_collectionView) {
        
        UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
        layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
        layout.itemSize = CGSizeMake(ZLCameraColletionViewW, ZLCameraColletionViewW);
        layout.minimumLineSpacing = ZLCameraColletionViewPadding;
        
        CGFloat collectionViewH = ZLCameraColletionViewW;
        CGFloat collectionViewY = self.caramView.height - collectionViewH - 10;
        
        UICollectionView *collectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(0, collectionViewY, self.view.width, collectionViewH)
                                                              collectionViewLayout:layout];
        collectionView.backgroundColor = [UIColor clearColor];
        [collectionView registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:@"cell"];
        collectionView.delegate = self;
        collectionView.dataSource = self;
        [self.caramView addSubview:collectionView];
        self.collectionView = collectionView;
    }
    return _collectionView;
}

- (void) initialize
{
    //1.创建会话层
    self.device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    
    // Input
    self.input = [AVCaptureDeviceInput deviceInputWithDevice:self.device error:nil];
    
    // Output
    self.captureOutput = [[AVCaptureStillImageOutput alloc] init];
    NSDictionary *outputSettings = [[NSDictionary alloc] initWithObjectsAndKeys:AVVideoCodecJPEG,AVVideoCodecKey,nil];
    [self.captureOutput setOutputSettings:outputSettings];
    
    // Session
    self.session = [[AVCaptureSession alloc]init];
    
    [self.session setSessionPreset:AVCaptureSessionPresetHigh];
    if ([self.session canAddInput:self.input])
    {
        [self.session addInput:self.input];
    }
    
    if ([self.session canAddOutput:_captureOutput])
    {
        [self.session addOutput:_captureOutput];
    }
    
    CGFloat viewWidth = self.view.frame.size.width;
    CGFloat viewHeight = viewWidth / 480 * 640;
    self.preview =[AVCaptureVideoPreviewLayer layerWithSession:self.session];
    self.preview.videoGravity = AVLayerVideoGravityResizeAspectFill;
    self.preview.frame = CGRectMake(0, 44,viewWidth, viewHeight);
    
    NSLog(@"%@",NSStringFromCGRect(self.view.frame));
    ZLCameraView *caramView = [[ZLCameraView alloc] initWithFrame:CGRectMake(0, 44, viewWidth, viewHeight)];
    caramView.backgroundColor = [UIColor clearColor];
    caramView.delegate = self;
    [self.view addSubview:caramView];
    [self.view.layer insertSublayer:self.preview atIndex:0];
    self.caramView = caramView;
}

- (void)cameraDidSelected:(ZLCameraView *)camera{
    [self.device lockForConfiguration:nil];
    [self.device setFocusMode:AVCaptureFocusModeAutoFocus];
    [self.device setFocusPointOfInterest:CGPointMake(50,50)];
    //操作完成后，记得进行unlock。
    [self.device unlockForConfiguration];
}

//对焦回调
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    if( [keyPath isEqualToString:@"adjustingFocus"] ){
        NSLog(@"qqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqq");
    }
}

- (void)viewDidLoad{
    [super viewDidLoad];
    
    [self initialize];
    [self setup];
    if (self.session) {
        [self.session startRunning];
    }
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [[UIApplication sharedApplication] setStatusBarHidden:YES];
}

- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    [[UIApplication sharedApplication] setStatusBarHidden:NO];
}

- (BOOL)prefersStatusBarHidden
{
    return YES;
}

#pragma mark 初始化按钮
- (UIButton *) setupButtonWithImageName : (NSString *) imageName andX : (CGFloat ) x{
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    [button setImage:[UIImage imageNamed:imageName] forState:UIControlStateNormal];
    button.backgroundColor = [UIColor clearColor];
    button.width = 80;
    button.y = 0;
    button.height = self.topView.height;
    button.x = x;
    [self.view addSubview:button];
    return button;
}

#pragma mark -初始化界面
- (void) setup{
    
    self.topView = [[UIView alloc] initWithFrame:CGRectZero];
    [self.topView setBackgroundColor:[UIColor blackColor]];
    [self.view addSubview:self.topView];
    
    /** flashImageView*/
    self.flashImageView = [[UIImageView alloc] initWithFrame:CGRectZero];
    [self.flashImageView setImage:[UIImage imageNamed:@"camera_close_icon"]];
    [self.topView addSubview:self.flashImageView];
    /** flash content*/
    UIView *flashContent = [[UIView alloc] initWithFrame:CGRectZero];
    [self.topView addSubview:flashContent];
    /** flash 自动*/
    UIButton *flashAuto = [[UIButton alloc] initWithFrame:CGRectZero];
    [flashAuto setTag:1001];
    [flashAuto setSelected:NO];
    [flashAuto setTitle:@"自动" forState:UIControlStateNormal];
    [flashAuto setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [flashAuto setTitleColor:XX_NAVIGATIONBAR_TINTCOLOR forState:UIControlStateSelected];
    [flashAuto addTarget:self action:@selector(flashCameraDevice:) forControlEvents:UIControlEventTouchUpInside];
    [self.topView addSubview:flashAuto];
    /** flash 打开*/
    UIButton *flashOpen = [[UIButton alloc] initWithFrame:CGRectZero];
    [flashOpen setTag:1002];
    [flashOpen setSelected:NO];
    [flashOpen setTitle:@"打开" forState:UIControlStateNormal];
    [flashOpen setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [flashOpen setTitleColor:XX_NAVIGATIONBAR_TINTCOLOR forState:UIControlStateSelected];
    [flashOpen addTarget:self action:@selector(flashCameraDevice:) forControlEvents:UIControlEventTouchUpInside];
    [self.topView addSubview:flashOpen];
    /** flash 关闭*/
    UIButton *flashClose = [[UIButton alloc] initWithFrame:CGRectZero];
    [flashClose setTag:1003];
    [flashClose setSelected:YES];
    [flashClose setTitle:@"关闭" forState:UIControlStateNormal];
    [flashClose setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [flashClose setTitleColor:XX_NAVIGATIONBAR_TINTCOLOR forState:UIControlStateSelected];
    [flashClose addTarget:self action:@selector(flashCameraDevice:) forControlEvents:UIControlEventTouchUpInside];
    [self.topView addSubview:flashClose];
    
    // 底部View
    self.controlView = [[UIView alloc] initWithFrame:CGRectZero];
    [self.controlView setBackgroundColor:[UIColor blackColor]];
    [self.view addSubview:self.controlView];
    //取消
    UIButton *cancalBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [cancalBtn setTitle:@"取消" forState:UIControlStateNormal];
    [cancalBtn addTarget:self action:@selector(cancel:) forControlEvents:UIControlEventTouchUpInside];
    [self.controlView addSubview:cancalBtn];
    //拍照
    UIButton *cameraBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    cameraBtn.showsTouchWhenHighlighted = YES;
    cameraBtn.imageView.contentMode = UIViewContentModeScaleAspectFit;
    [cameraBtn setImage:[UIImage imageNamed:@"camera_take_btn_normal"] forState:UIControlStateNormal];
    [cameraBtn setImage:[UIImage imageNamed:@"camera_take_btn_selected"] forState:UIControlStateHighlighted];
    [cameraBtn addTarget:self action:@selector(stillImage:) forControlEvents:UIControlEventTouchUpInside];
    [self.controlView addSubview:cameraBtn];
    // 切换摄像头
    UIButton *deviceBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [deviceBtn setBackgroundImage:[UIImage imageNamed:@"camera_exchange_btn_selected"] forState:UIControlStateNormal];
    [self.controlView addSubview:deviceBtn];
    [deviceBtn addTarget:self action:@selector(changeCameraDevice:) forControlEvents:UIControlEventTouchUpInside];
    
    [self.topView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.mas_equalTo(self.view);
        make.top.mas_equalTo(self.view);
        make.height.mas_offset(44);
    }];
    [self.flashImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(self.topView);
        make.left.mas_equalTo(10);
    }];
    [flashContent mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.mas_equalTo(self.topView);
        make.bottom.mas_equalTo(flashAuto);
        make.right.mas_equalTo(flashClose);
    }];
    [flashAuto mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.top.mas_equalTo(flashContent);
    }];
    [flashOpen mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(flashAuto);
        make.left.mas_equalTo(flashAuto.mas_right).mas_offset(57);
    }];
    [flashClose mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(flashOpen);
        make.left.mas_equalTo(flashOpen.mas_right).mas_offset(57);
    }];
    [self.controlView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.bottom.mas_equalTo(self.view);
        make.height.mas_equalTo(120);
    }];
    [cancalBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(self.controlView);
        make.left.mas_equalTo(self.controlView).mas_offset(20);
    }];
    [cameraBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.mas_equalTo(self.controlView);
    }];
    [deviceBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(cameraBtn);
        make.right.mas_equalTo(self.controlView).mas_offset(-20);
    }];
    
    AVCaptureFlashMode flashModel = [self.device flashMode];
    switch (flashModel)
    {
        case AVCaptureFlashModeOn:
            [self closeAllFlasBtn];
            [flashOpen setSelected:YES];
            [self.flashImageView setImage:[UIImage imageNamed:@"camera_open_icon"]];
            break;
        case AVCaptureFlashModeOff:
            [self closeAllFlasBtn];
            [flashClose setSelected:YES];
            [self.flashImageView setImage:[UIImage imageNamed:@"camera_close_icon"]];
            break;
        case AVCaptureFlashModeAuto:
            [self closeAllFlasBtn];
            [flashAuto setSelected:YES];
            [self.flashImageView setImage:[UIImage imageNamed:@"camera_auto_icon"]];
            break;
        default:
            [self closeAllFlasBtn];
            [flashClose setSelected:YES];
            [self.flashImageView setImage:[UIImage imageNamed:@"camera_close_icon"]];
            break;
    }
    
    // 完成
    if (self.cameraType == ZLCameraContinuous) {
//        UIButton *doneBtn = [UIButton buttonWithType:UIButtonTypeCustom];
//        doneBtn.frame = CGRectMake(self.view.width - 2 * margin - width, 0, width, controlView.height);
//        [doneBtn setTitle:@"完成" forState:UIControlStateNormal];
//        [doneBtn addTarget:self action:@selector(doneAction) forControlEvents:UIControlEventTouchUpInside];
//        [controlView addSubview:doneBtn];
    }
}

- (NSInteger ) numberOfSectionsInCollectionView:(UICollectionView *)collectionView{
    return 1;
}

- (NSInteger ) collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    return self.images.count;
}

- (UICollectionViewCell *) collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"cell" forIndexPath:indexPath];
    
    ZLCamera *camera = self.images[indexPath.item];
    
    ZLCameraImageView *lastView = [cell.contentView.subviews lastObject];
    if(![lastView isKindOfClass:[ZLCameraImageView class]]){
        // 解决重用问题
        UIImage *image = camera.thumbImage;
        ZLCameraImageView *imageView = [[ZLCameraImageView alloc] init];
        imageView.delegatge = self;
        imageView.edit = YES;
        imageView.image = image;
        imageView.frame = cell.bounds;
        imageView.contentMode = UIViewContentModeScaleAspectFill;
        [cell.contentView addSubview:imageView];
    }
    
    lastView.image = camera.thumbImage;
    
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    
    LGPhotoPickerBrowserViewController *browserVc = [[LGPhotoPickerBrowserViewController alloc] init];
    browserVc.dataSource = self;
    browserVc.delegate = self;
    browserVc.showType = LGShowImageTypeImageBroswer;
    browserVc.currentIndexPath = [NSIndexPath indexPathForItem:indexPath.item inSection:0];
    [self presentViewController:browserVc animated:NO completion:nil];
}


#pragma mark - <ZLPhotoPickerBrowserViewControllerDataSource>
- (NSInteger)photoBrowser:(LGPhotoPickerBrowserViewController *)photoBrowser numberOfItemsInSection:(NSUInteger)section{
    return self.images.count;
}

- (LGPhotoPickerBrowserPhoto *) photoBrowser:(LGPhotoPickerBrowserViewController *)pickerBrowser photoAtIndexPath:(NSIndexPath *)indexPath{
    
    id imageObj = [[self.images objectAtIndex:indexPath.row] photoImage];
    LGPhotoPickerBrowserPhoto *photo = [LGPhotoPickerBrowserPhoto photoAnyImageObjWith:imageObj];
    
    UICollectionViewCell *cell = (UICollectionViewCell *)[self.collectionView cellForItemAtIndexPath:[NSIndexPath indexPathForRow:indexPath.row inSection:0]];
    
    UIImageView *imageView = [[cell.contentView subviews] lastObject];
    photo.toView = imageView;
    photo.thumbImage = imageView.image;
    
    return photo;
}

- (void)deleteImageView:(ZLCameraImageView *)imageView{
    NSMutableArray *arrM = [self.images mutableCopy];
    for (ZLCamera *camera in self.images) {
        UIImage *image = camera.thumbImage;
        if ([image isEqual:imageView.image]) {
            [arrM removeObject:camera];
        }
    }
    self.images = arrM;
    [self.collectionView reloadData];
}

- (void)showPickerVc:(UIViewController *)vc{
    __weak typeof(vc)weakVc = vc;
    if (weakVc != nil) {
        [weakVc presentViewController:self animated:YES completion:nil];
    }
}

-(void)Captureimage
{
    //get connection
    AVCaptureConnection *videoConnection = nil;
    for (AVCaptureConnection *connection in self.captureOutput.connections) {
        for (AVCaptureInputPort *port in [connection inputPorts]) {
            if ([[port mediaType] isEqual:AVMediaTypeVideo] ) {
                videoConnection = connection;
                break;
            }
        }
        if (videoConnection) { break; }
    }
    
    //get UIImage
    [self.captureOutput captureStillImageAsynchronouslyFromConnection:videoConnection completionHandler:
     ^(CMSampleBufferRef imageSampleBuffer, NSError *error) {
         
         CFDictionaryRef exifAttachments =
         CMGetAttachment(imageSampleBuffer, kCGImagePropertyExifDictionary, NULL);
         if (exifAttachments) {
             // Do something with the attachments.
         }
         
         // Continue as appropriate.
         NSData *imageData = [AVCaptureStillImageOutput jpegStillImageNSDataRepresentation:imageSampleBuffer];
         UIImage *t_image = [UIImage imageWithData:imageData];
         t_image = [self cutImage:t_image];
         t_image = [self fixOrientation:t_image];
         NSData *data = UIImageJPEGRepresentation(t_image, 0.3);
         ZLCamera *camera = [[ZLCamera alloc] init];
         camera.photoImage = t_image;
         camera.thumbImage = [UIImage imageWithData:data];
         
         if (self.cameraType == ZLCameraSingle) {
             [self.images removeAllObjects];//由于当前只需要一张图片2015-11-6
             [self.images addObject:camera];
             [self displayImage:camera.photoImage];
         } else if (self.cameraType == ZLCameraContinuous) {
             [self.images addObject:camera];
             [self.collectionView reloadData];
             [self.collectionView selectItemAtIndexPath:[NSIndexPath indexPathForItem:self.images.count - 1 inSection:0] animated:YES scrollPosition:UICollectionViewScrollPositionRight];
         }
     }];
}

//裁剪image
- (UIImage *)cutImage:(UIImage *)srcImg {
    //注意：这个rect是指横屏时的rect，即屏幕对着自己，home建在右边
    CGRect rect = CGRectMake((srcImg.size.height / CGRectGetHeight(self.view.frame)) * 70, 0, srcImg.size.width * 1.33, srcImg.size.width);
    CGImageRef subImageRef = CGImageCreateWithImageInRect(srcImg.CGImage, rect);
    CGFloat subWidth = CGImageGetWidth(subImageRef);
    CGFloat subHeight = CGImageGetHeight(subImageRef);
    CGRect smallBounds = CGRectMake(0, 0, subWidth, subHeight);
    //旋转后，画出来
    CGAffineTransform transform = CGAffineTransformIdentity;
    transform = CGAffineTransformTranslate(transform, 0, subWidth);
    transform = CGAffineTransformRotate(transform, -M_PI_2);
    CGContextRef ctx = CGBitmapContextCreate(NULL, subHeight, subWidth,
                                             CGImageGetBitsPerComponent(subImageRef), 0,
                                             CGImageGetColorSpace(subImageRef),
                                             CGImageGetBitmapInfo(subImageRef));
    CGContextConcatCTM(ctx, transform);
    CGContextDrawImage(ctx, smallBounds, subImageRef);
    CGImageRef cgimg = CGBitmapContextCreateImage(ctx);
    UIImage *img = [UIImage imageWithCGImage:cgimg];
    
    CGContextRelease(ctx);
    CGImageRelease(cgimg);
    return img;
    
    
//    CGImageRef subImageRef = CGImageCreateWithImageInRect(srcImg.CGImage, rect);
//    CGRect smallBounds = CGRectMake(0, 0, CGImageGetWidth(subImageRef), CGImageGetHeight(subImageRef));
//    
//    UIGraphicsBeginImageContext(smallBounds.size);
//    CGContextRef context = UIGraphicsGetCurrentContext();
//    CGContextDrawImage(context, smallBounds, subImageRef);
//    UIImage* smallImage = [UIImage imageWithCGImage:subImageRef scale:1 orientation:UIImageOrientationRight];//由于直接从subImageRef中得到uiimage的方向是逆时针转了90°的
//    UIGraphicsEndImageContext();
//    CGImageRelease(subImageRef);
//    
//    return smallImage;
}

//旋转image
- (UIImage *)fixOrientation:(UIImage *)srcImg
{
    CGAffineTransform transform = CGAffineTransformIdentity;
    CGFloat width = srcImg.size.width;
    CGFloat height = srcImg.size.height;
    
    CGContextRef ctx;
    
    switch ([[UIDevice currentDevice] orientation]) {
        case UIDeviceOrientationUnknown:
        case UIDeviceOrientationFaceUp:
        case UIDeviceOrientationFaceDown:
        case UIDeviceOrientationPortrait:
        case UIDeviceOrientationPortraitUpsideDown: //竖屏，不旋转
            ctx = CGBitmapContextCreate(NULL, width, height,
                                        CGImageGetBitsPerComponent(srcImg.CGImage), 0,
                                        CGImageGetColorSpace(srcImg.CGImage),
                                        CGImageGetBitmapInfo(srcImg.CGImage));
            break;
            
        case UIDeviceOrientationLandscapeLeft:  //横屏，home键在右手边，逆时针旋转90°
            transform = CGAffineTransformTranslate(transform, height, 0);
            transform = CGAffineTransformRotate(transform, M_PI_2);
            ctx = CGBitmapContextCreate(NULL, height, width,
                                        CGImageGetBitsPerComponent(srcImg.CGImage), 0,
                                        CGImageGetColorSpace(srcImg.CGImage),
                                        CGImageGetBitmapInfo(srcImg.CGImage));
            break;
            
        case UIDeviceOrientationLandscapeRight:  //横屏，home键在左手边，顺时针旋转90°
            transform = CGAffineTransformTranslate(transform, 0, width);
            transform = CGAffineTransformRotate(transform, -M_PI_2);
            ctx = CGBitmapContextCreate(NULL, height, width,
                                        CGImageGetBitsPerComponent(srcImg.CGImage), 0,
                                        CGImageGetColorSpace(srcImg.CGImage),
                                        CGImageGetBitmapInfo(srcImg.CGImage));
            break;
            
        default:
            break;
    }
    
    CGContextConcatCTM(ctx, transform);
    CGContextDrawImage(ctx, CGRectMake(0,0,width,height), srcImg.CGImage);
    CGImageRef cgimg = CGBitmapContextCreateImage(ctx);
    UIImage *img = [UIImage imageWithCGImage:cgimg];
    
    CGContextRelease(ctx);
    CGImageRelease(cgimg);
    
    return img;
}

//LG
- (void)displayImage:(UIImage *)images {
    LGCameraImageView *view = [[LGCameraImageView alloc] initWithFrame:self.view.frame];
    view.delegate = self;
    view.imageOrientation = _imageOrientation;
    view.imageToDisplay = images;
    [self.view addSubview:view];
    
}

-(void)CaptureStillImage
{
    [self  Captureimage];
}

- (AVCaptureDevice *)cameraWithPosition:(AVCaptureDevicePosition)position
{
    NSArray *devices = [AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo];
    for ( AVCaptureDevice *device in devices )
        if ( device.position == position )
            return device;
    return nil;
}

- (void)changeCameraDevice:(id)sender
{
    // 翻转
    [UIView beginAnimations:@"animation" context:nil];
    [UIView setAnimationDuration:.5f];
    [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
    [UIView setAnimationTransition:UIViewAnimationTransitionFlipFromRight forView:self.view cache:YES];
    [UIView commitAnimations];
    
    NSArray *inputs = self.session.inputs;
    for ( AVCaptureDeviceInput *input in inputs ) {
        AVCaptureDevice *device = input.device;
        if ( [device hasMediaType:AVMediaTypeVideo] ) {
            AVCaptureDevicePosition position = device.position;
            AVCaptureDevice *newCamera = nil;
            AVCaptureDeviceInput *newInput = nil;
            
            if (position == AVCaptureDevicePositionFront)
                newCamera = [self cameraWithPosition:AVCaptureDevicePositionBack];
            else
                newCamera = [self cameraWithPosition:AVCaptureDevicePositionFront];
            newInput = [AVCaptureDeviceInput deviceInputWithDevice:newCamera error:nil];
            
            [self.session beginConfiguration];
            
            [self.session removeInput:input];
            [self.session addInput:newInput];
            
            // Changes take effect once the outermost commitConfiguration is invoked.
            [self.session commitConfiguration];
            break;
        }
    }
}

- (void) flashLightModel : (codeBlock) codeBlock{
    if (!codeBlock) return;
    [self.session beginConfiguration];
    [self.device lockForConfiguration:nil];
    codeBlock();
    [self.device unlockForConfiguration];
    [self.session commitConfiguration];
    [self.session startRunning];
}
- (void)closeAllFlasBtn
{
    [(UIButton *)[self.topView viewWithTag:1001] setSelected:NO];
    [(UIButton *)[self.topView viewWithTag:1002] setSelected:NO];
    [(UIButton *)[self.topView viewWithTag:1003] setSelected:NO];
}
- (void) flashCameraDevice:(UIButton *)sender
{
    if (_flashCameraState == 0 || _flashCameraState != sender.tag)
    {
        _flashCameraState = sender.tag;
        AVCaptureFlashMode mode;
        /** 统一改变状态*/
        [self closeAllFlasBtn];
        /** 改变选中按钮状态*/
        [sender setSelected:YES];
        
        switch (sender.tag-1000)
        {
            case 1:
                mode = AVCaptureFlashModeAuto;
                [self.flashImageView setImage:[UIImage imageNamed:@"camera_auto_icon"]];
                break;
            case 2:
                mode = AVCaptureFlashModeOn;
                [self.flashImageView setImage:[UIImage imageNamed:@"camera_open_icon"]];
                break;
            case 3:
                mode = AVCaptureFlashModeOff;
                [self.flashImageView setImage:[UIImage imageNamed:@"camera_close_icon"]];
                break;
            default:
                mode = AVCaptureFlashModeOff;
                [self.flashImageView setImage:[UIImage imageNamed:@"camera_close_icon"]];
                break;
        }
        if ([self.device isFlashModeSupported:mode])
        {
            [self flashLightModel:^{
                [self.device setFlashMode:mode];
            }];
        }
    }
}

- (void)cancel:(id)sender
{
    [self flashLightModel:^{
        [self.device setFlashMode:AVCaptureFlashModeOff];
    }];
    [self dismissViewControllerAnimated:YES completion:nil];
}

//拍照
- (void)stillImage:(id)sender
{
    // 判断图片的限制个数
    if (self.maxCount > 0 && self.images.count >= self.maxCount) {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"提示" message:[NSString stringWithFormat:@"拍照的个数不能超过%ld",(long)self.maxCount]delegate:nil cancelButtonTitle:@"好的" otherButtonTitles:nil, nil];
        [alertView show];
        return ;
    }
    
    [self Captureimage];
//    UIView *maskView = [[UIView alloc] init];
//    maskView.frame = self.view.bounds;
//    maskView.backgroundColor = [UIColor whiteColor];
//    [self.view addSubview:maskView];
//    [UIView animateWithDuration:.5 animations:^{
//        maskView.alpha = 0;
//    } completion:^(BOOL finished) {
//        [maskView removeFromSuperview];
//    }];
}

- (BOOL)shouldAutorotate{
    return YES;
}

#pragma mark - 屏幕
- (UIInterfaceOrientationMask)supportedInterfaceOrientations{
    return UIInterfaceOrientationMaskAll;
}
// 支持屏幕旋转
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation{
    return YES;
}
// 画面一开始加载时就是竖向
- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation{
    return UIInterfaceOrientationPortrait;
}

#pragma mark - XGCameraImageViewDelegate
- (void)xgCameraImageViewSendBtnTouched {
    [self doneAction];
}

- (void)xgCameraImageViewCancleBtnTouched {
    [self.images removeAllObjects];
}
//完成、取消
- (void)doneAction
{
    //关闭相册界面
    if(self.callback){
        self.callback(self.images);
    }
    [self cancel:nil];
}
@end

