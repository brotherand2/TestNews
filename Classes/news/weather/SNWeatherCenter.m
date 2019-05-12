//
//  SNWeatherCenter.m
//  sohunews
//
//  Created by yanchen wang on 12-7-17.
//  Copyright (c) 2012年 Sohu.com Inc. All rights reserved.
//

#import "SNWeatherCenter.h"
//#import "SNURLJSONResponse.h"
#import "NSDictionaryExtend.h"
#import "SNDBManager.h"
#import "SNUserLocationManager.h"
#import "SNWeatherRequest.h"

#define kCityDataFileName                   (@"cities.plist")
#define kTopicRefreshDefaultWeather         (@"kTopicRefreshDefaultWeather")
#define kTopicRefreshCityWeather            (@"kTopicRefreshCityWeather")

#define kDefaultGBCodeKey                   (@"kDefaultGBCodeKey")
#define kDefaultCityCodeKey                 (@"kDefaultCityCodeKey")
#define kDefaultCityNameKey                 (@"kDefaultCityNameKey")
#define kCitiesKey                          (@"cities")

#define kSubCitiesKey                       (@"kSubCitiesKey")

#define kDefaultCityObjKey                  (@"kDefaultCityObjKey")


static NSString * _dataFilePath() {
    NSArray *arr = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *filePath = nil;
    if ([arr count] > 0) {
        filePath = [[arr objectAtIndex:0] stringByAppendingPathComponent:kCityDataFileName];
    }
    return filePath;
}

@interface SNWeatherCenter ()
@property(nonatomic, strong)NSMutableDictionary *tempCityInfo;

- (BOOL)shouldRefreshForCity:(NSString *)cityCode;
- (void)setRefeshDateForCity:(NSString *)cityCode;

- (NSArray *)cacheDefaultWeather:(id)jsonObj;
- (NSArray *)cacheWeather:(id)jsonObj cityCode:(NSString *)cityCode gbCode:(NSString *)gbCode;
- (void)changeDefaultCity:(NSString *)gbCode;

@end

@implementation SNWeatherCenter
@synthesize tempCityInfo;
@synthesize cityInfo;

+ (SNWeatherCenter *)defaultCenter {
    static SNWeatherCenter *_center = nil;
    @synchronized(self) {
        if (nil == _center) {
            // 天气
            [self initCityDB];
            _center = [[SNWeatherCenter alloc] init];
        }
    }
    return _center;
}

+ (void)initCityDB {
    NSString *filePath = _dataFilePath();
    NSString *resDataFilePath = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:kCityDataFileName];
    NSDictionary *dic = [NSDictionary dictionaryWithContentsOfFile:resDataFilePath];
    NSString *cityVersion = [dic objectForKey:@"cityVersion"];
    NSFileManager *fileMgr = [NSFileManager defaultManager];
    // update
    if ([fileMgr fileExistsAtPath:filePath]) {
        NSDictionary *oldDic = [NSDictionary dictionaryWithContentsOfFile:filePath];
        NSString *oldCityVersion = [oldDic objectForKey:@"cityVersion"];
        
        //4.1.1版本更新了本地城市列表文件,增加判断
        NSString *updateCity = [[NSUserDefaults standardUserDefaults] objectForKey:@"updateCity"];
        
        if (![cityVersion isEqualToString:oldCityVersion] || !updateCity) {
            [fileMgr removeItemAtPath:filePath error:NULL];
        }
    }
    
    if (![fileMgr fileExistsAtPath:filePath]) {
        NSError *error = nil;
        [fileMgr copyItemAtPath:resDataFilePath toPath:filePath error:&error];
        if (error) {
            SNDebugLog(@"copy city file error");
        }else {
            [[NSUserDefaults standardUserDefaults] setObject:@"yes" forKey:@"updateCity"];
            [[NSUserDefaults standardUserDefaults] synchronize];
        }
    }
}

+ (NSDate *)refreshDateForCityByGBcode:(NSString *)gbcode {
    NSString *refreshDateKey = [NSString stringWithFormat:@"weather_refresh_date_city_%@", gbcode];
    return [[NSUserDefaults standardUserDefaults] objectForKey:refreshDateKey];
}

