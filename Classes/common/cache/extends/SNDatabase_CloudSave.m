//
//  SNDatabase_CloudSave.m
//  sohunews
//
//  Created by Diaochunmeng on 12-12-28.
//  Copyright (c) 2012年 Sohu.com Inc. All rights reserved.
//

#import "SNUserinfo.h"
#import "SNDatabase_CloudSave.h"
#import "SNDatabase_MyFavourite.h"

@implementation SNDatabase(CloudSave)

-(NSArray*)getMyCloudSaves
{
//    SNUserinfo* info = [SNUserinfo userinfo];
//    if(info==nil || [info getUsername]==nil || [[info getUsername] length]==0)
//        return nil;
    
    __block NSArray *_myFavourites = nil;
    [[SNDatabase readQueue] inDatabase:^(FMDatabase *db){
//        FMResultSet *rs	= [db executeQuery:[NSString stringWithFormat:@"SELECT * FROM %@ where userid=?  order by collecttime desc", TB_CLOUDSAVES], [info getUsername]];
        FMResultSet *rs	= [db executeQuery:[NSString stringWithFormat:@"SELECT * FROM %@ order by collecttime desc", TB_CLOUDSAVES]];
        if ([db hadError]) {
            SNDebugLog(@"INFO: %@--%@ : executeQuery error :%d, %@",
                       NSStringFromClass(self.class), NSStringFromSelector(_cmd), [db lastErrorCode], [db lastErrorMessage]);
            return;
        }
        _myFavourites	= [self getObjects:[SNCloudSave class] fromResultSet:rs];
        [rs close];
    }];
    
    return _myFavourites;
}

//函数在各个收藏页面中被调用,判断数据是否已经被存储过
-(SNCloudSave*)getMyCloudSave:(MYFAVOURITE_REFER)myFavouriteRefer contentLeveloneID:(NSString*)contentLeveloneID contentLeveltwoID:(NSString*)contentLeveltwoID
{
    NSString* link = [SNMyFavourite generCloudLinkEx:myFavouriteRefer contentLeveloneID:contentLeveloneID contentLeveltwoID:contentLeveltwoID showType:nil];
    if(link==nil || [link length]==0)
        return nil;
    
    __block SNCloudSave *_myFavourite	 = nil;
    //link可能不一致，所以先查link，查不到再茶一次具体项目
    [[SNDatabase readQueue] inDatabase:^(FMDatabase *db)
     {
//         FMResultSet *rs	= [db executeQuery:[NSString stringWithFormat:SN_String("SELECT * FROM %@ WHERE userid=? and link=?"), TB_CLOUDSAVES], [info getUsername], link];
         FMResultSet *rs	= [db executeQuery:[NSString stringWithFormat:SN_String("SELECT * FROM %@ WHERE link=?"), TB_CLOUDSAVES], link];
         if ([db hadError]) {
             SNDebugLog(@"%@--%@ : ExecuteQuery error:%d, %@.", NSStringFromClass(self.class), NSStringFromSelector(_cmd), [db lastErrorCode],[db lastErrorMessage]);
             return;
         }
         _myFavourite	= [self getFirstObject:[SNCloudSave class] fromResultSet:rs];
         [rs close];
     }];
    if (_myFavourite == nil)
    {
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
        [[SNDatabase readQueue] inDatabase:^(FMDatabase *db)
         {
//             FMResultSet *rs	= [db executeQuery:[NSString stringWithFormat:SN_String("SELECT * FROM %@ WHERE userid=? and contentLeveltwoID=? and myFavouriteRefer=?"), TB_CLOUDSAVES], [info getUsername], contentLevelSecondID, @(myFavouriteRefer)];
             FMResultSet *rs	= [db executeQuery:[NSString stringWithFormat:SN_String("SELECT * FROM %@ WHERE contentLeveltwoID=? and myFavouriteRefer=?"), TB_CLOUDSAVES], contentLevelSecondID, @(myFavouriteRefer)];
             if ([db hadError]) {
                 SNDebugLog(@"%@--%@ : ExecuteQuery error:%d, %@.", NSStringFromClass(self.class), NSStringFromSelector(_cmd), [db lastErrorCode],[db lastErrorMessage]);
                 return;
             }
             _myFavourite	= [self getFirstObject:[SNCloudSave class] fromResultSet:rs];
             [rs close];
         }];

    }
    return _myFavourite;
}

