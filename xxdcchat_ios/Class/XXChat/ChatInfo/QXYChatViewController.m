//
//  QXYChatViewController.m
//  QXYChatMessageUI
//
//  Created by 刘朝龙 on 2017/3/14.
//  Copyright © 2017年 刘朝龙. All rights reserved.
//

#import "QXYChatViewController.h"
#import "QXYChatContentViewController.h"
#import "QXYChatToolBoxViewController.h"
#import "XXGJChatFriendInfoViewController.h"
#import "XXGJChatGroupInfoViewController.h"
#import "XXGJReSendMessageManager.h"
#import "XXGJChatMessage.h"
#import "XXGJMessage.h"
#import "User.h"
#import "Group.h"
#import "Message.h"
#import "NewMessage.h"
#import "Args.h"

#define GET_MESSAGE_SIZE_PAGE 10

@interface QXYChatViewController () <QXYChatTollBoxDelegate, QXYChatContentDelegate, RecordingDelegate>

@property (nonatomic, strong)QXYChatContentViewController *chatContentVC;   // 聊天内容展示
@property (nonatomic, strong)QXYChatToolBoxViewController *chatToolBoxVC;   // 工具条
@property (nonatomic, assign)NSTimeInterval lastShowTimeInterval;
@property (nonatomic, strong)NSMutableArray *messageArray;

@end

@implementation QXYChatViewController

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    /** 清空最新消息的标记*/
    NSNumber *targetId = self.chatStyle == ChatStyleGroup ? _chatGroup.groupid: _chatUser.user_id;
    NewMessage *newMessage   = [self.appDelegate.dbModelManage excuteTable:TABLE_NEW_MESSAGE predicate:[NSString stringWithFormat:@"userId==%@ and targetId==%@", self.appDelegate.user.user_id, targetId] limit:1].lastObject;
    newMessage.reveCount = @(0);
    [self.appDelegate saveContext];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(readNewMessage:) name:XXGJ_SOCKET_REVE_NEW_MESSAGE object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reveiceDrawnMessage:) name:XXGJ_SOCKET_DEAWN_MESSAGE object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(sendRedEnvelopeMessage:) name:XXGJ_SEND_MESSAGE_REDENVELOPE_MESSAGE object:nil];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self.view setBackgroundColor:XX_BACKGROUND_COLOR];
    
    // 1. 添加内容控制器
    [self addChildViewController:self.chatContentVC];
    
    // 2. 添加内容视图
    [self.view addSubview:self.chatContentVC.view];
    
    if (self.chatStyle==ChatStyleSystem) {
        
        [self.chatContentVC.view mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.mas_equalTo(self.view);
        }];
    }
    else{
        // 1. 添加工具条控制器
        [self addChildViewController:self.chatToolBoxVC];
        
        // 2. 添加工具条的视图
        [self.view addSubview:self.chatToolBoxVC.view];
        
        [self.chatContentVC.view mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(self.view);
            make.left.right.mas_equalTo(self.view);
            make.bottom.mas_equalTo(self.chatToolBoxVC.view.mas_top);
        }];
        
        [self.chatToolBoxVC.view mas_makeConstraints:^(MASConstraintMaker *make) {
            make.bottom.mas_equalTo(self.view);
            make.left.right.mas_equalTo(self.view);
            make.height.mas_equalTo(50);
        }];
        
        /** 添加右按钮样式*/
        UIBarButtonItem *rightButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"group_btn_user"] style:UIBarButtonItemStylePlain target:self action:@selector(pushUserInfoMethod:)];
        /** 添加左按钮样式*/
        UIBarButtonItem *leftButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"btn_back_icon"] style:UIBarButtonItemStylePlain target:self action:@selector(backMethod:)];
        
        self.navigationItem.leftBarButtonItem  = leftButtonItem;
        self.navigationItem.rightBarButtonItem = rightButtonItem;
    }
    
    [self updateUserOrGroupInfo];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - lazy method
- (QXYChatToolBoxViewController *)chatToolBoxVC
{
    if (!_chatToolBoxVC)
    {
        _chatToolBoxVC = [QXYChatToolBoxViewController chatToolBoxViewControllerIsGroup:self.chatStyle==ChatStyleGroup];
        _chatToolBoxVC.targetId = self.chatStyle == ChatStyleGroup ? self.chatGroup.groupid : self.chatUser.user_id;
        _chatToolBoxVC.delegate = self;
    }
    
    return _chatToolBoxVC;
}

- (QXYChatContentViewController *)chatContentVC
{
    if (!_chatContentVC)
    {
        _chatContentVC = [QXYChatContentViewController chatContentViewController];
        _chatContentVC.delegate = self;
    }
    
    return _chatContentVC;
}

