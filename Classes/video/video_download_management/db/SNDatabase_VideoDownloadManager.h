//
//  SNDatabase_VideoDownloadManager.h
//  sohunews
//
//  Created by handy wang on 9/22/13.
//  Copyright (c) 2013 Sohu.com. All rights reserved.
//

#import "SNDatabase.h"
#import "SNVideoDownloadManager.h"
#import "SNM3U8SegmentInfo.h"
#import "SNVideoObjects.h"

@interface SNDatabase(VideoDownloadManager)

#pragma mark - /////////////////////About video/////////////////////
#pragma mark - Save
- (BOOL)saveADownloadVideo:(SNVideoDataDownload *)video;

#pragma mark - Update
- (BOOL)updateADownloadedVideo:(NSDictionary *)data byVid:(NSString *)vid;

#pragma mark - Delete
- (BOOL)deleteDownloadedVideosIn:(NSArray *)toBeDeletedItems;
- (BOOL)deleteADownloadedVideo:(NSString *)videoID;


#pragma mark - Query
- (NSArray *)queryAllDownloadVideosExcludingSuccessfulAndCanceled;
- (NSArray *)queryAllDownloadedVideos;
- (SNVideoDataDownload *)queryDownloadVideoByVID:(NSString *)vid;

#pragma mark - /////////////////////About segments/////////////////////
#pragma mark - Save
- (BOOL)saveAVideoSegment:(SNSegmentInfo *)segment;
- (BOOL)saveVideoSegments:(NSArray *)segments;

#pragma mark - Update
- (BOOL)updateVideoSegment:(NSDictionary *)data byVid:(NSString *)vid andSegmentOrder:(NSInteger)segmentOrder;
- (BOOL)updateAllSegmentsState:(SNVideoDownloadState)state byVid:vid excludingStates:(NSArray *)states;

#pragma mark - Delete
- (BOOL)deleteSegmentsByVid:(NSString *)vid;

#pragma mark - Query
- (NSArray *)queryVideoSegmentsByVID:(NSString *)vid;
- (CGFloat)queryVideoSegmentsTotalBytes:(NSString *)vid;
@end