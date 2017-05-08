//
//  Group.m
//  xxdcchat_ios
//
//  Created by 刘朝龙 on 2017/3/17.
//  Copyright © 2017年 刘朝龙. All rights reserved.
//

#import "Group.h"
#import "Message.h"
#import "User.h"

@implementation Group

+ (NSFetchRequest<Group *> *)fetchRequest {
    return [[NSFetchRequest alloc] initWithEntityName:@"Group"];
}

- (NSArray *)groupMember
{
    NSMutableArray *groupMembers = [NSMutableArray array];
    for (User *user in self.users)
    {
        if ([user.user_id isEqualToNumber:self.creator])
        {
            /** 将群主调到最前面*/
            [groupMembers insertObject:user atIndex:0];
        }
        else
        {
            [groupMembers addObject:user];
        }
    }
    [groupMembers sortUsingComparator:^NSComparisonResult(id  _Nonnull obj1, id  _Nonnull obj2) {
        User *firstUser  = obj1;
        User *secondUser = obj2;
        
        if ([firstUser.user_id isEqualToNumber:self.creator])
        {
            return 0;
        }
        
        return [firstUser.nick_name compare:secondUser.nick_name];
        
    }];
    return groupMembers.copy;
}

@dynamic create;
@dynamic creator;
@dynamic groupid;
@dynamic groupType;
@dynamic introduction;
@dynamic maxJoin;
@dynamic joinCount;
@dynamic name;
@dynamic pic;
@dynamic update;
@dynamic users;
@dynamic reveCount;
@dynamic avoidRemind;

@end
