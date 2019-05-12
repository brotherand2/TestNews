//
//  SNUserLocationManager.m
//  sohunews
//
//  Created by lhp on 10/22/13.
//  Copyright (c) 2013 Sohu.com. All rights reserved.
//

#import "SNUserLocationManager.h"
#import "NSDictionaryExtend.h"
#import "SNClientRegister.h"
#import "SNLocationRequest.h"
#import "SNAppConfigManager.h"
#import "SNUserSettingRequest.h"
#import "SNLocalChannelRequest.h"
#import "sohunewsAppDelegate.h"
#import "SNRollingNewsModel.h"
#import "SNDBManager.h"
#import "SNRollingNewsPublicManager.h"

#define UserLocationStorageKey @"UserLocationInfoKey"

// 地理位置更新状态
#define LocatingStatusNever       0    // 没有执行过地理位置请求
#define LocatingStatusUpdating    1    // 正在获取地理位置
#define LocatingStatusEnd         2    // 地理位置获取完毕，但是还没上报
#define LocatingStatusRequested   3    // 地理位置上报完毕

@interface SNUserLocationManager ()

@property (nonatomic) BOOL hadNotifyLocalChange;
@property (nonatomic, strong) CLLocationManager *locationManager;
@property (nonatomic, strong) NSTimer *updateTimer;

@property (nonatomic, strong) SNChannel *localChannel; // 用户设置的本地频道，或者上一次定位到的本地频道
@property (nonatomic, strong) SNChannel *houseProChannel; //房产频道用户设置频道

/* 
 地理位置状态，取值范围是
 #define LocatingStatusNever       0    // 没有执行过地理位置请求
 #define LocatingStatusUpdating    1    // 正在获取地理位置
 #define LocatingStatusEnd         2    // 地理位置获取完毕，但是还没上报
 #define LocatingStatusRequested   3    // 地理位置上报完毕
*/

@property (nonatomic) Byte locatingStatus;
@property (nonatomic) int updateLocationTime;

// 是当前地理位置的坐标， 不是本地频道的坐标。
@property (nonatomic) CLLocationCoordinate2D locationCoordinate;

/* 
 YES: 用户主动设置了本地频道
 NO: 不是用户设置的本地频道，而是根据定位算出来的。
 默认是NO. 只有用户在选择频道的界面里设置了本地频道之后才会变成NO
 当是YES的时候，不会弹出切换本地频道的提示。因为用户自己修改了频道，不需要告诉他切换回来
 当是NO的时候，一旦进入到本地频道界面，就要弹出切换城市的提示。
 一旦设置位YES，就只有下次启动的时候才能变成NO了。
 */
@property (nonatomic) BOOL localChannelFromUser;

@property (nonatomic, weak) NSObject *userData;

@property (nonatomic) BOOL isLocalChannelChange;

@property (nonatomic, assign) BOOL needRefreshFromNetWork;
@property (nonatomic, strong) NSString *prevGbcode;

@end

#define kUpdateLocationTime      60*30
#define kRequestTime           4*60*60
#define kLocationRequest                    @"locationRequest"
#define kLocalChannelRequest                @"localChannelRequest"
#define kCurrentLocationChannelRequest      @"currentLocationRequest"

@implementation SNUserLocationManager
@synthesize _request;

+ (SNUserLocationManager *)sharedInstance {
    static SNUserLocationManager *instance = nil;
    static dispatch_once_t dispatch;
    
    dispatch_once(&dispatch, ^(){
        instance = [[SNUserLocationManager alloc] init];
    });
    
    return instance;
}

- (id)init {
    self = [super init];
    
    if (self) {
        _locatingStatus = LocatingStatusNever;
        _isLocalChannelChange = YES;
        _hasLocationAuthorization = YES;
        
        _distanceValue = 2;
        _updateLocationTime = kUpdateLocationTime;
        _loactionRequestTime = kRequestTime;
        
        [self readUserLocation];
    }
    
    return self;
}