+ (NSString *)weekDayOfWeatherWeatherReport:(WeatherReport *)weather {
    NSString *weekDay = @"";
    if (weather) {
        NSDate *weatherDate = [SNWeatherCenter refreshDateForCityByGBcode:weather.cityGbcode];
        NSDate *realDate = [weatherDate dateByAddingTimeInterval:(60 * 60 * 24) * [weather.weatherIndex intValue]];
        NSCalendar *cld = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
        NSDateComponents *cpn = [cld components:NSWeekdayCalendarUnit fromDate:realDate];
        switch (cpn.weekday) {
            case 1:
                weekDay = NSLocalizedString(@"sunday", @"");
                break;
            case 2:
                weekDay = NSLocalizedString(@"monday", @"");
                break;
            case 3:
                weekDay = NSLocalizedString(@"tuesday", @"");
                break;
            case 4:
                weekDay = NSLocalizedString(@"wednesday", @"");
                break;
            case 5:
                weekDay = NSLocalizedString(@"thursday", @"");
                break;
            case 6:
                weekDay = NSLocalizedString(@"friday", @"");
                break;
            case 7:
                weekDay = NSLocalizedString(@"saturday", @"");
                break;
                
            default:
                break;
        }
    }
    return weekDay;
}

+ (NSString *)dateInfoStringByWeatherReport:(WeatherReport *)weather {
    NSString *dateInfo = @"";
    if (weather) {
        NSDate *weatherDate = [SNWeatherCenter refreshDateForCityByGBcode:weather.cityGbcode];
        NSDate *realDate = [weatherDate dateByAddingTimeInterval:(60 * 60 * 24) * [weather.weatherIndex intValue]];
        NSCalendar *cld = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
        NSDateComponents *cpn = [cld components:NSWeekdayCalendarUnit | NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit fromDate:realDate];
        NSString *weekDay = [SNWeatherCenter weekDayOfWeatherWeatherReport:weather];
        dateInfo = [NSString stringWithFormat:@"%ld月%ld日 %@ %@", (long)cpn.month, (long)cpn.day, weekDay, weather.chineseDate];
    }
    return dateInfo;
}

+ (NSArray *)weatherReportsByCityGbcode:(NSString *)gbcode {
    return [[SNDBManager currentDataBase] weatherReportsByCityGbCode:gbcode];
}

- (void)dealloc {
    [self clean];
}

- (NSMutableDictionary *)mutableCityInfo {
    NSString *filePath = _dataFilePath();
    NSMutableDictionary *dic = nil;
    if ([filePath length] > 0) {
        dic = [NSMutableDictionary dictionaryWithContentsOfFile:filePath];
        self.tempCityInfo = dic;
    }
    return dic;
}

#pragma mark - public methods
- (void)clean {
    self.tempCityInfo = nil;
}

- (void)commitCityInfo {
    if (self.tempCityInfo) {
        NSString *filePath = _dataFilePath();
        if ([[NSFileManager defaultManager] fileExistsAtPath:filePath]) {
            NSError *error = nil;
            [[NSFileManager defaultManager] removeItemAtPath:filePath error:&error];
            if (error) {
                SNDebugLog(@"%@-delete old file fail with error = %@", NSStringFromSelector(_cmd), error);
                return;
            }
            [self.tempCityInfo writeToFile:filePath atomically:YES];
        }
    }
}

- (void)refreshDefaultCityWeather:(id)delegate {
    NSDictionary *cityDic = self.cityInfo;
    NSDictionary *defaultCityInfo = [cityDic objectForKey:kDefaultCityObjKey];
    if (defaultCityInfo) {
        [self refreshCityWeatherByCityCode:[defaultCityInfo objectForKey:kCityObjKeyCode defalutObj:@""]
                                    gbcode:[defaultCityInfo objectForKey:kCityObjKeyGbCode defalutObj:@""]
                                  delegate:delegate channelId:[[SNUserLocationManager sharedInstance] localChannelId]];
    }
    else {
        if ([self shouldRefreshForCity:@"default"]) {
            [[[SNWeatherRequest alloc] init] send:^(SNBaseRequest *request, id responseObject) {
                
                NSArray *weathers = [self cacheDefaultWeather:responseObject];
                NSDictionary *dic = nil;
                if (weathers) {
                    dic = [NSDictionary dictionaryWithObject:weathers forKey:@"weathers"];
                }
                [SNNotificationManager postNotificationName:kWeatherDidChangeNotify object:nil userInfo:dic];
                
            } failure:^(SNBaseRequest *request, NSError *error) {
                
            }];
        }
    }
}

