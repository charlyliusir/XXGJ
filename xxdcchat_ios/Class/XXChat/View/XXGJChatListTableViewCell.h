//
//  XXGJChatListTableViewCell.h
//  xxdcchat_ios
//
//  Created by 刘朝龙 on 2017/3/16.
//  Copyright © 2017年 刘朝龙. All rights reserved.
//

#import "XXGJTableViewCell.h"
#import "XXGJChatItemList.h"

@interface XXGJChatListTableViewCell : XXGJTableViewCell

@property (nonatomic, strong)XXGJChatItemList *chatItemList;

+ (instancetype)chatItemListCell:(UITableView *)tableView;

@end
