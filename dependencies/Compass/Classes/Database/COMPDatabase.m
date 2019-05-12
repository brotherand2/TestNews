//
//  COMPDatabase.m
//  Compass
//
//  Created by 李耀忠 on 28/09/2017.
//  Copyright © 2017 Beijing Sohu New Media Information Technology Co. Ltd. All rights reserved.
//

#import "COMPDatabase.h"
#import "COMPFMDatabase.h"
#import "COMPFMDatabaseQueue.h"
#import <sqlite3.h>

@interface COMPDatabase()

@property (nonatomic) COMPFMDatabaseQueue *sqliteQueue;
@property (nonatomic, weak) COMPFMDatabase *databaseIn;

@end

@implementation COMPDatabase

+ (instancetype)databaseWithPath:(NSString *)path {
    return [[self alloc] initWithPath:path];
}

- (instancetype)initWithPath:(NSString *)path {
    self = [super init];
    if (self) {
        _sqliteQueue = [COMPFMDatabaseQueue databaseQueueWithPath:path flags:SQLITE_OPEN_READWRITE | SQLITE_OPEN_CREATE | SQLITE_OPEN_FILEPROTECTION_NONE];
        if (self.sqliteQueue == nil) {
            self = nil;
        }
    }
    return self;
}

- (void)dealloc {
    [self.sqliteQueue inDatabase:^(COMPFMDatabase *db) {
        [db closeOpenResultSets];
        [db close];
    }];
    [self.sqliteQueue close];
}

- (void)setPropertiesOfDatabase:(COMPFMDatabase *)database {
    database.maxBusyRetryTimeInterval = 10;
    database.logsErrors = YES;
}

- (void)inDatabase:(void (^)(COMPFMDatabase *db))block {
    @synchronized(self) {
        if (self.databaseIn) {
            COMPFMDatabase *db = self.databaseIn;
            [self setPropertiesOfDatabase:db];
            block(db);
        } else {
            [self.sqliteQueue inDatabase:^(COMPFMDatabase *db) {
                self.databaseIn = db;
                [self setPropertiesOfDatabase:db];
                block(db);
                self.databaseIn = nil;
            }];
        }
    }
}

- (BOOL)isTableExistent:(NSString *)tableName {
    __block BOOL ret = NO;
    [self inDatabase:^(COMPFMDatabase *db) {
        COMPFMResultSet *rs = [db executeQuery:@"select count(*) as 'count' from sqlite_master where type ='table' and name = ?", tableName];
        if ([rs next]) {
            NSInteger count = [rs intForColumn:@"count"];
            if (count > 0) {
                ret = YES;
            }
        }
        [rs close];
    }];
    return ret;
}

- (BOOL)insert:(NSDictionary *)row intoTable:(NSString *)table withReplace:(BOOL)replace {
    if (row == nil) {
        return NO;
    }
    NSArray *keys = [row allKeys];
    NSArray *values = [row allValues];
    NSString *keysString = [keys componentsJoinedByString:@", "];
    NSMutableString *valuesString = [NSMutableString string];

    for (NSInteger index = 0; index < values.count; index++) {
        if (index == 0) {
            [valuesString appendString:@"?"];
        } else {
            [valuesString appendString:@", ?"];
        }
    }

    NSString *sql = [NSString stringWithFormat:@"%@ into %@ (%@) values (%@)", (replace ? @"replace" : @"insert"), table, keysString, valuesString];

    __block BOOL result;
    __block NSError *error = nil;
    [self inDatabase:^(COMPFMDatabase *db) {
        result = [db executeUpdate:sql values:values error:&error];
    }];

    return result;
}

#pragma mark - public methods

#pragma mark execute

- (BOOL)executeUpdate:(NSString *)sql {
    __block BOOL ret = NO;
    [self inDatabase:^(COMPFMDatabase *db) {
        ret = [db executeUpdate:sql];
    }];

    return ret;
}

#pragma mark state

- (NSInteger)countFromTable:(NSString *)table {
    return [self countFromTable:table withCondition:nil];
}

- (NSInteger)countFromTable:(NSString *)table withCondition:(NSString *)condition {
    NSMutableString *sql = [NSMutableString stringWithFormat:@"select count(1) from %@", table];
    if (condition) {
        [sql appendFormat:@" %@", condition];
    }
    __block NSInteger count = 0;
    [self inDatabase:^(COMPFMDatabase *db) {
        COMPFMResultSet *rs = [db executeQuery:sql];
        if ([rs next]) {
            count = [rs intForColumnIndex:0];
        }
        [rs close];
    }];
    return count;
}

#pragma mark - Find

- (NSDictionary *)findOne:(NSString *)fields fromTable:(NSString *)table withCondition:(NSString *)condition {
    NSDictionary *one = [self findOne:fields fromTable:table withOrder:nil withCondition:condition];
    return one;
}

- (NSDictionary *)findOne:(NSString *)fields fromTable:(NSString *)table withOrder:(NSString *)order withCondition:(NSString *)condition {
    NSArray *list = [self findAll:fields fromTable:table withOffset:0 withCount:1 withOrder:order withCondition:condition];
    if ([list count] <= 0) {
        return nil;
    }
    return list[0];
}

#pragma mark insert delete update

- (BOOL)insert:(NSDictionary *)row intoTable:(NSString *)table {
    return [self insert:row intoTable:table withReplace:NO];
}


- (BOOL)deleteFromTable:(NSString *)table withCondition:(NSString *)condition {
    NSMutableString *sql = [NSMutableString stringWithFormat:@"delete from %@", table];
    if (condition) {
        [sql appendFormat:@" %@", condition];
    }
    __block BOOL ret = NO;
    [self inDatabase:^(COMPFMDatabase *db) {
        ret = [db executeUpdate:sql];
    }];
    return ret;
}

#pragma mark findAll

- (NSArray *)findAll:(NSString *)fields fromTable:(NSString *)table {
    return [self findAll:fields fromTable:table withOffset:0 withCount:-1 withOrder:nil withCondition:nil];
}

- (NSArray *)findAll:(NSString *)fields fromTable:(NSString *)table withOffset:(NSInteger)offset withCount:(NSInteger)count {
    return [self findAll:fields fromTable:table withOffset:offset withCount:count withOrder:nil withCondition:nil];
}

- (NSArray *)findAll:(NSString *)fields fromTable:(NSString *)table withOffset:(NSInteger)offset withCount:(NSInteger)count withOrder:(NSString *)order withCondition:(NSString *)condition {
    NSMutableString *sql = [NSMutableString stringWithFormat:@"select %@ from %@", fields, table];
    if (condition) {
        [sql appendFormat:@" %@", condition];
    }
    if (order) {
        [sql appendFormat:@" %@", order];
    }
    if (count >= 0) {
        [sql appendFormat:@" limit %@, %@", @(offset), @(count)];
    }

    __block NSMutableArray *list = nil;
    [self inDatabase:^(COMPFMDatabase *db) {
        COMPFMResultSet *rs = [db executeQuery:sql];
        if (rs) {
            list = [NSMutableArray array];
            while ([rs next]) {
                if (rs.resultDictionary) {
                    [list addObject:rs.resultDictionary];
                }
            }
            [rs close];
        }
    }];

    return list.copy;
}


@end
