//
//  SNSpecialActivity.m
//  sohunews
//
//  Created by yangln on 2017/9/5.
//  Copyright © 2017年 Sohu.com. All rights reserved.
//

#import "SNSpecialActivity.h"
#import "SNSpecialActivityRequest.h"
#import "SNSpecialAD.h"
#import "SNAlertStackManager.h"
#import "TMCache.h"
#import "SNRollingNewsViewController.h"
#import "SNSpecialActivityAlert.h"

#define RequestSuccessCode @"20170000"

@interface SNSpecialActivity () {
    TMCache * _cache;
    NSInteger _newsPageOpenCount;
}
@property (nonatomic, strong) SNSpecialActivityAlert * lastSpecialAlert;
@property (nonatomic, strong) SNSpecialAD * homePageAd;
@property (nonatomic, strong) NSMutableDictionary<NSString*, SNSpecialAD*> * channelAds;
@property (nonatomic, strong) SNSpecialAD * newsDetailAd;

@end

@implementation SNSpecialActivity

+ (SNSpecialActivity *)shareInstance {
    static SNSpecialActivity *specialActivity = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        specialActivity = [[SNSpecialActivity alloc] init];
    });
    return specialActivity;
}

- (void)requestActivityInfo {
    [[[SNSpecialActivityRequest alloc] init] send:^(SNBaseRequest *request, id response) {
        if (response && [response isKindOfClass:[NSDictionary class]]) {
            NSDictionary *responseDict = response;
            if ([[responseDict stringValueForKey:@"statusCode" defaultValue:@""] isEqualToString:RequestSuccessCode]) {
                self.activityInfo = [responseDict dictionaryValueForKey:kSpecialActivityData defalutValue:nil];
                [self parseActivityInfoDict:self.activityInfo];
            }
        }
    } failure:^(SNBaseRequest *resuet, NSError *error) {
    }];
    
    [self fetchSpecialADConfig];
}

- (void)parseActivityInfoDict:(NSDictionary *)infoDict {
    NSString *resourceUrl = [infoDict stringValueForKey:kSpecialActivityMaterial defaultValue:@""];
    if (resourceUrl.length > 0) {
        NSString *lastMD5 = [[NSUserDefaults standardUserDefaults] objectForKey:kSpecialActivityMD5Key];
        if ([[infoDict stringValueForKey:kSpecialActivityMD5Key defaultValue:@""] isEqualToString:lastMD5]) {
            //根据MD5有无变化，区分是否新下载zip包
            [SNUtility trigerSpecialActivity];
            return;
        }
        if (!self.isDownLoading) {
            self.isDownLoading = YES;
            [self clearActivityResource];
            [self downLaodActivityResource:infoDict];
        }
    }
    else {
        [self clearActivityResource];
    }
}

- (void)downLaodActivityResource:(NSDictionary *)dict {
    Reachability *reachability = [((sohunewsAppDelegate *)[UIApplication sharedApplication].delegate) getInternetReachability];
    NetworkStatus currentNetStatus = [reachability currentReachabilityStatus];
    if (currentNetStatus != ReachableViaWiFi) {
        //仅wifi下下载物料
        self.isDownLoading = NO;
        return;
    }
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSString *resourceUrl = [dict objectForKey:kSpecialActivityMaterial];
        NSString *md5Value = [dict objectForKey:kSpecialActivityMD5Key];
        NSURL *url = [NSURL URLWithString:resourceUrl];
        NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
        request.timeoutInterval = 500;
        NSError *error = nil;
        NSData *data = [NSURLConnection sendSynchronousRequest:request returningResponse:nil error:&error];
        NSString *path = [SNUtility getDocumentPath];
        path = [path stringByAppendingPathComponent:kSpecialActivityDocumentName];
        [[NSFileManager defaultManager] createDirectoryAtPath:path withIntermediateDirectories:YES attributes:nil error:nil];
        NSString *filePath = [path stringByAppendingPathComponent:kSpecialActivityDocumentZipName];
        /* 下载的数据 */
        if (data != nil){
            if ([data writeToFile:filePath atomically:YES]) {
                CFStringRef cfRef = FileMD5HashCreateWithPath((__bridge CFStringRef)(filePath));
                NSString *fileMD5 = (__bridge NSString *)cfRef;
                //MD5校验过之后，解压
                if ([fileMD5 isEqualToString:md5Value]) {
                    [[NSUserDefaults standardUserDefaults] setObject:fileMD5 forKey:kSpecialActivityMD5Key];
                    [[NSUserDefaults standardUserDefaults] synchronize];
                    
                    [[NSFileManager defaultManager] createDirectoryAtPath:path withIntermediateDirectories:YES attributes:nil error:nil];
                    [SNUtility unZipFile:filePath zipFileTo:path];
                    
                    //避免弱网络下，图片未下载完成
                    [self processActivityInBadNetWork];
                    
                    [SNNewsReport reportADotGif:@"_act=ad_download&_tp=success"];
                }
                CFRelease(cfRef);
            }
            else {
                SNDebugLog(@"保存失败.");
            }
        } else {
            SNDebugLog(@"%@", error);
            [SNNewsReport reportADotGif:@"_act=ad_download&_tp=fail"];
        }
        self.isDownLoading = NO;
    });
}

