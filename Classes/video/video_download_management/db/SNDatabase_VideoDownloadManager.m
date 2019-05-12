//
//  SNDatabase_VideoDownloadManager.m
//  sohunews
//
//  Created by handy wang on 9/22/13.
//  Copyright (c) 2013 Sohu.com. All rights reserved.
//

#import "SNDatabase_VideoDownloadManager.h"
#import "SNDatabase_Private.h"

@implementation SNDatabase(VideoDownloadManager)

#pragma mark - /////////////////////About video/////////////////////
#pragma mark - Save
- (BOOL)saveADownloadVideo:(SNVideoDataDownload *)video {
	__block BOOL bSucceed = YES;
    [[SNDatabase writeQueue] inTransaction:^(FMDatabase *db, BOOL *rollback) {
        [db executeUpdate:@"INSERT INTO tbVideosDownload(id, vid, title, poster, videoSources, downloadURL, videoType, localRelativePath, localM3U8URL, state, beginDownloadTimeInterval, finishDownloadTimeInterval) VALUES(NULL, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)",
         video.vid,
         video.title,
         video.poster,
         video.videoSources,
         video.downloadURL,
         video.videoType,
         video.localRelativePath,
         video.localM3U8URL,
         [NSNumber numberWithInt:video.state],
         [NSNumber numberWithDouble:video.beginDownloadTimeInterval],
         [NSNumber numberWithDouble:video.finishDownloadTimeInterval]
         ];
        
        if ([db hadError]) {
            SNDebugLog(@"saveADownloadVideo : error :%d,%@",[db lastErrorCode],[db lastErrorMessage]);
            *rollback = YES;
            bSucceed = NO;
        }
        else {
            bSucceed = YES;
        }
    }];
    return bSucceed;
}

#pragma mark - Update
- (BOOL)updateADownloadedVideo:(NSDictionary *)data byVid:(NSString *)vid {
	if (data.count <= 0 || vid.length <= 0) {
		SNDebugLog(@"Failed to updateADownloadedVideoByVid, because of invalid data.");
		return NO;
	}
    
    __block BOOL updateSuccess = NO;
    [[SNDatabase writeQueue] inDatabase:^(FMDatabase *db) {
        NSDictionary *updateSetStatementsInfo = [self formatUpdateSetStatementsInfoFromValuePairs:data ignoreNilValue:NO];
        if ([updateSetStatementsInfo count] == 0) {
            updateSuccess = NO;
        }
        else {
            NSString *setStatement			= [updateSetStatementsInfo objectForKey:UPDATE_SETSTATEMNT];
            NSMutableArray *valueArguments	= [updateSetStatementsInfo objectForKey:UPDATE_SETARGUMENTS];
            NSString *updateStatements		= [NSString stringWithFormat:@"UPDATE %@ %@ WHERE %@=?",
                                               TB_VIDEOS_DOWNLOAD, setStatement, TB_VIDEOS_DOWNLOAD_VID];
            [valueArguments addObject:vid];
            
            [db executeUpdate:updateStatements withArgumentsInArray:valueArguments];
            if ([db hadError]) {
                SNDebugLog(@"Failed to updateADownloadedVideoByVid %@, with coming message: error :%d, %@",
                           vid, [db lastErrorCode],[db lastErrorMessage]);
                updateSuccess = NO;
            }
            else {
                updateSuccess = YES;
            }
        }
    }];
	return updateSuccess;
}

#pragma mark - Delete
- (BOOL)deleteDownloadedVideosIn:(NSArray *)toBeDeletedItems {
    if (toBeDeletedItems.count <= 0) {
        return NO;
    }
    
	__block BOOL bSucceed = YES;
    [[SNDatabase writeQueue] inTransaction:^(FMDatabase *db, BOOL *rollback) {
        NSMutableArray *_vidArray = [NSMutableArray array];
        for (SNVideoDataDownload *_model in toBeDeletedItems) {
            if (_model.vid.length > 0) {
                [_vidArray addObject:_model.vid];
            }
        }
        
        NSString *_inCondition = [_vidArray componentsJoinedByString:@","];
        NSString *_sql = [NSString stringWithFormat:@"DELETE FROM tbVideosDownload where vid in (%@)", _inCondition];
        [db executeUpdate:_sql];
        
        if ([db hadError]) {
            SNDebugLog(@"deleteDownloadedVideosByVIDArray : error :%d,%@",[db lastErrorCode],[db lastErrorMessage]);
            *rollback = YES;
            bSucceed = NO;
        }
        else {
            bSucceed = YES;
        }
    }];
    return bSucceed;
}

