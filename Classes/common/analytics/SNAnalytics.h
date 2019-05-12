//
//  SNAnalytics.h
//  sohunews
//
//  Created by ivan.qi on 12-3-20.
//  Copyright (c) 2012年 Sohu.com Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SNAnalyticsTimers.h"
#import "SNAnalyticsConsts.h"
#import "SNUserTrackRecorder.h"
#import "SNInterceptConsts.h"
#import "SNReportConsts.h"

#define kMinuteTimeInterval     (180)

typedef enum {
    MyTicketsDotTpType_Pop,     //弹窗
    MyTicketsDotTpType_See,     //去看看
    MyTicketsDotTpType_LocalPv  //本地频道入口点击
} MyTicketsDotTpType;

@interface SNAnalytics : NSObject
@property (nonatomic, copy) NSString *rc;
@property (nonatomic, copy) NSString *lc;
@property (nonatomic, strong) NSMutableDictionary *channelRcs;
@property (nonatomic, assign) NSTimeInterval  startTime;

+ (SNAnalytics *)sharedInstance;

+ (NSString *)loginLinkStringForLocationId:(NSString *)locationId;


// 点击升级按钮之后的 统计
// s6=upgrade 	 NET=2g、3g、wifi

// for 登陆来源统计
/*
 用户登录来源以refer标识，如直播、tips、订阅、评论等。 其中登录来源需带各来源具体id值。 如“直播id”、“newId”。  参数形式为：refer&referId&refer_act， 即 refer=24（直播）&6534（直播ID）&2(语音评论)
 
 refer：15&&5
 */
- (void)appendLoginAnalyzeArgumnets:(SNReferFrom)refer
                            referId:(NSString *)referId
                           referAct:(SNReferAct)act;

// url + &refer= lastLoginReferArgumentsString
- (NSString *)configureLoginReferUrl:(NSString *)url;

typedef enum {
    SNAppAdActionTypeDownload, // 下载app
    SNAppAdActionTypeOpen // 打开了app
} SNAppAdActionType;



//
- (NSString *)configureUrlString:(NSString *)urlString;
- (NSDictionary *)addConfigureLoginReferParams;
@end
