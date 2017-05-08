//
//  QXYChatToolBoxViewController.h
//  QXYChatMessageUI
//
//  Created by 刘朝龙 on 2017/3/14.
//  Copyright © 2017年 刘朝龙. All rights reserved.
//

#import "XXGJViewController.h"
#import <Masonry.h>
#import "QXYChatToolView.h"
#import <RecorderManager.h>

@protocol QXYChatTollBoxDelegate;

@interface QXYChatToolBoxViewController : XXGJViewController

@property (nonatomic, readonly, strong)QXYChatToolView *chatToolView;
@property (nonatomic, assign)id <QXYChatTollBoxDelegate> delegate;
@property (nonatomic, assign)QXYChatToolBoxState toolBoxState;
@property (nonatomic, strong)NSNumber *targetId;

+ (instancetype)chatToolBoxViewControllerIsGroup:(BOOL)isgroup;

#pragma mark - open method
- (void)setReocrdDelegate:(id<RecordingDelegate>)reocrdDelegate;
- (void)closeChatToolView;
- (void)changeVoiceState:(QXYVoiceState)voiceState;
- (void)startReocrd;
- (void)stopRecord;
- (void)cancelRecord;
@end

@protocol QXYChatTollBoxDelegate <NSObject>

- (void)chatToolBox:(QXYChatToolBoxViewController *)chatToolBox  changeOrigin:(BOOL)origin changeFrame:(CGFloat)height animationDurtion:(CGFloat)durtion;
- (void)chatToolBox:(QXYChatToolBoxViewController *)chatToolBox openOtherItem:(BOOL)select;
- (void)chatToolBox:(QXYChatToolBoxViewController *)chatToolBox sendMessage:(id)msg;
- (void)chatToolBox:(QXYChatToolBoxViewController *)chatToolBox startSendImageMessage:(id)msg;
- (void)chatToolBox:(QXYChatToolBoxViewController *)chatToolBox sendImageMessage:(id)msg progress:(NSProgress *)progress;
- (void)chatToolBox:(QXYChatToolBoxViewController *)chatToolBox endSendImageMessage:(id)msg;


@end
