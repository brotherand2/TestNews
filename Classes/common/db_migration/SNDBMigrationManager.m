//
//  SNDBMigrationConfig.m
//  sohunews
//
//  Created by handy wang on 8/30/12.
//  Copyright (c) 2012 Sohu.com Inc. All rights reserved.
//

#import "SNDBMigrationManager.h"
#import "SNDBMigrationConst.h"
#import "SNDBMigrationUtil.h"
#import <sqlite3.h>

@interface SNDBMigrationManager()

- (void)configurate;

- (void)dispatchToDelgate:(BOOL)result;

@property (nonatomic, strong)NSArray *groupedVersions;
@end


@implementation SNDBMigrationManager

@synthesize delegate = _delegate;
@synthesize versions = _versions;

#pragma mark - Lifecycle

- (id)init {
    
    if (self = [super init]) {
        
        [self configurate];
        
        _preDBVersionIndex = NSNotFound;
        
        _currentDBVersionIndex = NSNotFound;
        
        _groupedVersions = [SNDBMigrationUtil getGroupeddDBVersions];
        
        _versions = [SNDBMigrationUtil getExpandedGroupVersions];
        
        _migratingVersion = nil;
        
    }
    
    return self;
    
}

- (void)dealloc {
    

    _migratingVersion = nil;


}

#pragma mark - Public methods implementation

+ (SNDBMigrationManager *)sharedInstance {
    
    static SNDBMigrationManager *_sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedInstance = [[SNDBMigrationManager alloc] init];
    });
    
    return _sharedInstance;
    
}

- (void)closeAppUsingDBIfNeeded {
    @try {
        [[SNDatabase readQueue] close];
        [[SNDatabase writeQueue] close];
    }
    @catch (NSException *exception) {
    }
    @finally {
    }
}

- (BOOL)isLatestDBVersion {
    
    NSString *_preDBVersion = [SNUserDefaults objectForKey:kSqliteVersionKey];
    
    BOOL _isLatestDBVersion = (!!_preDBVersion && [[self currentSqliteVersion] isEqualToString:_preDBVersion]);
    return _isLatestDBVersion;
    
}

- (void)backupSqliteFileInDocument {
	NSString *_dbFilePathInDocuments = [self sqliteDocumentPath];
    
	NSString *_backupDBFilePathInDocuments = [self sqliteBackupDocumentPath];
    
    NSError *error = nil;
    
    NSFileManager *_fileManager = [NSFileManager defaultManager];
    
    if ([_fileManager fileExistsAtPath:_dbFilePathInDocuments]) {
        [_fileManager copyItemAtPath:_dbFilePathInDocuments toPath:_backupDBFilePathInDocuments error:&error];
    }
    
}

- (BOOL)isSupportDBMigration {
    
    NSString *_preDBVersion = [SNUserDefaults objectForKey:kSqliteVersionKey];
    
    NSString *_preAppVersion = [SNUserDefaults objectForKey:kVersion];
    
    //如查没有_preDBVersion，则判断是否是3.1.2，因为数据迁移功能计划是在3.1.2后的版本开始实施；
    if (!_preDBVersion) {
        
        if ([_preAppVersion isEqualToString:kMinAppVersionOfSupportingDBMigration]) {
            
            [SNUserDefaults setObject:kMinSqliteVersionOfSupportingDBMigration forKey:kSqliteVersionKey];
            
        } else {
            
            //此种情况表明：之前没有数据库版本历史且之前的App版本不是3.1.2,这说明升级之前的程序是3.1.2以前的程序；
            //所以不支持数据迁移；
            
            return NO;
            
        }
        
    }
    
    
    _preDBVersion = [SNUserDefaults objectForKey:kSqliteVersionKey];
    
    NSInteger _tmpPreDBVersionIndex = [_versions indexOfObject:_preDBVersion];
    
    NSInteger _tmpCurrentDBVersionIndex = [_versions indexOfObject:[self currentSqliteVersion]];
    
    if (_tmpPreDBVersionIndex >= _tmpCurrentDBVersionIndex) {
        
        return NO;
        
    } else {
        
        return YES;
        
    }
    
}