- (CLLocationManager *)locationManager {
    if (!_locationManager) {
//        NSAssert([NSThread isMainThread], @"CLLocationManager init needs to be accessed on the main thread.");
        _locationManager = [[CLLocationManager alloc] init];
        _locationManager.distanceFilter = kCLDistanceFilterNone;
        _locationManager.desiredAccuracy = kCLLocationAccuracyBest;
        _locationManager.delegate = self;
    }
    return _locationManager;
}

- (void)notifyLocalChange {
    NSString *lastGbcode = [[NSUserDefaults standardUserDefaults] objectForKey:@"lastGbcode"] ? : @"";
    if (lastGbcode.length == 0) {
        //第一次的时候 存下当前位置为last位置
        [[NSUserDefaults standardUserDefaults]setObject:[self currentChannelGBCode] forKey:@"lastGbcode"];
        [[NSUserDefaults standardUserDefaults] synchronize];
        
        lastGbcode = [self currentChannelGBCode];
    }
    
    if ((![self.currentCityChannel.channelId isEqualToString:self.localChannelId])
        //用户没有点过@”不再提示“，并且用户所选城市和实际所在城市不一样
        || (![[self currentChannelGBCode] isEqualToString:lastGbcode]))
        //不论用户是否点过@”不在提示“，只要本次实际城市和上次实际城市不一样，就弹alert
    {
        _hadNotifyLocalChange = YES;
        
        [[NSUserDefaults standardUserDefaults]setObject:[self currentChannelGBCode] forKey:@"lastGbcode"];
        [[NSUserDefaults standardUserDefaults] synchronize];
        
        if ([[[NSUserDefaults standardUserDefaults] objectForKey:kIntelligetnLocationSwitchKey] boolValue]) {
            self.localChannel = self.currentCityChannel;
            
            [[SNDBManager currentDataBase] clearRollingNewsListByChannelId:kLocalChannelUnifyID];
            [self saveUserLocation];
            [self saveLocalChannel2Server:_currentCityChannel.gbcode channelId:nil];
            // 触发相应的cc统计 v5.2.0
            SNUserTrack *curPage = [SNUserTrack trackWithPage:1 link2:nil];
            SNUserTrack *toPage = [SNUserTrack trackWithPage:1 link2:nil];
            NSString *paramString = [NSString stringWithFormat:kAnalyticsUrlCC, [curPage toFormatString], [toPage toFormatString], f_change_city];
            paramString = [paramString stringByAppendingFormat:@"_%d&index=%d", 1, 1];
            [SNNewsReport reportADotGifWithTrack:paramString];
        }
    }
}

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex {
    if (1 == buttonIndex) //立即切换
    {
        self.localChannel = self.currentCityChannel;
        
        [self saveUserLocation];
        [self saveLocalChannel2Server:_currentCityChannel.gbcode channelId:nil];
    } else if (0 == buttonIndex) //不再提示
    {
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"kDontDisturbMe"];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
    
    // 触发相应的cc统计 v5.2.0
    SNUserTrack *curPage = [SNUserTrack trackWithPage:1 link2:nil];
    SNUserTrack *toPage = [SNUserTrack trackWithPage:1 link2:nil];
    NSString *paramString = [NSString stringWithFormat:kAnalyticsUrlCC, [curPage toFormatString], [toPage toFormatString], f_change_city];
    paramString = [paramString stringByAppendingFormat:@"_%d&index=%d", buttonIndex, buttonIndex];
    [SNNewsReport reportADotGifWithTrack:paramString];
}

- (NSString *)localChannelName {
    return nil == _localChannel ? @"" : _localChannel.channelName;
}

- (NSString *)localChannelId {
    return nil == _localChannel ? @"" : _localChannel.channelId;
}

- (NSString *)localChannelGBCode {
    return nil == _localChannel ? @"" : _localChannel.gbcode;
}

- (NSString *)currentChannelName {
    return nil == _currentCityChannel ? @"" : _currentCityChannel.channelName;
}

