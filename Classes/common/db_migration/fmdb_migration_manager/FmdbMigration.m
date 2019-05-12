//
//  FmdbMigrationColumn.m
//  fmdb-migration-manager
//
//  Created by Dr Nic on 6/09/08.
//  Copyright 2008 Mocra. All rights reserved.
//

#import "FmdbMigration.h"
#import "SNFmdbColumn.h"


@implementation FmdbMigration
@synthesize db=db_;

+ (id)migration {
	return [[self alloc] init];
}

#pragma mark -
#pragma mark up/down methods

- (void)up 
{
	SNDebugLog(@"%@", [NSString stringWithFormat:@"%@: -up method not implemented", NSStringFromClass([self class])]);
}

- (void)down 
{
	SNDebugLog(@"%@", [NSString stringWithFormat:@"%@: -down method not implemented", NSStringFromClass([self class])]);
}

- (void)upWithDatabase:(FMDatabase *)db 
{
	self.db = db;
	[self up];
}
- (void)downWithDatabase:(FMDatabase *)db 
{
	self.db = db;
	[self down];
}

#pragma mark -
#pragma mark Helper methods for manipulating database schema

- (void)createTable:(NSString *)tableName withColumns:(NSArray *)columns 
{
	[self createTable:tableName];
	for (FmdbMigrationColumn *migrationColumn in columns) {
		[self addColumn:migrationColumn forTableName:tableName];
	}
}

- (void)createTable:(NSString *)tableName 
{
	NSString *sql = [NSString stringWithFormat:@"CREATE TABLE IF NOT EXISTS %@ (ID integer primary key autoincrement)", tableName];
	[db_ executeUpdate:sql];
}

- (void)dropTable:(NSString *)tableName 
{
	NSString *sql = [NSString stringWithFormat:@"DROP TABLE IF EXISTS %@", tableName];
	[db_ executeUpdate:sql];
}

- (void)addColumn:(FmdbMigrationColumn *)column forTableName:(NSString *)tableName 
{
	NSString *sql = [NSString stringWithFormat:@"ALTER TABLE %@ ADD COLUMN %@", tableName, [column sqlDefinition]];
	[db_ executeUpdate:sql];
}

- (void)alterColumn:(FmdbMigrationColumn *)column forTableName:(NSString *)tableName
{
	NSString *sql = [NSString stringWithFormat:@"ALTER TABLE %@ ALTER COLUMN %@", tableName, [column sqlDefinition]];
	[db_ executeUpdate:sql];
}

