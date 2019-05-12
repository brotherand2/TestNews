
//
//  SNDatabase_RollingNews.m
//  sohunews
//
//  Created by 李 雪 on 11-10-18.
//  Copyright 2011 Sohu.com Inc. All rights reserved.
//
#import "SNDatabase_RollingNewsList.h"
#import "SNDatabase_NewsImage.h"
#import "SNDatabase_News.h"
#import "SNDatabase_Private.h"

@implementation SNDatabase(RollingNewsList)

- (NSString *)p_getRollingNewsHistoryDate:(NSInteger)days withData:(NSArray *)dateArray {
    NSMutableString *dateString = [[NSMutableString alloc] initWithString:@"("];
    for (NSInteger i = 0; i < days; i++) {
        RollingNewsListItem *item = dateArray[i];
        if (i == (days - 1)) {
            [dateString appendFormat:@"'%d'", item.createAt];
        } else {
            [dateString appendFormat:@"'%d', ", item.createAt];
        }
    }
    [dateString appendString:@")"];
    return dateString;
}

- (BOOL)clearRollingNewsHistoryByChannelID:(NSString *)channelID days:(NSInteger)days {
    //Days为保留几天历史记录
    [[SNDatabase readQueue] inDatabase:^(FMDatabase *db) {
        FMResultSet *rs = [db executeQuery:@"SELECT DISTINCT strftime('%Y%m%d', createAt, 'unixepoch') AS createAt FROM tbRollingNewsList WHERE channelId=? ORDER by createAt DESC", channelID];
        if ([db hadError]) {
            SNDebugLog(@"clearRollingNewsHistoryByChannelID: executeQuery error %d : %@, channelId=%@", [db lastErrorCode], [db lastErrorMessage], channelID);
            [rs close];
            return;
        }
        NSMutableArray *dayArray = nil;
        BOOL hasTodayNews = NO;
        while ([rs next]) {
            if (dayArray == nil) {
                dayArray = [[NSMutableArray alloc] init];
            }
            @autoreleasepool {
                RollingNewsListItem *item = [[RollingNewsListItem alloc] init];
                if (!hasTodayNews) {
                    NSInteger today = [rs intForColumn:TB_CREATEAT_COLUMN];
                    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
                    [dateFormatter setDateFormat:@"yyyyMMdd"];
                    NSInteger compareToday = [[dateFormatter stringFromDate:[NSDate date]] integerValue];
                    if (today == compareToday) {
                        hasTodayNews = YES;
                    }
                }
                
                item.createAt = [rs intForColumn:TB_CREATEAT_COLUMN];
                [dayArray addObject:item];
            }
        }
        
        [rs close];
        
        if (dayArray.count == 0) {
            return;
        }
        
        //数据
        NSString *stmt = @"";
        if (hasTodayNews) {
            if (dayArray.count > days + 1) {
                //删除多余数据保留当天数据, 和之前的Days
                stmt = [NSString stringWithFormat:@"DELETE FROM tbRollingNewsList where channelId=? AND strftime('%@', createAt, 'unixepoch') NOT IN %@", @"%Y%m%d", [self p_getRollingNewsHistoryDate:days + 1 withData:dayArray]];
            }
        } else {
            if (dayArray.count > days) {
                //删除多余数据
                stmt = [NSString stringWithFormat:@"DELETE FROM tbRollingNewsList where channelId=? AND strftime('%@', createAt, 'unixepoch') NOT IN %@", @"%Y%m%d", [self p_getRollingNewsHistoryDate:days withData:dayArray]];
            }
        }
        if (stmt.length > 0) {
            BOOL result = [db executeUpdate:stmt, channelID];
            if ([db hadError] || !result) {
                SNDebugLog(@"clearRollingNewsHistoryByChannelID: executeQuery error %d : %@, channelId=%@", [db lastErrorCode], [db lastErrorMessage], channelID);
            }
        }
    }];
    return YES;
}

#pragma mark -
#pragma mark rolling news article
- (NSArray *)getNewsShareImageListByChannelId:(NSString *)channelId
                                       newsId:(NSString *)newsId {
    __block NSArray *newsImageList = nil;
    [[SNDatabase readQueue] inDatabase:^(FMDatabase *db) {
        newsImageList = [self getNewsShareImageListByChannelId:channelId newsId:newsId inDatabase:db];
    }];
    return newsImageList;
}

- (NSArray *)getNewsShareImageListByChannelId:(NSString *)channelId
                                       newsId:(NSString *)newsId
                                   inDatabase:(FMDatabase *)db {
    if ([channelId length] == 0 || [newsId length] == 0) {
		SNDebugLog(@"getNewsShareImageListByChannelId : Invalid channelId=%@ or newsId=%@", channelId, newsId);
		return nil;
	}
	
	FMResultSet *rs	= [db executeQuery:@"SELECT * FROM tbNewsImage WHERE termId=? AND newsId=? AND type=?",channelId, newsId, NEWSSHAREIMAGE_TYPE];
	if ([db hadError]) {
		SNDebugLog(@"getNewsShareImageListByTermId : executeQuery error :%d,%@,termId=%@,newsId=%@", [db lastErrorCode], [db lastErrorMessage], channelId, newsId);
		return nil;
	}
	
	NSArray *newsImageList = [self getObjects:[NewsImageItem class] fromResultSet:rs];
	[rs close];
	return newsImageList;
}

- (NSArray *)getRollingNewsArticleFromResultSet:(FMResultSet *)rs
                                     inDatabase:(FMDatabase *)db {
	if (rs == nil) {
		SNDebugLog(@"getNewsArticleFromResultSet: Invalid rs");
		return nil;
	}
	
	NSMutableArray *newsArticle = [[NSMutableArray alloc] init];
	while ([rs next]) {
        @autoreleasepool {
            NewsArticleItem *item	= [[NewsArticleItem alloc] init];
            item.ID			= [rs intForColumn:TB_NEWSARTICLE_ID];
            item.channelId	= [rs stringForColumn:TB_NEWSARTICLE_CHANNELID];
            //item.pubId		= [rs stringForColumn:TB_NEWSARTICLE_PUBID];
            item.termId		= [rs stringForColumn:TB_NEWSARTICLE_TERMID];
            item.newsId		= [rs stringForColumn:TB_NEWSARTICLE_NEWSID];
            item.type		= [rs stringForColumn:TB_NEWSARTICLE_TYPE];
            item.title		= [rs stringForColumn:TB_NEWSARTICLE_TITLE];
            item.time		= [rs stringForColumn:TB_NEWSARTICLE_TIME];
            item.newsMark   = [rs stringForColumn:TB_NEWSARTICLE_NEWSMARK];
            item.originFrom = [rs stringForColumn:TB_NEWSARTICLE_ORIGINFROM];
            item.originTitle= [rs stringForColumn:TB_NEWSARTICLE_ORIGINTITLE];
            item.from		= [rs stringForColumn:TB_NEWSARTICLE_FROM];
            item.updateTime = [rs stringForColumn:TB_NEWSARTICLE_UPDATETIME];
            item.commentNum	= [rs stringForColumn:TB_NEWSARTICLE_COMMENTNUM];
            item.digNum		= [rs stringForColumn:TB_NEWSARTICLE_DIGNUM];
            item.content	= [rs stringForColumn:TB_NEWSARTICLE_CONTENT];
            item.link		= [rs stringForColumn:TB_NEWSARTICLE_LINK];
            item.nextName	= [rs stringForColumn:TB_NEWSARTICLE_NEXTNAME];
            item.nextId		= [rs stringForColumn:TB_NEWSARTICLE_NEXTID];
            item.preName	= [rs stringForColumn:TB_NEWSARTICLE_PRENAME];
            item.preId		= [rs stringForColumn:TB_NEWSARTICLE_PREID];
            item.shareContent	= [rs stringForColumn:TB_NEWSARTICLE_SHARECONTENT];
            item.subId      = [rs stringForColumn:TB_NEWSARTICLE_SUBID];
            item.cmtStatus  = [rs stringForColumn:TB_NEWSARTICLE_CMTSTATUS];
            item.cmtHint    = [rs stringForColumn:TB_NEWSARTICLE_CMTHINT];
            item.cmtRead    = [rs boolForColumn:TB_NEWSARTICLE_CMTREAD];
            item.logoUrl    = [rs stringForColumn:TB_NEWSARTICLE_LOGOURL];
            item.linkUrl    = [rs stringForColumn:TB_NEWSARTICLE_LINKURL];
            item.favour     = [rs boolForColumn:TB_NEWSARTICLE_FAVOUR];
            item.h5link     = [rs stringForColumn:TB_NEWSARTICLE_H5LINK];
            item.newsType = [rs intForColumn:TB_NEWSARTICLE_NEWSTYPE];
            item.openType = [rs intForColumn:TB_NEWSARTICLE_OPENTYPE];
            item.favIcon = [rs stringForColumn:TB_NEWSARTICLE_FAVICON];
            item.mediaName = [rs stringForColumn:TB_NEWSARTICLE_MEDIANAME];
            item.mediaLink = [rs stringForColumn:TB_NEWSARTICLE_MEDIALINK];
            item.optimizeRead = [rs stringForColumn:TB_NEWSARTICLE_OPTIMIZEREAD];
            item.tagChannelsStr = [rs stringForColumn:TB_NEWSARTICLE_TAGCHANNELS];
            item.stocksStr = [rs stringForColumn:TB_NEWSARTICLE_STOCKS];
            
            //获取分享图集
            item.shareImages = [self getNewsShareImageListByChannelId:item.channelId newsId:item.newsId inDatabase:db];
            
            [newsArticle addObject:item];
        }
	}
	
	return newsArticle;
}

- (NSString *)checkNewsListItemValue:(NSString *)value {
    if (!value) {
        return @"";
    }
    return value;
}