#pragma mark - getter and setter

#pragma mark - open method
- (void)setChatUser:(User *)chatUser
{
    _chatUser = chatUser;
    
    /** 更新显示最新消息样式*/
    [self setChatStyle:ChatStyleFriend];
    [self setNavigationBarTitle:_chatUser.nick_name];
    if ([_chatUser.user_id isEqualToNumber:@(-10000)])
    {
        [self setChatStyle:ChatStyleSystem];
        [self setNavigationBarTitle:@"系统消息"];
    }
    
}

- (void)setChatGroup:(Group *)chatGroup
{
    _chatGroup = chatGroup;
    
    [self setChatStyle:ChatStyleGroup];
    
    [self setNavigationBarTitle:[NSString stringWithFormat:@"%@(%lu)", _chatGroup.name, (unsigned long)_chatGroup.groupMember.count]];
}

#pragma mark - private method
- (void)updateUserOrGroupInfo
{
    /** 更新数据*/
    /** 先更新数据信息, 然后加载数据*/
    if (self.chatStyle == ChatStyleGroup)
    {
        /** 更新群信息*/
        /** 第一步, 判断群组最后更新状态*/
        [self updateGroupInfo:1];
    }
    else
    {
        [self reloadData];
    }
}
- (void)backMethod:(UIBarButtonItem *)barButtonItem
{
    [self.chatContentVC stopAudioPlay];
    [super backMethod:barButtonItem];
}

- (void)pushUserInfoMethod:(UIBarButtonItem *)barButtonItem
{
    if (self.chatStyle == ChatStyleFriend)
    {
        /** 跳转用户详情信息页面*/
        XXGJChatFriendInfoViewController *chatFriendInfoVC = [XXGJChatFriendInfoViewController chatFriendInfoViewController];
        chatFriendInfoVC.user = self.chatUser;
        [chatFriendInfoVC setClearBlock:^{
            [self clearMessages];
        }];
        [self.navigationController pushViewController:chatFriendInfoVC animated:YES];
    }
    else if (self.chatStyle == ChatStyleGroup)
    {
        /** 跳转群组详情信息页面*/
        XXGJChatGroupInfoViewController *chatGroupInfoVC = [XXGJChatGroupInfoViewController chatGroupInfoViewController];
        chatGroupInfoVC.group = self.chatGroup;
        [chatGroupInfoVC setClearBlock:^{
            [self clearMessages];
        }];
        [self.navigationController pushViewController:chatGroupInfoVC animated:YES];
    }
    
}

- (void)checkShowTime:(NSMutableArray *)msgArray
{
    self.lastShowTimeInterval = 0;
    for (XXGJChatMessage *chatMessage in msgArray)
    {
        if (chatMessage.messageType == XXGJWithdrawnMessage)
        {
            [chatMessage setIshiddenTimeView:NO];
        }else if (self.lastShowTimeInterval==0 || [NSDate didShowTimeView:self.lastShowTimeInterval beforeTime:[chatMessage.chatTime longLongValue]])
        {
            [chatMessage setIshiddenTimeView:NO];
            self.lastShowTimeInterval = [chatMessage.chatTime longLongValue];
        }else
        {
            [chatMessage setIshiddenTimeView:YES];
        }
    }
}

- (XXGJChatMessage *)msgConvertToChatMessageModel:(Message *)msg
{
    XXGJChatMessage *chatMessageModel = [[XXGJChatMessage alloc] init];
    [chatMessageModel setCreated:msg.create];
    [chatMessageModel setUser_id:[msg.isGroup boolValue]?msg.senderId:msg.targetId];
    [chatMessageModel setRelation_id:msg.relationId];
    [chatMessageModel setCellStyle:(ChatCellStyle)[msg.isSender boolValue]];
    [chatMessageModel setIsGroup:msg.isGroup];
    [chatMessageModel setMessageType:(XXGJTypeMessage)[msg.messageType unsignedIntegerValue]];
    [chatMessageModel setBusinessType:(XXGJTypeBusiness)[msg.businessType unsignedIntegerValue]];
    [chatMessageModel setChatTime:msg.create];
    [chatMessageModel setChatContent:msg.content];
    [chatMessageModel setMsgUuid:msg.uuid];
    [chatMessageModel setIsAck:msg.isAck];
    if ([msg.isSender isEqualToNumber:@(YES)])
    {
        [chatMessageModel setUserAvatar:self.appDelegate.user.avatar];
        [chatMessageModel setUserName:self.appDelegate.user.nick_name];
    }
    else
    {
        if ([msg.isGroup isEqualToNumber:@(YES)])
        {
            User *user = [self.appDelegate.dbModelManage excuteTable:TABLE_USER predicate:[NSString stringWithFormat:@"user_id==%@",msg.senderId] limit:1].lastObject;
            [chatMessageModel setUserAvatar:user.avatar];
            [chatMessageModel setUserName:user.nick_name];
        }else{
            User *user = [self.appDelegate.dbModelManage excuteTable:TABLE_USER predicate:[NSString stringWithFormat:@"user_id==%@",msg.targetId] limit:1].lastObject;
            [chatMessageModel setUserAvatar:user.avatar];
            [chatMessageModel setUserName:user.nick_name];
        }
    }
    chatMessageModel.args = msg.args;
    
    return chatMessageModel;
}

