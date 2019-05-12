//
//  CacheMgr_Private.m
//  sohunews
//
//  Created by 李 雪 on 11-10-18.
//  Copyright 2011 Sohu.com Inc. All rights reserved.
//

#import "SNDatabase_Private.h"
#import "CacheDefines.h"


@implementation SNDatabase(Private)
-(NSString*)formatParamStringFromValuePairs:(NSDictionary*)valuePairs isConditionStatements:(BOOL)bCondition;
{
	if (valuePairs == nil) {
		SNDebugLog(@"formatParamStringFromValuePairs : Invalid value pairs");
		return nil;
	}
	
	NSArray *keys	= [valuePairs allKeys];
	if ([keys count] == 0) {
		SNDebugLog(@"formatParamStringFromValuePairs: Empty value pairs");
		return nil;
	}
	
	NSMutableString *param	= [[NSMutableString alloc] init];
	for (NSString *key in keys) {
		NSString *value	= [valuePairs valueForKey:key];
		if (value != nil) {
			NSString *valuePair	= [NSString stringWithFormat:@"%@=\'%@\'",key,value];
			if ([param length] != 0) 
			{
				if (bCondition) {
					[param appendString:@" and "];
				}
				else {
					[param appendString:@","];
				}
			}
			[param appendString:valuePair];
		}
	}
	
	if ([param length] == 0) {
		return nil;
	}
	
	NSString *selectWhere	= [NSString stringWithString:param];
	return selectWhere;
}

-(NSDictionary*)formatUpdateSetStatementsInfoFromValuePairs:(NSDictionary*)valuePairs ignoreNilValue:(BOOL)bIgnoreNilValue
{
	if ([valuePairs count] == 0) {
		return nil;
	}
	
	NSMutableString *setStatement = [[NSMutableString alloc] initWithString:@"SET "];
	BOOL bFlag	= true;
	NSArray *keys	= [valuePairs allKeys];
	NSMutableArray *valueArguments	= [NSMutableArray array];
	for (NSString *key in keys) {
		NSString *value	= [valuePairs objectForKey:key];
		if (value == nil && bIgnoreNilValue) {
			continue;
		}
		
		NSString *set = nil;
		if (bFlag) {
			set	= [NSString stringWithFormat:@"%@=?",key];
			bFlag = false;
		}
		else {
			set	= [NSString stringWithFormat:@",%@=?",key];
		}
		[setStatement appendString:set];
		
		if (value == nil) {
			[valueArguments addObject:[NSNull null]];
		}
		else {
			[valueArguments addObject:value];
		}
	}
	
	[setStatement appendString:@" "];
	
	NSDictionary *dictionary = [NSDictionary dictionaryWithObjectsAndKeys:
								setStatement,UPDATE_SETSTATEMNT
								,valueArguments,UPDATE_SETARGUMENTS,nil];
	return dictionary;
}

-(NSString*)getCacheBasePath
{
	NSString *commonCachePath	= [[TTURLCache sharedCache] cachePath];
	if ([commonCachePath length] == 0) {
		SNDebugLog(@"getCacheBasePath : Empty common cache path");
		return nil;
	}
	
	NSRange rangeLastCommponent	= [commonCachePath rangeOfString:@"/" options:NSBackwardsSearch];
	if (rangeLastCommponent.location == NSNotFound) {
		SNDebugLog(@"getCacheBasePath : Invalid common cache path,%@",commonCachePath);
		return nil;
	}
	
	NSString *cacheBasePath	= [commonCachePath substringToIndex:rangeLastCommponent.location];
	return cacheBasePath;
}


-(NSString*)getNewspaperCachePath
{
	NSString *newspaperCacheDirectory		= [[self getCacheBasePath] stringByAppendingPathComponent:CACHE_NEWSPAPER_DIRECTORY];
	
	NSFileManager *fm	= [NSFileManager defaultManager];
	BOOL bIsDirectory	= NO;
	//文件夹已经存在，则直接返回
	if ([fm fileExistsAtPath:newspaperCacheDirectory isDirectory:&bIsDirectory] && bIsDirectory) {
		return newspaperCacheDirectory;
	}
	
	NSError *error;
	//否则，新创建
	BOOL bCreateSucceed	= [fm createDirectoryAtPath:newspaperCacheDirectory withIntermediateDirectories:YES attributes:nil error:&error];
	if (!bCreateSucceed) {
		SNDebugLog(@"getNewspaperCacheDirectory : create directory falied,%d,%@,path=%@"
				   ,[error code],[error localizedDescription],newspaperCacheDirectory);
		return nil;
	}
	
	return newspaperCacheDirectory;
}

-(NSString*)getUrlPathExtension:(NSString*)url
{
	NSString *urlLastPath	= [self getUrlLastPath:url];
	if (urlLastPath == nil || [urlLastPath length] == 0) {
		return nil;
	}
	
	NSRange rangeDot	= [urlLastPath rangeOfString:@"." options:NSBackwardsSearch];
	if (rangeDot.location == NSNotFound || rangeDot.location == ([url length] - 1)) {
		return nil;
	}
	
	NSInteger len	= [urlLastPath length] - rangeDot.location - 1;
	
	NSRange extensionRange	= NSMakeRange(rangeDot.location + 1, len);
	return [urlLastPath substringWithRange:extensionRange];
}