- (NSArray *)getRollingNewsListFromResultSet:(FMResultSet *)rs {
	if (rs == nil) {
		SNDebugLog(@"getRollingNewsListFromResultSet:Invalid rs");
		return nil;
	}
	
	NSMutableArray *newsList = [[NSMutableArray alloc] init];
	while ([rs next]) {
        RollingNewsListItem *item	= [[RollingNewsListItem alloc] init];
        item.ID				= [rs intForColumn:TB_ROLLINGNEWSLIST_ID];
        item.channelId		= [rs stringForColumn:TB_ROLLINGNEWSLIST_CHANNELID] ? : @"";
        item.pubId			= [rs stringForColumn:TB_ROLLINGNEWSLIST_PUBID] ? : @"";
        item.pubName		= [rs stringForColumn:TB_ROLLINGNEWSLIST_PUBNAME] ? : @"";
        item.newsId			= [rs stringForColumn:TB_ROLLINGNEWSLIST_NEWSID] ? : @"";
        item.type			= [rs stringForColumn:TB_ROLLINGNEWSLIST_TYPE] ? : @"";
        item.title			= [rs stringForColumn:TB_ROLLINGNEWSLIST_TITLE] ? : @"";
        item.description	= [rs stringForColumn:TB_ROLLINGNEWSLIST_DESCRIPTION] ? : @"";
        item.time			= [rs stringForColumn:TB_ROLLINGNEWSLIST_TIME] ? : @"";
        item.commentNum		= [rs stringForColumn:TB_ROLLINGNEWSLIST_COMMENTNUM] ? : @"";
        item.digNum			= [rs stringForColumn:TB_ROLLINGNEWSLIST_DIGNUM] ? : @"";
        item.listPic		= [rs stringForColumn:TB_ROLLINGNEWSLIST_LISTPIC] ? : @"";
        item.link			= [rs stringForColumn:TB_ROLLINGNEWSLIST_LINK] ? : @"";
        item.readFlag		= [rs stringForColumn:TB_ROLLINGNEWSLIST_READFLAG ] ? : @"";
        item.downloadFlag	= [rs stringForColumn:TB_ROLLINGNEWSLIST_DOWNLOADFLAG ] ? : @"";
        item.form           = [rs stringForColumn:TB_ROLLINGNEWSLIST_FORM ] ? : @"";
        item.listPicsNumber = [rs stringForColumn:TB_ROLLINGNEWSLIST_LISTPICSNUMBER ] ? : @"";
        item.timelineIndex  = [rs stringForColumn:TB_ROLLINGNEWSLIST_TIMELINEINDEX ] ? : @"";
        item.hasVideo       = [rs stringForColumn:TB_ROLLINGNEWSLIST_HASVIDEO ] ? : @"";
        item.hasAudio       = [rs stringForColumn:TB_ROLLINGNEWSLIST_HASAUDIO ] ? : @"";
        item.hasVote        = [rs stringForColumn:TB_ROLLINGNEWSLIST_HASVOTE ] ? : @"";
        item.updateTime     = [rs stringForColumn:TB_ROLLINGNEWSLIST_UPDATETIME ] ? : @"";
        item.expired        = [rs stringForColumn:TB_ROLLINGNEWSLIST_EXPIRED ] ? : @"";
        item.recomIconDay   = [rs stringForColumn:TB_ROLLINGNEWSLIST_RECOMICONDAY ] ? : @"";
        item.recomIconNight = [rs stringForColumn:TB_ROLLINGNEWSLIST_RECOMICONNIGHT ] ? : @"";
        item.media          = [rs stringForColumn:TB_ROLLINGNEWSLIST_MEDIA ] ? : @"";
        item.isWeather      = [rs stringForColumn:TB_ROLLINGNEWSLIST_ISWEATHER ] ? : @"";
        item.city           = [rs stringForColumn:TB_ROLLINGNEWSLIST_CITY ] ? : @"";
        item.tempLow        = [rs stringForColumn:TB_ROLLINGNEWSLIST_TEMPLOW ] ? : @"";
        item.tempHigh       = [rs stringForColumn:TB_ROLLINGNEWSLIST_TEMPHIGH ] ? : @"";
        item.weather        = [rs stringForColumn:TB_ROLLINGNEWSLIST_WEATHER ] ? : @"";
        item.weak           = [rs stringForColumn:TB_ROLLINGNEWSLIST_WEAK ] ? : @"";
        item.liveTemperature= [rs stringForColumn:TB_ROLLINGNEWSLIST_LIVETEMPERTURE ] ? : @"";
        item.pm25           = [rs stringForColumn:TB_ROLLINGNEWSLIST_PM25 ] ? : @"";
        item.quality        = [rs stringForColumn:TB_ROLLINGNEWSLIST_QUALITY ] ? : @"";
        item.weatherIoc     = [rs stringForColumn:TB_ROLLINGNEWSLIST_WEATHERIOC ] ? : @"";
        item.isRecom        = [rs stringForColumn:TB_ROLLINGNEWSLIST_ISRECOM ] ? : @"";
        item.recomType      = [rs stringForColumn:TB_ROLLINGNEWSLIST_RECOMTYPE ] ? : @"";
        item.liveStatus     = [rs stringForColumn:TB_ROLLINGNEWSLIST_LIVESTATUS ] ? : @"";
        item.local          = [rs stringForColumn:TB_ROLLINGNEWSLIST_LOCAL ] ? : @"";
        item.wind           = [rs stringForColumn:TB_ROLLINGNEWSLIST_WIND ] ? : @"";
        item.thirdPartUrl   = [rs stringForColumn:TB_ROLLINGNEWSLIST_THIRDPARTURL ] ? : @"";
        item.gbcode         = [rs stringForColumn:TB_ROLLINGNEWSLIST_GBCODE ] ? : @"";
        item.date           = [rs stringForColumn:TB_ROLLINGNEWSLIST_DATE ] ? : @"";
        item.localIoc       = [rs stringForColumn:TB_ROLLINGNEWSLIST_LOCALIOC ] ? : @"";
        item.templateId     = [rs stringForColumn:TB_ROLLINGNEWSLIST_TEMPLATEID ] ? : @"";
        item.templateType   = [rs stringForColumn:TB_ROLLINGNEWSLIST_TEMPLATETYPE] ? : @"1";
        item.dataString     = [rs stringForColumn:TB_ROLLINGNEWSLIST_DATASTRING ] ? : @"";
        item.playTime       = [rs stringForColumn:TB_ROLLINGNEWSLIST_PLAYTIME ] ? : @"";
        item.liveType       = [rs stringForColumn:TB_ROLLINGNEWSLIST_LIVETYPE ] ? : @"";
        item.isFlash        = [rs stringForColumn:TB_ROLLINGNEWSLIST_ISFLASH ] ? : @"";
        item.token          = [rs stringForColumn:TB_ROLLINGNEWSLIST_TOKEN ] ? : @"";
        item.position       = [rs stringForColumn:TB_ROLLINGNEWSLIST_POSITION ] ? : @"";
        item.newsStatsType  = [rs intForColumn:TB_ROLLINGNEWSLIST_STATSTYPE];
        item.morePageNum    = [rs intForColumn:TB_ROLLINGNEWSLIST_MOREPAGENUM];
        item.isHasSponsorships = [rs stringForColumn:TB_ROLLINGNEWSLIST_HASSPONSORSHIPS ] ? : @"";
        item.iconText       = [rs stringForColumn:TB_ROLLINGNEWSLIST_ICONTEXT ] ? : @"";
        item.newsTypeText   = [rs stringForColumn:TB_ROLLINGNEWSLIST_NEWSTYPETEXT ] ? : @"";
        item.sponsorships   = [rs stringForColumn:TB_ROLLINGNEWSLIST_SPONSORSHIPS ] ? : @"";
        item.cursor         = [rs stringForColumn:TB_ROLLINGNEWSLIST_CURSOR ] ? : @"";
        item.adReportState  = [rs intForColumn:TB_ROLLINGNEWSLIST_ADREPORTSTATE];
        item.subId          = [rs stringForColumn:TB_ROLLINGNEWSLIST_SUBID ] ? : @"";
        item.isTopNews      = [rs boolForColumn:TB_ROLLINGNEWSLIST_TOPNEWS];
        item.isLatest       = [rs boolForColumn:TB_ROLLINGNEWSLIST_LATEST];
        item.bgPic          = [rs stringForColumn:TB_ROLLINGNEWSLIST_REDPACKETBGPIC ] ? : @"";
        item.redPacketTitle = [rs stringForColumn:TB_ROLLINGNEWSLIST_REDPACKETTITLE ] ? : @"";
        item.sponsoredIcon  = [rs stringForColumn:TB_ROLLINGNEWSLIST_REDPACKETSPONSORICON ] ? : @"";
        item.redPacketID    = [rs stringForColumn:TB_ROLLINGNEWSLIST_REDPACKETBID ] ? : @"";
        item.tvPlayNum      = [rs stringForColumn:TB_ROLLINGNEWSLIST_TVPLAYNUM ] ? : @"";
        item.tvPlayTime     = [rs stringForColumn:TB_ROLLINGNEWSLIST_TVPLAYTIME ] ? : @"";
        item.playVid        = [rs stringForColumn:TB_ROLLINGNEWSLIST_VID ];
        item.tvUrl          = [rs stringForColumn:TB_ROLLINGNEWSLIST_TVURL ] ? : @"";
        item.sourceName     = [rs stringForColumn:TB_ROLLINGNEWSLIST_SOURCENAME ] ? : @"";
        item.siteValue      = [rs intForColumn:TB_ROLLINGNEWSLIST_SITE];
        item.recomReasons   = [rs stringForColumn:TB_ROLLINGNEWSLIST_RECOMREASONS ] ? : @"";
        item.recomTime      = [rs stringForColumn:TB_ROLLINGNEWSLIST_RECOMTIME ] ? : @"";
        item.blueTitle      = [rs stringForColumn:TB_ROLLINGNEWSLIST_BLUETITLE ] ? : @"";
        item.recomInfo      = [rs stringForColumn:TB_ROLLINGNEWSLIST_RECOMINFO ] ? : @"";
        item.trainCardId    = [rs stringForColumn:TB_ROLLINGNEWSLIST_TRAINCARDID ] ? : @"";
        item.createAt       = [rs intForColumn:TB_PAPER_READFLAG_CREATE ];

        [newsList addObject:item];
	}
	
	return newsList;
}

