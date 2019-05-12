//
//  SNDBMigrationController.m
//  sohunews
//
//  Created by handy wang on 8/29/12.
//  Copyright (c) 2012 Sohu.com Inc. All rights reserved.
//

#import "SNDBMigrationController.h"
#import "SNAlert.h"


#define kRetryCountWhenMigrateFail                                      (2)


@implementation SNDBMigrationController

#pragma mark - Instance method implementation

- (id)init {

    if (self = [super init]) {
    
        retryCountWhenMigrateFail = 1;
        
    }
    
    return self;

}

+ (SNDBMigrationController *)sharedInstance {
    
    static SNDBMigrationController *_sharedInstance = nil;
    
    @synchronized(self) {
        
        if (!_sharedInstance) {
            
            _sharedInstance = [[SNDBMigrationController alloc] init];
            
        }
        
    }
    
    return _sharedInstance;
    
}


#pragma mark - Public methods implementations

- (void)migrate {
    
    [[SNDBMigrationManager sharedInstance] closeAppUsingDBIfNeeded];
    
    SNDebugLog(@"INFO: %@--%@, Ready to migrate database.", NSStringFromClass(self.class), NSStringFromSelector(_cmd));
    
    [[SNDBMigrationManager sharedInstance] setDelegate:self];
    
    if ([[SNDBMigrationManager sharedInstance] isLatestDBVersion]) {
    
        [self launchApp];
        
        return;
    
    }
    
//    [[SNDBMigrationManager sharedInstance] backupSqliteFileInDocument];
        
    if ([[SNDBMigrationManager sharedInstance] isSupportDBMigration]) {
        
        SNDebugLog(@"INFO: %@--%@, Ready to migrate because app supported db migration.",
                   NSStringFromClass(self.class), NSStringFromSelector(_cmd));
        
        [[SNDBMigrationManager sharedInstance] migrateBaseOnSqliteFileInDocument];
    
    }
    //不支持数据迁移说明程序升级前是3.1.2以前的版本；
    //那么需要把Document下的数据库文件删除并用bunle里的3.1.2版数据库文件copy到Document下并migrate到最新数据库版本；
    else {
        
        SNDebugLog(@"INFO: %@--%@, Ready to migrate sqlite file directly because app didnt support db migration.",
                   NSStringFromClass(self.class), NSStringFromSelector(_cmd));
        
        [[SNDBMigrationManager sharedInstance] migrateBaseOnSqliteFileInBunle];

    }

}

- (void)launchApp {

    //TODO:

}

#pragma mark - SNDBMigrationManagerDelegate

- (void)didSucceededToMigrate {
    
    //Migrate完成后才改UserDefaults里的版本号
        
    BOOL _result = [[SNDBMigrationManager sharedInstance] updateVersionContext];
    
    if (_result) {
        
        SNDebugLog(@"INFO: %@--%@, Succeeded to migrate database.", NSStringFromClass(self.class), NSStringFromSelector(_cmd));
        
//        [[SNDBMigrationManager sharedInstance] deleteBackupedSqliteFileInDocument];
        
        [self launchApp];
        
    } else {
        
        SNDebugLog(@"INFO: %@--%@, Failed to migrate version context even if upgrade database successfully.", NSStringFromClass(self.class), NSStringFromSelector(_cmd));
        
        [self didFailedToMigrate];
        
    }

}

- (void)didFailedToMigrate {
    
    if (retryCountWhenMigrateFail >= (kRetryCountWhenMigrateFail+1)) {

        //加上第一次数据库升级一共三次尝试都失败
        SNDebugLog(@"INFO: Failed to migrate database with 3 times, So give up.");
        SNActionSheet *commentActionSheet = [[SNActionSheet alloc] initWithTitle:NSLocalizedString(@"migrate_message_title", @"")
                                                                        delegate:self
                                                                       iconImage:[SNUtility chooseActDefaultIconImage]
                                                                         content:NSLocalizedString(@"migrate_message_quite_app", @"")
                                                                      actionType:SNActionSheetTypeDefault
                                                               cancelButtonTitle:NSLocalizedString(@"migrate_message_ok", @"")
                                                          destructiveButtonTitle:nil
                                                               otherButtonTitles:nil];
        
        [[TTNavigator navigator].window addSubview:commentActionSheet];
        [commentActionSheet showActionViewAnimation];
        return;
    }
    
    SNDebugLog(@"INFO: %@--%@, Failed to upgrade database and retry.", NSStringFromClass(self.class), NSStringFromSelector(_cmd));
    
    retryCountWhenMigrateFail++;
    
    [[SNDBMigrationManager sharedInstance] migrateBaseOnSqliteFileInBunle];

}

#pragma mark -
#pragma mark SNActionSheetDelegate

- (void)actionSheet:(SNActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    
    if (buttonIndex == 0) {
        exit(0);
	}
}


#pragma mark - UIAlertViewDelegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    
	if (buttonIndex == 0) {
        
        exit(0);
        
	}
    
}

#pragma mark - Private methods implementation

@end