-(NSString*)getUrlLastPath:(NSString*)url
{
	if (url == nil | [url length] == 0) {
		return nil;
	}
	
	//跳过url的http头标记
	NSRange rangeHttp	= [url rangeOfString:[SNAPI rootScheme] options:NSCaseInsensitiveSearch];
	if (rangeHttp.location && rangeHttp.location < ([url length] - 1)) {
		url	= [url substringFromIndex:(rangeHttp.location + rangeHttp.length)];
	}
	
	//找到最后一个“/”
	NSRange rangeLastComponent	= [url rangeOfString:@"/" options:NSBackwardsSearch];
	if (rangeLastComponent.location == NSNotFound || rangeLastComponent.location == ([url length] - 1)) {
		return nil;
	}
	else {
		url	= [url substringFromIndex:(rangeLastComponent.location + 1)];
	}
	
	NSInteger len;
	
	NSRange rangeParam	= [url rangeOfString:@"?"];
	NSRange rangeAnchor	= [url rangeOfString:@"#"];
	if (rangeParam.location == NSNotFound &&  rangeAnchor.location == NSNotFound) {
		len	= [url length];
	}
	else {
		len	= (rangeParam.location < rangeAnchor.location) ? rangeParam.location : rangeAnchor.location;
	}
	
	NSRange lastPathRange	= NSMakeRange(0, len);
	return [url substringWithRange:lastPathRange];
}

-(NSString*)getNewspaperHomePageRelativePathFromOnlineUrl:(NSString*)url
{
	if (url == nil | [url length] == 0) {
		return nil;
	}
	
	NSString *newspaperPathFlag	= NEWSPAPER_PATH_FLAG;
	//找到报纸相对路径开始标记
	NSRange rangePathFlag	= [url rangeOfString:newspaperPathFlag options:NSCaseInsensitiveSearch];
	if (rangePathFlag.location == NSNotFound || rangePathFlag.location == ([url length] - 1)) {
		return nil;
	}
	else {
		url	= [url substringFromIndex:(rangePathFlag.location + [newspaperPathFlag length])];
	}
	
	NSInteger len	= 0;
	
	NSRange rangeParam	= [url rangeOfString:@"?"];
	NSRange rangeAnchor	= [url rangeOfString:@"#"];
	if (rangeParam.location == NSNotFound &&  rangeAnchor.location == NSNotFound) {
		len	= [url length];
	}
	else {
		len	= (rangeParam.location < rangeAnchor.location) ? rangeParam.location : rangeAnchor.location;
	}
	
	NSRange lastPathRange	= NSMakeRange(0, len);
	return [url substringWithRange:lastPathRange];
}

- (NSString *)getSingleNewspaperFolderPath:(NSString*)newspaperHomePagePath {
    if (!newspaperHomePagePath || [newspaperHomePagePath length] == 0) {
		return nil;
	}
    NSString *returnStr = [newspaperHomePagePath stringByDeletingLastPathComponent];
    if (returnStr) {
        returnStr = [returnStr stringByDeletingLastPathComponent];
    }
    
    return returnStr;
}

-(NSString*)getNewspaperFolderPathByHomePagePath:(NSString*)newspaperHomePagePath
{
	if (newspaperHomePagePath == nil || [newspaperHomePagePath length] == 0) {
		return nil;
	}
	
	NSString *newspaperCacheBasePath	= [self getNewspaperCachePath];
	if (newspaperCacheBasePath == nil || [newspaperCacheBasePath length] == 0) {
		SNDebugLog(@"getNewspaperFolderPathByHomePagePath : Empty newspaper cache base path");
		return nil;
	}
	
	NSRange rangeBasePath	= [newspaperHomePagePath rangeOfString:newspaperCacheBasePath];
	if (rangeBasePath.location == NSNotFound) {
		SNDebugLog(@"getNewspaperFolderPathByHomePagePath : Invaid newspaper path,home path = %@,base path = %@"
				   ,newspaperHomePagePath,newspaperCacheBasePath);
		return nil;
	}
	
	NSString *relativePath	= [newspaperHomePagePath substringFromIndex:rangeBasePath.location + rangeBasePath.length + 1];
	NSRange rangeFirstPath	= [relativePath rangeOfString:@"/"];
	if (rangeFirstPath.location == NSNotFound) {
		SNDebugLog(@"getNewspaperFolderPathByHomePagePath : Can't find relative path,home path = %@,base path = %@"
				   ,newspaperHomePagePath,newspaperCacheBasePath);
		return nil;
	}
	
	NSString *newspaperFolder	= [relativePath substringToIndex:rangeFirstPath.location];
	NSString *newspaperFolderPath	= [[self getNewspaperCachePath] stringByAppendingPathComponent:newspaperFolder];
	return newspaperFolderPath;
}


-(void)addSqlArgument:(NSString*)argument toArguments:(NSMutableArray*)arguments
{
	if (arguments == nil) {
		return;
	}
	
	if (argument != nil) {
		[arguments addObject:argument];
	}
	else {
		[arguments addObject:[NSNull null]];
	}
}

-(NSString*)generateCachePathByUrl:(NSString*)url basePath:(NSString*)basePath
{
	if (url == nil || [url length] == 0
		|| basePath == nil || [basePath length] == 0) {
		return nil;
	}
	
	NSString *fileName	= [url md5Hash];
	NSString *path = [basePath stringByAppendingPathComponent:fileName];
	return path;
}

@end
