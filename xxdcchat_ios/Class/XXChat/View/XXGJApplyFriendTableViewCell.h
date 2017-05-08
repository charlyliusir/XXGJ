//
//  XXGJApplyFriendTableViewCell.h
//  xxdcchat_ios
//
//  Created by 刘朝龙 on 2017/4/24.
//  Copyright © 2017年 刘朝龙. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "XXGJApplyFriendItem.h"
@class Message;

@protocol XXGJApplyFriendTableViewCellDelegate <NSObject>

/**
 同意添加好友

 @param applyFriendMessage 添加好友请求信息
 */
- (void)agreeApplyFriendMessage:(Message *)applyFriendMessage;

@end

@interface XXGJApplyFriendTableViewCell : UITableViewCell
/** delegate*/
@property (nonatomic, assign)id <XXGJApplyFriendTableViewCellDelegate>delegate;
/** 添加好友cell的model字段*/
@property (nonatomic, strong)XXGJApplyFriendItem *applyFriendItem;
/** 是不是最后一个cell*/
@property (nonatomic, assign)BOOL lastCell;
/** 请求添加好友的消息*/
@property (nonatomic, strong)Message *applyMessage;

+ (instancetype)applyFriendTableViewCell:(UITableView *)tableView;

@end
