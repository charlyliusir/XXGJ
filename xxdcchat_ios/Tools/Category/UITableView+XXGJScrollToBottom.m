//
//  UITableView+XXGJScrollToBottom.m
//  xxdcchat_ios
//
//  Created by 刘朝龙 on 2017/3/20.
//  Copyright © 2017年 刘朝龙. All rights reserved.
//

#import "UITableView+XXGJScrollToBottom.h"

@implementation UITableView (XXGJScrollToBottom)

- (void)scrollToTopWithAnimated:(BOOL)animated
{
    if ([self numberOfSections] > 0 && [self numberOfRowsInSection:0] > 0)
    {
        [self scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0] atScrollPosition:UITableViewScrollPositionTop animated:animated];
    }
}

- (void)scrollToBottomWithAnimated:(BOOL)animated
{
    if ([self numberOfSections] > 0)
    {
        NSInteger lastSectionIndex = [self numberOfSections] - 1;
        NSInteger lastRowIndex = [self numberOfRowsInSection:lastSectionIndex] - 1;
        if (lastRowIndex > 0)
        {
            NSIndexPath *lastIndexPath = [NSIndexPath indexPathForRow:lastRowIndex inSection:lastSectionIndex];
            [self scrollToRowAtIndexPath:lastIndexPath atScrollPosition: UITableViewScrollPositionBottom animated:animated];
            
        }
    }
}

- (void)scrollToIndex:(NSInteger)row animated:(BOOL)animated
{
    if ([self numberOfSections] > 0)
    {
        NSInteger lastSectionIndex = [self numberOfSections] - 1;
        NSInteger lastRowIndex = [self numberOfRowsInSection:lastSectionIndex] - 1;
        if (lastRowIndex > 0)
        {
            NSIndexPath *lastIndexPath = [NSIndexPath indexPathForRow:row - 1 inSection:lastSectionIndex];
            [self scrollToRowAtIndexPath:lastIndexPath atScrollPosition: UITableViewScrollPositionTop animated:animated];
        }
    }
}

@end