- (void)processActivityInBadNetWork {
    SNSplashViewController *splashViewController = [SNUtility getApplicationDelegate].splashViewController;
    SNSplashModel *splashModel = [SNUtility getApplicationDelegate].splashModel;
    if ((LoadingSwitch ? !splashModel.isSplashVisible : !splashViewController.isSplashViewVisible)) {
        UIViewController *topViewController = [TTNavigator navigator].topViewController;
        if ([[SNUtility sharedUtility].currentChannelId isEqualToString:@"1"] && [topViewController isKindOfClass:NSClassFromString(@"SNRollingNewsViewController")] && [[NSUserDefaults standardUserDefaults] boolForKey:kNewUserGuideHadEndShown]) {
            [SNUtility trigerSpecialActivity];
        }
    }
}

- (void)clearActivityResource {
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSString *path = [SNUtility getDocumentPath];
    path = [path stringByAppendingPathComponent:kSpecialActivityDocumentName];
    if ([fileManager fileExistsAtPath:path]) {
        [fileManager removeItemAtPath:path error:nil];
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:kSpecialActivityMD5Key];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
}

#pragma mark -
#pragma mark - Public Method
//准备展示对应的广告  需要在相应的页面来调用
- (BOOL)prepareShowFloatingADWithType:(SNFloatingADType)ADType majorkey:(NSString *)mkey{
    NSAssert([NSThread isMainThread], @"SNAlertStackManager addAlertViewToAlertStack: needs to be accessed on the main thread.");
    BOOL ret = NO;
    switch (ADType) {
        case SNFloatingADTypeHomePage:
        {
            break;
        }
        case SNFloatingADTypeChannels:
        {
            SNSpecialAD * prepareAd = nil;
            if (mkey.length > 0) {
                prepareAd = self.channelAds[mkey];
            }
            ///先处理红包，有广告不能显示红包
            SNRollingNewsViewController *newsViewController = nil;
            SNRollingNewsTableController *newsTableController = nil;
            if ([[[TTNavigator navigator] topViewController] isKindOfClass:[SNRollingNewsViewController class]]) {
                newsViewController = (SNRollingNewsViewController*)[[TTNavigator navigator] topViewController];
                newsTableController = (SNRollingNewsTableController*)[newsViewController getCurrentTableController];
            }
            if (prepareAd.available && [SNSpecialADTools didDownloadResourceWithMajorkey:mkey]) {
                ///如果广告目前可用
                newsTableController.redPacketBtn.hidden = YES;
                if (self.lastSpecialAlert.isShowing) {
                    //如果有前一个alert广告，需要先dismiss掉
                    __weak SNSpecialActivity * weakSelf = self;
                    [self.lastSpecialAlert dismissAlertViewCompleted:^{
                        SNSpecialActivityAlert * specialActivity = [[SNSpecialActivityAlert alloc] initWithAlertViewData:prepareAd];
                        specialActivity.adType = ADType;
                        weakSelf.lastSpecialAlert = specialActivity;
                        [[SNAlertStackManager sharedAlertStackManager] addAlertViewToAlertStack:specialActivity];
                    }];
                }else{
                    //如果没有之前的alert广告，则直接创建并add到stack中
                    SNSpecialActivityAlert * specialActivity = [[SNSpecialActivityAlert alloc] initWithAlertViewData:prepareAd];
                    specialActivity.adType = ADType;
                    self.lastSpecialAlert = specialActivity;
                    [[SNAlertStackManager sharedAlertStackManager] addAlertViewToAlertStack:specialActivity];
                }
                ret = YES;
            }else{
                [self.lastSpecialAlert dismissAlertViewCompleted:^{
                }];
                self.lastSpecialAlert = nil;
                [newsViewController setRedPacketShow];
            }
            break;
        }
        case SNFloatingADTypeNewsDetail:
        {
            [self recordNewsPageOpenCount];
            if ([self.newsDetailAd availableWithPageCount:_newsPageOpenCount] && [SNSpecialADTools didDownloadResourceWithMajorkey:mkey]) {
                SNSpecialActivityAlert *specialActivity = [[SNSpecialActivityAlert alloc] initWithAlertViewData:self.newsDetailAd];
                specialActivity.adType = ADType;
                [[SNAlertStackManager sharedAlertStackManager] addAlertViewToAlertStack:specialActivity];
                ret = YES;
            }
            break;
        }
        default:
            break;
    }
    return ret;
}

