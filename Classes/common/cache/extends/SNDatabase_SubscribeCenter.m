//
//  SNDatabase_SubscribeCenter.m
//  sohunews
//
//  Created by wang yanchen on 12-11-19.
//  Copyright (c) 2012年 Sohu.com Inc. All rights reserved.
//

#import "SNDatabase_SubscribeCenter.h"
#import "SNDatabase_Private.h"
#import "SNConsts.h"

@implementation SNDatabase(SubscribeCenter)

#pragma mark - private methods
- (NSArray *)getSubIdsFromResultSet:(FMResultSet *)rs {
    if (nil == rs) {
		SNDebugLog(@"%@--%@ : Invalid Result set.", NSStringFromClass(self.class), NSStringFromSelector(_cmd));
        return nil;
    }
    
    NSMutableArray *subIds = [NSMutableArray array];
    
    while ([rs next]) {
        @autoreleasepool {
            NSString *subId = [rs stringForColumn:TB_SUB_CENTER_RELATION_SUB_ID];
            if (subId) {
                [subIds addObject:subId];
            }
        }
    }
    
    return subIds;
}


- (NSDictionary *)getValuePairsFromSubscibeObject:(SCSubscribeObject *)subscribeObj {
    if (nil == subscribeObj) {
		SNDebugLog(@"INFO: %@--%@, Invalid subscribe object.", NSStringFromClass(self.class), NSStringFromSelector(_cmd));
        return nil;
    }
    
    NSMutableDictionary *vp = [NSMutableDictionary dictionary];
    
    if (subscribeObj.defaultSub) {
        [vp setObject:subscribeObj.defaultSub forKey:TB_SUB_CENTER_ALL_SUB_DEFAULT_SUB];
    }
    
    if (subscribeObj.subId) {
        [vp setObject:subscribeObj.subId forKey:TB_SUB_CENTER_ALL_SUB_SUB_ID];
    }
    if (subscribeObj.subName) {
        [vp setObject:subscribeObj.subName forKey:TB_SUB_CENTER_ALL_SUB_SUB_NAME];
    }
    if (subscribeObj.subIcon) {
        [vp setObject:subscribeObj.subIcon forKey:TB_SUB_CENTER_ALL_SUB_SUB_ICON];
    }
    if (subscribeObj.subInfo) {
        [vp setObject:subscribeObj.subInfo forKey:TB_SUB_CENTER_ALL_SUB_SUB_INFO];
    }
    if (subscribeObj.moreInfo) {
        [vp setObject:subscribeObj.moreInfo forKey:TB_SUB_CENTER_ALL_SUB_MORE_INFO];
    }
    if (subscribeObj.pubIds) {
        [vp setObject:subscribeObj.pubIds forKey:TB_SUB_CENTER_ALL_SUB_PUB_IDS];
    }
    if (subscribeObj.termId) {
        [vp setObject:subscribeObj.termId forKey:TB_SUB_CENTER_ALL_SUB_TERM_ID];
    }
    if (subscribeObj.lastTermLink) {
        [vp setObject:subscribeObj.lastTermLink forKey:TB_SUB_CENTER_ALL_SUB_LAST_TERM_LINK];
    }
    if (subscribeObj.isPush) {
        [vp setObject:subscribeObj.isPush forKey:TB_SUB_CENTER_ALL_SUB_IS_PUSH];
    }
    if (subscribeObj.defaultPush) {
        [vp setObject:subscribeObj.defaultPush forKey:TB_SUB_CENTER_ALL_SUB_DEFAULT_PUSH];
    }
    if (subscribeObj.publishTime) {
        [vp setObject:subscribeObj.publishTime forKey:TB_SUB_CENTER_ALL_SUB_PUBLISH_TIME];
    }
    if (subscribeObj.unReadCount) {
        [vp setObject:subscribeObj.unReadCount forKey:TB_SUB_CENTER_ALL_SUB_UN_READ_COUNT];
    }
    if (subscribeObj.subPersonCount) {
        [vp setObject:subscribeObj.subPersonCount forKey:TB_SUB_CENTER_ALL_SUB_PERSON_COUNT];
    }
    if (subscribeObj.topNews) {
        [vp setObject:subscribeObj.topNews forKey:TB_SUB_CENTER_ALL_SUB_TOP_NEWS];
    }
    if (subscribeObj.topNews2) {
        [vp setObject:subscribeObj.topNews2 forKey:TB_SUB_CENTER_ALL_SUB_TOP_NEWS2];
    }
    if (subscribeObj.isSubscribed) {
        [vp setObject:subscribeObj.isSubscribed forKey:TB_SUB_CENTER_ALL_SUB_IS_SUBSCRIBED];
    }
    if (subscribeObj.isDownloaded) {
        [vp setObject:subscribeObj.isDownloaded forKey:TB_SUB_CENTER_ALL_SUB_IS_DOWNLOADED];
    }
    if (subscribeObj.isOnRank) {
        [vp setObject:subscribeObj.isOnRank forKey:TB_SUB_CENTER_ALL_SUB_IS_ON_RANK];
    }
    if (subscribeObj.isTop) {
        [vp setObject:subscribeObj.isTop forKey:TB_SUB_CENTER_ALL_SUB_IS_TOP];
    }
    if (subscribeObj.topTime) {
        [vp setObject:subscribeObj.topTime forKey:TB_SUB_CENTER_ALL_SUB_TOP_TIME];
    }
    if (subscribeObj.indexValue) {
        [vp setObject:subscribeObj.indexValue forKey:TB_SUB_CENTER_ALL_SUB_INDEX_VALUE];
    }
    if (subscribeObj.starGrade) {
        [vp setObject:subscribeObj.starGrade forKey:TB_SUB_CENTER_ALL_SUB_GRADE_LEVEL];
    }
    if (subscribeObj.commentCount) {
        [vp setObject:subscribeObj.commentCount forKey:TB_SUB_CENTER_ALL_SUB_COMMENT_COUNT];
    }
    if (subscribeObj.openTimes) {
        [vp setObject:subscribeObj.openTimes forKey:TB_SUB_CENTER_ALL_SUB_OPEN_TIMES];
    }
    if (subscribeObj.backPromotion) {
        [vp setObject:subscribeObj.backPromotion forKey:TB_SUB_CENTER_ALL_SUB_BACK_PROMOTION];
    }
    if (subscribeObj.templeteType) {
        [vp setObject:subscribeObj.templeteType forKey:TB_SUB_CENTER_ALL_SUB_TEMPLATE_TYPE];
    }
    if (subscribeObj.status) {
        [vp setObject:subscribeObj.status forKey:TB_SUB_CENTER_ALL_SUB_STATUS];
    }
    if (subscribeObj.isSelected) {
        [vp setObject:subscribeObj.isSelected forKey:TB_SUB_CENTER_ALL_SUB_ISSELECTED];
    }
    if (subscribeObj.link) {
        [vp setObject:subscribeObj.link forKey:TB_SUB_CENTER_ALL_SUB_LINK];
    }
    if (subscribeObj.subShowType) {
        [vp setObject:subscribeObj.subShowType forKey:TB_SUB_CENTER_ALL_SUB_SUB_SHOW_TYPE];
    }
    if (subscribeObj.stickTop) {
        [vp setObject:subscribeObj.stickTop forKey:TB_SUB_CENTER_ALL_SUB_STICKTOP];
    }
    if (subscribeObj.buttonTxt) {
        [vp setObject:subscribeObj.buttonTxt forKey:TB_SUB_CENTER_ALL_SUB_BUTTONTXT];
    }
    if (subscribeObj.needLogin) {
        [vp setObject:subscribeObj.needLogin forKey:TB_SUB_CENTER_ALL_SUB_NEED_LOGIN];
    }
    if (subscribeObj.canOffline) {
        [vp setObject:subscribeObj.canOffline forKey:TB_SUB_CENTER_ALL_SUB_CAN_OFFLINE];
    }
    if (subscribeObj.userInfo) {
        [vp setObject:subscribeObj.userInfo forKey:TB_SUB_CENTER_ALL_SUB_USERINFO];
    }
    if (subscribeObj.showComment) {
        [vp setObject:subscribeObj.showComment forKey:TB_SUB_CENTER_ALL_SUB_SHOW_COMMENT];
    }
    if (subscribeObj.showRecmSub) {
        [vp setObject:subscribeObj.showRecmSub forKey:TB_SUB_CENTER_ALL_SUB_SHOW_RECOMMEND_SUB];
    }
    if (subscribeObj.topNewsAbstracts) {
        [vp setObject:subscribeObj.topNewsAbstracts forKey:TB_SUB_CENTER_ALL_SUB_TOP_NEWS_ABSTRACT];
    }
    if (subscribeObj.topNewsLink) {
        [vp setObject:subscribeObj.topNewsLink forKey:TB_SUB_CENTER_ALL_SUB_TOP_NEWS_LINK];
    }
    if (subscribeObj.topNewsPicsString) {
        [vp setObject:subscribeObj.topNewsPicsString forKey:TB_SUB_CENTER_ALL_SUB_TOP_NEWS_PICS];
    }
    if (subscribeObj.topNewsString) {
        [vp setObject:subscribeObj.topNewsString forKey:TB_SUB_CENTER_ALL_SUB_TOPNEWS];
    }
    if (subscribeObj.sortIndex) {
        [vp setObject:subscribeObj.sortIndex forKey:TB_SUB_CENTER_ALL_SUB_MY_SUB_SORT_INDEX];
    }
    if (subscribeObj.countShowText) {
        [vp setObject:subscribeObj.countShowText forKey:TB_SUB_CENTER_ALL_COUNT_SHOW_TEXT];
    }
    
    return vp;
}

- (NSDictionary *)getValuePairsFromSubTypeObject:(SCSubscribeTypeObject *)subTypeObj {
    if (nil == subTypeObj) {
		SNDebugLog(@"INFO: %@--%@, Invalid subscribe object.", NSStringFromClass(self.class), NSStringFromSelector(_cmd));
        return nil;
    }
    
    NSMutableDictionary *vp = [NSMutableDictionary dictionary];
    if (subTypeObj.typeId) {
        [vp setObject:subTypeObj.typeId forKey:TB_SUB_CENTER_TYPES_TYPE_ID];
    }
    if (subTypeObj.typeName) {
        [vp setObject:subTypeObj.typeName forKey:TB_SUB_CENTER_TYPES_TYPE_NAME];
    }
    if (subTypeObj.typeIcon) {
        [vp setObject:subTypeObj.typeIcon forKey:TB_SUB_CENTER_TYPES_TYPE_ICON];
    }
    if (subTypeObj.subId) {
        [vp setObject:subTypeObj.subId forKey:TB_SUB_CENTER_TYPES_SUB_ID];
    }
    if (subTypeObj.subName) {
        [vp setObject:subTypeObj.subName forKey:TB_SUB_CENTER_TYPES_SUB_NAME];
    }
    return vp;
}

#pragma mark - 我的订阅
// 批量保存我的订阅数据到数据库，如果数据库已存在则覆盖
- (BOOL)addSubscribeCenterSubscribeObjects:(NSArray*)mySubscribeObjectArray {
    return [self addSubscribeCenterSubscribeObjects:mySubscribeObjectArray updateIfExist:YES];
}

// 批量保存我的订阅数据到数据库
- (BOOL)addSubscribeCenterSubscribeObjects:(NSArray*)mySubscribeObjectArray updateIfExist:(BOOL)bUpdateIfExist {
	if ([mySubscribeObjectArray count] <= 0) {
		SNDebugLog(@"ERROR: %@--%@, Invalid subscribeList", NSStringFromClass(self.class), NSStringFromSelector(_cmd));
        return YES;
	}
    
    __block BOOL bSucceed = YES;
    [[SNDatabase writeQueue] inTransaction:^(FMDatabase *db, BOOL *rollback) {
        // 单个逐一add
        for (SCSubscribeObject *subObj in mySubscribeObjectArray) {
            bSucceed = [self addASubscribeCenterSubscribeObject:subObj updateIfExist:bUpdateIfExist inDatabase:db];
            if (!bSucceed) {
                *rollback = YES;
                return ;
            }
        }
    }];
    
    return bSucceed;
}

// 单个保存我的订阅数据到数据库，如果数据库已存在则覆盖
- (BOOL)addASubscribeCenterSubscribeObject:(SCSubscribeObject *)mySubscribeObject {
    return [self addASubscribeCenterSubscribeObject:mySubscribeObject updateIfExist:YES];
}

