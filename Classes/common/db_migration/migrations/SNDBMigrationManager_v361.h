//
//  SNDBMigrationManager_v361.h
//  sohunews
//
//  Created by Dan Cong on 10/21/13.
//  Copyright (c) 2013 Sohu.com. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FmdbMigration.h"

@interface FmdbMigration(v361)

//添加正文的自媒体管理属性：action，isPublished，editNewsLink
- (void)migrateUpTo3_6_1_1;

@end
