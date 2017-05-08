//
//  XXGJNetKitHeader.h
//  xxdcchat_ios
//
//  Created by 刘朝龙 on 2017/3/16.
//  Copyright © 2017年 刘朝龙. All rights reserved.
//

#ifndef XXGJNetKitHeader_h
#define XXGJNetKitHeader_h

#define XXGJ_N_BASE_URL @"http://m.7xingyao.com:9002/"
#define XXGJ_N_HOME_BASE_URL  @"http://www.7xingyao.com/home"
#define XXGJ_N_BASE_IMAGE_URL @"http://res1.7xingyao.com/res/"
#define XXGJ_N_BASE_LOGIN_URL @"http://m.7xingyao.com/home/api/mobile/"
#define XXGJ_N_BASE_GROUP_URL @"http://im.xxgj365.com:9002/"
#define XXGJ_N_UPLOAD_URL @"http://m.7xingyao.com/home/upload/fileUpload"
#define XXGJ_N_AVATAR_UPLOAD_URL @"http://www.7xingyao.com/home/user/mobile/upload"
#define XXGJ_N_WECHATPAY_URL @"http://m.7xingyao.com/home/pay/wechatpay/payByOrderIdApp/"

#pragma mark - home
#define XXGJ_N_HOME_MOBILE @"/api/mobile/"
#define XXGJ_N_HOME_UPDATEWEBUSER @"/user/updateWebUser"


#pragma mark - 用户操作
#define XXGJ_N_PFILE_USER @"user/"
#define XXGJ_N_CFILE_USER_LOGIN       @"login"
#define XXGJ_N_CFILE_USER_LOGOUT      @"logout"
#define XXGJ_N_CFILE_USER_GETALL      @"getAll"
#define XXGJ_N_CFILE_USER_REMIND      @"avoidRemind"
#define XXGJ_N_CFILE_USER_RELATION    @"getPersonRelation"
#define XXGJ_N_CFILE_USER_UPLOAD_TOKEN @"updateApnsTocken"

#pragma mark - 好友操作
#define XXGJ_N_PFILE_FRIEND @"friend/"
#define XXGJ_N_CFILE_FRIEND_LIST      @"list"
#define XXGJ_N_CFILE_FRIEND_GET       @"get"
#define XXGJ_N_CFILE_FRIEND_ADD       @"add"
#define XXGJ_N_CFILE_FRIEND_CONFIRM   @"confirm"
#define XXGJ_N_CFILE_FRIEND_DELETE    @"delete"

#pragma mark - 群组操作
#define XXGJ_N_PFILE_GROUP @"group/"
#define XXGJ_N_PFILE_GROUP_CREATE     @"add"
#define XXGJ_N_PFILE_GROUP_LIST       @"list"
#define XXGJ_N_PFILE_GROUP_GET        @"get"
#define XXGJ_N_PFILE_GROUP_EDIT       @"edit"
#define XXGJ_N_PFILE_GROUP_MYLIST     @"myList"
#define XXGJ_N_PFILE_GROUP_ADDMB      @"addMember"
#define XXGJ_N_PFILE_GROUP_LEAVE      @"leave"
#define XXGJ_N_PFILE_GROUP_REMOVEMB   @"removeMember"
#define XXGJ_N_PFILE_GROUP_GETGROUPRELATION   @"getGroupRelation"

#pragma mark - 红包操作
#define XXGJ_N_PFILE_REDENVELOPE @"redEnvelope/"
#define XXGJ_N_PFILE_REDENVELOPE_SAVE @"saveRedEnvelope"
#define XXGJ_N_PFILE_REDENVELOPE_GRAB @"grabRedEnvelope"
#define XXGJ_N_PFILE_REDENVELOPE_GRAB_Status @"grabRedEnvelopeStatus"

#pragma mark - 关系操作
#define XXGJ_N_PFILE_RELATION @"relation/"
#define XXGJ_N_PFILE_RELATION_GETLOCALSET @"localSet"

#pragma mark - 参数
#define XXGJ_N_PARAM_USERNAME     @"username"
#define XXGJ_N_PARAM_PASSWORD     @"password"
#define XXGJ_N_PARAM_CURRENTPAGE  @"currentPage"
#define XXGJ_N_PARAM_PAGESIZE     @"pageSize"

#define XXGJ_N_PARAM_USERID       @"user_id"
#define XXGJ_N_PARAM_FUSERID      @"from_user_id"
#define XXGJ_N_PARAM_TARGETID     @"target_id"
#define XXGJ_N_PARAM_CREATEID     @"create_id"
#define XXGJ_N_PARAM_GROUPID      @"group_id"
#define XXGJ_N_PARAM_FRIENDID     @"friend_id"
#define XXGJ_N_PARAM_REMARK       @"remark"
#define XXGJ_N_PARAM_NICKNAEM     @"nick_name"
#define XXGJ_N_PARAM_SESSIONKEY   @"session_key"
#define XXGJ_N_PARAM_TERMINALINFO @"terminal_info"
#define XXGJ_N_PARAM_RELATIONTYPE     @"relation_type"
#define XXGJ_N_PARAM_RELATIONSID      @"relation_id"      // 这里是后天自动生成的唯一对应的关系表示
#define XXGJ_N_PARAM_RELATIONSTATUS   @"relation_status"  // 是否同意添加用户 0 同意 1 不同意
#define XXGJ_N_PARAM_GROUPNAEM    @"group_name"
#define XXGJ_N_PARAM_GROUPDESC    @"group_desc"
#define XXGJ_N_PARAM_GROUPUSERS   @"users"
#define XXGJ_N_PARAM_ISSYSTEM     @"is_system"
#define XXGJ_N_PARAM_TYPE         @"type"                 // 消息免打扰-0:好友 1:群组
#define XXGJ_N_PARAM_STATUS       @"status"               // 消息免打扰-1:开启免打扰 0:关闭免打扰
#define XXGJ_N_PARAM_RED_SESSIONKEY       @"sessionKey"               // 抢红包
#define XXGJ_N_PARAM_RED_USERID           @"userId"                   // 抢红包
#define XXGJ_N_PARAM_RED_ISGROUP          @"isGroup"                  // 抢红包
#define XXGJ_N_PARAM_RED_NUM              @"num"                      // 抢红包
#define XXGJ_N_PARAM_RED_TARGETID         @"targetId"                 // 抢红包
#define XXGJ_N_PARAM_RED_ISRANDOM         @"isRandom"                 // 抢红包
#define XXGJ_N_PARAM_RED_AMOUNT           @"amount"                   // 抢红包
#define XXGJ_N_PARAM_RED_ENVELOPEID       @"redEnvelopeId"            // 抢红包
#define XXGJ_N_PARAM_RED_CONTENT @"content"            // 抢红包

#endif /* XXGJNetKitHeader_h */
