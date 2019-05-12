//
//  SNUserLocationManager.h
//  sohunews
//
//  Created by lhp on 10/22/13.
//  Copyright (c) 2013 Sohu.com. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <SystemConfiguration/CaptiveNetwork.h>
#import <CoreLocation/CoreLocation.h>
#import <CoreLocation/CLLocationManagerDelegate.h>
#import "SNChannel.h"

typedef enum {
    SNLocalChannelResultNone,           //定位不到城市
    SNLocalChannelResultCity,           //定位城市无频道信息
    SNLocalChannelResultLocalChannel,   //定位到本地频道
    SNLocalChannelResultLocating,       //定位中...
} SNLocalChannelResult;

@interface SNUserLocationManager : NSObject <CLLocationManagerDelegate>
typedef void (^RefreshLocationBlock)();
typedef void (^RefreshChannelLocationBlock)();
@property (nonatomic, copy) RefreshLocationBlock refreshBlock;
@property (nonatomic, copy) RefreshChannelLocationBlock refreshChannelBlock;
@property (nonatomic) int loactionRequestTime;
@property (nonatomic) int distanceValue;

@property (nonatomic, strong) NSString *resultString;

@property (weak, nonatomic, readonly) NSString *localChannelName;
@property (weak, nonatomic, readonly) NSString *localChannelId;
@property (weak, nonatomic, readonly) NSString *localChannelGBCode;

@property (weak, nonatomic, readonly) NSString *currentChannelName;
@property (weak, nonatomic, readonly) NSString *currentChannelId;
@property (weak, nonatomic, readonly) NSString *currentChannelGBCode;
@property (nonatomic, strong) SNChannel *currentCityChannel;   // 当前用户实际所在的城市对应的频道

@property (nonatomic, readonly) BOOL hasLocationAuthorization;
@property (nonatomic, readonly) SNLocalChannelResult localResult;

@property (nonatomic, strong) SNURLRequest *_request;
@property (nonatomic, assign) BOOL isRefreshLocation;
@property (nonatomic, assign) BOOL isRefreshChannelLocation;

+ (SNUserLocationManager *)sharedInstance;

- (NSString *)getLocationString;
- (NSString *)getNewsLocationString;
- (NSDictionary *)getNewsLocationParams;
- (NSString *)getLongitude;
- (NSString *)getLatitude;
- (NSString *)getResultString;

- (void)resetLocatingChannel;
- (void)updateLocationTime:(int)times;
- (void)updateLocationWithDate;
- (void)clearLocalChannel;

- (void)updateLocalChannelWithId:(NSString *)idString
                        cityName:(NSString *)name
                          gbcode:(NSString *)gbcode
                       channelId:(NSString *)channelId;

- (void)updateHouseProLocalChannelWithId:(NSString *)idString
                                cityName:(NSString *)name
                                  gbcode:(NSString *)gbcode
                               channelId:(NSString *)channelId;

- (void)updateLocation;
- (void)updateLocationUserData:(NSObject *)userData;

- (void)notifyLocalChange;

- (BOOL)canNotifyDefault;
- (BOOL)refreshFromNetwork;

+ (void)saveHouseProLocalType:(NSInteger)localType
                withChannelId:(NSString *)channelId;

+ (BOOL)isHouseProLocalTypeWithChannelId:(NSString *)channelId;

@end