- (BOOL)deleteADownloadedVideo:(NSString *)videoID {
	__block BOOL bSucceed = YES;
    [[SNDatabase writeQueue] inTransaction:^(FMDatabase *db, BOOL *rollback) {
        [db executeUpdate:@"DELETE FROM tbVideosDownload where vid=?", videoID];
       
        if ([db hadError]) {
            SNDebugLog(@"deleteADownloadedVideo : error :%d,%@",[db lastErrorCode],[db lastErrorMessage]);
            *rollback = YES;
            bSucceed = NO;
        }
        else {
            bSucceed = YES;
        }
    }];
    return bSucceed;
}

#pragma mark - Query
- (NSArray *)queryAllDownloadVideosExcludingSuccessfulAndCanceled {
    __block NSArray *_videos = nil;
    [[SNDatabase readQueue] inDatabase:^(FMDatabase *db) {
        NSString *_inCondiction = [NSString stringWithFormat:@"(%d, %d, %d, %d)",
                                   SNVideoDownloadState_Waiting,
                                   SNVideoDownloadState_Downloading,
                                   SNVideoDownloadState_Pause,
                                   SNVideoDownloadState_Failed];
        NSString *_sql = [NSString stringWithFormat:@"SELECT * FROM tbVideosDownload where state in %@ order by beginDownloadTimeInterval asc",
                          _inCondiction];
        FMResultSet *rs = [db executeQuery:_sql];
        if ([db hadError]) {
            SNDebugLog(@"queryVideosInDownloadingView : error :%d,%@",[db lastErrorCode],[db lastErrorMessage]);
        }
        else {
            _videos = [self getObjects:[SNVideoDataDownload class] fromResultSet:rs];
        }
    }];
    return _videos;
}

- (NSArray *)queryAllDownloadedVideos {
    __block NSArray *_allDownloadedVideos = nil;
    [[SNDatabase readQueue] inDatabase:^(FMDatabase *db) {
        FMResultSet *rs = [db executeQuery:@"SELECT * FROM tbVideosDownload where state=? order by finishDownloadTimeInterval desc",
                           [NSNumber numberWithInt:SNVideoDownloadState_Successful]];
        if ([db hadError]) {
            SNDebugLog(@"queryAllDownloadedVideos : error :%d,%@",[db lastErrorCode],[db lastErrorMessage]);
        }
        else {
            _allDownloadedVideos = [self getObjects:[SNVideoDataDownload class] fromResultSet:rs];
        }
    }];
    return _allDownloadedVideos;
}

- (SNVideoDataDownload *)queryDownloadVideoByVID:(NSString *)vid {
    __block SNVideoDataDownload *_model = nil;
    [[SNDatabase readQueue] inDatabase:^(FMDatabase *db) {
        FMResultSet *rs = [db executeQuery:@"SELECT * FROM tbVideosDownload where vid=?", vid];
        if ([db hadError]) {
            SNDebugLog(@"queryDownloadVideoByVID : error :%d,%@",[db lastErrorCode],[db lastErrorMessage]);
        }
        else {
            _model = [self getFirstObject:[SNVideoDataDownload class] fromResultSet:rs];
        }
    }];
    return _model;
}


#pragma mark - /////////////////////About segments/////////////////////
#pragma mark - Save
- (BOOL)saveAVideoSegment:(SNSegmentInfo *)segment {
    __block BOOL success = NO;
    [[SNDatabase writeQueue] inTransaction:^(FMDatabase *db, BOOL *rollback) {
        success = [self saveAVideoSegment:segment inDB:db];
        if (!success) {
            *rollback = YES;
            SNDebugLog(@"Failed to saveAVideoSegment");
        }
    }];
    return success;
}

- (BOOL)saveVideoSegments:(NSArray *)segments {
    __block BOOL success = NO;
    [[SNDatabase writeQueue] inTransaction:^(FMDatabase *db, BOOL *rollback) {
        for (SNM3U8SegmentInfo *_segment in segments) {
            success = [self saveAVideoSegment:_segment inDB:db];
            if (!success) {
                *rollback = YES;
                SNDebugLog(@"Failed to saveVideoSegments");
                break;
            }
        }
    }];
    return success;
}

- (BOOL)saveAVideoSegment:(SNSegmentInfo *)segment inDB:(FMDatabase *)db {
    BOOL success = NO;
    
    [db executeUpdate:@"INSERT INTO tbVideosDownload_segments(id, segmentOrder, urlString, duration, downloadBytes, totalBytes, state, videoType, vid) VALUES(NULL, ?, ?, ?, ?, ?, ?, ?, ?)",
     [NSNumber numberWithInteger:segment.segmentOrder],
     segment.urlString,
     [NSNumber numberWithInteger:segment.duration],
     [NSNumber numberWithFloat:segment.downloadBytes],
     [NSNumber numberWithFloat:segment.totalBytes],
     [NSNumber numberWithInt:segment.state],
     segment.videoType,
     segment.vid
     ];
    
    if ([db hadError]) {
        SNDebugLog(@"Failed to saveAVideoSegment:inDB : error :%d,%@",[db lastErrorCode],[db lastErrorMessage]);
        success = NO;
    }
    else {
        success = YES;
    }
    return success;
}

