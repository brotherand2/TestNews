//
//  CacheMgr_News.m
//  sohunews
//
//  Created by 李 雪 on 11-10-18.
//  Copyright 2011 Sohu.com Inc. All rights reserved.
//
#import "SNDatabase_Private.h"
#import "SNDatabase_NewsImage.h"
#import "SNDatabase_News.h"
#import "SNURLDataResponse.h"
#import "SNNewsImageUrlParser.h"
#import "SNDBManager.h"


@implementation SNDatabase(News)

-(NSArray*)getNewsArticleFromResultSet:(FMResultSet*)rs inDatabase:(FMDatabase *)db
{
	if (rs == nil) {
		SNDebugLog(@"getNewsArticleFromResultSet: Invalid rs");
		return nil;
	}
	
	NSMutableArray *newsArticle = [[NSMutableArray alloc] init];
	while ([rs next]) 
	{
		NewsArticleItem *item	= [[NewsArticleItem alloc] init];
        for (int i = 0 ; i< [rs columnCount]; i ++) {
            NSString *columnName =  [rs columnNameForIndex:i];
            id value = [rs objectForColumnIndex:i];
            if (value != (id)[NSNull null]) {
                [item setValue:value forKey:columnName];
            }
        }
        //获取分享图集
        NSString *termId = (item.termId == nil ? item.channelId : item.termId);
        item.shareImages    = [self getNewsShareImageListByTermId:termId newsId:item.newsId inDatabase:db];
		[newsArticle addObject:item];
	}
	
	return newsArticle;
}

-(NSDictionary*)getNewsArticleUpdateValuePairs:(NewsArticleItem *)newsArtcile withOption:(ADDNEWSARTICLE_OPTION)option
{
	if (newsArtcile == nil) {
		SNDebugLog(@"getNewsArticleUpdateValuePairs : Invalid newsArtcile");
		return nil;
	}
	
	NSMutableDictionary *valuePairs	= [[NSMutableDictionary alloc] init];
	switch (option) {
		case ADDNEWSARTICLE_BY_CHANNELID:
		{
			if (newsArtcile.channelId != nil) {
				[valuePairs setObject:newsArtcile.channelId forKey:TB_NEWSARTICLE_CHANNELID];
			}
		}
			break;

		case ADDNEWSARTICLE_BY_TERMID:
		default:
		{
			if (newsArtcile.termId != nil) {
				[valuePairs setObject:newsArtcile.termId forKey:TB_NEWSARTICLE_TERMID];
			}
		}
			break;
	}
	
	if (newsArtcile.type != nil) {
		[valuePairs setObject:newsArtcile.type forKey:TB_NEWSARTICLE_TYPE];
	}
	if (newsArtcile.title != nil) {
		[valuePairs setObject:newsArtcile.title forKey:TB_NEWSARTICLE_TITLE];
	}
    if (newsArtcile.newsMark != nil) {
        [valuePairs setObject:newsArtcile.newsMark forKey:TB_NEWSARTICLE_NEWSMARK];
    }
    if (newsArtcile.originFrom != nil) {
        [valuePairs setObject:newsArtcile.originFrom forKey:TB_NEWSARTICLE_ORIGINFROM];
    }
    if (newsArtcile.originTitle != nil) {
        [valuePairs setObject:newsArtcile.originTitle forKey:TB_NEWSARTICLE_ORIGINTITLE];
    }
	if (newsArtcile.time != nil) {
		[valuePairs setObject:newsArtcile.time forKey:TB_NEWSARTICLE_TIME];
	}
    if (newsArtcile.updateTime != nil) {
        [valuePairs setObject:newsArtcile.updateTime forKey:TB_NEWSARTICLE_UPDATETIME];
    }
	if (newsArtcile.from != nil) {
		[valuePairs setObject:newsArtcile.from forKey:TB_NEWSARTICLE_FROM];
	}
	if (newsArtcile.commentNum != nil) {
		[valuePairs setObject:newsArtcile.commentNum forKey:TB_NEWSARTICLE_COMMENTNUM];
	}
	if (newsArtcile.digNum != nil) {
		[valuePairs setObject:newsArtcile.digNum forKey:TB_NEWSARTICLE_DIGNUM];
	}
	if (newsArtcile.content != nil) {
		[valuePairs setObject:newsArtcile.content forKey:TB_NEWSARTICLE_CONTENT];
	}
	if (newsArtcile.link != nil) {
		[valuePairs setObject:newsArtcile.link forKey:TB_NEWSARTICLE_LINK];
	}
	if (newsArtcile.nextName != nil) {
		[valuePairs setObject:newsArtcile.nextName forKey:TB_NEWSARTICLE_NEXTNAME];
	}
	if (newsArtcile.nextId != nil) {
		[valuePairs setObject:newsArtcile.nextId forKey:TB_NEWSARTICLE_NEXTID];
	}
	if (newsArtcile.preName != nil) {
		[valuePairs setObject:newsArtcile.preName forKey:TB_NEWSARTICLE_PRENAME];
	}
	if (newsArtcile.preId != nil) {
		[valuePairs setObject:newsArtcile.preId forKey:TB_NEWSARTICLE_PREID];
	}
	if (newsArtcile.shareContent != nil) {
		[valuePairs setObject:newsArtcile.shareContent forKey:TB_NEWSARTICLE_SHARECONTENT];
	}
    if (newsArtcile.subId != nil) {
        [valuePairs setObject:newsArtcile.subId forKey:TB_NEWSARTICLE_SUBID];
    }
    if (newsArtcile.action != nil) {
        [valuePairs setObject:newsArtcile.action forKey:TB_NEWSARTICLE_ACTION];
    }
    if (newsArtcile.isPublished != nil) {
        [valuePairs setObject:newsArtcile.isPublished forKey:TB_NEWSARTICLE_IS_PUBLISH];
    }
    if (newsArtcile.editNewsLink != nil) {
        [valuePairs setObject:newsArtcile.editNewsLink forKey:TB_NEWSARTICLE_EDIT_LINK];
    }
    if (newsArtcile.operators != nil) {
        [valuePairs setObject:newsArtcile.operators forKey:TB_NEWSARTICLE_OPERATORS];
    }
    if (newsArtcile.logoUrl) {
        [valuePairs setObject:newsArtcile.logoUrl forKey:TB_NEWSARTICLE_LOGOURL];
    }
    if (newsArtcile.linkUrl) {
        [valuePairs setObject:newsArtcile.linkUrl forKey:TB_NEWSARTICLE_LINKURL];
    }
    if (newsArtcile.h5link) {
        [valuePairs setObject:newsArtcile.h5link forKey:TB_NEWSARTICLE_H5LINK];
    }
    if (newsArtcile.favIcon) {
        [valuePairs setObject:newsArtcile.favIcon forKey:TB_NEWSARTICLE_FAVICON];
    }
    if (newsArtcile.mediaName) {
        [valuePairs setObject:newsArtcile.mediaName forKey:TB_NEWSARTICLE_MEDIANAME];
    }
    if (newsArtcile.mediaLink) {
        [valuePairs setObject:newsArtcile.mediaLink forKey:TB_NEWSARTICLE_MEDIALINK];
    }
    if (newsArtcile.optimizeRead) {
        [valuePairs setObject:newsArtcile.optimizeRead forKey:TB_NEWSARTICLE_OPTIMIZEREAD];
    }
    if (newsArtcile.tagChannelsStr) {
        [valuePairs setObject:newsArtcile.tagChannelsStr forKey:TB_NEWSARTICLE_TAGCHANNELS];
    }
    if (newsArtcile.stocksStr) {
        [valuePairs setObject:newsArtcile.stocksStr forKeyedSubscript:TB_NEWSARTICLE_STOCKS];
    }
    [valuePairs setObject:[NSNumber numberWithBool:newsArtcile.cmtRead] forKey:TB_NEWSARTICLE_CMTREAD];
    [valuePairs setObject:[NSNumber numberWithBool:newsArtcile.favour] forKey:TB_NEWSARTICLE_FAVOUR];
    [valuePairs setObject:[NSNumber numberWithInteger:newsArtcile.newsType] forKey:TB_NEWSARTICLE_NEWSTYPE];
	[valuePairs setObject:[NSNumber numberWithInteger:newsArtcile.openType] forKey:TB_NEWSARTICLE_OPENTYPE];
	return valuePairs;
}

