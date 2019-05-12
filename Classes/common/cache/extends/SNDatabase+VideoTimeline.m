//
//  SNDatabase+VideoTimeline.m
//  sohunews
//
//  Created by chenhong on 13-10-12.
//  Copyright (c) 2013年 Sohu.com. All rights reserved.
//

#import "SNDatabase+VideoTimeline.h"
#import "SNDatabase_Private.h"
#import "NSJSONSerialization+String.h"

#define kMP4S_SEP @"||"

@implementation SNDatabase (VideoTimeline)

#pragma mark - update db
- (BOOL)updateATimelineVideo:(NSDictionary *)data byVid:(NSString *)vid {
	if (data.count <= 0 || vid.length <= 0) {
		SNDebugLog(@"Failed to updateATimelineVideo, because of invalid data.");
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
                                               TB_VIDEO_TIMELINE, setStatement, TB_VIDEO_TIMELINE_VID];
            [valueArguments addObject:vid];
            
            [db executeUpdate:updateStatements withArgumentsInArray:valueArguments];
            if ([db hadError]) {
                SNDebugLog(@"Failed to updateATimelineVideo %@, with coming message: error :%d, %@",
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




#pragma mark - Query
- (SNVideoData *)getVideoTimeLineByVid:(NSString *)vid {
	if ([vid length] == 0) {
		SNDebugLog(@"getVideoTimeLineByVid : Invalid vid=%@", vid);
		return nil;
	}
    
    __block NSArray *array = nil;
    [[SNDatabase readQueue] inDatabase:^(FMDatabase *db) {
        NSString *sql = [NSString stringWithFormat:@"SELECT * FROM %@ WHERE vid=?", TB_VIDEO_TIMELINE];
        
        FMResultSet *rs	= [db executeQuery:sql, vid];
        if ([db hadError]) {
            SNDebugLog(@"getVideoTimeLineByVid : executeQuery error :%d,%@, vid=%@",[db lastErrorCode],[db lastErrorMessage], vid);
            return;
        }
        
        array = [self getVideoTimeLineListFromResultSet:rs];
        [rs close];
    }];
	
    if (array.count > 0) {
        return [array objectAtIndex:0];
    }
    else {
        return nil;
    }
}

- (NSArray *)getAllOfflinePlayVideos {
    __block NSArray *array = nil;
    [[SNDatabase readQueue] inDatabase:^(FMDatabase *db) {
        //Group by的目的是为了去除相同vid的数据，因为timeline表中多个频道可能有同一个视频，因为下载这种视频后timeline里相同vid数据的offlinePlay状态都会被更新为YES
        //所以不group by的话同一个vid视频会被查到多条。
        NSString *sql = [NSString stringWithFormat:@"SELECT * FROM %@ WHERE %@=? GROUP BY vid ORDER BY %@ DESC",
                         TB_VIDEO_TIMELINE, TB_VIDEO_TIMELINE_OFFLINE_PLAY, TB_VIDEO_TIMELINE_FINISH_DOWNLOAD_TIMEINTERVAL];
        
        FMResultSet *rs	= [db executeQuery:sql, @(YES)];
        if ([db hadError]) {
            SNDebugLog(@"getAllOfflinePlayVideos : executeQuery error :%d,%@",[db lastErrorCode], [db lastErrorMessage]);
            return;
        }
        
        array = [self getVideoTimeLineListFromResultSet:rs];
        [rs close];
    }];
	
	return array;
}

- (SNVideoData *)getOfflinePlayVideoByVid:(NSString *)vid {
    __block SNVideoData *video = nil;
    [[SNDatabase readQueue] inDatabase:^(FMDatabase *db) {
        NSString *sql = [NSString stringWithFormat:@"SELECT * FROM %@ WHERE %@=? and %@=?",
                         TB_VIDEO_TIMELINE, TB_VIDEO_TIMELINE_OFFLINE_PLAY, TB_VIDEO_TIMELINE_VID];
        
        FMResultSet *rs	= [db executeQuery:sql, @(YES), vid];
        if ([db hadError]) {
            SNDebugLog(@"getOfflinePlayVideoByVid : executeQuery error :%d,%@",[db lastErrorCode], [db lastErrorMessage]);
            return;
        }
        
        NSArray *array = [self getVideoTimeLineListFromResultSet:rs];
        if (array.count > 0) {
            video = [array objectAtIndex:0];
        }
        [rs close];
    }];
    return video;
}

- (NSArray*)getVideoTimeLineListByChannelId:(NSString*)channelId
{
	if ([channelId length] == 0) {
		SNDebugLog(@"getVideoTimeLineListByChannelId : Invalid channelId=%@",channelId);
		return nil;
	}
    
    __block NSArray *array = nil;
    [[SNDatabase readQueue] inDatabase:^(FMDatabase *db) {
        
        //lijian 2015.07.29 这里这么修改是因为，离线的视频也是通过channelid保存的，在数据库里取的时候把这个数据也取出来了，所以清除了缓存后还能取出内容，实际上不应该包含离线视频的数据。
        //NSString *sql = [NSString stringWithFormat:@"SELECT * FROM %@ WHERE channelId=? ORDER BY %@ ASC",TB_VIDEO_TIMELINE, TB_VIDEO_TIMELINE_INDEX];
        NSString *sql = [NSString stringWithFormat:@"SELECT * FROM %@ WHERE channelId=? AND %@=? ORDER BY %@ ASC",TB_VIDEO_TIMELINE, TB_VIDEO_TIMELINE_OFFLINE_PLAY, TB_VIDEO_TIMELINE_INDEX];
        
        //FMResultSet *rs	= [db executeQuery:sql, channelId];
        FMResultSet *rs	= [db executeQuery:sql, channelId,@(NO)];
        if ([db hadError]) {
            SNDebugLog(@"getVideoTimeLineListByChannelId : executeQuery error :%d,%@,channelId=%@",[db lastErrorCode],[db lastErrorMessage],channelId);
            return;
        }
        
        array = [self getVideoTimeLineListFromResultSet:rs];
        [rs close];
    }];
	
	return array;
}

- (NSArray*)getVideoTimeLineListFromResultSet:(FMResultSet*)rs
{
	if (rs == nil) {
		SNDebugLog(@"getVideoTimeLineListFromResultSet: invalid rs");
		return nil;
	}
	
	NSMutableArray *array = [[NSMutableArray alloc] init];
	while ([rs next])
	{
        @autoreleasepool {
            SNVideoData *videoData = [[SNVideoData alloc] init];
            videoData.vid                = [rs stringForColumn:TB_VIDEO_TIMELINE_VID];
            videoData.messageId          = [rs stringForColumn:TB_VIDEO_TIMELINE_ID];
            videoData.channelId          = [rs stringForColumn:TB_VIDEO_TIMELINE_CHANNELID];
            videoData.columnId           = [rs intForColumn:TB_VIDEO_TIMELINE_COLUMN_ID];
            videoData.columnName         = [rs stringForColumn:TB_VIDEO_TIMELINE_COLUMN_NAME];
            videoData.poster             = [rs stringForColumn:TB_VIDEO_TIMELINE_PIC];
            videoData.poster_4_3         = [rs stringForColumn:TB_VIDEO_TIMELINE_PIC_4_3];
            videoData.smallImageUrl      = [rs stringForColumn:TB_VIDEO_TIMELINE_SMALL_PIC];
            videoData.wapUrl             = [rs stringForColumn:TB_VIDEO_TIMELINE_URL];
            videoData.title              = [rs stringForColumn:TB_VIDEO_TIMELINE_TITLE];
            
            videoData.videoUrl           = [[SNVideoUrl alloc] init];
            videoData.videoUrl.m3u8      = [rs stringForColumn:TB_VIDEO_TIMELINE_PLAYURL_M3U8];
            videoData.videoUrl.mp4       = [rs stringForColumn:TB_VIDEO_TIMELINE_PLAYURL_MP4];
            
            NSString *mp4s          = [rs stringForColumn:TB_VIDEO_TIMELINE_PLAYURL_MP4S];
            videoData.videoUrl.mp4s      = [mp4s componentsSeparatedByString:kMP4S_SEP];
            
            videoData.author             = [[SNVideoAuthor alloc] init];
            videoData.author.name        = [rs stringForColumn:TB_VIDEO_TIMELINE_AUTHOR_NAME];
            videoData.author.type        = [rs intForColumn:TB_VIDEO_TIMELINE_AUTHOR_TYPE];
            videoData.author.icon        = [rs stringForColumn:TB_VIDEO_TIMELINE_AUTHOR_ICON];
            
            videoData.share              = [[SNVideoShare alloc] init];
            videoData.share.content      = [rs stringForColumn:TB_VIDEO_TIMELINE_SHARE_CONTENT];
            videoData.share.h5Url        = [rs stringForColumn:TB_VIDEO_TIMELINE_SHARE_H5URL];
            videoData.share.ugcWordLimit = [rs intForColumn:TB_VIDEO_TIMELINE_SHARE_UGCWORDLIMIT];
            
            videoData.siteInfo           = [[SNVideoSiteInfo alloc] init];
            videoData.siteInfo.siteName  = [rs stringForColumn:TB_VIDEO_TIMELINE_SITE_NAME];
            videoData.siteInfo.siteId    = [rs stringForColumn:TB_VIDEO_TIMELINE_SITE_ID];
            videoData.siteInfo.site      = [rs stringForColumn:TB_VIDEO_TIMELINE_SITE];
            videoData.siteInfo.site2     = [rs stringForColumn:TB_VIDEO_TIMELINE_SITE2];
            videoData.siteInfo.adServer  = [rs stringForColumn:TB_VIDEO_TIMELINE_ADSERVER];
            videoData.siteInfo.playById  = [rs stringForColumn:TB_VIDEO_TIMELINE_PLAYBYID];
            videoData.siteInfo.playAd    = [rs stringForColumn:TB_VIDEO_TIMELINE_PLAYAD];
            
            videoData.link2              = [rs stringForColumn:TB_VIDEO_TIMELINE_LINK2];
            
            videoData.downloadType       = [rs intForColumn:TB_VIDEO_TIMELINE_DOWNLOAD];
            
            videoData.duration           = [rs intForColumn:TB_VIDEO_TIMELINE_DURATION];
            videoData.multipleType       = [rs intForColumn:TB_VIDEO_TIMELINE_MULTIPLETYPE];
            videoData.templatePicUrl     = [rs stringForColumn:TB_VIDEO_TIMELINE_TEMPLATEPIC];
            videoData.abstract           = [rs stringForColumn:TB_VIDEO_TIMELINE_CONTENT];
            videoData.playType           = [rs intForColumn:TB_VIDEO_TIMELINE_PLAYTYPE];
            
            videoData.mediaLink          = [rs stringForColumn:TB_VIDEO_TIMELINE_MEDIALINK];
            
            //---App换量相关--------------------------------------------------------
            if (videoData.multipleType == TimelineVideoType_AppBanner) {
                NSString *appContent = [rs stringForColumn:TB_VIDEO_TIMELINE_APPCONTENT];
                NSDictionary *dict = [NSJSONSerialization JSONObjectWithString:appContent
                                                                       options:NSJSONReadingMutableLeaves
                                                                         error:NULL];
                
                videoData.bannerImgURLOfOpenApp = [dict stringValueForKey:kTimelineAppContent_IconOpen defaultValue:nil];
                videoData.bannerImgURLOfDownloadApp = [dict stringValueForKey:kTimelineAppContent_IconDownload defaultValue:nil];
                videoData.bannerImgURLOfUpgradeApp = [dict stringValueForKey:kTimelineAppContent_IconUpgrade defaultValue:nil];
                videoData.appDownloadLink = [dict stringValueForKey:kTimelineAppContent_AppDownloadLink defaultValue:nil];
                videoData.appIdOfAppWillBeOpen = [dict stringValueForKey:kTimelineAppContent_AppIdOfAppWillBeOpen defaultValue:nil];
                videoData.appURLSchemaOfAppWillBeOpen = [dict stringValueForKey:kTimelineAppContent_AppURLSchemaOfAppWillBeOpen defaultValue:nil];
            }
            //---------------------------------------------------------------------
            
            videoData.offlinePlay       = [rs boolForColumn:TB_VIDEO_TIMELINE_OFFLINE_PLAY];
            videoData.finishDownloadTimeInterval = [rs stringForColumn:TB_VIDEO_TIMELINE_FINISH_DOWNLOAD_TIMEINTERVAL].doubleValue;
            videoData.uninterestInterval = [rs intForColumn:TB_VIDEO_TIMELINE_UNINTERINST];
            videoData.bannerString = [rs stringForColumn:TB_VIDEO_TIMELINE_BANNER_DATA];
            videoData.entryString = [rs stringForColumn:TB_VIDEO_TIMELINE_ENTRY_DATA];
            if(videoData.bannerString)
            {
                NSDictionary* dic = [NSJSONSerialization JSONObjectWithString:videoData.bannerString
                                                                      options:NSJSONReadingMutableLeaves
                                                                        error:NULL];
                SNVideoBannerData* banerData = [[SNVideoBannerData alloc] initWithDic:dic];
                videoData.banerData = banerData;
            }
            if(videoData.entryString)
            {
                NSArray* array = [NSJSONSerialization JSONObjectWithString:videoData.entryString
                                                                   options:NSJSONReadingMutableLeaves
                                                                     error:NULL];
                if([array isKindOfClass:[NSArray class]])
                {
                    NSMutableArray* entryArray = [NSMutableArray arrayWithCapacity:6];
                    for(NSDictionary* dic in array)
                    {
                        SNVideoEntryData* entry = [[SNVideoEntryData alloc] initWithDic:dic];
                        [entryArray addObject:entry];
                    }
                    videoData.entryData = entryArray;
                }
            }
            
            [array addObject:videoData];
            //videoData);
        }
	}
	
	return array;
}

#pragma mark - write db
- (BOOL)addVideoTimeLineList:(NSArray*)videoList channelId:(NSString *)channelId
{
	if ([videoList count] == 0) {
		SNDebugLog(@"addVideoTimeLineList : empty news list");
		return NO;
	}
	
	__block BOOL bSucceed	= YES;
    [[SNDatabase writeQueue] inTransaction:^(FMDatabase *db, BOOL *rollback) {
        for(int nIndex = 0; nIndex < [videoList count]; ++nIndex)
        {
            SNVideoData *videoData	= [videoList objectAtIndex:nIndex];
            bSucceed = [self addVideoTimeLineItem:videoData channelId:channelId inDatabase:db];
            if (!bSucceed) {
                SNDebugLog(@"addVideoTimeLineList : Failed");
                *rollback = YES;
                return;
            }
        }
    }];
	return bSucceed;
}

- (BOOL)addVideoData:(SNVideoData *)video channelId:(NSString *)channelId {
	if (!video) {
		SNDebugLog(@"addVideoData : nil video data");
		return NO;
	}
	
	__block BOOL bSucceed	= YES;
    [[SNDatabase writeQueue] inTransaction:^(FMDatabase *db, BOOL *rollback) {
        bSucceed = [self addVideoTimeLineItem:video channelId:channelId inDatabase:db];
        if (!bSucceed) {
            SNDebugLog(@"addVideoData : Failed");
            *rollback = YES;
            return;
        }
    }];
	return bSucceed;
}

- (BOOL)addVideoTimeLineItem:(SNVideoData*)videoData channelId:(NSString *)channelId inDatabase:(FMDatabase *)db
{
	if (videoData == nil) {
		SNDebugLog(@"addVideoTimeLineItem : Invalid item");
		return NO;
	}
	
	if ([channelId length] == 0) {
		SNDebugLog(@"addVideoTimeLineItem : Invalid item,channelId=%@", channelId);
		return NO;
	}
	
    //执行插入操作
    NSString *sql = [NSString stringWithFormat:@"INSERT INTO %@ (\
                     %@,%@,%@,%@,%@,\
                     %@,%@,%@,%@,%@,\
                     %@,%@,%@,%@,%@,\
                     %@,%@,%@,%@,%@,\
                     %@,%@,%@,%@,%@,\
                     %@,%@,%@,%@,%@,\
                     %@,%@,%@,%@,%@,\
                     %@,%@,%@,%@,%@\
                     ) VALUES (\
                     NULL,?,?,?,?,\
                     ?,?,?,?,?,\
                     ?,?,?,?,?,\
                     ?,?,?,?,?,\
                     ?,?,?,?,?,\
                     ?,?,?,?,?,\
                     ?,?,?,?,?,\
                     ?,?,?,?,?)",
                     TB_VIDEO_TIMELINE,
                     
                     TB_VIDEO_TIMELINE_INDEX,
                     TB_VIDEO_TIMELINE_CHANNELID,
                     TB_VIDEO_TIMELINE_ID,
                     TB_VIDEO_TIMELINE_VID,
                     TB_VIDEO_TIMELINE_COLUMN_ID,
                     
                     TB_VIDEO_TIMELINE_COLUMN_NAME,
                     TB_VIDEO_TIMELINE_PIC,
                     TB_VIDEO_TIMELINE_PIC_4_3,
                     TB_VIDEO_TIMELINE_URL,
                     TB_VIDEO_TIMELINE_TITLE,
                     
                     TB_VIDEO_TIMELINE_PLAYURL_MP4S,
                     TB_VIDEO_TIMELINE_PLAYURL_MP4,
                     TB_VIDEO_TIMELINE_PLAYURL_M3U8,
                     TB_VIDEO_TIMELINE_AUTHOR_NAME,
                     TB_VIDEO_TIMELINE_AUTHOR_ICON,
                     
                     TB_VIDEO_TIMELINE_AUTHOR_TYPE,
                     TB_VIDEO_TIMELINE_SHARE_CONTENT,
                     TB_VIDEO_TIMELINE_SHARE_H5URL,
                     TB_VIDEO_TIMELINE_SHARE_UGCWORDLIMIT,
                     TB_VIDEO_TIMELINE_SITE_NAME,
                     
                     TB_VIDEO_TIMELINE_LINK2,
                     TB_VIDEO_TIMELINE_DOWNLOAD,
                     TB_VIDEO_TIMELINE_DURATION,
                     TB_VIDEO_TIMELINE_MULTIPLETYPE,
                     TB_VIDEO_TIMELINE_TEMPLATEPIC,
                     
                     TB_VIDEO_TIMELINE_CONTENT,
                     TB_VIDEO_TIMELINE_PLAYTYPE,
                     TB_VIDEO_TIMELINE_MEDIALINK,
                     TB_VIDEO_TIMELINE_SITE_ID,
                     TB_VIDEO_TIMELINE_APPCONTENT,
                     
                     TB_VIDEO_TIMELINE_OFFLINE_PLAY,
                     TB_VIDEO_TIMELINE_SMALL_PIC,
                     TB_VIDEO_TIMELINE_SITE,
                     TB_VIDEO_TIMELINE_SITE2,
                     TB_VIDEO_TIMELINE_ADSERVER,
                     
                     TB_VIDEO_TIMELINE_PLAYBYID,
                     TB_VIDEO_TIMELINE_PLAYAD,
                     TB_VIDEO_TIMELINE_UNINTERINST,
                     TB_VIDEO_TIMELINE_BANNER_DATA,
                     TB_VIDEO_TIMELINE_ENTRY_DATA
                     ];
    
    NSMutableString *mp4s = nil;
    NSInteger cnt = [videoData.videoUrl.mp4s count];
    for (int i=0; i<cnt; ++i) {
        if (mp4s == nil) {
            mp4s = [[NSMutableString alloc] init];
        }
        NSString *url = [videoData.videoUrl.mp4s objectAtIndex:i];
        [mp4s appendString:url];
        if (i < cnt - 1) {
            [mp4s appendString:kMP4S_SEP];
        }
    }
    
    [db executeUpdate:sql,
     channelId, videoData.messageId, videoData.vid, [NSNumber numberWithInt:videoData.columnId],
     videoData.columnName, videoData.poster, videoData.poster_4_3, videoData.wapUrl, videoData.title,
     mp4s, videoData.videoUrl.mp4, videoData.videoUrl.m3u8, videoData.author.name, videoData.author.icon,
     [NSNumber numberWithInt:videoData.author.type], videoData.share.content, videoData.share.h5Url, @(videoData.share.ugcWordLimit), videoData.siteInfo.siteName,
     videoData.link2, [NSNumber numberWithInt:videoData.downloadType], [NSNumber numberWithInt:videoData.duration], @(videoData.multipleType), videoData.templatePicUrl,
     videoData.abstract, @(videoData.playType), videoData.mediaLink, videoData.siteInfo.siteId, videoData.appContent,
     @(videoData.offlinePlay), videoData.smallImageUrl, videoData.siteInfo.site, videoData.siteInfo.site2, videoData.siteInfo.adServer,
     videoData.siteInfo.playById, videoData.siteInfo.playAd, [NSNumber numberWithInt:videoData.uninterestInterval], videoData.bannerString, videoData.entryString];
    
    if ([db hadError]) {
        SNDebugLog(@"addVideoTimeLineItem : executeUpdate error:%d,%@",[db lastErrorCode],[db lastErrorMessage]);
        return NO;
    }
    
    return YES;
}

#pragma mark - delete db

- (BOOL)clearVideoTimeLineList
{
    __block BOOL result = YES;
    [[SNDatabase writeQueue] inTransaction:^(FMDatabase *db, BOOL *rollback) {
        //NSString *sql = @"delete from tbVideoTimeline where vid not in (select t2.vid from tbVideosDownload t2)";
        //result =  [db executeUpdate:sql];
        NSString *sql = [NSString stringWithFormat:@"DELETE FROM %@ WHERE offlinePlay!=?", TB_VIDEO_TIMELINE];
        result = [db executeUpdate:sql, @(YES)];
        if (!result) {
            *rollback = YES;
            SNDebugLog(@"clearVideoTimeLineList : executeUpdate error:%d,%@",[db lastErrorCode],[db lastErrorMessage]);
            return ;
        }
    }];
	return result;
}

- (BOOL)clearVideoTimeLineListByChannelId:(NSString *)channelId
{
    __block BOOL result = YES;
    [[SNDatabase writeQueue] inTransaction:^(FMDatabase *db, BOOL *rollback) {
        NSString *sql = [NSString stringWithFormat:@"DELETE FROM %@ WHERE channelId=? and offlinePlay!=?", TB_VIDEO_TIMELINE];
        result = [db executeUpdate:sql, channelId, @(YES)];
        if ([db hadError]) {
            *rollback = YES;
        }
    }];
	return result;
}

#pragma mark - max vid

- (NSString *)getVideoTimeLineListMaxVid {
    NSMutableArray *ids = [NSMutableArray array];
    [[SNDatabase readQueue] inDatabase:^(FMDatabase *db) {
        NSString *sql = [NSString stringWithFormat:@"SELECT MAX(%@) AS %@ FROM %@ WHERE %@=?",
                         TB_VIDEO_TIMELINE_VID, TB_VIDEO_TIMELINE_VID, TB_VIDEO_TIMELINE, TB_VIDEO_TIMELINE_CHANNELID];
        FMResultSet *rs	= [db executeQuery:sql, kVideoTimelineMainChannelId];
        
        if ([db hadError]) {
            SNDebugLog(@"selectMaxVid : executeQuery error :%d,%@",[db lastErrorCode],[db lastErrorMessage]);
            return;
        }
        while ([rs next]) {
            @autoreleasepool {
                NSString *vid = [rs stringForColumn:TB_VIDEO_TIMELINE_VID];
                if (vid) {
                    [ids addObject:vid];
                }
            }
        }
    }];
	if (ids.count > 0) {
        return [ids objectAtIndex:0];
    }
	return nil;
}

@end