- (void)forceRefreshDefaultCityWeather:(id)delegate {
    NSDictionary *cityDic = self.cityInfo;
    NSDictionary *defaultCityInfo = [cityDic objectForKey:kDefaultCityObjKey];
    if (defaultCityInfo) {
        [self forceRefreshWeatherByCityCode:[defaultCityInfo objectForKey:kCityObjKeyCode defalutObj:@""]
                                     gbcode:[defaultCityInfo objectForKey:kCityObjKeyGbCode defalutObj:@""]
                                   delegate:delegate channelId:[[SNUserLocationManager sharedInstance] localChannelId]];
    }
    else {
        //        @autoreleasepool {
        //            NSString *url = [NSString stringWithFormat:kWeatherRefresh, @"", @""];
        //            url = [SNUtility addAPIVersionToURL:url];
        //            SNURLRequest *request = [SNURLRequest requestWithURL:url delegate:self];
        //            request.isShowNoNetWorkMessage = YES;
        //            request.userInfo = [TTUserInfo topic:kTopicRefreshDefaultWeather strongRef:delegate weakRef:nil];
        //            request.response = [[SNURLJSONResponse alloc] init];
        //            request.cachePolicy = TTURLRequestCachePolicyNoCache;
        //            [request send];
        //        }
        [[[SNWeatherRequest alloc] init] send:^(SNBaseRequest *request, id responseObject) {
            
            NSArray *weathers = [self cacheDefaultWeather:responseObject];
            NSDictionary *dic = nil;
            if (weathers) {
                dic = [NSDictionary dictionaryWithObject:weathers forKey:@"weathers"];
            }
            [SNNotificationManager postNotificationName:kWeatherDidChangeNotify object:nil userInfo:dic];
            
        } failure:^(SNBaseRequest *request, NSError *error) {
            
        }];
        
    }
}

- (void)refreshCityWeatherByCityCode:(NSString *)cityCode gbcode:(NSString *)gbCode delegate:(id)delegate channelId:(NSString *)newsChn {
    if ([self shouldRefreshForCity:gbCode]) {
        NSMutableDictionary *params = [NSMutableDictionary dictionaryWithCapacity:3];
        [params setValue:cityCode forKey:@"code"];
        [params setValue:gbCode forKey:@"gbcode"];
        [params setValue:newsChn forKey:@"channelId"];
        [[[SNWeatherRequest alloc] initWithDictionary:params] send:^(SNBaseRequest *request, id responseObject) {
            SNDebugLog(@"weather json obj = %@", responseObject);
            NSArray *weathers = nil;
            weathers = [self cacheWeather:responseObject cityCode:cityCode gbCode:gbCode];
            if (delegate && [delegate respondsToSelector:@selector(weatherDidFinishLoad:weatherReports:)]) {
                [delegate weatherDidFinishLoad:gbCode weatherReports:weathers];
            }
            
            NSDictionary *dic = nil;
            if (weathers) {
                dic = [NSDictionary dictionaryWithObject:weathers forKey:@"weathers"];
            }
            
            [SNNotificationManager postNotificationName:kWeatherDidChangeNotify object:nil userInfo:dic];
        } failure:^(SNBaseRequest *request, NSError *error) {
            
        }];
        
    }
}

