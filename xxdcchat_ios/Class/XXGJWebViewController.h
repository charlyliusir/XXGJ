//
//  XXGJWebViewController.h
//  xxdcchat_ios
//
//  Created by 刘朝龙 on 2017/4/7.
//  Copyright © 2017年 刘朝龙. All rights reserved.
//

#import "XXGJViewController.h"

#define XXGJ_WBEVIEW_REQUEST_BASE_URL @"http://m.7xingyao.com/"
#define XXGJ_WBEVIEW_REQUEST_URL_MALL @"home/gk/mall/index" /** 商城*/
#define XXGJ_WBEVIEW_REQUEST_URL_CASE @"home/gk/case"/** 案例*/
#define XXGJ_WBEVIEW_REQUEST_URL_ZHUANGXIU @"home/user/index"/** 装修*/
/// 我的页面
#define XXGJ_WBEVIEW_REQUEST_URL_USER_WALLET @"home/gk/dispacher/toMyWallet" /** 钱包*/
#define XXGJ_WBEVIEW_REQUEST_URL_USER_ORDERINDEX @"home/gk/order/index" /** 我的订单*/
#define XXGJ_WBEVIEW_REQUEST_URL_USER_COMMON @"home/gk/designerSetting/serviceTimeSetting/common" /** 服务时间设置*/
#define XXGJ_WBEVIEW_REQUEST_URL_USER_CALENDAR @"home/gk/designerSetting/viewWorkCalendar" /** 工作日历*/
#define XXGJ_WBEVIEW_REQUEST_URL_USER_DESIGNER @"home/gk/dispacher/toMeSet/WorkerType-designer" /** 设计师设置*/
#define XXGJ_WBEVIEW_REQUEST_URL_USER_HOUSEKEEPER @"home/gk/dispacher/toMeSet/WorkerType-housekeeper" /**   装修管家设置*/
#define XXGJ_WBEVIEW_REQUEST_URL_USER_CONSULTANT @"home/gk/dispacher/toMeSet/WorkerType-consultant" /**   装修顾问设置*/
#define XXGJ_WBEVIEW_REQUEST_URL_USER_GROUPLIST @"home/gk/applyGroup/myApplyGroupList" /** 我的团队*/
#define XXGJ_WBEVIEW_REQUEST_URL_SET_COPARTNER @"home/gk/generalSetting/toMyCopartner" /** 我的合伙人*/
#define XXGJ_WBEVIEW_REQUEST_URL_SET_WORKER @"home/gk/dispacher/toMeSet/WorkerType-worker" /** 工人设置*/
#define XXGJ_WBEVIEW_REQUEST_URL_SET_DELIVERY @"home/gk/dispacher/toMeSet/WorkerType-delivery" /** 配送商设置*/
#define XXGJ_WBEVIEW_REQUEST_URL_SET_SERVICE @"home/gk/generalSetting/myCustomerService" /** 我的客服*/
#define XXGJ_WBEVIEW_REQUEST_URL_SET_SERVICEINFO @"home/gk/designerSetting/customerServiceInfo?customerServiceId=" /** 我的客服主页*/
#define XXGJ_WBEVIEW_REQUEST_URL_SET_SERVICESET @"home/gk/dispacher/toMeSet/WorkerType-customerService" /** 客服设置*/
#define XXGJ_WBEVIEW_REQUEST_URL_USER_DESINGERID @"home/gk/designerSetting/designerInfo?desingerId=" /** 我的设计师主页*/
//#define XXGJ_WBEVIEW_REQUEST_URL_USER_BEPRO @"home/gk/generalSetting/toBePro" /**申请专业会员*/
#define XXGJ_WBEVIEW_REQUEST_URL_USER_TOMEAPPLY @"home/gk/dispacher/toMeApply" /**申请专业会员*/
#define XXGJ_WBEVIEW_REQUEST_URL_TOFINDPARTNER @"/home/gk/generalSetting/toFindPartner" /** 申请合伙人*/
#define XXGJ_WBEVIEW_REQUEST_URL_USER_CARTVIEW @"home/gk/order/cartView" /** 我的购物车*/
#define XXGJ_WBEVIEW_REQUEST_URL_NEED_DEMAND @"home/gk/decoration/userDemandList" /** 装修任务*/
#define XXGJ_WBEVIEW_REQUEST_URL_NEED_DECORATION @"home/gk/decoration/toDecorate" /** 装修需求*/
#define XXGJ_WBEVIEW_REQUEST_URL_DESIGNER_LIST @"home/gk/designerSetting/designerList" /** 找设计师*/
#define XXGJ_WBEVIEW_REQUEST_URL_WORKER_LIST @"home/gk/budget/workerList" /** 找工人*/
#define XXGJ_WBEVIEW_REQUEST_URL_KEPPER_LIST @"home/gk/budget/keeperList" /** 找装修管家*/
#define XXGJ_WBEVIEW_REQUEST_URL_CONSULTANT_LIST @"home/gk/budget/consultantList" /** 找装修顾问*/


@interface XXGJWebViewController : XXGJViewController

@property (nonatomic, strong)NSString *requestUrl; /** 请求网页的 Url*/

@end
