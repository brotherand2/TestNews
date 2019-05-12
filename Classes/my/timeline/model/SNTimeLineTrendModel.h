//
//  SNTimeLineTrendModel.h
//  sohunews
//
//  Created by jialei on 13-12-9.
//  Copyright (c) 2013年 Sohu.com. All rights reserved.
//

#import "SNTimelineCircleModel.h"

@interface SNTimeLineTrendModel : SNTimelineCircleModel

@property (nonatomic, strong)NSString *actId;
@property (nonatomic, strong)NSMutableArray *commentObjects;
@property (nonatomic, strong)SNTimelineTrendItem *detailItem;
@property(nonatomic,weak) NSString *commentPreCursor;
@property(nonatomic,weak) NSString *commentNextCursor;

+ (SNTimeLineTrendModel *)modelForUserWithPid:(NSString *)pid;
+ (SNTimeLineTrendModel *)modelForDetailWithActId:(NSString *)actId;
- (void)timelineDetailRefresh;
- (void)timelineDetailGetMore:(NSString *)nextCommentCursor;

@end
