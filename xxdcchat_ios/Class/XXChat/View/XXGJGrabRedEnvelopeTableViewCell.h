//
//  XXGJGrabRedEnvelopeTableViewCell.h
//  xxdcchat_ios
//
//  Created by 刘朝龙 on 2017/4/26.
//  Copyright © 2017年 刘朝龙. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "XXGJGrabRedEnvelopeItem.h"

@interface XXGJGrabRedEnvelopeTableViewCell : UITableViewCell

@property (nonatomic, strong)XXGJGrabRedEnvelopeItem *grapRedEnvelopeItem;

+ (instancetype)grabRedEnvelopeCell:(UITableView *)tableView;

@end
