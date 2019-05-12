//
//  SNDatabase_Category.m
//  sohunews
//
//  Created by ivan on 3/14/12.
//  Copyright (c) 2012 Sohu.com Inc. All rights reserved.
//

#import "SNDatabase_Private.h"
#import "SNDatabase_Category.h"
#import "SNChannelManageContants.h"

@implementation SNDatabase(Category) 

-(BOOL)saveOrUpdateCategory:(CategoryItem *)aCategory {
	if (aCategory == nil) {
		SNDebugLog(@"saveOrUpdateCategory : Invalid aCategory");    
		return NO;
	}
    
    __block BOOL result = YES;
    [[SNDatabase writeQueue] inTransaction:^(FMDatabase *db, BOOL *rollback) {
        NSString *currentDateString=[NSString stringWithFormat:@"%f",[[NSDate date] timeIntervalSince1970]];
        result = [db executeUpdate:@"REPLACE INTO tbCategory(categoryId, name, icon, isSubed,position,top,topTime) values(?,?,?,?)", aCategory.categoryID, aCategory.name,aCategory.icon, aCategory.isSubed,aCategory.position,aCategory.top,currentDateString];
        if ([db hadError]) {
            *rollback = YES;
            return;
        }
    }];
	return result;
}
-(BOOL)insertCategory:(CategoryItem *)aCategory updateTopTime:(BOOL)update
{
    __block BOOL result = YES;
    [[SNDatabase writeQueue] inTransaction:^(FMDatabase *db, BOOL *rollback) {
        result = [self insertCategory:aCategory updateTopTime:update inDatabase:db];
        if (!result) {
            *rollback = YES;
        }
    }];
    return result;
}

-(BOOL)insertCategory:(CategoryItem *)aCategory updateTopTime:(BOOL)update inDatabase:(FMDatabase *)db
{
    if (aCategory == nil) {
		SNDebugLog(@"saveOrUpdateCategory : Invalid aCategory");
		return NO;
	}
    if (update) {
        NSString *currentDateString=[NSString stringWithFormat:@"%f",[[NSDate date] timeIntervalSince1970]];
        [db executeUpdate:@"insert into tbCategory(categoryId, name, icon, isSubed,position,top,topTime,lastModify) values(?,?,?,?,?,?,?,?)", aCategory.categoryID, aCategory.name,aCategory.icon, aCategory.isSubed,aCategory.position,aCategory.top,currentDateString, aCategory.lastModify];
    } else {
        [db executeUpdate:@"insert into tbCategory(categoryId, name, icon, isSubed,position,top) values(?,?,?,?,?,?)", aCategory.categoryID, aCategory.name,aCategory.icon, aCategory.isSubed,aCategory.position,aCategory.top];
    }
    
        
    if ([db hadError]) {
            return NO;
    }
	return YES;
}
-(BOOL)deleteCachedCategorys
{
    __block BOOL result = YES;
    [[SNDatabase writeQueue] inTransaction:^(FMDatabase *db, BOOL *rollback) {
        result = [self deleteCachedCategorysInDatabase:db];
        if(!result){
            *rollback = YES;
        }
    }];
    return result;
}
-(BOOL)deleteCachedCategorysInDatabase:(FMDatabase *)db{
    [db executeUpdate:@"delete from tbCategory"];
    if ([db hadError]) {
        return NO;
    }
    return YES;
}