//此函数在云端获取数据后被调用
-(BOOL)saveMyCloudSave:(SNCloudSave*)myCloudSave
{
    SNUserinfo* info = [SNUserinfo userinfo];
//    if(info==nil || [info getUsername]==nil || [[info getUsername] length]==0)
//        return NO;
    
    //即使从服务器端获得link，也使用自己生成的link存储！
    //这样可以用数据库里直接用link来做查找!!!
    __block NSString* link = nil;
    if (myCloudSave._link && [myCloudSave._link length])
    {
        link = myCloudSave._link;
    }
    else
    {
        link = [myCloudSave generCloudLink];
    }
    if(link==nil)
        return NO;
    
	if(myCloudSave==nil || myCloudSave._title==nil || myCloudSave._link==nil || myCloudSave._collectTime==nil)
    {
		SNDebugLog(@"%@--%@ : Invalid myFavourite data. %@", NSStringFromClass(self.class), NSStringFromSelector(_cmd), myCloudSave);
		return NO;
	}
    
    /*
     __block NSArray *_myFavourites = nil;
     [[SNDatabase readQueue] inDatabase:^(FMDatabase *db){
     //        FMResultSet *rs	= [db executeQuery:[NSString stringWithFormat:@"SELECT * FROM %@ where userid=?  order by collecttime desc", TB_CLOUDSAVES], [info getUsername]];
     FMResultSet *rs	= [db executeQuery:[NSString stringWithFormat:@"SELECT * FROM %@ order by collecttime desc", TB_CLOUDSAVES]];
     if ([db hadError]) {
     SNDebugLog(@"INFO: %@--%@ : executeQuery error :%d, %@",
     NSStringFromClass(self.class), NSStringFromSelector(_cmd), [db lastErrorCode], [db lastErrorMessage]);
     return;
     }
     _myFavourites	= [self getObjects:[SNCloudSave class] fromResultSet:rs];
     [rs close];
     }];
     */
    __block NSArray *_getFavourites = nil;
    __block BOOL result = YES;
    [[SNDatabase writeQueue]  inTransaction:^(FMDatabase *db, BOOL *rollback)
     {
//         FMResultSet *rs	= [db executeQuery:[NSString stringWithFormat:@"SELECT * FROM %@ where title = ? and link = ?", TB_CLOUDSAVES], myCloudSave._title, link];//v5.2.2有些新闻标题不一样，链接相同，应该视为同条新闻
        //link有些包含gbcode,避免相同newsId的存多次
         NSArray *array = [link componentsSeparatedByString:@"&"];
         if ([array count] > 0) {
             link = [array objectAtIndex:0];
         }
         if (myCloudSave._myFavouriteRefer == MYFAVOURITE_REFER_GROUPPHOTOLIST_IN_ROLLINGNEWS && myCloudSave._contentLeveloneID) {
             if ([array count] >= 2) {
                 link = [[array objectAtIndex:0] stringByAppendingFormat:@"&%@", [array objectAtIndex:1]];
             }

         }
         else if (myCloudSave._myFavouriteRefer == MYFAVOURITE_REFER_NEWS_IN_PUB && myCloudSave._contentLeveloneID) {
             if ([array count] > 2) {
                 if ([[array objectAtIndex:1] containsString:@"newsId="]) {
                     link = [NSString stringWithFormat:@"news://%@", [array objectAtIndex:1]];
                 }
             }
         }
         
         FMResultSet *rs	= [db executeQuery:[NSString stringWithFormat:@"SELECT * FROM %@ where link = ?", TB_CLOUDSAVES], link];
         _getFavourites	= [self getObjects:[SNCloudSave class] fromResultSet:rs];
         if ([_getFavourites count] > 0) {
             result = YES;
         }
         else {
             result = [db executeUpdate:[NSString stringWithFormat:@"REPLACE INTO %@ (userid, title, link, collecttime, myFavouriteRefer, contentLeveloneID, contentLeveltwoID) VALUES (?,?,?,?,?,?,?)", TB_CLOUDSAVES],[info getUsername],myCloudSave._title, link, myCloudSave._collectTime, [NSNumber numberWithInt:myCloudSave._myFavouriteRefer], myCloudSave._contentLeveloneID, myCloudSave._contentLeveltwoID];
             }
         if([db hadError])
         {
             SNDebugLog(@"%@--%@ : ExecuteQuery error:%d, %@.", NSStringFromClass(self.class), NSStringFromSelector(_cmd), [db lastErrorCode],[db lastErrorMessage]);
             *rollback = YES;
             return;
         }
     }];
    return result;
}


