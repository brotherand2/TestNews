//
//  COMPCompassManager.m
//  Compass
//
//  Created by 李耀忠 on 24/09/2017.
//  Copyright © 2017 Beijing Sohu New Media Information Technology Co. Ltd. All rights reserved.
//

#import "COMPCompassManager.h"
#import "COMPCompassManager+Private.h"
#import <UIKit/UIKit.h>
#import "COMPConstant.h"
#import "COMPConfig.h"
#import "COMPNetworkReachabilityManager.h"
#import "Recorditem.pb.h"
#import "NSString+COMPMD5.h"
#import "UIDevice+COMPExtension.h"
#import "COMPDatabase.h"
#import "COMPApi.h"
#import "COMPStatisticsTableAccess.h"
#import "COMPNetworkReachabilityManager.h"
#import "COMPHelper.h"
#import <objc/runtime.h>
#import "NSObject+COMPExtension.h"
#import "COMPRequestError.h"
#import "COMPConfiguration.h"
#import "COMPConfiguration+Private.h"

#define NO_VALUE -1

@interface COMPCompassManager ()

@property (nonatomic, readwrite) COMPConfiguration *configuration;
@property (nonatomic) NSString *postUrl;
@property (nonatomic) COMPStatisticsTableAccess *databaseAccess;
@property (nonatomic, weak) NSURLSessionDataTask *task;
@property (nonatomic) dispatch_queue_t dbqueue;
@property (nonatomic) NSInteger count;
@property (nonatomic) NSInteger retryCount;
@property (nonatomic) NSTimer *timer;

@property (nonatomic, copy) NSString *cid;
@property (nonatomic, copy) NSString *channelId;
@property (nonatomic, copy) NSString *currentMD5;

@property (nonatomic) int64_t appStartTimestamp;
@property (nonatomic) int64_t appEnterBackgroundTimestamp;

@property (nonatomic) NSMutableDictionary<NSURLSessionTask *, COMPAppRequestInfo *> *requestUrlDict;
@property (nonatomic) dispatch_queue_t requestInfoQueue;

@end

@implementation COMPCompassManager

@synthesize appStartTimestamp = _appStartTimestamp;
@synthesize appEnterBackgroundTimestamp = _appEnterBackgroundTimestamp;

+ (instancetype)sharedInstance {
    static dispatch_once_t onceToken;
    static COMPCompassManager *manager;
    dispatch_once(&onceToken, ^{
        manager = [[COMPCompassManager alloc] init];
    });

    return manager;
}

+ (void)startWithCId:(NSString*)cid {
    [self startWithCId:cid channelId:CHANNEL_APP_STORE configuration:nil];
}

+ (void)startWithCId:(NSString *)cid configuration:(COMPConfiguration *)configuration {
    [self startWithCId:cid channelId:CHANNEL_APP_STORE configuration:configuration];
}

+ (void)startWithCId:(NSString *)cid channelId:(NSString *)channelId configuration:(COMPConfiguration *)configuration {
    COMPCompassManager *instance = [self sharedInstance];
    instance.cid = cid;
    instance.channelId = channelId;
    if (configuration) {
        COMPConfiguration *copyConfiguration = [COMPConfiguration defaultConfiguration];
        copyConfiguration.allowInterveneNetwork = configuration.allowInterveneNetwork;
        instance.configuration = copyConfiguration;
    } else {
        instance.configuration = [COMPConfiguration defaultConfiguration];
    }

    [instance start];
}

- (instancetype)init {
    self = [super init];
    if (self) {
        _requestUrlDict = [NSMutableDictionary dictionary];
        _requestInfoQueue = dispatch_queue_create("COMPASS_Request_Queue", DISPATCH_QUEUE_CONCURRENT);
        _dbqueue = dispatch_queue_create("Compass_Statistics_DB_Queue", DISPATCH_QUEUE_SERIAL);

        _appStartTimestamp = NO_VALUE;
        _appEnterBackgroundTimestamp = NO_VALUE;
    }

    return self;
}

