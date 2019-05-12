//
//  SNDatabase_ShareList.h
//  sohunews
//
//  Created by yanchen wang on 12-5-28.
//  Copyright (c) 2012年 Sohu.com Inc. All rights reserved.
//



#import "SNDatabase.h"

@interface SNDatabase(ShareList)

- (NSArray *)shareList;
- (BOOL)setShareList:(NSArray *)items;

@end
