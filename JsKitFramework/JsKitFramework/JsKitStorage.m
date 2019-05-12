//
//  JsKitStorage.m
//  JsKitFramework
//
//  Created by sevenshal on 15/10/19.
//  Copyright © 2015年 sohu. All rights reserved.
//

#import "JsKitStorage.h"
#import "JsKitFramework.h"
#import "JKLimitMemoryCache.h"
#import <sqlite3.h>

#define TB_STORAGE "TB_STORAGE"
#define COL_KEY "COL_KEY"
#define COL_VALUE "COL_VALUE"
#define COL_EXPIRE "COL_EXPIRE"

#define MAX_CAHCE_SIZE 64

@implementation JsKitStorage {
    JKLimitMemoryCache *dic;
    sqlite3 *database;
}

@synthesize webAppName;

- (instancetype)initWithWebAppName:(NSString *)__webAppName {
    if (self=[super init]) {
        self.webAppName = __webAppName;
        dic = [[JKLimitMemoryCache alloc] initWithMaxSize:MAX_CAHCE_SIZE];
        int err = sqlite3_open([[self dataFilePath] UTF8String], &database);
        if (err == SQLITE_OK) {
            [self createTables];
            [self clearExpireDBItems];
        } else {
            database = NULL;
        }
    }
    return self;
}

- (void)jsInterface:(id)client
            setItem:(NSString *)key
              value:(id)value expire:(NSNumber *)expire {
    if (nil == key || nil == value)
        return;
    
    [self setItem:value forKey:key withExpire:expire];
}

- (id)jsInterface:(id)client getItem:(NSString *)key {
    return [self getItem:key];
}

- (id)jsInterface:(id)client findItems:(NSString *)likeKey {
    return [self findItems:likeKey];
}

- (void)jsInterface:(id)client removeItem:(NSString *)key {
    [self removeItem:key];
}

- (id)jsInterface:(id)client removeItems:(NSString *)likeKey {
    return [self removeItems:likeKey];
}

- (void)jsInterface_clear:(id)client {
    [self clear];
}

- (void)setItem:(id)item forKey:(NSString *)key {
    [self setItem:item forKey:key withExpire:nil];
}

- (void)setItem:(id)item forKey:(NSString *)key
     withExpire:(NSNumber *)expire {
    [dic setObject:item forKey:key];
    [self setDBItem:item forKey:key withExpire:expire];
}

- (id)getItem:(NSString *)key {
    id value = [dic objectForKey:key];
    if (!value) {
        value = [self getDBItem:key];
        if (value) {
            [dic setObject:value forKey:key];
        }
    }
    return value;
}

- (void)removeItem:(NSString *)key {
    [dic removeObjectForKey:key];
    [self removeDBItem:key];
}

- (void)clear {
    [dic removeAllObjects];
    [self clearDBItems];
}

- (NSString *)dataFilePath {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    return [documentsDirectory stringByAppendingFormat:@"/jskit_storage_%@",webAppName];
}

- (BOOL)createTables {
    char *sql = "CREATE TABLE IF NOT EXISTS "TB_STORAGE"(`"COL_KEY"` TEXT UNIQUE ON CONFLICT REPLACE,`"COL_VALUE"` TEXT NOT NULL ON CONFLICT FAIL,`"COL_EXPIRE"` INTEGER DEFAULT 0)";
    sqlite3_stmt *statement;
    NSInteger sqlReturn = sqlite3_prepare_v2(database, sql, -1, &statement, nil);
    
    //QL语句解析出错
    if (sqlReturn != SQLITE_OK) {
        return NO;
    }
    
    //执行SQL语句
    int success = sqlite3_step(statement);
    //释放sqlite3_stmt
    sqlite3_finalize(statement);
    
    //执行SQL语句失败
    if (success != SQLITE_DONE) {
        return NO;
    }
    return YES;
}

- (id)findItems:(NSString *)likeKey {
    //判断数据库是否打开
    if (database) {
        @synchronized(self) {
            sqlite3_stmt *statement = nil;
            if (sqlite3_prepare_v2(database, "SELECT "COL_KEY","COL_VALUE" FROM "TB_STORAGE" WHERE "COL_KEY" LIKE ?", -1, &statement, NULL) != SQLITE_OK) {
                return nil;
            }
            sqlite3_bind_text(statement, 1, [likeKey UTF8String], -1, SQLITE_TRANSIENT);
            NSString *keyStr;
            NSData *jsonResult;
            NSArray *value;
            NSMutableArray *list = [[NSMutableArray alloc] initWithCapacity:sqlite3_data_count(statement)];
            while (sqlite3_step(statement) == SQLITE_ROW) {
                keyStr = [NSString stringWithUTF8String:(const void *)sqlite3_column_blob(statement, 0)];
                jsonResult = [NSData dataWithBytes:(const void *)sqlite3_column_blob(statement, 1) length:sqlite3_column_bytes(statement,1)];
                value = [NSJSONSerialization JSONObjectWithData:jsonResult
                                                        options:kNilOptions
                                                          error:nil];
                [list addObject:@{@"key" : keyStr,
                                  @"value" : [value firstObject]}];
            }
            sqlite3_finalize(statement);
            return list;
        }
    }
    return nil;
}

