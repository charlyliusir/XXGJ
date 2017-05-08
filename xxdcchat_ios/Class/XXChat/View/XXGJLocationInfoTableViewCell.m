//
//  XXGJLocationInfoTableViewCell.m
//  xxdcchat_ios
//
//  Created by 刘朝龙 on 2017/4/11.
//  Copyright © 2017年 刘朝龙. All rights reserved.
//

#import "XXGJLocationInfoTableViewCell.h"

@interface XXGJLocationInfoTableViewCell ()
@property (weak, nonatomic) IBOutlet UILabel *locationNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *locationAddressLabel;
@property (weak, nonatomic) IBOutlet UIImageView *selectedImageView;


@end

@implementation XXGJLocationInfoTableViewCell
+ (instancetype)locationInfoCell:(UITableView *)tableView
{
    NSString *identifier = @"locationInfo";
    XXGJLocationInfoTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if (!cell) {
        cell = [[[NSBundle mainBundle] loadNibNamed:NSStringFromClass(self) owner:nil options:nil] lastObject];
    }
    return cell;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

#pragma mark - open method

/**
 cell 是否被选中

 @param isSelected 是否被选中
 */
- (void)setIsSelected:(BOOL)isSelected
{
    _isSelected = isSelected;
    [self.selectedImageView setHidden:!_isSelected];
}

/**
 cell 内容 model

 @param locationInfo model
 */
- (void)setLocationInfo:(XXGJLocationInfo *)locationInfo
{
    _locationInfo = locationInfo;
    
    /** 地址名称*/
    [self.locationNameLabel setText:_locationInfo.name];
    /** 地址信息*/
    [self.locationAddressLabel setText:_locationInfo.address];
}
@end
