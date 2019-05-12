//
//  SNDBMigrationManager_v360.h
//  sohunews
//
//  Created by Dan Cong on 9/11/13.
//  Copyright (c) 2013 Sohu.com. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FmdbMigration.h"

@interface FmdbMigration(v360)

//添加正文的自媒体管理属性：action，isPublished，editNewsLink
- (void)migrateUpTo3_6_0_1;

// sub obj 增加两个属性 showComment/showRecmSub
- (void)migrateUpTo3_6_0_2;

//添加正文的自媒体管理属性：operators
- (void)migrateUpTo3_6_0_3;

@end
