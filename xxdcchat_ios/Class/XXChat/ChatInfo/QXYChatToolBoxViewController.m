//
//  QXYChatToolBoxViewController.m
//  QXYChatMessageUI
//
//  Created by 刘朝龙 on 2017/3/14.
//  Copyright © 2017年 刘朝龙. All rights reserved.
//

#import "QXYChatToolBoxViewController.h"
#import <MobileCoreServices/MobileCoreServices.h>
#import <Masonry.h>
#import "LGPhotoPickerViewController.h"
#import "ZLCameraViewController.h"
#import "XXGJLocationViewController.h"
#import "XXGJSendRedEnvelopeViewController.h"
#import "LGPhotoAssets.h"
#import "XXGJMessage.h"

@interface QXYChatToolBoxViewController () <UINavigationControllerDelegate, UIImagePickerControllerDelegate,QXYChatToolViewDelegate, LGPhotoPickerViewControllerDelegate, XXGJLocationViewControllerDelegate, XXGJSendRedEnvelopeViewControllerDelegate>

@property (nonatomic, assign)BOOL isGroup;
@property (nonatomic, readwrite, strong)QXYChatToolView *chatToolView;
@property (nonatomic, strong)UIImagePickerController *pickerController;

@end

@implementation QXYChatToolBoxViewController

