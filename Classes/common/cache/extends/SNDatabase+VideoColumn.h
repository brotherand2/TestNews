//
//  SNDatabase+VideoColumn.h
//  sohunews
//
//  Created by jojo on 13-10-30.
//  Copyright (c) 2013年 Sohu.com. All rights reserved.
//

#import "SNDatabase.h"

@interface SNDatabase (VideoColumn)

- (BOOL)setVideoColumns:(NSArray *)columns;

- (BOOL)setVideoColumnSubed:(BOOL)subed byColumnId:(NSString *)columnId;
- (BOOL)setVideoColumnReadCount:(NSString *)count byColumnId:(NSString *)columnId;

- (NSArray *)getVideoColumnsByColumnId:(NSString *)columnId;

- (BOOL)clearAllVideoColumns;

@end
