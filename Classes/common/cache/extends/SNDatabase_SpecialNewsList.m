//
//  SNDatabase_SpecialNewsList.m
//  sohunews
//
//  Created by handy wang on 7/9/12.
//  Copyright (c) 2012 Sohu.com Inc. All rights reserved.
//
#import "SNDatabase_SpecialNewsList.h"
#import "SNDatabase_Private.h"

@implementation SNDatabase(SpecialNewsList)

#pragma mark - Private methods implementation

-(NSArray*)getSpecialNewsListFromResultSet:(FMResultSet*)rs {
	if (rs == nil) {
		SNDebugLog(@"INFO: %@--%@, GetSpecialNewsListFromResultSet: Invalid rs", NSStringFromClass(self.class), NSStringFromSelector(_cmd));
		return nil;
	}
	
	NSMutableArray *newsList = [[NSMutableArray alloc] init];
	while ([rs next]) {
        @autoreleasepool {
            SNSpecialNews *_specialNews = [[SNSpecialNews alloc] init];
            _specialNews.ID             = [rs intForColumn:TB_SPECIALNEWSLIST_ID];
            _specialNews.termId         = [rs stringForColumn:TB_SPECIALNEWSLIST_TERMID];
            _specialNews.termName       = [rs stringForColumn:TB_SPECIALNEWSLIST_TERMNAME];
            _specialNews.newsId         = [rs stringForColumn:TB_SPECIALNEWSLIST_NEWSID];
            _specialNews.newsType       = [rs stringForColumn:TB_SPECIALNEWSLIST_NEWSTYPE];
            _specialNews.title          = [rs stringForColumn:TB_SPECIALNEWSLIST_TITLE];
            
            NSString *_pic              = [rs stringForColumn:TB_SPECIALNEWSLIST_PICLIST];
            if ([kSNGroupPhotoNewsType isEqualToString:_specialNews.newsType]) {
                _specialNews.picArray   = [_pic componentsSeparatedByString:kParameterSeparator];
            } else {
                _specialNews.pic        = _pic;
            }
            
            _specialNews.abstract       = [rs stringForColumn:TB_SPECIALNEWSLIST_ABSTRACT];
            _specialNews.isFocusDisp    = [rs stringForColumn:TB_SPECIALNEWSLIST_ISFOCUSDISAP];
            _specialNews.link           = [rs stringForColumn:TB_SPECIALNEWSLIST_LINK];
            _specialNews.isRead         = [rs stringForColumn:TB_SPECIALNEWSLIST_ISREAD];
            _specialNews.form           = [rs stringForColumn:TB_SPECIALNEWSLIST_FORM];
            _specialNews.groupName      = [rs stringForColumn:TB_SPECIALNEWSLIST_GROUPNAME];
            _specialNews.hasVideo       = [rs stringForColumn:TB_SPECIALNEWSLIST_HAS_VIDEO];
            _specialNews.updateTime     = [rs stringForColumn:TB_SPECIALNEWSLIST_UPDATETIME];
            _specialNews.expired        = [rs stringForColumn:TB_SPECIALNEWSLIST_EXPIRED];
            
            [newsList addObject:_specialNews];
            _specialNews = nil;
        }
	}
	
	return newsList;
}

#pragma mark - Add methods implementation

-(BOOL)addMultiSpecialNewsList:(NSArray*)newsList updateIfExist:(BOOL)bUpdateIfExist {
	if ([newsList count] == 0) {
		SNDebugLog(@"%@--%@, AddMultiSpecialNewsList : empty news list", NSStringFromClass(self.class), NSStringFromSelector(_cmd));
		return NO;
	}
	
	__block BOOL bSucceed	= YES;
    
    [[SNDatabase writeQueue] inTransaction:^(FMDatabase *db, BOOL *rollback) {
        for(int nIndex = 0; nIndex<[newsList count]; nIndex++) {
            SNSpecialNews *news	= [newsList objectAtIndex:nIndex];
            bSucceed = [self addSingleSpecialNewsListItem:news updateIfExist:bUpdateIfExist inDatabase:db];
            if (!bSucceed) {
                *rollback = YES;
                SNDebugLog(@"%@--%@, AddMultiSpecialNewsList : Failed with comming message code %d, message %@!",
                           NSStringFromClass(self.class), NSStringFromSelector(_cmd), [db lastErrorCode],[db lastErrorMessage]);
                return ;
            }
        }
    }];
	return bSucceed;
}