- (void)updateGroupInfo:(NSUInteger)page
{
    NSLog(@"update group users ....");
    NSDictionary *dict = @{XXGJ_N_PARAM_USERID:self.chatGroup.groupid, XXGJ_N_PARAM_RELATIONTYPE:@(1), XXGJ_N_PARAM_CURRENTPAGE:@(page), XXGJ_N_PARAM_PAGESIZE:@(20)};
    /** 获取群成员列表*/
    [XXGJNetKit getFriendList:dict rBlock:^(id obj, BOOL success, NSError *error) {
        if (obj && [obj[@"statusText"] isEqualToString:@"ok"])
        {
            NSDictionary *result = obj[@"result"];
            NSDictionary *list   = result[@"list"];
            NSNumber *totalCount = result[@"totalCount"];
            NSNumber *nextPage   = result[@"nextPage"];
            
            /** 保持群成员*/
            for (NSDictionary *userDict in list)
            {
                /** 首先判断数据库中是否存在*/
                User *groupUser = [self.appDelegate.dbModelManage excuteTable:TABLE_USER predicate:[NSString stringWithFormat:@"user_id==%@", userDict[@"ID"]] limit:1].lastObject;
                if (!groupUser)
                /** 不存在, 就创建*/
                {
                    groupUser = [NSEntityDescription insertNewObjectForEntityForName:TABLE_USER inManagedObjectContext:self.appDelegate.managedObjectContext];
                    groupUser.user_id = userDict[@"ID"];
                    groupUser.avatar  = userDict[@"Avatar"];
                    groupUser.nick_name = userDict[@"NickName"];
                    groupUser.create = userDict[@"Created"];
                }
                
                if(![self.chatGroup.users containsObject:groupUser])
                {
                    [self.chatGroup addUsersObject:groupUser];
                }
            }
            [self.appDelegate saveContext];
            
            if ([totalCount unsignedIntegerValue] > page * 20 && [nextPage unsignedIntegerValue] != page) {
                [self updateGroupInfo:[nextPage unsignedIntegerValue]];
            }else
            {
                dispatch_async(dispatch_get_main_queue(), ^{
                    self.chatGroup.update = [NSDate currentDuringTime];
                    [self setNavigationBarTitle:[NSString stringWithFormat:@"%@(%lu)", _chatGroup.name, (unsigned long)_chatGroup.groupMember.count]];
                    [self reloadData];
                });
            }
        }
    }];
}

- (void)reloadData
{
    NSInteger offset   = self.chatContentVC.msgsArray.count;
    NSNumber *targetId = @(-10000);
    if (self.chatStyle != ChatStyleGroup) {
        targetId = self.chatUser.user_id;
    }else{
        targetId = self.chatGroup.groupid;
    }
    NSInteger msgsCount = [self.appDelegate.dbModelManage excuteTable:TABLE_MESSAGE propertie:@"uuid" countPredicate:[NSString stringWithFormat:@"targetId==%@", targetId]];
    if (msgsCount > self.chatContentVC.msgsArray.count)
    {
        /** 先获取这次要获取的个数*/
        NSInteger limit = GET_MESSAGE_SIZE_PAGE;
        if (msgsCount-self.chatContentVC.msgsArray.count<limit) {
            limit = msgsCount-self.chatContentVC.msgsArray.count;
        }
        /** 加载数据*/
        NSArray * msgsArray = [self.appDelegate.dbModelManage excuteTable:TABLE_MESSAGE predicate:[NSString stringWithFormat:@"targetId==%@", targetId] offset:offset limit:limit order:@"create" ascending:NO];
        NSMutableArray *newMessageArray = [NSMutableArray array];
        NSMutableArray *newDataArray = [NSMutableArray array];
        for (int i = (int)(msgsArray.count)-1; i >= 0; i --)
        {
            /** 制作适配聊天 cell 的 Model*/
            [newMessageArray addObject:msgsArray[i]];
            [newDataArray addObject:[self msgConvertToChatMessageModel:(Message *)msgsArray[i]]];
        }
        [newMessageArray addObjectsFromArray:self.messageArray];
        [newDataArray addObjectsFromArray:self.chatContentVC.msgsArray.copy];
        
        /** 处理时间显示关系*/
        [self checkShowTime:newDataArray];
        self.chatContentVC.msgsArray = newDataArray.mutableCopy;
        self.messageArray = newDataArray.mutableCopy;
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.chatContentVC reloadData];
            if (self.chatContentVC.msgsArray.count<=limit)
            {
                [self.chatContentVC scrollToBottom:NO];
            }
            else
            {
                [self.chatContentVC refreshData:limit];
            }
        });
    }
    else if (msgsCount == 0)
    {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.messageArray removeAllObjects];
            [self.chatContentVC.msgsArray removeAllObjects];
            [self.chatContentVC reloadData];
        });
    }
    else
    {
        dispatch_async(dispatch_get_main_queue(), ^{
            /** 没有更多的数据了, 这里直接隐藏*/
            [self.chatContentVC noMoreMessage];
            [self.chatContentVC refreshData:1];
        });
    }
}