- (BOOL)addASubscribeCenterSubscribeObject:(SCSubscribeObject *)mySubscribeObject updateIfExist:(BOOL)bUpdateIfExist
{
    __block BOOL result = YES;
    [[SNDatabase writeQueue] inTransaction:^(FMDatabase *db, BOOL *rollback) {
        result = [self addASubscribeCenterSubscribeObject:mySubscribeObject updateIfExist:bUpdateIfExist inDatabase:db];
        if (!result) {
            *rollback = YES;
        }
    }];
    return result;
}
// 单个保存我的订阅数据到数据库
- (BOOL)addASubscribeCenterSubscribeObject:(SCSubscribeObject *)mySubscribeObject updateIfExist:(BOOL)bUpdateIfExist inDatabase:(FMDatabase *)db{
	if (mySubscribeObject == nil) {
		SNDebugLog(@"%@--%@, Invalid subscribe", NSStringFromClass(self.class), NSStringFromSelector(_cmd));
		return NO;
	}
    
	//查询是否已经存在相同项
	NSInteger count= [db intForQuery:[NSString stringWithFormat:@"SELECT COUNT(*) FROM %@ WHERE subId=?", TB_SUB_CENTER_ALL_SUBSCRIBE], mySubscribeObject.subId];
	if ([db hadError]) {
		SNDebugLog(@"%@--%@, intForQuery for exist one error :%d, %@",  NSStringFromClass(self.class), NSStringFromSelector(_cmd), [db lastErrorCode],[db lastErrorMessage]);
		return NO;
	}
    
    // 如果数据在数据库中存在
    if (count > 0) {
        // 存在但不更新
		if (!bUpdateIfExist) {
			SNDebugLog(@"%@--%@ : subscribe item with subId=%@ already exists", NSStringFromClass(self.class), NSStringFromSelector(_cmd), mySubscribeObject.subId);
			return YES;
		}
        
        // 执行更新操作
        NSDictionary *valuePairs = [self getValuePairsFromSubscibeObject:mySubscribeObject];
		BOOL bSucceed	= [self updateSubscribeCenterSubscribeObjectBySubId:mySubscribeObject.subId withValuePairs:valuePairs addIfNotExist:NO inDatabase:db];
		if (!bSucceed) {
			SNDebugLog(@"%@--%@ : Update falied Update while subscribe item with subId=%@ already exists", NSStringFromClass(self.class), NSStringFromSelector(_cmd), mySubscribeObject.subId);
			return NO;
		}
		
		//SNDebugLog(@"%@--%@ : Update while subscribe item with subId=%@ already exists", NSStringFromClass(self.class), NSStringFromSelector(_cmd), mySubscribeObject.subId);
		return YES;
    }
    
    //[mySubscribeObject setStatusValue:[kHAVE_NEW_TERM intValue] forFlag:SCSubObjStatusFlagSubStatus];
    
    // 第一次插入早晚报订阅时，默认设置为置顶
    if ([mySubscribeObject.subId isEqualToString:kSohuNewsSubId]) {
        mySubscribeObject.isTop = @"1";
    }
    
    //如果在数据库中不存在，则在数据库中添加新记录
    [db executeUpdate:[NSString stringWithFormat:@"INSERT INTO %@ (ID,defaultSub,subId,subName,subIcon,subInfo,moreInfo,pubIds,termId,lastTermLink,isPush,defaultPush,publishTime,unReadCount,subPersonCount,topNews,topNews2,isSubscribed,isDownloaded,isOnRank,isTop,topTime,indexValue,starGrade,commentCount,openTimes,backPromotion,templeteType,status,link,subShowType,stickTop,buttonTxt,needLogin,canOffline,userInfo,showComment,showRecmSub,topNewsAbstracts,topNewsLink,topNewsPicsString,sortIndex,topNewsString,countShowText) VALUES (NULL,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?)", TB_SUB_CENTER_ALL_SUBSCRIBE],
     mySubscribeObject.defaultSub,
     mySubscribeObject.subId,
     mySubscribeObject.subName,
     mySubscribeObject.subIcon,
     mySubscribeObject.subInfo,
     mySubscribeObject.moreInfo,
     mySubscribeObject.pubIds,
     mySubscribeObject.termId,
     mySubscribeObject.lastTermLink,
     mySubscribeObject.isPush,
     mySubscribeObject.defaultPush,
     mySubscribeObject.publishTime,
     mySubscribeObject.unReadCount,
     mySubscribeObject.subPersonCount,
     mySubscribeObject.topNews,
     mySubscribeObject.topNews2,
     mySubscribeObject.isSubscribed,
     mySubscribeObject.isDownloaded,
     mySubscribeObject.isOnRank,
     mySubscribeObject.isTop,
     mySubscribeObject.topTime,
     mySubscribeObject.indexValue,
     mySubscribeObject.starGrade,
     mySubscribeObject.commentCount,
     mySubscribeObject.openTimes,
     mySubscribeObject.backPromotion,
     mySubscribeObject.templeteType,
     mySubscribeObject.status,
     mySubscribeObject.link,
     mySubscribeObject.subShowType,
     mySubscribeObject.stickTop,
     mySubscribeObject.buttonTxt,
     mySubscribeObject.needLogin,
     mySubscribeObject.canOffline,
     mySubscribeObject.userInfo,
     mySubscribeObject.showComment,
     mySubscribeObject.showRecmSub,
     mySubscribeObject.topNewsAbstracts,
     mySubscribeObject.topNewsLink,
     mySubscribeObject.topNewsPicsString,
     mySubscribeObject.sortIndex,
     mySubscribeObject.topNewsString,
     mySubscribeObject.countShowText
     ];
    
    
	if ([db hadError]) {
		SNDebugLog(@"%@--%@ : executeUpdate error :%d,%@,subscribe:%@", NSStringFromClass(self.class), NSStringFromSelector(_cmd), [db lastErrorCode],[db lastErrorMessage], mySubscribeObject);
		return NO;
	}
	else {
		SNDebugLog(@"%@--%@ : Succeed, subId=%@ subName=%@", NSStringFromClass(self.class), NSStringFromSelector(_cmd), mySubscribeObject.subId, mySubscribeObject.subName);
	}
	return YES;
}

// 根据subid删除我的订阅 -- 这里不需要删除数据，只需要将isSubscribed标志为0
- (BOOL)deleteSubscribeCenterSubscribeObjectBySubId:(NSString *)subId {
	__block BOOL result = YES;
    [[SNDatabase writeQueue] inTransaction:^(FMDatabase *db, BOOL *rollback) {
        result = [self deleteSubscribeCenterSubscribeObjectBySubId:subId inDatabase:db];
        if (!result) {
            *rollback = YES;
        }
    }];
    return result;
}

// 根据subid删除订阅(数据库删除)
- (BOOL)deleteSubscribeCenterSubscribeObjectFromDatabaseBySubId:(NSString *)subId {
    __block BOOL result = YES;
    [[SNDatabase writeQueue] inTransaction:^(FMDatabase *db, BOOL *rollback) {
        result = [self deleteSubscribeCenterSubscribeObjectFromDatabaseBySubId:subId inDatabase:db];
        if (!result) {
            *rollback = YES;
        }
    }];
    return result;
}

- (BOOL)deleteSubscribeCenterSubscribeObjectBySubId:(NSString *)subId inDatabase:(FMDatabase *)db {
	if ([subId length] == 0) {
		SNDebugLog(@"%@--%@ : Invalid subId", NSStringFromClass(self.class), NSStringFromSelector(_cmd));
		return NO;
	}
    
	// 根据subid删除我的订阅 -- 这里不需要删除数据，只需要将isSubscribed标志为0
//	[db executeUpdate:[NSString stringWithFormat:@"DELETE FROM %@ WHERE subId=?", TB_SUB_CENTER_ALL_SUBSCRIBE],subId];
	[db executeUpdate:[NSString stringWithFormat:@"UPDATE %@ SET %@=0 WHERE subId=?", TB_SUB_CENTER_ALL_SUBSCRIBE, TB_SUB_CENTER_ALL_SUB_IS_SUBSCRIBED],subId];
	
	if ([db hadError]) {
		SNDebugLog(@"%@--%@ : executeUpdate error :%d,%@,subId=%@", NSStringFromClass(self.class), NSStringFromSelector(_cmd), [db lastErrorCode],[db lastErrorMessage],subId);
		return NO;
	}
	
	return YES;
}

- (BOOL)deleteSubscribeCenterSubscribeObjectFromDatabaseBySubId:(NSString *)subId inDatabase:(FMDatabase *)db {
	if ([subId length] == 0) {
		SNDebugLog(@"%@--%@ : Invalid subId", NSStringFromClass(self.class), NSStringFromSelector(_cmd));
		return NO;
	}
    
	// 根据subid删除我的订阅 -- 这里不需要删除数据，只需要将isSubscribed标志为0
    [db executeUpdate:[NSString stringWithFormat:@"DELETE FROM %@ WHERE subId=?", TB_SUB_CENTER_ALL_SUBSCRIBE],subId];
	//[db executeUpdate:[NSString stringWithFormat:@"UPDATE %@ SET %@=0 WHERE subId=?", TB_SUB_CENTER_ALL_SUBSCRIBE, TB_SUB_CENTER_ALL_SUB_IS_SUBSCRIBED],subId];
	
	if ([db hadError]) {
		SNDebugLog(@"%@--%@ : executeUpdate error :%d,%@,subId=%@", NSStringFromClass(self.class), NSStringFromSelector(_cmd), [db lastErrorCode],[db lastErrorMessage],subId);
		return NO;
	}
	
	return YES;
}


// 删除不在所有订阅中的我订阅。出现刊物在“所有订阅列表”中没有但在“我的订阅”中有的现象的原因是：某刊物已被订阅，但是这个刊物某一天被下架了。
- (BOOL)deleteSubscribeCenterSubscribeObjectsInAllArray:(NSArray *)objsToDelete {
    if ([objsToDelete count] <= 0) {
		SNDebugLog(@"%@--%@ : Invalid subIds", NSStringFromClass(self.class), NSStringFromSelector(_cmd));
        return NO;
    }
    __block BOOL result = YES;
    [[SNDatabase writeQueue] inTransaction:^(FMDatabase *db, BOOL *rollback) {
        for (SCSubscribeObject *subObj in objsToDelete) {
            result = [self deleteSubscribeCenterSubscribeObjectBySubId:subObj.subId inDatabase:db];
            if (!result) {
                *rollback = YES;
                return;
            }
        }
    }];
    return result;
}

- (BOOL)deleteSubscribeCenterSubscribeObjectsInAllArray:(NSArray *)objsToDelete inDatabase:(FMDatabase *)db {
    if ([objsToDelete count] <= 0) {
		SNDebugLog(@"%@--%@ : Invalid subIds", NSStringFromClass(self.class), NSStringFromSelector(_cmd));
        return NO;
    }
    
    for (SCSubscribeObject *subObj in objsToDelete) {
        if (![self deleteSubscribeCenterSubscribeObjectBySubId:subObj.subId inDatabase:db]) {
            return NO;
        }
        SNDebugLog(@"deleteSubscribeCenterSubscribeObjectsInAllArray: %@", subObj);
    }
    
	if ([db hadError]) {
		SNDebugLog(@"%@--%@ : executeUpdate error :%d,%@", NSStringFromClass(self.class), NSStringFromSelector(_cmd), [db lastErrorCode],[db lastErrorMessage]);
		return NO;
	}
    
    return YES;
}

/***************************************************************************************************
 * 根据subId、pubId 更新单个订阅object
 */


