//
//  QXYChatContentViewController.h
//  QXYChatMessageUI
//
//  Created by 刘朝龙 on 2017/3/14.
//  Copyright © 2017年 刘朝龙. All rights reserved.
//

#import "XXGJViewController.h"
#import "XXGJAudioAlertView.h"
#import <Masonry.h>

@class XXGJChatMessage;

@protocol QXYChatContentDelegate <NSObject>

@optional
/**
 开始拖拽表格

 @param chatContentVC 控制器
 */
- (void)willDragContent:(id)chatContentVC;

/**
 拖拽表格超限

 @param chatContentVC 控制器
 */
- (void)overDragContent:(id)chatContentVC;


/**
 下拉加载更多
 */
- (void)refreshHeader:(id)chatContentVC;

@end

@interface QXYChatContentViewController : XXGJViewController

@property (nonatomic, assign)id <QXYChatContentDelegate> delegate;
@property (nonatomic, strong)NSMutableArray *msgsArray;

+ (instancetype)chatContentViewController;
#pragma mark - open method
/**
 清空用户所有聊天记录
 */
- (void)clearUserMessage;
/**
 刷新数据
 */
- (void)reloadData;

/**
 刷新数据结束
 */
- (void)refreshData:(NSInteger)index;

/**
 没有更多消息数据了
 */
- (void)noMoreMessage;

/**
 展示数据滚动到底
 */
- (void)scrollToBottom:(BOOL)animated;

/**
 更新模型的进度

 @param msg 模型信息
 @param progress 进度
 */
- (XXGJChatMessage *)updateMessage:(id)msg progress:(NSProgress *)progress;

/**
 停止当前播放的录音
 */
- (void)stopAudioPlay;

/**
 更新语音提示样式

 @param state 样式
 */
- (void)showRecordAudioUI:(AudioAlertViewStatus)state;

/**
 隐藏提示视图
 */
- (void)dismissRecordAudioUI;

/**
 监听更新音量

 @param volumeValue 音量
 */
- (void)listenAudioVolumeValue:(float)volumeValue;

@end