-(BOOL)saveMyCloudSaveWithMyFav:(SNMyFavourite*)myFavourite
{
    SNUserinfo* info = [SNUserinfo userinfo];
//    if(info==nil || [info getUsername]==nil || [[info getUsername] length]==0)
//        return NO;
    
	if(myFavourite==nil || myFavourite.title==nil || myFavourite.pubDate==nil)
		return NO;
    
    NSString* link = [myFavourite generCloudLink];
    if(link==nil)
        return NO;
    
    __block BOOL result = YES;
    
    [[SNDatabase writeQueue]  inTransaction:^(FMDatabase *db, BOOL *rollback)
     {
         NSTimeInterval interval = [[NSDate date] timeIntervalSince1970];
         NSString* timeString = [NSString stringWithFormat:@"%f", interval];
         
        result = [db executeUpdate:[NSString stringWithFormat:@"REPLACE INTO %@ (userid, title, link, collecttime,myFavouriteRefer,contentLeveloneID,contentLeveltwoID) VALUES (?,?,?,?,?,?,?)", TB_CLOUDSAVES],[info getUsername], myFavourite.title, link, timeString, [NSNumber numberWithInt:myFavourite.myFavouriteRefer], myFavourite.contentLeveloneID, myFavourite.contentLeveltwoID];
         
         if([db hadError])
         {
             SNDebugLog(@"INFO: %@--%@ : executeUpdate error:%d, %@", NSStringFromClass(self.class), NSStringFromSelector(_cmd), [db lastErrorCode],[db lastErrorMessage]);
             *rollback = YES;
             return ;
         }
     }];
    return result;
}

//函数在各个收藏页面中被调用，用户删除云数据网络操作成功后删除数据库里的云存储数据
-(BOOL)deleteMyCloudSave:(SNCloudSave*)myFavourite
{
//    SNUserinfo* info = [SNUserinfo userinfo];
//    if(info==nil || [info getUsername]==nil || [[info getUsername] length]==0)
//        return NO;
    
    __block BOOL result = YES;
    [[SNDatabase writeQueue] inTransaction:^(FMDatabase *db, BOOL *rollback)
     {
//         result =[db executeUpdate:[NSString stringWithFormat:@"DELETE FROM %@ WHERE userid=? and link=?", TB_CLOUDSAVES], [info getUsername], myFavourite._link];
         result =[db executeUpdate:[NSString stringWithFormat:@"DELETE FROM %@ WHERE link=?", TB_CLOUDSAVES], myFavourite._link];
         
         if([db hadError])
         {
             SNDebugLog(@"INFO: %@--%@ : executeUpdate error :%d, %@", NSStringFromClass(self.class), NSStringFromSelector(_cmd), [db lastErrorCode],[ db lastErrorMessage]);
             *rollback = YES;
             return;
         }
     }];
    
	return result;
}

-(BOOL)deleteMyCloudSaves
{
//    SNUserinfo* info = [SNUserinfo userinfo];
//    if(info==nil || [info getUsername]==nil || [[info getUsername] length]==0)
//        return NO;
    
    __block BOOL result = YES;
    [[SNDatabase writeQueue]  inTransaction:^(FMDatabase *db, BOOL *rollback)
     {
//         result = [db executeUpdate:[NSString stringWithFormat:@"DELETE FROM %@ WHERE userid=?", TB_CLOUDSAVES], [info getUsername]];
         result = [db executeUpdate:[NSString stringWithFormat:@"DELETE FROM %@", TB_CLOUDSAVES]];
         if ([db hadError]) {
             SNDebugLog(@"INFO: %@--%@ : executeUpdate error :%d, %@", NSStringFromClass(self.class), NSStringFromSelector(_cmd), [db lastErrorCode],[ db lastErrorMessage]);
             *rollback = YES;
             return;
         }
     }];
	return YES;
}
@end