- (void)completeMessage:(XXGJMessage *)message
{
    if ([message.BusinessType isEmpty]) {
        message.BusinessType = [XXGJBusinessType businessByType:(self.chatStyle == ChatStyleGroup) ? XXGJBusinessChatRoom : XXGJBusinessChatP2P];
    }
    message.UserId   = self.appDelegate.user.user_id;
    message.TargetId = (self.chatStyle == ChatStyleGroup) ? self.chatGroup.groupid:self.chatUser.user_id;
    if (self.chatStyle == ChatStyleGroup) {
        message.Status = @(2);
        message.IsGroup= @(1);
        [message addArgsObject:@{XXGJ_ARGS_PARAM_GROUPID:[NSString stringWithFormat:@"%@", self.chatGroup.groupid]}];
    }
}

#pragma mark - notify method
/**
 读取到一个新的消息

 @param notify 通知
 */
- (void)readNewMessage:(NSNotification *)notify
{
    id obj = notify.object;
    
    if ([obj isKindOfClass:[Message class]])
    {
        Message *msgObj = (Message *)obj;
        
        [self.appDelegate saveContext];
        
        /** 判断消息是否为当前朋友或群组消息*/
        if ((self.chatStyle == ChatStyleGroup && [msgObj.targetId isEqualToNumber:self.chatGroup.groupid]) || (self.chatStyle == ChatStyleFriend && [msgObj.targetId isEqualToNumber:self.chatUser.user_id]))
        {
            /** 判断消息是ACK消息还是新消息*/
            for (XXGJChatMessage *msg in self.chatContentVC.msgsArray)
            {
                /** 更新消息状态*/
                if ([msg.msgUuid isEqualToString:msgObj.uuid])
                {
                    /** 修改标识*/
                    msg.isAck = @(YES);
                    /** 直接更新*/
//                    [self.chatContentVC reloadData];
                    return ;
                }
            }
            /** 判断消息是否是之前时间消息, 如果是不更新*/
            if ([msgObj.create longLongValue] < self.lastShowTimeInterval)
            {
                return;
            }
            /** 接收一个新消息*/
            XXGJChatMessage *newMessage = [self msgConvertToChatMessageModel:msgObj];
            if ([NSDate didShowTimeView:self.lastShowTimeInterval beforeTime:[newMessage.chatTime longLongValue]])
            {
                [newMessage setIshiddenTimeView:NO];
                self.lastShowTimeInterval = [newMessage.chatTime longLongValue];
            }else
            {
                [newMessage setIshiddenTimeView:YES];
            }
            [self.messageArray addObject:msgObj];
            [self.chatContentVC.msgsArray addObject:newMessage];
            [self.chatContentVC reloadData];
            [self.chatContentVC scrollToBottom:YES];
            
        }
    }
    
}

/**
 读取一个撤销消息

 @param notify 通知
 */
- (void)reveiceDrawnMessage:(NSNotification *)notify
{
    Message *drawnMsg = (Message *)notify.object;
    for (XXGJChatMessage *message in self.chatContentVC.msgsArray)
    {
        /** 更新消息状态*/
        if ([drawnMsg.uuid isEqualToString:message.msgUuid])
        {
            [self.chatContentVC.msgsArray removeObject:message];
            break;
        }
    }
    
    [self.appDelegate.managedObjectContext deleteObject:drawnMsg];
    [self checkShowTime:self.chatContentVC.msgsArray];
    [self.chatContentVC reloadData];
    [self.chatContentVC scrollToBottom:YES];
}

/**
 清空聊天记录通知
 */
