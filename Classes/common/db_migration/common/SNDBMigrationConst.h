//
//  SNDBMigrationConst.h
//  sohunews
//
//  Created by handy wang on 2/12/14.
//  Copyright (c) 2014 Sohu.com. All rights reserved.
//

#import <Foundation/Foundation.h>

#define DB_FILE_NAME_3_1_2                                                  (@"SohuNews_dont_touch_me_3.1.2.sqlite")
#define kMinSqliteVersionOfSupportingDBMigration                            (@"3_1_2")
#define kExportedDBFileDir                                                  (@"exported_db")
#define kExportedDBFileName                                                 (@"SohuNews.sqlite.exported")
#define kExportedDBFileAttributesDBVersion                                  (@"sqlitedb_version")

#define kMigrateUpToSelectorPrefix                                          (@"migrateUpTo")
#define kMigrateDownToSelectorPrefix                                        (@"migrateDownTo")