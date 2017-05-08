//
//  XXGJChatRechTextViewCell.h
//  xxdcchat_ios
//
//  Created by 刘朝龙 on 2017/4/5.
//  Copyright © 2017年 刘朝龙. All rights reserved.
//

#import "XXGJChatBaseTableViewCell.h"
#import "DTAttributedTextContentView.h"
#import <DTFoundation/DTWeakSupport.h>

@interface XXGJChatRechTextViewCell : XXGJChatBaseTableViewCell

/**
 Creates a tableview cell with a given reuse identifier.
 @returns A prepared cell
 */
+ (instancetype)chatRechTextCell:(UITableView *)tableView cellStyle:(ChatCellStyle)style;

@end