- (NSDictionary *)getRollingNewsUpdateValuePairs:(RollingNewsListItem *)news {
	if (news == nil) {
		SNDebugLog(@"getRollingNewsUpdateValuePairs : Invalid news");
		return nil;
	}
	
	NSMutableDictionary *valuePairs	= [[NSMutableDictionary alloc] init];
    
	if (news.type != nil) {
		[valuePairs setObject:news.type forKey:TB_ROLLINGNEWSLIST_TYPE];
	}
	if (news.title != nil) {
		[valuePairs setObject:news.title forKey:TB_ROLLINGNEWSLIST_TITLE];
	}
	if (news.description != nil) {
		[valuePairs setObject:news.description forKey:TB_ROLLINGNEWSLIST_DESCRIPTION];
	}
	if (news.time != nil) {
		[valuePairs setObject:news.time forKey:TB_ROLLINGNEWSLIST_TIME];
	}
	if (news.commentNum != nil) {
		[valuePairs setObject:news.commentNum forKey:TB_ROLLINGNEWSLIST_COMMENTNUM];
	}
	if (news.digNum != nil) {
		[valuePairs setObject:news.digNum forKey:TB_ROLLINGNEWSLIST_DIGNUM];
	}
	if (news.listPic != nil) {
		[valuePairs setObject:news.listPic forKey:TB_ROLLINGNEWSLIST_LISTPIC];
	}
	if (news.link != nil) {
		[valuePairs setObject:news.link forKey:TB_ROLLINGNEWSLIST_LINK];
	}
	if (news.readFlag != nil) {
		[valuePairs setObject:news.readFlag forKey:TB_ROLLINGNEWSLIST_READFLAG];
	}
	if (news.downloadFlag != nil) {
		[valuePairs setObject:news.downloadFlag forKey:TB_ROLLINGNEWSLIST_DOWNLOADFLAG];
	}
    if (news.form != nil) {
		[valuePairs setObject:news.form forKey:TB_ROLLINGNEWSLIST_FORM];
	}
    if (news.listPicsNumber != nil) {
		[valuePairs setObject:news.listPicsNumber forKey:TB_ROLLINGNEWSLIST_LISTPICSNUMBER];
	}
    if (news.timelineIndex != nil) {
		[valuePairs setObject:news.timelineIndex forKey:TB_ROLLINGNEWSLIST_TIMELINEINDEX];
	}
    if (news.hasVideo != nil) {
		[valuePairs setObject:news.hasVideo forKey:TB_ROLLINGNEWSLIST_HASVIDEO];
	}
    if (news.hasAudio != nil) {
        [valuePairs setObject:news.hasAudio forKey:TB_ROLLINGNEWSLIST_HASAUDIO];
    }
    if (news.hasVote != nil) {
        [valuePairs setObject:news.hasVote forKey:TB_ROLLINGNEWSLIST_HASVOTE];
    }
    if (news.updateTime != nil) {
		[valuePairs setObject:news.updateTime forKey:TB_ROLLINGNEWSLIST_UPDATETIME];
	}
    if (news.expired != nil) {
		[valuePairs setObject:news.expired forKey:TB_ROLLINGNEWSLIST_EXPIRED];
	}
    if (news.media != nil) {
		[valuePairs setObject:news.media forKey:TB_ROLLINGNEWSLIST_MEDIA];
	}
    if (news.isWeather) {
        [valuePairs setObject:news.isWeather forKey:TB_ROLLINGNEWSLIST_ISWEATHER];
    }
    if (news.city) {
        [valuePairs setObject:news.city forKey:TB_ROLLINGNEWSLIST_CITY];
    }
    if (news.tempHigh) {
        [valuePairs setObject:news.tempHigh forKey:TB_ROLLINGNEWSLIST_TEMPHIGH];
    }
    if (news.tempLow) {
        [valuePairs setObject:news.tempLow forKey:TB_ROLLINGNEWSLIST_TEMPLOW];
    }
    if (news.weather) {
        [valuePairs setObject:news.weather forKey:TB_ROLLINGNEWSLIST_WEATHER];
    }
    if (news.weak) {
        [valuePairs setObject:news.weak forKey:TB_ROLLINGNEWSLIST_WEAK];
    }
    if (news.liveTemperature) {
        [valuePairs setObject:news.liveTemperature forKey:TB_ROLLINGNEWSLIST_LIVETEMPERTURE];
    }
    if (news.pm25) {
        [valuePairs setObject:news.pm25 forKey:TB_ROLLINGNEWSLIST_PM25];
    }
    if (news.quality) {
        [valuePairs setObject:news.quality forKey:TB_ROLLINGNEWSLIST_QUALITY];
    }
    if (news.weatherIoc) {
        [valuePairs setObject:news.weatherIoc forKey:TB_ROLLINGNEWSLIST_WEATHERIOC];
    }
    if (news.isRecom) {
        [valuePairs setObject:news.isRecom forKey:TB_ROLLINGNEWSLIST_ISRECOM];
    }
    if (news.recomType) {
        [valuePairs setObject:news.recomType forKey:TB_ROLLINGNEWSLIST_RECOMTYPE];
    }
    if (news.liveStatus) {
        [valuePairs setObject:news.liveStatus forKey:TB_ROLLINGNEWSLIST_LIVESTATUS];
    }
    if (news.local) {
        [valuePairs setObject:news.local forKey:TB_ROLLINGNEWSLIST_LOCAL];
    }
    if (news.wind) {
        [valuePairs setObject:news.wind forKey:TB_ROLLINGNEWSLIST_WIND];
    }
    if (news.thirdPartUrl) {
        [valuePairs setObject:news.thirdPartUrl forKey:TB_ROLLINGNEWSLIST_THIRDPARTURL];
    }
    if (news.gbcode) {
        [valuePairs setObject:news.gbcode forKey:TB_ROLLINGNEWSLIST_GBCODE];
    }
    if (news.date) {
        [valuePairs setObject:news.date forKey:TB_ROLLINGNEWSLIST_DATE];
    }
    if (news.localIoc) {
        [valuePairs setObject:news.localIoc forKey:TB_ROLLINGNEWSLIST_LOCALIOC];
    }
    if (news.templateId) {
        [valuePairs setObject:news.templateId forKey:TB_ROLLINGNEWSLIST_TEMPLATEID];
    }
    if (news.templateType) {
        [valuePairs setObject:news.templateType forKey:TB_ROLLINGNEWSLIST_TEMPLATETYPE];
    }
    if (news.dataString) {
        [valuePairs setObject:news.dataString forKey:TB_ROLLINGNEWSLIST_DATASTRING];
    }
    if (news.playTime) {
        [valuePairs setObject:news.playTime forKey:TB_ROLLINGNEWSLIST_PLAYTIME];
    }
    if (news.liveType) {
        [valuePairs setObject:news.liveType forKey:TB_ROLLINGNEWSLIST_LIVETYPE];
    }
    if (news.isFlash) {
        [valuePairs setObject:news.isFlash forKey:TB_ROLLINGNEWSLIST_ISFLASH];
    }
    if (news.token) {
        [valuePairs setObject:news.token forKey:TB_ROLLINGNEWSLIST_TOKEN];
    }
    if (news.position) {
        [valuePairs setObject:news.position forKey:TB_ROLLINGNEWSLIST_POSITION];
    }
    if (news.isHasSponsorships) {
        [valuePairs setObject:news.isHasSponsorships forKey:TB_ROLLINGNEWSLIST_HASSPONSORSHIPS];
    }
    if (news.iconText) {
        [valuePairs setObject:news.iconText forKey:TB_ROLLINGNEWSLIST_ICONTEXT];
    }
    if (news.newsTypeText) {
        [valuePairs setObject:news.newsTypeText forKey:TB_ROLLINGNEWSLIST_NEWSTYPETEXT];
    }
    if (news.sponsorships) {
        [valuePairs setObject:news.sponsorships forKey:TB_ROLLINGNEWSLIST_SPONSORSHIPS];
    }
    if (news.cursor) {
        [valuePairs setObject:news.cursor forKey:TB_ROLLINGNEWSLIST_CURSOR];
    }
    if (news.subId != nil) {
        [valuePairs setObject:news.subId forKey:TB_ROLLINGNEWSLIST_SUBID];
    }
    [valuePairs setObject:@(news.adReportState) forKey:TB_ROLLINGNEWSLIST_ADREPORTSTATE];
    
    NSNumber *statsTypeObj = @(news.newsStatsType);
    if (!!statsTypeObj) {
        [valuePairs setObject:statsTypeObj forKey:TB_ROLLINGNEWSLIST_STATSTYPE];
    }
    
    NSNumber *topNewsObj = @(news.isTopNews);
    if (topNewsObj) {
        [valuePairs setObject:topNewsObj forKey:TB_ROLLINGNEWSLIST_TOPNEWS];
    }
    
    NSNumber *isLatestObj = @(news.isLatest);
    if (isLatestObj) {
        [valuePairs setObject:isLatestObj forKey:TB_ROLLINGNEWSLIST_LATEST];
    }
    
    if (news.bgPic != nil) {
        [valuePairs setObject:news.bgPic forKey:TB_ROLLINGNEWSLIST_REDPACKETBGPIC];
    }
    if (news.sponsoredIcon != nil) {
        [valuePairs setObject:news.sponsoredIcon forKey:TB_ROLLINGNEWSLIST_REDPACKETSPONSORICON];
    }
    if (news.redPacketTitle != nil) {
        [valuePairs setObject:news.redPacketTitle forKey:TB_ROLLINGNEWSLIST_REDPACKETTITLE];
    }
    if (news.redPacketID != nil) {
        [valuePairs setObject:news.redPacketID forKey:TB_ROLLINGNEWSLIST_REDPACKETBID];
    }
    if (news.tvPlayNum != nil) {
        [valuePairs setObject:news.tvPlayNum forKey:TB_ROLLINGNEWSLIST_TVPLAYNUM];
    }
    if (news.tvPlayTime != nil) {
        [valuePairs setObject:news.tvPlayTime forKey:TB_ROLLINGNEWSLIST_TVPLAYTIME];
    }
    if (news.playVid != nil) {
        [valuePairs setObject:news.playVid forKey:TB_ROLLINGNEWSLIST_VID];
    }
    if (news.tvUrl != nil) {
        [valuePairs setObject:news.tvUrl forKey:TB_ROLLINGNEWSLIST_TVURL];
    }
    if (news.sourceName != nil) {
        [valuePairs setObject:news.sourceName forKey:TB_ROLLINGNEWSLIST_SOURCENAME];
    }
    NSNumber *siteValueObj = @(news.siteValue);
    if (siteValueObj) {
        [valuePairs setObject:siteValueObj forKey:TB_ROLLINGNEWSLIST_SITE];
    }
    if (news.recomReasons) {
        [valuePairs setObject:news.recomReasons forKey:TB_ROLLINGNEWSLIST_RECOMREASONS];
    }
    if (news.recomTime) {
        [valuePairs setObject:news.recomTime forKey:TB_ROLLINGNEWSLIST_RECOMTIME];
    }
    if (news.blueTitle) {
        [valuePairs setObject:news.blueTitle forKey:TB_ROLLINGNEWSLIST_BLUETITLE];
    }
    if (news.recomInfo) {
        [valuePairs setObject:news.recomInfo forKey:TB_ROLLINGNEWSLIST_RECOMINFO];
    }
    if (news.trainCardId) {
        [valuePairs setObject:news.trainCardId forKey:TB_ROLLINGNEWSLIST_TRAINCARDID];
    }
    
    return valuePairs;
}