- (NSString *)currentChannelId {
    return nil == _currentCityChannel ? @"" : _currentCityChannel.channelId;
}

- (NSString *)currentChannelGBCode {
    return [SNUtility sharedUtility].currentChannelGbcode ? : @"";
}

- (NSString *)houseProChannelId {
    return nil == _houseProChannel ? @"" : _houseProChannel.channelId;
}

- (SNLocalChannelResult)localResult {
    switch (_locatingStatus) {
        case LocatingStatusNever:
            return SNLocalChannelResultNone;
        case LocatingStatusUpdating:
            return SNLocalChannelResultLocating;
        case LocatingStatusEnd:
        case LocatingStatusRequested: {
            if (nil == _currentCityChannel) {
                return SNLocalChannelResultCity;
            } else {
                return SNLocalChannelResultLocalChannel;
            }
        }
        default:
            return SNLocalChannelResultNone;
    }
}

- (NSString *)getResultString {
    switch (self.localResult)
    {
        case SNLocalChannelResultLocating:
            return @"正在定位...";
            break;
        case SNLocalChannelResultCity:
            return self.resultString;
            break;
        case SNLocalChannelResultNone:
            return self.resultString;
            break;
        default:
            return nil;
    }
}

- (void)resetLocatingChannel {
    _locatingStatus = LocatingStatusNever;
}

- (void)locationFailRefreshLocalChannelList {
    self.resultString = kCurrentLocationFail;
    
    //刷新本地城市列表
    [SNNotificationManager postNotificationName:kRefeshLocalChannelListNotification object:nil];
}

- (void)updateLocationTime:(int)times {
    if (times == 0) {
        return;
    }
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wundeclared-selector"
    if (_updateLocationTime != times * 60) {
        _updateLocationTime = times * 60;
        [self.updateTimer invalidate];
        self.updateTimer = [NSTimer scheduledTimerWithTimeInterval:_updateLocationTime
                                                            target:self
                                                          selector:@selector(updateLocation)
                                                          userInfo:nil
                                                           repeats:YES];
#pragma clang diagnostic pop
    }
}

- (void)updateLocalChannelWithId:(NSString *)idString
                        cityName:(NSString *)name
                          gbcode:(NSString *)gbcode
                       channelId:(NSString *)channelId {
    if (![[SNUtility getApplicationDelegate] isNetworkReachable]) {
        [[SNCenterToast shareInstance] showCenterToastWithTitle:NSLocalizedString(@"network error", @"") toUrl:nil mode:SNCenterToastModeError];
        [SNRollingNewsPublicManager sharedInstance].isChangingLocalChannel = NO;
        return;
    }
    
    if (idString.length == 0 || name.length == 0 || gbcode.length == 0
        || ([idString isEqualToString:[self localChannelId]] && ![idString isEqualToString:kLocalChannelUnifyID])) {
        [SNRollingNewsPublicManager sharedInstance].isChangingLocalChannel = NO;
        return;
    }
    
    _userData = nil;
  
    SNChannel *channel = [[SNChannel alloc] init];
    
    channel.channelName = name;
    channel.channelId = idString;
    channel.gbcode = gbcode;
    
    [self saveLocalChannelServer:gbcode channelId:channelId selectedChannel:channel];
}

- (void)updateHouseProLocalChannelWithId:(NSString *)idString
                                cityName:(NSString *)name
                                  gbcode:(NSString *)gbcode
                               channelId:(NSString *)channelId {
    if (![[SNUtility getApplicationDelegate] isNetworkReachable]) {
        [[SNCenterToast shareInstance] showCenterToastWithTitle:NSLocalizedString(@"network error", @"") toUrl:nil mode:SNCenterToastModeError];
        [SNRollingNewsPublicManager sharedInstance].isChangingLocalChannel = NO;
        return;
    }
    
    if (idString.length == 0 || name.length == 0 || gbcode.length == 0
        || [idString isEqualToString:[self houseProChannelId]]) {
        [SNRollingNewsPublicManager sharedInstance].isChangingLocalChannel = NO;
        return;
    }
    
    _userData = nil;
    
    SNChannel *channel = [[SNChannel alloc] init];
    
    channel.channelName = name;
    channel.channelId = idString;
    channel.gbcode = gbcode;
    
    [self saveLocalChannelServer:gbcode channelId:channelId selectedChannel:channel];
}

