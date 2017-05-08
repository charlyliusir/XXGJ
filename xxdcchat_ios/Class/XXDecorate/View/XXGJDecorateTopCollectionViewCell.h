//
//  XXGJDecorateTopCollectionViewCell.h
//  xxdcchat_ios
//
//  Created by 刘朝龙 on 2017/4/13.
//  Copyright © 2017年 刘朝龙. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "XXGJDecorateTopModel.h"

@interface XXGJDecorateTopCollectionViewCell : UICollectionViewCell

@property (nonatomic, strong)XXGJDecorateTopModel *topModel;

+ (instancetype)decorateTopCollectionViewCell:(UICollectionView *)collectionView;

@end
