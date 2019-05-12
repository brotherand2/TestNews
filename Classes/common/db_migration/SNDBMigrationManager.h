//
//  SNDBMigrationConfig.h
//  sohunews
//
//  Created by handy wang on 8/30/12.
//  Copyright (c) 2012 Sohu.com Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FmdbMigration.h"
#import "FmdbMigrationManager.h"

#define kMinAppVersionOfSupportingDBMigration                                           (@"3.1.2")

@protocol SNDBMigrationManagerDelegate

- (void)didSucceededToMigrate;

- (void)didFailedToMigrate;

@end


@interface SNDBMigrationManager : FmdbMigration {
    
    id __weak _delegate;

    NSArray *_versions;
    
    unsigned long _preDBVersionIndex;
    
    unsigned long _currentDBVersionIndex;
    
    NSString *_migratingVersion;

}

@property(nonatomic, weak)id delegate;

@property(nonatomic, strong)NSArray *versions;

+ (SNDBMigrationManager *)sharedInstance;

- (void)closeAppUsingDBIfNeeded;

- (NSString *)currentSqliteVersion;

- (BOOL)isLatestDBVersion;

- (void)backupSqliteFileInDocument;

- (BOOL)isSupportDBMigration;

- (BOOL)replaceSqliteFileInDocumentWithinBundle;

- (void)deleteBackupedSqliteFileInDocument;

- (void)recoverBackupSqliteFileInDocument;

- (void)migrateBaseOnSqliteFileInDocument;

- (void)migrateBaseOnSqliteFileInBunle;

/**
 * 注意：在开发环境下和OCUnit测试下这个目录位置是不一样的，所以这个方法里面会涉及到创建document目录。
 * 创建document主要是为OCUnitTest测试情况下本身没有document目录考虑的。
 * 开发环境下，形如：/Users/handywang/Library/Application Support/iPhone Simulator/5.1/Applications/10E03F5C-79B5-4F2D-91F2-CCA2556BD485/Documents
 * OCUnit测试环境下，形如：/Users/handywang/Library/Application Support/iPhone Simulator/5.1/Documents
 */
- (NSString *)sqliteDocumentPath;

- (NSString *)sqliteBackupDocumentPath;

/**
 * 由于开发环境和OCUnitTest环境下bundle路完全不一样，所以不能采用
 * [[[NSBundle bundleForClass:[self class]] resourcePath] stringByAppendingPathComponent:DB_FILE_NAME];
 * 方式来获取路径，而是采用一种通用的方式
 * [[[NSBundle bundleForClass:[self class]] resourcePath] stringByAppendingPathComponent:DB_FILE_NAME];
 * 来获取slqite文件的bundle路径；
 */
- (NSString *)sqliteFileBounlePath;

- (BOOL)updateVersionContext;

- (BOOL)isDatabaseCorrupted;

@end