-(NewsArticleItem*)getNewsArticelByTermId:(NSString*)termId newsId:(NSString*)newsId
{
	if ([termId length] == 0 || [newsId length] == 0) {
		SNDebugLog(@"getNewsArticelByTermId : Invalid termId=%@ or newsId=%@",termId,newsId);
		return nil;
	}
    __block NewsArticleItem *newsArticleItem = nil;
	[[SNDatabase readQueue] inDatabase:^(FMDatabase *db) {
        FMResultSet *rs	= [db executeQuery:@"SELECT * FROM tbNewsArticle WHERE termId=? AND newsId=?",termId,newsId];
        if ([db hadError])
        {
            SNDebugLog(@"getNewsArticelByTermId: executeQuery error %d : %@,newsId=%@",[db lastErrorCode],[db lastErrorMessage],newsId);
            return;
        }
        
        NSArray *newsArticleList	= [self getNewsArticleFromResultSet:rs inDatabase:db];
        [rs close];
        
        switch ([newsArticleList count]) {
            case 0:
                SNDebugLog(@"getNewsArticelByTermId : Can't find news article with termId = %@,newsId = %@",termId,newsId);
                return;
            case 1:
                newsArticleItem = [newsArticleList objectAtIndex:0];
                return;
            default:
                SNDebugLog(@"getNewsArticelByTermId : Find %d news article with termId = %@,newsId = %@",[newsArticleList count],termId,newsId);
                newsArticleItem = [newsArticleList objectAtIndex:0];
                return ;
        }
    }];
    return newsArticleItem;
}

-(BOOL)addSingleNewsArticleOrUpdate:(NewsArticleItem*)newsArtcile
{
	return [self addSingleNewsArticle:newsArtcile updateIfExist:YES];
}

-(BOOL)addSingleNewsArticleIfNotExist:(NewsArticleItem*)newsArtcile
{
	return [self addSingleNewsArticle:newsArtcile updateIfExist:NO];
}

-(BOOL)addSingleNewsArticle:(NewsArticleItem*)newsArtcile updateIfExist:(BOOL)bUpdateIfExist
{
	return [self addSingleNewsArticle:newsArtcile updateIfExist:bUpdateIfExist withOption:ADDNEWSARTICLE_BY_TERMID];
}

-(BOOL)addSingleNewsArticleOrUpdate:(NewsArticleItem*)newsArtcile withOption:(ADDNEWSARTICLE_OPTION)option
{
	return [self addSingleNewsArticle:newsArtcile updateIfExist:YES withOption:option];
}

-(BOOL)addSingleNewsArticleOrUpdate:(NewsArticleItem*)newsArtcile withOption:(ADDNEWSARTICLE_OPTION)option inDatabase:(FMDatabase *)db
{
	return [self addSingleNewsArticle:newsArtcile updateIfExist:YES withOption:option inDatabase:db];
}

-(BOOL)addSingleNewsArticleIfNotExist:(NewsArticleItem*)newsArtcile withOption:(ADDNEWSARTICLE_OPTION)option
{
	return [self addSingleNewsArticle:newsArtcile updateIfExist:NO withOption:option];
}