// 更新单个订阅
- (BOOL)updateSubscribeCenterSubscribeObject:(SCSubscribeObject *)subObj addIfNotExist:(BOOL)bAddIfNotExist {
    if (nil == subObj) {
        SNDebugLog(@"%@--%@ invalidate subObj", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
        return NO;
    }
    
    NSDictionary *valuePair = [self getValuePairsFromSubscibeObject:subObj];
//    SNDebugLog(@"%@-%@ valuePair = %@", NSStringFromClass([self class]), NSStringFromSelector(_cmd), valuePair);
    
    return [self updateSubscribeCenterSubscribeObjectBySubId:subObj.subId withValuePairs:valuePair addIfNotExist:bAddIfNotExist];
}

// 更新单个SubHome我的订阅，如果不存在不要添加到数据库
- (BOOL)updateSubscribeCenterSubscribeObjectBySubId:(NSString*)subId withValuePairs:(NSDictionary*)valuePairs {
    return [self updateSubscribeCenterSubscribeObjectBySubId:subId withValuePairs:valuePairs addIfNotExist:NO];
}

// 更新单个SubHome我的订阅，如果不存在并可以根据参数决定要不要添加到数据库
- (BOOL)updateSubscribeCenterSubscribeObjectBySubId:(NSString*)subId withValuePairs:(NSDictionary*)valuePairs addIfNotExist:(BOOL)bAddIfNotExist
{
    __block BOOL result = YES;
    [[SNDatabase writeQueue] inTransaction:^(FMDatabase *db, BOOL *rollback) {
        result = [self updateSubscribeCenterSubscribeObjectBySubId:subId withValuePairs:valuePairs addIfNotExist:bAddIfNotExist inDatabase:db];
        if (!result) {
            *rollback = YES;
        }
    }];
    return result;
}

- (BOOL)updateSubscribeCenterSubscribeObjectBySubId:(NSString*)subId withValuePairs:(NSDictionary*)valuePairs addIfNotExist:(BOOL)bAddIfNotExist inDatabase:(FMDatabase *)db {
    
    if ([subId isEqual:[NSNull null]]) {
        return NO;
    }
    
    if (![subId isKindOfClass:[NSString class]]) {
        return NO;
    }
    
	if ([subId length] == 0) {
		SNDebugLog(@"%@--%@ : Invalid subId", NSStringFromClass(self.class), NSStringFromSelector(_cmd));
		return NO;
	}
	if ([valuePairs count] == 0) {
		SNDebugLog(@"%@--%@ : Invalid valuePairs", NSStringFromClass(self.class), NSStringFromSelector(_cmd));
		return NO;
	}
	
	//查询是否已经存在相同项
	FMResultSet *rs	= [db executeQuery:[NSString stringWithFormat:@"SELECT * FROM %@ WHERE subId=?", TB_SUB_CENTER_ALL_SUBSCRIBE], subId];
	if ([db hadError]) {
		SNDebugLog(@"%@--%@ : executeQuery for exist one error :%d, %@, subId=%@", NSStringFromClass(self.class), NSStringFromSelector(_cmd), [db lastErrorCode], [db lastErrorMessage], subId);
		return NO;
	}
	
	NSArray *subHomeMySubscribeArray = [self getObjects:[SCSubscribeObject class] fromResultSet:rs];
	[rs close];
	
	//不存在，
	if([subHomeMySubscribeArray count] == 0) {
		if (!bAddIfNotExist) {
			SNDebugLog(@"%@--%@ : subscribe item with subId=%@ doesn't exist", NSStringFromClass(self.class), NSStringFromSelector(_cmd), subId);
			return YES;
		}
		//新增
		else {
            [db executeUpdate:[NSString stringWithFormat:@"INSERT INTO %@ (ID,defaultSub,subId,subName,subIcon,subInfo,moreInfo,pubIds,termId,lastTermLink,isPush,defaultPush,publishTime,unReadCount,subPersonCount,topNews,topNews2,isSubscribed,isDownloaded,isOnRank,isTop,topTime,indexValue,starGrade,commentCount,openTimes,backPromotion,templeteType,status,link,subShowType,stickTop,buttonTxt,needLogin,canOffline,userInfo,showComment,showRecmSub,topNewsAbstracts,topNewsLink,topNewsPicsString,sortIndex,topNewsString, countShowText) VALUES (NULL,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?)", TB_SUB_CENTER_ALL_SUBSCRIBE],
             [valuePairs objectForKey:TB_SUB_CENTER_ALL_SUB_DEFAULT_SUB],
             subId,
             [valuePairs objectForKey:TB_SUB_CENTER_ALL_SUB_SUB_NAME],
             [valuePairs objectForKey:TB_SUB_CENTER_ALL_SUB_SUB_ICON],
             [valuePairs objectForKey:TB_SUB_CENTER_ALL_SUB_SUB_INFO],
             [valuePairs objectForKey:TB_SUB_CENTER_ALL_SUB_MORE_INFO],
             [valuePairs objectForKey:TB_SUB_CENTER_ALL_SUB_PUB_IDS],
             [valuePairs objectForKey:TB_SUB_CENTER_ALL_SUB_TERM_ID],
             [valuePairs objectForKey:TB_SUB_CENTER_ALL_SUB_LAST_TERM_LINK],
             [valuePairs objectForKey:TB_SUB_CENTER_ALL_SUB_IS_PUSH],
             [valuePairs objectForKey:TB_SUB_CENTER_ALL_SUB_DEFAULT_PUSH],
             [valuePairs objectForKey:TB_SUB_CENTER_ALL_SUB_PUBLISH_TIME],
             [valuePairs objectForKey:TB_SUB_CENTER_ALL_SUB_UN_READ_COUNT],
             [valuePairs objectForKey:TB_SUB_CENTER_ALL_SUB_PERSON_COUNT],
             [valuePairs objectForKey:TB_SUB_CENTER_ALL_SUB_TOP_NEWS],
             [valuePairs objectForKey:TB_SUB_CENTER_ALL_SUB_TOP_NEWS2],
             [valuePairs objectForKey:TB_SUB_CENTER_ALL_SUB_IS_SUBSCRIBED],
             [valuePairs objectForKey:TB_SUB_CENTER_ALL_SUB_IS_DOWNLOADED],
             [valuePairs objectForKey:TB_SUB_CENTER_ALL_SUB_IS_ON_RANK],
             [valuePairs objectForKey:TB_SUB_CENTER_ALL_SUB_IS_TOP],
             [valuePairs objectForKey:TB_SUB_CENTER_ALL_SUB_TOP_TIME],
             [valuePairs objectForKey:TB_SUB_CENTER_ALL_SUB_INDEX_VALUE],
             [valuePairs objectForKey:TB_SUB_CENTER_ALL_SUB_GRADE_LEVEL],
             [valuePairs objectForKey:TB_SUB_CENTER_ALL_SUB_COMMENT_COUNT],
             [valuePairs objectForKey:TB_SUB_CENTER_ALL_SUB_OPEN_TIMES],
             [valuePairs objectForKey:TB_SUB_CENTER_ALL_SUB_BACK_PROMOTION],
             [valuePairs objectForKey:TB_SUB_CENTER_ALL_SUB_TEMPLATE_TYPE],
             [valuePairs objectForKey:TB_SUB_CENTER_ALL_SUB_STATUS],
             [valuePairs objectForKey:TB_SUB_CENTER_ALL_SUB_LINK],
             [valuePairs objectForKey:TB_SUB_CENTER_ALL_SUB_SUB_SHOW_TYPE],
             [valuePairs objectForKey:TB_SUB_CENTER_ALL_SUB_STICKTOP],
             [valuePairs objectForKey:TB_SUB_CENTER_ALL_SUB_BUTTONTXT],
             [valuePairs objectForKey:TB_SUB_CENTER_ALL_SUB_NEED_LOGIN],
             [valuePairs objectForKey:TB_SUB_CENTER_ALL_SUB_CAN_OFFLINE],
             [valuePairs objectForKey:TB_SUB_CENTER_ALL_SUB_USERINFO],
             [valuePairs objectForKey:TB_SUB_CENTER_ALL_SUB_SHOW_COMMENT],
             [valuePairs objectForKey:TB_SUB_CENTER_ALL_SUB_SHOW_RECOMMEND_SUB],
             [valuePairs objectForKey:TB_SUB_CENTER_ALL_SUB_TOP_NEWS_ABSTRACT],
             [valuePairs objectForKey:TB_SUB_CENTER_ALL_SUB_TOP_NEWS_LINK],
             [valuePairs objectForKey:TB_SUB_CENTER_ALL_SUB_TOP_NEWS_PICS],
             [valuePairs objectForKey:TB_SUB_CENTER_ALL_SUB_MY_SUB_SORT_INDEX],
             [valuePairs objectForKey:TB_SUB_CENTER_ALL_SUB_TOPNEWS],
             [valuePairs objectForKey:TB_SUB_CENTER_ALL_COUNT_SHOW_TEXT]
             ];
            
			if([db hadError]) {
				SNDebugLog(@"%@--%@ : executeUpdate insert item error :%d, %@, subId=%@, ItemInfo:%@", NSStringFromClass(self.class), NSStringFromSelector(_cmd), [db lastErrorCode],[db lastErrorMessage],subId,valuePairs);
				return NO;
			}
			SNDebugLog(@"%@--%@ : insert item,subId=%@,ItemInfo:%@", NSStringFromClass(self.class), NSStringFromSelector(_cmd), subId,valuePairs);
			return YES;
		}
	}
    
    NSMutableDictionary *newValupairs = [valuePairs mutableCopy];

    // merge isTop等属性
    SCSubscribeObject *subObj = [subHomeMySubscribeArray objectAtIndex:0];
//    if (subObj.isTop) {
//        [newValupairs setObject:subObj.isTop forKey:TB_SUB_CENTER_ALL_SUB_IS_TOP];
//    }
//    if (subObj.topTime) {
//        [newValupairs setObject:subObj.topTime forKey:TB_SUB_CENTER_ALL_SUB_TOP_TIME];
//    }
    
    id statuArg = [valuePairs objectForKey:@"manulSetStatus"];
    
    // 设置‘新’状态
    BOOL changeStatus = NO;
    
    // 除非手动强制刷新，否则比较termId
    if (!statuArg) {
        //NSString *newTermId = [valuePairs objectForKey:TB_SUB_CENTER_ALL_SUB_TERM_ID];
        
        //BOOL changeTermId = (newTermId && !([subObj.termId isEqualToString:@"0"] || [subObj.termId isEqualToString:newTermId]));
        
        //SNDebugLog(@"subId:%@ oldTermId:%@ newTermId:%@", subObj.subId, subObj.termId, newTermId);
        
        NSString *newPublishTime = [valuePairs objectForKey:TB_SUB_CENTER_ALL_SUB_PUBLISH_TIME];

        BOOL changePublishTime = newPublishTime && subObj.publishTime && ![subObj.publishTime isEqualToString:newPublishTime];
        
        if (/*changeTermId || */changePublishTime) {
            changeStatus = [subObj setStatusValue:[kHAVE_NEW_TERM intValue] forFlag:SCSubObjStatusFlagSubStatus];
            if (subObj.status != nil) {
                [newValupairs setObject:subObj.status forKey:TB_SUB_CENTER_ALL_SUB_STATUS];
            }
        }
    }
    
    [newValupairs removeObjectForKey:@"manulSetStatus"];
	
	//如果该项存在，则执行更新操作
	NSDictionary *updateSetStatementsInfo = [self formatUpdateSetStatementsInfoFromValuePairs:newValupairs ignoreNilValue:NO];
	if ([updateSetStatementsInfo count] == 0) {
		return NO;
	}
	
	NSString *setStatement			= [updateSetStatementsInfo objectForKey:UPDATE_SETSTATEMNT];
	NSMutableArray *valueArguments	= [updateSetStatementsInfo objectForKey:UPDATE_SETARGUMENTS];
	
	
	NSString *updateStatements	= [NSString stringWithFormat:@"UPDATE %@ %@ WHERE %@=?", TB_SUB_CENTER_ALL_SUBSCRIBE, setStatement, TB_SUB_CENTER_ALL_SUB_SUB_ID];
	[valueArguments addObject:subId];
    
	[db executeUpdate:updateStatements withArgumentsInArray:valueArguments];
    
	if ([db hadError]) {
		SNDebugLog(@"%@--%@ : executeUpdate error :%d,%@,updateStatements=%@,valueArguments:%@" , NSStringFromClass(self.class), NSStringFromSelector(_cmd), [db lastErrorCode],[db lastErrorMessage],updateStatements,valueArguments);
		return NO;
	}
	
    if (changeStatus) {
        NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:subObj.subId, @"subId", subObj.status, @"status", nil];
        [SNNotificationManager postNotificationName:kSubscribeObjectStatusChangedNotification object:nil userInfo:dict];
    }
    
	return YES;
}

// 更新单个SubHome我的订阅，如果不存在不要添加到数据库
- (BOOL)updateSubscribeCenterSubscribeObjectByPubId:(NSString*)pubId withValuePairs:(NSDictionary*)valuePairs {
    return [self updateSubscribeCenterSubscribeObjectByPubId:pubId withValuePairs:valuePairs addIfNotExist:NO];
}

// 更新单个SubHome我的订阅，如果不存在并可以根据参数决定要不要添加到数据库
- (BOOL)updateSubscribeCenterSubscribeObjectByPubId:(NSString*)pubId withValuePairs:(NSDictionary*)valuePairs addIfNotExist:(BOOL)bAddIfNotExist {
    if (!pubId || [@"" isEqualToString:pubId]) {
        return NO;
    }
    if (!valuePairs || [valuePairs count] <= 0) {
        return NO;
    }
    
    NSArray *mySubArray = [self getSubscribeCenterMySubscribeArray];
    for (SCSubscribeObject *subObj in mySubArray) {
        if (subObj && subObj.pubIds) {
            NSArray *_pubIdArray = [subObj.pubIds componentsSeparatedByString:@","];
            if (_pubIdArray && _pubIdArray.count > 0 && [_pubIdArray indexOfObject:pubId] != NSNotFound) {
                return [self updateSubscribeCenterSubscribeObjectBySubId:subObj.subId withValuePairs:valuePairs addIfNotExist:bAddIfNotExist];
            }
        }
    }
    return NO;
}

// 获取我的订阅数据(包括我的订阅和内置我的订阅)
// 不返回快讯，返回猜你喜欢
- (NSArray *)getSubscribeCenterMySubscribeArray {
    return [self getSubscribeCenterMySubscribeArrayByType:0];
}

// 返回快讯，不返回猜你喜欢
- (NSArray *)getSubArrayWithoutYouMayLike {
    return [self getSubscribeCenterMySubscribeArrayByType:1];
}

// 不返回快讯，不返回猜你喜欢
- (NSArray *)getSubArrayWithoutExpressOrYouMayLike {
    return [self getSubscribeCenterMySubscribeArrayByType:2];
}

