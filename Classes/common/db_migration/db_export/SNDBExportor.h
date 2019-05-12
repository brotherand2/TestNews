//
//  SNDBExportor.h
//  sohunews
//
//  Created by handy wang on 2/12/14.
//  Copyright (c) 2014 Sohu.com. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SNDBMigrationConst.h"
#import "SNDBMigrationUtil.h"
#import "SNDBExportorMigration.h"
#import "FmdbMigrationManager.h"

@interface SNDBExportor : NSObject

+ (SNDBExportor *)sharedInstance;
- (void)exportDB;

@end