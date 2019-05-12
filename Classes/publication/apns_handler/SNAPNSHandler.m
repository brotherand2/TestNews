//
//  SNNotificationHandler.m
//  sohunews
//
//  Created by handy wang on 4/6/12.
//  Copyright (c) 2012 Sohu.com Inc. All rights reserved.
//

#import "SNAPNSHandler.h"
#import "SNSubItem.h"
#import "SNDBManager.h"
#import "SNLiveInviteModel.h"
#import "SNUserManager.h"
#import "SNTimelineSharedVideoPlayerView.h"
#import "SNRollingNewsPublicManager.h"

@interface SNAPNSHandler()

//- (NSMutableDictionary *)parsePushUrlPath:(NSString*)pushUrlPath schema:(NSString *)schemaStr;

- (void)cancelDownload;

- (void)saveLatestExpressInfo:(NSDictionary *)userInfo;

@end


@implementation SNAPNSHandler

#pragma mark - Singleton instance method

+ (SNAPNSHandler *)sharedInstance {
    static SNAPNSHandler *_sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedInstance = [[SNAPNSHandler alloc] init];
    });
    return _sharedInstance; 
}

//处理Push来的数据
- (void)handleReciveNotifyWithFromBack:(BOOL)fromBack {
    NSDictionary *_pushNotificationData = (NSDictionary *)[[SNUtility getApplicationDelegate].pushNotificationQueue checkOut];
    if (_pushNotificationData) {
        [UIApplication sharedApplication].applicationIconBadgeNumber = 0;
        
        NSDictionary *pushDictionary = [NSDictionary dictionaryWithDictionary:_pushNotificationData];
        NSString *pushURLStr = [pushDictionary objectForKey:kNotifyUrlKey];//v3.0.1开始看url属性，为了兼容老版本不能接收即时新闻推送
        if (nil == pushURLStr) {
            pushURLStr = [pushDictionary objectForKey:kNotifyKey]; //v3.0.1以前都看pushurl属性，仍然收快讯报纸
            pushURLStr = [pushURLStr stringByReplacingOccurrencesOfString:@".xml" withString:@""];//去掉.xml后缀
        }
        
        SNDebugLog(@"pushURLStr : %@",pushURLStr);
        
        if (pushDictionary && pushDictionary.count > 0 && pushURLStr && ![@"" isEqualToString:pushURLStr]) {
            if (pushURLStr.length) {
                [[SNTimelineSharedVideoPlayerView sharedInstance] forceStop];
                [SNNotificationManager postNotificationName:kNotifyDidHandled object:nil];
                
                NSMutableDictionary *context = [NSMutableDictionary dictionary];
                
                [context setValuesForKeysWithDictionary:pushDictionary];
                [context setObject:@"notify" forKey:@"notification"];
                [context setObject:@"1" forKey:kNewsExpressType];
                
                if ([pushURLStr startWith:kProtocolVideo]) {
                    [context setObject:@(WSMVVideoPlayerRefer_PushNotification) forKey:kWSMVVideoPlayerReferKey];
                }
                [context setObject:kNewsOnline forKey:kNewsMode];
                
                if ([pushURLStr hasPrefix:kProtocolChannel]) {
                    NSDictionary *dict = [SNUtility parseProtocolUrl:pushURLStr schema:kProtocolChannel];
                    if ([[dict objectForKey:@"channelName"]isEqualToString:@"小说"]) {
                        //小说频道push点击，加参数区分
                        pushURLStr = [NSString stringWithFormat:@"%@&type=push",pushURLStr];
                    }else
                    {
                       [SNRollingNewsPublicManager sharedInstance].channelProtocolNewsID = [dict stringValueForKey:@"newsId" defaultValue:@""];
                    }
                }
                if (fromBack) {
                    [context setObject:[NSNumber numberWithInteger:SNOpenAppOriginFromPush] forKey:kOpenAppOriginFromKey];
                }
                
                //小说push跳转埋点统计
                if ([pushURLStr containsString:kProtocolStoryReadChapter]) {
                    NSDictionary *dic = [SNUtility parseURLParam:pushURLStr schema:kProtocolStoryReadChapter];
                    NSString *bookId = [NSString stringWithFormat:@"%@",[dic objectForKey:@"novelId"]];
                    if ([dic allKeys].count > 2) {//继续阅读push点击埋点统计
                        [SNNewsReport reportADotGif:[NSString stringWithFormat:@"act=fic&tp=pv&from=9&bookId=%@",bookId]];
                    } else {//阅读页push点击埋点统计
                        [SNNewsReport reportADotGif:[NSString stringWithFormat:@"act=fic&tp=pv&from=8&bookId=%@",bookId]];
                    }
                }else if ([pushURLStr containsString:kProtocolStoryNovelDetail]) {//详情页push点击埋点统计
                    NSDictionary *dic = [SNUtility parseURLParam:pushURLStr schema:kProtocolStoryNovelDetail];
                    NSString *bookId = [NSString stringWithFormat:@"%@",[dic objectForKey:@"novelId"]];
                    [SNNewsReport reportADotGif:[NSString stringWithFormat:@"act=fic_todetail&objType=fic_todetail&fromObjType=%@&bookId=%@",@"12",bookId]];
                }
                
                [SNUtility shouldUseSpreadAnimation:NO];
                [SNUtility openProtocolUrl:pushURLStr context:context];
                [SNRollingNewsPublicManager sharedInstance].isOpenNewsFromPush = NO;
            }
        }
    }

}