- (void)deleteBackupedSqliteFileInDocument {

//    SNDebugLog(@"INFO: %@--%@, Delete sqlite file......", NSStringFromClass(self.class), NSStringFromSelector(_cmd));
    
    NSFileManager *_fileManager = [NSFileManager defaultManager];
    
	NSString *_backupDBFilePathInDocuments = [self sqliteBackupDocumentPath];
    
    NSError *error = nil;
    
    if ([_fileManager fileExistsAtPath:_backupDBFilePathInDocuments]) {
        
        BOOL _result = [_fileManager removeItemAtPath:_backupDBFilePathInDocuments error:&error];
        
        if (!_result || !!error) {
            
//            SNDebugLog(@"INFO: %@--%@, Failed to delete backuped sqlite file with comming message:[%@]",
//                       NSStringFromClass(self.class), NSStringFromSelector(_cmd), [error description]);
            
        } else {
            
//            SNDebugLog(@"INFO: %@--%@, Succeeded to delete backuped sqlite file.", NSStringFromClass(self.class), NSStringFromSelector(_cmd));
            
        }
    
    }
    
}

- (void)recoverBackupSqliteFileInDocument {

//    SNDebugLog(@"INFO: %@--%@, Recover backuped sqlite file for retrying migration ......", NSStringFromClass(self.class), NSStringFromSelector(_cmd));
    
    NSFileManager *_fileManager = [NSFileManager defaultManager];
    
	NSString *_dbFilePathInDocuments = [self sqliteDocumentPath];
    
	NSString *_backupDBFilePathInDocuments = [self sqliteBackupDocumentPath];
    
    NSError *error = nil;
    
    if ([_fileManager fileExistsAtPath:_dbFilePathInDocuments]) {
    
        [_fileManager removeItemAtPath:_dbFilePathInDocuments error:&error];
        
    }
    
    if ([_fileManager fileExistsAtPath:_backupDBFilePathInDocuments]) {
        
        [_fileManager copyItemAtPath:_backupDBFilePathInDocuments toPath:_dbFilePathInDocuments error:&error];
    
    }
    
    [self deleteBackupedSqliteFileInDocument];

}

- (void)migrateBaseOnSqliteFileInDocument {
    
    BOOL _upgradeSuccessfully = YES;
    
    _preDBVersionIndex = [_versions indexOfObject:[SNUserDefaults objectForKey:kSqliteVersionKey]];
    
    _currentDBVersionIndex = [_versions indexOfObject:[self currentSqliteVersion]];
    if (_preDBVersionIndex + 1 > [_versions count]) {
        return;
    }
    NSArray *_migratedVersions = [_versions subarrayWithRange:NSMakeRange(_preDBVersionIndex+1, (_currentDBVersionIndex-_preDBVersionIndex))];
    
    for (NSString *_migratedVersion in _migratedVersions) {
        
        _migratingVersion = [_migratedVersion copy];
        
        NSString *_dbFilePathInDocument = [self sqliteDocumentPath];
        
//        SNDebugLog(@"INFO: %@--%@, Migrating with db [%@]......", NSStringFromClass(self.class), NSStringFromSelector(_cmd), _dbFilePathInDocument);
        
        FmdbMigrationManager *_fmdbMigrationManager = [FmdbMigrationManager executeForDatabasePath:_dbFilePathInDocument
                                                                                    withMigrations:[NSArray arrayWithObject:self]];
//        SNDebugLog(@"INFO: %@--%@, fmdbMigrationManager is [%@]",
//                   NSStringFromClass(self.class), NSStringFromSelector(_cmd), _fmdbMigrationManager);
        
        _upgradeSuccessfully = !!_fmdbMigrationManager;
        
        //某版本升级失败;
        //目前：只要某版本升级失败则宣告此次数据库迁移失败，但在DBMigrationController里会从3.1.2版本数据库再重试两次；
        //TODO:根据升级成功的上一次数据库版本进行重试续迁移([self recoverBackupSqliteFileInDocument])，
        //如果重试两次还是失败那么跳出循环宣告整个数据库迁移失败；
        if (!_upgradeSuccessfully) {
            
//            SNDebugLog(@"INFO: %@--%@, Failed to migrate for version [%@]",
//                       NSStringFromClass(self.class), NSStringFromSelector(_cmd), _migratedVersion);
            
             //(_migratingVersion);
            
            break;
            
        } else {
        
            //TODO:迁移成功一个数据库版本就备份迁移成功的这个数据库版本，预防在迁移接下来的版本时失败后，还要从3.1.2版本重新向上迁移；
            
            //1）数据库版本号更新为迁移成功这次；
//            [[NSUserDefaults standardUserDefaults] setObject:_migratingVersion forKey:kSqliteVersionKey];
//            [[NSUserDefaults standardUserDefaults] synchronize];
            //2）删除上一次备份的数据库文件；
//            [self deleteBackupedSqliteFileInDocument];
            //3）备份迁移成功的在document目录下的数据库文件；
//            [self backupSqliteFileInDocument];
            
        }
        
    }
    
    if (_upgradeSuccessfully) {
        
//        SNDebugLog(@"INFO: %@--%@, Succeeded to migrate.", NSStringFromClass(self.class), NSStringFromSelector(_cmd));
        
    }

    [self dispatchToDelgate:_upgradeSuccessfully];
    
}

