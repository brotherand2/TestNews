//
//  SNM3U8VideoDownloadRequest.h
//  sohunews
//
//  Created by handy wang on 9/4/13.
//  Copyright (c) 2013 Sohu.com. All rights reserved.
//

#import "SNVideoDownloadRequest.h"

@interface SNM3U8VideoDownloadRequest : SNVideoDownloadRequest
@property (nonatomic, weak)id             callback;

- (void)clearAllSegmentRequests;
@end
