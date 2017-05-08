//
//  XXGJChatBaseTableViewCell.h
//  xxdcchat_ios
//
//  Created by 刘朝龙 on 2017/3/19.
//  Copyright © 2017年 刘朝龙. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Masonry.h>
#import <UIButton+WebCache.h>
#import <UIImageView+WebCache.h>
#import "XXGJChatMessage.h"
@protocol XXGJChatTableViewCellDelegate;

#define CHAT_USERICON_WIDTH  40
#define CHAT_USERICON_HEIGHT 40

#define LESS_WIDTH ([UIScreen mainScreen].bounds.size.width-120)

typedef NS_ENUM(NSUInteger, ChatCellEditStyle) {
    ChatCellEditStyleDel,
    ChatCellEditStyleDrawn,
    ChatCellEditStyleReSend
};

@interface XXGJChatBaseTableViewCell : UITableViewCell
@property (nonatomic, assign)id <XXGJChatTableViewCellDelegate>delegate;
@property (nonatomic, strong)XXGJChatMessage *chatMessage;
@property (nonatomic, readonly, strong)UIView *timeContentView;
@property (nonatomic, readonly, strong)UILabel *timeLabel;
@property (nonatomic, readonly, strong)UILabel *userName;
@property (nonatomic, readonly, strong)UIButton *userIconImage;
@property (nonatomic, readonly, strong)UIImageView *nodeBoardImage;
@property (nonatomic, readonly, strong)UIActivityIndicatorView * activityIndicatorView;
@property (nonatomic, readonly, strong)UIButton *reSendBtn;
@property (nonatomic, strong)NSMutableArray *menuItemArray;

@property (nonatomic, assign)CGFloat height;

@property (nonatomic, assign)ChatCellStyle chatCellStyle;

+ (instancetype)chatBaseCell:(UITableView *)tableView;
- (void)setMessage:(XXGJChatMessage *)msg;

- (void)layoutMeUI;
- (void)layoutOtherUI;
// MAKE-菜单方法
- (void)editTextMessage:(UILongPressGestureRecognizer *)longPressGR;
- (void)deleteItemClicked:(id)sender;
- (void)copyItemClicked:(id)sender;
- (void)drawnMessageClicked:(id)sender;
@end

@protocol XXGJChatTableViewCellDelegate <NSObject>

@optional

/**
 点击语音信息执行

 @param chatTableViewCell cell
 @param audioRecord 语音信息
 */
- (void)chatTableViewCell:(XXGJChatBaseTableViewCell *)chatTableViewCell
         checkAudioRecord:(id)audioRecord;

/**
 点击定位信息执行，查看定位信息

 @param chatTableViewCell cell
 @param locationModel 定位信息
 */
- (void)chatTableViewCell:(XXGJChatBaseTableViewCell *)chatTableViewCell
          openMapLocation:(id)locationModel;

/**
 点击图片执行， 查看图片大图

 @param chatTableViewCell cell
 @param imageUrl 图片网上地址
 @param img 图片
 */
- (void)chatTableViewCell:(XXGJChatBaseTableViewCell *)chatTableViewCell
             openImageUrl:(NSURL *)imageUrl
                    image:(UIImage *)img;

/**
 打开红包执行

 @param chatTableViewCell cell
 @param chatMessage 聊天信息
 */
- (void)chatTableViewCell:(XXGJChatBaseTableViewCell *)chatTableViewCell
          openRedEnvelope:(XXGJChatMessage*)chatMessage;

/**
 点击用户头像执行

 @param chatTableViewCell cell
 @param chatMessage 聊天信息
 */
- (void)chatTableViewCell:(XXGJChatBaseTableViewCell *)chatTableViewCell
               goUserInfo:(XXGJChatMessage*)chatMessage;

/**
 菜单方法执行

 @param chatTableViewCell cell
 @param chatMessage 聊天信息
 @param editStyle 菜单方法类型
 */
- (void)chatTableViewCell:(XXGJChatBaseTableViewCell *)chatTableViewCell
          editTextMessage:(XXGJChatMessage*)chatMessage
                 editType:(ChatCellEditStyle)editStyle;

/**
 点击cell中链接执行

 @param chatTableViewCell cell
 @param linkUrl 链接
 */
- (void)chatTableViewCell:(XXGJChatBaseTableViewCell *)chatTableViewCell
             checkLinkUrl:(NSURL *)linkUrl;

@end
