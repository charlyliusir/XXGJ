//
//  XXGJLocationInfoTableViewCell.h
//  xxdcchat_ios
//
//  Created by 刘朝龙 on 2017/4/11.
//  Copyright © 2017年 刘朝龙. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "XXGJLocationInfo.h"

@interface XXGJLocationInfoTableViewCell : UITableViewCell

@property (nonatomic, strong)XXGJLocationInfo *locationInfo;
@property (nonatomic, assign)BOOL isSelected;

+ (instancetype)locationInfoCell:(UITableView *)tableView;

@end