- (void)forceRefreshWeatherByCityCode:(NSString *)cityCode gbcode:(NSString *)gbCode delegate:(id)delegate channelId:(NSString *)newsChn{
    //    @autoreleasepool {
    //        NSString *url = [NSString stringWithFormat:kWeatherRefresh, cityCode, gbCode];
    //        url = [SNUtility addAPIVersionToURL:url];
    //        url = [url stringByAppendingFormat:@"&channelId=%@",newsChn];
    //        SNURLRequest *request = [SNURLRequest requestWithURL:url delegate:self];
    //        request.isShowNoNetWorkMessage = YES;
    //        NSMutableDictionary *codes = [NSMutableDictionary dictionaryWithCapacity:2];
    //        if ([cityCode length] > 0) {
    //            [codes setObject:cityCode forKey:@"cityCode"];
    //        }
    //        if ([gbCode length] > 0) {
    //            [codes setObject:gbCode forKey:@"gbcode"];
    //        }
    //        if (delegate) {
    //            [codes setObject:delegate forKey:@"delegate"];
    //        }
    //        if (newsChn) {
    //            [codes setObject:newsChn forKey:@"channelId"];
    //        }
    //        request.userInfo = [TTUserInfo topic:kTopicRefreshCityWeather strongRef:codes weakRef:nil];
    //        request.response = [[SNURLJSONResponse alloc] init];
    //        request.cachePolicy = TTURLRequestCachePolicyNoCache;
    //        [request send];
    //    }
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithCapacity:3];
    [params setValue:cityCode forKey:@"code"];
    [params setValue:gbCode forKey:@"gbcode"];
    [params setValue:newsChn forKey:@"channelId"];
    [[[SNWeatherRequest alloc] initWithDictionary:params] send:^(SNBaseRequest *request, id responseObject) {
        SNDebugLog(@"weather json obj = %@", responseObject);
        NSArray *weathers = nil;
        weathers = [self cacheWeather:responseObject cityCode:cityCode gbCode:gbCode];
        if (delegate && [delegate respondsToSelector:@selector(weatherDidFinishLoad:weatherReports:)]) {
            [delegate weatherDidFinishLoad:gbCode weatherReports:weathers];
        }
        
        NSDictionary *dic = nil;
        if (weathers) {
            dic = [NSDictionary dictionaryWithObject:weathers forKey:@"weathers"];
        }
        
        [SNNotificationManager postNotificationName:kWeatherDidChangeNotify object:nil userInfo:dic];
    } failure:^(SNBaseRequest *request, NSError *error) {
        
    }];
}

- (void)appendSubCityByGbcode:(NSString *)gbcode {
    if (gbcode && [gbcode length] > 0) {
        NSMutableDictionary *dic = self.cityInfo;
        NSArray *subCities = [dic objectForKey:kSubCitiesKey];
        
        // 排重
        for (NSDictionary *subCity in subCities) {
            if ([[subCity objectForKey:kCityObjKeyGbCode] isEqualToString:gbcode]) {
                return; // 已经有了
            }
        }
        
        NSArray *allCities = [dic objectForKey:kCitiesKey];
        NSDictionary *findCity = nil;
        for (NSDictionary *aCity in allCities) {
            if ([[aCity objectForKey:kCityObjKeyGbCode] isEqualToString:gbcode]) {
                findCity = aCity;
                break;
            }
        }
        if (nil == findCity) {
            return;
        }
        
        NSMutableArray *tempArray = subCities == nil ? [NSMutableArray arrayWithCapacity:5] : [NSMutableArray arrayWithArray:subCities];
        [tempArray addObject:findCity];
        
        [dic setObject:tempArray forKey:kSubCitiesKey];
        
        [self commitCityInfo];
    }
}

- (void)removeSubCityByGbcode:(NSString *)gbcode {
    if (gbcode && [gbcode length] > 0) {
        NSMutableDictionary *dic = self.cityInfo;
        NSArray *subCities = [dic objectForKey:kSubCitiesKey];
        NSMutableArray *tempArray = subCities == nil ? [NSMutableArray arrayWithCapacity:5] : [NSMutableArray arrayWithArray:subCities];
        NSDictionary *findCity = nil;
        for (NSDictionary *aCity in tempArray) {
            if ([[aCity objectForKey:kCityObjKeyGbCode] isEqualToString:gbcode]) {
                findCity = aCity;
                break;
            }
        }
        
        if (nil == findCity) {
            return;
        }
        
        [tempArray removeObject:findCity];
        
        [dic setObject:tempArray forKey:kSubCitiesKey];
        [self commitCityInfo];
    }
}

