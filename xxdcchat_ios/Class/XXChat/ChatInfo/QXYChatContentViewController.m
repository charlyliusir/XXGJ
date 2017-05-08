//
//  QXYChatContentViewController.m
//  QXYChatMessageUI
//
//  Created by 刘朝龙 on 2017/3/14.
//  Copyright © 2017年 刘朝龙. All rights reserved.
//

#import "QXYChatContentViewController.h"
#import "XXGJPictureViewController.h"
#import "XXGJGrabRedEnvelopeViewController.h"
#import "XXGJMapViewController.h"
#import "XXGJChatTextTableViewCell.h"
#import "XXGJDrawnTableViewCell.h"
#import "XXGJChatImageTableViewCell.h"
#import "XXGJChatRechTextViewCell.h"
#import "XXGJChatAudioTableViewCell.h"
#import "XXGJChatRedEnvelopeTableViewCell.h"
#import "XXGJUserInfoViewController.h"
#import "XXGJGrabRedEnvelopeStatusView.h"
#import "XXGJReSendMessageManager.h"
#import <DTAttributedTextCell.h>
#import <MJRefresh.h>
#import <PlayerManager.h>
#import "NSString+IMEx.h"
#import "XXGJBusinessType.h"
#import "XXGJAlertView.h"
#import "XXGJMessage.h"
#import "Message.h"
#import "Args.h"

@interface QXYChatContentViewController () <UITableViewDelegate, UITableViewDataSource, XXGJAlertViewDelegate, XXGJChatTableViewCellDelegate, PlayingDelegate>

@property (nonatomic, strong)XXGJAudioAlertView *audioAlertView;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic, assign)NSInteger playAudioIndex;
@property (nonatomic, strong)NSDate *playDate;

@end

@implementation QXYChatContentViewController
+ (instancetype)chatContentViewController
{
    return [[[NSBundle mainBundle] loadNibNamed:NSStringFromClass(self) owner:nil options:nil] firstObject];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateUI:) name:NOTIFY_RESENDMESSAGE_RELOAD object:nil];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self.view setBackgroundColor:XX_RGBCOLOR_WITHOUTA(248, 248, 248)];
    [self.tableView setBackgroundColor:[UIColor clearColor]];
    // 0. 初始化播放语音标记
    self.playAudioIndex = -1; /** -1 表示没有播放语音*/
    
    self.tableView.mj_header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
        //Call this Block When enter the refresh status automatically
        if (self.delegate && [self.delegate respondsToSelector:@selector(refreshHeader:)])
        {
            [self.delegate refreshHeader:self];
        }
    }];
    
}

- (void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    
    [self.tableView setFrame:self.view.frame];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - lazy method
- (NSMutableArray *)msgsArray
{
    if (!_msgsArray)
    {
        _msgsArray = [NSMutableArray array];
    }
    return _msgsArray;
}

- (UIView *)audioAlertView
{
    if (!_audioAlertView)
    {
        _audioAlertView = [XXGJAudioAlertView audioAlertViewWithStatus:AudioAlertViewStatusDefine];
        [_audioAlertView setFrame:self.view.frame];
        [self.view addSubview:_audioAlertView];
    }
    
    return _audioAlertView;
}


#pragma mark - open method
/**
 清空用户所有聊天记录
 */
- (void)clearUserMessage
{
    [self.msgsArray removeAllObjects];
    [self reloadData];
}
/**
 刷新数据
 */
- (void)reloadData
{
    [self.tableView.mj_header endRefreshing];
    [self.tableView reloadData];
}

- (void)refreshData:(NSInteger)index
{
    /** 滚动到的位置*/
    [self.tableView scrollToIndex:index animated:NO];
}

- (void)noMoreMessage
{
    [self.tableView.mj_header endRefreshing];
}

/**
 展示数据滚动到底
 */
- (void)scrollToBottom:(BOOL)animated
{
    [self.tableView scrollToBottomWithAnimated:animated];
}

- (XXGJChatMessage *)getChatMessageWithMessage:(XXGJMessage *)message
{
    for (XXGJChatMessage *chatMessage in self.msgsArray)
    {
        if ([chatMessage.msgUuid isEqualToString:message.uuid])
        {
            return chatMessage;
        }
    }
    
    return nil;
}

- (XXGJChatMessage *)updateMessage:(id)msg progress:(NSProgress *)progress
{
    XXGJChatMessage *chatMessage = [self getChatMessageWithMessage:msg];
    if (progress)
    {
        chatMessage.args.progress = [NSString stringWithFormat:@"%0.1f", 100.0 * progress.completedUnitCount / progress.totalUnitCount];
    }else{
        chatMessage.args.progress = nil;
    }
    
    [self.appDelegate saveContext];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        NSIndexPath *indexPath=[NSIndexPath indexPathForRow:[self.msgsArray indexOfObject:chatMessage] inSection:0];
        [self.tableView reloadRowsAtIndexPaths:[NSArray arrayWithObjects:indexPath,nil] withRowAnimation:UITableViewRowAnimationNone];
    });
    
    return chatMessage;
}

