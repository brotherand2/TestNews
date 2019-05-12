//
//  SNDatabase_Weather.m
//  sohunews
//
//  Created by yanchen wang on 12-7-17.
//  Copyright (c) 2012年 Sohu.com Inc. All rights reserved.
//
#import "SNDatabase_Weather.h"
#import "SNDBManager.h"

@implementation SNDatabase(Weather)

- (BOOL)saveOneReport:(WeatherReport *)report inDatabase:(FMDatabase *)db {
    if (!report) {
        return NO;
    }
    
    [db executeUpdate:@"INSERT INTO tbWeatherReports (weatherIndex, city, cityCode, cityGbcode, chuanyi, date, chineseDate, ganmao, jiaotong, lvyou, platformId, tempHigh, tempLow, weather, weatherIconUrl, weatherLocalIconUrl, wind, wuran, yundong, shareLink, pm25, quality, shareContent, morelink, copywriting) VALUES (?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?)",
     report.weatherIndex, report.city, report.cityCode,
     report.cityGbcode, report.chuanyi, report.date, report.chineseDate,
     report.ganmao, report.jiaotong, report.lvyou, report.platformId, report.tempHigh, report.tempLow,
     report.weather, report.weatherIconUrl, report.weatherLocalIconUrl, report.wind, report.wuran, report.yundong, report.shareLink, report.pm25, report.quality, report.shareContent, report.morelink, report.copywriting];
    
    if ([db hadError]) {
        SNDebugLog(@"save a report error error=%@", [db lastErrorMessage]);
        return NO;
    }
    return YES;
}

- (BOOL)updateWeatherReports:(NSArray *)reports {
    __block BOOL bRet = YES;
    [[SNDatabase writeQueue] inTransaction:^(FMDatabase *db, BOOL *rollback) {
        if ([reports count] > 0) {
            WeatherReport *report = [reports objectAtIndex:0];
            bRet = [db executeUpdate:@"DELETE FROM tbWeatherReports WHERE cityGbcode = ?", report.cityGbcode];
            if ([db hadError]) {
                SNDebugLog(@"Delete old reports fail");
                *rollback= YES;
                return ;
            }
            for (WeatherReport *aReport in reports) {
                bRet = [self saveOneReport:aReport inDatabase:db];
                if (!bRet) {
                    *rollback = YES;
                    return;
                }
            }
        }
    }];
    return bRet;
}

- (NSArray *)weatherReportsByCityGbCode:(NSString *)gbcode {
    NSMutableArray *arr = [NSMutableArray arrayWithCapacity:3];

    [[SNDatabase readQueue] inDatabase:^(FMDatabase *db) {
        FMResultSet *rs = [db executeQuery:@"SELECT * FROM tbWeatherReports WHERE cityGbcode = ?",gbcode];
        [arr addObjectsFromArray:[self getObjects:[WeatherReport class] fromResultSet:rs]];
    }];
    return arr;
}

@end