- (NSString *)getLocationString {
    NSString *locationString = nil;
    
    if (_locationCoordinate.longitude != 0 ||
        _locationCoordinate.latitude != 0) {
        locationString = [NSString stringWithFormat:@"cdma_lng=%lf&cdma_lat=%lf",_locationCoordinate.longitude, _locationCoordinate.latitude];
    }
    return locationString;
}

- (NSString *)getNewsLocationString {
    NSString *locationString = nil;
    if (_locationCoordinate.longitude != 0 || _locationCoordinate.latitude != 0) {
        locationString = [NSString stringWithFormat:@"cdma_lng=%lf&cdma_lat=%lf",_locationCoordinate.longitude, _locationCoordinate.latitude];
    }
    return locationString;
}

- (NSDictionary *)getNewsLocationParams {
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithCapacity:2];
    if (_locationCoordinate.longitude != 0 || _locationCoordinate.latitude != 0) {
        [params setValue:[NSString stringWithFormat:@"%lf",_locationCoordinate.longitude] forKey:@"cdma_lng"];
        [params setValue:[NSString stringWithFormat:@"%lf",_locationCoordinate.latitude] forKey:@"cdma_lat"];
    }
    return params.copy;
}

- (NSString *)getLongitude {
    return [[self getLongitudeAndLatitude] objectAtIndex:0];
}

- (NSString *)getLatitude {
    return [[self getLongitudeAndLatitude] objectAtIndex:1];
}