-(BOOL)addMultiNewsArticle:(NSArray*)newsArticleList withOption:(ADDNEWSARTICLE_OPTION)option
{
	return [self addMultiNewsArticle:newsArticleList updateIfExist:YES withOption:option];
}

-(BOOL)addSingleNewsArticle:(NewsArticleItem*)newsArtcile updateIfExist:(BOOL)bUpdateIfExist withOption:(ADDNEWSARTICLE_OPTION)option inDatabase:(FMDatabase *)db
{
	if (newsArtcile == nil) {
		SNDebugLog(@"addSingleNewsArticle : Invalid newsArtcile");
		return NO;
	}
	
	if ([[SNDBManager sharedInstance] isNewsArticleInDownloading:newsArtcile]) {
		SNDebugLog(@"addSingleNewsArticle : newsArtcile(newsId=%@,channelId=%@,termId=%@) is already in downloading"
				   ,newsArtcile.newsId,newsArtcile.channelId,newsArtcile.termId);
		return NO;
	}
	
	//判断重复插入
    BOOL result = YES;
    NSInteger count = 0;
    switch (option) {
        case ADDNEWSARTICLE_BY_CHANNELID:
            count = [db intForQuery:@"SELECT COUNT(*) FROM tbNewsArticle WHERE channelId=? AND newsId=?",newsArtcile.channelId,newsArtcile.newsId];
            break;

        case ADDNEWSARTICLE_BY_TERMID:
        default:
            count = [db intForQuery:@"SELECT COUNT(*) FROM tbNewsArticle WHERE termId=? AND newsId=?",newsArtcile.termId,newsArtcile.newsId];
            break;
    }
    
    if ([db hadError])
    {
        SNDebugLog(@"addSingleNewsArticle: executeQuery for exist one error %d : %@,newsArtcile:%@,option=%d"
                   ,[db lastErrorCode],[db lastErrorMessage],newsArtcile,option);
        return NO;
    }
    if (count > 0) {
        if (!bUpdateIfExist)
        {
            SNDebugLog(@"addSingleNewsArticle : news article=%@ already exists(count=%d),option=%d"
                       ,newsArtcile,count,option);
            return NO;
        }
        
        //执行更新操作
        NSDictionary *valuePairs	= [self getNewsArticleUpdateValuePairs:newsArtcile withOption:option];
        
        switch (option) {
            case ADDNEWSARTICLE_BY_CHANNELID:
            {
                result	= [self updateNewsArticleByChannelId:newsArtcile.channelId
                                                       newsId:newsArtcile.newsId
                                               withValuePairs:valuePairs
                                                addIfNotExist:NO inDatabase:db];
                
                [self deleteNewsImageByTermId:newsArtcile.channelId newsId:newsArtcile.newsId inDatabase:db];
            }
                break;

            case ADDNEWSARTICLE_BY_TERMID:
            default:
            {
                result	= [self updateNewsArticleByTermId:newsArtcile.termId
                                                    newsId:newsArtcile.newsId
                                            withValuePairs:valuePairs
                                             addIfNotExist:NO inDatabase:db];
                
                [self deleteNewsImageByTermId:newsArtcile.termId newsId:newsArtcile.newsId inDatabase:db];
            }
                break;
        }

        //加入分享图集
        [self addMultiNewsImage:newsArtcile.shareImages inDatabase:db];
    }
    else {
        newsArtcile.type    = [NSString stringWithFormat:@"%d",option];
        [self addNewsArticle:newsArtcile inDatabase:db];
    }
    return result;
}

-(BOOL)addSingleNewsArticle:(NewsArticleItem*)newsArtcile updateIfExist:(BOOL)bUpdateIfExist withOption:(ADDNEWSARTICLE_OPTION)option
{
    __block BOOL result = YES;
    [[SNDatabase writeQueue] inTransaction:^(FMDatabase *db, BOOL *rollback) {
        result = [self addSingleNewsArticle:newsArtcile updateIfExist:bUpdateIfExist withOption:option inDatabase:db];
        if (!result) {
            *rollback = YES;
        }
    }];
    return result;
}

-(BOOL)addNewsArticle:(NewsArticleItem *)newsArticle inDatabase:(FMDatabase *)db
{
	if (newsArticle == nil) {
		SNDebugLog(@"addNewsArticle : Invalid newsArtcile");
		return NO;
	}
	
	[db executeUpdate:@"INSERT INTO tbNewsArticle (ID,channelId,termId,newsId,type,title,newsMark,originFrom,originTitle,time,updateTime,source,commentNum,digNum,content \
	 ,link,readFlag,nextName,nextId,nextNewsLink, nextNewsLink2 ,preName,preId,shareContent,createAt,subId,action, isPublished, editNewsLink,operators,cmtStatus,cmtHint,logoUrl,linkUrl,cmtRead,favour,newsType,h5link,openType,favIcon,mediaName,mediaLink,optimizeRead,tagChannelsStr,stocksStr) VALUES (NULL,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?)"
	 ,newsArticle.channelId,newsArticle.termId,newsArticle.newsId,newsArticle.type,newsArticle.title,newsArticle.newsMark,newsArticle.originFrom,newsArticle.originTitle,newsArticle.time,newsArticle.updateTime,newsArticle.from,newsArticle.commentNum,newsArticle.digNum,newsArticle.content,newsArticle.link,newsArticle.readFlag,newsArticle.nextName,newsArticle.nextId,newsArticle.nextNewsLink, newsArticle.nextNewsLink2, newsArticle.preName,newsArticle.preId,newsArticle.shareContent, [NSDate nowTimeIntervalNumber],newsArticle.subId, newsArticle.action, newsArticle.isPublished, newsArticle.editNewsLink, newsArticle.operators,newsArticle.cmtStatus,newsArticle.cmtHint,newsArticle.logoUrl,newsArticle.linkUrl,[NSNumber numberWithBool:newsArticle.cmtRead],[NSNumber numberWithBool:newsArticle.favour],[NSNumber numberWithInteger:newsArticle.newsType],newsArticle.h5link,[NSNumber numberWithInteger:newsArticle.openType],newsArticle.favIcon,newsArticle.mediaName,newsArticle.mediaLink,newsArticle.optimizeRead,newsArticle.tagChannelsStr,newsArticle.stocksStr];
	
	if ([db hadError]) 
	{
		SNDebugLog(@"addNewsArticle: executeUpdate  error %d:%@,newsArtcile:%@"
				   ,[db lastErrorCode],[db lastErrorMessage],newsArticle);
		return NO;
	}
    
    SNDebugLog(@"add article %@ %@ %@", newsArticle.termId, newsArticle.channelId, newsArticle.newsId);
    
    //加入分享图集
    [self addMultiNewsImage:newsArticle.shareImages inDatabase:db];
	
	return YES;
}