- (NSDictionary *)cityDicInfoByGbcode:(NSString *)defaultCode {
    NSDictionary *cityDic = nil;
    
    if ([defaultCode length] > 0) {
        NSDictionary *dic = self.cityInfo;
        NSArray *allCities = [dic objectForKey:kCitiesKey];
        for (NSDictionary *aCity in allCities) {
            if ([[aCity objectForKey:kCityObjKeyGbCode] isEqualToString:defaultCode]) {
                cityDic = aCity;
                break;
            }
        }
    }
    
    return cityDic;
}

- (NSDictionary *)cityDicInfoByCityName:(NSString *)cityName {
    NSDictionary *cityDic = nil;
    if (cityName.length > 0) {
        NSDictionary *dic = self.cityInfo;
        NSArray *allCities = [dic objectForKey:kCitiesKey];
        for (NSDictionary *aCity in allCities) {
            if ([[aCity objectForKey:kCityObjKeyCity] isEqualToString:cityName]) {
                cityDic = aCity;
                break;
            }
        }
    }
    return cityDic;
}

- (NSArray *)subedCitiesArray {
    NSArray *arr = nil;
    NSDictionary *dic = self.cityInfo;
    arr = [dic objectForKey:kSubCitiesKey];
    return arr;
}

- (void)setSubedCitiesArray:(NSArray *)newArray {
    if (newArray) {
        NSMutableDictionary *dic = self.cityInfo;
        [dic setObject:newArray forKey:kSubCitiesKey];
        [self commitCityInfo];
    }
}

- (void)resetDefaultCity:(NSDictionary *)defaultCityInfo {
    if (defaultCityInfo) {
        NSMutableDictionary *dic = self.cityInfo;
        [dic setObject:defaultCityInfo forKey:kDefaultCityObjKey];
        [self commitCityInfo];
        [SNNotificationManager postNotificationName:kWeatherDidChangeNotify object:nil];
    }
}

- (NSDictionary *)defaultCityInfo {
    NSDictionary *dic = self.cityInfo;
    return [dic objectForKey:kDefaultCityObjKey];
}

- (WeatherReport *)defaultWeatherReportForToday {
    WeatherReport *weather = nil;
    NSDictionary *dic = self.cityInfo;
    NSDictionary *defaultCity = [dic objectForKey:kDefaultCityObjKey];
    NSArray *weatherArr = nil;
    if (defaultCity) {
        NSString *gbcode = [defaultCity objectForKey:kCityObjKeyGbCode];
        weatherArr = [[SNDBManager currentDataBase] weatherReportsByCityGbCode:gbcode];
        if ([weatherArr count] > 0) {
            weather = [weatherArr objectAtIndex:0];
        }
    }
    return weather;
}

#pragma mark - private methods
- (BOOL)shouldRefreshForCity:(NSString *)cityCode {
    if ([cityCode length] > 0) {
        
        // 半小时刷新一次
        NSDate *weatherDate = [SNWeatherCenter refreshDateForCityByGBcode:cityCode];
        if (weatherDate && [weatherDate isKindOfClass:[NSDate class]]) {
            return [(NSDate *)[weatherDate dateByAddingTimeInterval:30*60] compare:[NSDate date]] < 0;
        } else {
            return YES;
        }
        //        NSString *key = [NSString stringWithFormat:@"weather_refresh_city_%@", cityCode];
        //        NSString *val = [[NSUserDefaults standardUserDefaults] objectForKey:key];
        //        if (nil == val) {
        //            return YES;
        //        }
        //        NSCalendar *calendar = [[[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar] autorelease];
        //        NSDateComponents *dateComp = [calendar components:NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit fromDate:[NSDate date]];
        //        NSString *calStr = [NSString stringWithFormat:@"%d%d%d", dateComp.year, dateComp.month, dateComp.day];
        //        if (![calStr isEqual:val]) {
        //            return YES;
        //        }
    }
    return NO;
}

