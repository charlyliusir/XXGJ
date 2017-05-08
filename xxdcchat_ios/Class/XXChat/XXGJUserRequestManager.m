//
//  XXGJUserRequestManager.m
//  xxdcchat_ios
//
//  Created by 刘朝龙 on 2017/3/31.
//  Copyright © 2017年 刘朝龙. All rights reserved.
//

#import "XXGJUserRequestManager.h"
#import "AppDelegate.h"
#import "User.h"
#import "Group.h"

@interface XXGJUserRequestManager ()

@property (nonatomic, strong)AppDelegate *appDelegate;

@end

@implementation XXGJUserRequestManager

- (instancetype)init
{
    if (self = [super init])
    {
        self.appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    }
    
    return self;
}

+ (instancetype)sharedRequestMananger
{
    static dispatch_once_t t;
    static XXGJUserRequestManager *userRequestManager;
    dispatch_once(&t, ^{
        userRequestManager = [[XXGJUserRequestManager alloc] init];
    });
    
    return userRequestManager;
}

- (void)updateFriend
{
    [self.appDelegate.user removeFriends:self.appDelegate.user.friends];
    [self getFriendList:@(1)];
}

- (void)updateGroup
{
    [self.appDelegate.user removeGroups:self.appDelegate.user.groups];
    [self getGroupList:@(1)];
}

- (void)getFriendList:(NSNumber *)currentPage
{
    NSNumber *userId = self.appDelegate.user.user_id;
    
    NSDictionary *dict = @{
                           XXGJ_N_PARAM_USERID:userId,
                           XXGJ_N_PARAM_RELATIONTYPE:@0,
                           XXGJ_N_PARAM_CURRENTPAGE:currentPage,
                           XXGJ_N_PARAM_PAGESIZE:@20,
                           };
    
    [XXGJNetKit getFriendList:dict rBlock:^(id obj, BOOL success, NSError *error) {
        NSLog(@"get friend list");
        if ([obj[@"status"] boolValue]&&[obj[@"statusText"] isEqualToString:@"ok"])
        {
            
            NSDictionary *res   = obj[@"result"];
            NSNumber *totalCount= res[@"totalCount"];
            NSNumber *nextPage  = res[@"nextPage"];
            NSArray *list = res[@"list"];
            
            /** 此处更新或添加新用户*/
            for (NSDictionary *friendDict in list)
            {
                
                User *friend = [self.appDelegate.dbModelManage excuteTable:TABLE_USER predicate:[NSString stringWithFormat:@"user_id==%@", friendDict[@"ID"]]].lastObject;
                if (!friend)
                {
                    friend = [NSEntityDescription insertNewObjectForEntityForName:@"User" inManagedObjectContext:self.appDelegate.managedObjectContext];
                    friend.user_id= friendDict[@"ID"];
                }
                if (![self.appDelegate.user.friends containsObject:friend])
                {
                    [self.appDelegate.user addFriendsObject:friend];
                }
                
                friend.avatar = friendDict[@"Avatar"];
                friend.nick_name = friendDict[@"NickName"];
                self.appDelegate.user.update = @([NSDate timeIntervalSinceReferenceDate]);;
            }
            
            [self.appDelegate saveContext];
            /** 如果还有用户没有加载完毕,则再次继续加载*/
            if (![nextPage isEqualToNumber:currentPage]&&[totalCount integerValue]>[currentPage integerValue]*20)
            {
                [self getFriendList:nextPage];
            }else
            {
                /** 群组列表加载完毕, 更新最后更新时间*/
                [[NSUserDefaults standardUserDefaults] setObject:@([NSDate timeIntervalSinceReferenceDate]) forKey:XX_USERDEFAULT_TIME];
                [[NSUserDefaults standardUserDefaults] synchronize];
                /** 更新好友关系*/
                [self getFriendRelation];
            }
            
        }
        
    }];
}

