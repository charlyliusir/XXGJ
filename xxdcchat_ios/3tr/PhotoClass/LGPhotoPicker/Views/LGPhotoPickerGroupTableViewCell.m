//
//  LGPickerGroupTableViewCell.m
//  LGPhotoBrowser
//
//  Created by ligang on 15/10/27.
//  Copyright (c) 2015年 L&G. All rights reserved.

#import "LGPhotoPickerGroupTableViewCell.h"
#import "LGPhotoPickerGroup.h"
#import <AssetsLibrary/AssetsLibrary.h>
#import <Masonry.h>

@interface LGPhotoPickerGroupTableViewCell ()
@property (weak, nonatomic) UIImageView *groupImageView;
@property (weak, nonatomic) UILabel *groupNameLabel;
@property (weak, nonatomic) UILabel *groupPicCountLabel;
@property (weak, nonatomic) UIView *topLine;
@property (weak, nonatomic) UIView *bottomLine;
@end

@implementation LGPhotoPickerGroupTableViewCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    if ([super initWithStyle:style reuseIdentifier:reuseIdentifier])
    {
        UIView *topLine = [[UIView alloc] init];
        [topLine setBackgroundColor:XX_RGBCOLOR_WITHOUTA(224, 224, 224)];
        [self.contentView addSubview:topLine];
        UIView *bottomLine = [[UIView alloc] init];
        [bottomLine setBackgroundColor:XX_RGBCOLOR_WITHOUTA(224, 224, 224)];
        [self.contentView addSubview:bottomLine];
        UIImageView *groupImageView = [[UIImageView alloc] init];
        groupImageView.contentMode = UIViewContentModeScaleAspectFit;
        [self.contentView addSubview:groupImageView];
        UILabel *groupNameLabel = [[UILabel alloc] init];
        [groupNameLabel setFont:[UIFont systemFontOfSize:15]];
        [groupNameLabel setTextColor:XX_RGBCOLOR_WITHOUTA(51, 51, 51)];
        [self.contentView addSubview:groupNameLabel];
        UILabel *groupPicCountLabel = [[UILabel alloc] init];
        groupPicCountLabel.font = [UIFont systemFontOfSize:15];
        groupPicCountLabel.textColor = XX_RGBCOLOR_WITHOUTA(153, 153, 153);
        [self.contentView addSubview:groupPicCountLabel];        
        
        [topLine mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(self.contentView);
            make.left.right.mas_equalTo(self.contentView);
            make.height.mas_offset(1);
        }];
        [bottomLine mas_makeConstraints:^(MASConstraintMaker *make) {
            make.bottom.mas_equalTo(self.contentView);
            make.left.right.mas_equalTo(self.contentView);
            make.height.mas_offset(1);
        }];
        [groupImageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerY.mas_equalTo(self.contentView);
            make.left.mas_offset(10);
            make.width.height.mas_offset(49);
        }];
        [groupNameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(groupImageView.mas_right).mas_offset(10);
            make.centerY.mas_equalTo(groupImageView);
        }];
        [groupPicCountLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(groupNameLabel.mas_right);
            make.centerY.mas_equalTo(groupImageView);
        }];
        self.topLine = topLine;
        self.bottomLine = bottomLine;
        self.groupImageView = groupImageView;
        self.groupNameLabel = groupNameLabel;
        self.groupPicCountLabel = groupPicCountLabel;
    }
    return self;
}

- (void)setShowLine:(NSUInteger)showLine
{
    _showLine = showLine;
    
    if (showLine==1)
    {
        [self.topLine setHidden:YES];
        [self.bottomLine setHidden:NO];
    }else
    {
        [self.topLine setHidden:NO];
        [self.bottomLine setHidden:NO];
    }
}

- (void)setGroup:(LGPhotoPickerGroup *)group {
    _group = group;
    
    self.groupNameLabel.text  = group.groupName;
    self.groupImageView.image = group.thumbImage;
    self.groupPicCountLabel.text = [NSString stringWithFormat:@"(%ld)",(long)group.assetsCount];
}

@end
