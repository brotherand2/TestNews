//
//  SNDatabase+ReadFlag.h
//  sohunews
//
//  Created by guoyalun on 7/5/13.
//  Copyright (c) 2013 Sohu.com. All rights reserved.
//

#import "SNDatabase.h"

@interface SNDatabase (ReadFlag)

- (void)saveLink2:(NSString *)link2 read:(BOOL)flag;
- (BOOL)readFlagForLink2:(NSString *)link2;
- (BOOL)removeAllLink2;
@end