- (void)dismissLastChannelSpecialAlert {
    if (self.lastSpecialAlert.isShowing) {
        [self.lastSpecialAlert dismissAlertViewCompleted:^{
        }];
        self.lastSpecialAlert = nil;
        if ([[[TTNavigator navigator] topViewController] isKindOfClass:[SNRollingNewsViewController class]]) {
            SNRollingNewsViewController *newsViewController = (SNRollingNewsViewController*)[[TTNavigator navigator] topViewController];
            SNRollingNewsTableController *newsTableController = (SNRollingNewsTableController*)[newsViewController getCurrentTableController];
            [newsViewController setRedPacketShow];
        }
    }
}

- (void)setCurrentShowingChannelAlert:(SNSpecialActivityAlert *)alert {
    self.lastSpecialAlert = alert;
}

- (BOOL)isShowingChannelSpecialAd {
    return self.lastSpecialAlert.isShowing;
}

- (void)fetchSpecialADConfig {
    
    [SNSpecialADTools fetchAdConfigArticleAd:^(NSArray *articleAds) {
        if (articleAds.count > 0) {
            //正文页广告
            [self updateNewsDetailAdWithDic:articleAds.firstObject];
            //同步到本地
            [self updateAdCache:self.newsDetailAd majorkey:SNFloatingADTypeNewsDetailIdentifier];
        }
    } channelAd:^(NSArray *channelAds) {
        if (channelAds.count > 0) {
            //频道流
            [self updateChannelAdsWithArray:channelAds];
            //同步到本地
            [self updateAdGroupCache:self.channelAds majorkey:SNFloatingADTypeChannelsIdentifier];
        }
    }];
}

//同步到本地
- (void)saveSpecialAdState {
    [self updateAdCache:self.newsDetailAd majorkey:SNFloatingADTypeNewsDetailIdentifier];
    [self updateAdGroupCache:self.channelAds majorkey:SNFloatingADTypeChannelsIdentifier];
}

- (void)recordNewsPageOpenCount {
    //看缓存里有没有
    NSString * countStr = [self.cache objectForKey:SNNewsPageOpenCountCacheKey];
    if (countStr.length > 0) {
        _newsPageOpenCount = [countStr integerValue];
    }else{
        _newsPageOpenCount = 0;
    }
    //看是否超过一个自然日，超过了则计数归零
    NSDate * lastDate = [self.cache objectForKey:SNNewsPageOpenDateCacheKey];
    if (lastDate && [SNSpecialADTools isNaturalDaythanDate: lastDate withTimePoint:self.newsDetailAd.statPoint]) {
        _newsPageOpenCount = 0;
    }
    _newsPageOpenCount += 1;
    [self.cache setObject:[NSString stringWithFormat:@"%d",_newsPageOpenCount] forKey:SNNewsPageOpenCountCacheKey];
    [self.cache setObject:[NSDate date] forKey:SNNewsPageOpenDateCacheKey];
}

#pragma makr -
#pragma mark - Private Method