- (void)showRecordAudioUI:(AudioAlertViewStatus)state
{
    [self.view bringSubviewToFront:self.audioAlertView];
    [self.audioAlertView setAudioAlertViewStatus:state];
    [self.audioAlertView setHidden:NO];
}

- (void)dismissRecordAudioUI
{
    [self.audioAlertView setAudioAlertViewStatus:AudioAlertViewStatusDefine];
    [self.view sendSubviewToBack:self.audioAlertView];
    [self.audioAlertView setHidden:YES];
}

- (void)listenAudioVolumeValue:(float)volumeValue
{
    [self.audioAlertView changeVolumeValue:volumeValue];
}

#pragma mark - private method
/**
 有重发消息更新, 需要同步更新界面

 @param notify 通知
 */
- (void)updateUI:(NSNotification *)notify
{
    dispatch_async(dispatch_get_main_queue(), ^{
       [self reloadData]; 
    });
}

- (NSString *)getFilePath:(NSString *)floder fileName:(NSString *)fileName
{
    /** 将图片缓存到本地*/
    NSString *imagefloder = [[NSString cacheStore] appendFileStore:floder];
    /** 创建文件夹*/
    if ([NSString createFilePath:imagefloder])
    {
        return [imagefloder stringByAppendingPathComponent:fileName];
    }
    
    return nil;
}

- (void)playAudioWithPath:(NSString *)filePath
{
    if(self.playAudioIndex!=-1)
        /** 有其他音频播放, 先停掉, 然后继续播放*/
    {
        /** 清空代理*/
        [PlayerManager sharedManager].delegate = nil;
        [[PlayerManager sharedManager] stopPlaying];
        /** 更新刚才播放音频的 cell*/
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:self.playAudioIndex inSection:0];
        /** 刷新Cell*/
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
        });
    }
    
    [[PlayerManager sharedManager] playAudioWithFileName:[self getFilePath:@"audio" fileName:filePath] delegate:self];
}

- (void)stopAudioPlay
{
    if (self.playAudioIndex!=-1)
    {
        [[PlayerManager sharedManager] stopPlaying];
        [PlayerManager sharedManager].delegate = nil;
        [self setPlayDate:nil];
    }
}

/**
 进入抢红包的详情页面
 */
- (void)goGrabInfoViewControll:(id)grabStatusItem
{
    XXGJGrabRedEnvelopeViewController *grabRedEnvelopeVC = [XXGJGrabRedEnvelopeViewController grabRedEnvelopeViewControllerWithStatus:grabStatusItem];
    [[self.appDelegate rootViewControllerNavi] pushViewController:grabRedEnvelopeVC animated:YES];
}

#pragma mark - notify method

#pragma mark - delegate
#pragma mark - audio play delegate
- (void)playingStoped
{
    /** 更新刚才播放音频的 cell*/
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:self.playAudioIndex inSection:0];
    /** 更新标记*/
    self.playAudioIndex = -1;
    /** 更新有效点击时间时间*/
    [self setPlayDate:nil];
    /** 刷新Cell*/
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
    });
}

#pragma mark - chat table view cell delegate
/**
 点击语音信息执行
 
 @param chatTableViewCell cell
 @param audioRecord 语音信息
 */