- (NewsArticleItem *)getNewsArticelByChannelId:(NSString *)channelId
                                        newsId:(NSString *)newsId {
	if ([channelId length] == 0 || [newsId length] == 0) {
		SNDebugLog(@"getNewsArticelByChannelId : Invalid channelId=%@ or newsId=%@", channelId, newsId);
		return nil;
	}
	__block NSArray *newsArticleList = nil;
    [[SNDatabase readQueue] inDatabase:^(FMDatabase *db) {
        FMResultSet *rs	= [db executeQuery:@"SELECT * FROM tbNewsArticle WHERE channelId=? AND newsId=?", channelId, newsId];
        if ([db hadError]) {
            SNDebugLog(@"getNewsArticelByChannelId: executeQuery error %d : %@,channelId=%@,newsId=%@"
                       ,[db lastErrorCode],[db lastErrorMessage],channelId,newsId);
            return;
        }
        
        newsArticleList	= [self getRollingNewsArticleFromResultSet:rs inDatabase:db];
        [rs close];
    }];
    
		
	switch ([newsArticleList count]) {
		case 0:
			SNDebugLog(@"getNewsArticelByChannelId : Can't find news article with channelId = %@,newsId = %@", channelId, newsId);
			return nil;
		case 1:
			return (NewsArticleItem *)[newsArticleList objectAtIndex:0];
		default:
			SNDebugLog(@"getNewsArticelByChannelId : Find %d news article with channelId = %@,newsId = %@", [newsArticleList count], channelId, newsId);
			return (NewsArticleItem *)[newsArticleList objectAtIndex:0];
	}
}

- (BOOL)addSingleRollingArticleOrUpdate:(NewsArticleItem *)newsArtcile {
	return [self addSingleRollingArticle:newsArtcile updateIfExist:YES];
}

- (BOOL)addSingleRollingArticleIfNotExist:(NewsArticleItem *)newsArtcile {
	return [self addSingleRollingArticle:newsArtcile updateIfExist:NO];
}

- (BOOL)addSingleRollingArticle:(NewsArticleItem *)newsArtcile
                  updateIfExist:(BOOL)bUpdateIfExist {
	return [self addSingleNewsArticle:newsArtcile
                        updateIfExist:bUpdateIfExist
                           withOption:ADDNEWSARTICLE_BY_CHANNELID];
}

#pragma mark -
#pragma mark rolling news list
- (NSArray *)getRollingNewsListNextPageByChannelId:(NSString *)channelId
                                     timelineIndex:(NSString *)timelineIndex {
	if ([channelId length] == 0) {
		SNDebugLog(@"getRollingNewsListByChannelId : Invalid channelId=%@ timelineIndex=%@", channelId, timelineIndex);
		return nil;
	}
    __block NSArray *rollingNewsList = nil;
    __block typeof(self) weakSelf = self;
    __block typeof(FMDatabaseQueue *) weakDataBase = [SNDatabase readQueue];
    [weakDataBase inDatabase:^(FMDatabase *db) {
        NSString *stmt = nil;
        if (timelineIndex.length > 0) {
            stmt = [NSString stringWithFormat:@"SELECT * FROM tbRollingNewsList WHERE channelId=? AND (form='1' or form='5') AND timelineIndex >= %@ ORDER BY timelineIndex DESC", timelineIndex];
        } else {
            stmt = [NSString stringWithFormat:@"SELECT * FROM tbRollingNewsList WHERE channelId=? AND (form='1' or form='5') ORDER BY timelineIndex DESC"];
        }
        
        FMResultSet *rs = [db executeQuery:stmt, channelId];
        if ([db hadError]) {
            SNDebugLog(@"getRollingNewsListByChannelId : executeQuery error :%d,%@,channelId=%@ timelineIndex=%@"
                       , [db lastErrorCode], [db lastErrorMessage], channelId,  timelineIndex);
            return;
        }
        
        rollingNewsList	= [weakSelf getRollingNewsListFromResultSet:rs];
        
        [rs close];
    }];
	
	return rollingNewsList;
}

- (NSArray *)getRollingNewsListNextPageByChannelId:(NSString *)channelId
                                     timelineIndex:(NSString *)timelineIndex
                                          pageSize:(int)pageSize {
	if ([channelId length] == 0 || pageSize < 1) {
		SNDebugLog(@"getRollingNewsListByChannelId : Invalid channelId=%@ timelineIndex=%@ pageSize=%d",channelId, timelineIndex, pageSize);
		return nil;
	}
    
    __block NSArray *rollingNewsList = nil;
    [[SNDatabase readQueue] inDatabase:^(FMDatabase *db) {
        NSString *stmt = nil;
        if (timelineIndex.length > 0) {
            stmt = [NSString stringWithFormat:@"SELECT * FROM tbRollingNewsList WHERE channelId=? AND form='1' AND timelineIndex < %@ ORDER BY timelineIndex DESC Limit %d", timelineIndex, pageSize];
        } else {
            //过滤首页， 我的订阅入口 wangyy
            stmt = [NSString stringWithFormat:@"SELECT * FROM tbRollingNewsList WHERE channelId=? AND form='1'  AND templateType!='16' ORDER BY timelineIndex DESC Limit %d", pageSize];
        }
        FMResultSet *rs	= [db executeQuery:stmt, channelId];
        if ([db hadError]) {
            SNDebugLog(@"getRollingNewsListByChannelId : executeQuery error :%d,%@,channelId=%@ timelineIndex=%@ pageSize=%d"
                       ,[db lastErrorCode],[db lastErrorMessage],channelId, timelineIndex, pageSize);
            return;
        }
        
        rollingNewsList	= [self getRollingNewsListFromResultSet:rs];
        [rs close];
    }];
    
	return rollingNewsList;
}

- (NSArray *)getRollingNewsListByChannelId:(NSString *)channelId
                                      page:(int)page
                                  pageSize:(int)pageSize {
	if ([channelId length] == 0 || page < 1 || pageSize < 1) {
		SNDebugLog(@"getRollingNewsListByChannelId : Invalid channelId=%@ page=%d pageSize=%d", channelId, page, pageSize);
		return nil;
	}
	__block NSArray *rollingNewsList = nil;
    [[SNDatabase readQueue] inDatabase:^(FMDatabase *db) {
        NSString *stmt = [NSString stringWithFormat:@"SELECT * FROM tbRollingNewsList WHERE channelId=? AND form='1' ORDER BY timelineIndex DESC Limit %d Offset %d", pageSize, (page - 1) * pageSize];
        FMResultSet *rs	= [db executeQuery:stmt, channelId];
        if ([db hadError]) {
            SNDebugLog(@"getRollingNewsListByChannelId : executeQuery error :%d,%@,channelId=%@ page=%d pageSize=%d"
                       , [db lastErrorCode], [db lastErrorMessage], channelId, page, pageSize);
            return;
        }
        
        rollingNewsList	= [self getRollingNewsListFromResultSet:rs];
        [rs close];
    }];
    
	return rollingNewsList;
}

- (NSArray *)getRollingHeadlineListByChannelId:(NSString *)channelId {
	if ([channelId length] == 0) {
		SNDebugLog(@"getRollingNewsListByChannelId : Invalid channelId=%@", channelId);
		return nil;
	}
    __block NSArray *rollingNewsList = nil;
    [[SNDatabase readQueue] inDatabase:^(FMDatabase *db) {
        FMResultSet *rs	= [db executeQuery:@"SELECT * FROM tbRollingNewsList WHERE channelId=? AND form='2'", channelId];
        if ([db hadError]) {
            SNDebugLog(@"getRollingNewsListByChannelId : executeQuery error :%d,%@,channelId=%@", [db lastErrorCode], [db lastErrorMessage], channelId);
            return;
        }
        
        rollingNewsList	= [self getRollingNewsListFromResultSet:rs];
        [rs close];
    }];
	
	return rollingNewsList;
}

- (NSArray *)getUnreadRollingExpressListByChannelId:(NSString *)channelId {
	if ([channelId length] == 0) {
		SNDebugLog(@"getRollingNewsListByChannelId : Invalid channelId=%@", channelId);
		return nil;
	}
	__block NSArray *rollingNewsList = nil;
    [[SNDatabase readQueue] inDatabase:^(FMDatabase *db) {
        FMResultSet *rs	= [db executeQuery:@"SELECT * FROM tbRollingNewsList WHERE channelId=? AND form='3' AND readFlag='0'", channelId];
        if ([db hadError]) {
            SNDebugLog(@"getRollingNewsListByChannelId : executeQuery error :%d,%@,channelId=%@", [db lastErrorCode], [db lastErrorMessage], channelId);
            return;
        }
        
        rollingNewsList	= [self getRollingNewsListFromResultSet:rs];
        [rs close];
    }];
		
	return rollingNewsList;
}

- (NSArray *)getLastRollingExpressListByChannelId:(NSString *)channelId {
	if ([channelId length] == 0) {
		SNDebugLog(@"getRollingNewsListByChannelId : Invalid channelId=%@", channelId);
		return nil;
	}
	__block NSArray *rollingNewsList = nil;
    [[SNDatabase readQueue] inDatabase:^(FMDatabase *db) {
        FMResultSet *rs	= [db executeQuery:@"SELECT * FROM tbRollingNewsList WHERE channelId=? AND form='3'",channelId];
        if ([db hadError]) {
            SNDebugLog(@"getRollingNewsListByChannelId : executeQuery error :%d,%@,channelId=%@", [db lastErrorCode], [db lastErrorMessage], channelId);
            return;
        }
        
        rollingNewsList	= [self getRollingNewsListFromResultSet:rs];
        [rs close];
	}];
	
	return rollingNewsList;
}