- (void)didReceiveRemoteNotification:(NSDictionary *)userInfo {
    if (userInfo) {
        SNDebugLog(@"didReceiveRemoteNotification:%@", userInfo);
        NSString *pushURLStr = [userInfo objectForKey:kNotifyUrlKey];
        if ([pushURLStr startWith:kProtocolLive]) {
            NSDictionary *dict = [SNUtility parseURLParam:pushURLStr schema:kProtocolLive];
            NSString *busi = [dict stringValueForKey:@"busi" defaultValue:nil];
            SNDebugLog(@"didReceiveRemoteNotification: %@", userInfo);
            if (busi) {
                // 如果是直播邀请，保存在数据库表中
                SNLiveInviteStatusObj *inviteObj = [[SNLiveInviteStatusObj alloc] initWithDict:dict];
                if ([busi intValue] == LIVE_INVITE_BUSI_SUCCESS) {
                    inviteObj.inviteStatus = [NSNumber numberWithInt:LIVE_INVITE_SUC];
                } else if ([busi intValue] == LIVE_INVITE_BUSI_INVITING) {
                    inviteObj.inviteStatus = [NSNumber numberWithInt:LIVE_INVITING];
                } else {
                    inviteObj.inviteStatus = [NSNumber numberWithInt:LIVE_INVITE_UNKNOWN];
                }
                
                NSDictionary *apsDic = [userInfo objectForKey:@"aps"];
                NSString *alertStr = [apsDic objectForKey:@"alert"];
                inviteObj.showmsg = alertStr;
                
                if (inviteObj.passport.length == 0) {
                    // 使用当前用户的passport
                    inviteObj.passport = [SNUserManager getUserId];
                }
                [[SNDBManager currentDataBase] addOrUpdateLiveInviteItem:inviteObj];
            }
        }
    }
}

#pragma mark - Private methods implementaion

- (void)cancelDownload {
}

- (void)saveLatestExpressInfo:(NSDictionary *)userInfo {
 
    NSString *_channelId = [userInfo objectForKey:kChannelId];
    NSString *_newsId = [userInfo objectForKey:kNewsId];
    NSString *_form = kRollingNewsFormExpress;
    
    RollingNewsListItem *_rollingNewsListItem = [[RollingNewsListItem alloc] init];
    _rollingNewsListItem.channelId = _channelId;
    _rollingNewsListItem.newsId = _newsId;
    _rollingNewsListItem.form = _form;
    
    [[SNDBManager currentDataBase] addSingleRollingNewsListItem:_rollingNewsListItem updateIfExist:YES];
    
}

@end
