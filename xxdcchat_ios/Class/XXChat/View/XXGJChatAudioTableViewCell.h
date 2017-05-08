//
//  XXGJChatAudioTableViewCell.h
//  xxdcchat_ios
//
//  Created by 刘朝龙 on 2017/4/12.
//  Copyright © 2017年 刘朝龙. All rights reserved.
//

#import "XXGJChatBaseTableViewCell.h"

@interface XXGJChatAudioTableViewCell : XXGJChatBaseTableViewCell

- (void)startPlayAnimation;
- (void)stopPlayAnimation;
+ (instancetype)chatAudioCell:(UITableView *)tableView cellStyle:(ChatCellStyle)style;

@end