-(BOOL)addMultiCategory:(NSArray*)aCategoryArray updateTopTime:(BOOL)update{
    SNDebugLog(@"%d",update);
    if ([aCategoryArray count] == 0) {
		SNDebugLog(@"addMultiCategory : Invalid aCategoryArray");
	}
	
	__block BOOL bSucceed	= TRUE;
    [[SNDatabase writeQueue] inTransaction:^(FMDatabase *db, BOOL *rollback) {
        FMResultSet *rs	= [db executeQuery:@"SELECT * FROM tbCategory"];
        if ([db hadError]) {
            SNDebugLog(@"getAllCachedCategory : executeQuery error :%d,%@",[db lastErrorCode],[db lastErrorMessage]);
            return;
        }
        NSMutableArray *cacheList = (NSMutableArray *)[self getObjects:[CategoryItem class] fromResultSet:rs];
        [rs close];
        
        bSucceed = [self deleteCachedCategorysInDatabase:db];
        if (!bSucceed) {
            *rollback = YES;
            return ;
        }
        NSInteger index = 0;
        for (CategoryItem *category in aCategoryArray) {
            bSucceed = [self insertCategory:category updateTopTime:update inDatabase:db];
            if (!bSucceed) {
                *rollback = YES;
                return;
            }
            if (++index >= kChannelMaxVolum) {
                break;
            }
        }
        //把原来的topTime 和 lastModify 重置回来        
        if (!update) {
            for (CategoryItem *item in cacheList) {
                
                if(item.topTime==nil && item.lastModify==nil)
                    continue;
                
                bSucceed = [db executeUpdate:@"update tbCategory set topTime = ?,lastModify=? WHERE categoryId = ?",item.topTime,item.lastModify,item.categoryID];
                if ([db hadError]) {
                    SNDebugLog(@"getAllCachedCategory : executeQuery error :%d,%@",[db lastErrorCode],[db lastErrorMessage]);
                    *rollback = YES;
                    return;
                }
            }
        }
        
        if (update) {
            [SNUserDefaults setBool:YES forKey:kCategoryEdit];
        }
    }];
    return bSucceed;
}

-(NSMutableArray*)getAllCachedCategory {
    __block NSMutableArray *cacheList = nil;
    [[SNDatabase readQueue] inDatabase:^(FMDatabase *db) {
        FMResultSet *rs	= [db executeQuery:@"SELECT * FROM tbCategory"];
        if ([db hadError]) {
            SNDebugLog(@"getAllCachedCategory : executeQuery error :%d,%@",[db lastErrorCode],[db lastErrorMessage]);
            return;
        }
        cacheList = (NSMutableArray *)[self getObjects:[CategoryItem class] fromResultSet:rs];
        [rs close];
    }];
    
    return cacheList;
}

-(CategoryItem *)getFirstCachedCategory {
    __block CategoryItem *categoryItem = nil;
    [[SNDatabase readQueue] inDatabase:^(FMDatabase *db) {
        FMResultSet *rs	= [db executeQuery:@"SELECT * FROM tbCategory limit 1"]; // 增加了频道排序编辑功能 就不需要根据id排序了
        if ([db hadError]) {
            SNDebugLog(@"getAllCachedCategory : executeQuery error :%d,%@",[db lastErrorCode],[db lastErrorMessage]);
            return;
        }
        categoryItem = [self getFirstObject:[CategoryItem class] fromResultSet:rs];
        [rs close];
    }];
    return categoryItem;
}

-(NSArray*)getSubedCategoryList
{
    __block NSArray *categorylArray = nil;
    [[SNDatabase readQueue] inDatabase:^(FMDatabase *db) {
        FMResultSet *rs	= [db executeQuery:@"SELECT * FROM tbCategory where isSubed='1'"];
        if ([db hadError]) {
            SNDebugLog(@"tbCategory : executeQuery error:%d,%@",[db lastErrorCode],[db lastErrorMessage]);
            return;
        }
        categorylArray = [self getObjects:[CategoryItem class] fromResultSet:rs limitCount:kChannelMaxVolum];
        [rs close];
    }];
	
	return categorylArray;
}

-(NSArray*)getUnSubedCategoryList
{
    __block NSArray *categorylArray = nil;
    [[SNDatabase readQueue] inDatabase:^(FMDatabase *db) {
        FMResultSet *rs	= [db executeQuery:@"SELECT * FROM tbCategory where isSubed!='1'"];
        if ([db hadError]) {
            SNDebugLog(@"tbCategory : executeQuery error:%d,%@",[db lastErrorCode],[db lastErrorMessage]);
            return;
        }
        categorylArray = [self getObjects:[CategoryItem class] fromResultSet:rs limitCount:kChannelMaxVolum];
        [rs close];
    }];
	
	return categorylArray;
}
@end