- (void)setRefeshDateForCity:(NSString *)cityCode {
    if ([cityCode length] > 0) {
        //        NSString *key = [NSString stringWithFormat:@"weather_refresh_city_%@", cityCode];
        NSString *refreshDateKey = [NSString stringWithFormat:@"weather_refresh_date_city_%@", cityCode];
        
        //        NSCalendar *calendar = [[[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar] autorelease];
        //        NSDateComponents *dateComp = [calendar components:NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit fromDate:[NSDate date]];
        //        NSString *calStr = [NSString stringWithFormat:@"%d%d%d", dateComp.year, dateComp.month, dateComp.day];
        //
        //        [[NSUserDefaults standardUserDefaults] setObject:calStr forKey:key];
        [[NSUserDefaults standardUserDefaults] setObject:[NSDate date] forKey:refreshDateKey];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
}

- (NSArray *)cacheDefaultWeather:(id)jsonObj {
    NSArray *weathers = nil;
    if ([jsonObj isKindOfClass:[NSDictionary class]]) {
        NSDictionary *dicInfo = jsonObj;
        NSString *defaultGbCode = [dicInfo objectForKey:@"defaultGbcode"];
        NSString *shareLink = [dicInfo objectForKey:@"sharedLink"];
        NSDictionary *cityInfoDic = [self cityDicInfoByGbcode:defaultGbCode];
        NSMutableArray *reports = [NSMutableArray arrayWithCapacity:3];
        NSDictionary *moreLinkDic = [jsonObj objectForKey:@"moreLink"];
        id weatherObj = [dicInfo objectForKey:@"weather"];
        
        if ([weatherObj isKindOfClass:[NSArray class]]) {
            for (int i = 0; i < [(NSArray *)weatherObj count]; ++ i) {
                NSDictionary *weatherInfo = [(NSArray *)weatherObj objectAtIndex:i];
                WeatherReport *weatherReport = [[WeatherReport alloc] initWithDictionary:weatherInfo];
                weatherReport.city = [cityInfoDic objectForKey:kCityObjKeyCity defalutObj:@""];
                weatherReport.cityGbcode = defaultGbCode;
                weatherReport.cityCode = [cityInfoDic objectForKey:kCityObjKeyCode defalutObj:@""];
                weatherReport.weatherIndex = [NSString stringWithFormat:@"%d", i];
                weatherReport.shareLink = shareLink;
                weatherReport.copywriting = [moreLinkDic stringValueForKey:@"copywriting" defaultValue:@""];
                weatherReport.morelink = [moreLinkDic stringValueForKey:@"link" defaultValue:@""];
                [reports addObject:weatherReport];
            }
        }
        else if ([weatherObj isKindOfClass:[NSDictionary class]]) {
            WeatherReport *weatherReport = [[WeatherReport alloc] initWithDictionary:weatherObj];
            weatherReport.city = [cityInfoDic objectForKey:kCityObjKeyCity defalutObj:@""];
            weatherReport.cityGbcode = defaultGbCode;
            weatherReport.cityCode = [cityInfoDic objectForKey:kCityObjKeyCode defalutObj:@""];
            weatherReport.weatherIndex = [NSString stringWithFormat:@"%d", 0];
            weatherReport.shareLink = shareLink;
            [reports addObject:weatherReport];
        }
        
        [self changeDefaultCity:defaultGbCode];
        [self appendSubCityByGbcode:defaultGbCode];
        weathers = reports;
        if ([[SNDBManager currentDataBase] updateWeatherReports:reports]) {
            [self setRefeshDateForCity:@"default"];
            [self setRefeshDateForCity:defaultGbCode];
        }
    }
    
    return weathers;
}

- (NSArray *)cacheWeather:(id)jsonObj cityCode:(NSString *)cityCode gbCode:(NSString *)gbCode {
    NSArray *weathers = nil;
    if ([jsonObj isKindOfClass:[NSDictionary class]]) {
        NSMutableArray *reports = [NSMutableArray arrayWithCapacity:3];
        NSDictionary *cityInfoDic = [self cityDicInfoByGbcode:gbCode];
        NSString *shareLink = [jsonObj objectForKey:@"sharedLink"];
        NSDictionary *moreLinkDic = [jsonObj objectForKey:@"moreLink"];
        id weatherObj = [jsonObj objectForKey:@"weather"];
        if ([weatherObj isKindOfClass:[NSArray class]]) {
            for (int i = 0; i < [(NSArray *)weatherObj count]; ++ i) {
                NSDictionary *weatherInfo = [(NSArray *)weatherObj objectAtIndex:i];
                WeatherReport *weatherReport = [[WeatherReport alloc] initWithDictionary:weatherInfo];
                weatherReport.city = [cityInfoDic objectForKey:kCityObjKeyCity defalutObj:@""];
                weatherReport.cityGbcode = gbCode;
                weatherReport.cityCode = [cityInfoDic objectForKey:kCityObjKeyCode defalutObj:@""];
                weatherReport.weatherIndex = [NSString stringWithFormat:@"%d", i];
                weatherReport.shareLink = shareLink;
                weatherReport.copywriting = [moreLinkDic stringValueForKey:@"copywriting" defaultValue:@""];
                weatherReport.morelink = [moreLinkDic stringValueForKey:@"link" defaultValue:@""];
                [reports addObject:weatherReport];
            }
        }
        else if ([weatherObj isKindOfClass:[NSDictionary class]]) {
            WeatherReport *weatherReport = [[WeatherReport alloc] initWithDictionary:weatherObj];
            weatherReport.city = [cityInfoDic objectForKey:kCityObjKeyCity defalutObj:@""];
            weatherReport.cityGbcode = gbCode;
            weatherReport.cityCode = [cityInfoDic objectForKey:kCityObjKeyCode defalutObj:@""];
            weatherReport.weatherIndex = [NSString stringWithFormat:@"%d", 0];
            weatherReport.shareLink = shareLink;
            [reports addObject:weatherReport];
        }
        
        weathers = reports;
        if ([[SNDBManager currentDataBase] updateWeatherReports:reports]) {
            [self setRefeshDateForCity:gbCode];
        }
    }
    
    return weathers;
}

- (void)changeDefaultCity:(NSString *)gbCode {
    NSMutableDictionary *cityInfoDic = self.cityInfo;
    NSArray *cityArray = [cityInfoDic objectForKey:kCitiesKey];
    for (NSDictionary *aCityInfo in cityArray) {
        if ([gbCode isEqualToString:[aCityInfo objectForKey:kCityObjKeyGbCode]]) {
            [cityInfoDic setObject:aCityInfo forKey:kDefaultCityObjKey];
            break;
        }
    }
    
    [self commitCityInfo];
}

//#pragma mark - TTURLRequestDelegate
//- (void)requestDidFinishLoad:(TTURLRequest*)request {
//    TTUserInfo *userInfo = request.userInfo;
//    NSArray *weathers = nil;
//    if ([userInfo.topic isEqual:kTopicRefreshDefaultWeather]) {
//        SNURLJSONResponse *json = request.response;
//        SNDebugLog(@"default json obj = %@", json.rootObject);
//        weathers = [self cacheDefaultWeather:json.rootObject];
//    }
//    else if ([userInfo.topic isEqual:kTopicRefreshCityWeather]) {
//        SNURLJSONResponse *json = request.response;
//        SNDebugLog(@"weather json obj = %@", json.rootObject);
//        NSDictionary *dic = userInfo.strongRef;
//        weathers = [self cacheWeather:json.rootObject cityCode:[dic objectForKey:@"cityCode" defalutObj:@""] gbCode:[dic objectForKey:@"gbcode" defalutObj:@""]];
//        id delegate = [dic objectForKey:@"delegate"];
//        if (delegate && [delegate respondsToSelector:@selector(weatherDidFinishLoad:weatherReports:)]) {
//            [delegate weatherDidFinishLoad:[dic objectForKey:@"gbcode" defalutObj:@""] weatherReports:weathers];
//        }
//    }
//
//    NSDictionary *dic = nil;
//    if (weathers) {
//        dic = [NSDictionary dictionaryWithObject:weathers forKey:@"weathers"];
//    }
//
//    [SNNotificationManager postNotificationName:kWeatherDidChangeNotify object:nil userInfo:dic];
//}
//
//- (void)request:(TTURLRequest*)request didFailLoadWithError:(NSError*)error {
//    
//}

@end