- (NSArray *)getLastRollingRecomendListByChannelId:(NSString *)channelId {
    if ([channelId length] == 0) {
		SNDebugLog(@"getRollingNewsListByChannelId : Invalid channelId=%@", channelId);
		return nil;
	}
	__block NSArray *rollingNewsList = nil;
    [[SNDatabase readQueue] inDatabase:^(FMDatabase *db) {
        FMResultSet *rs	= [db executeQuery:@"SELECT * FROM tbRollingNewsList WHERE channelId=? AND form='4' ORDER BY timelineIndex", channelId];
        if ([db hadError]) {
            SNDebugLog(@"getRollingNewsListByChannelId : executeQuery error :%d,%@,channelId=%@", [db lastErrorCode], [db lastErrorMessage], channelId);
            return;
        }
        
        rollingNewsList	= [self getRollingNewsListFromResultSet:rs];
        [rs close];
	}];
	
	return rollingNewsList;
}

- (RollingNewsListItem *)getRollingNewsListItemByChannelId:(NSString *)channelId newsId:(NSString *)newsId {
	if ([channelId length] == 0 || [newsId length] == 0) {
		SNDebugLog(@"getRollingNewsListItemByChannelId : Invalid channelId=%@ or newsId=%@", channelId, newsId);
		return nil;
	}
	__block NSArray *rollingNewsList = nil;
    [[SNDatabase readQueue] inDatabase:^(FMDatabase *db) {
        FMResultSet *rs	= [db executeQuery:@"SELECT * FROM tbRollingNewsList WHERE channelId=? AND newsId=?", channelId, newsId];
        if ([db hadError]) {
            SNDebugLog(@"getRollingNewsListItemByChannelId : executeQuery error :%d,%@,channelId=%@,newsId=%@", [db lastErrorCode], [db lastErrorMessage], channelId,newsId);
            return;
        }
        
        rollingNewsList	= [self getRollingNewsListFromResultSet:rs];
        [rs close];
    }];
	
	switch ([rollingNewsList count]) {
		case 0:
			return nil;
		case 1:
			return [rollingNewsList objectAtIndex:0];
		default:
			SNDebugLog(@"getRollingNewsListItemByChannelId : More than one(%d) news item exist", [rollingNewsList count]);
			return [rollingNewsList objectAtIndex:0];
	}
}

- (RollingNewsListItem *)getRollingNewsListItemByNewsId:(NSString *)newsId {
	if ([newsId length] == 0) {
		SNDebugLog(@"getRollingNewsListItemByChannelId : Invalid newsId=%@", newsId);
		return nil;
	}
	__block NSArray *rollingNewsList = nil;
    [[SNDatabase readQueue] inDatabase:^(FMDatabase *db) {
        FMResultSet *rs	= [db executeQuery:@"SELECT * FROM tbRollingNewsList WHERE newsId=?", newsId];
        if ([db hadError]) {
            SNDebugLog(@"getRollingNewsListItemByChannelId : executeQuery error :%d,%@, newsId=%@"
                       , [db lastErrorCode], [db lastErrorMessage], newsId);
            return;
        }
        
        rollingNewsList	= [self getRollingNewsListFromResultSet:rs];
        [rs close];
    }];
	
	switch ([rollingNewsList count]) {
		case 0:
			return nil;
		case 1:
			return [rollingNewsList objectAtIndex:0];
		default:
			SNDebugLog(@"getRollingNewsListItemByChannelId : More than one(%d) news item exist",[rollingNewsList count]);
			return [rollingNewsList objectAtIndex:0];
	}
}

- (NSArray *)getRollingNewsListNextPageByChannelId:(NSString *)channelId
                                     timelineIndex:(NSString *)timelineIndex
                                              form:(NSString *)form
                                          pageSize:(int)pageSize
                                          dateTime:(NSNumber *)dateTime
                                             later:(BOOL)later
{
    if ([channelId length] == 0) {
        SNDebugLog(@"getRollingNewsListByChannelId : Invalid channelId=%@ timelineIndex=%@ form = %@ createTime=%@ ",channelId, timelineIndex, form, dateTime);
        return nil;
    }
    __block NSArray *rollingNewsList = nil;
    __block typeof(self) weakSelf = self;
    __block typeof(FMDatabaseQueue *) weakDataBase = [SNDatabase readQueue];
    
    NSString *laterStr = later ? @">=" : @"<";
    [weakDataBase inDatabase:^(FMDatabase *db) {
        NSString *stmt = nil;
        if (timelineIndex.length > 0) {
            stmt = [NSString stringWithFormat:@"SELECT * FROM tbRollingNewsList WHERE channelId=? AND form=? AND timelineIndex <%@ AND createAt %@? ORDER BY timelineIndex DESC Limit %d",timelineIndex, laterStr, pageSize];
        } else {
            stmt = [NSString stringWithFormat:@"SELECT * FROM tbRollingNewsList WHERE channelId=? AND form=? AND createAt %@? ORDER BY timelineIndex DESC Limit %d", laterStr, pageSize];
        }
        
        FMResultSet *rs = [db executeQuery:stmt, channelId, form, dateTime];
        if ([db hadError]) {
            SNDebugLog(@"getRollingNewsListByChannelId : executeQuery error :%d,%@,channelId=%@ timelineIndex=%@ from = %@ dateTime = %@"
                       , [db lastErrorCode], [db lastErrorMessage], channelId,  timelineIndex,form, dateTime);
            return;
        }
        
        rollingNewsList = [weakSelf getRollingNewsListFromResultSet:rs];
        [rs close];
    }];
    
    return rollingNewsList;
}

- (NSArray *)getRollingNewsListNextPageByChannelId:(NSString *)channelId
                                     timelineIndex:(NSString *)timelineIndex
                                              form:(NSString *)form
                                       trainCardId:(NSString *)trainCardId {
    if ([channelId length] == 0) {
        SNDebugLog(@"getRollingNewsListByChannelId : Invalid channelId=%@ timelineIndex=%@ form=%@  trainCardId =%@", channelId, timelineIndex, form, trainCardId);
        return nil;
    }
    __block NSArray *rollingNewsList = nil;
    __block typeof(self) weakSelf = self;
    __block typeof(FMDatabaseQueue *) weakDataBase = [SNDatabase readQueue];
    [weakDataBase inDatabase:^(FMDatabase *db) {
        NSString *stmt = nil;
        stmt = [NSString stringWithFormat:@"SELECT * FROM tbRollingNewsList WHERE channelId=? AND form=? AND trainCardId = ? ORDER BY timelineIndex DESC "];
        
        FMResultSet *rs = [db executeQuery:stmt, channelId, form,trainCardId];
        if ([db hadError]) {
            SNDebugLog(@"getRollingNewsListByChannelId : executeQuery error :%d,%@,channelId=%@ timelineIndex=%@ form = %@, trainCardId = %@", [db lastErrorCode], [db lastErrorMessage], channelId,  timelineIndex, form, trainCardId);
            return;
        }
        
        rollingNewsList = [weakSelf getRollingNewsListFromResultSet:rs];
        [rs close];
    }];
    
    return rollingNewsList;
}

- (NSArray *)getRollingFocusNewsListByChannelId:(NSString *)channelId trainCardId:(NSString *)trainCardId {
    if ([channelId length] == 0) {
        SNDebugLog(@"getRollingFocusNewsListByChannelId : Invalid channelId=%@ trainCardId=%@", channelId,trainCardId);
        return nil;
    }
    __block NSArray *rollingNewsList = nil;
    __block typeof(self) weakSelf = self;
    __block typeof(FMDatabaseQueue *) weakDataBase = [SNDatabase readQueue];
    [weakDataBase inDatabase:^(FMDatabase *db) {
        NSString *stmt = nil;
        if (trainCardId && trainCardId.length > 0) {
            stmt = [NSString stringWithFormat:@"SELECT * FROM tbRollingNewsList WHERE channelId=? AND  (form='5' or form='7') AND trainCardId=?  ORDER BY timelineIndex DESC "];
        } else {
            stmt = [NSString stringWithFormat:@"SELECT * FROM tbRollingNewsList WHERE channelId=? AND  (form='5' or form='7') ORDER BY timelineIndex DESC "];
        }
        
        FMResultSet *rs = [db executeQuery:stmt, channelId, trainCardId];
        if ([db hadError]) {
            SNDebugLog(@"getRollingFocusNewsListByChannelId : executeQuery error :%d,%@,channelId=%@ trainCardId=%@", [db lastErrorCode], [db lastErrorMessage], channelId, trainCardId);
            return;
        }
        
        rollingNewsList = [weakSelf getRollingNewsListFromResultSet:rs];
        [rs close];
    }];
    
    return rollingNewsList;
}

- (BOOL)addSingleRollingNewsListItem:(RollingNewsListItem *)news {
	return [self addSingleRollingNewsListItem:news updateIfExist:NO];
}

- (BOOL)addSingleRollingNewsListItem:(RollingNewsListItem *)news
                       updateIfExist:(BOOL)bUpdateIfExist {
    __block BOOL result = YES;
    [[SNDatabase writeQueue] inTransaction:^(FMDatabase *db, BOOL *rollback) {
        result = [self addSingleRollingNewsListItem:news updateIfExist:bUpdateIfExist inDatabase:db];
        if (!result) {
            *rollback = YES;
        }
    }];
    return result;
}

