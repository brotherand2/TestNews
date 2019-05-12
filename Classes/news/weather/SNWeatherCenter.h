//
//  SNWeatherCenter.h
//  sohunews
//
//  Created by yanchen wang on 12-7-17.
//  Copyright (c) 2012年 Sohu.com Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

#define kTemperatureMark                        (@"℃")
#define kTemperatureDegree                      (@"°")

#define kWeatherCityMaxNum                      (5)

#define kCityObjKeyCity                         (@"city")
#define kCityObjKeyCode                         (@"code")
#define kCityObjKeyGbCode                       (@"gbcode")
#define kCityObjKeyIndex                        (@"index")
#define kCityObjKeyProvince                     (@"province")

typedef enum {
    SNWeatherIconSizeSmall,
    SNWeatherIconSizeNormal,
    SNWeatherIconSizeBig,
}SNWeatherIconSize;

@class WeatherReport;

@protocol SNWeatherCenterDelegate <NSObject>

@optional
- (void)weatherDidFinishLoad:(NSString *)gbcode weatherReports:(NSArray *)weathers;

@end

@interface SNWeatherCenter : NSObject<TTURLRequestDelegate>

@property(strong, nonatomic, readonly, getter = mutableCityInfo)NSMutableDictionary *cityInfo;

+ (SNWeatherCenter *)defaultCenter;
+ (void)initCityDB;

+ (NSDate *)refreshDateForCityByGBcode:(NSString *)gbcode;
+ (NSString *)weekDayOfWeatherWeatherReport:(WeatherReport *)weather;
+ (NSString *)dateInfoStringByWeatherReport:(WeatherReport *)weather;
+ (NSArray *)weatherReportsByCityGbcode:(NSString *)gbcode;

// 低内存时  清理
- (void)clean;
- (void)commitCityInfo;

- (void)refreshDefaultCityWeather:(id)delegate;
- (void)forceRefreshDefaultCityWeather:(id)delegate;
- (void)refreshCityWeatherByCityCode:(NSString *)cityCode gbcode:(NSString *)gbCode delegate:(id)delegate channelId:(NSString *)newsChn;
- (void)forceRefreshWeatherByCityCode:(NSString *)cityCode gbcode:(NSString *)gbCode delegate:(id)delegate channelId:(NSString *)newsChn;

- (void)appendSubCityByGbcode:(NSString *)gbcode;
- (void)removeSubCityByGbcode:(NSString *)gbcode;

- (NSDictionary *)cityDicInfoByGbcode:(NSString *)defaultCode;
- (NSDictionary *)cityDicInfoByCityName:(NSString *)cityName;
- (NSArray *)subedCitiesArray;
- (void)setSubedCitiesArray:(NSArray *)newArray;

- (void)resetDefaultCity:(NSDictionary *)defaultCityInfo;
- (NSDictionary *)defaultCityInfo;

- (WeatherReport *)defaultWeatherReportForToday;


@end
