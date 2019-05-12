//
//  SNDatabase_GroupTag.m
//  sohunews
//
//  Created by ivan on 3/12/12.
//  Copyright (c) 2012 Sohu.com Inc. All rights reserved.
//

#import "SNDatabase_Tag.h"

@implementation SNDatabase(Tag)

-(BOOL)saveOrUpdateTag:(SNTagItem *)aTag
{
    __block BOOL result = YES;
    [[SNDatabase writeQueue] inTransaction:^(FMDatabase *db, BOOL *rollback) {
        result = [self saveOrUpdateTag:aTag inDatabase:db];
        if (!result) {
            *rollback = YES;
        }
    }];
    return result;
}

-(BOOL)saveOrUpdateTag:(SNTagItem *)aTag inDatabase:(FMDatabase *)db{
	if (aTag == nil) {
		SNDebugLog(@"addSingleTagIfNotExist : Invalid aTag");    
		return NO;
	}
    [db executeUpdate:@"REPLACE into tbTag(tagId, tagName) values(?,?)", aTag.tagId, aTag.tagName];
    
    if ([db hadError]) {
        SNDebugLog(@"saveOrUpdateTag : executeUpdate for exist one error :%d,%@",[db lastErrorCode],[db lastErrorMessage]);
        return NO;
    }
    return YES;
}

-(BOOL)deleteCachedTagsInDatabase:(FMDatabase *)db {
    [db executeUpdate:@"delete from tbTag"];
    if ([db hadError]) {
        return NO;
    }
    return YES;
}

-(BOOL)addMultiTag:(NSArray*)aTagArray {
    if ([aTagArray count] == 0) {
		SNDebugLog(@"addMultiTag : Invalid aTagArray");
	}
	
	__block BOOL bSucceed	= YES;
    [[SNDatabase writeQueue] inTransaction:^(FMDatabase *db, BOOL *rollback) {
        bSucceed = [self deleteCachedTagsInDatabase:db];
        if (!bSucceed) {
            *rollback = YES;
            return ;
        }
        for (SNTagItem *tag in aTagArray) {
            bSucceed = [self saveOrUpdateTag:tag inDatabase:db];
            if (!bSucceed) {
                *rollback = YES;
                return ;
            }
        }
    
    }];
    
	return bSucceed;
}

-(NSMutableArray*)getAllCachedTag {
    __block NSMutableArray *cacheList = nil;
    [[SNDatabase readQueue] inDatabase:^(FMDatabase *db) {
        FMResultSet *rs	= [db executeQuery:@"SELECT * FROM tbTag"];
        
        if ([db hadError]) {
            SNDebugLog(@"getAllCachedGroupTag : executeQuery error :%d,%@",[db lastErrorCode],[db lastErrorMessage]);
            return;
        }
        cacheList = (NSMutableArray *)[self getObjects:[SNTagItem class] fromResultSet:rs limitCount:19];
        [rs close];
        
    }];
    
    return cacheList;
}

@end