-(BOOL)addSingleSpecialNewsListItem:(SNSpecialNews *)news {
	return [self addSingleSpecialNewsListItem:news updateIfExist:NO];
}

-(BOOL)addSingleSpecialNewsListItem:(SNSpecialNews *)news updateIfExist:(BOOL)bUpdateIfExist
{
    __block BOOL result = YES;
    [[SNDatabase writeQueue] inTransaction:^(FMDatabase *db, BOOL *rollback) {
        result = [self addSingleSpecialNewsListItem:news updateIfExist:bUpdateIfExist inDatabase:db];
        if (!result) {
            *rollback = YES;
        }
    }];
    return result;
}

-(BOOL)addSingleSpecialNewsListItem:(SNSpecialNews *)news updateIfExist:(BOOL)bUpdateIfExist inDatabase:(FMDatabase *)db {
	if (news == nil) {
		SNDebugLog(@"%@--%@, AddSingleSpecialNewsListItem : news is nil.", NSStringFromClass(self.class), NSStringFromSelector(_cmd));
		return NO;
	}
	
	if ([news.termId length] == 0) {
		SNDebugLog(@"%@--%@, AddSingleSpecialNewsListItem : Invalid news, termId is nil.", NSStringFromClass(self.class), NSStringFromSelector(_cmd));
		return NO;
	}
    NSString *_picList = nil;
    
    if ([kSNGroupPhotoNewsType isEqualToString:news.newsType]) {
        if (news.picArray.count > 0) {
            _picList = [news.picArray componentsJoinedByString:kParameterSeparator];
        } else {
            _picList = news.pic;
        }
    } else {
        _picList = news.pic;
    }
    
    //首先检查是否已经存在
    SNSpecialNews *_newsCached = [self getSpecialNewsByTermId:news.termId newsId:news.newsId];
    news.expired = _newsCached.expired;
    
    if (_newsCached && ![_newsCached.updateTime isEqualToString:news.updateTime]) {
        news.expired = @"1";
    }
    
	if (bUpdateIfExist) {
     	[db executeUpdate:[NSString stringWithFormat:@"REPLACE INTO %@ (termId, termName, newsId, newsType, title, pic_list, abstract, isFocusDisp, link, isRead, form, groupName, hasVideo, updateTime, expired, createAt)\
                           VALUES (?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?)", TB_SPECIALNEWSLIST],
         news.termId, news.termName, news.newsId, news.newsType, news.title, _picList, news.abstract, news.isFocusDisp, news.link, news.isRead, news.form, news.groupName, news.hasVideo, news.updateTime, news.expired, [NSDate nowTimeIntervalNumber]];
		if ([db hadError]) {
			SNDebugLog(@"INFO: %@--%@ : executeUpdate error:%d, %@", NSStringFromClass(self.class), NSStringFromSelector(_cmd), [db lastErrorCode],[db lastErrorMessage]);
			return NO;
		}
    } else {
        NSInteger count = [db intForQuery:[NSString stringWithFormat:SN_String("SELECT COUNT(*) FROM %@ WHERE termId=? AND newsId=?"), TB_SPECIALNEWSLIST], news.termId, news.newsId];
        if (count == 0) {
            [db executeUpdate:[NSString stringWithFormat:@"INSERT INTO %@ (ID, termId, termName, newsId, newsType, title, pic_list, abstract, isFocusDisp, link, isRead, form, groupName, hasVideo, updateTime, expired, createAt)\
                               VALUES (NULL,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?)", TB_SPECIALNEWSLIST],
             news.termId, news.termName, news.newsId, news.newsType, news.title, _picList, news.abstract, news.isFocusDisp, news.link, news.isRead, news.form, news.groupName, news.hasVideo, news.updateTime, news.expired, [NSDate nowTimeIntervalNumber]];
            if ([db hadError]) {
                SNDebugLog(@"INFO: %@--%@ : executeUpdate error:%d, %@", NSStringFromClass(self.class), NSStringFromSelector(_cmd), [db lastErrorCode],[db lastErrorMessage]);
                return NO;
            }
        }
    }
    return YES;
}