-(BOOL)addNewsArticle:(NewsArticleItem *)newsArticle
{
    __block BOOL result = YES;
    [[SNDatabase writeQueue] inTransaction:^(FMDatabase *db, BOOL *rollback) {
        result = [self addNewsArticle:newsArticle inDatabase:db];
        if (!result) {
            *rollback = YES;
        }
    }];
    return result;
}

- (BOOL)updateNewsCmtReadByChannelId:(NSString*)channelId newsId:(NSString*)newsId hasRead:(BOOL)hasRead {
    __block BOOL result = YES;
    [[SNDatabase writeQueue] inTransaction:^(FMDatabase *db, BOOL *rollback) {
        result =  [db executeUpdate:@"update tbNewsArticle set cmtRead=? where channelId = ? and newsId = ?", [NSNumber numberWithBool:hasRead], channelId, newsId];
        if ([db hadError]) {
            *rollback = YES;
            SNDebugLog(@"updateNewsCmtReadByTermId : executeUpdate error :%d,%@"
                       ,[db lastErrorCode],[db lastErrorMessage]);
            return;
        }
    }];
    return result;
}

-(BOOL)updateNewsArticleByTermId:(NSString*)termId newsId:(NSString*)newsId withValuePairs:(NSDictionary*)valuePairs
{
	return [self updateNewsArticleByTermId:termId newsId:newsId withValuePairs:valuePairs addIfNotExist:NO];
}

