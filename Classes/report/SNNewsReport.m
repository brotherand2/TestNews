//
//  SNNewsReport.m
//  sohunews
//
//  Created by yangln on 2016/12/6.
//  Copyright © 2016年 Sohu.com. All rights reserved.
//

#import "SNNewsReport.h"
#import "SNNewsReportRequest.h"
#import "SNUserManager.h"
#import "SNUserLocationManager.h"
#import "SNPickStatisticRequest.h"

@implementation SNNewsReport

+ (SNNewsReport *)shareInstance {
    static SNNewsReport* newsReport = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        newsReport = [[SNNewsReport alloc] init];
    });
    return newsReport;
}


#pragma mark a.gif
+ (void)reportADotGif:(NSString *)string {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0),^{
        NSString *urlString = [SNAPI aDotGifUrlWithParameters:string];
        urlString = [urlString stringByAppendingFormat:@"&p1=%@&pid=%@&abmode=%d", [SNUserManager getP1], [SNUserManager getPid], [SNUtility AbTestAppStyle]];
        [[SNNewsReport shareInstance] reportWithUrl:urlString];
        
        //丢失校验
        [SNUtility missingCheckReportWithUrl:urlString];
    });
}

+ (void)reportADotGifWithTrack:(NSString *)string {
    __block NSString *reportStr = string;
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
        //经纬度
        SNUserLocationManager *locationManager = [SNUserLocationManager sharedInstance];
        NSString *locationString = [locationManager getNewsLocationString];
        if (locationString) {
            reportStr = [reportStr stringByAppendingFormat:@"&%@",locationString];
        }
        [self reportADotGif:reportStr];
    });
}

#pragma mark usr.gif
+ (void)reportUsrDotGif:(NSString *)string {
}

#pragma mark p.go
+ (void)reportPDotGo:(NSString *)actionID msgID:(NSString *)msgID {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
        NSMutableDictionary *params = [NSMutableDictionary dictionaryWithCapacity:10];
        [params setValue:[SNAPI productId] forKey:@"pid"];
        [params setValue:@"iOS" forKey:@"p"];
        [params setValue:[[[NSBundle mainBundle] infoDictionary] objectForKey:kBundleVersionKey] forKey:@"v"];
        [params setValue:[NSString stringWithFormat:@"%zd",[SNUtility marketID]] forKey:@"h"];
        [params setValue:actionID forKey:@"action"];
        [params setValue:[SNUtility getDeviceUDID] forKey:@"pushId"];
        [params setValue:msgID forKey:@"msgId"];
        [params setValue:@"1" forKey:@"isapp"];
        NSString *url = [params appendParamToUrlString:SNLinks_Path_ReportPush];
        [[SNNewsReport shareInstance] reportWithUrl:url];
    });
}

#pragma mark share
+ (void)reportShareWithInfo:(NSDictionary *)dict {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
        ShareTargetType targetType = [[dict stringValueForKey:kShareTargetKey defaultValue:@""] integerValue];
        NSString *targetName = [dict stringValueForKey:kShareTargetNameKey defaultValue:@""];
        NSString *shareType = [dict stringValueForKey:kShareInfoKeyShareType defaultValue:@""];
        if ([shareType isEqualToString:@"qianfan"]) {
            shareType = @"qf_live";
        }
        NSString *shareID = [dict stringValueForKey:kShareInfoKeyNewsId defaultValue:@""];
        if (shareID.length == 0) {
            shareID = [dict stringValueForKey:kRedPacketIDKey defaultValue:@""];
        }
        NSString *shareContent = [[dict stringValueForKey:kShareContentKey defaultValue:@""] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        NSString *shareSubID = [dict stringValueForKey:kShareInfoLogKeySubId defaultValue:@""];
        NSString *userName = [dict stringValueForKey:kShareInfoKeyUserName defaultValue:@""];
        // 为了区分分享  分享评论 增加一个参数scmt
        NSString *comment = [dict stringValueForKey:kShareInfoKeyShareComment defaultValue:@""];
        NSString *paramString = nil;
        NSString *target = nil;
        NSInteger fastShare = 0;
        NSString *h5wt = [dict stringValueForKey:kH5WebType defaultValue:@""];
        switch (targetType) {
            case ShareTargetWeixinFriend: {
                target = @"weixin";
                fastShare = 1;
            }
                break;
            case ShareTargetWeixinTimeline: {
                target = @"weixin_blog";
                fastShare = 2;
            }
                break;
            case ShareTargetQQ_friends: {
                target = @"qq_friends";
            }
                break;
            case ShareTargetQZone: {
                target = @"qq";
            }
                break;
            case ShareTargetAPSession: {
                target = @"alipayFriend";
            }
                break;
            case ShareTargetAPTimeLine: {
                target = @"alipayCircle";
            }
                break;
            case ShareTargetSNS: {
                target = @"sinaweibo";
                if ([shareType isEqualToString:@"fastshare"] && [targetName isEqualToString:@"sinaweibo"]) {
                    fastShare = 3;
                }
                if (userName.length > 0) {
                }
            }
                break;
            case ShareTargetSohu: {
                target = @"sns_sohu";
            }
                break;
            default:
                target = @"other";
                break;
        }
        paramString = [NSString stringWithFormat:kShareReportParams, target,shareType, shareID, shareContent, shareSubID];
        if (fastShare > 0) {
            paramString = [paramString stringByAppendingFormat:@"&dto=%d", fastShare];
        }
        
        if (comment.length > 0) {
            NSString *commentStr = [comment stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
            paramString = [paramString stringByAppendingFormat:@"&scmt=%@", commentStr];
        }
        
        NSString* webUrl = [dict objectForKey:@"webUrl"];
        if (webUrl && webUrl.length>0) {
            paramString = [paramString stringByAppendingFormat:@"&url=%@",[webUrl URLEncodedString]];
        }
        
        if (h5wt.length > 0) {
            paramString = [paramString stringByAppendingString:@"&newstype=8"];
        }
        [self reportADotGif:paramString];
    });
}

- (void)reportWithUrl:(NSString *)url {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
        [[[SNNewsReportRequest alloc] initWithUrl:url] send:nil failure:nil];
    });
}

+ (void)reportChannelStayDuration:(CGFloat)duration channelID:(NSString *)channelId {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
        NSMutableDictionary *params = [NSMutableDictionary dictionaryWithCapacity:10];
        [params setValue:@"channel_stay" forKey:@"_act"];
        [params setValue:@"tm" forKey:@"_tp"];
        [params setValue:[NSNumber numberWithFloat:duration] forKey:@"ttime"];
        [params setValue:channelId forKey:@"channelid"];
        [params setValue:[NSNumber numberWithInteger:[SNUtility AbTestAppStyle]] forKey:@"abmode"];
        [[[SNPickStatisticRequest alloc] initWithDictionary:params andStatisticType:PickLinkDotGifTypeA] send:nil failure:nil];
    });
}

@end
