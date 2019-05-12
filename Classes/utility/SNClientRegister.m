//
//  SNClientRegister.m
//  sohunews
//
//  Created by Dan Cong on 4/4/14.
//  Copyright (c) 2014 Sohu.com. All rights reserved.
//

#import "SNClientRegister.h"
#import "SNDBManager.h"
#import "SNCheckManager.h"
#import "SNUserLocationManager.h"
#import "SNWeatherCenter.h"
#import "SNInterceptConfigManager.h"
#import "SNSubscribeCenterService.h"
#import "SNMessageMgrConsts.h"
#import "SNCloudSaveService.h"
#import "SNUserManager.h"
#import "SNUserRegistRequest.h"
#import "SNMySDK.h"
#import "UICKeyChainStore.h"
#import "SNSpecialActivity.h"

#define kSN_CLIENT_INFO_KEYCHAIN_SERVIVCE   (@"kSN_CLIENT_INFO_KEYCHAIN_SERVIVCE")
#define kSN_CLIENT_INFO_KEYCHAIN_KEY        (@"kSN_CLIENT_INFO_KEYCHAIN_KEY")

@implementation SNClientRegister

@synthesize s_cookie = _s_cookie;

+ (SNClientRegister *)sharedInstance {
    static SNClientRegister *_sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedInstance = [[SNClientRegister alloc] init];
    });
    
    return _sharedInstance;
}

- (void)ensureRegister {
    if (!self.isRegisted) {
        SNDebugLog(@"no P1, try to regist");
        [self updateClientInfoToServer];
    }
}

- (BOOL)isRegisted {
    return self.uid
    && ![kDefaultProfileClientID isEqualToString:self.uid]
    && [[NSUserDefaults standardUserDefaults] objectForKey:kProfileClientIDKey]
    && [[NSUserDefaults standardUserDefaults] objectForKey:kRegistedNewUserKey];  //4.0版本本地新闻需要用户重新注册
}

- (BOOL)isDeviceModelAdapted {
    return self.sid
    && ![kDefaultDeviceAdaptID isEqualToString:self.sid]
    && [[NSUserDefaults standardUserDefaults] objectForKey:kDeviceAdaptIDKey];
}

- (void)updateClientInfoToServer {
    
    [self setupCookie];
    
    //如果本地已经有uid了，或者适配id，那么就不用请求regist.go接口了
    if (self.isRegisted && self.isDeviceModelAdapted) {
        if ([[SNDBManager currentDataBase] getSubArrayCount] == 0) {
            //注册成功后要发送mySubscribe.go请求，主要是给推送设置提供展示数据
            [[SNSubscribeCenterService defaultService] loadMySubFromServer];
        }
        if (!_deviceTokenChanged) {
            return;
        }
    }
    
//    if (![self keychainClientInfo]) {
//        ///如果启动的时候userdefault里没有cid，钥匙串里也没有cid存储，那么会在splash页里去请求regist.go
//        ///主要是为了避免regist.go的重复请求
//        return;
//    }
    
    self.uid = nil;
    self.sid = nil;
    
    [[[SNUserRegistRequest alloc] init] send:^(SNBaseRequest *request, id responseObject) {
        if (![responseObject isKindOfClass:[NSDictionary class]]) {
            return ;
        }
        [self saveClientInfoToKeychain:responseObject];
        [self updateLocalClientInfo:responseObject isLaunching:YES];
    } failure:^(SNBaseRequest *request, NSError *error) {
        // 如果注册失败了， 清理掉token, 下次好继续上报
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:kDevicetokenKey];
        [[NSUserDefaults standardUserDefaults] synchronize];
        
        NSString *errorCode = [NSString stringWithFormat:@"%d", error.code];
        [SNUtility resultErrorReportWithType:kRegistErrorType dict:@{@"regist":errorCode}];
    }];
}