- (void)clearMessages
{
    self.lastShowTimeInterval = 0;
    [self.chatContentVC clearUserMessage];
}

/**
 发送红包消息

 @param notify 通知
 */
- (void)sendRedEnvelopeMessage:(NSNotification *)notify
{
    XXGJMessage *redEnvelopeMessage = (XXGJMessage *)notify.object;
    /** 完善红包消息*/
    [self completeMessage:redEnvelopeMessage];
    /** 保存红包消息*/
    Message *newMessage = [NSEntityDescription insertNewObjectForEntityForName:TABLE_MESSAGE inManagedObjectContext:self.appDelegate.managedObjectContext];
    [redEnvelopeMessage convertToMessage:newMessage userId:self.appDelegate.user.user_id];
    newMessage.relationId  = redEnvelopeMessage.Args[XXGJ_ARGS_PARAM_REDENVELOPE_ID];
    newMessage.isReSend    = @(NO);
    [self.appDelegate saveContext];
    
    XXGJChatMessage *newChatMessage = [self msgConvertToChatMessageModel:newMessage];
    if ([NSDate didShowTimeView:self.lastShowTimeInterval beforeTime:[newChatMessage.chatTime longLongValue]])
    {
        [newChatMessage setIshiddenTimeView:NO];
        self.lastShowTimeInterval = [newChatMessage.chatTime longLongValue];
    }else
    {
        [newChatMessage setIshiddenTimeView:YES];
    }
    [self.chatContentVC.msgsArray addObject:newChatMessage];
    
    [self.chatContentVC reloadData];
    [self.chatContentVC scrollToBottom:NO];
}

- (NSString *)getFilePath:(NSString *)floder fileName:(NSString *)fileName
{
    /** 将图片缓存到本地*/
    NSString *imagefloder = [[NSString cacheStore] stringByAppendingPathComponent:floder];
    /** 创建文件夹*/
    if ([NSString createFilePath:imagefloder])
    {
        return [imagefloder stringByAppendingPathComponent:fileName];
    }
    
    return nil;
}

#pragma mark - delegate
#pragma mark - reocrd delegate

/**
 录制结束

 @param filePath 存放位置
 @param interval 录制时间
 */
- (void)recordingFinishedWithFileName:(NSNumber *)filePath time:(NSTimeInterval)interval
{
    NSString *fileName = [NSString stringWithFormat:@"%@.spx", filePath];
    if (interval <= 1.5f)
        /** 判断interval小于1s丢弃*/
    {
        /** 删除录音文件*/
        [[NSFileManager defaultManager] removeItemAtPath:[self getFilePath:@"audio" fileName:fileName] error:nil];
        /** 提示时间太短*/
        [self.chatContentVC showRecordAudioUI:AudioAlertViewStatusShort];
        dispatch_time_t time=dispatch_time(DISPATCH_TIME_NOW, 0.5*NSEC_PER_SEC);
        dispatch_after(time,dispatch_get_main_queue(), ^{
            [self.chatContentVC dismissRecordAudioUI];
        });
    }else
    {
        dispatch_async(dispatch_get_main_queue(), ^{
            /** 显示在cell上*/
            XXGJMessage *message = [[XXGJMessage alloc] init];
            message.Created      = filePath;
            message.MessageType  = @(XXGJAudioMessage);
            message.Content = [NSString stringWithFormat:@"%.0f", interval];
            [message addArgsObject:@{XXGJ_ARGS_PARAM_DURATION:@([message.Content integerValue])}];
            [message addArgsObject:@{XXGJ_ARGS_PARAM_URL:fileName}];
            [self completeMessage:message];
            
            /** 将消息保持到本地数据库*/
            /** 第一步, copy args参数*/
            Args *args = [NSEntityDescription insertNewObjectForEntityForName:TABLE_ARGS inManagedObjectContext:self.appDelegate.managedObjectContext];
            [message getMessageArgsObject:args];
            /** 第二步, copy 消息数据*/
            Message *newMessage = [NSEntityDescription insertNewObjectForEntityForName:TABLE_MESSAGE inManagedObjectContext:self.appDelegate.managedObjectContext];
            [message convertToMessage:newMessage userId:self.appDelegate.user.user_id];
            newMessage.isReSend = @(NO);
            newMessage.args = args;
            
            XXGJChatMessage *newChatMessage = [self msgConvertToChatMessageModel:newMessage];
            if ([NSDate didShowTimeView:self.lastShowTimeInterval beforeTime:[newChatMessage.chatTime longLongValue]])
            {
                [newChatMessage setIshiddenTimeView:NO];
                self.lastShowTimeInterval = [newChatMessage.chatTime longLongValue];
            }else
            {
                [newChatMessage setIshiddenTimeView:YES];
            }
            [[XXGJReSendMessageManager sharedReSendMessageManger] addReSendMessageObject:newChatMessage objectUuid:newChatMessage.msgUuid];
            [self.chatContentVC.msgsArray addObject:newChatMessage];
            
            [self.chatContentVC reloadData];
            [self.chatContentVC scrollToBottom:YES];
            
            /** 先上传文件*/
            NSData *fileData = [NSData dataWithContentsOfFile:[self getFilePath:@"audio" fileName:fileName]];
            [XXGJNetKit uploadImageWithData:fileData rProgress:nil rBlock:^(id obj, BOOL success, NSError *error) {
                
                if (success && obj && [obj[@"status"][@"msg"] isEqualToString:@"success"])
                {
                    NSDictionary *data = obj[@"data"];
                    [message setArgsObject:data[@"url"] forKey:XXGJ_ARGS_PARAM_URL];
                    [self.appDelegate saveContext];
                    /** 上传成功, 发送消息*/
                    if (self.appDelegate.reachabiltyStatus==AFNetworkReachabilityStatusUnknown||self.appDelegate.reachabiltyStatus==AFNetworkReachabilityStatusNotReachable)
                    {
                        [MBProgressHUD showLoadHUDText:@"网络不可使用，请检查网络" during:0.5 originX:20];
                        return;
                    }
                    if (!self.appDelegate.socketManage.socketConnected)
                    {
                        [MBProgressHUD showLoadHUDText:@"服务器开小差了..." during:0.5 originX:20];
                        return;
                    }
                    dispatch_async(dispatch_get_main_queue(), ^{
                        NSLog(@"开始发送消息");
                        [self.chatContentVC updateMessage:message progress:nil];
                        [self.appDelegate.socketManage sendChatMessage:message];
                    });
                }
            }];
        });
    }
    
    [self.chatToolBoxVC setReocrdDelegate:nil];
}

