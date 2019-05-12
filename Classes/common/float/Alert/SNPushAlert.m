//
//  SNPushAlert.m
//  sohunews
//
//  Created by TengLi on 2017/6/26.
//  Copyright © 2017年 Sohu.com. All rights reserved.
//

#import "SNPushAlert.h"
#import "SNNewAlertView.h"
#import "SNAPNSHandler.h"
#import "SNTimelineSharedVideoPlayerView.h"
#import "SNRollingNewsPublicManager.h"

@interface SNPushAlert ()
@property (nonatomic, strong) SNNewAlertView *pushAlert;
@property (nonatomic, strong) NSDictionary *receivedUserInfo;
@end

@implementation SNPushAlert

- (instancetype)initWithAlertViewData:(id)content
{
    self = [super init];
    if (self) {
        self.alertViewType = SNAlertViewPushType;
        [self setAlertViewData:content];
    }
    return self;
}

- (void)setAlertViewData:(id)content {
    if (content && [content isKindOfClass:[NSDictionary class]]) {
        NSDictionary *receivedUserInfo = (NSDictionary *)content;
        self.receivedUserInfo = receivedUserInfo;
        id pushAlert = nil;
        NSDictionary *apsDict = [receivedUserInfo objectForKey:kPushAPS];
        pushAlert = [apsDict objectForKey:kPushAlert];
        NSString *pushTitle = nil;
        NSString *pushContent = nil;
        if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"10.0")) {
            if (pushAlert && [pushAlert isKindOfClass:[NSDictionary class]]) {
                pushTitle = [pushAlert objectForKey:kPushTitle];
                pushContent = [pushAlert objectForKey:kPushBody];
            }
        } else {
            if (pushAlert && [pushAlert isKindOfClass:[NSString class]]) {
                pushContent = pushAlert;
            }
        }
        if (0 == pushTitle.length) {
            pushTitle = kBundleNameKey;
        }
        
        SNNewAlertView *pushAlertView = [[SNNewAlertView alloc] initWithTitle:pushTitle
                                                                      message:pushContent
                                                                     delegate:self
                                                            cancelButtonTitle:@"关闭"
                                                             otherButtonTitle:@"立即查看"];
        self.pushAlert = pushAlertView;
        self.pushAlert.alertViewType = SNAlertViewPushType;
        __weak typeof(self)weakself = self;
        [pushAlertView actionWithBlocksCancelButtonHandler:^{
            [SNNewsReport reportADotGif:@"_act=push&_tp=incancel"];
            [SNUtility clearPushCount];
        } otherButtonHandler:^{
            
            [[SNUtility sharedUtility] setLastOpenUrl:nil];
            if ([[[TTNavigator navigator] topViewController] isKindOfClass:[SKStoreProductViewController class]]) {
                SKStoreProductViewController *storeProductViewController = (SKStoreProductViewController*)[[TTNavigator navigator] topViewController];
                [storeProductViewController dismissModalViewController];
            }
            // 处理反馈页面上传图片接到推送查看
            UIViewController *viewController = [[TTNavigator navigator] topViewController];
            if ([viewController isKindOfClass:NSClassFromString(@"PUUIAlbumListViewController")] || [viewController isKindOfClass:NSClassFromString(@"PUUIPhotosAlbumViewController")] || [viewController isKindOfClass:NSClassFromString(@"PUUIMomentsGridViewController")] || [viewController isKindOfClass:NSClassFromString(@"PLUIPrivacyViewController")]) {
                [viewController dismissViewControllerAnimated:NO completion:nil];
            }
            [SNNewsReport reportADotGif:@"_act=push&_tp=inread"];
            if ([pushTitle isEqualToString:NSLocalizedString(@"liveRoom", @"liveRoom")]) {
                [weakself openLive:receivedUserInfo];
            } else {
                [weakself showRemotePush];
            }
            [SNUtility clearPushCount];
//            [SNUtility forceScreenPortrait];
        }];

    }
}

- (void)showAlertView {
    if (self.pushAlert) {
        [super showAlertView];
        //收到了通知 发个notify
        [SNNotificationManager postNotificationName:kNotifyDidReceive object:nil userInfo:self.receivedUserInfo];
        [[UIApplication sharedApplication].keyWindow endEditing:YES];
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.25 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self.pushAlert show];
            [[SNUtility getApplicationDelegate].pushNotificationQueue cleanUp];
        });
    } else {
        [self dismissAlertView];
    }
}

