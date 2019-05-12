//
//  SNDatabase+NewFeedBack.m
//  sohunews
//
//  Created by 李腾 on 2016/10/20.
//  Copyright © 2016年 Sohu.com. All rights reserved.
//

#import "SNDatabase+NewFeedBack.h"

@implementation SNDatabase (NewFeedBack)

-(NSMutableArray *)loadAllFeedBacks {
    __block NSMutableArray *fbs = nil;
    [[SNDatabase readQueue] inDatabase:^(FMDatabase *db) {
        FMResultSet *rs	= [db executeQuery:@"SELECT * FROM tbNewFeedback"];
        if ([db hadError]) {
            return;
        }
        
        fbs	= [self getFeedBacksFromResultSet:rs];
        [rs close];
        
    }];
    return fbs;
    
}

-(NSMutableArray *)getFeedBacksFromResultSet:(FMResultSet*)rs
{
    if (rs == nil) {
        SNDebugLog(@"getFloorCommentFromResultSet:Invalid rs");
        return nil;
    }
    
    NSMutableArray *fbs = [NSMutableArray array];
    while ([rs next])
    {
        NSData *data = [rs objectForColumnName:@"model"];
        SNFeedBackModel *model = [NSKeyedUnarchiver unarchiveObjectWithData:data];
        [fbs addObject:model];
    }
    
    return fbs;
}

-(BOOL)saveFeedBacksToDB:(NSMutableArray *)fbs {
    if (fbs == nil || [fbs count] == 0) {
        return NO;
    }
    
    __block BOOL bSucceed	= YES;
    [[SNDatabase writeQueue] inTransaction:^(FMDatabase *db, BOOL *rollback) {
        for (SNFeedBackModel *fb in fbs) {
            bSucceed = [self addFeedBack:fb inDatabase:db];
            if (!bSucceed) {
                *rollback = YES;
                return;
            }
        }
    }];
    return bSucceed;
}


-(BOOL)addFeedBack:(SNFeedBackModel *)fb
{
    __block BOOL result = YES;
    [[SNDatabase writeQueue] inTransaction:^(FMDatabase *db, BOOL *rollback) {
        result = [self addFeedBack:fb inDatabase:db];
        if (!result) {
            *rollback = YES;
        }
    }];
    return result;
}
-(BOOL)addFeedBack:(SNFeedBackModel *)fb inDatabase:(FMDatabase *)db {
    if (fb == nil) {
        return NO;
    }
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        
        NSString *sql = @"create table if not exists tbNewFeedback(model blob);";
        BOOL result = [db executeUpdate:sql];
        if (result) {
            //            SNDebugLog(@"创建表成功");
        } else {
            return;
        }
    });
    
    
    // 添加
    NSData *data = [NSKeyedArchiver archivedDataWithRootObject:fb];
    [db executeUpdate:@"INSERT INTO tbNewFeedBack (model) VALUES (?)",data];
    
    if ([db hadError]) {
        SNDebugLog(@"addSingleFB : db executeUpdate error:%d,%@"
                   ,[db lastErrorCode],[db lastErrorMessage]);
        return NO;
    }
    return YES;
}

- (BOOL)deleteAllFeedBacks {
    
    __block BOOL result = YES;
    [[SNDatabase writeQueue] inTransaction:^(FMDatabase *db, BOOL *rollback) {
        result = [db executeUpdate:@"delete from tbNewFeedback"];
        if ([db hadError]) {
            *rollback = YES;
            return;
        }
    }];
    return result;}

@end