- (void)chatTableViewCell:(XXGJChatBaseTableViewCell *)chatTableViewCell
         checkAudioRecord:(id)audioRecord
{
    XXGJChatMessage *chatMessage = (XXGJChatMessage *)audioRecord;
    /** 判断现在播放的是不是当前点击的Cell*/
    NSInteger clickItem = [self.msgsArray indexOfObject:chatMessage];
    /** 避免频繁点击, 频繁开启播放录音*/
    if (clickItem == self.playAudioIndex && [[NSDate date] timeIntervalSinceDate:self.playDate] >= 1.0)
    /** 如果再次点击正在播放的语音, 停止播放*/
    {
        [self stopAudioPlay];
        return;
    } else if (self.playDate && clickItem == self.playAudioIndex)
    {
        NSLog(@"%lf", [[NSDate date] timeIntervalSinceDate:self.playDate]);
        self.playDate = [NSDate date];
        return;
    }
    self.playDate = [NSDate date];
    /** 直接播放*/
    //1492415068000.spx
    [self playAudioWithPath:chatMessage.args.url];
    /** 播放成功, 设置播放的*/
    self.playAudioIndex = [self.msgsArray indexOfObject:chatMessage];
    /** 添加播放动画*/
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:self.playAudioIndex inSection:0];
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
    });
}

/**
 点击定位信息执行，查看定位信息
 
 @param chatTableViewCell cell
 @param locationModel 定位信息
 */
- (void)chatTableViewCell:(XXGJChatBaseTableViewCell *)chatTableViewCell
          openMapLocation:(id)locationModel
{
    Args *locationArgs = (Args *)locationModel;
    /** 拆解名称和信息*/
    NSArray *addressArr = [locationArgs.address componentsSeparatedByString:@"||"];
    CLLocationCoordinate2D pt;
    pt.longitude = [locationArgs.longitude doubleValue];
    pt.latitude = [locationArgs.latitude doubleValue];
    
    XXGJLocationInfo *locationInfo = [XXGJLocationInfo locationInfoWithName:addressArr.firstObject address:addressArr.lastObject city:nil location:pt];
    /** 跳转到地图页面*/
    XXGJMapViewController *mapViewController = [XXGJMapViewController mapViewController];
    mapViewController.locationInfo = locationInfo;
    [[self.appDelegate rootViewControllerNavi] pushViewController:mapViewController animated:YES];
}

/**
 点击图片执行， 查看图片大图
 
 @param chatTableViewCell cell
 @param imageUrl 图片网上地址
 @param image 图片
 */
- (void)chatTableViewCell:(XXGJChatBaseTableViewCell *)chatTableViewCell
             openImageUrl:(NSURL *)imageUrl
                    image:(UIImage *)image
{
    XXGJPictureViewController *pictureVC = [[XXGJPictureViewController alloc] init];
    pictureVC.image  = image;
    pictureVC.imgUrl = imageUrl;
    [self presentViewController:pictureVC animated:YES completion:nil];
}

/**
 打开红包执行
 
 @param chatTableViewCell cell
 @param chatMessage 聊天信息
 */
- (void)chatTableViewCell:(XXGJChatBaseTableViewCell *)chatTableViewCell
          openRedEnvelope:(XXGJChatMessage*)chatMessage
{
    /** 点开红包界面*/
    NSString *session_key = self.appDelegate.socketManage.session_key;
    NSNumber *user_id     = self.appDelegate.user.user_id;
    NSMutableDictionary *dict = @{}.mutableCopy;
    // sessionKey
    if (!session_key)
    {
        [MBProgressHUD showLoadHUDCustomImage:successHUDName title:@"服务器开小差了"];
        return;
    }
    [dict setObject:session_key forKey:XXGJ_N_PARAM_RED_SESSIONKEY];
    [dict setObject:user_id forKey:XXGJ_N_PARAM_RED_USERID];
    [dict setObject:chatMessage.args.redEnvelopeId forKey:XXGJ_ARGS_PARAM_REDENVELOPE_ID];
    [MBProgressHUD showLoadHUDIndeterminate:@"开启红包"];
    [XXGJNetKit grabRedEnvelopeStatus:dict rBlock:^(id obj, BOOL success, NSError *error) {
        [MBProgressHUD hiddenHUD];
        if (success && obj)
        {
            NSDictionary *data = (NSDictionary *)obj;
            if (data && [data[@"statusText"] isEqualToString:@"success"])
            {
                NSDictionary *result = data[@"result"];
                __block XXGJGrabRedEnvelopeStatusView *grabStatusView = [XXGJGrabRedEnvelopeStatusView grabRedEnvelopeStatusViewWithOption:result];
                [grabStatusView setOverBlock:^(BOOL goGrabInfo, id grabInfo) {
                    if (goGrabInfo) [self goGrabInfoViewControll:grabInfo];
                    /** 清空内存*/
                    grabStatusView = nil;
                }];
                [grabStatusView showInWindom];
            }
        }
    }];
}