- (void)dropColumn:(FmdbMigrationColumn *)column forTableName:(NSString *)tableName
{
    /*
    //常规的SQL实现方式，但是SQLite不支持Drop column数据库操作，所以采用后面的操作方式；
	NSString *sql = [NSString stringWithFormat:@"ALTER TABLE %@ DROP COLUMN %@", tableName, [column sqlDefinition]];
	[db_ executeUpdate:sql];
     */
    
    
    //由于傻逼SQLite不支持Drop column数据库操作，所以采用下面的操作方式：
    if (!column || !column || [@"" isEqualToString:tableName]) {
    
        return;
        
    }
    
    [db_ beginTransaction];
    
    //Save columns into array
    NSMutableArray *_tableColumns = [NSMutableArray array];
    
    NSString *_sql = [NSString stringWithFormat:@"PRAGMA table_info(%@)", tableName];
    
    FMResultSet *rs = [db_ executeQuery:_sql];
    
	while ([rs next]) {
        @autoreleasepool {
            SNFmdbColumn *_column = [[SNFmdbColumn alloc] init];
            
            _column.cid = [rs intForColumn:@"cid"];
            
            _column.name = [rs stringForColumn:@"name"];
            
            _column.type = [rs stringForColumn:@"type"];
            
            _column.notnull = [rs boolForColumn:@"notnull"];
            
            _column.dflt_value = [rs objectForColumnName:@"dflt_value"];
            
            _column.pk = [rs boolForColumn:@"pk"];
            
            [_tableColumns addObject:_column];
            
             //(_column);
        }
	}
    
    //Rename table
    _sql = nil;
    NSString *_tmpTableName = @"______tmpTableName______";
    
    if (_tableColumns && (_tableColumns.count > 0)) {
        
        _sql = [NSString stringWithFormat:@"ALTER TABLE %@ RENAME TO %@", tableName, _tmpTableName];
        
        BOOL _renameTableResut = [db_ executeUpdate:_sql];
        
        if (!_renameTableResut) {
            
            if ([db_ hadError]) {
                
                SNDebugLog(@"ERROR: %@--%@ : executeUpdate error with comming message :%d, %@",
                           NSStringFromClass(self.class), NSStringFromSelector(_cmd), [db_ lastErrorCode],[db_ lastErrorMessage]);
            }
            
            [db_ rollback];
        
            return;
        
        }
        
        
        //Create a new table dont contain column parameter specified.
        _sql = nil;
        NSMutableArray *_newTableColumns = [NSMutableArray array];
        
        for (SNFmdbColumn *_column in _tableColumns) {
            
            SNDebugLog(@"INFO: %@--%@, column data from oldTableColumns is [%@]", NSStringFromClass(self.class), NSStringFromSelector(_cmd), [_column description]);
        
            if ([_column.name isEqualToString:column.columnName]) {
                
                continue;
                
            }
            
            [_newTableColumns addObject:_column];
        
        }
    
        
        NSMutableString *_tmpSQL = [NSMutableString string];
        
        for (SNFmdbColumn *_column in _newTableColumns) {
            
            SNDebugLog(@"INFO: %@--%@, column data from newTableColumns is [%@]", NSStringFromClass(self.class), NSStringFromSelector(_cmd), [_column description]);
                        
            if ([_tableColumns indexOfObject:_column] > 0) {
            
                [_tmpSQL appendString:@", "];
            
            }
            
            [_tmpSQL appendFormat:@"%@ %@ %@ %@ %@",
             _column.name,
             _column.type,
             ((_column.pk) ? (([_column.type isEqualToString:@"integer"] || [_column.type isEqualToString:@"INTEGER"]) ? @"primary key autoincrement" : @"primary key") : @"" ),
             (_column.notnull ? @"not null" : @""),
             (((NSNull *)(_column.dflt_value) == [NSNull null]) ? @"" : [NSString stringWithFormat:@"DEFAULT %@",_column.dflt_value])
             ];
        
        }
        
        NSString *_createNewsTableSQL = [NSString stringWithFormat:@"CREATE TABLE IF NOT EXISTS %@ ( %@ )", tableName, _tmpSQL];
        
        SNDebugLog(@"INFO: %@--%@, Crate new table SQL IS [%@]", NSStringFromClass(self.class), NSStringFromSelector(_cmd), _createNewsTableSQL);
        
        BOOL _rst = [db_ executeUpdate:_createNewsTableSQL];
        
        if (_rst) {

            //Fill back data into new table;
            
            NSMutableString *_columnNamesSQLFragment = [NSMutableString string];
            
            for (SNFmdbColumn *_column in _newTableColumns) {
                
                if ([_newTableColumns indexOfObject:_column] > 0) {
                    
                    [_columnNamesSQLFragment appendString:@", "];
                
                }
            
                [_columnNamesSQLFragment appendString:_column.name];
                
            }
            
            NSString *_valuesSQLFrament = [NSString stringWithFormat:@"SELECT %@ from %@", _columnNamesSQLFragment, _tmpTableName];
            
            NSString *_fillBackDataSQL = [NSString stringWithFormat:@"INSERT INTO %@(%@) %@",
                                          tableName, _columnNamesSQLFragment, _valuesSQLFrament];
            
            SNDebugLog(@"INFO: %@--%@, Fill back data SQL IS [%@]", NSStringFromClass(self.class), NSStringFromSelector(_cmd), _fillBackDataSQL);
            
            BOOL _insertRst = [db_ executeUpdate:_fillBackDataSQL];
            
            if (_insertRst) {
                
                
                //Drop tmp table
                NSString *_dropTableSQL = [NSString stringWithFormat:@"DROP TABLE %@", _tmpTableName];
                
                BOOL _dropTableResult = [db_ executeUpdate:_dropTableSQL];
                
                if (_dropTableResult) {
                
                    [db_ commit];
                    
                } else {
                    
                    if ([db_ hadError]) {
                        
                        SNDebugLog(@"ERROR: %@--%@ : executeUpdate error with comming message :%d, %@",
                                   NSStringFromClass(self.class), NSStringFromSelector(_cmd), [db_ lastErrorCode],[db_ lastErrorMessage]);
                    }
                
                    [db_ rollback];
                
                }
                            
            } else {
                
                if ([db_ hadError]) {
                    
                    SNDebugLog(@"ERROR: %@--%@ : executeUpdate error with comming message :%d, %@",
                               NSStringFromClass(self.class), NSStringFromSelector(_cmd), [db_ lastErrorCode],[db_ lastErrorMessage]);
                }
            
                [db_ rollback];
            
            }

        
        } else {
            
            if ([db_ hadError]) {
            
                SNDebugLog(@"ERROR: %@--%@ : executeUpdate error with comming message :%d, %@",
                       NSStringFromClass(self.class), NSStringFromSelector(_cmd), [db_ lastErrorCode],[db_ lastErrorMessage]);
            }
        
            [db_ rollback];
            
        }
        
    } else {
        
        if ([db_ hadError]) {
            
                SNDebugLog(@"ERROR: %@--%@ : executeUpdate error with comming message :%d, %@",
                       NSStringFromClass(self.class), NSStringFromSelector(_cmd), [db_ lastErrorCode],[db_ lastErrorMessage]);
        }
    
        [db_ rollback];
        
    }

}

- (BOOL)executeSQL:(NSString *)sql {
    
    if (!sql || [@"" isEqualToString:sql]) {
    
        return NO;
        
    }
    
    BOOL _executeResult = [db_ executeUpdate:sql];
    
    SNDebugLog(@"INFO: %@--%@, Excute SQL [%@] result is [%d]",
               NSStringFromClass(self.class), NSStringFromSelector(_cmd), sql, _executeResult);

	return _executeResult;
    
}


#pragma mark -
#pragma mark Unit testing helpers

- (id)initWithDatabase:(FMDatabase *)db 
{
	if (self = [super init]) {
		self.db = db;
		return self;
	}
	return nil;
}



@end
