//
//  XXGJAudioAlertView.m
//  xxdcchat_ios
//
//  Created by 刘朝龙 on 2017/4/12.
//  Copyright © 2017年 刘朝龙. All rights reserved.
//

#import "XXGJAudioAlertView.h"

@interface XXGJAudioAlertView ()
@property (weak, nonatomic) IBOutlet UIImageView *cancelLabelBgView;
@property (weak, nonatomic) IBOutlet UILabel *alertTitileLabel;
@property (weak, nonatomic) IBOutlet UIImageView *cancelImageView;
@property (weak, nonatomic) IBOutlet UIView *audioRecordView;
@property (weak, nonatomic) IBOutlet UIImageView *valueVolumeImageView;
@property (nonatomic, assign)AudioAlertViewStatus audioAlertViewStatus;

@property (nonatomic, assign)NSUInteger volumeValue;

@end

@implementation XXGJAudioAlertView
/**
 创建语音提示视图
 
 @param alertViewStatus 根据状态创建
 @return 返回视图
 */
+ (instancetype)audioAlertViewWithStatus:(AudioAlertViewStatus)alertViewStatus
{
    XXGJAudioAlertView *audioAlertView = [[NSBundle mainBundle] loadNibNamed:NSStringFromClass(self) owner:nil options:nil].lastObject;
    audioAlertView.audioAlertViewStatus = alertViewStatus;
    return audioAlertView;
}

/**
 改变提示视图样式
 
 @param alertViewStatus 改变样式
 */
- (void)setAudioAlertViewStatus:(AudioAlertViewStatus)alertViewStatus
{
    if (_audioAlertViewStatus != alertViewStatus)
    {
        _audioAlertViewStatus = alertViewStatus;
        switch (_audioAlertViewStatus) {
            case AudioAlertViewStatusCancel:
            {
                [self.alertTitileLabel setText:@"松开手指，取消发送"];
                [self.cancelImageView setImage:[UIImage imageNamed:@"RecordCancel"]];
                [self.cancelLabelBgView setHidden:NO];
                [self.cancelImageView setHidden:NO];
                [self.audioRecordView setHidden:YES];
            }
                break;
            case AudioAlertViewStatusShort:
            {
                [self.alertTitileLabel setText:@"说话时间太短"];
                [self.cancelImageView setImage:[UIImage imageNamed:@"MessageTooShort"]];
                [self.cancelImageView setHidden:NO];
                [self.cancelLabelBgView setHidden:YES];
                [self.audioRecordView setHidden:YES];
            }
                break;
            default:
            {
                [self.alertTitileLabel setText:@"手指上滑，取消发送"];
                [self.valueVolumeImageView setImage:[UIImage imageNamed:@"RecordingSignal001"]];
                [self.cancelLabelBgView setHidden:YES];
                [self.cancelImageView setHidden:YES];
                [self.audioRecordView setHidden:NO];
            }
                break;
        }
    }
}
/**
 改变音量
 
 @param volume 音量
 */
- (void)changeVolumeValue:(float)volume
{
    if (self.audioAlertViewStatus == AudioAlertViewStatusDefine || self.audioAlertViewStatus == AudioAlertViewStatusRecord)
    {
        NSInteger item = volume * 10 >= 1 ? volume * 10 : 1;
        NSMutableString *recordingSignalString = @"RecordingSignal00".mutableCopy;
        [recordingSignalString appendFormat:@"%ld", item < 9 ? item : 9];
        [self.valueVolumeImageView setImage:[UIImage imageNamed:recordingSignalString.copy]];
    }
    
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