/**
 点击用户头像执行
 
 @param chatTableViewCell cell
 @param chatMessage 聊天信息
 */
- (void)chatTableViewCell:(XXGJChatBaseTableViewCell *)chatTableViewCell
               goUserInfo:(XXGJChatMessage*)chatMessage
{
        if ([chatMessage.user_id isEqualToNumber:@(-10000)]) {
            /** 系统不能点进去查看详情*/
            return;
        }
        NSNumber *userId = self.appDelegate.user.user_id;
        if (chatMessage.cellStyle == ChatCellStyleOther)
        {
            userId = chatMessage.user_id;
        }
        if (userId) {
            /** 如果用户不存在，就不让进入*/
            XXGJUserInfoViewController *userInfoVC = [XXGJUserInfoViewController userInfoViewController];
            userInfoVC.user_id = userId;
            [self.navigationController pushViewController:userInfoVC animated:YES];
            
        }
}

/**
 菜单方法执行
 
 @param chatTableViewCell cell
 @param chatMessage 聊天信息
 @param editStyle 菜单方法类型
 */
- (void)chatTableViewCell:(XXGJChatBaseTableViewCell *)chatTableViewCell
          editTextMessage:(XXGJChatMessage*)chatMessage
                 editType:(ChatCellEditStyle)editStyle
{
    // 1, 读取数据库中本条消息
    Message *opMessage = [self.appDelegate.dbModelManage excuteTable:TABLE_MESSAGE predicate:[NSString stringWithFormat:@"uuid=='%@'", chatMessage.msgUuid]].lastObject;
    
    /** 撤销消息*/
    if (editStyle == ChatCellEditStyleDrawn)
    {
        XXGJMessage *message = [[XXGJMessage alloc] init];
        [message setMessageType:@(XXGJWithdrawnMessage)];
        [message setContent:[NSString stringWithFormat:@"'%@'撤销了一条消息", self.appDelegate.user.nick_name]];
        [message setUserId:opMessage.userId];
        [message setTargetId:opMessage.targetId];
        [message setStatus:@(2)];
        [message setArgsObject:chatMessage.msgUuid forKey:@"targetUuid"];
        [message setIsGroup:chatMessage.isGroup];
        if ([chatMessage.isGroup boolValue])
        {
            [message setArgsObject:chatMessage.isGroup forKey:XXGJ_ARGS_PARAM_GROUPID];
        }
        /** 将撤销消息的uuid保存起来*/
        [self.appDelegate.drawnMessageUuidDict setValue:message forKey:message.uuid];
        [self.appDelegate.socketManage sendChatMessage:message];
    }
    /** 重新发送*/
    else if (editStyle == ChatCellEditStyleReSend)
    {
        XXGJMessage *message = [XXGJMessage messageWithDataBaseMessage:opMessage];
        [self.appDelegate.socketManage sendChatMessage:message];
    }
    /** 删除消息*/
    else if (editStyle == ChatCellEditStyleDel)
    {
        // 2, 删除数据库中的消息
        // 3, 删除应用列表中本条消息
        // 4, 刷新tableview
        
        [self.appDelegate.managedObjectContext deleteObject:opMessage];
        [self.appDelegate saveContext];
        
        [self.msgsArray removeObject:chatMessage];
        
        [self.tableView reloadData];
    }
}