-(BOOL)updateNewsArticleByTermId:(NSString*)termId newsId:(NSString*)newsId withValuePairs:(NSDictionary*)valuePairs addIfNotExist:(BOOL)bAddIfNotExist inDatabase:(FMDatabase *)db;
{
	if ([termId length] == 0 || [newsId length] == 0) {
		SNDebugLog(@"updateNewsArticleByTermId : Invalid termId=%@ or newsId=%@",termId,newsId);
		return NO;
	}
	
	if ([valuePairs count] == 0) {
		SNDebugLog(@"updateNewsArticleByTermId : Invalid valuePairs");
		return NO;
	}
	
	//查询此前是否已经存在
	FMResultSet *rs	= [db executeQuery:@"SELECT * FROM tbNewsArticle WHERE termId=? and newsId=?",termId,newsId];
	if ([db hadError]) {
		SNDebugLog(@"updateNewsArticleByTermId : executeQuery for exist one error :%d,%@,termId=%@,newsId=%@"
				   ,[db lastErrorCode],[db lastErrorMessage],termId,newsId);
		return NO;
	}
	
	NSArray *newsArticleInfo	= [self getNewsArticleFromResultSet:rs inDatabase:db];
	[rs close];
	
	//不存在，
	if([newsArticleInfo count] == 0)
	{
		if (!bAddIfNotExist) {
			SNDebugLog(@"updateNewsArticleByTermId : newsArticle with termId=%@ and newsId=%@ doesn't exist",termId,newsId);
			return NO;
		}
		//新增
		else {
			[db executeUpdate:@"INSERT INTO tbNewsArticle (ID,channelId,termId,newsId,type,title,newsMark,originFrom,originTitle,time,updateTime,source,commentNum,digNum,content \
			 ,link,readFlag,nextName,nextId, nextNewsLink, nextNewsLink2, preName,preId,shareContent, createAt, subId, action, isPublished, editNewsLink, operators,logoUrl,linkUrl,newsType,h5link,mediaName,mediaLink,optimizeRead,tagChannelsStr,stocksStr) VALUES (NULL,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?)"
			 ,[valuePairs objectForKey:TB_NEWSARTICLE_CHANNELID]
			 ,termId,newsId,[valuePairs objectForKey:TB_NEWSARTICLE_TYPE]
			 ,[valuePairs objectForKey:TB_NEWSARTICLE_TITLE]
             ,[valuePairs objectForKey:TB_NEWSARTICLE_NEWSMARK]
             ,[valuePairs objectForKey:TB_NEWSARTICLE_ORIGINFROM]
             ,[valuePairs objectForKey:TB_NEWSARTICLE_ORIGINTITLE]
             ,[valuePairs objectForKey:TB_NEWSARTICLE_TIME]
             ,[valuePairs objectForKey:TB_NEWSARTICLE_UPDATETIME]
			 ,[valuePairs objectForKey:TB_NEWSARTICLE_FROM],[valuePairs objectForKey:TB_NEWSARTICLE_COMMENTNUM]
			 ,[valuePairs objectForKey:TB_NEWSARTICLE_DIGNUM],[valuePairs objectForKey:TB_NEWSARTICLE_CONTENT]
			 ,[valuePairs objectForKey:TB_NEWSARTICLE_LINK],[valuePairs objectForKey:TB_NEWSARTICLE_READFLAG]
			 ,[valuePairs objectForKey:TB_NEWSARTICLE_NEXTNAME],[valuePairs objectForKey:TB_NEWSARTICLE_NEXTID]
             ,[valuePairs objectForKey:TB_NEWSARTICLE_NEXTNEWSLINK],[valuePairs objectForKey:TB_NEWSARTICLE_NEXTNEWSLINK2]
			 ,[valuePairs objectForKey:TB_NEWSARTICLE_PRENAME],[valuePairs objectForKey:TB_NEWSARTICLE_PREID]
			 ,[valuePairs objectForKey:TB_NEWSARTICLE_SHARECONTENT], [NSDate nowTimeIntervalNumber]
             ,[valuePairs objectForKey:TB_NEWSARTICLE_SUBID]
             ,[valuePairs objectForKey:TB_NEWSARTICLE_ACTION]
             ,[valuePairs objectForKey:TB_NEWSARTICLE_IS_PUBLISH]
             ,[valuePairs objectForKey:TB_NEWSARTICLE_EDIT_LINK]
             ,[valuePairs objectForKey:TB_NEWSARTICLE_OPERATORS]
             ,[valuePairs objectForKey:TB_NEWSARTICLE_LOGOURL]
             ,[valuePairs objectForKey:TB_NEWSARTICLE_LINKURL]
             ,[valuePairs objectForKey:TB_NEWSARTICLE_NEWSTYPE]
             ,[valuePairs objectForKey:TB_NEWSARTICLE_H5LINK]
             ,[valuePairs objectForKey:TB_NEWSARTICLE_MEDIANAME]
             ,[valuePairs objectForKey:TB_NEWSARTICLE_MEDIALINK]
             ,[valuePairs objectForKey:TB_NEWSARTICLE_OPTIMIZEREAD]
             ,[valuePairs objectForKey:TB_NEWSARTICLE_TAGCHANNELS]
             ,[valuePairs objectForKey:TB_NEWSARTICLE_STOCKS]
             ];
			
			if ([db hadError]) 
			{
				SNDebugLog(@"updateNewsArticleByTermId: executeUpdate insert item  error %d:%@,termId=%@,newsId=%@,valuePairs:%@"
						   ,[db lastErrorCode],[db lastErrorMessage],termId,newsId,valuePairs);
				return NO;
			}
			
			SNDebugLog(@"updateNewsArticleByTermId: insert newsArticle,termId=%@,newsId=%@,valuePairs:%@",termId,newsId,valuePairs);
			return YES;
		}
	}
	
	//如果该项存在，则执行更新操作
    NSMutableDictionary *_mDic = nil;
    if (!!valuePairs) {
        _mDic = [NSMutableDictionary dictionaryWithDictionary:valuePairs];
        [_mDic setObject:[NSDate nowTimeIntervalNumber] forKey:TB_CREATEAT_COLUMN];
    }
	NSDictionary *updateSetStatementsInfo = [self formatUpdateSetStatementsInfoFromValuePairs:_mDic ignoreNilValue:NO];
	if ([updateSetStatementsInfo count] == 0) {
		return NO;
	}
	
	NSString *setStatement			= [updateSetStatementsInfo objectForKey:UPDATE_SETSTATEMNT];
	NSMutableArray *valueArguments	= [updateSetStatementsInfo objectForKey:UPDATE_SETARGUMENTS];
	NSString *updateStatements		= [NSString stringWithFormat:@"UPDATE %@ %@ WHERE %@=? AND %@=?"
									   ,TB_NEWSARTICLE,setStatement,TB_NEWSARTICLE_TERMID,TB_NEWSARTICLE_NEWSID];
	[valueArguments addObject:termId];
	[valueArguments addObject:newsId];
	
	[db executeUpdate:updateStatements withArgumentsInArray:valueArguments];
	if ([db hadError]) {
		SNDebugLog(@"updateNewsArticleByTermId : executeUpdate error :%d,%@,updateStatements=%@,valueArguments:%@"
				   ,[db lastErrorCode],[db lastErrorMessage],updateStatements,valueArguments);
		return NO;
	}
	
	return YES;
}

-(BOOL)updateNewsArticleByTermId:(NSString*)termId newsId:(NSString*)newsId withValuePairs:(NSDictionary*)valuePairs addIfNotExist:(BOOL)bAddIfNotExist
{
    __block BOOL result = YES;
    [[SNDatabase writeQueue] inTransaction:^(FMDatabase *db, BOOL *rollback) {
        result = [self updateNewsArticleByTermId:termId newsId:newsId withValuePairs:valuePairs addIfNotExist:bAddIfNotExist inDatabase:db];
        if (!result) {
            *rollback = YES;
        }
    }];
    return result;
}

-(BOOL)updateNewsArticleByChannelId:(NSString*)cId newsId:(NSString*)newsId withValuePairs:(NSDictionary*)valuePairs
{
	return [self updateNewsArticleByChannelId:cId newsId:newsId withValuePairs:valuePairs addIfNotExist:YES];
}

