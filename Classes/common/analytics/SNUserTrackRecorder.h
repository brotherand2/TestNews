//
//  SNUserTrackRecorder.h
//  sohunews
//
//  Created by jojo on 13-12-25.
//  Copyright (c) 2013年 Sohu.com. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SNUserTrack.h"
#import "SNAnalyticsConsts.h"

/*
 * push --> loading --> tab --> detail
 * loading --> tab --> detail
 * tab --> detail
 */

@interface SNUserTrackRecorder : NSObject

@property (nonatomic, strong) SNUserTrack *pushPage;
@property (nonatomic, strong) SNUserTrack *loadingPage;

+ (SNUserTrackRecorder *)sharedRecorder;
- (NSMutableArray *)tracksWithViewControllers:(NSArray *)controllers;

- (BOOL)shouldReportTrackForObj:(id)obj;
- (void)cacheAlreadyReportedTrackForObj:(id)obj;
- (void)clearCachedTrackInfoForObj:(id)obj;

@end

@interface UIViewController (userTracks)

// 触发pv统计 不会重复发送
- (BOOL)reportPVAnalyzeWithCurrentNavigationController:(SNNavigationController *)navi dictInfo:(NSDictionary*)dictInfo;
- (BOOL)reportPVAnalyzeWithCurrentNavigationController:(SNNavigationController *)navi;

- (SNCCPVPage)currentPage;
- (NSString *)currentOpenLink2Url;

@end

@interface NSArray (userTracks)

- (NSString *)toTracksString;

@end