- (id)getDBItem:(NSString *)key {
    //判断数据库是否打开
    if (database) {
        @synchronized(self) {
            sqlite3_stmt *statement = nil;

            if (sqlite3_prepare_v2(database, "SELECT "COL_VALUE" FROM "TB_STORAGE" WHERE "COL_KEY" =?", -1, &statement, NULL) != SQLITE_OK) {
                return nil;
            }
            sqlite3_bind_text(statement, 1, [key UTF8String], -1, SQLITE_TRANSIENT);
            if (sqlite3_step(statement) != SQLITE_ROW) {
                sqlite3_finalize(statement);
                return nil;
            }
            const void *result = (const void *)sqlite3_column_blob(statement, 0);
            NSData *jsonResult = [NSData dataWithBytes:result length:sqlite3_column_bytes(statement,0)];
            NSArray *array = [NSJSONSerialization JSONObjectWithData:jsonResult options:kNilOptions error:nil];
            if (array.count > 0) {
                sqlite3_finalize(statement);
                return [array objectAtIndex:0];
            }
            sqlite3_finalize(statement);
        }
    }
    return nil;
}

- (void)setDBItem:(id)value forKey:(NSString *)key {
    [self setDBItem:value forKey:key withExpire:nil];
}

- (void)setDBItem:(id)value forKey:(NSString *)key
       withExpire:(NSNumber *)expire {
    if (database) {
        @synchronized(self) {
            @autoreleasepool {
                NSData *data = value ? [NSJSONSerialization dataWithJSONObject:@[value] options:kNilOptions error:nil] : [NSData data];
                sqlite3_stmt *statement = nil;
                
                if (sqlite3_prepare_v2(database, "REPLACE INTO "TB_STORAGE"("COL_KEY","COL_VALUE","COL_EXPIRE") VALUES(?,?,?)", -1, &statement, NULL) != SQLITE_OK) {
                    return;
                }
                sqlite3_bind_text(statement, 1, [key UTF8String], -1, SQLITE_TRANSIENT);
                sqlite3_bind_blob(statement, 2, [data bytes], (int)[data length], SQLITE_TRANSIENT);
                sqlite3_bind_int64(statement, 3, expire?((int64_t)[NSDate timeIntervalSinceReferenceDate]+[expire longValue]):0);
                int success = sqlite3_step(statement);
                if (success == SQLITE_ERROR) {
                }
                //释放statement
                sqlite3_finalize(statement);
            }
        }
    }
}

- (id)removeItems:(NSString *)likeKey {
    [dic removeAllObjects];
    if (database) {
        @synchronized(self) {
            sqlite3_stmt *statement = nil;
            if (sqlite3_prepare_v2(database, "DELETE FROM "TB_STORAGE" WHERE "COL_KEY" LIKE ?", -1, &statement, NULL) != SQLITE_OK) {
                return @0;
            }
            sqlite3_bind_text(statement, 1, [likeKey UTF8String], -1, SQLITE_TRANSIENT);
            int success = sqlite3_step(statement);
            if (success == SQLITE_ERROR) {
            }
            //释放statement
            sqlite3_finalize(statement);
            return @(sqlite3_changes(database));
        }
    }
    return @0;
}

- (void)removeDBItem:(NSString *)key {
    if (database) {
        @synchronized(self) {
            sqlite3_stmt *statement = nil;
            if (sqlite3_prepare_v2(database, "DELETE FROM "TB_STORAGE" WHERE "COL_KEY"=?", -1, &statement, NULL) != SQLITE_OK) {
                return;
            }
            sqlite3_bind_text(statement, 1, [key UTF8String], -1, SQLITE_TRANSIENT);
            int success = sqlite3_step(statement);
            if (success == SQLITE_ERROR) {
            }
            //释放statement
            sqlite3_finalize(statement);
        }
    }
}

- (void)clearDBItems {
    if (database) {
        @synchronized(self) {
            sqlite3_stmt *statement = nil;
            if (sqlite3_prepare_v2(database, "DELETE FROM "TB_STORAGE, -1, &statement, NULL) != SQLITE_OK) {
                return;
            }
            int success = sqlite3_step(statement);
            if (success == SQLITE_ERROR) {
            }
            //释放statement
            sqlite3_finalize(statement);
        }
    }
}

- (void)clearExpireDBItems {
    if (database) {
        @synchronized(self) {
            sqlite3_stmt *statement = nil;
            if (sqlite3_prepare_v2(database, "DELETE FROM "TB_STORAGE" WHERE "COL_EXPIRE"!=0 AND "COL_EXPIRE"<?", -1, &statement, NULL) != SQLITE_OK) {
                return;
            }
            sqlite3_bind_int64(statement, 1, (int64_t)[NSDate timeIntervalSinceReferenceDate]);
            int success = sqlite3_step(statement);
            if (success == SQLITE_ERROR) {
            }
            //释放statement
            sqlite3_finalize(statement);
        }
    }
}

@end