-(BOOL)updateNewsArticleByChannelId:(NSString*)cId newsId:(NSString*)newsId withValuePairs:(NSDictionary*)valuePairs addIfNotExist:(BOOL)bAddIfNotExist inDatabase:(FMDatabase *)db
{
	if ([cId length] == 0 || [newsId length] == 0) {
		SNDebugLog(@"updateNewsArticleByChannelId : Invalid ChannelId=%@ or newsId=%@",cId,newsId);
		return NO;
	}
	
	if ([valuePairs count] == 0) {
		SNDebugLog(@"updateNewsArticleByChannelId : Invalid valuePairs");
		return NO;
	}
	
	//查询此前是否已经存在
	FMResultSet *rs	= [db executeQuery:@"SELECT * FROM tbNewsArticle WHERE channelId=? and newsId=?",cId,newsId];
	if ([db hadError]) {
		SNDebugLog(@"updateNewsArticleByChannelId : executeQuery for exist one error :%d,%@,channelId=%@,newsId=%@"
				   ,[db lastErrorCode],[db lastErrorMessage],cId,newsId);
		return NO;
	}
	
	NSArray *newsArticleInfo	= [self getNewsArticleFromResultSet:rs inDatabase:db];
	[rs close];
	
	//不存在，
	if([newsArticleInfo count] == 0)
	{
		if (!bAddIfNotExist) {
			SNDebugLog(@"updateNewsArticleByChannelId : newsArticle with channelId=%@ and newsId=%@ doesn't exist",cId,newsId);
			return NO;
		}
		//新增
		else {
            [db executeUpdate:@"INSERT INTO tbNewsArticle (ID,channelId,termId,newsId,type,title,newsMark,originFrom,time,updateTime,source,commentNum,digNum,content \
             ,link,readFlag,nextName,nextId, nextNewsLink, nextNewsLink2, preName,preId,shareContent, createAt, subId, action, isPublished, editNewsLink, operators,logoUrl,linkUrl,newsType,h5link,mediaName,mediaLink,optimizeRead,tagChannelsStr,stocksStr) VALUES (NULL,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?)"
             ,cId
             ,[valuePairs objectForKey:TB_NEWSARTICLE_TERMID],newsId,[valuePairs objectForKey:TB_NEWSARTICLE_TYPE]
             ,[valuePairs objectForKey:TB_NEWSARTICLE_TITLE]
             ,[valuePairs objectForKey:TB_NEWSARTICLE_NEWSMARK]
             ,[valuePairs objectForKey:TB_NEWSARTICLE_ORIGINFROM]
             ,[valuePairs objectForKey:TB_NEWSARTICLE_TIME]
             ,[valuePairs objectForKey:TB_NEWSARTICLE_UPDATETIME]
             ,[valuePairs objectForKey:TB_NEWSARTICLE_FROM],[valuePairs objectForKey:TB_NEWSARTICLE_COMMENTNUM]
             ,[valuePairs objectForKey:TB_NEWSARTICLE_DIGNUM],[valuePairs objectForKey:TB_NEWSARTICLE_CONTENT]
             ,[valuePairs objectForKey:TB_NEWSARTICLE_LINK],[valuePairs objectForKey:TB_NEWSARTICLE_READFLAG]
             ,[valuePairs objectForKey:TB_NEWSARTICLE_NEXTNAME],[valuePairs objectForKey:TB_NEWSARTICLE_NEXTID]
             ,[valuePairs objectForKey:TB_NEWSARTICLE_NEXTNEWSLINK],[valuePairs objectForKey:TB_NEWSARTICLE_NEXTNEWSLINK2]
             ,[valuePairs objectForKey:TB_NEWSARTICLE_PRENAME],[valuePairs objectForKey:TB_NEWSARTICLE_PREID]
             ,[valuePairs objectForKey:TB_NEWSARTICLE_SHARECONTENT], [NSDate nowTimeIntervalNumber]
             ,[valuePairs objectForKey:TB_NEWSARTICLE_SUBID]
             ,[valuePairs objectForKey:TB_NEWSARTICLE_ACTION]
             ,[valuePairs objectForKey:TB_NEWSARTICLE_IS_PUBLISH]
             ,[valuePairs objectForKey:TB_NEWSARTICLE_EDIT_LINK]
             ,[valuePairs objectForKey:TB_NEWSARTICLE_OPERATORS]
             ,[valuePairs objectForKey:TB_NEWSARTICLE_LOGOURL]
             ,[valuePairs objectForKey:TB_NEWSARTICLE_LINKURL]
             ,[valuePairs objectForKey:TB_NEWSARTICLE_NEWSTYPE]
             ,[valuePairs objectForKey:TB_NEWSARTICLE_H5LINK]
             ,[valuePairs objectForKey:TB_NEWSARTICLE_MEDIANAME]
             ,[valuePairs objectForKey:TB_NEWSARTICLE_MEDIALINK]
             ,[valuePairs objectForKey:TB_NEWSARTICLE_OPTIMIZEREAD]
             ,[valuePairs objectForKey:TB_NEWSARTICLE_TAGCHANNELS]
             ,[valuePairs objectForKey:TB_NEWSARTICLE_STOCKS]
             ];
			
			if ([db hadError]) 
			{
				SNDebugLog(@"updateNewsArticleByChannelId: executeUpdate insert item  error %d:%@,channelId=%@,newsId=%@,valuePairs:%@"
						   ,[db lastErrorCode],[db lastErrorMessage],cId,newsId,valuePairs);
				return NO;
			}
			
			SNDebugLog(@"updateNewsArticleByChannelId: insert newsArticle,channelId=%@,newsId=%@,valuePairs:%@",cId,newsId,valuePairs);
			return YES;
		}
	}
	
	//如果该项存在，则执行更新操作
    NSMutableDictionary *_mDic = nil;
    if (!!valuePairs) {
        _mDic = [NSMutableDictionary dictionaryWithDictionary:valuePairs];
        [_mDic setObject:[NSDate nowTimeIntervalNumber] forKey:TB_CREATEAT_COLUMN];
    }
	NSDictionary *updateSetStatementsInfo = [self formatUpdateSetStatementsInfoFromValuePairs:_mDic ignoreNilValue:NO];
	if ([updateSetStatementsInfo count] == 0) {
		return NO;
	}
	
	NSString *setStatement			= [updateSetStatementsInfo objectForKey:UPDATE_SETSTATEMNT];
	NSMutableArray *valueArguments	= [updateSetStatementsInfo objectForKey:UPDATE_SETARGUMENTS];
	NSString *updateStatements		= [NSString stringWithFormat:@"UPDATE %@ %@ WHERE %@=? AND %@=?"
									   ,TB_NEWSARTICLE,setStatement,TB_NEWSARTICLE_CHANNELID,TB_NEWSARTICLE_NEWSID];
	[valueArguments addObject:cId];
	[valueArguments addObject:newsId];
	
	[db executeUpdate:updateStatements withArgumentsInArray:valueArguments];
	if ([db hadError]) {
		SNDebugLog(@"updateNewsArticleByChannelId : executeUpdate error :%d,%@,updateStatements=%@,valueArguments:%@"
				   ,[db lastErrorCode],[db lastErrorMessage],updateStatements,valueArguments);
		return NO;
	}
	
	return YES;
}