- (void)start {
    NSString *documentPath = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)[0];
    NSString *databasePath = [documentPath stringByAppendingPathComponent:DATABASE_PATH];

    COMPDatabase *database = [COMPDatabase databaseWithPath:databasePath];
    if (!database) {
        return;
    }
    _databaseAccess = [[COMPStatisticsTableAccess alloc] initWithDatabase:database];
    BOOL result = [_databaseAccess createTable];
    if (!result) {
        return;
    }
    _count = [_databaseAccess count];

    //首先上传AppDeviceInfo，该信息每天只上传一次
    [self uploadAppDeviceInfo];
    //删除7天前的记录，防止数据库过度膨胀
    [self deleteOldStatistics];
    
    //监测网络连接状态
    [[COMPNetworkReachabilityManager sharedInstance] startReachabilityMonitoring];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reachabilityStatusChanged:) name:COMPNetowrkReachabilityStatusChangedNotification object:nil];
    
    if (self.configuration.timeIntervalForUpload > 0) {
        _timer = [NSTimer scheduledTimerWithTimeInterval:self.configuration.timeIntervalForUpload target:self selector:@selector(timerHandler:) userInfo:nil repeats:YES];
    }
    //启动后立马上传一次
    [self timerHandler:_timer];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationDidFinishLaunching:) name:UIApplicationDidFinishLaunchingNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationDidEnterBackground:) name:UIApplicationDidEnterBackgroundNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationWillEnterForeground:) name:UIApplicationWillEnterForegroundNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleApplicationSignificantTimeChangeNotification:) name:UIApplicationSignificantTimeChangeNotification object:nil];
}

