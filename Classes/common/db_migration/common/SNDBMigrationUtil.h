//
//  SNDBMigrationUtil.h
//  sohunews
//
//  Created by handy wang on 2/18/14.
//  Copyright (c) 2014 Sohu.com. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SNDBMigrationUtil : NSObject

+ (NSArray *)getGroupeddDBVersions;

+ (NSArray *)getExpandedGroupVersions;

+ (NSString *)getPenultimateDBLargeVersion;

//获取Bundle中存放导出的数据库文件路径
+ (NSString *)getExportedDBFilePathInBundle;

//根据已导出的数据文件路径拆分出这个数据库文件的版本号
+ (NSString *)getExportedDBFileVersionInBundle;
    
@end