- (void)updateLocalClientInfo:(NSDictionary *)clientInfo isLaunching:(BOOL)isAppLaunching {
    
    NSString *uidStr = [clientInfo objectForKey:KEY_UID];
    NSString *sidStr = [clientInfo objectForKey:KEY_SID];
    SNDebugLog(@"sohunewsAppDelegate - returnString uid = %@, sid= %@", uidStr, sidStr);
    
    if (uidStr) {
        NSUserDefaults *_userDefaults = [NSUserDefaults standardUserDefaults];
        NSString *cid = [_userDefaults objectForKey:kProfileClientIDKey];
        
        if (_uid.length == 0 || [kDefaultProfileClientID isEqualToString:_uid] ||
            cid.length == 0 || [kDefaultProfileClientID isEqualToString:cid]) {
            self.uid = uidStr;
            [SNCheckManager startCheckService:DefaultRefreshInterval];
            [_userDefaults setObject:uidStr forKey:kProfileClientIDKey];
            [_userDefaults setObject:[NSNumber numberWithBool:YES] forKey:kRegistedNewUserKey];
            [_userDefaults synchronize];
            
            [SNNotificationManager postNotificationName:kRegistGoSuccess object:nil];
            
            [self requestConfigOnce:isAppLaunching];
        }
    }
    else {
        [SNUtility resultErrorReportWithType:kRegistErrorType dict:@{@"regist":@"cid_empty"}];
    }
    
    //SID 服务器用来适配图片
    //9:iphone3 10:iphone4及以上(retina) 21:ipad
    if (sidStr) {
        NSUserDefaults *_userDefaults = [NSUserDefaults standardUserDefaults];
        NSString *devAdaptId = [_userDefaults objectForKey:kDeviceAdaptIDKey];
        
        if (_sid.length == 0 || [kDefaultDeviceAdaptID isEqualToString:_sid] ||
            devAdaptId.length == 0 || [kDefaultDeviceAdaptID isEqualToString:devAdaptId]) {
            self.sid = sidStr;
            [_userDefaults setObject:sidStr forKey:kDeviceAdaptIDKey];
            [_userDefaults synchronize];
        }
    }
    [self setupCookie];
    //注册成功后要发送mySubscribe.go请求，主要是给推送设置提供展示数据
    [[SNSubscribeCenterService defaultService] loadMySubFromServer];
    
    // 4.0 用户行为拦截 注册成功后及时刷新最新的拦截配置 by jojo
    if (self.isRegisted && self.isDeviceModelAdapted) {
        [SNInterceptConfigManager refreshConfig];
    }
}

- (void)registerClientAnyway {
    [self registerClientAnywaySuccess:^(SNBaseRequest *request) {} fail:^(SNBaseRequest *request, NSError *error) {}];
}

- (void)registerClientAnywaySuccess:(SNRegisterClientAnywaySuccessCallback)success fail:(SNRegisterClientAnywayFailCallback)fail {
    [self setupCookie];
    
    [[[SNUserRegistRequest alloc] init] send:^(SNBaseRequest *request, id responseObject) {
        [self didSuccessRegisterClientAnyway:responseObject];
        [SNUtility sendSettingModeType:SNUserSettingGetMode mode:nil];
        success(request);
    } failure:^(SNBaseRequest *request, NSError *error) {
        [self didFailRegisterClientAnyway:request error:error];
        fail(request,error);
    }];
}

- (void)didSuccessRegisterClientAnyway:(id )dataDic {
    if (![dataDic isKindOfClass:[NSDictionary class]]) {
        return;
    }
    [self saveClientInfoToKeychain:dataDic];
    [self updateLocalClientInfo:dataDic isLaunching:NO];
}

