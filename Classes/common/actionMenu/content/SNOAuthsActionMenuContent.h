//
//  SNOAuthsActionMenuContent.h
//  sohunews
//
//  Created by Dan Cong on 12/10/13.
//  Copyright (c) 2013 Sohu.com. All rights reserved.
//

#import "SNActionMenuContent.h"
#import "SNDatabase_ReadCircle.h"

@interface SNOAuthsActionMenuContent : SNActionMenuContent <SNShareManagerDelegate>

@property(nonatomic, strong)NSMutableDictionary *dic;

@property(nonatomic, strong)NSString *userName;
@property(nonatomic, strong)NSString *targetName;
@property(nonatomic, strong)NSString *shareUGCComment;
@property(nonatomic, strong)NSString *shareLogSubId;

- (void)appendShareReadObjectByTimelineType:(SNTimelineContentType)timelineType contentId:(NSString *)contentId;
- (void)useShareContentAsContent;

@end
