//
//  SNTimeLineTrendModel.h
//  sohunews
//
//  Created by jialei on 13-12-9.
//  Copyright (c) 2013年 Sohu.com. All rights reserved.
//

#import "SNTimelineCircleModel.h"

@interface SNTimeLineTrendModel : SNTimelineCircleModel

@property (nonatomic, retain)NSString *actId;
@property (nonatomic, retain)NSMutableArray *commentObjects;
@property (nonatomic, retain)SNTimelineTrendItem *detailItem;
@property(nonatomic,assign) NSString *commentPreCursor;
@property(nonatomic,assign) NSString *commentNextCursor;

+ (SNTimeLineTrendModel *)modelForUserWithPid:(NSString *)pid;
+ (SNTimeLineTrendModel *)modelForDetailWithActId:(NSString *)actId;
- (void)timelineDetailRefresh;
- (void)timelineDetailGetMore:(NSString *)nextCommentCursor;

@end