- (NSArray *)getSubSortedArrayWithoutExpressOrYouMayLike {
    return [self getSubscribeCenterMySubscribeArrayByType:4];
}

- (NSArray *)getRecomSubArray {
    return [self getSubscribeCenterMySubscribeArrayByType:5];
}

- (NSArray *)getSubArrayWithExpress {
    return [self getSubscribeCenterMySubscribeArrayByType:6];
}

// 不返回快讯
- (NSArray *)getMySubscribeArrayInDatabase:(FMDatabase *)db {
    return [self getSubscribeCenterMySubscribeArrayByType:0 inDatabase:db];
}

- (NSArray *)getRecomSubscribeArrayInDatabase:(FMDatabase *)db {
    return [self getSubscribeCenterMySubscribeArrayByType:5 inDatabase:db];
}

- (BOOL)getExpressPushState
{
    __block BOOL push = NO;
    [[SNDatabase readQueue] inDatabase:^(FMDatabase *db) {
        FMResultSet *rs = [db executeQuery:[NSString stringWithFormat:@"SELECT * FROM %@ WHERE %@ = ?",TB_SUB_CENTER_ALL_SUBSCRIBE,TB_SUB_CENTER_ALL_SUB_SUB_ID],kExpressPushId];
        SCSubscribeObject *sub = [self getFirstObject:[SCSubscribeObject class] fromResultSet:rs];
        [rs close];
        if ([sub.isPush isEqualToString:@"1"]) {
            push = YES;
        }
    }];
    return NO;
}

- (NSInteger)getSubArrayCount
{
    __block BOOL count = 0;
    [[SNDatabase readQueue] inDatabase:^(FMDatabase *db) {
        count = [db intForQuery:[NSString stringWithFormat:@"SELECT COUNT(*) FROM %@",TB_SUB_CENTER_ALL_SUBSCRIBE]];
        if ([db hadError]) {
            SNDebugLog(@"getSubArrayCount ERROR %d,%@",[db lastErrorCode],[db lastErrorMessage]);
        }
    }];
    return count;
}


// 内部方法
// type: 1 - 返回快讯，不返回猜你喜欢
//      2 - 不返回快讯，不返回猜你喜欢
//      3 - 返回可离线刊物
//      4 - 不返回快讯，不反悔猜你喜欢，按用户排序后的顺序返回
//      5 - 推荐订阅isSubscribed=2的（v5.3.2）
//      其他 - 不返回快讯，返回猜你喜欢（如我的订阅）
- (NSArray *)getSubscribeCenterMySubscribeArrayByType:(int)type
{
    NSMutableArray *resultList = [NSMutableArray arrayWithCapacity:128];
    [[SNDatabase readQueue] inDatabase:^(FMDatabase *db) {
        [resultList addObjectsFromArray:[self getSubscribeCenterMySubscribeArrayByType:type inDatabase:db]];
    }];
    return resultList;
}

- (NSArray *)getSubArrayCanOffline {
    return [self getSubscribeCenterMySubscribeArrayByType:3];
}

- (NSArray *)getSubscribeCenterMySubscribeArrayByType:(int)type inDatabase:(FMDatabase *)db {
    NSMutableArray *resultList = [NSMutableArray arrayWithCapacity:128];
    NSString *queryByTopTime = nil;
    NSString *queryByPublishTime = nil;
    
    // isTop -- topTime
    if (type == 1) {
        // 返回快讯，不返回猜你喜欢（推送设置）
        queryByTopTime = [NSString stringWithFormat:@"SELECT * FROM %@ WHERE %@=1 AND %@=1 AND %@ != %@ ORDER BY %@ DESC",
                          TB_SUB_CENTER_ALL_SUBSCRIBE,
                          TB_SUB_CENTER_ALL_SUB_IS_TOP,
                          TB_SUB_CENTER_ALL_SUB_IS_SUBSCRIBED,
                          TB_SUB_CENTER_ALL_SUB_SUB_SHOW_TYPE,
                          kPluginSubShowType,
                          TB_SUB_CENTER_ALL_SUB_TOP_TIME];
        
        queryByPublishTime = [NSString stringWithFormat:@"SELECT * FROM %@ WHERE (%@=0 OR %@ is null) AND %@=1 AND %@ != %@ ORDER BY %@ DESC",
                              TB_SUB_CENTER_ALL_SUBSCRIBE,
                              TB_SUB_CENTER_ALL_SUB_IS_TOP,
                              TB_SUB_CENTER_ALL_SUB_IS_TOP,
                              TB_SUB_CENTER_ALL_SUB_IS_SUBSCRIBED,
                              TB_SUB_CENTER_ALL_SUB_SUB_SHOW_TYPE,
                              kPluginSubShowType,
                              TB_SUB_CENTER_ALL_SUB_PUBLISH_TIME];
    } else if (type == 2) {
        // 不返回快讯，不返回猜你喜欢（摇一摇）
        queryByTopTime = [NSString stringWithFormat:@"SELECT * FROM %@ WHERE %@=1 AND %@=1 AND %@ != 89 AND %@ != %@ ORDER BY %@ DESC",
                          TB_SUB_CENTER_ALL_SUBSCRIBE,
                          TB_SUB_CENTER_ALL_SUB_IS_TOP,
                          TB_SUB_CENTER_ALL_SUB_IS_SUBSCRIBED,
                          TB_SUB_CENTER_ALL_SUB_SUB_ID,
                          TB_SUB_CENTER_ALL_SUB_SUB_SHOW_TYPE,
                          kPluginSubShowType,
                          TB_SUB_CENTER_ALL_SUB_TOP_TIME];
        
        queryByPublishTime = [NSString stringWithFormat:@"SELECT * FROM %@ WHERE (%@=0 OR %@ is null) AND %@=1 AND %@ != 89 AND %@ != %@ ORDER BY %@ DESC",
                              TB_SUB_CENTER_ALL_SUBSCRIBE,
                              TB_SUB_CENTER_ALL_SUB_IS_TOP,
                              TB_SUB_CENTER_ALL_SUB_IS_TOP,
                              TB_SUB_CENTER_ALL_SUB_IS_SUBSCRIBED,
                              TB_SUB_CENTER_ALL_SUB_SUB_ID,
                              TB_SUB_CENTER_ALL_SUB_SUB_SHOW_TYPE,
                              kPluginSubShowType,
                              TB_SUB_CENTER_ALL_SUB_PUBLISH_TIME];
    } else if (type == 3) {
        // 返回可离线刊物
        queryByTopTime = [NSString stringWithFormat:@"SELECT * FROM %@ WHERE %@=1 AND %@=1 AND %@ != 89 AND %@ != %@ AND %@=1 ORDER BY %@ DESC",
                          TB_SUB_CENTER_ALL_SUBSCRIBE,
                          TB_SUB_CENTER_ALL_SUB_IS_TOP,
                          TB_SUB_CENTER_ALL_SUB_IS_SUBSCRIBED,
                          TB_SUB_CENTER_ALL_SUB_SUB_ID,
                          TB_SUB_CENTER_ALL_SUB_SUB_SHOW_TYPE,
                          kPluginSubShowType,
                          TB_SUB_CENTER_ALL_SUB_CAN_OFFLINE,
                          TB_SUB_CENTER_ALL_SUB_TOP_TIME];
        
        queryByPublishTime = [NSString stringWithFormat:@"SELECT * FROM %@ WHERE (%@=0 OR %@ is null) AND %@=1 AND %@ != 89 AND %@ != %@ AND %@=1 ORDER BY %@ DESC",
                              TB_SUB_CENTER_ALL_SUBSCRIBE,
                              TB_SUB_CENTER_ALL_SUB_IS_TOP,
                              TB_SUB_CENTER_ALL_SUB_IS_TOP,
                              TB_SUB_CENTER_ALL_SUB_IS_SUBSCRIBED,
                              TB_SUB_CENTER_ALL_SUB_SUB_ID,
                              TB_SUB_CENTER_ALL_SUB_SUB_SHOW_TYPE,
                              kPluginSubShowType,
                              TB_SUB_CENTER_ALL_SUB_CAN_OFFLINE,
                              TB_SUB_CENTER_ALL_SUB_PUBLISH_TIME];
    } else if (type == 4) {
        
        queryByTopTime = [NSString stringWithFormat:@"SELECT * FROM %@ WHERE %@=1 AND %@ != 89 AND %@ != %@ ORDER BY -%@ DESC",
                          TB_SUB_CENTER_ALL_SUBSCRIBE,
                          TB_SUB_CENTER_ALL_SUB_IS_SUBSCRIBED,
                          TB_SUB_CENTER_ALL_SUB_SUB_ID,
                          TB_SUB_CENTER_ALL_SUB_SUB_SHOW_TYPE,
                          kPluginSubShowType,
                          TB_SUB_CENTER_ALL_SUB_MY_SUB_SORT_INDEX];
        
        FMResultSet *rs	= [db executeQuery:queryByTopTime];
        if ([db hadError]) {
            SNDebugLog(@"%@--%@ : executeQuery error :%d, %@",  NSStringFromClass(self.class), NSStringFromSelector(_cmd), [db lastErrorCode],[db lastErrorMessage]);
            return nil;
        }
        NSArray *topGroupList = [self getObjects:[SCSubscribeObject class] fromResultSet:rs];
        [resultList addObjectsFromArray:topGroupList];
        [rs close];
        
        return resultList;
        
    } else if(type == 5) {
        queryByPublishTime = [NSString stringWithFormat:@"SELECT * FROM %@ WHERE %@=2 ORDER BY -%@ DESC",
                              TB_SUB_CENTER_ALL_SUBSCRIBE,
                              TB_SUB_CENTER_ALL_SUB_IS_SUBSCRIBED,
                              TB_SUB_CENTER_ALL_SUB_MY_SUB_SORT_INDEX];
    }
    else if(type == 6) {
        queryByPublishTime = [NSString stringWithFormat:@"SELECT * FROM %@ WHERE %@=1 AND %@ = 89 ORDER BY -%@ DESC",
                              TB_SUB_CENTER_ALL_SUBSCRIBE,
                              TB_SUB_CENTER_ALL_SUB_IS_SUBSCRIBED,
                              TB_SUB_CENTER_ALL_SUB_SUB_ID,
                              TB_SUB_CENTER_ALL_SUB_MY_SUB_SORT_INDEX];
    }else {
        // 不返回快讯，返回猜你喜欢（我的订阅）
//        queryByTopTime = [NSString stringWithFormat:@"SELECT * FROM %@ WHERE %@=1 AND %@=1 AND %@ != 89 ORDER BY %@ DESC",
//                          TB_SUB_CENTER_ALL_SUBSCRIBE,
//                          TB_SUB_CENTER_ALL_SUB_IS_TOP,
//                          TB_SUB_CENTER_ALL_SUB_IS_SUBSCRIBED,
//                          TB_SUB_CENTER_ALL_SUB_SUB_ID,
//                          TB_SUB_CENTER_ALL_SUB_TOP_TIME];
        
        queryByPublishTime = [NSString stringWithFormat:@"SELECT * FROM %@ WHERE %@=1 AND %@ != 89 ORDER BY %@ DESC",
                              TB_SUB_CENTER_ALL_SUBSCRIBE,
                              TB_SUB_CENTER_ALL_SUB_IS_SUBSCRIBED,
                              TB_SUB_CENTER_ALL_SUB_SUB_ID,
                              TB_SUB_CENTER_ALL_SUB_PUBLISH_TIME];
    }
    
    FMResultSet *rs = nil;
    if (queryByTopTime)
    {
        rs	= [db executeQuery:queryByTopTime];
        if ([db hadError]) {
            SNDebugLog(@"%@--%@ : executeQuery error :%d, %@",  NSStringFromClass(self.class), NSStringFromSelector(_cmd), [db lastErrorCode],[db lastErrorMessage]);
            return nil;
        }
        NSArray *topGroupList = [self getObjects:[SCSubscribeObject class] fromResultSet:rs];
        [resultList addObjectsFromArray:topGroupList];
        [rs close];
    }
    
    // publishTime
	rs	= [db executeQuery:queryByPublishTime];
	if ([db hadError]) {
		SNDebugLog(@"%@--%@ : executeQuery error :%d, %@",  NSStringFromClass(self.class), NSStringFromSelector(_cmd), [db lastErrorCode],[db lastErrorMessage]);
		return nil;
	}
	NSArray *subscribeList = [self getObjects:[SCSubscribeObject class] fromResultSet:rs];
    [resultList addObjectsFromArray:subscribeList];
	[rs close];
    
	return resultList;
}