#pragma mark - Update
- (BOOL)updateVideoSegment:(NSDictionary *)data byVid:(NSString *)vid andSegmentOrder:(NSInteger)segmentOrder {
	if (data.count <= 0 || vid.length <= 0) {
		SNDebugLog(@"Failed to updateVideoSegmentByVid, because of invalid data.");
		return NO;
	}
    
    __block BOOL updateSuccess = NO;
    [[SNDatabase writeQueue] inDatabase:^(FMDatabase *db) {
        NSDictionary *updateSetStatementsInfo = [self formatUpdateSetStatementsInfoFromValuePairs:data ignoreNilValue:NO];
        if ([updateSetStatementsInfo count] == 0) {
            updateSuccess = NO;
        }
        else {
            NSString *setStatement			= [updateSetStatementsInfo objectForKey:UPDATE_SETSTATEMNT];
            NSMutableArray *valueArguments	= [updateSetStatementsInfo objectForKey:UPDATE_SETARGUMENTS];
            NSString *updateStatements		= [NSString stringWithFormat:@"UPDATE tbVideosDownload_segments %@ WHERE vid=? and segmentOrder=?", setStatement];
            [valueArguments addObject:vid];
            [valueArguments addObject:[NSNumber numberWithInteger:segmentOrder]];
            
            [db executeUpdate:updateStatements withArgumentsInArray:valueArguments];
            if ([db hadError]) {
                SNDebugLog(@"Failed to updateVideoSegmentByVid %@, with coming message: error :%d, %@",
                           vid, [db lastErrorCode],[db lastErrorMessage]);
                updateSuccess = NO;
            }
            else {
                updateSuccess = YES;
            }
        }
    }];
	return updateSuccess;
}

- (BOOL)updateAllSegmentsState:(SNVideoDownloadState)state byVid:vid excludingStates:(NSArray *)states {
    __block BOOL success = NO;
    [[SNDatabase writeQueue] inTransaction:^(FMDatabase *db, BOOL *rollback) {
        NSString *_excludingStatesCondition = @"";
        if (states.count > 0) {
            _excludingStatesCondition = @"and state not in (%@)";
            NSString *_inCondition = [states componentsJoinedByString:@","];
            _excludingStatesCondition = [NSString stringWithFormat:_excludingStatesCondition, _inCondition];
        }
        NSString *_updateSQL = [NSString stringWithFormat:@"UPDATE tbVideosDownload_segments set state=? where vid=? %@",
                                _excludingStatesCondition];
        [db executeUpdate:_updateSQL,[NSNumber numberWithInt:state], vid];
        
        if ([db hadError]) {
            SNDebugLog(@"updateAllSegmentsState : error :%d,%@",[db lastErrorCode],[db lastErrorMessage]);
            *rollback = YES;
            success = NO;
        }
        else {
            success = YES;
        }
    }];
    return success;
}

#pragma mark - Delete
- (BOOL)deleteSegmentsByVid:(NSString *)vid {
 	__block BOOL bSucceed = YES;
    [[SNDatabase writeQueue] inTransaction:^(FMDatabase *db, BOOL *rollback) {
        [db executeUpdate:@"DELETE FROM tbVideosDownload_segments where vid=?", vid];
        
        if ([db hadError]) {
            SNDebugLog(@"deleteSegmentsByVid : error :%d,%@",[db lastErrorCode],[db lastErrorMessage]);
            *rollback = YES;
            bSucceed = NO;
        }
        else {
            bSucceed = YES;
        }
    }];
    return bSucceed;
}

#pragma mark - Query
- (NSArray *)queryVideoSegmentsByVID:(NSString *)vid {
    __block NSArray *_segments = nil;
    [[SNDatabase readQueue] inDatabase:^(FMDatabase *db) {
        FMResultSet *rs = [db executeQuery:@"SELECT * FROM tbVideosDownload_segments where vid=?", vid];
        if ([db hadError]) {
            SNDebugLog(@"queryVideoSegmentsByVID : error :%d,%@",[db lastErrorCode],[db lastErrorMessage]);
        }
        else {
            _segments = [self getObjects:[SNSegmentInfo class] fromResultSet:rs];
        }
    }];
    return _segments;
}

- (CGFloat)queryVideoSegmentsTotalBytes:(NSString *)vid {
    __block CGFloat _segmentsTotalBytes = 0;
    [[SNDatabase readQueue] inDatabase:^(FMDatabase *db) {
        _segmentsTotalBytes = [db doubleForQuery:@"SELECT sum(totalBytes) from tbVideosDownload_segments where vid=?", vid];
        
        if ([db hadError]) {
            SNDebugLog(@"queryVideoSegmentsTotalBytes : error :%d,%@",[db lastErrorCode],[db lastErrorMessage]);
            _segmentsTotalBytes = 0;
        }
    }];
    return _segmentsTotalBytes;
}

@end