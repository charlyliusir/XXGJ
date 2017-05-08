//
//  XXGJGroupItemTableViewCell.h
//  xxdcchat_ios
//
//  Created by 刘朝龙 on 2017/4/3.
//  Copyright © 2017年 刘朝龙. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, GroupItemStyle) {
    GroupItemStyleOnlyTitle,
    GroupItemStyleTitleInfo,
    GroupItemStyleAll
};

@interface XXGJGroupItemTableViewCell : UITableViewCell

@property (nonatomic,   copy)NSString *itemTitle;
@property (nonatomic,   copy)NSString *itemInfo;
@property (nonatomic, assign)GroupItemStyle itemStyle;

+ (instancetype)groupItemCell:(UITableView *)tableView;

- (void)setHiddenBottomLine:(BOOL)hidden;
- (void)setStyle;

@end