- (NSArray *)getSubscribeCenterSelectedMySubList {
    NSMutableArray *allSubs = [NSMutableArray array];
    [[SNDatabase readQueue] inDatabase:^(FMDatabase *db) {
        FMResultSet *rs	= nil;
        
        // 先加载根据topTime排序的集合
        rs = [db executeQuery:[NSString stringWithFormat:@"select a.ID, a.defaultSub, a.subId, a.subName, a.subIcon, a.subInfo, a.moreInfo, a.pubIds, a.termId, a.lastTermLink, a.isPush, a.defaultPush, a.publishTime, a.unReadCount, a.subPersonCount, a.topNews, a.topNews2, a.isSubscribed, a.isDownloaded, a.isOnRank, a.isTop, a.topTime, a.indexValue, a.starGrade, a.commentCount, a.openTimes, a.backPromotion, a.templeteType, a.status, a.isSelected, a.link, a.subShowType, a.countShowText from %@ a where a.isSubscribed='1' and a.isSelected='1' and a.subId != '%@' and a.subShowType != '%@' and a.isTop = '1' ORDER BY a.topTime desc;", TB_SUB_CENTER_ALL_SUBSCRIBE, kExpressPushId, kPluginSubShowType]];
        if ([db hadError]) {
            SNDebugLog(@"ERROR : %@--%@, executeQuery error :%d,%@", NSStringFromClass(self.class),  NSStringFromSelector(_cmd), [db lastErrorCode],[db lastErrorMessage]);
            return;
        }
        NSArray *subscribeList = [self getObjects:[SCSubscribeObject class] fromResultSet:rs];
        [rs close];
        if ([subscribeList count] > 0) {
            [allSubs addObjectsFromArray:subscribeList];
        }
        
        // 再加载根据publistTime排序的未置顶的数据集合
        rs = [db executeQuery:[NSString stringWithFormat:@"select a.ID, a.defaultSub, a.subId, a.subName, a.subIcon, a.subInfo, a.moreInfo, a.pubIds, a.termId, a.lastTermLink, a.isPush, a.defaultPush, a.publishTime, a.unReadCount, a.subPersonCount, a.topNews, a.topNews2, a.isSubscribed, a.isDownloaded, a.isOnRank, a.isTop, a.topTime, a.indexValue, a.starGrade, a.commentCount, a.openTimes, a.backPromotion, a.templeteType, a.status, a.isSelected, a.link, a.subShowType, a.countShowText from %@ a where a.isSubscribed='1' and a.isSelected='1' and a.subId != '%@' and a.subShowType != '%@' and (a.isTop != '1' or a.isTop is null) ORDER BY a.publishTime desc;", TB_SUB_CENTER_ALL_SUBSCRIBE, kExpressPushId, kPluginSubShowType]];
        if ([db hadError]) {
            SNDebugLog(@"ERROR : %@--%@, executeQuery error :%d,%@", NSStringFromClass(self.class),  NSStringFromSelector(_cmd), [db lastErrorCode],[db lastErrorMessage]);
            return;
        }
        NSArray *subscribeListUnTop = [self getObjects:[SCSubscribeObject class] fromResultSet:rs];
        [rs close];
        if ([subscribeListUnTop count] > 0) {
            [allSubs addObjectsFromArray:subscribeListUnTop];
        }
    }];
    
	return allSubs;
}

// 获取未下载的且在下载设置里勾选的“我的订阅”数据集合
- (NSArray *)getSubscribeCenterSelectedUndownloadedMySubList {
    NSMutableArray *allSubs = [NSMutableArray array];
    [[SNDatabase readQueue] inDatabase:^(FMDatabase *db) {
        FMResultSet *rs	= nil;
        
        // 先加载根据topTime排序的集合
        rs = [db executeQuery:[NSString stringWithFormat:@"select a.ID, a.defaultSub, a.subId, a.subName, a.subIcon, a.subInfo, a.moreInfo, a.pubIds, a.termId, a.lastTermLink, a.isPush, a.defaultPush, a.publishTime, a.subPersonCount, a.topNews, a.topNews2, a.isSubscribed, a.isDownloaded, a.isOnRank, a.isTop, a.topTime, a.indexValue, a.starGrade, a.commentCount, a.openTimes, a.backPromotion, a.templeteType, a.status, a.isSelected, a.link, a.subShowType, a.countShowText from %@ a left join %@ b on (a.subId = b.subId and a.termId = b.termId) where (b.downloadFlag = '0' or b.downloadFlag is null or (a.publishTime != b.publishTime and b.publishTime is not null)) and (a.isSelected='1' and a.isSubscribed='1' and a.subId != '%@' and a.subShowType != '%@' and a.isTop = '1') ORDER BY a.topTime desc;", TB_SUB_CENTER_ALL_SUBSCRIBE, TB_NEWSPAPER, kExpressPushId, kPluginSubShowType]];
        if ([db hadError]) {
            SNDebugLog(@"ERROR : %@--%@, executeQuery error :%d,%@", NSStringFromClass(self.class),  NSStringFromSelector(_cmd), [db lastErrorCode],[db lastErrorMessage]);
            return;
        }
        NSArray *subscribeList = [self getObjects:[SCSubscribeObject class] fromResultSet:rs];
        [rs close];
        if ([subscribeList count] > 0) {
            [allSubs addObjectsFromArray:subscribeList];
        }
        
        // 再加载根据publistTime排序的未置顶的数据集合
        rs = [db executeQuery:[NSString stringWithFormat:@"select a.ID, a.defaultSub, a.subId, a.subName, a.subIcon, a.subInfo, a.moreInfo, a.pubIds, a.termId, a.lastTermLink, a.isPush, a.defaultPush, a.publishTime, a.subPersonCount, a.topNews, a.topNews2, a.isSubscribed, a.isDownloaded, a.isOnRank, a.isTop, a.topTime, a.indexValue, a.starGrade, a.commentCount, a.openTimes, a.backPromotion, a.templeteType, a.status, a.isSelected, a.link, a.subShowType, a.countShowText from %@ a left join %@ b on (a.subId = b.subId and a.termId = b.termId) where (b.downloadFlag = '0' or b.downloadFlag is null or (a.publishTime != b.publishTime and b.publishTime is not null)) and (a.isSelected='1' and a.isSubscribed='1' and a.subId != '%@' and a.subShowType != '%@' and (a.isTop != '1' or a.isTop is null)) ORDER BY a.publishTime desc;", TB_SUB_CENTER_ALL_SUBSCRIBE, TB_NEWSPAPER, kExpressPushId, kPluginSubShowType]];
        if ([db hadError]) {
            SNDebugLog(@"ERROR : %@--%@, executeQuery error :%d,%@", NSStringFromClass(self.class),  NSStringFromSelector(_cmd), [db lastErrorCode],[db lastErrorMessage]);
            return;
        }
        NSArray *subscribeListUnTop = [self getObjects:[SCSubscribeObject class] fromResultSet:rs];
        [rs close];
        if ([subscribeListUnTop count] > 0) {
            [allSubs addObjectsFromArray:subscribeListUnTop];
        }
    }];
    
	return allSubs;
}

// 获取未下载的“我的订阅”数据集合
- (NSArray *)getSubscribeCenterUndownloadedMySubList {
    NSMutableArray *allSubs = [NSMutableArray array];
    [[SNDatabase readQueue] inDatabase:^(FMDatabase *db) {
        FMResultSet *rs	= nil;
        
        // 先加载根据topTime排序的集合
        rs = [db executeQuery:[NSString stringWithFormat:@"select a.ID, a.defaultSub, a.subId, a.subName, a.subIcon, a.subInfo, a.moreInfo, a.pubIds, a.termId, a.lastTermLink, a.isPush, a.defaultPush, a.publishTime, a.subPersonCount, a.topNews, a.topNews2, a.isSubscribed, a.isDownloaded, a.isOnRank, a.isTop, a.topTime, a.indexValue, a.starGrade, a.commentCount, a.openTimes, a.backPromotion, a.templeteType, a.status, a.isSelected, a.link, a.subShowType, a.countShowText from %@ a left join %@ b on (a.subId = b.subId and a.termId = b.termId) where (b.downloadFlag = '0' or b.downloadFlag is null or (a.publishTime != b.publishTime and b.publishTime is not null)) and (a.isSubscribed='1' and a.subId != '%@' and a.subShowType != '%@' and a.isTop = '1') ORDER BY a.topTime desc;", TB_SUB_CENTER_ALL_SUBSCRIBE, TB_NEWSPAPER, kExpressPushId, kPluginSubShowType]];
        if ([db hadError]) {
            SNDebugLog(@"ERROR : %@--%@, executeQuery error :%d,%@", NSStringFromClass(self.class),  NSStringFromSelector(_cmd), [db lastErrorCode],[db lastErrorMessage]);
            return;
        }
        NSArray *subscribeList = [self getObjects:[SCSubscribeObject class] fromResultSet:rs];
        [rs close];
        if ([subscribeList count] > 0) {
            [allSubs addObjectsFromArray:subscribeList];
        }
        
        // 再加载根据publistTime排序的未置顶的数据集合
        rs = [db executeQuery:[NSString stringWithFormat:@"select a.ID, a.defaultSub, a.subId, a.subName, a.subIcon, a.subInfo, a.moreInfo, a.pubIds, a.termId, a.lastTermLink, a.isPush, a.defaultPush, a.publishTime, a.subPersonCount, a.topNews, a.topNews2, a.isSubscribed, a.isDownloaded, a.isOnRank, a.isTop, a.topTime, a.indexValue, a.starGrade, a.commentCount, a.openTimes, a.backPromotion, a.templeteType, a.status, a.isSelected, a.link, a.subShowType, a.countShowText from %@ a left join %@ b on (a.subId = b.subId and a.termId = b.termId) where (b.downloadFlag = '0' or b.downloadFlag is null or (a.publishTime != b.publishTime and b.publishTime is not null)) and (a.isSubscribed='1' and a.subId != '%@' and a.subShowType != '%@' and (a.isTop != '1' or a.isTop is null)) ORDER BY a.publishTime desc;", TB_SUB_CENTER_ALL_SUBSCRIBE, TB_NEWSPAPER, kExpressPushId, kPluginSubShowType]];
        if ([db hadError]) {
            SNDebugLog(@"ERROR : %@--%@, executeQuery error :%d,%@", NSStringFromClass(self.class),  NSStringFromSelector(_cmd), [db lastErrorCode],[db lastErrorMessage]);
            return;
        }
        NSArray *subscribeListUnTop = [self getObjects:[SCSubscribeObject class] fromResultSet:rs];
        [rs close];
        if ([subscribeListUnTop count] > 0) {
            [allSubs addObjectsFromArray:subscribeListUnTop];
        }
    }];
	     
	return allSubs;
}

-(BOOL)isNewsSubscribe:(NSString*)aLink
{
    NSArray* channelArray = [NSArray arrayWithObjects:kProtocolNewsChannel,kProtocolWeiboChannel,kProtocolPhotoChannel,kProtocolLiveChannel, nil];
    for(NSString* channel in channelArray)
    {
        if (NSNotFound != [aLink rangeOfString:channel].location)
            return YES;
    }
    
    return NO;
}

// add in 3.4 for 离线下载 筛除以订阅里的频道信息,因为频道里数据是无法通过zip包的方式来下载的
-(NSMutableArray*)filterNewsSubscribeFromSubscribeArray:(NSArray*)aList
{
    NSMutableArray* array = [NSMutableArray array];
    for(NSInteger i=0; i<[aList count]; i++)
    {
        id object = [aList objectAtIndex:i];
        if([object isKindOfClass:[SCSubscribeObject class]])
        {
            SCSubscribeObject* data = (SCSubscribeObject*)object;            
            
            if(data.link!=nil && [data.link length]>0)
            {
                if(![self isNewsSubscribe:data.link])
                    [array addObject:data];
            }
            //没有link,目前只能在单独离线频道里出现
            else
                [array addObject:data];
        }
    }
    return array;
}

#pragma mark - 所有订阅

// 保存我的订阅到数据库 (先delete all再insert的事务操作)
- (BOOL)addSubscribeCenterMySubscribes:(NSArray *)mySubscribePOArray {
	if (nil == mySubscribePOArray) {
		SNDebugLog(@"ERROR: %@--%@ : Invalid list", NSStringFromClass(self.class), NSStringFromSelector(_cmd));
		return NO;
	}
	
	__block BOOL result = YES;
    [[SNDatabase writeQueue] inTransaction:^(FMDatabase *db, BOOL *rollback) {
        // 先清理掉服务器已经下架的 我的刊物
        NSArray *allsubs = [self getMySubscribeArrayInDatabase:db];
        
        if ([allsubs count] > 0) {
            NSMutableArray *leaveToDelete = [NSMutableArray arrayWithArray:allsubs];
            [leaveToDelete removeObjectsInArray:mySubscribePOArray];
            
            if ([leaveToDelete count] > 0) {
                result = [self deleteSubscribeCenterSubscribeObjectsInAllArray:leaveToDelete inDatabase:db];
            }
            
            if ([db hadError]) {
                *rollback = YES;
                SNDebugLog(@"ERROR: %@--%@ : executeUpdate delete former list with comming error message : %d, %@", NSStringFromClass(self.class), NSStringFromSelector(_cmd), [db lastErrorCode],[db lastErrorMessage]);
                return;
            }
        }
    }];
	if (![self addSubscribeCenterSubscribeObjects:mySubscribePOArray updateIfExist:YES]) {
		return NO;
	}
    
	return YES;
}