- (void)openLive:(NSDictionary *)notificationDict {
    NSMutableDictionary *userInfo = [NSMutableDictionary dictionary];
    NSString *liveId = [notificationDict objectForKey:kLiveIdKey];
    NSString *liveType = [notificationDict objectForKey:kLiveTypeKey];
    
    if (liveId) {
        [userInfo setObject:liveId forKey:kLiveIdKey];
    }
    
    if (liveType) {
        [userInfo setObject:liveType forKey:kLiveTypeKey];
    }
    if (liveId) {
        TTURLAction *urlAction = [[[TTURLAction actionWithURLPath:@"tt://live"] applyAnimated:YES] applyQuery:userInfo];
        [[TTNavigator navigator] openURLAction:urlAction];
    }
}

- (void)showRemotePush {
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, NSEC_PER_SEC * 0.5), dispatch_get_main_queue(), ^{
        [SNNotificationManager postNotificationName:kNotifyExpressShow object:nil userInfo:[NSDictionary dictionaryWithObject:[NSNumber numberWithBool:YES] forKey:kShowNotificationKey]];
    });
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, NSEC_PER_SEC * 0.1), dispatch_get_main_queue(), ^() {
        [SNUtility shouldUseSpreadAnimation:NO];
        [self handleReceiveNotify];
    });
    
    [[UIApplication sharedApplication] setStatusBarOrientation:UIInterfaceOrientationPortrait];
    [UIApplication sharedApplication].statusBarHidden = NO;
}

- (void)handleReceiveNotify {
    if (self.receivedUserInfo) {
        [UIApplication sharedApplication].applicationIconBadgeNumber = 0;

        NSString *pushURLStr = [self.receivedUserInfo objectForKey:kNotifyUrlKey];//v3.0.1开始看url属性，为了兼容老版本不能接收即时新闻推送
        if (nil == pushURLStr) {
            pushURLStr = [self.receivedUserInfo objectForKey:kNotifyKey]; //v3.0.1以前都看pushurl属性，仍然收快讯报纸
            pushURLStr = [pushURLStr stringByReplacingOccurrencesOfString:@".xml" withString:@""];//去掉.xml后缀
        }
        
        SNDebugLog(@"pushNotificationData : %@",self.receivedUserInfo);
        SNDebugLog(@"pushURLStr : %@",pushURLStr);
        
        if (self.receivedUserInfo && self.receivedUserInfo.count > 0 && pushURLStr && ![@"" isEqualToString:pushURLStr]) {
            if (pushURLStr.length) {
                [[SNTimelineSharedVideoPlayerView sharedInstance] forceStop];
                [SNNotificationManager postNotificationName:kNotifyDidHandled object:nil];
                
                NSMutableDictionary *context = [NSMutableDictionary dictionary];
                
                [context setValuesForKeysWithDictionary:self.receivedUserInfo];
                [context setObject:@"notify" forKey:@"notification"];
                [context setObject:@"1" forKey:kNewsExpressType];
                
                if ([pushURLStr startWith:kProtocolVideo]) {
                    [context setObject:@(WSMVVideoPlayerRefer_PushNotification) forKey:kWSMVVideoPlayerReferKey];
                }
                [context setObject:kNewsOnline forKey:kNewsMode];
                SNDebugLog(@"%@", context);
                
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
                
                //小说push跳转埋点统计
                if ([pushURLStr containsString:kProtocolStoryReadChapter]) {
                    NSDictionary *dic = [SNUtility parseURLParam:pushURLStr schema:kProtocolStoryReadChapter];
                    NSString *bookId = [NSString stringWithFormat:@"%@",[dic objectForKey:@"novelId"]];
                    if ([dic allKeys].count > 2) {//继续阅读push点击埋点统计
                        [SNNewsReport reportADotGif:[NSString stringWithFormat:@"act=fic&tp=pv&from=9&bookId=%@",bookId]];
                    } else {//阅读页push点击埋点统计
                        [SNNewsReport reportADotGif:[NSString stringWithFormat:@"act=fic&tp=pv&from=8&bookId=%@",bookId]];
                    }
                } else if ([pushURLStr containsString:kProtocolStoryNovelDetail]) {//详情页push点击埋点统计
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

- (void)dealloc {
    self.pushAlert = nil;
}

@end