/**
 点击cell中链接执行
 
 @param chatTableViewCell cell
 @param linkUrl 链接
 */
- (void)chatTableViewCell:(XXGJChatBaseTableViewCell *)chatTableViewCell
             checkLinkUrl:(NSURL *)linkUrl
{
    
}

#pragma mark - table view delegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    XXGJChatMessage *message = self.msgsArray[indexPath.row];
    /** 内容高度*/
    CGFloat height = 0;
    /** node与内容的间隙高度*/
    CGFloat space  = 24;
    /** 包含时间标记的总高度*/
    CGFloat topHeight = message.ishiddenTimeView ? 10 : 77.5;
    /** 用户名的高度*/
    CGFloat nameHeight= (message.cellStyle==ChatCellStyleOther&&[message.isGroup boolValue]) ? 17.5 : 0;
    
    if (message.messageType == XXGJTextMessage)
    {
        /** text高度*/
        height = [message.chatContent changeStationWidthTxtt:LESS_WIDTH-36.5 anfont:16];
        
    }
    /** 撤销信息样式*/
    else if (message.messageType == XXGJWithdrawnMessage)
    {
        return 80;
    }/** 图片信息样式*/
    else if (message.messageType == XXGJImageMessage)
    {
        /** 图片高度*/
        CGFloat width  = [message.args.bitmapWidth floatValue]/3.0f;
        height = [message.args.bitmapHeight floatValue]/3.0f;
        if (width >= LESS_WIDTH - 6)
        {
            height = (LESS_WIDTH-6) /width * height;
        }
        /** node 与 图片间隙*/
        space = 2;
        
    }
    else if (message.messageType == XXGJRichText&&[message.chatContent characterAtIndex:0]=='<')
    {
        XXGJChatRechTextViewCell *rechTextCell = [XXGJChatRechTextViewCell chatRechTextCell:tableView cellStyle:message.cellStyle];
        [rechTextCell setMessage:message];
        return [message.cellHeight floatValue];
    }
    else if (message.messageType == XXGJAudioMessage)
    {
        height = 40;
        space = 0;
        
        return topHeight + nameHeight + space + height;
    }
    else if (message.messageType == XXGJRedEnvelope)
    {
        height = 88.5;
        space = 0;
    }
    else
    {
        /** text高度*/
        height = [message.chatContent changeStationWidthTxtt:LESS_WIDTH-36.5 anfont:16];
    }

    return topHeight + nameHeight + space + height;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    /** 系统消息点击 Cell */
    XXGJChatMessage *message = self.msgsArray[indexPath.row];
    if ([message.user_id isEqualToNumber:@(-10000)])
    {
        /** 判断是否是添加好友消息*/
        if (message.businessType == XXGJBusinessFriendApply)
        {
            /** 判断是否已经是好友*/
            NSString *contentMessage = message.chatContent;
            XXGJAlertView *alertView = [XXGJAlertView alertViewContent:contentMessage withDelegate:self withObject:message];
            alertView.tag = 1001;
            [alertView setContentName:@"拒绝" alertIndex:AlertViewIndexCancel];
            [alertView setContentName:@"同意" alertIndex:AlertViewIndexConfirm];
            [alertView showInView:self.view];
        }
    }
}

