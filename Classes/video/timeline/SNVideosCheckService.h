//
//  SNVideosCheckService.h
//  sohunews
//
//  Created by chenhong on 13-10-29.
//  Copyright (c) 2013年 Sohu.com. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SNVideosCheckService : NSObject

+ (SNVideosCheckService *)sharedInstance;
- (void)start;
- (void)restart;
- (void)delayTheCheck;
- (void)checkIfNeeded;
- (void)stop;

- (BOOL)autoPlayTimelineVideos;
- (BOOL)canTimelineToDetailPage;
@end
