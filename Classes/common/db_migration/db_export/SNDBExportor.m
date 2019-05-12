//
//  SNDBExportor.m
//  sohunews
//
//  Created by handy wang on 2/12/14.
//  Copyright (c) 2014 Sohu.com. All rights reserved.
//

#import "SNDBExportor.h"
#import "SNPreference.h"

@implementation SNDBExportor

#pragma mark - Public
+ (SNDBExportor *)sharedInstance {
    static SNDBExportor *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[SNDBExportor alloc] init];
    });
    return sharedInstance;
}

- (void)exportDB {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        @autoreleasepool {

            //删除Document目录下已导出的数据库文件
            if (![self removeExportedDBFileIfExistedInDocuments]) {
                return;
            }
            
            //开发模式
            if ([SNPreference sharedInstance].debugModeEnabled) {
                [self exportDBFileIfNeeded];
            
            //非开发模式
            } else {
                [self throwCompileErrorIfNoExportedDBFileInBundle];
            }
            
        }
    });
}

#pragma mark - Private
- (BOOL)removeExportedDBFileIfExistedInDocuments {
    NSString *exportedDBFileDirInDocuments = [self getExportedDBFileDirInDocuments];
    
    NSFileManager *fm = [NSFileManager defaultManager];
    NSError *error = nil;
    [fm removeItemAtPath:exportedDBFileDirInDocuments error:&error];
    if (!!error) {
        SNDebugLog(@"Failed to remove exported db file in documents");
        return NO;
    }
    return YES;
}

- (void)exportDBFileIfNeeded {
    if ([SNPreference sharedInstance].debugModeEnabled) {
    
        NSString *penultimateDBLargeVersion = [SNDBMigrationUtil getPenultimateDBLargeVersion];
        NSString *exportedDBVersionInBundle = [SNDBMigrationUtil getExportedDBFileVersionInBundle];
        BOOL isPenultimateDBLargeVersion = [exportedDBVersionInBundle isEqualToString:penultimateDBLargeVersion] && (penultimateDBLargeVersion.length > 0);
        
        //在bundle里已导出的数据文件不是倒数第二个大版本(可能不存在或存在但不是倒数第二个大版本)
        if (!isPenultimateDBLargeVersion) {
            BOOL isExportSuccessful = [self exportDBFile];
            if (isExportSuccessful) {
                SNDebugLog(@"Pls add & copy the exported db file into 'Supporting' Files dir of project dir.");
            }
            else {
                SNDebugLog(@"Pls check why exporting db file is failed.");
            }
        }
        //在bundle里已导出的数据文件是倒数第二个大版本
        else {
            SNDebugLog(@"Exported db file in bundle is latest Penultimate version.");
        }
    
    }
}

#pragma mark - In documents
- (NSString *)getDocumentsDir {
    NSArray *_paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
	NSString *documentsDir = [_paths objectAtIndex:0];
    return documentsDir;
}

- (NSString *)getExportedDBFileDirInDocuments {
    NSString *exportedDBFileDirInDocuments = [[self getDocumentsDir] stringByAppendingPathComponent:kExportedDBFileDir];
    NSError *error = nil;
    BOOL rst = [[NSFileManager defaultManager] createDirectoryAtPath:exportedDBFileDirInDocuments withIntermediateDirectories:YES attributes:nil error:&error];
    if (!rst || !!error) {
        return nil;
    }
    else {
        return exportedDBFileDirInDocuments;
    }
}

//获取Documents中存放导出的数据库文件路径
- (NSString *)getExportedDBFilePathInDocumentsWithDBVersion:(NSString *)dbVersion {
    NSString *fileName = [kExportedDBFileName stringByAppendingFormat:@"|%@|exported", dbVersion];
    NSString *exportedDBFilePathInDocuments = [[self getExportedDBFileDirInDocuments] stringByAppendingPathComponent:fileName];
    return exportedDBFilePathInDocuments;
}