// 保存推荐订阅到数据库(先delete all再insert)
- (BOOL)addSubscribeCenterRecomSubscribes:(NSArray *)recomSubscribePOArray {
    if (nil == recomSubscribePOArray) {
        return NO;
    }
    
    __block BOOL result = YES;
    [[SNDatabase writeQueue] inTransaction:^(FMDatabase *db, BOOL *rollback) {
        // 先清理掉服务器已经下架的 我的刊物
        NSArray *allsubs = [self getRecomSubscribeArrayInDatabase:db];
        
        if ([allsubs count] > 0) {
            NSMutableArray *leaveToDelete = [NSMutableArray arrayWithArray:allsubs];
            [leaveToDelete removeObjectsInArray:recomSubscribePOArray];
            
            if ([leaveToDelete count] > 0) {
                result = [self deleteSubscribeCenterSubscribeObjectsInAllArray:leaveToDelete inDatabase:db];
            }
            
            if ([db hadError]) {
                *rollback = YES;
                return;
            }
        }
    }];
    if (![self addSubscribeCenterSubscribeObjects:recomSubscribePOArray updateIfExist:YES]) {
        return NO;
    }
    
    return YES;
}

// 保存更多推荐订阅到数据库
- (BOOL)addSubscribeCenterMoreRecomSubscribes:(NSArray *)recomSubscribePOArray {
    if (nil == recomSubscribePOArray) {
        return NO;
    }
    
    if (![self addSubscribeCenterSubscribeObjects:recomSubscribePOArray updateIfExist:YES]) {
        return NO;
    }
    
    return YES;
}

// 保存所有订阅数据到数据库（先delete all再insert的事务操作）
- (BOOL)addSubscribeCenterAllSubscribes:(NSArray *)allSubscribePOArray {
	if (nil == allSubscribePOArray) {
		SNDebugLog(@"ERROR: %@--%@ : Invalid list", NSStringFromClass(self.class), NSStringFromSelector(_cmd));
		return NO;
	}
	__block BOOL result = YES;
	[[SNDatabase writeQueue] inTransaction:^(FMDatabase *db, BOOL *rollback) {
        // 先清理掉服务器已经下架的刊物
        NSArray *allsubs = [self getSubscribeCenterAllSubscribesArrayInDatabase:db];
        
        if ([allsubs count] > 0) {
            NSMutableArray *leaveToDelete = [NSMutableArray arrayWithArray:allsubs];
            [leaveToDelete removeObjectsInArray:allSubscribePOArray];
            
            if ([leaveToDelete count] > 0) {
                result = [self deleteSubscribeCenterSubscribeObjectsInAllArray:leaveToDelete inDatabase:db];
            }
            
            if ([db hadError]) {
                *rollback = YES;
                SNDebugLog(@"ERROR: %@--%@ : executeUpdate delete former list with comming error message : %d, %@", NSStringFromClass(self.class), NSStringFromSelector(_cmd), [db lastErrorCode],[db lastErrorMessage]);
                return;
            }
        }
        
    }];
	
	if (![self addSubscribeCenterSubscribeObjects:allSubscribePOArray updateIfExist:YES]) {
		return NO;
	}
    
	return YES;
}

// 获取所有订阅数据列表（已订阅和未订阅的）
- (NSArray *)getSubscribeCenterAllSubscribesArray {
    __block NSArray *allSubscribe  = nil;
    [[SNDatabase readQueue] inDatabase:^(FMDatabase *db) {
        
        FMResultSet *rs	= [db executeQuery:[NSString stringWithFormat:@"SELECT * FROM %@", TB_SUB_CENTER_ALL_SUBSCRIBE]];
        
        if ([db hadError]) {
            SNDebugLog(@"%@--%@ : executeQuery  error :%d, %@" , NSStringFromClass(self.class), NSStringFromSelector(_cmd), [db lastErrorCode], [db lastErrorMessage]);
            return ;
        }
        
        allSubscribe = [self getObjects:[SCSubscribeObject class] fromResultSet:rs];
        
        [rs close];
    }];
    
	return allSubscribe;
}

- (NSArray *)getSubscribeCenterAllSubscribesArrayInDatabase:(FMDatabase *)db {
    FMResultSet *rs	= [db executeQuery:[NSString stringWithFormat:@"SELECT * FROM %@", TB_SUB_CENTER_ALL_SUBSCRIBE]];
    
    if ([db hadError]) {
        SNDebugLog(@"%@--%@ : executeQuery  error :%d, %@" , NSStringFromClass(self.class), NSStringFromSelector(_cmd), [db lastErrorCode], [db lastErrorMessage]);
        return nil;
    }
    
    NSArray *allSubscribe = [self getObjects:[SCSubscribeObject class] fromResultSet:rs];
    
    [rs close];
    
	return allSubscribe;
}

// 获取所有订阅中在rank list上的数据
- (NSArray *)getSubscribeCenterAllSubscribesOnRankListArray {
    __block NSArray *allSubscribe = nil;
    [[SNDatabase readQueue] inDatabase:^(FMDatabase *db) {
        FMResultSet *rs	= [db executeQuery:[NSString stringWithFormat:@"SELECT * FROM %@ WHERE %@=1", TB_SUB_CENTER_ALL_SUBSCRIBE, TB_SUB_CENTER_ALL_SUB_IS_ON_RANK]];
        
        if ([db hadError]) {
            SNDebugLog(@"%@--%@ : executeQuery  error :%d, %@" , NSStringFromClass(self.class), NSStringFromSelector(_cmd), [db lastErrorCode], [db lastErrorMessage]);
            return;
        }
        
        allSubscribe = [self getObjects:[SCSubscribeObject class] fromResultSet:rs];
        
        [rs close];
    
    }];
	   
	return allSubscribe;
}