- (BOOL)addSingleRollingNewsListItem:(RollingNewsListItem *)news
                       updateIfExist:(BOOL)bUpdateIfExist
                          inDatabase:(FMDatabase *)db {
	if (news == nil) {
		SNDebugLog(@"addSingleRollingNewsListItem : Invalid news item");
		return NO;
	}
	
	if ([news.channelId length] == 0) {
		SNDebugLog(@"addSingleRollingNewsListItem : Invalid news item,channelId=%@",news.channelId);
		return NO;
	}
	
	//首先检查是否已经存在
	FMResultSet *rs	= nil;
	if ([news.channelId length] != 0 ){
        rs = [db executeQuery:@"SELECT * FROM tbRollingNewsList WHERE channelId=? AND newsId=? AND trainCardId=?", news.channelId, news.newsId,news.trainCardId];
	}
	
	
	if ([db hadError]) {
		SNDebugLog(@"addSingleRollingNewsListItem : executeQuery error:%d,%@",[db lastErrorCode], [db lastErrorMessage]);
		return NO;
	}
	
	NSArray *rollingNewsList = [self getRollingNewsListFromResultSet:rs];
	[rs close];
	if ([rollingNewsList count] > 0) {
		if (!bUpdateIfExist) {
			SNDebugLog(@"addSingleRollingNewsListItem : RollingNews with channelId=%@,newsId=%@ already exist",news.channelId,news.newsId);
			return YES; //pass, not quit
		} else {
			//判断这个新闻缓存是否过期，保存后便于读取article时刷新缓存
            RollingNewsListItem *cache = [rollingNewsList objectAtIndex:0];
            news.expired = cache.expired;
            
            if (news.updateTime) {
                if (![cache.updateTime isEqualToString:news.updateTime]) {
                    news.expired = @"1";
                }
            }
            
            if (cache.isTopNews) {
                return YES;
            }
            
			//准备更新
			NSDictionary *valuePairs = [self getRollingNewsUpdateValuePairs:news];
			BOOL bUpdated = NO;

            bUpdated = [self updateRollingNewsListItemByChannelId:news.channelId newsId:news.newsId
                                               trainCardId:news.trainCardId withValuePairs:valuePairs inDatabase:db];
			
			if (!bUpdated) {
				SNDebugLog(@"addSingleRollingNewsListItem : RollingNews with channelId=%@,newsId=%@ already exist,update failed" ,news.channelId,news.newsId);
				return NO;
			}
			return YES;
		}
	} else {
        //执行插入操作
        [db executeUpdate:@"INSERT INTO tbRollingNewsList (ID,channelId,subId,pubId,pubName,newsId,type,title,description,time,commentNum,digNum,listPic \
         ,link,readFlag,downloadFlag,form,listPicsNumber,timelineIndex,hasVideo,hasAudio,hasVote,updateTime,expired,createAt,recomiconday,recomiconnight,media,isRecom,recomType,liveStatus,local,isWeather,city,tempHigh,tempLow,weather,pm25,quality,weatherIoc,wind,thirdPartUrl,gbcode,date,localIoc,templateId,templateType,dataString,playTime,liveType,isFlash,token,position,statsType,adType,adAbPosition,adPosition,refreshCount,loadMoreCount,scope,appChannel,newsChannel,morePageNum,isHasSponsorships,iconText,sponsorships,cursor,adReportState,topNews,isLatest,weak,liveTemperature,redPacketTitle,redPacketBgPic,redPacketSponsorIcon,redPacketID,tvPlayNum,tvPlayTime,vid,tvUrl,sourceName,SITE,recomReasons,recomTime,blueTitle,newsTypeText,recomInfo,trainCardId) VALUES (NULL,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?)",news.channelId,news.subId,news.pubId,news.pubName,news.newsId ,news.type,news.title,news.description,news.time,news.commentNum,news.digNum,news.listPic,news.link,news.readFlag,news.downloadFlag, news.form, news.listPicsNumber, news.timelineIndex, news.hasVideo, news.hasAudio, news.hasVote, news.updateTime, @"1",[NSDate nowDateToSysytemIntervalNumber],news.recomIconDay,news.recomIconNight, news.media,news.isRecom,news.recomType,news.liveStatus,news.local,news.isWeather,news.city,news.tempHigh,news.tempLow,news.weather,news.pm25,news.quality,news.weatherIoc,news.wind,news.thirdPartUrl,news.gbcode,news.date,news.localIoc,news.templateId,news.templateType,news.dataString,news.playTime,news.liveType,news.isFlash,news.token,news.position,@(news.newsStatsType), news.adType, @(news.adAbPosition), @(news.adPosition), @(news.refreshCount), @(news.loadMoreCount), news.scope, @(news.appChannel), @(news.newsChannel),@(news.morePageNum),news.isHasSponsorships,news.iconText,news.sponsorships,news.cursor,@(news.adReportState),@(news.isTopNews),@(news.isLatest),news.weak,news.liveTemperature,news.title,news.bgPic,news.sponsoredIcon,news.redPacketID,news.tvPlayNum,news.tvPlayTime,news.playVid,news.tvUrl,news.sourceName,@(news.siteValue),news.recomReasons,news.recomTime,news.blueTitle,news.newsTypeText, news.recomInfo,news.trainCardId];

		if ([db hadError]) {
            SNDebugLog(@"addSingleRollingNewsListItem : executeUpdate error:%d,%@",[db lastErrorCode],[db lastErrorMessage]);
			SNDebugLog(@"addSingleRollingNewsListItem : executeUpdate error:%d,%@",[db lastErrorCode],[db lastErrorMessage]);
			return NO;
		}
		
		return YES;
	}
}

- (BOOL)addMultiRollingNewsListItem:(NSArray *)newsList {
	if ([newsList count] == 0) {
		SNDebugLog(@"addMultiRollingNewsListItem : empty news list");
		return NO;
	}
	
	__block BOOL bSucceed = YES;
    [[SNDatabase writeQueue] inTransaction:^(FMDatabase *db, BOOL *rollback) {
        for (NSInteger nIndex = [newsList count] - 1; nIndex>= 0; nIndex--) {
            RollingNewsListItem *news = [newsList objectAtIndex:nIndex];
            bSucceed = [self addSingleRollingNewsListItem:news updateIfExist:NO inDatabase:db];
            if (!bSucceed) {
                SNDebugLog(@"addMultiRollingNewsListItem : Failed");
                *rollback = YES;
                return;
            }
        }
    }];
	return bSucceed;
}

- (BOOL)addMultiRollingNewsListItem:(NSArray *)newsList
                      updateIfExist:(BOOL)bUpdateIfExist {
	if ([newsList count] == 0) {
		SNDebugLog(@"addMultiRollingNewsListItem : empty news list");
		return NO;
	}
	
	__block BOOL bSucceed = YES;
    [[SNDatabase writeQueue] inTransaction:^(FMDatabase *db, BOOL *rollback) {
        for (NSInteger nIndex = [newsList count] - 1; nIndex>= 0; nIndex--) {
            RollingNewsListItem *news = [newsList objectAtIndex:nIndex];
            bSucceed = [self addSingleRollingNewsListItem:news updateIfExist:bUpdateIfExist inDatabase:db];
            if (!bSucceed) {
                SNDebugLog(@"addMultiRollingNewsListItem : Failed");
                *rollback = YES;
                return;
            }
        }
    }];
	
	return bSucceed;
}
- (BOOL)updateRollingNewsListItemByChannelId:(NSString *)channelId
                                      newsId:(NSString *)newsId
                              withValuePairs:(NSDictionary *)valuePairs {
    __block BOOL result = YES;
    [[SNDatabase writeQueue] inTransaction:^(FMDatabase *db, BOOL *rollback) {
        result = [self updateRollingNewsListItemByChannelId:channelId newsId:newsId withValuePairs:valuePairs inDatabase:db];
        if (!result) {
            *rollback = YES;
        }
    }];
    return  result;
}

- (BOOL)updateRollingNewsListItemByNewsId:(NSString *)newsId
                           withValuePairs:(NSDictionary *)valuePairs {
    __block BOOL result = YES;
    [[SNDatabase writeQueue] inTransaction:^(FMDatabase *db, BOOL *roolback){
        result = [self updateRollingNewsListItemByNewsId:newsId withValuePairs:valuePairs inDatabase:db];
        if ((!result)) {
            *roolback = YES;
        }
    }];
    return result;
}

- (BOOL)updateRollingNewsListItemByChannelId:(NSString *)channelId
                                      newsId:(NSString *)newsId
                              withValuePairs:(NSDictionary *)valuePairs inDatabase:(FMDatabase *)db {
	if ([channelId length] == 0 || [newsId length] == 0) {
		SNDebugLog(@"updateRollingNewsListItemByChannelId : Invalid channelId=%@ or newsId=%@",channelId,newsId);
		return NO;
	}
	
	if ([valuePairs count] == 0) {
		SNDebugLog(@"updateRollingNewsListItemByChannelId : Invalid valuePairs");
		return NO;
	}
	
	//执行更新
    NSMutableDictionary *_mDic = nil;
    if (!!valuePairs) {
        _mDic = [NSMutableDictionary dictionaryWithDictionary:valuePairs];
//        [_mDic setObject:[NSDate nowDateToSysytemIntervalNumber] forKey:TB_CREATEAT_COLUMN];
    }
	NSDictionary *updateStatementsInfo	= [self formatUpdateSetStatementsInfoFromValuePairs:_mDic ignoreNilValue:NO];
	if ([updateStatementsInfo count] == 0) {
		SNDebugLog(@"updateRollingNewsListItemByChannelId : formatUpdateSetStatementsInfoFromValuePairs failed");
		return NO;
	}
	
	NSString *statement = [updateStatementsInfo objectForKey:UPDATE_SETSTATEMNT];
	NSMutableArray *updateArguments	= [updateStatementsInfo objectForKey:UPDATE_SETARGUMENTS];
	
	NSString *updateStatement = [NSString stringWithFormat:@"UPDATE %@ %@ WHERE %@=? AND %@=?", TB_ROLLINGNEWSLIST, statement, TB_ROLLINGNEWSLIST_CHANNELID, TB_ROLLINGNEWSLIST_NEWSID];
	
	[updateArguments addObject:channelId];
	[updateArguments addObject:newsId];
	
	[db executeUpdate:updateStatement withArgumentsInArray:updateArguments];
	if ([db hadError]) {
		SNDebugLog(@"updateRollingNewsListItemByChannelId : executeUpdate error:%d,%@,channelId=%@,newsId=%@"
				   , [db lastErrorCode], [db lastErrorMessage], channelId, newsId);
		return NO;
	}
	
	return YES;
}