- (void)didFailRegisterClientAnyway:(SNBaseRequest *)request error:(NSError *)error {
    SNDebugLog(@"Failed to re-register client device with following msg: %d,%@", error.code, error.localizedDescription);
    
    // 如果注册失败了， 清理掉token, 下次好继续上报
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:kDevicetokenKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (void)setupCookie {
	// get client id
	self.uid = [[NSUserDefaults standardUserDefaults] objectForKey:kProfileClientIDKey];
	if ([self.uid length] == 0) {
		self.uid = kDefaultProfileClientID;
	}
    
    // get device adapt id
	self.sid = [[NSUserDefaults standardUserDefaults] objectForKey:kDeviceAdaptIDKey];
	if ([_sid length] == 0) {
		self.sid = kDefaultDeviceAdaptID;
	}
    
	//get udid
#if TARGET_IPHONE_SIMULATOR
	NSString *UDID = @"64E5B68E-8EA1-4CB8-8544-C04FEA1AED3E";
    NSString *IDFA = @"20834213-0F5F-4631-83F2-3A4E2C47F688";
#else
    NSString *UDID = [SNUtility getDeviceUDID];
    NSString *IDFA = [UIDevice deviceIDFA];

    //NSString * regKeyChain = [UIDevice deviceUDID];
    //NSString *idfv = [[[UIDevice currentDevice] identifierForVendor] UUIDString];
    //if(nil != self.uid){
    //    SNDebugLog(@"-------------uid %@", self.uid);
    //    SNDebugLog(@"-------------p1 %@", [SNUserManager getP1]);
    //}
    //SNDebugLog(@"-------------regKeyChain %@", regKeyChain);
    //SNDebugLog(@"-------------Keychain %@", UDID);
    //SNDebugLog(@"-------------IDFA %@", IDFA);
    //SNDebugLog(@"-------------idfv %@", idfv);
#endif
	
	//get version
	NSString *version = [[[NSBundle mainBundle] infoDictionary] objectForKey: kBundleVersionKey];
	
	//get system name and version
	NSString *systemName = [[UIDevice currentDevice] systemName];
	NSString *systemVersion = [[UIDevice currentDevice] systemVersion];
	
#if TARGET_IPHONE_SIMULATOR
	NSString *deviceInfo = kDeviceModel;
#else
	NSString *deviceInfo = [[UIDevice currentDevice] model];
#endif
	
	NSString *carrierName = [[SNUtility sharedUtility] getCarrierName];
    if (carrierName) {
        if (NSNotFound != [carrierName rangeOfString:@"移动" options:NSCaseInsensitiveSearch].location) {
            carrierName = @"CMCC";
        }
        else if (NSNotFound != [carrierName rangeOfString:@"联通" options:NSCaseInsensitiveSearch].location) {
            carrierName = @"UNIC";
        }
        else if (NSNotFound != [carrierName rangeOfString:@"电信" options:NSCaseInsensitiveSearch].location) {
            carrierName = @"CT";
        }
    }
    
    //wifi or 3G or gprs
    NSString *reachStatus = [[SNUtility getApplicationDelegate] currentNetworkStatusString];
    
    int marketId = [SNUtility marketID];
    
	//create cookie
    NSString *screenSize = [[UIDevice currentDevice] screenSizeStringForSohuNews];
    NSString *unencrypedCookie = [NSString stringWithFormat:kHeaderFormatString, APIVersion,
                                  _uid, UDID, IDFA, version, systemName, systemVersion, screenSize, deviceInfo, marketId, [[SNAPI productId] intValue], [[UIDevice currentDevice] platformForSohuNews]];
    if (carrierName) {
        unencrypedCookie = [unencrypedCookie stringByAppendingFormat:@"&k=%@", carrierName];
    }
    
	if (self.deviceToken) {
        unencrypedCookie = [unencrypedCookie stringByAppendingFormat:@"&p=%@", self.deviceToken];
	}
	
    if (reachStatus) {
        unencrypedCookie = [unencrypedCookie stringByAppendingFormat:@"&q=%@", reachStatus];
    }
    
    if (reachStatus) {
        unencrypedCookie = [unencrypedCookie stringByAppendingFormat:@"&ma=%@", [[UIDevice currentDevice] macAddress]];
        SNDebugLog(@"MAC address: %@", [[UIDevice currentDevice] macAddress]);
    }
    
    //5.1 add build
    NSString *appBuild = [[[NSBundle mainBundle] infoDictionary] objectForKey:kBundleBuild];
    if (appBuild) {
        unencrypedCookie = [unencrypedCookie stringByAppendingFormat:@"&buildCode=%@", appBuild];
    }
    
	SNDebugLog(@"unencrypedCookie: %@", unencrypedCookie);
	self.s_cookie = [AesEncryptDecrypt encrypt:unencrypedCookie withKey:kAESEncryptKey];
	
	[[NSUserDefaults standardUserDefaults] setObject:self.s_cookie forKey:kProfileCookieKey];
	[[NSUserDefaults standardUserDefaults] synchronize];
}

- (void)reset {
    /**
     *  无用的NSUserDefaults key，如下：
     *  kProfileGuideOnFirstRun, kProfileDevicetokenKey, kAdRefreshTime, kIS_NEW_REGISTERED_DEVICE
     */
    
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults removeObjectForKey:kProfileClientIDKey];//cid
    [userDefaults removeObjectForKey:kProfileCookieKey];//s_cookie
    [userDefaults removeObjectForKey:kDeviceAdaptIDKey];//即sid, 服务器用来适配图片 9:iphone3 10:iphone4及以上(retina) 21:ipad
    [userDefaults removeObjectForKey:kRegistedNewUserKey];//4.0版本本地新闻用户重新注册是否成功
    [userDefaults removeObjectForKey:kUserExpire];//使用户过期
    [userDefaults removeObjectForKey:kMessageMgrLastMsgIdReceivedKey];//SNMessageMgr接收的最后一条消息的id
    [userDefaults removeObjectForKey:kLocationRequestDate];//SNUserLocationManager通过服务器定位成功的时间点
    [userDefaults removeObjectForKey:kLocationDate];//SNUserLocationManager 记录的SDK定位时间点
    [userDefaults removeObjectForKey:kClientInfoSynchronized];//版本升级信息
    [userDefaults removeObjectForKey:kCheckDoResponse];//check.do的数据
    [userDefaults removeObjectForKey:kChannelManagerSwitchType];//新闻Tab频道管理里有频道类型选择（此功能已去掉）
    [userDefaults removeObjectForKey:kAppNotLaunchedForSomeTimeNotifyEnabled];//本地应用长期未启动提醒
    [userDefaults removeObjectForKey:kChannelModelRefreshTime];//记录频道更新时间
    [userDefaults synchronize];
}