- (void)updateLocationUserData:(NSObject *)userData {
    switch (_locatingStatus)
    {
        case LocatingStatusNever:
        case LocatingStatusEnd:
        case LocatingStatusRequested:
            break;
        case LocatingStatusUpdating:
        default:  // 不认识的状态，不处理
            return;
    }
    
    //用户禁止定位服务
    CLAuthorizationStatus locationStatus = [CLLocationManager authorizationStatus];
    BOOL locationServiceEnabled = [CLLocationManager locationServicesEnabled];
    
    if (!locationServiceEnabled ||
        locationStatus == kCLAuthorizationStatusDenied) {
        _hasLocationAuthorization = NO;
        _locatingStatus = LocatingStatusEnd;
        [self locationFailRefreshLocalChannelList];
        return;
    }
    
    _userData = userData;
    [self.locationManager stopUpdatingLocation];
    
    BOOL isIOS8 = [[[UIDevice currentDevice] systemVersion] floatValue] >= 8.0;
    
    if (isIOS8) {
        [self.locationManager requestWhenInUseAuthorization];
    }
    
    _locatingStatus = LocatingStatusUpdating;
    
    [self.locationManager startUpdatingLocation];
    
    NSTimeInterval locationDate = [[NSDate date] timeIntervalSince1970];
    NSString *locationDateString = [NSString stringWithFormat:@"%lf",locationDate];
    
    [[NSUserDefaults standardUserDefaults] setObject:locationDateString forKey:kLocationDate];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (void)updateLocation {
    [self updateLocationUserData:nil];
}

- (void)updateLocationWithDate {
    NSString *lastDateString = [[NSUserDefaults standardUserDefaults] objectForKey:kLocationDate];
    
    if (!lastDateString) {
        return;
    }
    
    NSTimeInterval nowDate = [[NSDate date] timeIntervalSince1970];
    NSTimeInterval lastDate = [lastDateString floatValue];
    
    if (nowDate - lastDate > _updateLocationTime) {
        [self updateLocation];
    }
}

- (void)locationUpdated:(CLLocation *)newLocation {
    // 已经定位完了，或者已经上报过了，如果没有经过重新定位的过程，不再上报
    if (LocatingStatusEnd == _locatingStatus || LocatingStatusRequested == _locatingStatus) {
        return;
    }
    
    _locatingStatus = LocatingStatusEnd;

    [self.locationManager stopUpdatingLocation];
    
    if (newLocation.horizontalAccuracy >= 0) {
        CLLocationCoordinate2D newLocationCoordinate = [newLocation coordinate];
        
        //lijian 161125 获取地理信息的方法，暂时不用，不要删
//        CLGeocoder *geocoder = [[CLGeocoder alloc] init];
//        //创建位置
//        CLLocation *location = [[CLLocation alloc] initWithLatitude:newLocationCoordinate.latitude longitude:newLocationCoordinate.longitude];
//        
//        [geocoder reverseGeocodeLocation:location completionHandler:^(NSArray<CLPlacemark *> * _Nullable placemarks, NSError * _Nullable error) {
//            
//            //判断是否有错误或者placemarks是否为空
//            if (error !=nil || placemarks.count==0) {
//                SNDebugLog(@"%@",error);
//                return ;
//            }
//            for (CLPlacemark *placemark in placemarks) {
//                //赋值详细地址
//                NSString *identifier = [NSLocale localeIdentifierFromComponents: [NSDictionary dictionaryWithObject: placemark.ISOcountryCode forKey: NSLocaleCountryCode]];
//                NSString *country = [[NSLocale currentLocale] displayNameForKey: NSLocaleIdentifier value: identifier];
//            }
//            
//        }];
        
        // 获取地理位置失败，加载过去保存的地理位置
        if (_locationCoordinate.latitude != newLocationCoordinate.latitude
            || _locationCoordinate.longitude != newLocationCoordinate.longitude)
        {
            // 这段代码本来是在注释里的，现在拿下来了
            self.locationCoordinate = newLocationCoordinate;
            
            //获取本地新闻频道
            [self requestLocalChannel];
            //上报地理位置 wangyy
            [self locationRequest];
        } else {
            if (_isRefreshLocation) {
                if (self.refreshBlock) {
                    self.refreshBlock();
                }
            }
            if (_isRefreshChannelLocation) {
                if (self.refreshChannelBlock) {
                    self.refreshChannelBlock();
                }
            }
        }
    } else {
        [self locationFailRefreshLocalChannelList];
    }
}

#pragma mark -
#pragma mark CLLocationManagerDelegate
- (void)locationManager:(CLLocationManager *)manager
	didUpdateToLocation:(CLLocation *)newLocation
		   fromLocation:(CLLocation *)oldLocation {
    [manager stopUpdatingLocation];
    
    if (_locatingStatus == LocatingStatusEnd || _locatingStatus == LocatingStatusRequested) {
        return;
    }
    [self locationUpdated:newLocation];
}

- (void)locationManager:(CLLocationManager *)manager
     didUpdateLocations:(NSArray *)locations {
    [manager stopUpdatingLocation];
    
    if (_locatingStatus == LocatingStatusEnd || _locatingStatus == LocatingStatusRequested) {
        return;
    }
    
    [self locationUpdated:[locations objectAtIndex:0]];
    
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    if (![userDefaults objectForKey:kIntelligetnLocationSwitchKey]) {
        [userDefaults setObject:[NSNumber numberWithBool:YES] forKey:kIntelligetnLocationSwitchKey];
        [userDefaults synchronize];
    }
}

- (void)locationManager:(CLLocationManager *)manager
       didFailWithError:(NSError *)error {
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    if (![userDefaults objectForKey:kIntelligetnLocationSwitchKey]) {
        [userDefaults setObject:[NSNumber numberWithBool:NO] forKey:kIntelligetnLocationSwitchKey];
        [userDefaults synchronize];
    }
    [manager stopUpdatingLocation];
    
    if (_locatingStatus == LocatingStatusEnd || _locatingStatus == LocatingStatusRequested) {
        return;
    }
    
    _locatingStatus = LocatingStatusEnd;

    [self locationFailRefreshLocalChannelList];
}

- (void)requestLocalChannel {
   [[[SNLocalChannelRequest alloc] initWithLocationCoordinate:_locationCoordinate] send:^(SNBaseRequest *request, id responseObject) {
       if (responseObject) {
           NSDictionary *response = nil;
           if ([responseObject isKindOfClass:[NSDictionary class]]) {
               response = (NSDictionary *)responseObject;
           } else {
               response = [NSJSONSerialization JSONObjectWithData:responseObject options:0 error:nil];
           }
           
           _locatingStatus = LocatingStatusRequested;
           
           NSDictionary *channelDic = [response objectForKey:@"localChannel"];
           if (channelDic && channelDic.count > 0)
           {
               self.currentCityChannel = [self dicToChannel:channelDic];
               [SNUtility sharedUtility].currentChannelGbcode = self.currentCityChannel.gbcode;
               [[NSUserDefaults standardUserDefaults] setObject:channelDic[kGbcode] forKey:kAdGbcode];
               BOOL toChange = ![[NSUserDefaults standardUserDefaults] boolForKey:@"notifyLocalChange_first"];
               if ([[[NSUserDefaults standardUserDefaults] objectForKey:kIntelligetnLocationSwitchKey] boolValue] && toChange && self.isRefreshLocation == NO)
               {
                   [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"notifyLocalChange_first"];
                   [[NSUserDefaults standardUserDefaults] synchronize];
                   [self notifyLocalChange];
               }
               
               NSString *cityString = self.currentCityChannel.channelName;
               if (cityString) {
                   [[NSUserDefaults standardUserDefaults] setObject:cityString forKey:kLocationCityKey];
                   [[NSUserDefaults standardUserDefaults] synchronize];
               }
               if (_isRefreshLocation) {
                   if (self.refreshBlock) {
                       self.refreshBlock();
                   }
               }
               if (_isRefreshChannelLocation) {
                   if (self.refreshChannelBlock) {
                       self.refreshChannelBlock();
                   }
               }
               return;
           }
       }

   } failure:^(SNBaseRequest *request, NSError *error) {
       [self locationFailRefreshLocalChannelList];
   }];
}

- (double)distanceBetweenOrderBy:(double)lat1 :(double)lat2 :(double)lng1 :(double)lng2 {
    CLLocation *curLocation = [[CLLocation alloc] initWithLatitude:lat1 longitude:lng1];
    CLLocation *otherLocation = [[CLLocation alloc] initWithLatitude:lat2 longitude:lng2];
    double distance = [curLocation distanceFromLocation:otherLocation];
    return distance;
}

- (void)saveLocalChannelServer:(NSString *)gbcode
                     channelId:(NSString *)channelId
               selectedChannel:(SNChannel *)channel {
    //房产频道设置用户地理信息和本地区分
    BOOL isHousePro = [SNUserLocationManager isHouseProLocalTypeWithChannelId:channelId];

    [[[SNUserSettingRequest alloc] initWithUserSettingMode:isHousePro?SNUserSettingHousePropLocationMode:SNUserSettingLocationMode andModeString:gbcode] send:^(SNBaseRequest *request, id responseObject) {
        if (isHousePro) {
            self.houseProChannel = channel;
            
            [SNNotificationManager postNotificationName:kRollingHouseChannelUpdateLocalNotification object:self.userData];
        } else {
            self.isLocalChannelChange = YES;
            self.localChannel = channel;
            self.localChannelFromUser = YES;
            [self saveUserLocation];
            self.needRefreshFromNetWork = YES;
            [SNRollingNewsPublicManager sharedInstance].localADCount = 0;
            //如果更新当前频道, 需要清除当前的加载状态
            [SNRollingNewsPublicManager sharedInstance].isRequestChannelData = NO;
            [SNNotificationManager postNotificationName:kRollingChannelUpdateLocalNotification object:self.userData];
        }
        [SNRollingNewsPublicManager sharedInstance].isChangingLocalChannel = NO;
        _userData = nil;
    } failure:^(SNBaseRequest *request, NSError *error) {
        [self locationFailRefreshLocalChannelList];
        [SNRollingNewsPublicManager sharedInstance].isChangingLocalChannel = NO;
    }];
}

- (void)saveLocalChannel2Server:(NSString *)gbcode
                      channelId:(NSString *)channelId {

    if (nil == gbcode || gbcode.length == 0) return;

    //房产频道设置用户地理信息和本地区分
    BOOL isHousePro = [SNUserLocationManager isHouseProLocalTypeWithChannelId:channelId];

    [[[SNUserSettingRequest alloc] initWithUserSettingMode:isHousePro?SNUserSettingHousePropLocationMode:SNUserSettingLocationMode andModeString:gbcode] send:^(SNBaseRequest *request, id responseObject) {
        NSDictionary *response = responseObject;
        //本地和房产频道地理逻辑分开 wangyy
        if (isHousePro) {
            [SNNotificationManager postNotificationName:kRollingHouseChannelUpdateLocalNotification object:_userData];
        } else {
            _isLocalChannelChange = YES;
            _needRefreshFromNetWork = YES;
            //若频道list.go下发城市与定位一致，无需再次请求list.go
            SNChannel *channel = [SNUtility getChannelByChannelID:kLocalChannelUnifyID];
            if (![channel.channelName isEqualToString:self.localChannelName]) {
                [SNNotificationManager postNotificationName:kRollingChannelUpdateLocalNotification object:_userData];
            }
        }
        
        _userData = nil;
        
    } failure:^(SNBaseRequest *request, NSError *error) {
        [self locationFailRefreshLocalChannelList];
    }];

}

- (void)dealloc
{
    [_updateTimer invalidate];
    self.locationManager.delegate = nil;
    
    [self._request cancel];
    
    [SNNotificationManager removeObserver:self];
}

#pragma mark - Parse location string
- (NSArray *)getLongitudeAndLatitude {
    NSString *longitude = @"";
    NSString *latitude = @"";
    
    NSString *locationString = [self getLocationString];
    NSArray *locationArray = [locationString componentsSeparatedByString:@"&"];
    if (locationArray.count == 2) {
        //经度
        NSString *longitudeString = [locationArray objectAtIndex:0];
        NSArray *longitudeArray = [longitudeString componentsSeparatedByString:@"="];
        if (longitudeArray.count == 2) {
            longitude = [longitudeArray objectAtIndex:1];
        }
        //纬度
        NSString *latitudeString = [locationArray objectAtIndex:1];
        NSArray *latitudeArray = [latitudeString componentsSeparatedByString:@"="];
        if (latitudeArray.count == 2) {
            latitude = [latitudeArray objectAtIndex:1];
        }
    }
    
    longitude = longitude.length > 0 ? longitude : @"";
    latitude = latitude.length > 0 ? latitude : @"";
    return @[longitude, latitude];
}

- (NSDictionary *)channelToDic:(SNChannel *)channel {
    if (nil == channel) {
        return @{};
    }
    
    NSMutableDictionary *dic = [[NSMutableDictionary alloc] init];
    
    dic[@"id"] = channel.channelId ? @(channel.channelId.integerValue) : @(0);
    dic[@"gbcode"] = channel.gbcode ? : @"";
    dic[@"name"] = channel.channelName ? : @"";
    
    return dic;
}

- (SNChannel *)dicToChannel:(NSDictionary *)dic {
    if (nil == dic || dic.count == 0) {
        return nil;
    }
    
    SNChannel *channel = [[SNChannel alloc] init];
    
    channel.channelId = dic[@"id"] == nil ? nil : ((NSNumber *)dic[@"id"]).stringValue;
    
    // 两个接口返回的城市名的key不一样，做一个兼容。
    // location.go返回的城市名叫city,
    // locationChannel.go返回的城市名叫name
    channel.channelName = dic[@"name"] == nil ? dic[@"city"] : dic[@"name"];
    
    if ([dic[@"gbcode"] isKindOfClass:[NSString class]]) {
        //兼容服务端数据异常
        channel.gbcode = dic[@"gbcode"];
    }
    
    return channel;
}

- (void)saveUserLocation {
    NSMutableDictionary *userDic = [NSMutableDictionary dictionary];
    
    [userDic setObject:[self channelToDic:_currentCityChannel] forKey:@"current"];
    [userDic setObject:[self channelToDic:_localChannel] forKey:@"location"];
    [userDic setObject:@(_locationCoordinate.longitude) forKey:@"longtitude"];
    [userDic setObject:@(_locationCoordinate.latitude) forKey:@"latitude"];
    
    if (self.currentChannelId.length > 0) {
        [SNRollingNewsModel isLocalChannel:self.currentChannelId];
    }
    
    if (self.localChannelId.length > 0) {
        [SNRollingNewsModel isLocalChannel:self.localChannelId];
    }
    
    [[NSUserDefaults standardUserDefaults] setObject:userDic forKey:UserLocationStorageKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (void)readUserLocation {
    NSDictionary *userDic = [[NSUserDefaults standardUserDefaults] objectForKey:UserLocationStorageKey];
    
    if (nil != userDic && userDic.count > 0) {
        _locationCoordinate.longitude = ((NSNumber *)userDic[@"longtitude"]).doubleValue;
        _locationCoordinate.latitude = ((NSNumber *)userDic[@"latitude"]).doubleValue;
        
        self.localChannel = [self dicToChannel:userDic[@"location"]];
        self.currentCityChannel = [self dicToChannel:userDic[@"current"]];
        [SNUtility sharedUtility].currentChannelGbcode = self.currentCityChannel.gbcode;
    }
}

- (void)clearLocalChannel {
    _localChannel = nil;
    [self saveUserLocation];
}

- (BOOL)canNotifyDefault {
    BOOL can = _isLocalChannelChange;
    _isLocalChannelChange = NO;
    return can;
}

- (BOOL)refreshFromNetwork {
    BOOL can = _needRefreshFromNetWork;
    _needRefreshFromNetWork = NO;
    return can;
}

+ (void)saveHouseProLocalType:(NSInteger)localType
                withChannelId:(NSString *)channelId {
    if (localType == 2) {
        [[NSUserDefaults standardUserDefaults] setInteger:localType forKey:channelId];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
}

+ (BOOL)isHouseProLocalTypeWithChannelId:(NSString *)channelId {
    if (channelId == nil) {
        return NO;
    }
    NSInteger localType = [[NSUserDefaults standardUserDefaults] integerForKey:channelId];
    return localType == 2 ? YES : NO;
}

- (BOOL)locationRequest {
    if (_locationCoordinate.latitude == 0.0f ||
        _locationCoordinate.longitude == 0.0) {
        return NO;
    }
    [[[SNLocationRequest alloc] initWithLocation:CGPointMake(_locationCoordinate.latitude, _locationCoordinate.longitude)] send:^(SNBaseRequest *request, id responseObject) {
        SNDebugLog(@"%@",responseObject);
        if ([responseObject isKindOfClass:[NSDictionary class]]) {
            NSString *cityName = [responseObject objectForKey:kCity];
            SNChannel *dataBaseChannel = [SNUtility getChannelByChannelID:kLocalChannelUnifyID];
            if (![cityName isEqualToString:dataBaseChannel.channelName]) {
                [[SNDBManager currentDataBase] clearRollingEditNewsListByChannelId:dataBaseChannel.channelId];
            }
            
        }
    } failure:^(SNBaseRequest *request, NSError *error) {
        SNDebugLog(@"%@",error.localizedDescription);
    }];
    return YES;
}

@end