- (BOOL)updateRollingNewsListItemByChannelId:(NSString *)channelId
                                      newsId:(NSString *)newsId
                                 trainCardId:(NSString *)trainCardId
                              withValuePairs:(NSDictionary *)valuePairs inDatabase:(FMDatabase *)db {
    if ([channelId length] == 0 || [newsId length] == 0) {
        SNDebugLog(@"updateRollingNewsListItemByChannelId : Invalid channelId=%@ or newsId=%@",channelId,newsId);
        return NO;
    }
    
    if ([valuePairs count] == 0) {
        SNDebugLog(@"updateRollingNewsListItemByChannelId : Invalid valuePairs");
        return NO;
    }
    
    //执行更新
    NSMutableDictionary *_mDic = nil;
    if (!!valuePairs) {
        _mDic = [NSMutableDictionary dictionaryWithDictionary:valuePairs];
        [_mDic setObject:[NSDate nowDateToSysytemIntervalNumber] forKey:TB_CREATEAT_COLUMN];
    }
    NSDictionary *updateStatementsInfo = [self formatUpdateSetStatementsInfoFromValuePairs:_mDic ignoreNilValue:NO];
    if ([updateStatementsInfo count] == 0) {
        SNDebugLog(@"updateRollingNewsListItemByChannelId : formatUpdateSetStatementsInfoFromValuePairs failed");
        return NO;
    }
    
    NSString *statement = [updateStatementsInfo objectForKey:UPDATE_SETSTATEMNT];
    NSMutableArray *updateArguments    = [updateStatementsInfo objectForKey:UPDATE_SETARGUMENTS];
    
    NSString *updateStatement = [NSString stringWithFormat:@"UPDATE %@ %@ WHERE %@=? AND %@=?", TB_ROLLINGNEWSLIST, statement, TB_ROLLINGNEWSLIST_CHANNELID, TB_ROLLINGNEWSLIST_NEWSID];
    [updateArguments addObject:channelId];
    [updateArguments addObject:newsId];
    
    if (trainCardId && trainCardId.length > 0) {
        updateStatement = [NSString stringWithFormat:@"UPDATE %@ %@ WHERE %@=? AND %@=? AND %@=?", TB_ROLLINGNEWSLIST, statement, TB_ROLLINGNEWSLIST_CHANNELID, TB_ROLLINGNEWSLIST_NEWSID,TB_ROLLINGNEWSLIST_TRAINCARDID];
        [updateArguments addObject:trainCardId];
    }
    
    
    [db executeUpdate:updateStatement withArgumentsInArray:updateArguments];
    if ([db hadError]) {
        SNDebugLog(@"updateRollingNewsListItemByChannelId : executeUpdate error:%d,%@,channelId=%@,newsId=%@, trainCardId=%@"
                   , [db lastErrorCode], [db lastErrorMessage], channelId, newsId,trainCardId);
        return NO;
    }
    
    return YES;
}

- (BOOL)updateRollingNewsListItemByNewsId:(NSString *)newsId
                           withValuePairs:(NSDictionary *)valuePairs
                               inDatabase:(FMDatabase *)db {
	if ([newsId length] == 0) {
		SNDebugLog(@"updateRollingNewsListItemByChannelId : Invalid newsId=%@", newsId);
		return NO;
	}
	
	if ([valuePairs count] == 0) {
		SNDebugLog(@"updateRollingNewsListItemByChannelId : Invalid valuePairs");
		return NO;
	}
	
	//执行更新
    NSMutableDictionary *_mDic = nil;
    if (!!valuePairs) {
        _mDic = [NSMutableDictionary dictionaryWithDictionary:valuePairs];
        [_mDic setObject:[NSDate nowDateToSysytemIntervalNumber] forKey:TB_CREATEAT_COLUMN];
    }
    
	NSDictionary *updateStatementsInfo	= [self formatUpdateSetStatementsInfoFromValuePairs:_mDic ignoreNilValue:NO];
	if ([updateStatementsInfo count] == 0) {
		SNDebugLog(@"updateRollingNewsListItemByChannelId : formatUpdateSetStatementsInfoFromValuePairs failed");
		return NO;
	}
	
	NSString *statement				= [updateStatementsInfo objectForKey:UPDATE_SETSTATEMNT];
	NSMutableArray *updateArguments	= [updateStatementsInfo objectForKey:UPDATE_SETARGUMENTS];
	
	NSString *updateStatement = [NSString stringWithFormat:@"UPDATE %@ %@ WHERE %@=?", TB_ROLLINGNEWSLIST, statement, TB_ROLLINGNEWSLIST_NEWSID];
	
	[updateArguments addObject:newsId];
	
	[db executeUpdate:updateStatement withArgumentsInArray:updateArguments];
	if ([db hadError]) {
		SNDebugLog(@"updateRollingNewsListItemByChannelId : executeUpdate error:%d,%@,newsId=%@"
				   , [db lastErrorCode], [db lastErrorMessage], newsId);
		return NO;
	}
	
	return YES;
}

- (BOOL)updateFocusToTrainItemByChannelId:(NSString *)channelId {
    __block BOOL result = YES;
    [[SNDatabase writeQueue] inTransaction:^(FMDatabase *db, BOOL *rollback) {
        result = [db executeUpdate:@"UPDATE tbRollingNewsList set templateType ='79' WHERE channelId=? AND templateType='202'", channelId];
        if ([db hadError]) {
            *rollback = YES;
        }
    }];
    return result;
}

- (BOOL)updateFocusToTrainNewsByChannelId:(NSString *)channelId {
    __block BOOL result = YES;
    [[SNDatabase writeQueue] inTransaction:^(FMDatabase *db, BOOL *rollback) {
        result = [db executeUpdate:@"UPDATE tbRollingNewsList set form ='8' WHERE channelId=? AND (form='5' or form ='7')", channelId];
        if ([db hadError]) {
            *rollback = YES;
        }
    }];
    return result;
}

- (BOOL)deleteRollingNewsListItemByChannelId:(NSString *)channelId
                                      newsId:(NSString *)newsId {
    //删除单条新闻
	if ([channelId length] == 0 || [newsId length] == 0) {
		SNDebugLog(@"deleteRollingNewsListItemByChannelId : Invalid channelId=%@ or newsId=%@",channelId,newsId);
		return NO;
	}
    __block BOOL result = YES;
    [[SNDatabase writeQueue] inTransaction:^(FMDatabase *db, BOOL *rollback) {
        result = [db executeUpdate:@"DELETE FROM tbRollingNewsList WHERE channelId=? AND newsId=?", channelId, newsId];
        if ([db hadError]) {
            SNDebugLog(@"deleteRollingNewsListItemByChannelId : executeUpdate error :%d,%@,channelId=%@,newsId=%@"
                       , [db lastErrorCode], [db lastErrorMessage], channelId,newsId);
            *rollback = YES;
            return;
        }
    }];
    return result;
}

- (BOOL)markRollingNewsListItemAsReadByChannelId:(NSString *)channelId
                                          newsId:(NSString *)newsId {
    NSDictionary *kevValue = [NSDictionary dictionaryWithObject:@"1" forKey:TB_ROLLINGNEWSLIST_READFLAG];
    return [self updateRollingNewsListItemByChannelId:channelId newsId:newsId withValuePairs:kevValue];
}

- (BOOL)markRollingNewsListItemAsNotExpiredByChannelId:(NSString *)channelId
                                                newsId:(NSString *)newsId {
    NSDictionary *kevValue = [NSDictionary dictionaryWithObject:@"0" forKey:TB_ROLLINGNEWSLIST_EXPIRED];
    return [self updateRollingNewsListItemByChannelId:channelId newsId:newsId withValuePairs:kevValue];
}

- (BOOL)markRollingNewsListItemAsReadAndNotExpiredByChannelId:(NSString *)channelId newsId:(NSString *)newsId {
    NSDictionary *kevValue = [NSDictionary dictionaryWithObjectsAndKeys:@"1", TB_ROLLINGNEWSLIST_READFLAG, @"0", TB_ROLLINGNEWSLIST_EXPIRED, nil];
    return [self updateRollingNewsListItemByChannelId:channelId newsId:newsId withValuePairs:kevValue];
}

- (BOOL)checkRollingNewsListItemReadOrNotByChannelId:(NSString *)channelId newsId:(NSString *)newsId {
    RollingNewsListItem *item = [self getRollingNewsListItemByChannelId:channelId newsId:newsId];
    return [@"1" isEqualToString:item.readFlag];
}

//TODO:清理
- (BOOL)clearRollingEditNewsListByChannelId:(NSString *)channelId {
    __block BOOL result = YES;
    [[SNDatabase writeQueue] inTransaction:^(FMDatabase *db, BOOL *rollback) {
        result = [db executeUpdate:@"DELETE FROM tbRollingNewsList WHERE channelId=? AND form='1'", channelId];
        if ([db hadError]) {
            *rollback = YES;
        }
    }];
    return result;
}

- (BOOL)clearRollingLocalWeatherNewsByChannelId:(NSString *)channelId {
    __block BOOL result = YES;
    [[SNDatabase writeQueue] inTransaction:^(FMDatabase *db, BOOL *rollback) {
        result = [db executeUpdate:@"DELETE FROM tbRollingNewsList WHERE channelId=? AND form='1' AND type='16' ", channelId];
        if ([db hadError]) {
            *rollback = YES;
        }
    }];
    return result;
}

- (BOOL)clearRollingRecommendNewsListByChannelId:(NSString *)channelId {
    __block BOOL result = YES;
    [[SNDatabase writeQueue] inTransaction:^(FMDatabase *db, BOOL *rollback) {
        result = [db executeUpdate:@"DELETE FROM tbRollingNewsList WHERE channelId=? AND form='4'", channelId];
        if ([db hadError]) {
            *rollback = YES;
        }
    }];
	return result;
}

//没有调用过
/*
- (BOOL)clearAllRecommendNewsList {
    __block BOOL result = YES;
    [[SNDatabase writeQueue] inTransaction:^(FMDatabase *db, BOOL *rollback) {
        result = [db executeUpdate:@"DELETE FROM tbRollingNewsList WHERE form='4'"];
        if ([db hadError]) {
            *rollback = YES;
        }
    }];
	return result;
}*/

- (BOOL)clearAllTopRollingNewsList:(NSString *)channelId {
    __block BOOL result = YES;
    [[SNDatabase writeQueue] inTransaction:^(FMDatabase *db, BOOL *rollback) {
        result = [db executeUpdate:@"DELETE FROM tbRollingNewsList WHERE channelId=? AND topNews='1'", channelId];
        if ([db hadError]) {
            *rollback = YES;
        }
    }];
    return result;
}

//TODO:
- (BOOL)clearAllOtherRollingNewsList:(NSString *)channelId {
    __block BOOL result = YES;
    [[SNDatabase writeQueue] inTransaction:^(FMDatabase *db, BOOL *rollback) {
        result = [db executeUpdate:@"DELETE FROM tbRollingNewsList WHERE channelId=? AND topNews='0' AND isLatest='0'", channelId];
        if ([db hadError]) {
            *rollback = YES;
        }
    }];
    return result;
}