#pragma mark - Delete methods implementation

-(BOOL)clearSpecialHeadlineNewsByTermId:(NSString *)termId {
	__block BOOL result = YES;
    [[SNDatabase writeQueue] inTransaction:^(FMDatabase *db, BOOL *rollback) {
        result = [db executeUpdate:[NSString stringWithFormat:@"DELETE FROM %@ WHERE termId=? AND form='%@'", TB_SPECIALNEWSLIST, kSNSpecialNewsForm_Headline], termId];
        if ([db hadError]) {
            SNDebugLog(@"INFO: %@--%@ : executeUpdate error :%d, %@", NSStringFromClass(self.class), NSStringFromSelector(_cmd), [db lastErrorCode],[db lastErrorMessage]);
            *rollback = YES;
            return;
        }
    }];
	
	return result;
}

-(BOOL)deleteSpecialNewsByTermId:(NSString *)termId newsId:(NSString *)newsId {
    if (termId.length == 0 || newsId.length == 0) {
        return YES;
    }
    
    __block BOOL result = YES;
    [[SNDatabase writeQueue] inTransaction:^(FMDatabase *db, BOOL *rollback) {
        result = [db executeUpdate:[NSString stringWithFormat:@"DELETE FROM %@ WHERE termId=? AND newsId=?", TB_SPECIALNEWSLIST], termId, newsId];
        if ([db hadError]) {
            SNDebugLog(@"INFO: %@--%@ : executeUpdate error :%d, %@", NSStringFromClass(self.class), NSStringFromSelector(_cmd), [db lastErrorCode],[db lastErrorMessage]);
            *rollback = YES;
            return;
        }
    }];
	
	return result;
}

-(BOOL)clearSpecialNewsByTermId:(NSString *)termId {
    __block BOOL result = YES;
    [[SNDatabase writeQueue] inTransaction:^(FMDatabase *db, BOOL *rollback) {
        result = [db executeUpdate:[NSString stringWithFormat:@"DELETE FROM %@ WHERE termId=? AND form='%@'", TB_SPECIALNEWSLIST, kSNSpecialNewsForm_Normal], termId];
        if ([db hadError]) {
            SNDebugLog(@"INFO: %@--%@ : executeUpdate error :%d, %@", NSStringFromClass(self.class), NSStringFromSelector(_cmd), [db lastErrorCode],[db lastErrorMessage]);
            *rollback = YES;
            return;
        }
    }];
	
	return result;
}

- (BOOL)clearSpecialNewsList {
    __block BOOL result = YES;
    [[SNDatabase writeQueue] inTransaction:^(FMDatabase *db, BOOL *rollback) {
        result = [db executeUpdate:[NSString stringWithFormat:@"DELETE FROM %@", TB_SPECIALNEWSLIST]];
        if ([db hadError]) {
            SNDebugLog(@"clearSpecialNewsList : db executeUpdate error:%d,%@"
                       ,[db lastErrorCode],[db lastErrorMessage]);
            *rollback = YES;
            return;
        }
    }];
	
	return result;
}

#pragma mark - Update methods implementation

- (BOOL)markSpecialNewsAsReadByTermId:(NSString*)termId newsId:(NSString*)newsId {
    NSDictionary *kevValue = [NSDictionary dictionaryWithObject:kSNSpecialNewsIsRead_YES forKey:TB_SPECIALNEWSLIST_ISREAD];
    return [self updateSpecialNewsListByTermId:termId newsId:newsId withValuePairs:kevValue];
}

