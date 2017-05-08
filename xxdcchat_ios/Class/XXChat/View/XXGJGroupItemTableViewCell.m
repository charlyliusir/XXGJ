//
//  XXGJGroupItemTableViewCell.m
//  xxdcchat_ios
//
//  Created by 刘朝龙 on 2017/4/3.
//  Copyright © 2017年 刘朝龙. All rights reserved.
//

#import "XXGJGroupItemTableViewCell.h"

@interface XXGJGroupItemTableViewCell ()
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *infoLabel;
@property (weak, nonatomic) IBOutlet UILabel *arrowImageView;
@property (weak, nonatomic) IBOutlet UIView *bottomLineView;

@end


@implementation XXGJGroupItemTableViewCell

+ (instancetype)groupItemCell:(UITableView *)tableView
{
    NSString *identifier = @"groupitem";
    XXGJGroupItemTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if (!cell) {
        cell = [[[NSBundle mainBundle] loadNibNamed:NSStringFromClass(self) owner:nil options:nil] lastObject];
    }
    return cell;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setItemStyle:(GroupItemStyle)itemStyle
{
    _itemStyle = itemStyle;
    
    switch (_itemStyle) {
        case GroupItemStyleAll:
        {
            [self.titleLabel setHidden:NO];
            [self.infoLabel setHidden:NO];
            [self.arrowImageView setHidden:NO];
            [self.titleLabel setTextColor:XX_RGBCOLOR_WITHOUTA(51, 51, 51)];
        }
            break;
        case GroupItemStyleOnlyTitle:
        {
            [self.titleLabel setHidden:NO];
            [self.infoLabel setHidden:YES];
            [self.arrowImageView setHidden:YES];
            [self.titleLabel setTextColor:XX_RGBCOLOR_WITHOUTA(14, 170, 159)];
        }
            break;
        case GroupItemStyleTitleInfo:
        {
            [self.titleLabel setHidden:NO];
            [self.infoLabel setHidden:NO];
            [self.arrowImageView setHidden:YES];
            [self.titleLabel setTextColor:XX_RGBCOLOR_WITHOUTA(51, 51, 51)];
            
        }
            break;
        default:
            break;
    }
    
}

- (void)setHiddenBottomLine:(BOOL)hidden
{
    [self.bottomLineView setHidden:hidden];
}

- (void)setStyle
{
    [self.titleLabel setText:self.itemTitle];
    if (![self.infoLabel isHidden])
    {
        [self.infoLabel setText:self.itemInfo];
    }
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