- (void)getGroupList:(NSNumber *)currentPage
{
    NSNumber *userId = self.appDelegate.user.user_id;
    
    NSDictionary *dict = @{
                           XXGJ_N_PARAM_USERID:userId,
                           XXGJ_N_PARAM_CURRENTPAGE:currentPage,
                           XXGJ_N_PARAM_PAGESIZE:@20,
                           };
    
    [XXGJNetKit getMyGroups:dict rBlock:^(id obj, BOOL success, NSError *error) {
        
        
        if ([obj[@"status"] boolValue]&&[obj[@"statusText"] isEqualToString:@"ok"])
        {
            
            NSDictionary *res   = obj[@"result"];
            NSNumber *totalCount= res[@"totalCount"];
            NSNumber *nextPage  = res[@"nextPage"];
            NSArray *list = res[@"list"];
            
            /** 此处更新或添加新用户*/
            for (NSDictionary *groupDict in list)
            {
                
                Group *group = [self.appDelegate.dbModelManage excuteTable:TABLE_GROUP predicate:[NSString stringWithFormat:@"groupid==%@", groupDict[@"iD"]] limit:1].lastObject;
                if (!group)
                {
                    group = [NSEntityDescription insertNewObjectForEntityForName:@"Group" inManagedObjectContext:self.appDelegate.managedObjectContext];
                    group.create  = groupDict[@"created"];
                    group.creator = groupDict[@"creator"];
                    group.groupid= groupDict[@"iD"];
                    group.maxJoin= groupDict[@"maxJoin"];
                }
                if (![self.appDelegate.user.groups containsObject:group])
                {
                    [self.appDelegate.user addGroupsObject:group];
                }
                group.pic    = groupDict[@"pic"];
                group.name   = groupDict[@"name"];
                group.joinCount    = groupDict[@"joinCount"];
                group.introduction = groupDict[@"introduction"];
                self.appDelegate.user.update = @([NSDate timeIntervalSinceReferenceDate]);;
                
            }
            [self.appDelegate saveContext];
            
            /** 如果还有用户没有加载完毕,则再次继续加载*/
            if (![nextPage isEqualToNumber:currentPage]&&[totalCount integerValue]>[currentPage integerValue]*20)
            {
                [self getGroupList:nextPage];
            }
            else
            {
                /** 群组列表加载完毕, 更新最后更新时间*/
                [[NSUserDefaults standardUserDefaults] setObject:@([NSDate timeIntervalSinceReferenceDate]) forKey:XX_USERDEFAULT_TIME];
                [[NSUserDefaults standardUserDefaults] synchronize];
                /** 更新群组关系*/
                [self getGroupRelation];
            }
            
        }
    }];
}


/**
 创建朋友关系
 */
- (void)getFriendRelation
{
    __block NSUInteger groupMemberCount = 0;
    for (User *friend in self.appDelegate.user.friends)
    {
        NSDictionary *dict = @{XXGJ_N_PARAM_USERID:self.appDelegate.user.user_id,XXGJ_N_PARAM_FRIENDID:friend.user_id,XXGJ_N_PARAM_TYPE:@(1)};
        [XXGJNetKit getLocalSet:dict rBlock:^(id obj, BOOL success, NSError *error) {
            NSDictionary *dict = (NSDictionary *)obj;
            friend.avoidRemind = dict[@"result"];
            groupMemberCount += 1;
            if (groupMemberCount==self.appDelegate.user.groups.count)
            {
                [self.appDelegate saveContext];
            }
        }];
    }
    
}


/**
 创建群组关系
 */
- (void)getGroupRelation
{
    __block NSUInteger groupMemberCount = 0;
    for (Group *group in self.appDelegate.user.groups)
    {
        NSDictionary *dict = @{XXGJ_N_PARAM_USERID:self.appDelegate.user.user_id,XXGJ_N_PARAM_FRIENDID:group.groupid,XXGJ_N_PARAM_TYPE:@(1)};
        [XXGJNetKit getLocalSet:dict rBlock:^(id obj, BOOL success, NSError *error) {
            NSDictionary *dict = (NSDictionary *)obj;
            group.avoidRemind = dict[@"result"];
            groupMemberCount += 1;
            if (groupMemberCount==self.appDelegate.user.groups.count)
            {
                [self.appDelegate saveContext];
            }
        }];
    }
}

@end