- (void)setS_cookie:(NSString *)s_cookie
{
    _s_cookie = [s_cookie copy];
}

- (NSString *)s_cookie
{
    return _s_cookie;
}


#pragma mark - 
#pragma mark - save uid sid to keychain
- (BOOL)isRegistedInKeychain {
    return nil != [self keychainClientInfo];
}

- (BOOL)saveClientInfoToKeychain:(NSDictionary *)info {
    if (![info isKindOfClass:[NSDictionary class]]) {
        return NO;
    }
    NSError * jsonError = nil;
    NSData * infoData = [NSJSONSerialization dataWithJSONObject:info options:NSJSONWritingPrettyPrinted error:&jsonError];
    if (jsonError) {
        SNDebugLog(@"Failed: saveClientInfoToKeychain: with error: %@",jsonError.localizedDescription);
        return NO;
    }
    UICKeyChainStore * keychain = [UICKeyChainStore keyChainStoreWithService:kSN_CLIENT_INFO_KEYCHAIN_SERVIVCE];
    NSError * keychainError = nil;
    if (![keychain setData:infoData forKey:kSN_CLIENT_INFO_KEYCHAIN_KEY error:&keychainError]) {
        SNDebugLog(@"Failed: saveClientInfoToKeychain: with error: %@",keychainError.localizedDescription);
        return NO;
    }
    return YES;
}

- (NSDictionary *)keychainClientInfo {
    NSDictionary * clientInfo = nil;
    UICKeyChainStore * keychain = [UICKeyChainStore keyChainStoreWithService:kSN_CLIENT_INFO_KEYCHAIN_SERVIVCE];
    NSError * keychainError = nil;
    NSData * infoData = [keychain dataForKey:kSN_CLIENT_INFO_KEYCHAIN_KEY error:&keychainError];
    if (keychainError || !infoData) {
        SNDebugLog(@"Failed: getKeychainClientInfo with error: %@",keychainError.localizedDescription);
    }else{
        NSError * jsonError = nil;
        clientInfo = [NSJSONSerialization JSONObjectWithData:infoData options:NSJSONReadingMutableLeaves error:&jsonError];
        if (jsonError) {
            SNDebugLog(@"Failed: getKeychainClientInfo with error: %@",jsonError.localizedDescription);
        }
    }
    return clientInfo;
}

//避免多次请求
- (void)requestConfigOnce:(BOOL)appLaunch {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        if (appLaunch) {
            // 解决卸载重装后,不进收藏时,浏览到之前收藏新闻显示未收藏问题,只需要执行一次
            [SNCloudSaveService synCloudFavoriteData];
        }
        // 启动之后刷新下默认天气
        [[SNWeatherCenter defaultCenter] forceRefreshDefaultCityWeather:nil];
        
        //保证SNS第一次启动
        [[SNMySDK sharedInstance] setupSNS];
        
        //保证请求setting.go使用正确p1
        [[SNAppConfigManager sharedInstance] requestConfigAsync];
        
        //可定制化活动弹窗
        [[SNSpecialActivity shareInstance] requestActivityInfo];
    });
}

@end