- (BOOL)markSpecialNewsListItemAsNotExpiredByTermId:(NSString*)termId newsId:(NSString*)newsId
{
    NSDictionary *kevValue = [NSDictionary dictionaryWithObject:@"0" forKey:TB_SPECIALNEWSLIST_EXPIRED];
    
    return [self updateSpecialNewsListByTermId:termId newsId:newsId withValuePairs:kevValue];
}

- (BOOL)markSpecialNewsListItemAsReadAndNotExpiredByTermId:(NSString *)termId newsId:(NSString *)newsId {
    NSDictionary *kevValue = [NSDictionary dictionaryWithObjectsAndKeys:kSNSpecialNewsIsRead_YES, TB_SPECIALNEWSLIST_ISREAD, @"0", TB_SPECIALNEWSLIST_EXPIRED, nil];
     return [self updateSpecialNewsListByTermId:termId newsId:newsId withValuePairs:kevValue];
}

- (BOOL)updateSpecialNewsListByTermId:(NSString*)termId newsId:(NSString*)newsId withValuePairs:(NSDictionary*)valuePairs
{
    __block BOOL result = YES;
    [[SNDatabase writeQueue] inTransaction:^(FMDatabase *db, BOOL *rollback) {
        result = [self updateSpecialNewsListByTermId:termId newsId:newsId withValuePairs:valuePairs inDatabase:db];
        if(!result){
            *rollback = YES;
        }
    }];
    return result;
}
- (BOOL)updateSpecialNewsListByTermId:(NSString*)termId newsId:(NSString*)newsId withValuePairs:(NSDictionary*)valuePairs inDatabase:(FMDatabase *)db{
	if ([termId length] == 0 || [newsId length] == 0) {
		SNDebugLog(@"INFO: %@--%@ : Invalid termId=%@ or newsId=%@",
                   termId, newsId, NSStringFromClass(self.class), NSStringFromSelector(_cmd));
		return NO;
	}
	
	if ([valuePairs count] == 0) {
		SNDebugLog(@"INFO: %@--%@ : Invalid valuePairs", NSStringFromClass(self.class), NSStringFromSelector(_cmd));
		return NO;
	}
	
	//执行更新
    NSMutableDictionary *_mDic = nil;
    if (!!valuePairs) {
        _mDic = [NSMutableDictionary dictionaryWithDictionary:valuePairs];
        [_mDic setObject:[NSDate nowTimeIntervalNumber] forKey:TB_CREATEAT_COLUMN];
    }
	NSDictionary *updateStatementsInfo	= [self formatUpdateSetStatementsInfoFromValuePairs:_mDic ignoreNilValue:NO];
	if ([updateStatementsInfo count] == 0) {
		SNDebugLog(@"INFO: %@--%@ : formatUpdateSetStatementsInfoFromValuePairs failed", NSStringFromClass(self.class), NSStringFromSelector(_cmd));
		return NO;
	}
	
	NSString *statement				= [updateStatementsInfo objectForKey:UPDATE_SETSTATEMNT];
	NSMutableArray *updateArguments	= [updateStatementsInfo objectForKey:UPDATE_SETARGUMENTS];
	
	NSString *updateStatement		= [NSString stringWithFormat:@"UPDATE %@ %@ WHERE %@=? AND %@=?", TB_SPECIALNEWSLIST, statement, TB_SPECIALNEWSLIST_TERMID, TB_SPECIALNEWSLIST_NEWSID];
	
	[updateArguments addObject:termId];
	[updateArguments addObject:newsId];
	
	[db executeUpdate:updateStatement withArgumentsInArray:updateArguments];
	if ([db hadError]) {
		SNDebugLog(@"INFO: %@--%@ : executeUpdate error:%d,%@, termId=%@, newsId=%@"
				   , NSStringFromClass(self.class), NSStringFromSelector(_cmd), [db lastErrorCode], [db lastErrorMessage], termId, newsId);
		return NO;
	}
	
	return YES;
}

#pragma mark - Query methods implementation

- (BOOL)checkSpecialNewsReadOrNotByTermId:(NSString *)termId newsId:(NSString*)newsId {
    SNSpecialNews *_news = [self getSpecialNewsByTermId:termId newsId:newsId];
    
    return [@"1" isEqualToString:_news.isRead];
}