-(BOOL)updateNewsArticleByChannelId:(NSString*)cId newsId:(NSString*)newsId withValuePairs:(NSDictionary*)valuePairs addIfNotExist:(BOOL)bAddIfNotExist
{
    __block BOOL result = YES;
    [[SNDatabase writeQueue] inTransaction:^(FMDatabase *db, BOOL *rollback) {
        result = [self updateNewsArticleByChannelId:cId newsId:newsId withValuePairs:valuePairs addIfNotExist:bAddIfNotExist inDatabase:db];
        if (!result) {
            *rollback = YES;
        }
    }];
    return result;
}

-(BOOL)deleteNewsArticlebyTermId:(NSString*)termId newsId:(NSString*)newsId
{
	if ([termId length] == 0 || [newsId length] == 0) {
		SNDebugLog(@"deleteNewsArticlebyTermId : Invalid termId=%@ or newsId=%@",termId,newsId);
		return NO;
	}
	__block BOOL result = YES;

    [[SNDatabase writeQueue] inTransaction:^(FMDatabase *db, BOOL *rollback) {
        //删除新闻
        result = [db executeUpdate:@"DELETE FROM tbNewsArticle WHERE termId=? AND newsId=?",termId,newsId];
        if ([db hadError]) {
            *rollback = YES;
            SNDebugLog(@"deleteNewsArticlebyNewId : executeUpdate to delete newsArticle error :%d,%@,termId=%@,newsId=%@"
                       ,[db lastErrorCode],[db lastErrorMessage],termId,newsId);
            return;
        }
        
        //删除新闻相关的图片        
         result = [db executeUpdate:@"DELETE FROM tbNewsImage WHERE newsId=? AND termId=?", newsId, termId];
        if ([db hadError]) {
            *rollback  = YES;
            SNDebugLog(@"deleteNewsArticlebyNewId : executeUpdate to delete newsImage error :%d,%@,newsId=%@"
                       ,[db lastErrorCode],[db lastErrorMessage],newsId);
            return;
        }
         //删除新闻相关的音频   
        result = [db executeUpdate:@"DELETE FROM tbNewsAudio WHERE newsId=? AND termId=?", newsId, termId];
        if ([db hadError]) {
            *rollback  = YES;
            SNDebugLog(@"deleteNewsArticlebyNewId : executeUpdate to delete tbNewsAudio error :%d,%@,newsId=%@"
                       ,[db lastErrorCode],[db lastErrorMessage],newsId);
            return;
        }
    }];
		
	return result;
}

-(BOOL)deleteNewsArticlebyChannelId:(NSString*)cId newsId:(NSString*)newsId
{
	if ([cId length] == 0 || [newsId length] == 0) {
		SNDebugLog(@"deleteNewsArticlebyChannelId : Invalid channelId=%@ or newsId=%@",cId,newsId);
		return NO;
	}
	__block BOOL result = YES;

    [[SNDatabase writeQueue] inTransaction:^(FMDatabase *db, BOOL *rollback) {
        //删除新闻
        result = [db executeUpdate:@"DELETE FROM tbNewsArticle WHERE channelId=? AND newsId=?",cId,newsId];
        if ([db hadError]) {
            *rollback = YES;
            SNDebugLog(@"deleteNewsArticlebyChannelId : executeUpdate to delete newsArticle error :%d,%@,channelId=%@,newsId=%@"
                       ,[db lastErrorCode],[db lastErrorMessage],cId,newsId);
            return;
        }
        
        //删除新闻相关的图片, 这里的cId被当做termId        
        result = [db executeUpdate:@"DELETE FROM tbNewsImage WHERE newsId=? AND termId=?",newsId,cId];
        if ([db hadError]) {
            *rollback = YES;
            SNDebugLog(@"deleteNewsArticlebyChannelId : executeUpdate to delete newsImage error :%d,%@,newsId=%@"
                       ,[db lastErrorCode],[db lastErrorMessage],newsId);
            return;
        }
        
        //删除新闻相关的音频, 这里的cId被当做termId
        result = [db executeUpdate:@"DELETE FROM tbNewsAudio WHERE newsId=? AND termId=?",newsId,cId];
        if ([db hadError]) {
            *rollback = YES;
            SNDebugLog(@"deleteNewsArticlebyChannelId : executeUpdate to delete tbNewsAudio error :%d,%@,newsId=%@"
                       ,[db lastErrorCode],[db lastErrorMessage],newsId);
            return;
        }
    }];
			
	return result;
}

