//
//  User.m
//  xxdcchat_ios
//
//  Created by 刘朝龙 on 2017/3/17.
//  Copyright © 2017年 刘朝龙. All rights reserved.
//

#import "User.h"
#import "Message.h"
#import "Group.h"

@implementation User

+ (NSFetchRequest<User *> *)fetchRequest {
    return [[NSFetchRequest alloc] initWithEntityName:@"User"];
}

- (NSArray *)getUserFriends
{
    NSMutableArray *friends = [NSMutableArray array];
    for (User *friend in self.friends)
    {
        [friends addObject:friend];
    }
    
    return friends.copy;
}

- (NSArray *)getUserGroups
{
    NSMutableArray *groups = [NSMutableArray array];
    for (Group *group in self.groups)
    {
        [groups addObject:group];
    }
    [groups sortUsingComparator:^NSComparisonResult(id  _Nonnull obj1, id  _Nonnull obj2) {
        Group *firstGroup = obj1;
        Group *secondGroup = obj2;
        
        return [firstGroup.name compare:secondGroup.name];
    }];
    
    return groups.copy;
}


@dynamic avatar;
@dynamic create;
@dynamic introduction;
@dynamic nick_name;
@dynamic mobile;
@dynamic email;
@dynamic company;
@dynamic terminalInfo;
@dynamic update;
@dynamic user_id;
@dynamic location;
@dynamic address;
@dynamic sex;
@dynamic hometown;
@dynamic birthday;
@dynamic friends;
@dynamic groups;
@dynamic reveCount;
@dynamic avoidRemind;
@end