#pragma mark - table view datasource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _msgsArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    XXGJChatMessage *message = self.msgsArray[indexPath.row];
    /** 在这里判断cell的样式--文字、富文本、图片、语音*/
    if (message.messageType == XXGJTextMessage)
    {
        XXGJChatTextTableViewCell *chatTextCell = [XXGJChatTextTableViewCell chatTextCell:tableView cellStyle:message.cellStyle];
        [chatTextCell setDelegate:self];
        [chatTextCell setMessage:message];
        return chatTextCell;
    }
    /** 撤销信息样式*/
    else if (message.messageType == XXGJWithdrawnMessage)
    {
        XXGJDrawnTableViewCell *chatDrawnCell = [XXGJDrawnTableViewCell chatDrawnCell:tableView];
        [chatDrawnCell setMessage:message];
        return chatDrawnCell;
    }
    /** 图片信息样式*/
    else if (message.messageType == XXGJImageMessage)
    {
        XXGJChatImageTableViewCell *chatImageCell = [XXGJChatImageTableViewCell chatImageCell:tableView cellStyle:message.cellStyle];
        [chatImageCell setDelegate:self];
        [chatImageCell setMessage:message];
        return chatImageCell;
    }
    else if (message.messageType == XXGJRichText&&[message.chatContent characterAtIndex:0]=='<')
    {
        XXGJChatRechTextViewCell *rechTextCell = [XXGJChatRechTextViewCell chatRechTextCell:tableView cellStyle:message.cellStyle];
        [rechTextCell setDelegate:self];
        [rechTextCell setMessage:message];
        return rechTextCell;
    }
    else if (message.messageType == XXGJAudioMessage)
    {
        XXGJChatAudioTableViewCell *audioCell = [XXGJChatAudioTableViewCell chatAudioCell:tableView cellStyle:message.cellStyle];
        [audioCell setMessage:message];
        [audioCell setDelegate:self];
        /** 判断是否开启播放动画*/
        if (self.playAudioIndex==indexPath.row)
        {
            [audioCell startPlayAnimation];
        }else
        {
            [audioCell stopPlayAnimation];
        }
        return audioCell;
    }
    else if (message.messageType == XXGJRedEnvelope)
    {
        XXGJChatRedEnvelopeTableViewCell *chatRedEnvelopeCell = [XXGJChatRedEnvelopeTableViewCell chatRedEnvelopeCell:tableView cellStyle:message.cellStyle];
        [chatRedEnvelopeCell setDelegate:self];
        [chatRedEnvelopeCell setMessage:message];
        return chatRedEnvelopeCell;
    }
    else
    {
        NSLog(@"audio text %@", message.chatContent);
        NSLog(@"这里崩了");
        XXGJChatTextTableViewCell *chatTextCell = [XXGJChatTextTableViewCell chatTextCell:tableView cellStyle:message.cellStyle];
        [chatTextCell setMessage:message];
        return chatTextCell;
    }
    return nil;
}

#pragma mark - table view scroll method
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    NSLog(@"will begin dragging");
    if (self.delegate && [self.delegate respondsToSelector:@selector(willDragContent:)]) {
        [self.delegate willDragContent:self];
    }
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    
}

#pragma mark - alert delegate
- (void)alertView:(XXGJAlertView *)alertView clickAtIndex:(AlertViewIndex)index object:(id)object
{
    if (alertView.tag == 1001)
    {
        XXGJChatMessage *chatMessage = (XXGJChatMessage *)object;
        NSNumber *status = @(1); /** 默认不同意*/
        if (index == AlertViewIndexConfirm)
            /** 同意添加好友*/
        {
            status = @(0);
        }
        [MBProgressHUD showLoadHUDIndeterminate:@"执行命令..."];
        [XXGJNetKit confirmFriend:@{XXGJ_N_PARAM_RELATIONSID:chatMessage.relation_id, XXGJ_N_PARAM_RELATIONSTATUS:status} rBlock:^(id obj, BOOL success, NSError *error) {
            // 重新加载好友列表, 以及好友信息
            if (obj && [obj[@"statusText"] isEqualToString:@"ok"]) {
                if ([status isEqualToNumber:@(AlertViewIndexCancel)])
                {
                    [MBProgressHUD showLoadHUDText:[NSString stringWithFormat:@"成功拒绝 '%@' 请求", chatMessage.chatContent] during:0.5];
                }else
                {
                    [[XXGJUserRequestManager sharedRequestMananger] updateFriend];
                    /** 添加好友*/
                    [MBProgressHUD showLoadHUDText:[NSString stringWithFormat:@"同意 '%@' 请求, 并与对方建立好友关系", chatMessage.chatContent] during:0.5];
                }
                
            }else{
                [MBProgressHUD showLoadHUDText:@"执行命令失败, 请检查网络状态" during:0.25];
            }
            
            [alertView hidden];
        }];
    }
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
