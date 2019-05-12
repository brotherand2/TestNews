//
//  SNDatabase_MyFavourite.m
//  sohunews
//
//  Created by handy wang on 8/7/12.
//  Copyright (c) 2012 Sohu.com Inc. All rights reserved.
//

#import "SNDatabase_MyFavourite.h"
#import "SNDatabase_Private.h"


@implementation SNDatabase(MyFavourite)

#pragma mark - Public methods implementation
- (BOOL)saveMyFavourite:(SNMyFavourite *)myFavourite {
	if (myFavourite == nil || 
        myFavourite.myFavouriteRefer == MYFAVOURITE_REFER_NONE ||
        myFavourite.contentLeveloneID == nil || [@"" isEqualToString:myFavourite.contentLeveloneID] ||
        myFavourite.contentLeveltwoID == nil || [@"" isEqualToString:myFavourite.contentLeveltwoID]) {
		SNDebugLog(@"%@--%@ : Invalid myFavourite data. %@", NSStringFromClass(self.class), NSStringFromSelector(_cmd), myFavourite);
		return NO;
	}
    
	//首先检查是否已经存在
    __block BOOL result = YES;
    [[SNDatabase writeQueue] inTransaction:^(FMDatabase *db, BOOL *rollback) {
        result = [db executeUpdate:[NSString stringWithFormat:@"REPLACE INTO %@(title, myFavouriteRefer, contentLeveloneID, contentLeveltwoID, imgURL, isRead, pubDate, userId)\
                           VALUES (?,?,?,?,?,?,?,?)", TB_MYFAVOURITES],
         myFavourite.title, [NSNumber numberWithInt:myFavourite.myFavouriteRefer], myFavourite.contentLeveloneID, myFavourite.contentLeveltwoID, myFavourite.imgURL,myFavourite.isRead, myFavourite.pubDate, myFavourite.userId];
		if ([db hadError]) {
			SNDebugLog(@"INFO: %@--%@ : executeUpdate error:%d, %@", NSStringFromClass(self.class), NSStringFromSelector(_cmd), [db lastErrorCode],[db lastErrorMessage]);
            *rollback = YES;
			return;
		}
    }];
    
    return result;
}

- (BOOL)deleteMyFavourite:(SNMyFavourite *)myFavourite {
    
    __block BOOL result = YES;
    [[SNDatabase writeQueue] inTransaction:^(FMDatabase *db, BOOL *rollback) {
       result =[db executeUpdate:[NSString stringWithFormat:@"DELETE FROM %@ WHERE myFavouriteRefer=? and contentLeveloneID=? and contentLeveltwoID=?", TB_MYFAVOURITES], [NSNumber numberWithInt:myFavourite.myFavouriteRefer], myFavourite.contentLeveloneID, myFavourite.contentLeveltwoID];
        
        if ([db hadError]) {
            SNDebugLog(@"INFO: %@--%@ : executeUpdate error :%d, %@", NSStringFromClass(self.class), NSStringFromSelector(_cmd), [db lastErrorCode],[ db lastErrorMessage]);
            *rollback = YES;
            return;
        }
    }];
	return result;
}

- (BOOL)deleteMyFavouriteEx:(SNCloudSave *)myCloudSave
{
    __block BOOL result = YES;
    [[SNDatabase writeQueue] inTransaction:^(FMDatabase *db, BOOL *rollback) {
        result =[db executeUpdate:[NSString stringWithFormat:@"DELETE FROM %@ WHERE myFavouriteRefer=? and contentLeveloneID=? and contentLeveltwoID=? and userId=?", TB_MYFAVOURITES], [NSNumber numberWithInt:myCloudSave._myFavouriteRefer], myCloudSave._contentLeveloneID, myCloudSave._contentLeveltwoID, myCloudSave._userId];
        
        if ([db hadError]) {
            SNDebugLog(@"INFO: %@--%@ : executeUpdate error :%d, %@", NSStringFromClass(self.class), NSStringFromSelector(_cmd), [db lastErrorCode],[ db lastErrorMessage]);
            *rollback = YES;
            return;
        }
    }];
	return result;
}

- (BOOL)deleteMyFavourites:(NSArray *)myFavourites {
    
    if (!myFavourites || myFavourites.count <= 0) {
        return NO;
    }
    NSMutableString *_conditionIDs = [NSMutableString stringWithString:@" ID in ("];
    for (int _index = 0; _index < myFavourites.count; _index++) {
        if (_index != 0) {
            [_conditionIDs appendFormat:@" , "];
        }
        SNMyFavourite *_myFavourite = [myFavourites objectAtIndex:_index];
        [_conditionIDs appendString:[NSString stringWithFormat:@"%ld",(long)_myFavourite.ID]];
    }
    [_conditionIDs appendString:@")"];
    __block BOOL result = YES;
    [[SNDatabase writeQueue] inTransaction:^(FMDatabase *db, BOOL *rollback) {
        result = [db executeUpdate:[NSString stringWithFormat:@"DELETE FROM %@ WHERE %@", TB_MYFAVOURITES, _conditionIDs]];
        if ([db hadError]) {
            SNDebugLog(@"INFO: %@--%@ : executeUpdate error :%d, %@", NSStringFromClass(self.class), NSStringFromSelector(_cmd), [db lastErrorCode],[ db lastErrorMessage]);
            *rollback = YES;
            return;
        }
    }];
	return result;
}