- (void)dealloc {
    [self.timer invalidate];
    [[COMPNetworkReachabilityManager sharedInstance] stopReachabilityMonitoring];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (BOOL)isReachable {
    if (self.configuration.allowsCellularAccess) {
        return [COMPNetworkReachabilityManager sharedInstance].isReachable;
    } else {
        return [COMPNetworkReachabilityManager sharedInstance].isReachableViaWiFi;
    }
}

- (void)reachabilityStatusChanged:(NSNotification *)notification {
    __weak typeof(self) weakSelf = self;
    dispatch_async(self.dbqueue, ^{
        if (!weakSelf.task && weakSelf.retryCount >= UPLOAD_RETRY_COUNT && weakSelf.isReachable) {
            weakSelf.retryCount = 0;
            [weakSelf uploadStatisticsToServer];
        }
    });
}

- (void)timerHandler:(NSTimer *)timer {
    __weak typeof(self) weakSelf = self;
    dispatch_async(self.dbqueue, ^{
        if (!weakSelf.task && weakSelf.isReachable) {
            [weakSelf uploadStatisticsToServer];
        }
    });
}

- (void)deleteOldStatistics {
    //删除7天之前的历史记录
    __weak typeof(self) weakSelf = self;
    dispatch_async(self.dbqueue, ^{
        NSDate *date = [NSDate dateWithTimeIntervalSinceNow:-DB_MAX_LIFE];
        [weakSelf.databaseAccess deleteDataBeforeDate:date];
    });
}

#pragma mark - AppDeviceInfo

- (void)uploadAppDeviceInfo {
    COMPAppDeviceInfo *appDeviceInfo = [[COMPAppDeviceInfo alloc] init];
    appDeviceInfo.appName = [self appName];
    appDeviceInfo.deviceType = PLANTFORM_IOS;
    appDeviceInfo.brand = BRAND_APPLE;
    appDeviceInfo.product = [self product];
    appDeviceInfo.sdkVersion = SDK_VERSION;
    appDeviceInfo.appVersion = [self appVersion];
    appDeviceInfo.channel = CHANNEL_APP_STORE;
    appDeviceInfo.systemVersion = [self systemVersion];

    NSInteger rand = [[NSUserDefaults standardUserDefaults] integerForKey:COMP_USER_KEY_RAND];
    if (rand == 0) {
        rand = arc4random_uniform(INT_MAX - 1) + 1;
        [[NSUserDefaults standardUserDefaults] setInteger:rand forKey:COMP_USER_KEY_RAND];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
    appDeviceInfo.rand = (int32_t)rand;

    NSString *md5 = [[NSString alloc] initWithData:appDeviceInfo.data encoding:NSUTF8StringEncoding].comp_md5;
    NSString *md5Previous = [[NSUserDefaults standardUserDefaults] stringForKey:COMP_USER_KEY_MD5];
    self.currentMD5 = md5;

    BOOL needUpdate = NO;
    NSString *dateString = [[NSUserDefaults standardUserDefaults] stringForKey:COMP_USER_KEY_DATE];
    NSString *todayString = [COMPHelper currentDateString];
    if (!dateString || ![dateString isEqualToString:todayString]) {
        needUpdate = YES;
        [[NSUserDefaults standardUserDefaults] setObject:todayString forKey:COMP_USER_KEY_DATE];
    }

    if (![md5 isEqualToString:md5Previous]) {
        needUpdate = YES;
        [[NSUserDefaults standardUserDefaults] setObject:md5 forKey:COMP_USER_KEY_MD5];
    }

    if (needUpdate) {
        appDeviceInfo.md5 = md5;
        [[NSUserDefaults standardUserDefaults] synchronize];

        COMPRecordItemElem *recordItemElem = [[COMPRecordItemElem alloc] init];
        recordItemElem.appDeviceInfo = appDeviceInfo;
        recordItemElem.ts = [COMPHelper timestampInMiniseconds];
        NSData *jsonData = recordItemElem.data;

        [self addStatisticsDataToDB:jsonData];
    }
}

//备注：名字是appName，但上传的是bundleId
- (NSString *)appName {
    static dispatch_once_t onceToken;
    static NSString *bundleIdentifier;
    dispatch_once(&onceToken, ^{
        NSDictionary *infoDictionary = [[NSBundle mainBundle] infoDictionary];
        bundleIdentifier = infoDictionary[(__bridge NSString *)kCFBundleIdentifierKey];
    });

    return bundleIdentifier;
}

- (NSString *)deviceId {
    static dispatch_once_t onceToken;
    static NSString *deviceId;
    dispatch_once(&onceToken, ^{
        deviceId = [UIDevice currentDevice].identifierForVendor.UUIDString;
    });

    return deviceId;
}
- (NSString *)product {
    static dispatch_once_t onceToken;
    static NSString *modelName;
    dispatch_once(&onceToken, ^{
        modelName = [UIDevice comp_deviceModelName];
    });

    return modelName;
}

- (NSString *)appVersion {
    static dispatch_once_t onceToken;
    static NSString *appVersion;
    dispatch_once(&onceToken, ^{
        NSDictionary *infoDictionary = [[NSBundle mainBundle] infoDictionary];
        appVersion = [infoDictionary objectForKey:@"CFBundleShortVersionString"];
    });

    return appVersion;
}

- (NSString *)systemVersion {
    static dispatch_once_t onceToken;
    static NSString *systemVersion;
    dispatch_once(&onceToken, ^{
        systemVersion = [UIDevice currentDevice].systemVersion;
    });

    return systemVersion;
}

#pragma mark - AppSessionInfo

- (int64_t)appStartTimestamp {
    if (_appStartTimestamp == NO_VALUE) {
        _appStartTimestamp = [[[NSUserDefaults standardUserDefaults] objectForKey:COMP_USER_KEY_START_TIME] longLongValue];
    }
    return _appStartTimestamp;
}

- (void)setAppStartTimestamp:(int64_t)appStartTimestamp {
    _appStartTimestamp = appStartTimestamp;
    [[NSUserDefaults standardUserDefaults] setObject:@(appStartTimestamp) forKey:COMP_USER_KEY_START_TIME];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (int64_t)appEnterBackgroundTimestamp {
    if (_appEnterBackgroundTimestamp == NO_VALUE) {
        _appEnterBackgroundTimestamp = [[[NSUserDefaults standardUserDefaults] objectForKey:COMP_USER_KEY_BACKGROUND_TIME] longLongValue];
    }
    return _appEnterBackgroundTimestamp;
}

- (void)setAppEnterBackgroundTimestamp:(int64_t)appEnterBackgroundTimestamp {
    _appEnterBackgroundTimestamp = appEnterBackgroundTimestamp;
    [[NSUserDefaults standardUserDefaults] setObject:@(appEnterBackgroundTimestamp) forKey:COMP_USER_KEY_BACKGROUND_TIME];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (void)applicationDidFinishLaunching:(NSNotification *)notification {
    NSDictionary *userInfo = notification.userInfo;
    COMPAppSessionInfo *sessionInfo = [[COMPAppSessionInfo alloc] init];
    sessionInfo.sessionType = COMPOpenAppType;
    sessionInfo.md5 = self.currentMD5;
    //App正常启动
    if (!userInfo) {
        sessionInfo.appOpenType = COMPAppStartType;
    } else if (userInfo[UIApplicationLaunchOptionsRemoteNotificationKey] != nil || userInfo[UIApplicationLaunchOptionsLocalNotificationKey] != nil) {
        sessionInfo.appOpenType = COMPPushStartType;
    } else if (userInfo[UIApplicationLaunchOptionsURLKey] != nil || userInfo[UIApplicationLaunchOptionsSourceApplicationKey] != nil) {
        sessionInfo.appOpenType = COMPThirdPartyAppStartType;
        sessionInfo.thirdPartyAppName = userInfo[UIApplicationLaunchOptionsSourceApplicationKey];
    }

    //INFO：App打开时，duration记录与App上次进入后台的duration，最长为一周
    self.appStartTimestamp = [COMPHelper timestampInMiniseconds];
    if (self.appEnterBackgroundTimestamp <= 0) {
        sessionInfo.duration = SESSION_MAX_LIFE;
    } else {
        sessionInfo.duration = self.appStartTimestamp - self.appEnterBackgroundTimestamp;
        if (sessionInfo.duration > SESSION_MAX_LIFE) {
            sessionInfo.duration = SESSION_MAX_LIFE;
        }
    }
    [self uploadAppSessionInfo:sessionInfo];

    self.appEnterBackgroundTimestamp = 0;
}

- (void)applicationDidEnterBackground:(NSNotification *)notification {
    self.appEnterBackgroundTimestamp = [COMPHelper timestampInMiniseconds];

    COMPAppSessionInfo *sessionInfoClose = [[COMPAppSessionInfo alloc] init];
    sessionInfoClose.sessionType = COMPCloseAppType;
    sessionInfoClose.duration = self.appEnterBackgroundTimestamp - self.appStartTimestamp;
    if (sessionInfoClose.duration > SESSION_MAX_LIFE) {
        sessionInfoClose.duration = SESSION_MAX_LIFE;
    }
    sessionInfoClose.md5 = self.currentMD5;
    [self uploadAppSessionInfo:sessionInfoClose];

    self.appStartTimestamp = 0;
}

- (void)applicationWillEnterForeground:(NSNotification *)notification {
    self.appStartTimestamp = [COMPHelper timestampInMiniseconds];

    COMPAppSessionInfo *sessionInfo = [[COMPAppSessionInfo alloc] init];
    sessionInfo.sessionType = COMPOpenAppType;
    sessionInfo.md5 = self.currentMD5;
    sessionInfo.appOpenType = COMPAppStartType;
    //INFO：App打开时，duration记录与App上次进入后台的duration，最长为一周
    if (self.appEnterBackgroundTimestamp <= 0) {
        sessionInfo.duration = SESSION_MAX_LIFE;
    } else {
        sessionInfo.duration = self.appStartTimestamp - self.appEnterBackgroundTimestamp;
        if (sessionInfo.duration > SESSION_MAX_LIFE) {
            sessionInfo.duration = SESSION_MAX_LIFE;
        }
    }
    [self uploadAppSessionInfo:sessionInfo];

    self.appEnterBackgroundTimestamp = 0;
}

- (void)handleApplicationSignificantTimeChangeNotification:(NSNotification *)notification {
    [self uploadAppDeviceInfo];
}

- (void)uploadAppSessionInfo:(COMPAppSessionInfo *)sessionInfo {
    COMPRecordItemElem *recordItemElem = [[COMPRecordItemElem alloc] init];
    recordItemElem.appSessionInfo = sessionInfo;
    recordItemElem.ts = [COMPHelper timestampInMiniseconds];
    NSData *jsonData = recordItemElem.data;

    [self addStatisticsDataToDB:jsonData uploadImmediately:YES];
}

#pragma mark - AppRequestInfo

- (void)urlSessionTaskDidStart:(NSURLSessionTask *)task {
    if ([task.originalRequest.URL.absoluteString containsString:NET_URL_PREFIX]) {
        return;
    }

    __block COMPAppRequestInfo *requestInfoA;
    dispatch_sync(self.requestInfoQueue, ^{
        requestInfoA = self.requestUrlDict[task];
    });

    if (!requestInfoA) {
        COMPAppRequestInfo *requestInfo = [[COMPAppRequestInfo alloc] init];
        dispatch_barrier_sync(self.requestInfoQueue, ^{
            self.requestUrlDict[task] = requestInfo;
        });

        NSURLRequest *request = task.currentRequest;
        requestInfo.schema = request.URL.scheme;
        requestInfo.domain = request.URL.host;
        requestInfo.url = request.URL.path;
        requestInfo.method = request.HTTPMethod;
        requestInfo.ts = [COMPHelper timestampInMiniseconds];
        requestInfo.count = 1;
        if (request.HTTPBody) {
            requestInfo.reqSize = request.HTTPBody.length;
        }
        requestInfo.clientIp = [COMPHelper getIPAddress:YES];
    }
}

- (void)urlSessionTask:(NSURLSessionTask *)task totalBytesExpectedToSend:(int64_t)totalBytesExpectedToSend {
    __block COMPAppRequestInfo *requestInfo;
    dispatch_sync(self.requestInfoQueue, ^{
        requestInfo = self.requestUrlDict[task];
    });

    if (requestInfo && requestInfo.reqSize == 0) {
        requestInfo.reqSize = totalBytesExpectedToSend;
    }
}

- (void)urlSessionTask:(NSURLSessionTask *)task didReceiveResponse:(NSURLResponse *)response ts:(int64_t)timestamp {
    __block COMPAppRequestInfo *requestInfo;
    dispatch_sync(self.requestInfoQueue, ^{
        requestInfo = self.requestUrlDict[task];
    });

    if (requestInfo && requestInfo.ttfb == 0) {
        requestInfo.ttfb = timestamp - requestInfo.ts;
    }
}

#if (defined(__IPHONE_10_0) && __IPHONE_OS_VERSION_MAX_ALLOWED >= __IPHONE_10_0)

- (void)urlSessionTask:(NSURLSessionTask *)task didFinishCollectingMetrics:(NSURLSessionTaskMetrics *)metrics {
    __block COMPAppRequestInfo *requestInfo;
    dispatch_sync(self.requestInfoQueue, ^{
        requestInfo = self.requestUrlDict[task];
    });

    if (requestInfo && metrics.transactionMetrics.count > 0) {
        NSURLSessionTaskTransactionMetrics *metric = metrics.transactionMetrics[0];
        if (metric.fetchStartDate) {
            requestInfo.ts = [metric.fetchStartDate timeIntervalSince1970] * 1000;
        }
        if (metric.responseStartDate) {
            requestInfo.ttfb = [metric.responseStartDate timeIntervalSince1970] * 1000 - requestInfo.ts;
        }
        if (metric.responseEndDate) {
            requestInfo.time = [metric.responseEndDate timeIntervalSince1970] * 1000 - requestInfo.ts;
        }
    }
}

#endif

- (void)urlSessionTaskDidStop:(NSURLSessionTask *)task error:(NSError *)error {
    __block COMPAppRequestInfo *requestInfo;
    dispatch_sync(self.requestInfoQueue, ^{
        requestInfo = self.requestUrlDict[task];
    });

    if (requestInfo) {
        requestInfo.time = [COMPHelper timestampInMiniseconds] - requestInfo.ts;
        if (error) {
            requestInfo.code = [COMPRequestError socketErrorCodeFromURLSessionErrorCode:error.code];
        } else if (task.response && [task.response isKindOfClass:[NSHTTPURLResponse class]]) {
            requestInfo.code = (int32_t)[(NSHTTPURLResponse *)(task.response) statusCode];
        } else {
            requestInfo.code = 0;
        }
        requestInfo.resSize = task.response.expectedContentLength;
        requestInfo.md5 = self.currentMD5;

        dispatch_barrier_sync(self.requestInfoQueue, ^{
            self.requestUrlDict[task] = nil;
        });
        [self uploadAppRequestInfo:requestInfo];
    }
}

- (void)uploadAppRequestInfo:(COMPAppRequestInfo *)requestInfo {
    COMPRecordItemElem *recordItemElem = [[COMPRecordItemElem alloc] init];
    recordItemElem.appRequestInfo = requestInfo;
    recordItemElem.ts = [COMPHelper timestampInMiniseconds];
    NSData *jsonData = recordItemElem.data;

    [self addStatisticsDataToDB:jsonData];
}

#pragma mark - Database

- (void)addStatisticsDataToDB:(NSData *)data {
    [self addStatisticsDataToDB:data uploadImmediately:NO];
}

- (void)addStatisticsDataToDB:(NSData *)data uploadImmediately:(BOOL)uploadImmediately {
    __weak typeof(self) weakSelf = self;
    dispatch_async(self.dbqueue, ^{
        BOOL result = [weakSelf.databaseAccess addStatisticsWithData:data uploadImmediately:uploadImmediately];
        if (result) {
            weakSelf.count += 1;
            if (weakSelf.isReachable && (uploadImmediately || [weakSelf.databaseAccess needUpdateImmediately] || weakSelf.count >= UPLOAD_COUNT) && !weakSelf.task && weakSelf.retryCount < UPLOAD_RETRY_COUNT) {
                [weakSelf uploadStatisticsToServer];
            }
        }
    });
}

#pragma mark - Upload

- (NSInteger)appIdForBundleId:(NSString *)bundleId {
    if ([bundleId hasPrefix:BUNDLE_ID_YOUXI_SHORT_VIDEO]) {
        return COMPYouXiShortVideo;
    } else if ([bundleId hasPrefix:BUNDLE_ID_YOUJU_VIDEO]) {
        return COMPYouJuVideo;
    } else if ([bundleId hasPrefix:BUNDLE_ID_ZIXUN_CLIENT]) {
        return COMPZixunClient;
    } else if ([bundleId hasPrefix:BUNDLE_ID_NEWS_CLIENT]) {
        return COMPNewsClient;
    }
    return COMPUndefinedAppNameType;
}

- (NSString *)postUrl {
    if (!_postUrl) {
        NSString *comp = self.cid.length > 0 ? self.cid : self.deviceId;
        NSInteger appId = [self appIdForBundleId:self.appName];
        _postUrl = [NSString stringWithFormat:@"%@%@?devId=%@", NET_URL_PREFIX, @(appId), comp];
    }

    return _postUrl;
}

- (void)uploadStatisticsToServer {
    NSArray<NSDictionary *> *statisticsList = [self.databaseAccess statisticsDataWithCount:UPLOAD_COUNT];
    NSInteger count = statisticsList.count;
    if (count < 1 || !self.isReachable) {
        return;
    }

    COMPRecordItemListReq *list = [[COMPRecordItemListReq alloc] init];
    NSMutableArray<COMPRecordItemElem *> *successRequestInfos = [NSMutableArray array];
    NSMutableArray<COMPRecordItemElem *> *recordItems = [NSMutableArray arrayWithCapacity:count];
    for (NSInteger index = 0; index < count; index++) {
        NSDictionary *dict = statisticsList[index];
        NSError *error = nil;
        COMPRecordItemElem *recordItemElem = [COMPRecordItemElem parseFromData:dict[TABLE_COLUMN_CONTENT] error:&error];
        if (!error && recordItemElem) {
            COMPAppRequestInfo *requestInfo = recordItemElem.appRequestInfo;
            //如果网络请求成功，且耗时小于设定值则采用聚合上传
            if (requestInfo && (requestInfo.code >= 100 && requestInfo.code < 400) && requestInfo.time <= REQUEST_TIME_INTERVAL) {
                BOOL find = NO;
                for (COMPRecordItemElem *item in successRequestInfos) {
                    if ([item.appRequestInfo.schema isEqualToString:requestInfo.schema] &&
                        [item.appRequestInfo.domain isEqualToString:requestInfo.domain] &&
                        item.appRequestInfo.code == requestInfo.code &&
                        [item.appRequestInfo.method isEqualToString:requestInfo.method]) {
                        find = YES;
                        item.appRequestInfo.count ++;
                        item.appRequestInfo.url = requestInfo.url;
                        item.appRequestInfo.ts = requestInfo.ts;
                        item.appRequestInfo.ttfb += requestInfo.ttfb;
                        item.appRequestInfo.time += requestInfo.time;
                        item.appRequestInfo.reqSize += requestInfo.reqSize;
                        item.appRequestInfo.resSize += requestInfo.resSize;
                        item.appRequestInfo.clientIp = requestInfo.clientIp;
                        item.appRequestInfo.serverIp = requestInfo.serverIp;
                        item.appRequestInfo.md5 = requestInfo.md5;
                        item.ts = recordItemElem.ts;
                        break;
                    }
                }
                if (!find) {
                    [successRequestInfos addObject:recordItemElem];
                }
            } else {
                [recordItems addObject:recordItemElem];
            }
        }
    }
    [recordItems addObjectsFromArray:successRequestInfos];

    list.recordItemElem = recordItems;
    count = recordItems.count;

    NSDictionary *lastData = [statisticsList lastObject];
    __weak typeof(self) weakSelf = self;
    NSURLSessionDataTask *task = [COMPApi post:self.postUrl jsonData:list.data completionHandler:^(NSError *error) {
        dispatch_async(weakSelf.dbqueue, ^{
            weakSelf.task = nil;
            if (!error || (error.code != COMPApiErrorCodeLocal)) {
                if (error) {
                    NSLog(@"Compass埋点数据客户端错误，error = %@", error);
                } else {
                    NSLog(@"Compass埋点数据上传服务器成功，共%@条", @(count));
                }
                
                [weakSelf.databaseAccess deleteStatisticsNoNewerThanData:lastData];
                weakSelf.count = [weakSelf.databaseAccess count];
                weakSelf.retryCount = 0;
                if (weakSelf.isReachable && (weakSelf.count >= UPLOAD_COUNT || [weakSelf.databaseAccess needUpdateImmediately])) {
                    [weakSelf uploadStatisticsToServer];
                }
            } else {
                weakSelf.retryCount++;
                if (weakSelf.retryCount < UPLOAD_RETRY_COUNT) {
                    NSLog(@"Compass埋点上传失败重试 %@", @(weakSelf.retryCount));
                    [weakSelf uploadStatisticsToServer];
                } else {
                    NSLog(@"Compass埋点上传重试%@次失败，等待%@秒", @UPLOAD_RETRY_COUNT, @UPLOAD_RETRY_INTERVAL);
                    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(UPLOAD_RETRY_INTERVAL * NSEC_PER_SEC)), weakSelf.dbqueue, ^{
                        if (weakSelf.isReachable && !weakSelf.task && weakSelf.retryCount >= UPLOAD_RETRY_COUNT) {
                            weakSelf.retryCount = 0;
                            [weakSelf uploadStatisticsToServer];
                        }
                    });
                }
            }
        });
    }];

    self.task = task;
}

@end