- (SNSpecialNews *)getSpecialNewsByTermId:(NSString *)termId newsId:(NSString*)newsId {
	if ([termId length] == 0 || [newsId length] == 0) {
		SNDebugLog(@"INFO: %@--%@ : Invalid termId=%@ or newsId=%@", NSStringFromClass(self.class), NSStringFromSelector(_cmd), termId, newsId);
		return nil;
	}
    __block NSArray *_specialnewsList = nil;
    [[SNDatabase readQueue] inDatabase:^(FMDatabase *db) {
        FMResultSet *rs	= [db executeQuery:[NSString stringWithFormat:@"SELECT * FROM %@ WHERE termId=? AND newsId=?", TB_SPECIALNEWSLIST], termId, newsId];
        if ([db hadError]) {
            SNDebugLog(@"INFO: %@--%@ : executeQuery error :%d, %@, termId=%@, newsId=%@", 
                       NSStringFromClass(self.class), NSStringFromSelector(_cmd), [db lastErrorCode], [db lastErrorMessage], termId, newsId);
            return;
        }
        
        _specialnewsList	= [self getSpecialNewsListFromResultSet:rs];
        [rs close];
    }];
	
	switch ([_specialnewsList count]) {
		case 0:
			return nil;
		case 1:
			return [_specialnewsList objectAtIndex:0];
		default:
			SNDebugLog(@"INFO: %@--%@ : More than one(%d) news item exist", NSStringFromClass(self.class), NSStringFromSelector(_cmd), [_specialnewsList count]);
			return [_specialnewsList objectAtIndex:0];
	}
}

- (NSArray *)getSpecialHeadlineNewsListByTermId:(NSString *)termId {
    if ([termId length] == 0) {
		SNDebugLog(@"INFO: %@--%@ : Invalid termId=%@", NSStringFromClass(self.class), NSStringFromSelector(_cmd), termId);
		return nil;
	}
    __block NSArray *rollingNewsList = nil;
    [[SNDatabase readQueue] inDatabase:^(FMDatabase *db) {
        FMResultSet *rs	= [db executeQuery:[NSString stringWithFormat:@"SELECT * FROM %@ WHERE termId=? AND form='%@' order by ID desc", TB_SPECIALNEWSLIST, kSNSpecialNewsForm_Headline], termId];
        if ([db hadError]) {
            SNDebugLog(@"INFO: %@--%@ : executeQuery error :%d, %@, termId=%@", 
                       NSStringFromClass(self.class), NSStringFromSelector(_cmd), [db lastErrorCode], [db lastErrorMessage], termId);
            return;
        }
        
        rollingNewsList	= [self getSpecialNewsListFromResultSet:rs];
        [rs close];
    }];
	
	return rollingNewsList;
}

- (NSArray *)getSpecialNormalNewsListByTermId:(NSString *)termId {
 	if ([termId length] == 0) {
		SNDebugLog(@"INFO: %@--%@ : Invalid termId=%@.", 
                   NSStringFromClass(self.class), NSStringFromSelector(_cmd), termId);
		return nil;
	}
    __block NSArray *rollingNewsList = nil;
    [[SNDatabase readQueue] inDatabase:^(FMDatabase *db) {
        NSString *stmt = [NSString stringWithFormat:@"SELECT * FROM %@ WHERE termId=? AND form='%@' order by ID asc", TB_SPECIALNEWSLIST, kSNSpecialNewsForm_Normal];
        FMResultSet *rs	= [db executeQuery:stmt, termId];
        if ([db hadError]) {
            SNDebugLog(@"INFO: %@--%@ : ExecuteQuery error:%d, %@, termId=%@",
                       NSStringFromClass(self.class), NSStringFromSelector(_cmd), [db lastErrorCode], [db lastErrorMessage], termId);
            return;
        }
        
        rollingNewsList	= [self getSpecialNewsListFromResultSet:rs];
        [rs close];
	}];
    
	return rollingNewsList;
}

@end