- (BOOL)updateLatestRollingNewsList:(NSString *)channelId {
    __block BOOL result = YES;
    [[SNDatabase writeQueue] inTransaction:^(FMDatabase *db, BOOL *rollback) {
        result = [db executeUpdate:@"UPDATE tbRollingNewsList set isLatest = '0' WHERE channelId=? AND topNews='0'", channelId];
        if ([db hadError]) {
            *rollback = YES;
        }
    }];
    return result;
}

//TODO:刷新没存数据库
- (BOOL)clearRefreshRollingNewsItem:(NSString *)channelId {
    __block BOOL result = YES;
    [[SNDatabase writeQueue] inTransaction:^(FMDatabase *db, BOOL *rollback) {
        result = [db executeUpdate:@"DELETE FROM tbRollingNewsList WHERE channelId=? AND templateType='201'", channelId];
        if ([db hadError]) {
            *rollback = YES;
        }
    }];
    return result;
}

- (NSString *)getMaxRollingTimelineIndexByChannelId:(NSString *)channelId {
	if ([channelId length] == 0) {
		SNDebugLog(@"getMaxRollingTimelineIndexByChannelId : Invalid channelId=%@", channelId);
		return nil;
	}
    NSMutableArray *ids = [NSMutableArray array];
    
    [[SNDatabase readQueue] inDatabase:^(FMDatabase *db) {
        FMResultSet *rs	= [db executeQuery:@"SELECT MAX(timelineIndex) AS maxTimelineIndex FROM tbRollingNewsList WHERE channelId=? AND form='1'", channelId];
        if ([db hadError]) {
            SNDebugLog(@"getMaxRollingTimelineIndexByChannelId : executeQuery error :%d,%@,channelId=%@", [db lastErrorCode], [db lastErrorMessage], channelId);
            return;
        }
        while ([rs next]) {
            @autoreleasepool {
                [ids addObject:[NSString stringWithFormat:@"%d", [rs intForColumn:@"maxTimelineIndex"]]];
            }
        }
    }];
	
	if (ids.count > 0) {
        return [ids objectAtIndex:0];
    }
    
	return @"0";
}

- (NSString *)getMinRollingTimelineIndexByChannelId:(NSString *)channelId {
	if ([channelId length] == 0) {
		SNDebugLog(@"getMinRollingTimelineIndexByChannelId : Invalid channelId=%@", channelId);
		return nil;
	}
    NSMutableArray *ids = [NSMutableArray array];

    [[SNDatabase readQueue] inDatabase:^(FMDatabase *db) {
        FMResultSet *rs	= [db executeQuery:@"SELECT MIN(timelineIndex) AS minTimelineIndex FROM tbRollingNewsList WHERE channelId=? AND form='1'", channelId];
        if ([db hadError]) {
            SNDebugLog(@"getMinRollingTimelineIndexByChannelId : executeQuery error :%d,%@,channelId=%@", [db lastErrorCode], [db lastErrorMessage], channelId);
            return;
        }
        while ([rs next]) {
            @autoreleasepool {
                [ids addObject:[NSString stringWithFormat:@"%d", [rs intForColumn:@"minTimelineIndex"]]];
            }
        }
    }];
	
	if (ids.count > 0) {
        return [ids objectAtIndex:0];
    }
    
	return @"-1";
}

- (NSString *)getMaxRollingTimelineIndexByChannelId:(NSString *)channelId
                                               form1:(NSString *)form1
                                               form2:(NSString *)form2
{
    if ([channelId length] == 0) {
        SNDebugLog(@"getMaxRollingTimelineIndexByChannelId : Invalid channelId=%@ form1=%@ form2=%@",channelId, form1, form2);
        return nil;
    }
    NSMutableArray *ids = [NSMutableArray array];
    
    [[SNDatabase readQueue] inDatabase:^(FMDatabase *db) {
        FMResultSet *rs    = [db executeQuery:@"SELECT MAX(timelineIndex) AS maxTimelineIndex FROM tbRollingNewsList WHERE channelId=?",channelId];
        if ([db hadError]) {
            SNDebugLog(@"getMaxRollingTimelineIndexByChannelId : executeQuery error :%d,%@,channelId=%@ form1=%@ or from2=%@"
                       ,[db lastErrorCode],[db lastErrorMessage],channelId, form1, form2);
            return;
        }
        while ([rs next]) {
            @autoreleasepool {
                [ids addObject:[NSString stringWithFormat:@"%d", [rs intForColumn:@"maxTimelineIndex"]]];
            }
        }
    }];
    
    if (ids.count > 0) {
        return [ids objectAtIndex:0];
    }
    
    return @"0";
}

//删除滚动新闻列表
- (BOOL)clearRollingNewsListExceptChannelID:(NSString *)channelId {
    __block BOOL result = YES;
    [[SNDatabase writeQueue] inTransaction:^(FMDatabase *db, BOOL *rollback) {
        result = [db executeUpdate:@"DELETE FROM tbRollingNewsList WHERE channelId !=?", channelId];
        if (!result) {
            *rollback = YES;
            return;
        }
    }];
    return result;
}

- (BOOL)clearRollingNewsList {
    //判断是不是要闻改版版本
    __block BOOL result = YES;
    [[SNDatabase writeQueue] inTransaction:^(FMDatabase *db, BOOL *rollback) {
       result = [db executeUpdate:@"DELETE FROM tbRollingNewsList"];
        if (!result) {
            *rollback = YES;
            return;
        }
    }];
	return result;
}

- (BOOL)clearRollingNewsListByChannelId:(NSString *)channelId {
    //如果是要闻改版, 保留要闻数据
    if ([SNNewsFullscreenManager newsChannelChanged] && [@"1" isEqualToString:channelId]) {
        return NO;
    }
    //判断要闻
    __block BOOL result = YES;
    [[SNDatabase writeQueue] inTransaction:^(FMDatabase *db, BOOL *rollback) {
        result = [db executeUpdate:@"DELETE FROM tbRollingNewsList WHERE channelId=?", channelId];
        if (!result) {
            *rollback = YES;
            return;
        }
    }];
    return result;
}

- (BOOL)clearHomeChannelRollingNewsList{
    __block BOOL result = YES;
    [[SNDatabase writeQueue] inTransaction:^(FMDatabase *db, BOOL *rollback) {
        result = [db executeUpdate:@"DELETE FROM tbRollingNewsList WHERE channelId=1"];
        if (!result) {
            *rollback = YES;
            return;
        }
    }];
    return result;
}

- (BOOL)clearRollingLoadMoreNewsListByChannelId:(NSString *)channelId {
    __block BOOL result = YES;
    [[SNDatabase writeQueue] inTransaction:^(FMDatabase *db, BOOL *rollback) {
        result = [db executeUpdate:@"DELETE FROM tbRollingNewsList WHERE channelId=? AND templateType='20'", channelId];
        if ([db hadError]) {
            *rollback = YES;
        }
    }];
    return result;
}

- (BOOL)clearRollingRecommendNewsListByChannelId:(NSString *)channelId
                                            form:(NSString *)form {
    __block BOOL result = YES;
    [[SNDatabase writeQueue] inTransaction:^(FMDatabase *db, BOOL *rollback) {
        result = [db executeUpdate:@"DELETE FROM tbRollingNewsList WHERE channelId=? AND form=?", channelId, form];
        if ([db hadError]) {
            *rollback = YES;
        }
    }];
    return result;
}

#pragma mark - About RollingNews list download - by Handy
- (BOOL)saveDownloadedRollingNewsItemArrayToDB:(NSArray *)downloadedRollingNews
                                  forChannelID:(NSString *)channelID {
    __block BOOL result = YES;
    [[SNDatabase writeQueue] inTransaction:^(FMDatabase *db, BOOL *rollback) {
        result = [self clearRollingHeadlinesForDownloadByChannelId:channelID inDatabase:db];
        if (!result) {
            *rollback = YES;
            return;
        }
        
        result = [self clearRollingExpressNewsListForDownloadByChannelId:channelID inDatabase:db];
        if (!result) {
            *rollback = YES;
            return;
        }
        
        result = [self addMultiRollingNewsListItemForDownload:downloadedRollingNews updateIfExist:NO inDatabase:db];
        if (!result) {
            *rollback = YES;
            return;
        }
    }];
    
    return result;
}

- (BOOL)clearRollingHeadlinesForDownloadByChannelId:(NSString *)channelId
                                         inDatabase:(FMDatabase *)db {
	[db executeUpdate:@"DELETE FROM tbRollingNewsList WHERE channelId=? AND form='2'", channelId];
	if ([db hadError]) {
		SNDebugLog(@"===ERROR: Clear rollingHeadlinesForDownloadByChannelId : executeUpdate error :%d,%@", [db lastErrorCode],[db lastErrorMessage]);
		return NO;
	}
	return YES;
}

- (BOOL)clearRollingExpressNewsListForDownloadByChannelId:(NSString *)channelId inDatabase:(FMDatabase *)db {
	[db executeUpdate:@"DELETE FROM tbRollingNewsList WHERE channelId=? AND form='3'", channelId];
	if ([db hadError]) {
		SNDebugLog(@"==ERROR: Clear rollingHeadlineListByChannelId : executeUpdate error :%d,%@", [db lastErrorCode],[db lastErrorMessage]);
		return NO;
	}
	return YES;
}

- (BOOL)addMultiRollingNewsListItemForDownload:(NSArray *)newsList
                                 updateIfExist:(BOOL)bUpdateIfExist
                                    inDatabase:(FMDatabase *)db {
	if ([newsList count] == 0) {
		SNDebugLog(@"addMultiRollingNewsListItem : empty news list");
		return NO;
	}
	
	BOOL bSucceed = YES;
	for(NSInteger nIndex = [newsList count] - 1;nIndex>= 0;nIndex--) {
		RollingNewsListItem *news = [newsList objectAtIndex:nIndex];
		if (![self addSingleRollingNewsListItem:news updateIfExist:bUpdateIfExist inDatabase:db]) {
			bSucceed = NO;
			SNDebugLog(@"addMultiRollingNewsListItem : Failed");
			break;
		}
	}
	return bSucceed;
}

@end
