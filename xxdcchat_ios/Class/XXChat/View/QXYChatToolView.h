//
//  QXYChatToolView.h
//  QXYChatMessageUI
//
//  Created by 刘朝龙 on 2017/3/14.
//  Copyright © 2017年 刘朝龙. All rights reserved.
//

#import <UIKit/UIKit.h>
#define QXY_CHAT_TOOL_VIEW_HEIGHT 48

@protocol QXYChatToolViewDelegate;

typedef NS_ENUM(NSInteger, QXYVoiceState) {
    QXYVoiceStateNormal,
    QXYVoiceStateSelect,
    QXYVoiceStateClose,
};

typedef NS_ENUM(NSInteger, QXYChatToolBoxState) {
    QXYChatToolBoxStateKeyBoard,
    QXYChatToolBoxStateKeyVoice,
    QXYChatToolBoxStateKeyOther,
};

typedef NS_ENUM(NSInteger, QXYChatToolBoxOtherItem) {
    QXYChatToolBoxOtherItemPhoto,
    QXYChatToolBoxOtherItemTakePhoto,
    QXYChatToolBoxOtherItemPhone,
    QXYChatToolBoxOtherItemRedEnvelop,
    QXYChatToolBoxOtherItemLocation,
    QXYChatToolBoxOtherItemFlow,
    QXYChatToolBoxOtherItemPhotoDecorate
};

@interface QXYChatToolView : UIView

@property (weak, readonly, nonatomic) IBOutlet UIView *chatRecordContentView;
@property (nonatomic, assign)id <QXYChatToolViewDelegate> delegate;

+ (instancetype)chatToolView;

#pragma mark - open method

/**
 根据当前语音状态,修改语音按钮中对应的文字

 @param voiceState 语音状态
 */
- (void)changeVoiceState:(QXYVoiceState)voiceState;

/**
 关闭其他视图
 */
- (void)closeChatToolView;
@end

@protocol QXYChatToolViewDelegate <NSObject>

@optional
- (void)chatToolView:(QXYChatToolView *)chatToolView sendMessage:(NSString *)msgText;
- (void)chatToolView:(QXYChatToolView *)chatToolView openOtherItem:(BOOL)select;
- (void)chatToolView:(QXYChatToolView *)chatToolView exchangBoxState:(QXYChatToolBoxState)boxState;
- (void)chatToolView:(QXYChatToolView *)chatToolView didSelectOtherItem:(QXYChatToolBoxOtherItem)item;

@end