- (void)migrateBaseOnSqliteFileInBunle {
    //从bundle里已导出的比3.1.2版本高的数据库升级
    BOOL canMigrateFromExportedDBFile = [self migrateFromPenultimateDBLargeVersion];
    if (canMigrateFromExportedDBFile) {
        return;
    }
    
    //从bundle里的3.1.2版本升级
    if ([self replaceSqliteFileInDocumentWithinBundle]) {
        
        //既然已成功的把3.1.2的数据库拷到document下，那么这时的情况就已经和3.1.2版程序升级是一个意思；
        //所以下面fake了3.1.2程序的数据库升级到最新程序时的环境；
        //---Begin
        [SNUserDefaults setObject:kMinSqliteVersionOfSupportingDBMigration forKey:kSqliteVersionKey];
        //---End
        
        [self migrateBaseOnSqliteFileInDocument];
        
    } else {
    
        [self dispatchToDelgate:NO];
        
    }
    
}

- (BOOL)migrateFromPenultimateDBLargeVersion {
    NSString *exportedDBVersionInBundle = [SNDBMigrationUtil getExportedDBFileVersionInBundle];
    if (exportedDBVersionInBundle.length > 0) {
        NSString *exportedDBFilePathInBundle = [SNDBMigrationUtil getExportedDBFilePathInBundle];
        NSString *sqliteDocumentPath = [[SNDBMigrationManager sharedInstance] sqliteDocumentPath];
        
        NSError *error = nil;
        BOOL rstOfRemoving = NO;
        BOOL isDir;
        if ([[NSFileManager defaultManager] fileExistsAtPath:sqliteDocumentPath isDirectory:&isDir]) {
            [self closeAppUsingDBIfNeeded];
            rstOfRemoving = [[NSFileManager defaultManager] removeItemAtPath:sqliteDocumentPath error:&error];
        }
        if (rstOfRemoving && !error) {
            BOOL rst = [[NSFileManager defaultManager] copyItemAtPath:exportedDBFilePathInBundle toPath:sqliteDocumentPath error:&error];
            if (rst && !error) {
                SNDebugLog(@"Migrating from exported db file from db version %@.", exportedDBVersionInBundle);
                [SNUserDefaults setObject:exportedDBVersionInBundle forKey:kSqliteVersionKey];
                [[SNDBMigrationManager sharedInstance] migrateBaseOnSqliteFileInDocument];
                return YES;
            }
        }
    }
    return NO;
}

/**
 * 注意：在开发环境下和OCUnit测试下这个目录位置是不一样的，所以这个方法里面会涉及到创建document目录。
 * 创建document主要是为OCUnitTest测试情况下本身没有document目录考虑的。
 * 开发环境下，形如：/Users/handywang/Library/Application Support/iPhone Simulator/5.1/Applications/10E03F5C-79B5-4F2D-91F2-CCA2556BD485/Documents
 * OCUnit测试环境下，形如：/Users/handywang/Library/Application Support/iPhone Simulator/5.1/Documents
 */
