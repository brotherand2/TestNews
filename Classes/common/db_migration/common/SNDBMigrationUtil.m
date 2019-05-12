//
//  SNDBMigrationUtil.m
//  sohunews
//
//  Created by handy wang on 2/18/14.
//  Copyright (c) 2014 Sohu.com. All rights reserved.
//

#import "SNDBMigrationUtil.h"
#import "SNDBMigrationConst.h"
#import "NSString+DBMigration.h"

@implementation SNDBMigrationUtil

#pragma mark -
+ (NSArray *)getGroupeddDBVersions {
    return @[
             @[kMinSqliteVersionOfSupportingDBMigration],//for app version 3.1.2
             @[@"3_1_3_1", @"3_1_3_2",@"3_1_3_3"],//for app version 3.1.3
             @[@"3_1_4_1"],//for app version 3.1.4
             @[@"3_1_5_1", @"3_1_5_2", @"3_1_5_3", @"3_1_5_4"], // for app version 3.1.5
             @[@"3_2_0_1", @"3_2_0_2", @"3_2_0_3", @"3_2_0_4", @"3_2_0_5"], // for app version 3.2.0
             @[@"3_3_0_1", @"3_3_0_2", @"3_3_0_3", @"3_3_0_4"],// for app version 3.3.0
             @[@"3_3_1_1", @"3_3_1_2", @"3_3_1_3", @"3_3_1_4", @"3_3_1_5", @"3_3_1_6"], // for app version 3.3.1
             @[@"3_4_0_1", @"3_4_0_2", @"3_4_0_3", @"3_4_0_4", @"3_4_0_5", @"3_4_0_6"],// for app version 3.4.0
             @[@"3_4_1_1"], // for app version 3.4.1
             @[@"3_5_0_0", @"3_5_0_1", @"3_5_0_2", @"3_5_0_3", @"3_5_0_4", @"3_5_0_5", @"3_5_0_6"], // for app version 3.5.0
             @[@"3_5_1_0", @"3_5_1_1", @"3_5_1_2", @"3_5_1_3", @"3_5_1_4", @"3_5_1_5"],// for app version 3.5.1
             @[@"3_6_0_1", @"3_6_0_2", @"3_6_0_3"],// for app version 3.6
             @[@"3_6_1_1"], // for app version 3.6.1
             @[@"3_7_0_0",@"3_7_0_1",@"3_7_0_2",@"3_7_0_3",@"3_7_0_4",@"3_7_0_5", @"3_7_0_6",@"3_7_0_7"],// for app version 3.7
             @[@"3_7_1_1",@"3_7_1_2",@"3_7_1_3",@"3_7_1_4",@"3_7_1_5",@"3_7_1_6"],//for app version 3.8 (曾叫3.7.1)
             @[@"4_0_0_1",@"4_0_0_2",@"4_0_0_3",@"4_0_0_4",@"4_0_0_5",@"4_0_0_6",@"4_0_0_7",@"4_0_0_8",@"4_0_0_9",@"4_0_0_10"],//for app version 4.0
             @[@"4_0_1_1",@"4_0_1_2",@"4_0_1_3"],//for app version 4.1(曾叫4.0.1)
             @[@"4_2_0_1",@"4_2_0_2",@"4_2_0_3",@"4_2_0_4",@"4_2_0_5"],//for app version 4.2
             @[@"4_3_0_1",@"4_3_0_2",@"4_3_0_3"],//for app version 4.3
             @[@"4_3_1_1",@"4_3_1_2"],//for app version 4.3.1
             @[@"4_3_2_1",@"4_3_2_2",@"4_3_2_3",@"4_3_2_4",@"4_3_2_5",@"4_3_2_6",@"4_3_2_7",@"4_3_2_8",@"4_3_2_9",@"4_3_2_10"],
             @[@"5_0_0_1",@"5_0_0_2",@"5_0_0_3",@"5_0_0_4",@"5_0_0_5",@"5_0_0_6",@"5_0_0_7"],
             @[@"5_1_0_1"],@[@"5_2_0"],@[@"5_2_1"],@[@"5_3_0"],@[@"5_3_1"],@[@"5_3_2"],@[@"5_4_1"],@[@"5_5_5"],@[@"5_5_2"],@[@"5_6_0"],@[@"5_6_1"],@[@"5_8_0"],@[@"5_8_1"],@[@"5_8_2"],@[@"5_9_6"],@[@"5_9_7"]
             ];
}

+ (NSArray *)getExpandedGroupVersions {
    NSMutableArray *array = [NSMutableArray array];
    
    for (NSArray *group in [self getGroupeddDBVersions]) {
        for (NSString *version in group) {
            if (version.length > 0) {
                [array addObject:version];
            }
        }
    }
    
    return array;
}

+ (NSString *)getPenultimateDBLargeVersion {
    NSString *penultimateDBLargeVersion = nil;
    
    NSArray *versions = [self getGroupeddDBVersions];
    NSInteger groupedVersionCount = versions.count;
    if (groupedVersionCount >= 2) {
        NSArray *penultimateGroup = [versions objectAtIndex:(groupedVersionCount-2)];
        penultimateDBLargeVersion = [penultimateGroup lastObject];
    }
    else {
        penultimateDBLargeVersion = kMinSqliteVersionOfSupportingDBMigration;
    }
    
    return penultimateDBLargeVersion;
}

//根据已导出的数据文件路径拆分出这个数据库文件的版本号
+ (NSString *)getExportedDBFileVersionInBundle {
    NSString *dbFileName = [self getExportedDBFileNameInBundle];
    
    if (dbFileName.length > 0) {
        NSArray *components = [dbFileName componentsSeparatedByString:@"|"];
        if (components.count == 3) {
            NSString *exportedDBVersionInBundle = [components objectAtIndex:1];
            return exportedDBVersionInBundle;
        }
    }
    return nil;
}

//获取Bundle中存放导出的数据库文件路径
+ (NSString *)getExportedDBFilePathInBundle {
    NSString *dbFileName = [self getExportedDBFileNameInBundle];
    if (dbFileName.length > 0) {
        NSString *exportedDBFileDirInBundle = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:kExportedDBFileDir];
        return [exportedDBFileDirInBundle stringByAppendingPathComponent:dbFileName];
    }
    else {
        return nil;
    }
}

#pragma mark -
+ (NSString *)getExportedDBFileNameInBundle {
    NSString *exportedDBFileDirInBundle = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:kExportedDBFileDir];
    NSString *dbFileName = nil;
    NSArray *contents = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:exportedDBFileDirInBundle error:nil];
    for (NSString *fileName in contents) {
        if ([fileName endWith:@"|exported"]) {
            dbFileName = fileName;
            break;
        }
    }
    
    return dbFileName;
}

@end