// 根据subTypeId获取对应的所有刊物数据
- (NSArray *)getSubscribeCenterSubItemsBySubTypeId:(NSString *)typeId {
    if ([typeId length] <= 0) {
        SNDebugLog(@"%@--%@ invalidate typeId", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
        return nil;
    }
    
    // step 1: 从关系表中获取对应typeId下的所有subId集合
    NSArray *subIds = [self getSubscribeTypeRelationSubIdsForTypeId:typeId];
    if ([subIds count] <= 0) {
        SNDebugLog(@"%@--%@ there`s no subId that is relation to typeId %@", NSStringFromClass([self class]), NSStringFromSelector(_cmd), typeId);
        return nil;
    }
    
    NSMutableArray *subItemsArray = [NSMutableArray array];
    
    for (NSString *subId in subIds) {
        SCSubscribeObject *subObj = [self getSubscribeCenterSubscribeObjectBySubId:subId];
        if (subObj) {
            [subItemsArray addObject:subObj];
        }
    }
    
    return [subItemsArray count] > 0 ? subItemsArray : nil;
}

// 根据subId获取对应的某一个“所有订阅”数据
- (SCSubscribeObject *)getSubscribeCenterSubscribeObjectBySubId:(NSString*)subId {
	__block NSArray *allSubscribes = nil;
    [[SNDatabase readQueue] inDatabase:^(FMDatabase *db) {
        FMResultSet *rs	= [db executeQuery:[NSString stringWithFormat:@"SELECT * FROM %@ where subId=?", TB_SUB_CENTER_ALL_SUBSCRIBE], subId];
        if ([db hadError]) {
            SNDebugLog(@"%@--%@ : executeQuery  error :%d, %@", NSStringFromClass(self.class), NSStringFromSelector(_cmd), [db lastErrorCode], [db lastErrorMessage]);
            return;
        }
        
        allSubscribes = [self getObjects:[SCSubscribeObject class] fromResultSet:rs];
        [rs close];
	    
    }];
    
    if (allSubscribes && allSubscribes.count > 0) {
        return [allSubscribes objectAtIndex:0];
    } else {
        return nil;
    }
}

// 根据pubId获取对应的某一个“所有订阅”数据
- (SCSubscribeObject *)getSubscribeCenterSubscribeObjectByPubId:(NSString *)pubId {
    if (!pubId || [@"" isEqualToString:pubId]) {
        return nil;
    }
    
    NSArray *_mySubArray = [self getSubscribeCenterAllSubscribesArray];
    for (SCSubscribeObject *_mySubPO in _mySubArray) {
        if (_mySubPO && _mySubPO.pubIds) {
            NSArray *_pubIdArray = [_mySubPO.pubIds componentsSeparatedByString:@","];
            if (_pubIdArray && _pubIdArray.count > 0 && [_pubIdArray indexOfObject:pubId] != NSNotFound) {
                return _mySubPO;
            }
        }
    }
    return nil;
}

// 根据pubIds获取对应的某一个“所有订阅”数据
- (SCSubscribeObject *)getSubscribeCenterSubscribeObjectByPubIds:(NSString*)pubIds {
    
    __block NSArray *allSubscribes  = nil;
    [[SNDatabase readQueue] inDatabase:^(FMDatabase *db) {
        FMResultSet *rs	= [db executeQuery:[NSString stringWithFormat:@"SELECT * FROM %@ where pubIds=?", TB_SUB_CENTER_ALL_SUBSCRIBE], pubIds];
        
        if ([db hadError]) {
            
            SNDebugLog(@"%@--%@ : executeQuery  error :%d, %@", NSStringFromClass(self.class), NSStringFromSelector(_cmd), [db lastErrorCode], [db lastErrorMessage]);
            
            return;
        }
        
        allSubscribes = [self getObjects:[SCSubscribeObject class] fromResultSet:rs];
        
        [rs close];
	}];
    if (allSubscribes && allSubscribes.count > 0) {
        
        return [allSubscribes objectAtIndex:0];
        
    } else {
        
        return nil;
        
    }
}

// 获取所有未订阅所有订阅数据列表（未订阅）
- (NSArray*)getSubscribeCenterUnsubAllSubscribesArray {
    __block NSArray *allSubscribe  = nil;
    [[SNDatabase readQueue] inDatabase:^(FMDatabase *db) {
        FMResultSet *rs	= [db executeQuery:[NSString stringWithFormat:@"SELECT * FROM %@ where isSubscribed != '1'", TB_SUB_CENTER_ALL_SUBSCRIBE]];
        if ([db hadError]) {
            SNDebugLog(@"%@--%@ : executeQuery  error :%d, %@" , NSStringFromClass(self.class), NSStringFromSelector(_cmd), [db lastErrorCode], [db lastErrorMessage]);
            return;
        }
        allSubscribe = [self getObjects:[SCSubscribeObject class] fromResultSet:rs];
        [rs close];
    }];
	return allSubscribe;
}

// 获取推荐刊物列表数据
- (NSArray *)getSubscribeCenterRecommendedSubs {
    __block NSArray *allSubscribe  = nil;
    [[SNDatabase readQueue] inDatabase:^(FMDatabase *db) {
        FMResultSet *rs	= [db executeQuery:[NSString stringWithFormat:@"SELECT * FROM %@ where defaultSub == '1' and isSubscribed != '1'", TB_SUB_CENTER_ALL_SUBSCRIBE]];
        
        if ([db hadError]) {
            SNDebugLog(@"%@--%@ : executeQuery  error :%d, %@" , NSStringFromClass(self.class), NSStringFromSelector(_cmd), [db lastErrorCode], [db lastErrorMessage]);
            return;
        }
        allSubscribe = [self getObjects:[SCSubscribeObject class] fromResultSet:rs];
        [rs close];
        
    }];
	
	return allSubscribe;
}

#pragma mark - subtype list
// sub type list
// 批量添加
- (BOOL)addSubscribeCenterSubTypes:(NSArray *)typesArray bUpdateIfExist:(BOOL)bUPdateIfExist {
    if ([typesArray count] <= 0 || nil == typesArray) {
        SNDebugLog(@"ERROR %@--%@ invalidate typesArray", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
        return NO;
    }
    
    __block BOOL bSucceed = YES;
    [[SNDatabase writeQueue] inTransaction:^(FMDatabase *db, BOOL *rollback) {
        for (SCSubscribeTypeObject *typeObj in typesArray) {
            bSucceed = [self addSubscribeCenterSubType:typeObj bUpdateIfExist:bUPdateIfExist inDatabase:db];
            if (!bSucceed) {
                *rollback = YES;
                return;
            }
        }
    }];
    
    return bSucceed;
}

- (BOOL)addSubscribeCenterSubType:(SCSubscribeTypeObject *)typeObj bUpdateIfExist:(BOOL)bUpdateIfExist
{
    __block BOOL result = YES;
    [[SNDatabase writeQueue] inTransaction:^(FMDatabase *db, BOOL *rollback) {
        result = [self addSubscribeCenterSubType:typeObj bUpdateIfExist:bUpdateIfExist inDatabase:db];
        if (!result) {
            *rollback = YES;
        }
    }];
    return result;
}
// 单个添加
- (BOOL)addSubscribeCenterSubType:(SCSubscribeTypeObject *)typeObj bUpdateIfExist:(BOOL)bUpdateIfExist inDatabase:(FMDatabase *)db{
    if (nil == typeObj) {
        SNDebugLog(@"%@--%@ invalidate typeObj", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
        return NO;
    }
    if (bUpdateIfExist) {
        [db executeUpdate:[NSString stringWithFormat:@"REPLACE INTO %@ (typeId,typeName,typeIcon,subId,subName) VALUES (?,?,?,?,?)", TB_SUB_CENTER_SUB_TYPES],
         typeObj.typeId,
         typeObj.typeName,
         typeObj.typeIcon,
         typeObj.subId,
         typeObj.subName];
        
        if ([db hadError]) {
            SNDebugLog(@"%@--%@ error occur while executeUpdate : %d - %@",
                       NSStringFromClass([self class]), NSStringFromSelector(_cmd), [db lastErrorCode], [db lastErrorMessage]);
            return NO;
        }

    } else {
        
        NSInteger count = [db intForQuery:[NSString stringWithFormat:@"SELECT COUNT(*) FROM %@ WHERE %@ = ?", TB_SUB_CENTER_SUB_TYPES, TB_SUB_CENTER_TYPES_TYPE_ID], typeObj.typeId];
        if (count==0) {
            [db executeUpdate:[NSString stringWithFormat:@"INSERT INTO %@ (typeId,typeName,typeIcon,subId,subName) VALUES (?,?,?,?,?)", TB_SUB_CENTER_SUB_TYPES],
             typeObj.typeId,
             typeObj.typeName,
             typeObj.typeIcon,
             typeObj.subId,
             typeObj.subName];
            
            if ([db hadError]) {
                SNDebugLog(@"%@--%@ error occur while executeUpdate : %d - %@",
                           NSStringFromClass([self class]), NSStringFromSelector(_cmd), [db lastErrorCode], [db lastErrorMessage]);
                return NO;
            }
        }
    }
    return YES;
}

- (BOOL)updateSubscribeCenterSubType:(SCSubscribeTypeObject *)typeObj bAddIfNotExist:(BOOL)bAddIfNotExist
{
    __block BOOL result = YES;
    [[SNDatabase writeQueue] inTransaction:^(FMDatabase *db, BOOL *rollback) {
        result = [self updateSubscribeCenterSubType:typeObj bAddIfNotExist:bAddIfNotExist inDatabase:db];
        if (!result) {
            *rollback = YES;
        }
    }];
    return result;
}
// 单个更新
- (BOOL)updateSubscribeCenterSubType:(SCSubscribeTypeObject *)typeObj bAddIfNotExist:(BOOL)bAddIfNotExist inDatabase:(FMDatabase *)db{
    if (nil == typeObj) {
        SNDebugLog(@"%@--%@ invalidte typeObj", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
        return NO;
    }
    
    // 查询是否存在
    FMResultSet *rs = [db executeQuery:[NSString stringWithFormat:@"SELECT * FROM %@ WHERE %@ = ?", TB_SUB_CENTER_SUB_TYPES, TB_SUB_CENTER_TYPES_TYPE_ID], typeObj.typeId];
    if ([db hadError]) {
        SNDebugLog(@"%@--%@ error occur while query if type exist with error :%d - %@",
                   NSStringFromClass([self class]), NSStringFromSelector(_cmd), [db lastErrorCode], [db lastErrorMessage]);
        return NO;
    }
    NSArray *typeArray = [self getObjects:[SCSubscribeTypeObject class] fromResultSet:rs];
    [rs close];
    
    // 不存在
    if ([typeArray count] == 0) {
        if (!bAddIfNotExist) {
            SNDebugLog(@"%@--%@ item already exists, need not add new item", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
            return YES;
        }
        
        // 新增
        [db executeUpdate:[NSString stringWithFormat:@"INSERT INTO %@ (typeId,typeName,typeIcon,subId,subName) VALUES (?,?,?,?,?)", TB_SUB_CENTER_SUB_TYPES],
         typeObj.typeId,
         typeObj.typeName,
         typeObj.typeIcon,
         typeObj.subId,
         typeObj.subName];
        
        if ([db hadError]) {
            SNDebugLog(@"%@--%@ error occur while executeUpdate : %d - %@",
                       NSStringFromClass([self class]), NSStringFromSelector(_cmd), [db lastErrorCode], [db lastErrorMessage]);
            return NO;
        }
        
        SNDebugLog(@"%@--%@ insert subtype obj succeeded with typeId %@",
                   NSStringFromClass([self class]), NSStringFromSelector(_cmd), typeObj.typeId);
        return YES;
        
    }
    
	//如果该项存在，则执行更新操作
    NSDictionary *valuePairs = [self getValuePairsFromSubTypeObject:typeObj];
	NSDictionary *updateSetStatementsInfo = [self formatUpdateSetStatementsInfoFromValuePairs:valuePairs ignoreNilValue:NO];
	if ([updateSetStatementsInfo count] == 0) {
		return NO;
	}
	
	NSString *setStatement			= [updateSetStatementsInfo objectForKey:UPDATE_SETSTATEMNT];
	NSMutableArray *valueArguments	= [updateSetStatementsInfo objectForKey:UPDATE_SETARGUMENTS];
	
	
	NSString *updateStatements	= [NSString stringWithFormat:@"UPDATE %@ %@ WHERE %@=?", TB_SUB_CENTER_SUB_TYPES, setStatement, TB_SUB_CENTER_TYPES_TYPE_ID];
	[valueArguments addObject:typeObj.typeId];
    
	[db executeUpdate:updateStatements withArgumentsInArray:valueArguments];
    
	if ([db hadError]) {
		SNDebugLog(@"%@--%@ : executeUpdate error :%d,%@,updateStatements=%@,valueArguments:%@" , NSStringFromClass(self.class), NSStringFromSelector(_cmd), [db lastErrorCode],[db lastErrorMessage],updateStatements,valueArguments);
		return NO;
	}
	
	return YES;
}

// 保存新的刊物列表到数据库 (先删除掉服务端下架的，并删除对应的关系; 有则更新，没有就添加,并且更新对应的关系到关系表)
- (BOOL)setSubscribeCenterSubTypes:(NSArray *)subTypes {
    if (nil == subTypes) {
        SNDebugLog(@"ERROR %@--%@ invalidate subTypes", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
        return NO;
    }
    __block BOOL result = YES;
    [[SNDatabase writeQueue] inTransaction:^(FMDatabase *db, BOOL *rollback) {
        // 先去掉服务端不存在的分类
        NSArray *oldTypes = [self getSubscribeCenterSubTypesInDatabase:db];
        if ([oldTypes count] > 0) {
            NSMutableArray *leftToDelete = [NSMutableArray arrayWithArray:oldTypes];
            [leftToDelete removeObjectsInArray:subTypes];
            if ([leftToDelete count] > 0) {
                for (SCSubscribeTypeObject *typeObj in leftToDelete) {
                    // 删除type
                    result = [self deleteSubscribeCenterSubTypeByTypeId:typeObj.typeId inDatabase:db];
                    // 删除对应的关系
                    result = [self deleteSubscribeTypeRelationByTypeId:typeObj.typeId inDatabase:db];
                    
                    if ([db hadError]) {
                        *rollback = YES;
                        SNDebugLog(@"%@--%@ error occur while deleteSubscribeCenterSubTypeByTypeId or deleteSubscribeTypeRelationByTypeId with error code %d error msg %@",
                                   NSStringFromClass([self class]), NSStringFromSelector(_cmd), [db lastErrorCode], [db lastErrorMessage]);
                        return ;
                    }
                }
                
            }
        }
        
        // 先把老的全部删除 再添加新的 -- 主要为了让顺序同服务器配置的一样
        result = [db executeUpdate:[NSString stringWithFormat:@"DELETE FROM %@", TB_SUB_CENTER_SUB_TYPES]];
        if ([db hadError]) {
            *rollback = YES;
            SNDebugLog(@"%@-- delete old types failed with error:%d - %@", NSStringFromSelector(_cmd), [db lastErrorCode], [db lastErrorMessage]);
            return;
        }
    }];
        
    if (![self addSubscribeCenterSubTypes:subTypes bUpdateIfExist:YES]) {
        SNDebugLog(@"%@--%@ error when excute  addSubscribeCenterSubTypes", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
        return NO;
    }
    
    SNDebugLog(@"%@--%@ succeeded !", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
    return YES;
}

// 获取刊物分类列表
- (NSArray *)getSubscribeCenterSubTypes
{
    __block NSArray *subTypes  = nil;
    [[SNDatabase readQueue] inDatabase:^(FMDatabase *db) {
        subTypes = [self getSubscribeCenterSubTypesInDatabase:db];
    }];
    return subTypes;
}
- (NSArray *)getSubscribeCenterSubTypesInDatabase:(FMDatabase *)db{
    FMResultSet *rs = [db executeQuery:[NSString stringWithFormat:@"SELECT * FROM %@", TB_SUB_CENTER_SUB_TYPES]];
    if ([db hadError]) {
        SNDebugLog(@"%@--%@ error occur while excute query : %d - %@",
                   NSStringFromClass([self class]), NSStringFromSelector(_cmd), [db lastErrorCode], [db lastErrorMessage]);
        return nil;
    }
    NSArray *subTypes = [self getObjects:[SCSubscribeTypeObject class] fromResultSet:rs];
    [rs close];
    
    return subTypes;
}

// 删除type集合
- (BOOL)deleteSubscribeCenterSubTypesInArray:(NSArray *)subTypes {
    __block BOOL bSucceed = YES;
    [[SNDatabase writeQueue] inTransaction:^(FMDatabase *db, BOOL *rollback) {
        for (SCSubscribeTypeObject *typeObj in subTypes) {
            bSucceed = [self deleteSubscribeCenterSubTypeByTypeId:typeObj.typeId inDatabase:db];
            if (!bSucceed) {
                *rollback = YES;
                return ;
            }
        }
    }];
    
    return bSucceed;
}

// 根据typeId删除某个type数据
- (BOOL)deleteSubscribeCenterSubTypeByTypeId:(NSString *)typeId
{
    __block BOOL result = YES;
    [[SNDatabase writeQueue] inTransaction:^(FMDatabase *db, BOOL *rollback) {
        result = [self deleteSubscribeCenterSubTypeByTypeId:typeId inDatabase:db];
        if (!result) {
            *rollback = YES;
        }
    }];
    return result;
}
- (BOOL)deleteSubscribeCenterSubTypeByTypeId:(NSString *)typeId inDatabase:(FMDatabase *)db{
    if (nil == typeId || [typeId length] <= 0) {
        SNDebugLog(@"%@--%@ invalidate typeId", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
        return NO;
    }
    
    [db executeUpdate:[NSString stringWithFormat:@"DELETE FROM %@ WHERE %@ = ?", TB_SUB_CENTER_SUB_TYPES, TB_SUB_CENTER_TYPES_TYPE_ID], typeId];
    if ([db hadError]) {
        SNDebugLog(@"%@--%@ excuteUpdate error : %d - %@", NSStringFromClass([self class]), NSStringFromSelector(_cmd), [db lastErrorCode], [db lastErrorMessage]);
        return NO;
    }
    
    return YES;
}

#pragma mark - relation for all sub and sub types
- (BOOL)addSubscribeATypeRelation:(NSString *)typeId subId:(NSString *)subId
{
    __block BOOL result = YES;
    [[SNDatabase writeQueue] inTransaction:^(FMDatabase *db, BOOL *rollback) {
        result  = [self addSubscribeATypeRelation:typeId subId:subId inDatabase:db];
        if (!result) {
            *rollback = YES;
        }
    }];
    return result;
}
// 单条保存
- (BOOL)addSubscribeATypeRelation:(NSString *)typeId subId:(NSString *)subId inDatabase:(FMDatabase *)db{
    if ([typeId length] <= 0 || [subId length] <= 0) {
        SNDebugLog(@"%@--%@ invalidate type", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
        return NO;
    }
    
    if ([subId isEqualToString:kExpressPushId]) {
        SNDebugLog(@"%@--%@ ignore express ! subId %@", NSStringFromClass([self class]), NSStringFromSelector(_cmd), subId);
        return YES;
    }
    
    [db executeUpdate:[NSString stringWithFormat:@"REPLACE INTO %@ (%@,%@) VALUES (?,?)",
                       TB_SUB_CENTER_RELATION_SUB_TYPE,
                       TB_SUB_CENTER_RELATION_TYPE_ID,
                       TB_SUB_CENTER_RELATION_SUB_ID], typeId, subId];
    if ([db hadError]) {
        SNDebugLog(@"%@--%@ excuteUpdate error : %d - %@", NSStringFromClass([self class]), NSStringFromSelector(_cmd), [db lastErrorCode], [db lastErrorMessage]);
        return NO;
    }
    return YES;
}

// 保存 - 先删除之前的老数据  更新最新的
- (BOOL)setSubscribeTypeRelationSubIds:(NSArray *)subIds forTypeId:(NSString *)typeId {
    if ([typeId length] <= 0) {
        SNDebugLog(@"%@--%@ invalidate subIds array %@ or typeId %@", NSStringFromClass([self class]), NSStringFromSelector(_cmd), subIds, typeId);
        return NO;
    }
    
    __block BOOL result = YES;
    [[SNDatabase writeQueue] inTransaction:^(FMDatabase *db, BOOL *rollback) {
        result = [db executeUpdate:[NSString stringWithFormat:@"DELETE FROM %@ WHERE %@=?", TB_SUB_CENTER_RELATION_SUB_TYPE, TB_SUB_CENTER_RELATION_TYPE_ID], typeId];
        if ([db hadError]) {
            *rollback = YES;
            SNDebugLog(@"%@--%@ delete old data error : %d - %@", NSStringFromClass([self class]), NSStringFromSelector(_cmd), [db lastErrorCode], [db lastErrorMessage]);
            return;
        }
    }];
    
    
    [[SNDatabase writeQueue] inTransaction:^(FMDatabase *db, BOOL *rollback) {
        for (NSString *subId in subIds) {
            result = [self addSubscribeATypeRelation:typeId subId:subId inDatabase:db];
            if (!result) {
                SNDebugLog(@"%@--%@ addSubscribeATypeRelation typeId=%@ subId=%@ failed with error : %d - %@", NSStringFromClass([self class]), NSStringFromSelector(_cmd),
                           typeId, subId, [db lastErrorCode], [db lastErrorMessage]);
                *rollback = YES;
                return;
            }
        }
    }];
    
    return result;
}

// 获取对应typeId的所有订阅的subId集合
- (NSArray *)getSubscribeTypeRelationSubIdsForTypeId:(NSString *)typeId {
    if ([typeId length] <= 0) {
        SNDebugLog(@"%@--%@ invalidate typeId", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
        return nil;
    }
    __block NSArray *subIds = nil;
    [[SNDatabase readQueue] inDatabase:^(FMDatabase *db) {
        FMResultSet *rs = [db executeQuery:[NSString stringWithFormat:@"SELECT subId FROM %@ WHERE %@=? ORDER BY ID ASC", TB_SUB_CENTER_RELATION_SUB_TYPE, TB_SUB_CENTER_RELATION_TYPE_ID], typeId];
        if ([db hadError]) {
            SNDebugLog(@"%@--%@ executeQuery error : %d - %@", NSStringFromClass([self class]), NSStringFromSelector(_cmd), [db lastErrorCode], [db lastErrorMessage]);
            return;
        }
        subIds = [self getSubIdsFromResultSet:rs];
        [rs close];
    }];
    return subIds;
}

// 根据typeId集合 删除关系表中对应的所有关系
- (BOOL)deleteSubscribeTypeRelationInArray:(NSArray *)relationArray {
    if ([relationArray count] <= 0) {
        SNDebugLog(@"%@--%@ invalidate relationArray", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
        return NO;
    }
    
    __block BOOL bSucceed = YES;
    [[SNDatabase writeQueue] inTransaction:^(FMDatabase *db, BOOL *rollback) {
        for (NSString *typeId in relationArray) {
            bSucceed = [self deleteSubscribeTypeRelationByTypeId:typeId inDatabase:db];
            if (!bSucceed) {
                SNDebugLog(@"%@--%@ deleteSubscribeTypeRelationByTypeId failed with error : %d - %@", NSStringFromClass([self class]), NSStringFromSelector(_cmd), [db lastErrorCode], [db lastErrorMessage]);
                *rollback = YES;
                return;
            }
        }
    }];
    
    
    return bSucceed;
}

// 根据typeId删除关系表中对应的所有关系
- (BOOL)deleteSubscribeTypeRelationByTypeId:(NSString *)typeId
{
    __block BOOL result = YES;
    [[SNDatabase writeQueue] inTransaction:^(FMDatabase *db, BOOL *rollback) {
        result = [self deleteSubscribeTypeRelationByTypeId:typeId inDatabase:db];
        if (!result) {
            *rollback = YES;
        }
    }];
    return result;
}
- (BOOL)deleteSubscribeTypeRelationByTypeId:(NSString *)typeId inDatabase:(FMDatabase *)db{
    if ([typeId length] <= 0) {
        SNDebugLog(@"");
        return NO;
    }
    
    [db executeUpdate:[NSString stringWithFormat:@"DELETE FROM %@ WHERE %@ = ?", TB_SUB_CENTER_RELATION_SUB_TYPE, TB_SUB_CENTER_RELATION_TYPE_ID], typeId];
    if ([db hadError]) {
        SNDebugLog(@"%@--%@ executeUpdate failed with error : %d - %@", NSStringFromClass([self class]), NSStringFromSelector(_cmd), [db lastErrorCode], [db lastErrorMessage]);
        return NO;
    }
    
    return YES;
}

#pragma mark - ad list

// 重置ad list - 先删除之前的旧数据 再插入新数据
- (BOOL)setSubscribeCenterAdList:(NSArray *)adList ofType:(SNSubCenterAdListType)type {
    // 可以允许空数据传入
    __block BOOL result = YES;
    [[SNDatabase writeQueue] inTransaction:^(FMDatabase *db, BOOL *rollback) {
        result = [db executeUpdate:[NSString stringWithFormat:@"DELETE FROM %@ WHERE %@ = %d", TB_SUB_CENTER_AD_LIST, TB_SUB_CENTER_AD_LIST_TYPE, type]];
        if ([db hadError]) {
            *rollback = YES;
            SNDebugLog(@"%@--%@ execute delete failed with error : %d - %@", NSStringFromClass([self class]), NSStringFromSelector(_cmd), [db lastErrorCode], [db lastErrorMessage]);
            return;
        }
    }];
    
    if ([adList count] > 0) {
        [[SNDatabase writeQueue] inTransaction:^(FMDatabase *db, BOOL *rollback) {
            for (SCSubscribeAdObject *adObj in adList) {
                result = [db executeUpdate:[NSString stringWithFormat:@"INSERT INTO %@ \
                                            (%@,%@,%@,%@,%@,%@,%@,%@) VALUES \
                                            (?,?,?,?,?,?,?,?)",
                                            TB_SUB_CENTER_AD_LIST,
                                            TB_SUB_CENTER_AD_LIST_AD_NAME,
                                            TB_SUB_CENTER_AD_LIST_AD_TYPE,
                                            TB_SUB_CENTER_AD_LIST_AD_IMG,
                                            TB_SUB_CENTER_AD_LIST_REF_ID,
                                            TB_SUB_CENTER_AD_LIST_REF_TEXT,
                                            TB_SUB_CENTER_AD_LIST_REF_LINK,
                                            TB_SUB_CENTER_AD_LIST_TYPE,
                                            TB_SUB_CENTER_AD_LIST_ADID],
                                            adObj.adName, adObj.adType, adObj.adImage,
                                            adObj.refId, adObj.refText, adObj.refLink,
                                            @(type), adObj.adId];
                
                if ([db hadError]) {
                    SNDebugLog(@"%@-- db execute insert action failed with error : %d- %@ adObj:%@", NSStringFromSelector(_cmd), [db lastErrorCode], [db lastErrorMessage], adObj);
                    *rollback = YES;
                    return;
                }
            }
        }];
        
    }
    
    return result;
}

// 获取ad list
- (NSArray *)getSubscribeCenterAdListForType:(SNSubCenterAdListType)type {
    __block NSArray *adList  = nil;
    [[SNDatabase readQueue] inDatabase:^(FMDatabase *db) {
        FMResultSet *rs = [db executeQuery:[NSString stringWithFormat:@"SELECT * FROM %@ WHERE %@ = %d", TB_SUB_CENTER_AD_LIST, TB_SUB_CENTER_AD_LIST_TYPE, type]];
        if ([db hadError]) {
            SNDebugLog(@"%@-- execute query failed with error : %d - %@", NSStringFromSelector(_cmd), [db lastErrorCode], [db lastErrorMessage]);
            return;
        }
        adList = [self getObjects:[SCSubscribeAdObject class] fromResultSet:rs];
        [rs close];
    }];
    
    return adList;
}


#pragma mark - sub comment list

// 保存刊物评论列表  先删除老数据 在添加新数据
- (BOOL)setSubscribeCenterSubCommentsArray:(NSArray *)commentArray forSubId:(NSString *)subId {
    if ([subId length] <= 0) {
        SNDebugLog(@"%@--%@ invalidate subId", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
        return NO;
    }
    // 先删除老数据
    [[SNDatabase writeQueue] inTransaction:^(FMDatabase *db, BOOL *rollback) {
        [db executeUpdate:[NSString stringWithFormat:@"DELETE FROM %@ WHERE subId=?", TB_SUB_CENTER_SUB_COMMENT], subId];
        if ([db hadError]) {
            SNDebugLog(@"%@--%@ delete old items error : %d - %@", NSStringFromClass([self class]), NSStringFromSelector(_cmd), [db lastErrorCode], [db lastErrorMessage]);
            *rollback = YES;
            return;
        }        
    }];
    
    return [self addSubscribeCenterSubComments:commentArray];
}

// 单个添加
- (BOOL)addSubscribeCenterSubComment:(SCSubscribeCommentObject *)commentObj inDatabase:(FMDatabase *)db {
    if (nil == commentObj) {
        SNDebugLog(@"%@--%@ invalidate commentObj", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
        return NO;
    }
    
    NSString *sqlStr = [NSString stringWithFormat:@"INSERT INTO %@ (%@,%@,%@,%@,%@,%@) VALUES (?,?,?,?,?,?)",
                        TB_SUB_CENTER_SUB_COMMENT,
                        TB_SUB_CENTER_SUB_COMMENT_SUB_ID,
                        TB_SUB_CENTER_SUB_COMMENT_CTIME,
                        TB_SUB_CENTER_SUB_COMMENT_AUTHOR,
                        TB_SUB_CENTER_SUB_COMMENT_CONTENT,
                        TB_SUB_CENTER_SUB_COMMENT_STAR_GRADE,
                        TB_SUB_CENTER_SUB_COMMENT_CITY];
    [db executeUpdate:sqlStr, commentObj.subId, commentObj.ctime, commentObj.author, commentObj.content, commentObj.starGrade, commentObj.city];
    if ([db hadError]) {
        SNDebugLog(@"%@--%@ insert comment failed with error:%d - %@", NSStringFromClass([self class]), NSStringFromSelector(_cmd), [db lastErrorCode], [db lastErrorMessage]);
        return NO;
    }
    
    return YES;
}

- (BOOL)addSubscribeCenterSubComment:(SCSubscribeCommentObject *)commentObj
{
    __block BOOL result = YES;
    [[SNDatabase writeQueue] inTransaction:^(FMDatabase *db, BOOL *rollback) {
        result = [self addSubscribeCenterSubComment:commentObj inDatabase:db];
        if (!result) {
            *rollback = YES;
        }
    }];
    return result;
}

// 批量添加
- (BOOL)addSubscribeCenterSubComments:(NSArray *)commentsArray {
    if ([commentsArray count] <= 0) {
        SNDebugLog(@"%@--%@ invalidate comment array", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
        return NO;
    }
    
    __block BOOL bSuccess = YES;
    [[SNDatabase writeQueue] inTransaction:^(FMDatabase *db, BOOL *rollback) {
        for (SCSubscribeCommentObject *cmtObj in commentsArray) {
            bSuccess = [self addSubscribeCenterSubComment:cmtObj inDatabase:db];
            if (!bSuccess) {
                SNDebugLog(@"%@--%@ failed addSubscribeCenterSubComment %@ with error : %d - %@",
                           NSStringFromClass([self class]),
                           NSStringFromSelector(_cmd),
                           cmtObj.subId,
                           [db lastErrorCode],
                           [db lastErrorMessage]);
                *rollback = YES;
                return ;
            }
        }
    }];
    
    
    return bSuccess;
}

// 通过subId 获取对应的所有comment 数据
- (NSArray *)getSubscribeCenterSubCommentsBySubId:(NSString *)subId {
    if ([subId length] <= 0) {
        SNDebugLog(@"%@--%@ invalidate subId",
                   NSStringFromClass([self class]),
                   NSStringFromSelector(_cmd));
        return nil;
    }
    __block NSArray *commentsArray  = nil;
    [[SNDatabase readQueue] inDatabase:^(FMDatabase *db) {
        FMResultSet *rs = [db executeQuery:[NSString stringWithFormat:@"SELECT * FROM %@ WHERE %@=?",
                                            TB_SUB_CENTER_SUB_COMMENT,
                                            TB_SUB_CENTER_SUB_COMMENT_SUB_ID], subId];
        if ([db hadError]) {
            SNDebugLog(@"%@--%@ executeQuery subId %@ error : %d -%@",
                       NSStringFromClass([self class]),
                       NSStringFromSelector(_cmd),
                       subId,
                       [db lastErrorCode],
                       [db lastErrorMessage]);
            return;
        }
        commentsArray = [self getObjects:[SCSubscribeCommentObject class] fromResultSet:rs];
        [rs close];
    }];
    
    return commentsArray;
}

@end
