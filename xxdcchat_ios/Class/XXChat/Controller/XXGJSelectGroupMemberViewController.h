//
//  XXGJSelectGroupMemberViewController.h
//  xxdcchat_ios
//
//  Created by 刘朝龙 on 2017/4/4.
//  Copyright © 2017年 刘朝龙. All rights reserved.
//

#import "XXGJViewController.h"

typedef NS_ENUM(NSInteger, XXGJSelectType) {
    XXGJSelectTypeCreateGroup,
    XXGJSelectTypeAddGroupMemeber,
    XXGJSelectTypeDeleteGroupMemeber
};

@interface XXGJSelectGroupMemberViewController : XXGJViewController

@property (nonatomic, strong)Group *group;
@property (nonatomic, strong)NSArray *groupMembersArr;   /** 成员数组*/
@property (nonatomic, assign)XXGJSelectType type;       /** VC 样式*/

+ (instancetype)selectGroupMemberViewController;

@end
