//
//  SNDatabase+newsAudio.m
//  sohunews
//
//  Created by guoyalun on 5/6/13.
//  Copyright (c) 2013 Sohu.com. All rights reserved.
//

#import "SNDatabase+newsAudio.h"

@implementation SNDatabase (newsAudio)

-(NSArray*)getNewsAudioList
{
    NSMutableArray *audioList = [NSMutableArray array];
    [[SNDatabase readQueue] inDatabase:^(FMDatabase *db) {
        FMResultSet *rs	= [db executeQuery:@"SELECT * FROM tbNewsAudio"];
        if ([db hadError]) {
            SNDebugLog(@"getNewsAudioList : executeQuery error :%d,%@"
                       ,[db lastErrorCode],[db lastErrorMessage]);
            return;
        }
        [audioList addObjectsFromArray:[self getObjects:[SNNewsAudio class] fromResultSet:rs]];
        [rs close];
    }];
    
	return audioList;

}
-(NSArray*)getNewsAudioByTermId:(NSString*)termId newsId:(NSString*)newsId
{
    NSMutableArray *audioList = [NSMutableArray array];
    [[SNDatabase readQueue] inDatabase:^(FMDatabase *db) {
        [audioList addObjectsFromArray:[self getNewsAudioByTermId:termId newsId:newsId inDatabase:db]];
    }];
    return audioList;
}
-(NSArray*)getNewsAudioByTermId:(NSString*)termId newsId:(NSString*)newsId inDatabase:(FMDatabase *)db
{
    NSMutableArray *audioList = [NSMutableArray array];
    FMResultSet *rs	= [db executeQuery:@"SELECT * FROM tbNewsAudio WHERE termId=? AND newsId=?",termId,newsId];
    if ([db hadError]) {
        SNDebugLog(@"getNewsAudioByTermId : executeQuery error :%d,%@"
                   ,[db lastErrorCode],[db lastErrorMessage]);
        return audioList;
    }
    [audioList addObjectsFromArray:[self getObjects:[SNNewsAudio class] fromResultSet:rs]];
    [rs close];
    return audioList;
}
-(SNNewsAudio *)getNewsAudioByUrl:(NSString*)url
{
    __block SNNewsAudio *newsAudio = nil;
    [[SNDatabase readQueue] inDatabase:^(FMDatabase *db) {
        FMResultSet *rs	= [db executeQuery:@"SELECT * FROM tbNewsAudio WHERE url=?",url];
        if ([db hadError]) {
            SNDebugLog(@"getNewsAudioByUrl : executeQuery error :%d,%@"
                       ,[db lastErrorCode],[db lastErrorMessage]);
            return;
        }
        newsAudio = [self getFirstObject:[SNNewsAudio class] fromResultSet:rs];
        [rs close];
    }];
    return newsAudio;
}

-(BOOL)addSingleNewsAudio:(SNNewsAudio*)newsAudio
{
    __block BOOL result = NO;
    [[SNDatabase writeQueue] inTransaction:^(FMDatabase *db, BOOL *rollback) {
        result = [self addSingleNewsAudio:newsAudio inDatabase:db];
        if (!result) {
            *rollback = YES;
            return ;
        }
    }];
    return result;
}
-(BOOL)addSingleNewsAudio:(SNNewsAudio*)newsAudio inDatabase:(FMDatabase *)db
{
    BOOL result = [db executeUpdate:@"REPLACE INTO tbNewsAudio (termId,newsId,audioId,name,url,playTime,size) \
     VALUES (?,?,?,?,?,?,?)",newsAudio.termId,newsAudio.newsId,newsAudio.audioId,newsAudio.name
     ,newsAudio.url,newsAudio.playTime,newsAudio.size];
    if ([db hadError]) {
        SNDebugLog(@"addSingleNewsAudio : executeUpdate error :%d,%@,newsImage:%@"
                   ,[db lastErrorCode],[db lastErrorMessage],newsAudio);
        return NO;
    }
    return result;

}

-(BOOL)addMultiNewsAudio:(NSArray*)newsAudioList
{
    __block  BOOL result = NO;
    [[SNDatabase writeQueue] inTransaction:^(FMDatabase *db, BOOL *rollback) {
        result = [self addMultiNewsAudio:newsAudioList inDatabase:db];
        if (!result) {
            *rollback = YES;
            return ;
        }
    }];
    return result;
}

-(BOOL)addMultiNewsAudio:(NSArray*)newsAudioList inDatabase:(FMDatabase *)db
{
    BOOL result = NO;
    for (SNNewsAudio *audio in newsAudioList) {
        result = [self addSingleNewsAudio:audio inDatabase:db];
        if (!result) {
            return NO;
        }
    }
    return result;
}

-(BOOL)deleteNewsAudioByUrl:(NSString*)url
{
    __block BOOL result = NO;
    [[SNDatabase writeQueue] inTransaction:^(FMDatabase *db, BOOL *rollback) {
        result = [db executeUpdate:@"DELETE FROM tbNewsAudio WHERE url=?",url];
        if ([db hadError]) {
            SNDebugLog(@"deleteNewsAudioByUrl : executeQuery error :%d,%@"
                       ,[db lastErrorCode],[db lastErrorMessage]);
            return;
        }
        
    }];
    return result;

}

-(BOOL)deleteNewsAudioByNewsId:(NSString*)newsId
{
    __block BOOL result = NO;
    [[SNDatabase writeQueue] inTransaction:^(FMDatabase *db, BOOL *rollback) {
        result = [db executeUpdate:@"DELETE FROM tbNewsAudio WHERE newsId=?",newsId];
        if ([db hadError]) {
            SNDebugLog(@"deleteNewsAudioByNewsId : executeQuery error :%d,%@"
                       ,[db lastErrorCode],[db lastErrorMessage]);
            return;
        }

    }];
    return result;
}

-(BOOL)deleteNewsAudioByTermId:(NSString*)termId newsId:(NSString*)newsId inDatabase:(FMDatabase *)db
{
    BOOL result = [db executeUpdate:@"DELETE FROM tbNewsAudio WHERE termId=? AND newsId=?",termId,newsId];
    if ([db hadError]) {
        SNDebugLog(@"deleteNewsAudioByTermId : executeQuery error :%d,%@"
                   ,[db lastErrorCode],[db lastErrorMessage]);
        return NO;
    }
    return result;

}



@end