- (NSArray *)getMyFavourites {
	__block NSArray *_myFavourites = nil;
    [[SNDatabase readQueue] inDatabase:^(FMDatabase *db) {
        
        FMResultSet *rs	= [db executeQuery:[NSString stringWithFormat:@"SELECT * FROM %@ order by ID desc", TB_MYFAVOURITES]];
        if ([db hadError]) {
            SNDebugLog(@"INFO: %@--%@ : executeQuery error :%d, %@",
                       NSStringFromClass(self.class), NSStringFromSelector(_cmd), [db lastErrorCode], [db lastErrorMessage]);
            return;
        }
        _myFavourites	= [self getObjects:[SNMyFavourite class] fromResultSet:rs];
        [rs close];
    }];
    
    return _myFavourites;
}

- (NSArray *)getToDeleteFav:(NSString*)aUserid
{
    if(aUserid==nil)
        return nil;
    
    __block NSArray *_myFavourites = nil;
    [[SNDatabase readQueue] inDatabase:^(FMDatabase *db) {
        
        FMResultSet *rs	= [db executeQuery:[NSString stringWithFormat:@"SELECT * FROM %@ WHERE userId=? order by ID desc", TB_MYFAVOURITES], aUserid];
        //FMResultSet *rs	= [db executeQuery:[NSString stringWithFormat:@"SELECT * FROM %@ WHERE contentLeveloneID=?", TB_MYFAVOURITES], aUserid];
        if ([db hadError]) {
            SNDebugLog(@"INFO: %@--%@ : executeQuery error :%d, %@",
                       NSStringFromClass(self.class), NSStringFromSelector(_cmd), [db lastErrorCode], [db lastErrorMessage]);
            return;
        }
        _myFavourites	= [self getObjects:[SNMyFavourite class] fromResultSet:rs];
        [rs close];
    }];
    
    return _myFavourites;
}

- (SNMyFavourite *)getMyFavourite:(MYFAVOURITE_REFER)myFavouriteRefer 
                contentLeveloneID:(NSString *)contentLeveloneID contentLeveltwoID:(NSString *)contentLeveltwoID {
    __block SNMyFavourite *_myFavourite	 = nil;
    NSString *contentLevelSecondID = nil;
    NSArray *propertyArray = [contentLeveltwoID componentsSeparatedByString:@"#"];
    if ([propertyArray count] == 2 && myFavouriteRefer == MYFAVOURITE_REFER_PUB_HOME)
    {
        contentLevelSecondID = propertyArray[0];
    }
    else
    {
        contentLevelSecondID = contentLeveltwoID;
    }

    [[SNDatabase readQueue] inDatabase:^(FMDatabase *db) {
        FMResultSet *rs	= [db executeQuery:[NSString stringWithFormat:@"SELECT * FROM %@ WHERE myFavouriteRefer=? and contentLeveloneID=? and contentLeveltwoID=?", TB_MYFAVOURITES], [NSNumber numberWithInt:myFavouriteRefer], contentLeveloneID, contentLevelSecondID];
        if ([db hadError]) {
            SNDebugLog(@"%@--%@ : ExecuteQuery error:%d, %@.", NSStringFromClass(self.class), NSStringFromSelector(_cmd), [db lastErrorCode],[db lastErrorMessage]);
            return;
        }
        _myFavourite = [self getFirstObject:[SNMyFavourite class] fromResultSet:rs];
        [rs close];
    }];
    return _myFavourite;
    
}

- (BOOL)updateMyFavourite:(NSInteger)ID hasRead:(BOOL)isRead
{
    __block BOOL result = YES;
    [[SNDatabase writeQueue] inTransaction:^(FMDatabase *db, BOOL *rollback) {
        result = [db executeUpdate:[NSString stringWithFormat:@"UPDATE %@ SET isRead = ? WHERE ID = ?", TB_MYFAVOURITES],isRead?kMyFavouriteCellIsRead_YES:kMyFavouriteCellIsRead_NO,[NSNumber numberWithInteger:ID]];;
        if ([db hadError]) {
            SNDebugLog(@"INFO: %@--%@ : executeUpdate error:%d, %@, ID=%d" ,
                       NSStringFromClass(self.class), NSStringFromSelector(_cmd), [db lastErrorCode], [db lastErrorMessage], ID);
            *rollback = YES;
            return;
        }
    }];
	return result;
}

-(BOOL)deleteMyFavouriteAll
{
    __block BOOL result = YES;
    [[SNDatabase writeQueue]  inTransaction:^(FMDatabase *db, BOOL *rollback)
     {
         result = [db executeUpdate:[NSString stringWithFormat:@"DELETE FROM %@", TB_MYFAVOURITES]];
         if ([db hadError]) {
             SNDebugLog(@"INFO: %@--%@ : executeUpdate error :%d, %@", NSStringFromClass(self.class), NSStringFromSelector(_cmd), [db lastErrorCode],[ db lastErrorMessage]);
             *rollback = YES;
             return;
         }
     }];
	return YES;
}
@end