/**
 录制超时
 */
- (void)recordingTimeout
{
    [self.chatContentVC dismissRecordAudioUI];
    [self.chatToolBoxVC setReocrdDelegate:nil];
}

/**
 录制停止
 */
- (void)recordingStopped
{
    [self.chatContentVC dismissRecordAudioUI];
}

/**
 录制失败

 @param failureInfoString 失败说明
 */
- (void)recordingFailed:(NSString *)failureInfoString
{
    [self.chatContentVC dismissRecordAudioUI];
    [self.chatToolBoxVC setReocrdDelegate:nil];
}

/**
 录音变化

 @param levelMeter 音量
 */
- (void)levelMeterChanged:(float)levelMeter
{
    NSLog(@"levelMeterChanged--%f", levelMeter);
    [self.chatContentVC listenAudioVolumeValue:levelMeter];
}
#pragma mark - view delegate
- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    UITouch *touch = [touches anyObject];
    
    CGPoint point = [touch locationInView:self.chatToolBoxVC.chatToolView.chatRecordContentView];
    
    if (point.y > 0 && point.x > 0)
        /** 如果在说话按钮上, 开始录音, 显示录音动画*/
    {
        [self.chatToolBoxVC startReocrd];
        /** 录音动画*/
        [self.chatContentVC showRecordAudioUI:AudioAlertViewStatusDefine];
        /** 监听录音状态改变, 设置录音的代理*/
        [self.chatToolBoxVC setReocrdDelegate:self];
    }
}

- (void)touchesMoved:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    UITouch *touch = [touches anyObject];
    
    CGPoint point = [touch locationInView:self.chatToolBoxVC.chatToolView.chatRecordContentView];
    
    if (point.y < 0)
        /** 手指移动到了聊天视图, 提示松开手指放弃录音*/
    {
        [self.chatToolBoxVC changeVoiceState:QXYVoiceStateClose];
        [self.chatContentVC showRecordAudioUI:AudioAlertViewStatusCancel];
    }else if (point.y > 0)
        /** 手指回到了聊天视图, 显示正在录音, 并显示录音音量*/
    {
        [self.chatToolBoxVC changeVoiceState:QXYVoiceStateSelect];
        [self.chatContentVC showRecordAudioUI:AudioAlertViewStatusRecord];
    }
}

- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    UITouch *touch = [touches anyObject];
    
    CGPoint point = [touch locationInView:self.chatToolBoxVC.view];
    
    if (point.y >= 0)
        /** 录音结束, 且手指最后位置在录音按钮上, 停止录音并等待发送录音消息*/
    {
        [self.chatToolBoxVC stopRecord];
    }else if(point.y < 0)
        /** 录音结束, 且手指最后位置不在录音按钮上, 取消本次录音并不发送录音消息*/
    {
        [self.chatToolBoxVC cancelRecord];
        [self.chatContentVC dismissRecordAudioUI];
        /** 移除代理*/
        [self.chatToolBoxVC setReocrdDelegate:nil];
    }
}

