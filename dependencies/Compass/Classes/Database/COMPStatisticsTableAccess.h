//
//  COMPStatisticsTableAccess.h
//  Compass
//
//  Created by 李耀忠 on 25/09/2017.
//  Copyright © 2017 Beijing Sohu New Media Information Technology Co. Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "COMPDatabase.h"

#define TABLE_COLUMN_ID @"id"
#define TABLE_COLUMN_CONTENT @"content"

@interface COMPStatisticsTableAccess : NSObject

@property (nonatomic, readonly) NSInteger count;

- (instancetype)initWithDatabase:(COMPDatabase *)database;
- (BOOL)createTable;
- (BOOL)addStatisticsWithData:(NSData *)data uploadImmediately:(BOOL)uploadImmediately;
- (NSArray<NSDictionary *> *)allStatisticsData;
- (NSArray<NSDictionary *> *)statisticsDataWithCount:(NSInteger)maxCount;
- (BOOL)deleteStatisticsNoNewerThanData:(NSDictionary *)data;
- (BOOL)deleteDataBeforeDate:(NSDate *)date;
- (BOOL)needUpdateImmediately;

@end
