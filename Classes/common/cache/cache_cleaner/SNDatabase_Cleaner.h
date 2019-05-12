//
//  CacheMgr_Cleaner.h
//  sohunews
//
//  Created by handy on 9/10/12.
//  Copyright (c) 2012 Sohu.com Inc. All rights reserved.
//

#import "SNDatabase.h"

@interface SNDatabase(Cleaner)

- (void)cleanAllExpiredCache;

@end