#pragma mark - chat content delegate
- (void)refreshHeader:(id)chatContentVC
{
    [self reloadData];
}

- (void)willDragContent:(id)chatContentVC
{
    /** 如果是系统消息, 不执行这个方法*/
    if (self.chatStyle!=ChatStyleSystem) {
        // 如果是键盘状态，撤销键盘
        if (self.chatToolBoxVC.toolBoxState == QXYChatToolBoxStateKeyBoard)
        {
            [self.view endEditing:YES];
        }
        /** 如果视图是收起状态，不用进行其他操作*/
        if (self.chatToolBoxVC.view.frame.size.height == 50)  return;
        // 收起所有视图
        [UIView animateWithDuration:0.25 animations:^{
            [self.chatToolBoxVC.view mas_updateConstraints:^(MASConstraintMaker *make) {
                make.height.mas_equalTo(50);
            }];
            [self.view layoutIfNeeded];
        } completion:^(BOOL finished) {
            [self.chatContentVC scrollToBottom:YES];
            [self.chatToolBoxVC closeChatToolView];
        }];
    }
}

#pragma mark - chat tool box delegate
- (void)chatToolBox:(QXYChatToolBoxViewController *)chatToolBox changeOrigin:(BOOL)origin changeFrame:(CGFloat)height animationDurtion:(CGFloat)durtion
{
    CGFloat updateHeight = 50;
    if (!origin) updateHeight += height;
    // 执行动画，将其他视图页面展示出来
    [UIView animateWithDuration:durtion animations:^{
        [self.chatToolBoxVC.view mas_updateConstraints:^(MASConstraintMaker *make) {
            make.height.mas_equalTo(updateHeight);
        }];
        [self.view layoutIfNeeded];
    } completion:^(BOOL finished) {
        [self.chatContentVC scrollToBottom:YES];
    }];
}


/**
 展开或收起其他页面
 
 @param chatToolBox <#chatToolBox description#>
 @param select <#select description#>
 */
- (void)chatToolBox:(QXYChatToolBoxViewController *)chatToolBox openOtherItem:(BOOL)select
{
    // 如果是键盘状态，撤销键盘
    if (self.chatToolBoxVC.toolBoxState == QXYChatToolBoxStateKeyBoard)
    {
        [self.view endEditing:YES];
    }
    CGFloat height = select ? 225 : 0;
    // 执行动画，将其他视图页面展示出来
    [UIView animateWithDuration:0.25 animations:^{
        [self.chatToolBoxVC.view mas_updateConstraints:^(MASConstraintMaker *make) {
            make.height.mas_equalTo(50 + height);
        }];
        [self.view layoutIfNeeded];
    } completion:^(BOOL finished) {
        [self.chatContentVC scrollToBottom:YES];
    }];
    
}

/**
 代理方法, 发送消息
 
 @param chatToolBox <#chatToolBox description#>
 @param msg <#msg description#>
 */
- (void)chatToolBox:(QXYChatToolBoxViewController *)chatToolBox sendMessage:(id)msg
{
    if (self.appDelegate.reachabiltyStatus==AFNetworkReachabilityStatusUnknown||self.appDelegate.reachabiltyStatus==AFNetworkReachabilityStatusNotReachable)
    {
        [MBProgressHUD showLoadHUDText:@"网络不可使用，请检查网络" during:0.5 originX:20];
        return;
    }
    if (!self.appDelegate.socketManage.socketConnected)
    {
        [MBProgressHUD showLoadHUDText:@"服务器开小差了..." during:0.5 originX:20];
        return;
    }
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
       
        XXGJMessage *message = (XXGJMessage *)msg;
        /** 完善消息内容*/
        [self completeMessage:message];
        
        /** 将消息保持到本地数据库*/
        /** 第一步, copy args参数*/
        Args *args = [NSEntityDescription insertNewObjectForEntityForName:TABLE_ARGS inManagedObjectContext:self.appDelegate.managedObjectContext];
        [message getMessageArgsObject:args];
        /** 第二步, copy 消息数据*/
        Message *newMessage = [NSEntityDescription insertNewObjectForEntityForName:TABLE_MESSAGE inManagedObjectContext:self.appDelegate.managedObjectContext];
        [message convertToMessage:newMessage userId:self.appDelegate.user.user_id];
        newMessage.isReSend = @(NO);
        newMessage.args = args;
        
        XXGJChatMessage *newChatMessage = [self msgConvertToChatMessageModel:newMessage];
        if ([NSDate didShowTimeView:self.lastShowTimeInterval beforeTime:[newChatMessage.chatTime longLongValue]])
        {
            [newChatMessage setIshiddenTimeView:NO];
            self.lastShowTimeInterval = [newChatMessage.chatTime longLongValue];
        }else
        {
            [newChatMessage setIshiddenTimeView:YES];
        }
        [self.messageArray addObject:newMessage];
        [self.chatContentVC.msgsArray addObject:newChatMessage];
        
        [self.appDelegate saveContext];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.chatContentVC reloadData];
            [self.chatContentVC scrollToBottom:YES];
            [self.appDelegate.socketManage sendChatMessage:message];
        });
    });
}