+ (instancetype)chatToolBoxViewControllerIsGroup:(BOOL)isgroup
{
    QXYChatToolBoxViewController *chatToolBoxVC = [[[NSBundle mainBundle] loadNibNamed:NSStringFromClass(self) owner:nil options:nil] firstObject];
    chatToolBoxVC.isGroup = isgroup;
    return chatToolBoxVC;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(willChangeFrame:) name:UIKeyboardWillChangeFrameNotification object:nil];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = [UIColor blueColor];
    
    // 隐藏录音按钮
    [self.view addSubview:self.chatToolView];
    [self.chatToolView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(self.view);
    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - lazy method
- (QXYChatToolView *)chatToolView
{
    if (!_chatToolView)
    {
        _chatToolView = [QXYChatToolView chatToolView];
        [_chatToolView setDelegate:self];
    }
    
    return _chatToolView;
}

- (UIImagePickerController *)pickerController
{
    if (!_pickerController)
    {
        _pickerController = [[UIImagePickerController alloc] init];
    }
    
    return _pickerController;
}

#pragma mark - open method
- (void)closeChatToolView
{
    [_chatToolView closeChatToolView];
}
- (void)changeVoiceState:(QXYVoiceState)voiceState
{
    [_chatToolView changeVoiceState:voiceState];
}
- (void)startReocrd
{
    [self changeVoiceState:QXYVoiceStateSelect];
    /** 开始录音*/
    [[RecorderManager sharedManager] startRecording];
}
- (void)stopRecord
{
    [self changeVoiceState:QXYVoiceStateNormal];
    [[RecorderManager sharedManager] stopRecording];
}
- (void)cancelRecord
{
    [self changeVoiceState:QXYVoiceStateNormal];
    [[RecorderManager sharedManager] cancelRecording];
}
- (void)setReocrdDelegate:(id<RecordingDelegate>)reocrdDelegate
{
    [[RecorderManager sharedManager] setDelegate:reocrdDelegate];
}

#pragma mark - private method
- (void)openSystemPhotoAlbum
{
    LGPhotoPickerViewController *pickerVc = [[LGPhotoPickerViewController alloc] initWithShowType:LGShowImageTypeImagePicker];
    pickerVc.status = PickerViewShowStatusCameraRoll;
    pickerVc.maxCount = 1;   // 最多能选9张图片
    pickerVc.delegate = self;
    [pickerVc showPickerVc:self];
    
//    [self.pickerController setSourceType:UIImagePickerControllerSourceTypeSavedPhotosAlbum];
//    [self.pickerController setDelegate:self];
//    [self presentViewController:self.pickerController animated:YES completion:nil];
}

- (void)openCamera
{
    
    ZLCameraViewController *cameraVC = [[ZLCameraViewController alloc] init];
    // 拍照最多个数
    cameraVC.maxCount = 1;
    // 单拍
    cameraVC.cameraType = ZLCameraSingle;
    cameraVC.callback = ^(NSArray *cameras){
        //在这里得到拍照结果
        //数组元素是ZLCamera对象
        /*
         @exemple
         ZLCamera *canamerPhoto = cameras[0];
         UIImage *image = canamerPhoto.photoImage;
         */
        ZLCamera *cameraPhoto = cameras[0];
        [self sendImageMessage:cameraPhoto.photoImage];
    };
    [cameraVC showPickerVc:self];
    
//    [self.pickerController setSourceType:UIImagePickerControllerSourceTypeCamera];
//    [self.pickerController setMediaTypes:@[(NSString *)kUTTypeImage]];
//    [self.pickerController setCameraCaptureMode:UIImagePickerControllerCameraCaptureModePhoto];
//    [self.pickerController setDelegate:self];
//    [self presentViewController:self.pickerController animated:YES completion:nil];
}

- (void)shareLocation
{
    XXGJLocationViewController *locationVC = [XXGJLocationViewController locationViewControllerComeBackBlock:^(XXGJMessage *message)
    {
        if (self.delegate && [self.delegate respondsToSelector:@selector(chatToolBox:sendMessage:)]) {
            [self.delegate chatToolBox:self sendMessage:message];
        }
    }];
    UINavigationController *naviController = [[UINavigationController alloc] initWithRootViewController:locationVC];
    [self presentViewController:naviController animated:YES completion:nil];
}

- (void)sendRedEnvelope
{
    XXGJSendRedEnvelopeViewController *sendRedEnvelopeVC = [XXGJSendRedEnvelopeViewController sendRedEnvelopeViewControllerWithMethod:self.isGroup?SendRedEnvelopeMethodGroup:SendRedEnvelopeMethodFriend];
    sendRedEnvelopeVC.targetId = self.targetId;
    sendRedEnvelopeVC.delegate = self;
    UINavigationController *navigationVC = [[UINavigationController alloc] initWithRootViewController:sendRedEnvelopeVC];
    [self presentViewController:navigationVC animated:YES completion:nil];
}

/**
 压图片质量
 
 @param image image
 @return Data
 */
- (NSData *)zipImageWithImage:(UIImage *)image
{
    if (!image) {
        return nil;
    }
    CGFloat maxFileSize = 32*1024;
    CGFloat compression = 0.9f;
    NSData *compressedData = UIImageJPEGRepresentation(image, compression);
    while ([compressedData length] > maxFileSize) {
        compression *= 0.9;
        compressedData = UIImageJPEGRepresentation([self compressImage:image newWidth:image.size.width*compression], compression);
    }
    return compressedData;
}

/**
 *  等比缩放本图片大小
 *
 *  @param newImageWidth 缩放后图片宽度，像素为单位
 *
 *  @return self-->(image)
 */
- (UIImage *)compressImage:(UIImage *)image newWidth:(CGFloat)newImageWidth
{
    if (!image) return nil;
    float imageWidth = image.size.width;
    float imageHeight = image.size.height;
    float width = newImageWidth;
    float height = image.size.height/(image.size.width/width);
    
    float widthScale = imageWidth /width;
    float heightScale = imageHeight /height;
    
    // 创建一个bitmap的context
    // 并把它设置成为当前正在使用的context
    UIGraphicsBeginImageContext(CGSizeMake(width, height));
    
    if (widthScale > heightScale) {
        [image drawInRect:CGRectMake(0, 0, imageWidth /heightScale , height)];
    }
    else {
        [image drawInRect:CGRectMake(0, 0, width , imageHeight /widthScale)];
    }
    
    // 从当前context中创建一个改变大小后的图片
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    // 使当前的context出堆栈
    UIGraphicsEndImageContext();
    
    return newImage;
    
}

- (NSString *)getFilePath:(NSString *)floder fileName:(NSString *)fileName
{
    /** 将图片缓存到本地*/
    NSString *imagefloder = [[NSString cacheStore] appendFileStore:floder];
    /** 创建文件夹*/
    if ([NSString createFilePath:imagefloder])
    {
        return [imagefloder stringByAppendingPathComponent:fileName];
    }
    
    return nil;
}

#pragma mark - notify method
- (void)willChangeFrame:(NSNotification *)notification
{
    NSDictionary *dict = notification.userInfo;
    
    // 记录动画时长
    CGFloat animationDuration = [dict[@"UIKeyboardAnimationDurationUserInfoKey"] floatValue];
    CGFloat beginOriginY = [dict[@"UIKeyboardFrameBeginUserInfoKey"] CGRectValue].origin.y;
    CGFloat endOriginY = [dict[@"UIKeyboardFrameEndUserInfoKey"] CGRectValue].origin.y;
    CGFloat height     = [dict[@"UIKeyboardFrameEndUserInfoKey"] CGRectValue].size.height;
    

    NSLog(@"will change frame height : %lf", endOriginY-beginOriginY);
    
    // 获取键盘的最终高度，然后通知更新UI
    if (self.delegate && [self.delegate respondsToSelector:@selector(chatToolBox:changeOrigin:changeFrame:animationDurtion:)]) {
        BOOL origin = endOriginY-beginOriginY > 0 ? YES : NO;
        [self.delegate chatToolBox:self
                      changeOrigin:origin
                       changeFrame:height
                  animationDurtion:animationDuration];
    }
}

#pragma mark - delegate
#pragma mark - red envelope delegate
- (void)sendRedEnvelopeMessage:(XXGJMessage *)redEnvelopeMessage
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(chatToolBox:sendMessage:)]) {
        [self.delegate chatToolBox:self sendMessage:redEnvelopeMessage];
    }
}

#pragma mark - location delegate
/**
 发送定位消息
 
 @param message 定位消息
 */
