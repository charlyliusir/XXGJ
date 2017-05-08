//
//  UITableView+XXGJScrollToBottom.h
//  xxdcchat_ios
//
//  Created by 刘朝龙 on 2017/3/20.
//  Copyright © 2017年 刘朝龙. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UITableView (XXGJScrollToBottom)

- (void)scrollToBottomWithAnimated:(BOOL)animated;
- (void)scrollToTopWithAnimated:(BOOL)animated;
- (void)scrollToIndex:(NSInteger)row animated:(BOOL)animated;

@end
