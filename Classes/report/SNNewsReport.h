//
//  SNNewsReport.h
//  sohunews
//
//  Created by yangln on 2016/12/6.
//  Copyright © 2016年 Sohu.com. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SNReportConsts.h"
#import "SNUserTrack.h"

@interface SNNewsReport : NSObject

@property (nonatomic, assign) NSTimeInterval startTime;//进入直播间时长

+ (SNNewsReport *)shareInstance;

/***
 *a.gif统计pv(点击量)和uv(访问量)
 */
+ (void)reportADotGif:(NSString *)string;

/***
 *a.gif统计pv(点击量)和uv(访问量),包含轨迹的统计
 */
+ (void)reportADotGifWithTrack:(NSString *)string;

/***
 *usr.gif统计用户粘性
 */
+ (void)reportUsrDotGif:(NSString *)string;

/***
 *p.go用于push通知栏点击的统计
 */
+ (void)reportPDotGo:(NSString *)actionID msgID:(NSString *)msgID;

/***
 *分享相关统计
 * 实时上传客户端分享行为
 * target      = 分享途径  微信&微博、社交网站
 * targetName  = 分享渠道的名称
 * userName    = 用户绑定的账号名称，微信暂时取不到
 * shareType   = 分享的内容类型 news新闻 pics组图 term报纸
 * typeID      = 分享内容的id
 * shareContent = 分享的内容
 */
+ (void)reportShareWithInfo:(NSDictionary *)dict;

/***
 *统计request
 */
- (void)reportWithUrl:(NSString *)url;

/***
 *统计频道流停留时长
 */
+ (void)reportChannelStayDuration:(CGFloat)duration channelID:(NSString *)channelId;

@end