/**
 选择完毕图片

 @param chatToolBox <#chatToolBox description#>
 @param msg <#msg description#>
 */
- (void)chatToolBox:(QXYChatToolBoxViewController *)chatToolBox startSendImageMessage:(id)msg
{
    if (self.appDelegate.reachabiltyStatus==AFNetworkReachabilityStatusUnknown||self.appDelegate.reachabiltyStatus==AFNetworkReachabilityStatusNotReachable)
    {
        [MBProgressHUD showLoadHUDText:@"网络不可使用，请检查网络" during:0.5 originX:20];
        return;
    }
    if (!self.appDelegate.socketManage.socketConnected)
    {
        [MBProgressHUD showLoadHUDText:@"服务器开小差了..." during:0.5 originX:20];
        return;
    }
    XXGJMessage *message = (XXGJMessage *)msg;
    /** 完善消息内容*/
    [self completeMessage:message];
    
    Args *args = [NSEntityDescription insertNewObjectForEntityForName:TABLE_ARGS inManagedObjectContext:self.appDelegate.managedObjectContext];
    args.bitmapSize = message.Args[XXGJ_ARGS_PARAM_BITMPSIZE];
    args.bitmapWidth = message.Args[XXGJ_ARGS_PARAM_BITMPWIDTH];
    args.bitmapHeight = message.Args[XXGJ_ARGS_PARAM_BITMPHEIGHT];
    args.imgUrl = message.Args[XXGJ_ARGS_PARAM_IMAGEURL];
    args.progress = @"0.0";
    
    /** 将消息保持到本地数据库*/
    Message *newMessage = [NSEntityDescription insertNewObjectForEntityForName:TABLE_MESSAGE inManagedObjectContext:self.appDelegate.managedObjectContext];
    [message convertToMessage:newMessage userId:self.appDelegate.user.user_id];
    newMessage.isReSend = @(NO);
    newMessage.args   = args;
    args.message      = newMessage;
    [self.appDelegate saveContext];
    
    XXGJChatMessage *newChatMessage = [self msgConvertToChatMessageModel:newMessage];
    if ([NSDate didShowTimeView:self.lastShowTimeInterval beforeTime:[newChatMessage.chatTime longLongValue]])
    {
        [newChatMessage setIshiddenTimeView:NO];
        self.lastShowTimeInterval = [newChatMessage.chatTime longLongValue];
    }else
    {
        [newChatMessage setIshiddenTimeView:YES];
    }
    [self.messageArray addObject:newMessage];
    [self.chatContentVC.msgsArray addObject:newChatMessage];
    
    [self.chatContentVC reloadData];
    [self.chatContentVC scrollToBottom:NO];
}

/**
 图片上传

 @param chatToolBox <#chatToolBox description#>
 @param msg <#msg description#>
 @param progress <#progress description#>
 */
- (void)chatToolBox:(QXYChatToolBoxViewController *)chatToolBox sendImageMessage:(id)msg progress:(NSProgress *)progress
{
    [self.chatContentVC updateMessage:msg progress:progress];
}

/**
 图片上传完毕

 @param chatToolBox <#chatToolBox description#>
 @param msg <#msg description#>
 */
- (void)chatToolBox:(QXYChatToolBoxViewController *)chatToolBox endSendImageMessage:(id)msg
{
    if (self.appDelegate.reachabiltyStatus==AFNetworkReachabilityStatusUnknown||self.appDelegate.reachabiltyStatus==AFNetworkReachabilityStatusNotReachable)
    {
        [MBProgressHUD showLoadHUDText:@"网络不可使用，请检查网络" during:0.5 originX:20];
        return;
    }
    if (!self.appDelegate.socketManage.socketConnected)
    {
        [MBProgressHUD showLoadHUDText:@"服务器开小差了..." during:0.5 originX:20];
        return;
    }
    [self.chatContentVC updateMessage:msg progress:nil];
    [self.appDelegate.socketManage sendChatMessage:msg];
}
/*
 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 */

@end
