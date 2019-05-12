//
//  CacheMgr_Private.h
//  sohunews
//
//  Created by 李 雪 on 11-10-18.
//  Copyright 2011 Sohu.com Inc. All rights reserved.
//

#import "SNDatabase.h"

@interface SNDatabase(Private)

-(NSString*)formatParamStringFromValuePairs:(NSDictionary*)valuePairs isConditionStatements:(BOOL)bCondition;
-(NSDictionary*)formatUpdateSetStatementsInfoFromValuePairs:(NSDictionary*)valuePairs ignoreNilValue:(BOOL)bIgnoreNilValue;

-(NSString*)getCacheBasePath;
-(NSString*)getNewspaperCachePath;


-(NSString*)getUrlPathExtension:(NSString*)url;
-(NSString*)getUrlLastPath:(NSString*)url;
-(NSString*)getNewspaperHomePageRelativePathFromOnlineUrl:(NSString*)url;
-(NSString*)getNewspaperFolderPathByHomePagePath:(NSString*)newspaperHomePagePath;
-(NSString *)getSingleNewspaperFolderPath:(NSString*)newspaperHomePagePath;

-(void)addSqlArgument:(NSString*)argument toArguments:(NSMutableArray*)arguments;

-(NSString*)generateCachePathByUrl:(NSString*)url basePath:(NSString*)basePath;

@end