- (void)sendLocationMessage:(XXGJMessage *)message
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(chatToolBox:sendMessage:)]) {
        [self.delegate chatToolBox:self sendMessage:message];
    }
}

#pragma mark - chat tool view delegate

/**
 发送一条文本信息

 @param chatToolView 聊天工具视图
 @param msgText 发送内容
 */
- (void)chatToolView:(QXYChatToolView *)chatToolView sendMessage:(NSString *)msgText
{
    // 这里发送一个文本信息
    XXGJMessage *message = [[XXGJMessage alloc] init];
    message.Content      = msgText;
    message.MessageType  = @(XXGJTextMessage);
    if (self.delegate && [self.delegate respondsToSelector:@selector(chatToolBox:sendMessage:)]) {
        [self.delegate chatToolBox:self sendMessage:message];
    }
}

- (void)chatToolView:(QXYChatToolView *)chatToolView openOtherItem:(BOOL)select
{
    if (self.delegate&&[self.delegate respondsToSelector:@selector(chatToolBox:openOtherItem:)])
    {
        [self.delegate chatToolBox:self openOtherItem:select];
    }
}

- (void)chatToolView:(QXYChatToolView *)chatToolView didSelectOtherItem:(QXYChatToolBoxOtherItem)item
{
    // 这里经过处理
    switch (item) {
        case QXYChatToolBoxOtherItemPhoto:
            [self openSystemPhotoAlbum];
            break;
        case QXYChatToolBoxOtherItemTakePhoto:
            [self openCamera];
            break;
        case QXYChatToolBoxOtherItemLocation:
            [self shareLocation];
            break;
        case QXYChatToolBoxOtherItemRedEnvelop:
            [self sendRedEnvelope];
            break;
        default:
            break;
    }
}

#pragma mark - photo album delegate
/**
 *  返回所有的Asstes对象
 */
- (void)pickerViewControllerDoneAsstes:(NSArray *)assets isOriginal:(BOOL)original
{
    LGPhotoAssets *photoAsset = assets[0];
    [self sendImageMessage:photoAsset.compressionImage];
}
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (void)sendImageMessage:(UIImage *)image
{
    [MBProgressHUD showLoadHUDIndeterminate:@"正在选择图片" during:0.5];
    // 压缩图片
    NSData *fileData = UIImageJPEGRepresentation(image, 1.0f);
    
    NSString *newDate = [NSDate dateForDateFormatter:@"yyyy-MM-dd HH:mm:ss"];
    NSString *localPath = [self getFilePath:@"xx_caches_image" fileName:newDate];
    /** 保持图片到地址*/
    [fileData writeToFile:localPath atomically:YES];
    /** 图片参数*/
    float width  = image.size.width;
    float height = image.size.height;
    float lenth  = fileData.length;
    float size   = round(lenth/1024.f*100)/100;
    /** 提示有新的图片*/
    XXGJMessage *message = [[XXGJMessage alloc] init];
    message.MessageType  = @(XXGJImageMessage);
    [message addArgsObject:@{XXGJ_ARGS_PARAM_BITMPTIME:@""}];
    [message addArgsObject:@{XXGJ_ARGS_PARAM_BITMPHEIGHT:@(height)}];
    [message addArgsObject:@{XXGJ_ARGS_PARAM_BITMPWIDTH:@(width)}];
    [message addArgsObject:@{XXGJ_ARGS_PARAM_BITMPSIZE:@(size)}];
    [message addArgsObject:@{XXGJ_ARGS_PARAM_UPDATETIME:newDate}];
    if (localPath)
    {
        [message addArgsObject:@{XXGJ_ARGS_PARAM_IMAGEURL:localPath}];
        message.Content = localPath;
    }
    
    /** 更新界面*/
    if (self.delegate && [self.delegate respondsToSelector:@selector(chatToolBox:startSendImageMessage:)]) {
        [self.delegate chatToolBox:self startSendImageMessage:message];
    }
    [MBProgressHUD showLoadHUDText:@"选择成功" during:0.5];
    [XXGJNetKit uploadImageWithData:fileData rProgress:^(NSProgress *downloadProgress) {
        
        if (self.delegate && [self.delegate respondsToSelector:@selector(chatToolBox:sendImageMessage:progress:)]) {
            [self.delegate chatToolBox:self sendImageMessage:message progress:downloadProgress];
        }
    } rBlock:^(id obj, BOOL success, NSError *error) {
        
        if (success && obj && [obj[@"status"][@"msg"] isEqualToString:@"success"])
        {
            NSDictionary *data = obj[@"data"];
            [message addArgsObject:@{XXGJ_ARGS_PARAM_IMAGEURL:data[@"url"]}];
            message.Content = data[@"url"];
            if (self.delegate && [self.delegate respondsToSelector:@selector(chatToolBox:endSendImageMessage:)])
            {
                [self.delegate chatToolBox:self endSendImageMessage:message];
            }
        } else
            /** 上传失败*/
        {
            NSLog(@"上传失败...");
        }
        
    }];
}

@end
