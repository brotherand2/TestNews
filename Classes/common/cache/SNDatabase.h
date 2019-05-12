
//  Created by ivan 
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FMDatabase.h"
#import "FMDatabaseAdditions.h"
#import "FMDatabaseQueue.h"
#import "ZipArchive.h"
#import "CacheObjects.h"
#import "CacheDefines.h"
#import "NSDate-Utilities.h"

#define	UPDATE_SETSTATEMNT			@"setStatement"
#define	UPDATE_SETARGUMENTS			@"valueArguments"


//database table name
#define kTablenamePubCover					(@"publishmentCover")
#define kTablenamePubThumb					(@"publishmentThumb")

//database sql
#define kSqlCreateTable						(@"create table")
#define kSqlInsertTable						(@"insert into")
#define kSqlUpdateTable						(@"update")

#define SQL_CREATETABLE(TABLENAME, TABLELIST)  ([NSString stringWithFormat:@"%@ %@ (%@)", kSqlCreateTable, (TABLENAME), (TABLELIST)])
#define SQL_INSERTTOTABLE(TABLENAME, TABLELIST, TABLELISTVALUE)  ([NSString stringWithFormat:@"%@ %@ (%@) values (%@)", kSqlInsertTable, (TABLENAME), (TABLELIST), (TABLELISTVALUE)])
#define SQL_UPDATETABLE(TABLENAME, CHANGECOLUMN)  ([NSString stringWithFormat:@"%@ %@ set %@ = ? where %@ = ?", kSqlUpdateTable, (TABLENAME),(CHANGECOLUMN), (CHANGECOLUMN)])

typedef enum {
	ORDER_OPT_DEFAULT,
	ORDER_OPT_ASC,
	ORDER_OPT_DESC
}ORDER_OPTION;

typedef enum
{
	ADDNEWSARTICLE_BY_TERMID,//订阅刊物的某期
	ADDNEWSARTICLE_BY_CHANNELID,//滚动频道
	//ADDNEWSARTICLE_BY_PUBID//订阅刊物
}ADDNEWSARTICLE_OPTION;




@protocol SNDatabaseRequestDelegate;
@interface SNDatabase : NSObject<NSXMLParserDelegate,ZipArchiveDelegate>
{
    NSMutableArray *_UrlRequestAry;
    BOOL _isChangePushSetting;
	BOOL _isChangeReadStatus;
    
    NSMutableDictionary *_imgDownloadDelegates;
	
@private
	NSString	*_newspaperHomePagePath;
}
@property (nonatomic) BOOL isChangePushSetting;
@property (nonatomic) BOOL isChangeReadStatus;

- (NSMutableArray *)getObjects:(Class)clazz fromResultSet:(FMResultSet *)rs limitCount:(NSInteger)maxCount;
- (NSArray *)getObjects:(Class)clazz fromResultSet:(FMResultSet *)rs;
- (id)getFirstObject:(Class)clazz fromResultSet:(FMResultSet *)rs;

- (void)addObserver:(id)observer;
- (void)deleteObserver:(id)observer;

-(BOOL)isUrlBeingRequested:(NSString*)url;
-(BOOL)setDelegate:(id)delegate ofUrl:(NSString*)url;
-(BOOL)cancelRequestByUrl:(NSString*)url;

-(NSString*)getCommonCachePath;

//缓存清理策略
-(float)getCacheTotalSize;
-(float)getTTCacheSize;
-(BOOL)clearAllCache;

//恢复为原始数据库
+(void)deleteAndUseDefaultSqliteFile;

+ (FMDatabaseQueue *)readQueue;
+ (FMDatabaseQueue *)writeQueue;

- (void)removeDelegatesForURL:(NSString *)url;

@end


@protocol SNDatabaseRequestDelegate<NSObject>

@optional
- (void)requestDidStartLoad:(NSString*)url;
- (void)requestUpdateProgress:(NSString*)url receivedLen:(NSInteger)receivedLen totalLen:(NSInteger)totalLen;
- (void)requestDidFinishLoad:(NSString*)url;
- (void)request:(NSString*)url didFailLoadWithError:(NSError*)error;
- (void)requestDidCancelLoad:(NSString*)url;

@end
