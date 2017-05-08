//
//  XXGJChatItemTableViewCell.h
//  xxdcchat_ios
//
//  Created by 刘朝龙 on 2017/3/16.
//  Copyright © 2017年 刘朝龙. All rights reserved.
//

#import "XXGJTableViewCell.h"
#import "XXGJChatItem.h"
@class User;

@interface XXGJChatItemTableViewCell : XXGJTableViewCell

@property (nonatomic, strong)XXGJChatItem *chatItem;
@property (nonatomic, strong)User *itemUser;

+ (instancetype)chatItemCell:(UITableView *)tableView  hasSelectBtn:(BOOL)hasSelectBtn;

@end
