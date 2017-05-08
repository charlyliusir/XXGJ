//
//  XXGJChatTextTableViewCell.h
//  xxdcchat_ios
//
//  Created by 刘朝龙 on 2017/3/19.
//  Copyright © 2017年 刘朝龙. All rights reserved.
//

#import "XXGJChatBaseTableViewCell.h"

@interface XXGJChatTextTableViewCell : XXGJChatBaseTableViewCell

+ (instancetype)chatTextCell:(UITableView *)tableView cellStyle:(ChatCellStyle)style;

- (void)setMessage:(XXGJChatMessage *)msg;

@end