#pragma mark - In bundle
- (BOOL)exportDBFile {
    NSString *fromVersion = [SNDBMigrationUtil getExportedDBFileVersionInBundle];
    NSString *toVersion = [SNDBMigrationUtil getPenultimateDBLargeVersion];
    
    if (toVersion.length <= 0) {
        return NO;
    }

    NSString *fromDBFilePath = [SNDBMigrationUtil getExportedDBFilePathInBundle];
    BOOL isDir;
    if (![[NSFileManager defaultManager] fileExistsAtPath:fromDBFilePath isDirectory:&isDir]
        || fromVersion.length <= 0) {
        
        fromVersion = kMinSqliteVersionOfSupportingDBMigration;
        fromDBFilePath = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:DB_FILE_NAME_3_1_2];
    }
    
    NSFileManager *fm = [NSFileManager defaultManager];
    if ([fm fileExistsAtPath:fromDBFilePath isDirectory:&isDir]) {
        
        //---这是为了容错让逻辑完整，不写也行
        NSError *error = nil;
        NSString *exportedDBFilePathInDocuments = [self getExportedDBFilePathInDocumentsWithDBVersion:toVersion];
        if ([[NSFileManager defaultManager] fileExistsAtPath:exportedDBFilePathInDocuments isDirectory:&isDir]) {
            BOOL rst =[[NSFileManager defaultManager] removeItemAtPath:exportedDBFilePathInDocuments error:&error];
            if (!rst || !!error) {
                return NO;
            }
        }
        //---

        NSError *copyError = nil;
        BOOL copyRst = [fm copyItemAtPath:fromDBFilePath toPath:exportedDBFilePathInDocuments error:&copyError];
        if (copyRst && !copyError) {
            BOOL exportRst = [self executeMigrationHistoryFromVersion:fromVersion toVersion:toVersion onDBFilePath:exportedDBFilePathInDocuments];
            if (!exportRst && [[NSFileManager defaultManager] fileExistsAtPath:exportedDBFilePathInDocuments]) {
                NSError *rError = nil;
                BOOL rResult = [[NSFileManager defaultManager] removeItemAtPath:exportedDBFilePathInDocuments error:&rError];
                if (!!rError || !rResult) {
                    return NO;
                }
                else {
                    return YES;
                }
            }
            else {
                return exportRst;
            }
        }
        else {
            return NO;
        }
    }
    else {
        return NO;
    }
}

- (BOOL)executeMigrationHistoryFromVersion:(NSString *)fromVersion toVersion:(NSString *)toVersion onDBFilePath:(NSString *)dbFilePath {
    if (fromVersion.length <= 0 || toVersion.length <= 0 || dbFilePath.length <= 0) {
        return NO;
    }
    
    NSArray *versions = [SNDBMigrationUtil getExpandedGroupVersions];
    unsigned long fromDBVersionIndex = [versions indexOfObject:fromVersion];
    unsigned long toDBVersionIndex = [versions indexOfObject:toVersion];
    if (fromDBVersionIndex == NSNotFound || toDBVersionIndex == NSNotFound) {
        return NO;
    }
    
    if (fromDBVersionIndex == toDBVersionIndex) {
        return YES;
    }
    else if (fromDBVersionIndex > toDBVersionIndex) {
        return NO;
    }
    
    SNDBExportorMigration *fmdbMigration = [[SNDBExportorMigration alloc] init];
	FmdbMigrationManager *fmdbManager = [[FmdbMigrationManager alloc] initWithDatabasePath:dbFilePath];
    fmdbMigration.db = fmdbManager.db;
    
    NSArray *_migratedVersions = [versions subarrayWithRange:NSMakeRange(fromDBVersionIndex+1, (toDBVersionIndex-fromDBVersionIndex))];
    for (NSString *version in _migratedVersions) {
        SEL upSelector = NSSelectorFromString([kMigrateUpToSelectorPrefix stringByAppendingString:version]);
        if ([fmdbMigration respondsToSelector:upSelector]) {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
            [fmdbMigration performSelector:upSelector];
#pragma clang diagnostic pop

        }
    }
    
    fmdbManager = nil;
    fmdbMigration = nil;
    
    return YES;
}

#pragma mark -
- (void)throwCompileErrorIfNoExportedDBFileInBundle {
    if (![SNPreference sharedInstance].debugModeEnabled) {
        NSString *exportedDBFilePathInBundle = [SNDBMigrationUtil getExportedDBFilePathInBundle];
    
        NSString *exportedDBFileVersion = [SNDBMigrationUtil getExportedDBFileVersionInBundle];
        NSString *penultimateDBLargeVersion = [SNDBMigrationUtil getPenultimateDBLargeVersion];
    
        BOOL isDir;
        if (![[NSFileManager defaultManager] fileExistsAtPath:exportedDBFilePathInBundle isDirectory:&isDir]
            || (![penultimateDBLargeVersion isEqualToString:exportedDBFileVersion])) {
            SNDebugLog(@"Pls turn on DEBUG_MODE and reRun in xocde to export penultimate db file, then copy it to assets dir in project.");
        }
    }
}

@end