- (void)updateNewsDetailAdWithDic:(NSDictionary *)dic {
    //正文页广告
    if (!self.newsDetailAd) {
        self.newsDetailAd = [self adCacheForKey:SNFloatingADTypeNewsDetailIdentifier];
    }
    if (!self.newsDetailAd) {
        self.newsDetailAd = [SNSpecialAD createSpecialADWithDictionary:dic];
    }else{
        [self.newsDetailAd updateWithDic:dic];
    }
    if (self.newsDetailAd.needRefreshResources || ![SNSpecialADTools didDownloadResourceWithMajorkey:self.newsDetailAd.spaceId]) {
        [SNSpecialADTools preDownloadAdResourceWithUrl:self.newsDetailAd.material md5Key:self.newsDetailAd.md5Key majorKey:self.newsDetailAd.spaceId];
    }
}

- (void)updateChannelAdsWithArray:(NSArray *)channelAds {
    //频道流广告
    //如果服务端将已经下发过的，并且在有效期内的广告删除，则客户端仍然会展示，
    //如果想删除某个广告，必须服务端修改广告有效期，不可直接删除
    //如果广告已经到期，则可随意删除
    if (!self.channelAds) {
        NSDictionary * cacheAds = [self adGroupCacheForKey:SNFloatingADTypeChannelsIdentifier];
        self.channelAds = [NSMutableDictionary dictionaryWithDictionary:cacheAds];
        if (self.channelAds) {
            //清理缓存中的失效广告
            NSMutableArray * tempChannelIds = [NSMutableArray array];
            for (NSString * key in self.channelAds.allKeys) {
                SNSpecialAD * ad = [self.channelAds objectForKey:key];
                if (!ad.isAvailableFromLifeCircle || ![ad isKindOfClass:[SNSpecialAD class]]) {
                    [tempChannelIds addObject:key];
                }
            }
            for (NSString * channelId in tempChannelIds) {
                [self.channelAds removeObjectForKey:channelId];
                
            }
        }
    }
    if (!self.channelAds) {
        self.channelAds = [NSMutableDictionary dictionary];
    }
    for (NSDictionary * adDic in channelAds) {
        if ([adDic isKindOfClass:[NSDictionary class]]) {
            NSString * channelId = [adDic stringValueForKey:kSpecialActivityChannelId defaultValue:nil];
            if (channelId) {
                SNSpecialAD * ad = [self.channelAds objectForKey:channelId];
                if (ad) {
                    //如果之前存在，则更新广告信息
                    //并且需要保留之前的曝光计数
                    [ad updateWithDic:adDic];
                }else{
                    //如果之前没有，则创建新的广告模型
                    ad = [SNSpecialAD createSpecialADWithDictionary:adDic];
                    if (ad) {
                        [self.channelAds setObject:ad forKey:channelId];
                    }
                }
                [ad limitExposureCount];
                if (ad.needRefreshResources) {
                    [SNSpecialADTools preDownloadAdResourceWithUrl:ad.material md5Key:ad.md5Key majorKey:ad.spaceId];
                }
            }
        }
    }
}

#pragma mark -
#pragma mark - 存储
- (void)updateAdGroupCache:(NSMutableDictionary<NSString*, SNSpecialAD*> *)adGroup majorkey:(NSString *)mkey {
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        if (adGroup && mkey.length > 0) {
            [self.cache setObject:adGroup forKey:mkey];
        }
    });
}

- (void)updateAdCache:(SNSpecialAD *)adModel majorkey:(NSString *)mkey {
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        if (adModel && mkey.length > 0) {
            [self.cache setObject:adModel forKey:mkey];
        }
    });
}

- (NSMutableDictionary<NSString*, SNSpecialAD*> *)adGroupCacheForKey:(NSString *)mkey {
    if (mkey.length > 0) {
        return [self.cache objectForKey:mkey];
    }
    return nil;
}

- (SNSpecialAD *)adCacheForKey:(NSString *)mkey {
    if (mkey.length > 0) {
        return [self.cache objectForKey:mkey];
    }
    return nil;
}

- (void)clearSNSpecialADCache {
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        [self.cache removeAllObjects];
        self.newsDetailAd = nil;
        [self.channelAds removeAllObjects];
    });
}

- (TMCache *)cache {
    if (!_cache) {
        _cache = [[TMCache alloc] initWithName:@"SNSpecialADCache"];
    }
    return _cache;
}

@end
