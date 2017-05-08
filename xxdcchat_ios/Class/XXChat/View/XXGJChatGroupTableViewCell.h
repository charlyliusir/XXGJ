//
//  XXGJChatGroupTableViewCell.h
//  xxdcchat_ios
//
//  Created by 刘朝龙 on 2017/3/18.
//  Copyright © 2017年 刘朝龙. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "XXGJChatGroupItem.h"

@interface XXGJChatGroupTableViewCell : UITableViewCell

@property (nonatomic, strong)XXGJChatGroupItem *chatGroupItem;

+ (instancetype)chatGroupItemListCell:(UITableView *)tableView;

@end