-(BOOL)clearNewsArticleList
{
    __block BOOL result = YES;
    [[SNDatabase writeQueue] inTransaction:^(FMDatabase *db, BOOL *rollback) {
        //删除新闻
        result = [db executeUpdate:@"DELETE FROM tbNewsArticle"];
        if ([db hadError]) {
            *rollback = YES;
            SNDebugLog(@"clearNewsArticleList : executeUpdate to delete newsArticle error :%d,%@"
                       ,[db lastErrorCode],[db lastErrorMessage]);
            return;
        }
        
        //删除新闻相关的图片        
        result = [db executeUpdate:@"DELETE FROM tbNewsImage"];
        if ([db hadError]) {
            *rollback = YES;
            SNDebugLog(@"clearNewsArticleList : executeUpdate to delete newsImage error :%d,%@"
                       ,[db lastErrorCode],[db lastErrorMessage]);
            return;
        }
        
        //删除新闻相关的音频
        result = [db executeUpdate:@"DELETE FROM tbNewsAudio"];
        if ([db hadError]) {
            *rollback = YES;
            SNDebugLog(@"clearNewsArticleList : executeUpdate to delete tbNewsAudio error :%d,%@"
                       ,[db lastErrorCode],[db lastErrorMessage]);
            return;
        }
        
        
        // 删除投票数据
        result = [db executeUpdate:@"DELETE FROM tbVotesInfo"];
        if ([db hadError]) {
            *rollback = YES;
            SNDebugLog(@"clearNewsArticleList : executeUpdate to delete votesInfo error :%d,%@"
                       ,[db lastErrorCode],[db lastErrorMessage]);
            return;
        }
    }];

	return result;
}

-(NSArray*)getImageUrlFromNewsContent:(NSString*)newsContent
{
	NSArray *imgAry	= [SNNewsImageUrlParser getImageUrlFromNewsContent:newsContent];
	return imgAry;
}

-(NSArray*)getThumbnailUrlFromNewsContent:(NSString*)newsContent
{
	NSArray *imgAry	= [SNNewsImageUrlParser getThumbnailUrlFromNewsContent:newsContent];
	return imgAry;
}

- (BOOL)updateNewsArticleFavourByChannelId:(NSString*)cId newsId:(NSString*)newsId
{
    __block BOOL result = YES;
    [[SNDatabase writeQueue] inTransaction:^(FMDatabase *db, BOOL *rollback) {
        result =  [db executeUpdate:@"update tbNewsArticle set favour=? where channelId = ? and newsId = ?", [NSNumber numberWithBool:YES], cId, newsId];
        if ([db hadError]) {
            *rollback = YES;
            SNDebugLog(@"updateNewsArticleFavourByChannelId : executeUpdate error :%d,%@"
                       ,[db lastErrorCode],[db lastErrorMessage]);
            return;
        }
    }];
    return result;
}
- (BOOL)updateNewsArticleFavourByTermId:(NSString*)termId newsId:(NSString*)newsId
{
    __block BOOL result = YES;
    [[SNDatabase writeQueue] inTransaction:^(FMDatabase *db, BOOL *rollback) {
        result =  [db executeUpdate:@"update tbNewsArticle set favour=? where termId = ? and newsId = ?", [NSNumber numberWithBool:YES], termId, newsId];
        if ([db hadError]) {
            *rollback = YES;
            SNDebugLog(@"updateNewsArticleFavourByTermId : executeUpdate error :%d,%@"
                       ,[db lastErrorCode],[db lastErrorMessage]);
            return;
        }
    }];
    return result;
}

#pragma mark - 程序中目前没有用到的

-(NSArray*)getNewsArticle
{
	return [self getNewsArticleListWithTimeOrderOption:ORDER_OPT_DEFAULT];
}

-(NSArray*)getNewsArticleListWithTimeOrderOption:(ORDER_OPTION)orderOpt;
{
    __block NSArray *newsArticleList = nil;
    [[SNDatabase readQueue] inDatabase:^(FMDatabase *db) {
        FMResultSet *rs	= nil;
        switch (orderOpt) {
            case ORDER_OPT_ASC:
                rs = [db executeQuery:@"SELECT * FROM tbNewsArticle ORDER BY time ASC"];
                break;
            case ORDER_OPT_DESC:
                rs = [db executeQuery:@"SELECT * FROM tbNewsArticle ORDER BY time DESC"];
                break;
            case ORDER_OPT_DEFAULT:
            default:
                rs = [db executeQuery:@"SELECT * FROM tbNewsArticle"];
                break;
        }
        
        if ([db hadError])
        {
            SNDebugLog(@"getNewsArticleListWithTimeOrderOption: executeQuery error %d : %@",[db lastErrorCode],[db lastErrorMessage]);
            return;
        }
        
        newsArticleList	= [self getNewsArticleFromResultSet:rs inDatabase:db];
        [rs close];
    }];
	return newsArticleList;
}

-(BOOL)addMultiNewsArticle:(NSArray*)newsArticleList updateIfExist:(BOOL)bUpdateIfExist withOption:(ADDNEWSARTICLE_OPTION)option
{
	if ([newsArticleList count] == 0) {
		SNDebugLog(@"addMultiNewsArticle : Invalid newsArticleList");
		return NO;
	}
	__block BOOL result = YES;
    [[SNDatabase writeQueue] inTransaction:^(FMDatabase *db, BOOL *rollback) {
        for (NewsArticleItem *newsArticle in newsArticleList) {
            result = [self addSingleNewsArticleOrUpdate:newsArticle withOption:option inDatabase:db];
            if (!result) {
                *rollback = YES;
                return;
            }
        }
    }];
	return result;
}

-(BOOL)addMultiNewsArticle:(NSArray*)newsArticleList
{
	return [self addMultiNewsArticle:newsArticleList updateIfExist:YES];
}

-(BOOL)addMultiNewsArticle:(NSArray*)newsArticleList updateIfExist:(BOOL)bUpdateIfExist
{
	return [self addMultiNewsArticle:newsArticleList updateIfExist:bUpdateIfExist withOption:ADDNEWSARTICLE_BY_TERMID];
}

@end