- (NSString *)sqliteDocumentPath {
    
//    SNDebugLog(@"INFO: %@--%@, Getting sqlite file path in document......", NSStringFromClass(self.class), NSStringFromSelector(_cmd));
    
    NSFileManager *_fileManager = [NSFileManager defaultManager];
    
    NSArray *_paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    
	NSString *_documentsDirectory = [_paths objectAtIndex:0];
    
    NSError *error = nil;
    
    BOOL _result = NO;
    
    if (![_fileManager fileExistsAtPath:_documentsDirectory]) {
        
        _result = [_fileManager createDirectoryAtPath:_documentsDirectory withIntermediateDirectories:YES attributes:nil error:&error];
        
    } else {
        
        _result = YES;
        
    }
    
    if (_result) {
        
        NSString *_dbFilePathInDocuments = [_documentsDirectory stringByAppendingPathComponent:DB_FILE_NAME];
        
//        SNDebugLog(@"INFO: %@--%@, Got sqlite file path in docuemnt:[%@]", NSStringFromClass(self.class), NSStringFromSelector(_cmd), _dbFilePathInDocuments);
        
        return 	_dbFilePathInDocuments;
        
    } else {
        
//        SNDebugLog(@"INFO: %@--%@, Failed to get sqlite file path in document.", NSStringFromClass(self.class), NSStringFromSelector(_cmd));
        
        return nil;
        
    }
    
}

- (NSString *)sqliteBackupDocumentPath {
    
//    SNDebugLog(@"INFO: %@--%@, Getting sqlite backup file path in document......", NSStringFromClass(self.class), NSStringFromSelector(_cmd));
    
    NSFileManager *_fileManager = [NSFileManager defaultManager];
    
    NSArray *_paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    
	NSString *_documentsDirectory = [_paths objectAtIndex:0];
    
    NSError *error = nil;
    
    BOOL _result = NO;
    
    if (![_fileManager fileExistsAtPath:_documentsDirectory]) {
        
        _result = [_fileManager createDirectoryAtPath:_documentsDirectory withIntermediateDirectories:YES attributes:nil error:&error];
        
    } else {
        
        _result = YES;
        
    }
    
    if (_result) {
        
        NSString *_dbFilePathInDocuments = [_documentsDirectory stringByAppendingPathComponent:DB_FILE_NAME_FOR_BACKUP];
        
//        SNDebugLog(@"INFO: %@--%@, Got sqlite backup file path in docuemnt:[%@]", NSStringFromClass(self.class), NSStringFromSelector(_cmd), _dbFilePathInDocuments);
        
        return 	_dbFilePathInDocuments;
        
    } else {
        
//        SNDebugLog(@"INFO: %@--%@, Failed to get sqlite backup file path in document.", NSStringFromClass(self.class), NSStringFromSelector(_cmd));
        
        return nil;
        
    }
    
}

/**
 * 由于开发环境和OCUnitTest环境下bundle路完全不一样，所以不能采用
 * [[[NSBundle bundleForClass:[self class]] resourcePath] stringByAppendingPathComponent:DB_FILE_NAME];
 * 方式来获取路径，而是采用一种通用的方式
 * [[[NSBundle bundleForClass:[self class]] resourcePath] stringByAppendingPathComponent:DB_FILE_NAME];
 * 来获取slqite文件的bundle路径；
 */
- (NSString *)sqliteFileBounlePath {
    
//    SNDebugLog(@"INFO: %@--%@, Getting sqlite file path in bundle......", NSStringFromClass(self.class), NSStringFromSelector(_cmd));
    
    NSString *_sqliteFileBounlePath = [[[NSBundle bundleForClass:[self class]] resourcePath] stringByAppendingPathComponent:DB_FILE_NAME_3_1_2];
    
    if (!!_sqliteFileBounlePath && ![@"" isEqualToString:_sqliteFileBounlePath]) {
        
//        SNDebugLog(@"INFO: %@--%@, Got sqlite file path:[%@]", NSStringFromClass(self.class), NSStringFromSelector(_cmd), _sqliteFileBounlePath);
        
    } else {
        
//        SNDebugLog(@"INFO: %@--%@, Failed to get sqlite file path in boundle.", NSStringFromClass(self.class), NSStringFromSelector(_cmd));
        
    }
    
    return _sqliteFileBounlePath;
    
}

- (BOOL)updateVersionContext {
    [SNUserDefaults setObject:[self currentSqliteVersion] forKey:kSqliteVersionKey];
    return YES;
}

- (BOOL)isDatabaseCorrupted {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *path = [documentsDirectory stringByAppendingPathComponent:DB_FILE_NAME];
    BOOL bResult = FALSE;
    
    if ([[NSFileManager defaultManager] fileExistsAtPath:path]) {
        sqlite3 *database = nil;
        int err = sqlite3_open([path UTF8String], &database);
        if (err != SQLITE_OK) {
            SNDebugLog(@"error opening DB: %d", err);
            return YES;
        }
        
        //NSString *sqlRaw = @"PRAGMA integrity_check;";
        //NSString *sqlRaw = @"PRAGMA quick_check;";
        
        char *errorMsg = nil;
        if (sqlite3_exec(database, "PRAGMA quick_check;", NULL, NULL, &errorMsg) != SQLITE_OK) {
            SNDebugLog(@"Failed quick_check: %s", errorMsg);
            bResult = YES;
        }
        
        sqlite3_close(database);
    }
    else {
        bResult = NO;
    }
    
    return bResult;
}


#pragma mark - Private methods implementation

- (void)configurate {
    
    //Do nothing temporarily.
    
}

- (NSString *)currentSqliteVersion {

    return [_versions lastObject];

}

- (BOOL)replaceSqliteFileInDocumentWithinBundle {
    
//    SNDebugLog(@"INFO: %@--%@, Ready to upgrade sqlite file.",
//               NSStringFromClass(self.class), NSStringFromSelector(_cmd));
    
    NSFileManager *_fileManager = [NSFileManager defaultManager];
    
    NSError *error = nil;
    
	NSString *_dbFilePathInDocuments = [self sqliteDocumentPath];
    
    //删除旧数据库文件
    if ([_fileManager fileExistsAtPath:_dbFilePathInDocuments]) {
        
        [self closeAppUsingDBIfNeeded];

        BOOL _result = [_fileManager removeItemAtPath:_dbFilePathInDocuments error:&error];
        
        if (!_result || !!error) {
            
//            SNDebugLog(@"INFO: %@--%@, Failed to delete old database file with comming message:[%@]",
//                       NSStringFromClass(self.class), NSStringFromSelector(_cmd), [error description]);
            
            return NO;
            
        } else {
            
//            SNDebugLog(@"INFO: %@--%@, Succeeded to delete old database file.", NSStringFromClass(self.class), NSStringFromSelector(_cmd));
            
        }
        
    }
    
    //复制新数据库文件
    NSString *_dbFilePathInBundle = [self sqliteFileBounlePath];
    
    error = nil;
    
//    SNDebugLog(@"INFO: %@--%@, dbFilePathInBundle is [%@]", NSStringFromClass(self.class), NSStringFromSelector(_cmd), _dbFilePathInBundle);
    
//    SNDebugLog(@"INFO: %@--%@, dbFilePathInDocuments is [%@]", NSStringFromClass(self.class), NSStringFromSelector(_cmd), _dbFilePathInDocuments);
    
    BOOL _result = [_fileManager copyItemAtPath:_dbFilePathInBundle toPath:_dbFilePathInDocuments error:&error];
    
    if (!_result || error) {
        
//        SNDebugLog(@"INFO: %@--%@, Failed to replace sqlite file directly with comming message:[%@]",
//                   NSStringFromClass(self.class), NSStringFromSelector(_cmd), [error description]);
        
        return NO;
        
    } else {
        
//        SNDebugLog(@"INFO: %@--%@, Succeeded to replace sqlite file directly.", NSStringFromClass(self.class), NSStringFromSelector(_cmd));
        
        return YES;
        
    }

}

- (void)dispatchToDelgate:(BOOL)result {
    
    if (result) {
        
        if ([_delegate respondsToSelector:@selector(didSucceededToMigrate)]) {
            
            [_delegate didSucceededToMigrate];
            
        }
        
    } else {
        
        if ([_delegate respondsToSelector:@selector(didFailedToMigrate)]) {
            
            [_delegate didFailedToMigrate];
            
        }
        
    }

}

//Override; Do migrate really.

- (void)up {
    
    SEL _migratingSelector = NSSelectorFromString([kMigrateUpToSelectorPrefix stringByAppendingString:_migratingVersion]);
    
//    BOOL _rst = [self respondsToSelector:_migratingSelector];
    
//    SNDebugLog(@"INFO: %@--%@, %@ responds to selector [%@]",
//               NSStringFromClass(self.class), NSStringFromSelector(_cmd), (_rst ? @"Can" : @"Can't"), NSStringFromSelector(_migratingSelector));
    
    if ([self respondsToSelector:_migratingSelector]) {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
        [self performSelector:_migratingSelector];
#pragma clang diagnostic pop
    }
    
     //(_migratingVersion);

}

@end
