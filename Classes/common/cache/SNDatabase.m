
//  Created by ivan
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import "SNDatabase.h"
#import "CacheDefines.h"


#import "SNDatabase_Private.h"
#import "TBXML.h"
#import "UIDevice-Hardware.h"
#import "SNURLDataResponse.h"
#import "SNDBManager.h"

@interface SNDatabase (NetWork)

-(BOOL)onNewsZipDownloadFinished:(NewspaperZipRequestItem*)newspaperZipRequest;
-(void)onNewsZipDownloadFinishedInThread:(NewspaperZipRequestItem*)newspaperZipRequest;
-(BOOL)onPhotoDownloadFinished:(PhotoRequestItem*)photoRequest;
-(BOOL)onRecommendGalleryDownloadFinished:(RecommendGalleryRequestItem*)recommendGalleryRequest;

@end

@implementation SNDatabase
@synthesize isChangePushSetting = _isChangePushSetting;
@synthesize isChangeReadStatus = _isChangeReadStatus;

+ (FMDatabaseQueue *)readQueue
{
    static FMDatabaseQueue *_sharedQueue = nil;
    @synchronized(self) {
        if (!_sharedQueue) {
            [self checkDBFile];
            _sharedQueue = [FMDatabaseQueue databaseQueueWithPath:[self getDBFilePath]];
        }
    }
    return _sharedQueue;
}

+ (FMDatabaseQueue *)writeQueue
{
    static FMDatabaseQueue *_writeQueue = nil;
    @synchronized(self) {
        if (!_writeQueue) {
            [self checkDBFile];
            _writeQueue = [FMDatabaseQueue databaseQueueWithPath:[self getDBFilePath]];
        }
    }
    return _writeQueue;
}

+ (NSString *)getDBFilePath {
	NSArray  *paths                 = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
	NSString *documentsDirectory	= [paths objectAtIndex:0];
	NSString *dbFilePath            = [documentsDirectory stringByAppendingPathComponent:DB_FILE_NAME];
	return dbFilePath;
}

+ (BOOL)checkDBFile {
	NSFileManager *fm               = [NSFileManager defaultManager];
	NSString *writableDBPath		= [self getDBFilePath];
	if (![fm fileExistsAtPath:writableDBPath])
	{
		NSString *defaultDBPath	= [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:DB_FILE_NAME];
		NSError *error;
		if (![fm copyItemAtPath:defaultDBPath toPath:writableDBPath error:&error])
		{
			SNDebugLog(@"checkDBFile:recover DB file failed,error = %@",[error localizedDescription]);
			return NO;
		}
	}
	
	return YES;
}

- (id)init
{
    if (self = [super init]) {
        _UrlRequestAry = [[NSMutableArray alloc] init];
    }
    return self;
}
- (void)dealloc
{
    _UrlRequestAry = nil;
}



- (NSArray *)getObjects:(Class)clazz fromResultSet:(FMResultSet *)rs
{
    if (!rs) {
        return nil;
    }
    NSMutableArray *results = [NSMutableArray array];
    while ([rs next]) {
        id obj = [[clazz alloc] init];
        for (int i = 0 ; i< [rs columnCount]; i ++) {
            @autoreleasepool {
                NSString *columnName =  [rs columnNameForIndex:i];
                id value = [rs objectForColumnIndex:i];
                if (value != (id)[NSNull null]) {
                    [obj setValue:value forKey:columnName];
                }
            }
        }
        [results addObject:obj];
    }
    return results;
}

- (NSMutableArray *)getObjects:(Class)clazz fromResultSet:(FMResultSet *)rs limitCount:(NSInteger)maxCount
{
    if (!rs) {
        return nil;
    }
    NSMutableArray *results = [NSMutableArray array];
    NSInteger count = 0;
    while ([rs next]) {
        if (count>maxCount) {
            break;
        }
        id obj = [[clazz alloc] init];
        for (int i = 0 ; i< [rs columnCount]; i ++) {
            @autoreleasepool {
                NSString *columnName =  [rs columnNameForIndex:i];
                id value = [rs objectForColumnIndex:i];
                if (value != (id)[NSNull null]) {
                    [obj setValue:value forKey:columnName];
                }
            }
        }
        [results addObject:obj];
        count ++;
    }
    return results;
}



- (id)getFirstObject:(Class)clazz fromResultSet:(FMResultSet *)rs
{
    if (!rs) {
        return nil;
    }
    if ([rs next]) {
        id obj = [[clazz alloc] init];
        for (int i = 0 ; i< [rs columnCount]; i ++) {
            NSString *columnName =  [rs columnNameForIndex:i];
            id value = [rs objectForColumnIndex:i];
            if (value != (id)[NSNull null]) {
                [obj setValue:value forKey:columnName];
            }
        }
       return obj;
    }
    return nil;
}




- (void)addObserver:(id)observer {
	[self addObserver:observer forKeyPath:@"isChangePushSetting" options:(NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld) context:NULL];
}

- (void)deleteObserver:(id)observer {
	[self removeObserver:observer forKeyPath:@"isChangePushSetting"];
}

-(BOOL)isUrlBeingRequested:(NSString*)url
{
    if ([url length] == 0) {
		return NO;
	}
    
    @synchronized(self)
    {
        NSArray *arr = [NSArray arrayWithArray:_UrlRequestAry];
        for (CacheMgrURLRequest *request in arr) {
            if ([request.url isEqualToString:url]) {
                return YES;
            }
        }
    }
	
	return NO;
}

-(BOOL)setDelegate:(id)delegate ofUrl:(NSString*)url
{
    if ([url length] == 0) {
		return NO;
	}
    
    @synchronized(self)
    {
        NSArray *arr = [NSArray arrayWithArray:_UrlRequestAry];
        for (CacheMgrURLRequest *request in arr) {
            if ([request.url isEqualToString:url]) {
                request.urlRequestDelegate	= delegate;
                return YES;
            }
        }
    }
	
	return NO;
}

-(BOOL)cancelRequestByUrl:(NSString*)url
{
	if (url == nil || [url length] == 0) {
		return NO;
	}
    
    @synchronized(self)
    {
        NSArray *arr = [NSArray arrayWithArray:_UrlRequestAry];
        for (CacheMgrURLRequest *request in arr) {
            if ([request.url isEqualToString:url]) {
                [request cancel];
                return YES;
            }
        }
    }
	
	return NO;
}

-(NSString*)getCommonCachePath
{
	return [[TTURLCache sharedCache] cachePath];
}

-(float)getCacheTotalSize;
{
	NSString *cachePath	= [self getCacheBasePath];
	unsigned long long int cacheSize	= [UIDevice getFolderSize:cachePath];
    return cacheSize/(1024.0 * 1024.0);
}

-(float)getTTCacheSize
{
	NSString *cachePath	= [[TTURLCache sharedCache] cachePath];
	unsigned long long int cacheSize	= [UIDevice getFolderSize:cachePath];
    return cacheSize/(1024.0 * 1024.0);
}

//-(float)getFileSize:(NSString*)filePath
//{
//    NSFileManager *fm	= [NSFileManager defaultManager];
//    if (![fm fileExistsAtPath:filePath]) {
//        return 0;
//    }
//	
//    NSError *error = nil;
//    NSDictionary *dictionary = [fm attributesOfItemAtPath:filePath error: &error];
//    if (dictionary == nil ) {
//        return 0;
//    }
//    
//    NSNumber *fileSystemSizeInBytes = [dictionary objectForKey: NSFileSize];
//    float size = [fileSystemSizeInBytes floatValue];
//    return size;
//}

+(void)deleteAndUseDefaultSqliteFile {
    NSFileManager *fm	= [NSFileManager defaultManager];
	NSString *writableDBPath		= [SNDatabase getDBFilePath];
    
    NSString *defaultDBPath	= [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:DB_FILE_NAME];
    NSError *error;
    
    if ([fm fileExistsAtPath:writableDBPath]) {
        [fm removeItemAtPath:writableDBPath error:&error];
    }
    
    if (![fm copyItemAtPath:defaultDBPath toPath:writableDBPath error:&error])
    {
        SNDebugLog(@"checkDBFile:recover DB file failed,error = %@",[error localizedDescription]);
    }
}

-(BOOL)clearAllCache
{
	if (![self clearNewsArticleList]) {
		SNDebugLog(@"clearAllCache : clearNewsArticleList failed");
	}
    
    if (![self clearGalleryList]) {
        SNDebugLog(@"clearAllCache : clearGalleryList failed");
    }
    
    if (![self clearRollingNewsList]) {
        SNDebugLog(@"clearAllCache : clearRollingNewsList failed");
    }
    
    if (![self clearGroupPhotoList]) {
        SNDebugLog(@"clearAllCache : clearGroupPhotoList failed");
    }

    if (![self clearCommentJson]) {
        SNDebugLog(@"clearAllCache : clearCommentJson failed");
    }
    
    if (![self clearSpecialNewsList]) {
        SNDebugLog(@"clearAllCache : clearSpecialNewsList failed");
    }

    if (![self clearLivingGames]) {
        SNDebugLog(@"clearAllCache : clearLivingGames failed");
    }
    
    if (![self clearAllWeiboHotItems]) {
        SNDebugLog(@"clearAllCache : clearAllWeiboHotItems failed");
    }
    
    if (![self clearWeiboHotDetail]) {
        SNDebugLog(@"clearAllCache : clearWeiboHotDetail failed");
    }
    
    if (![self clearWeiboComment]) {
        SNDebugLog(@"clearAllCache : clearWeiboComment failed");
    }
    
    if (![self clearAllTimelineOriginObjs]) {
        SNDebugLog(@"clearAllCache : clearAllTimelineOriginObjs failed");
    }
    
    if (![self clearAllTimelineObjs]) {
        SNDebugLog(@"clearAllCache : clearAllTimelineObjs failed");
    }
    
    if (![self removeAllLink2]) {
        SNDebugLog(@"clearAllCache : removeAllLink2 failed");
    }
    
    if (![self clearVideoTimeLineList]) {
        SNDebugLog(@"clearAllCache : clearVideoTimeLineList failed");
    }
	if (![self clearVideoBreakpointList])
    {
        SNDebugLog(@"clearAllCache : clearVideoBreakpointList failed");
    }
    
    // 4.0 广告 by jojo
    // 清理及时新闻列表缓存的广告定向数据
    if (![self adInfoClearAdInfosByType:SNAdInfoTypeChannelBanner]) {
		SNDebugLog(@"clearAllCache : clear article adinfos failed");
    }
    // 清理组图新闻缓存的广告定向数据
    if (![self adInfoClearAdInfosByType:SNAdInfoTypePhotoListNews]) {
		SNDebugLog(@"clearAllCache : clear photolist adinfos failed");
    }
    // 删除新闻缓存的广告定向回传数据
    if (![self adInfoClearAdInfosByType:SNAdInfoTypeArticle]) {
		SNDebugLog(@"clearAllCache : clear channel adinfos failed");
    }

    if (![self clearAllLiveInviteItems]) {
        SNDebugLog(@"clearAllCache : clear live invite failed");
    }
    
	return YES;
}


#pragma mark -
#pragma mark TTURLRequestDelegate
- (void)requestDidStartLoad:(TTURLRequest*)request {
	CacheMgrURLRequest *urlRequest	= (CacheMgrURLRequest*)request;
	
	SNDebugLog(@"CacheMgr - requestDidStartLoad,Url = %@",request.urlPath);
	
	if (urlRequest.urlRequestDelegate && [urlRequest.urlRequestDelegate respondsToSelector:@selector(requestDidStartLoad:)])
	{
		[urlRequest.urlRequestDelegate requestDidStartLoad:urlRequest.url];
	}
}

- (void)requestDidUploadData:(TTURLRequest*)request
{
	SNDebugLog(@"CacheMgr - requestDidUploadData...");
}

- (void)request:(TTURLRequest*)request didReceiveAuthenticationChallenge:(NSURLAuthenticationChallenge*)challenge
{
	SNDebugLog(@"CacheMgr - request didReceiveAuthenticationChallenge...");
}

- (void)requestDidCancelLoad:(TTURLRequest*)request
{
	SNDebugLog(@"CacheMgr - requestDidCancelLoad:Url=%@", [request urlPath]);
	
	CacheMgrURLRequest *cacheRequest	= (CacheMgrURLRequest*)request;
	if (cacheRequest.urlRequestDelegate && [cacheRequest.urlRequestDelegate respondsToSelector:@selector(requestDidCancelLoad:)])
	{
		[cacheRequest.urlRequestDelegate requestDidCancelLoad:cacheRequest.url];
	}
		
	//从下载任务列表中清除
	[_UrlRequestAry removeObject:cacheRequest];
}

- (void)removeDelegatesForURL:(NSString *)url
{
    if (!url && ![url isKindOfClass:[NSString class]]) {
        return;
    }
    
    NSMutableArray *delegates = [_imgDownloadDelegates objectForKey:url];
    
    if (delegates && [delegates isKindOfClass:[NSArray class]]) {
        [_imgDownloadDelegates removeObjectForKey:url];
        SNDebugLog(@"removeDelegatesForURL:%@", url);
    }
    
}

- (void)requestDidFinishLoad:(TTURLRequest*)request {
	
	SNDebugLog(@"CacheMgr - requestDidFinishLoad...");
	BOOL bHandleSucceed	= NO;
    BOOL bCancelled = NO;
    if ([request isKindOfClass:[SNURLRequest class]]) {
        bCancelled = [(SNURLRequest *)request isCancelled];
    }
    
    BOOL unzipOfflineNewspaperFailed = NO;
	CacheMgrURLRequest *cacheRequest	= (CacheMgrURLRequest*)request;
	switch (cacheRequest.nRequestType) {
			//新闻zip包
		case CacheMgrURLRequestTypeNewspaperZip:
        {
            if (!bCancelled) {
                //Modified by handy, 为了让解压不阻塞UI，所以在线程里解压；
                bHandleSucceed = [self onNewsZipDownloadFinished:(NewspaperZipRequestItem*)cacheRequest];
                if (!bHandleSucceed) {
                    unzipOfflineNewspaperFailed = YES;
                }
                //                    [NSThread detachNewThreadSelector:@selector(onNewsZipDownloadFinishedInThread:) toTarget:self withObject:(NewspaperZipRequestItem*)cacheRequest];
                //                    return;
            }
            else {
                bHandleSucceed = YES;
            }
        }
			break;
            //组图图片
        case CacheMgrURLRequestTypeGalleryPhoto:
        {
            if (!bCancelled) {
                bHandleSucceed = [self onPhotoDownloadFinished:(PhotoRequestItem*)cacheRequest];
            }
            else {
                bHandleSucceed = YES;
            }
        }
            break;
        case CacheMgrURLRequestTypeRecommendGallery:
        {
            if (!bCancelled) {
                bHandleSucceed = [self onRecommendGalleryDownloadFinished:(RecommendGalleryRequestItem*)cacheRequest];
            }
            else {
                bHandleSucceed = YES;
            }
        }
            break;
		default:
			break;
	}
	
    
    //对组图图片下载的所有并发的delegate进行回调
    if (CacheMgrURLRequestTypeGalleryPhoto == cacheRequest.nRequestType) {
        
        SEL selector = nil;
        
        if (bCancelled) {
            selector = @selector(requestDidCancelLoad:);
        } else if (bHandleSucceed) {
            selector = @selector(requestDidFinishLoad:);
        } else if (!bHandleSucceed) {
            selector = @selector(request:didFailLoadWithError:);
        }
        
        NSArray *arr = [NSArray arrayWithArray:[_imgDownloadDelegates objectForKey:cacheRequest.url]];
        for (id deleg in arr) {
            if ([deleg respondsToSelector:selector])
            {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
                if (selector == @selector(request:didFailLoadWithError:)) {
                    NSError *error	= [[NSError alloc] initWithDomain:@"Invalid file" code:0 userInfo:nil];
                    [deleg performSelector:selector withObject:cacheRequest.url withObject:error];
                } else {
                    [deleg performSelector:selector withObject:cacheRequest.url];
                }
#pragma clang diagnostic pop
            }
        }
        
        [self removeDelegatesForURL:cacheRequest.url];
        
    }
    //对单个delegate回调
    else {
        
        if (bCancelled) {
            [self requestDidCancelLoad:request];
            
        } else if (bHandleSucceed) {
            SNDebugLog(@"CacheMgr - requestDidFinishLoad succeed");
            
            if (cacheRequest.urlRequestDelegate && [cacheRequest.urlRequestDelegate respondsToSelector:@selector(requestDidFinishLoad:)])
            {
                [cacheRequest.urlRequestDelegate requestDidFinishLoad:cacheRequest.url];
            }
        } else if (!bHandleSucceed) {
            SNDebugLog(@"CacheMgr - requestDidFinishLoad fail");
            
            if (cacheRequest.urlRequestDelegate && [cacheRequest.urlRequestDelegate respondsToSelector:@selector(request:didFailLoadWithError:)])
            {
                if (!unzipOfflineNewspaperFailed) {
                    NSError *error	= [[NSError alloc] initWithDomain:@"Invalid file"
                                                                 code:0
                                                             userInfo:nil];
                    [cacheRequest.urlRequestDelegate request:cacheRequest.url didFailLoadWithError:error];
                } else {
                    //unzipOfflineNewspaperFailed = NO;
                    NSError *error	= [[NSError alloc] initWithDomain:@"Failed to Unzip news zip file."
                                                                 code:kCORRUPTED_PACKAGE_ERROR_CODE
                                                             userInfo:nil];
                    [cacheRequest.urlRequestDelegate request:cacheRequest.url didFailLoadWithError:error];
                }
            }
        }
        
    }
	
	
	//从下载任务列表中清除
	[_UrlRequestAry removeObject:cacheRequest];
}

- (void)request:(TTURLRequest*)request didFailLoadWithError:(NSError*)error {
	SNDebugLog(@"CacheMgr - didFailLoadWithError:%d,%@,Url=%@",[error code],[error localizedDescription],[request urlPath]);
	
	CacheMgrURLRequest *cacheRequest	= (CacheMgrURLRequest*)request;
	switch (cacheRequest.nRequestType) {
		case CacheMgrURLRequestTypeNewspaperZip:
        {
            if (cacheRequest.nRetryCount++ < 3) {
                [cacheRequest performSelector:@selector(send) withObject:nil afterDelay:2];
                SNDebugLog(@"CacheMgr - didFailLoadWithError: Download newspaper zip failed,retry in 2s,retry count = %d",cacheRequest.nRetryCount);
                return;
            } else {
                NSInteger _responseErrorCode = [error code];
                if (_responseErrorCode == kNOT_FOUND_PACKAGE_IN_SERVER_ERROR_CODE) {
                    error = [NSError errorWithDomain:error.domain code:kNOT_FOUND_PACKAGE_IN_SERVER_ERROR_CODE userInfo:error.userInfo];
                }
            }
        }
			break;
        case CacheMgrURLRequestTypeRecommendGallery:
        case CacheMgrURLRequestTypeGalleryPhoto:
        {
            //去掉组图图片下载失败的重试，容易死循环。
            //            if (cacheRequest.nRetryCount++ < 2) {
            //                [cacheRequest performSelector:@selector(send) withObject:nil afterDelay:0.5];
            //                SNDebugLog(@"CacheMgr - didFailLoadWithError: Download photo failed,retry count = %d",cacheRequest.nRetryCount);
            //                return;
            //            }
        }
            break;
		default:
			break;
	}
	
	if (cacheRequest.urlRequestDelegate && [cacheRequest.urlRequestDelegate respondsToSelector:@selector(request:didFailLoadWithError:)])
	{
		[cacheRequest.urlRequestDelegate request:cacheRequest.url didFailLoadWithError:error];
	}
	//从下载任务列表中清除
	[_UrlRequestAry removeObject:cacheRequest];
}

-(BOOL)onNewsZipDownloadFinished:(NewspaperZipRequestItem*)newspaperZipRequest
{
#ifndef DOWNLOAD_INTO_MEMORY
    NSString* filePath = [[TTURLCache sharedCache] cachePathForURL:newspaperZipRequest.urlPath];
    SNDebugLog(SN_String("INFO: onNewsZipDownloadFinished, Url path is %@, download into path:%@, copy to path: %@"), newspaperZipRequest.urlPath, filePath, newspaperZipRequest.path);
    if (filePath && [[NSFileManager defaultManager] fileExistsAtPath:filePath]) {
        [[NSFileManager defaultManager] removeItemAtPath:newspaperZipRequest.path error:nil];
        [[NSFileManager defaultManager] moveItemAtPath:filePath toPath:newspaperZipRequest.path error:nil];
    }
#else
    SNURLDataResponse *response	= (SNURLDataResponse*)newspaperZipRequest.response;
	NSData *zipData	= response.data;

	
	
	SNDebugLog(@"onNewsZipDownloadFinished : Download finished,size=%d,url=%@,begin to unzip"
			   ,zipData.length, newspaperZipRequest.url);
	//ZIP包存文件
	if (![zipData writeToFile:newspaperZipRequest.path atomically:YES])
	{
		SNDebugLog(@"onNewsZipDownloadFinished : zipData write to file failed,path=%@",newspaperZipRequest.path);
		//从下载任务列表中清除
		[_UrlRequestAry removeObject:newspaperZipRequest];
		return NO;
	}
#endif
	NSString *newspaperHomePagePath	= nil;
	//ZIP包解压缩
	ZipArchive *zip	= [[ZipArchive alloc] init];
	zip.delegate	= self;
	zip.needUnzipProcessNotify	= YES;
	_newspaperHomePagePath	= nil;
    NSFileManager *fm	= [NSFileManager defaultManager];
    NSError *error	= nil;
	if ([zip UnzipOpenFile:newspaperZipRequest.path]) {
		NSString *newspaperCachePath	= [self getNewspaperCachePath];
		if ([zip UnzipFileTo:newspaperCachePath overWrite:YES]) {
			
			//解压成功之后，找到新闻主页
            //			NSString *newspaperHomePageRelativePath	= [self getNewspaperHomePageRelativePathFromOnlineUrl:newspaperZipRequest.newspaperInfo.termLink];
            //			if (newspaperHomePageRelativePath == nil || [newspaperHomePageRelativePath length] == 0) {
            //				SNDebugLog(@"onNewsZipDownloadFinished : Can't find newspaper home page from Online url,%@",newspaperZipRequest.newspaperInfo.termLink);
            //			}
            //			else {
            //				NSString *newspaperCacheFolder	= [self getNewspaperCachePath];
            //				newspaperHomePagePath = [newspaperCacheFolder stringByAppendingPathComponent:newspaperHomePageRelativePath];
            //				//判断根据规则拼接的报纸首页是否有效
            //				if (![fm fileExistsAtPath:newspaperHomePagePath]) {
            //					SNDebugLog(@"onNewsZipDownloadFinished : Invalid newspaper home page,%@",newspaperHomePagePath);
            //				}
            //			}
			
			if ([_newspaperHomePagePath length] != 0) {
				NSString *newspaperCacheFolder	= [self getNewspaperCachePath];
				newspaperHomePagePath = [newspaperCacheFolder stringByAppendingPathComponent:_newspaperHomePagePath];
				//判断根据规则拼接的报纸首页是否有效
				if (![fm fileExistsAtPath:newspaperHomePagePath]) {
					SNDebugLog(@"onNewsZipDownloadFinished : Invalid newspaper home page,%@",newspaperHomePagePath);
				}
			}
		}
		//解压失败
		else {
			SNDebugLog(@"onNewsZipDownloadFinished : Unzip zip file failed,zipPath = %@,UnZipPath = %@"
                       ,newspaperZipRequest.path,newspaperCachePath);
		}
        //删除zip包
        if (![fm removeItemAtPath:newspaperZipRequest.path error:&error]) {
            SNDebugLog(@"onNewsZipDownloadFinished : delete Zip file failed,%d,%@,zipPath=%@"
                       ,[error code],[error localizedDescription],newspaperZipRequest.path);
        }
		[zip UnzipCloseFile];
	}
	else {
		SNDebugLog(@"onNewsZipDownloadFinished : Open zip file failed,path = %@",newspaperZipRequest.path);
        if (![fm removeItemAtPath:newspaperZipRequest.path error:&error]) {
            SNDebugLog(@"onNewsZipDownloadFinished : delete Zip file failed,%d,%@,zipPath=%@"
                       ,[error code],[error localizedDescription],newspaperZipRequest.path);
        }
	}
	
	
	if ([newspaperHomePagePath length] == 0) {
        SNDebugLog(@"INFO: Failed to unzip file.");
		return NO;
	}
    
	//更新数据库
	NSMutableDictionary *valuePairs	= [[NSMutableDictionary alloc] init];
	//重置已下载标记
	[valuePairs setObject:@"1" forKey:TB_NEWSPAPER_DOWNLOADFLAG];
	//zip包解压后的目录地址
	[valuePairs setObject:newspaperHomePagePath forKey:TB_NEWSPAPER_NEWSPAPERPATH];
    [valuePairs setObject:[NSDate date] forKey:TB_NEWSPAPER_DOWNLOADTIME];
    SNDebugLog(@"downloadTime:%@", [NSDate date]);
	//更新至数据库
	[self updateNewspaperByTermId:newspaperZipRequest.newspaperInfo.termId withValuePairs:valuePairs addIfNotExist:NO];
	return YES;
	
}

- (void)didFinishLoadBackToMainThread:(NSMutableDictionary *)dic {
    id<SNDatabaseRequestDelegate> requestDelegate = (id<SNDatabaseRequestDelegate>)[dic objectForKey:@"requestDelegate"];
    NSString *_requestURL = [dic objectForKey:@"requestURL"];
    if (requestDelegate && [requestDelegate respondsToSelector:@selector(requestDidFinishLoad:)]) {
        [requestDelegate requestDidFinishLoad:_requestURL];
    }
    dic = nil;
}

- (void)didFailLoadWithErrorBackToMainThread:(NSMutableDictionary *)dic {
    id<SNDatabaseRequestDelegate> requestDelegate = (id<SNDatabaseRequestDelegate>)[dic objectForKey:@"requestDelegate"];
    NSString *_requestURL = [dic objectForKey:@"requestURL"];
    NSError *_error = [dic objectForKey:@"error"];
    if (requestDelegate && [requestDelegate respondsToSelector:@selector(request:didFailLoadWithError:)]) {
        [requestDelegate request:_requestURL didFailLoadWithError:_error];
    }
    dic = nil;
}

-(void)onNewsZipDownloadFinishedInThread:(NewspaperZipRequestItem*)newspaperZipRequest {
    NSString* filePath = [[TTURLCache sharedCache] cachePathForURL:newspaperZipRequest.urlPath];
    if (filePath && [[NSFileManager defaultManager] fileExistsAtPath:filePath]) {
        [[NSFileManager defaultManager] removeItemAtPath:newspaperZipRequest.path error:nil];
        [[NSFileManager defaultManager] moveItemAtPath:filePath toPath:newspaperZipRequest.path error:nil];
    }
	
	NSString *newspaperHomePagePath	= nil;
	//ZIP包解压缩
	ZipArchive *zip	= [[ZipArchive alloc] init];
	zip.delegate	= self;
	zip.needUnzipProcessNotify	= YES;
	_newspaperHomePagePath	= nil;
    NSFileManager *fm	= [NSFileManager defaultManager];
    NSError *error	= nil;
	if ([zip UnzipOpenFile:newspaperZipRequest.path]) {
		NSString *newspaperCachePath	= [self getNewspaperCachePath];
		if ([zip UnzipFileTo:newspaperCachePath overWrite:YES]) {
			if ([_newspaperHomePagePath length] != 0) {
				NSString *newspaperCacheFolder	= [self getNewspaperCachePath];
				newspaperHomePagePath = [newspaperCacheFolder stringByAppendingPathComponent:_newspaperHomePagePath];
				//判断根据规则拼接的报纸首页是否有效
				if (![fm fileExistsAtPath:newspaperHomePagePath]) {
					SNDebugLog(@"onNewsZipDownloadFinished : Invalid newspaper home page,%@",newspaperHomePagePath);
				}
			}
		}
		//解压失败
		else {
			SNDebugLog(@"onNewsZipDownloadFinished : Unzip zip file failed,zipPath = %@,UnZipPath = %@"
                       ,newspaperZipRequest.path,newspaperCachePath);
		}
        //删除zip包
        if (![fm removeItemAtPath:newspaperZipRequest.path error:&error]) {
            SNDebugLog(@"onNewsZipDownloadFinished : delete Zip file failed,%d,%@,zipPath=%@"
                       ,[error code],[error localizedDescription],newspaperZipRequest.path);
        }
		[zip UnzipCloseFile];
	}
	else {
		SNDebugLog(@"onNewsZipDownloadFinished : Open zip file failed,path = %@",newspaperZipRequest.path);
        if (![fm removeItemAtPath:newspaperZipRequest.path error:&error]) {
            SNDebugLog(@"onNewsZipDownloadFinished : delete Zip file failed,%d,%@,zipPath=%@"
                       ,[error code],[error localizedDescription],newspaperZipRequest.path);
        }
	}
	
	
	if ([newspaperHomePagePath length] == 0) {
        //---回调失败的delegate
        SNDebugLog(@"ERROR: %@--%@, ", NSStringFromClass(self.class), NSStringFromSelector(_cmd));
        if (newspaperZipRequest.urlRequestDelegate && [newspaperZipRequest.urlRequestDelegate respondsToSelector:@selector(request:didFailLoadWithError:)]) {
            NSError *error	= [[NSError alloc] initWithDomain:@"Invalid file"
                                                         code:0
                                                     userInfo:nil];
            if (newspaperZipRequest.urlRequestDelegate) {
                NSMutableDictionary *_params = [[NSMutableDictionary alloc] init];
                [_params setObject:newspaperZipRequest.urlRequestDelegate forKey:@"requestDelegate"];
                [_params setObject:newspaperZipRequest.url forKey:@"requestURL"];
                [_params setObject:error forKey:@"error"];
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self didFailLoadWithErrorBackToMainThread:_params];
                });
//                [self performSelectorOnMainThread:@selector(didFailLoadWithErrorBackToMainThread:) withObject:_params waitUntilDone:NO modes:[NSArray arrayWithObject:NSRunLoopCommonModes]];
            }
        }
        //从下载任务列表中清除
        [_UrlRequestAry removeObject:newspaperZipRequest];
		return;
        //---
	}
    
	//更新数据库
	NSMutableDictionary *valuePairs	= [[NSMutableDictionary alloc] init];
	//重置已下载标记
	[valuePairs setObject:@"1" forKey:TB_NEWSPAPER_DOWNLOADFLAG];
	//zip包解压后的目录地址
	[valuePairs setObject:newspaperHomePagePath forKey:TB_NEWSPAPER_NEWSPAPERPATH];
    [valuePairs setObject:[NSDate date] forKey:TB_NEWSPAPER_DOWNLOADTIME];
    SNDebugLog(@"downloadTime:%@", [NSDate date]);
	//更新至数据库
	[self updateNewspaperByTermId:newspaperZipRequest.newspaperInfo.termId withValuePairs:valuePairs addIfNotExist:NO];
    
    SNDebugLog(@"CacheMgr - requestDidFinishLoad succeed");
    
    //---回调成功的delegate
    if (newspaperZipRequest.urlRequestDelegate) {
        NSMutableDictionary *_params = [[NSMutableDictionary alloc] init];
        [_params setObject:newspaperZipRequest.urlRequestDelegate forKey:@"requestDelegate"];
        [_params setObject:newspaperZipRequest.url forKey:@"requestURL"];
        dispatch_async(dispatch_get_main_queue(), ^{
            [self didFinishLoadBackToMainThread:_params];
        });
//        [self performSelectorOnMainThread:@selector(didFinishLoadBackToMainThread:) withObject:_params waitUntilDone:NO modes:[NSArray arrayWithObject:NSRunLoopCommonModes]];
        //从下载任务列表中清除
        [_UrlRequestAry removeObject:newspaperZipRequest];
    }
    //---
}

-(BOOL)onPhotoDownloadFinished:(PhotoRequestItem*)photoRequest
{
    PhotoItem *photo	= photoRequest.photoInfo;
	//上层的封装可能会对请求的url作诸如增加参数这类的改变，因此，在请求完成之后用url生成本地路径试比较准确的做法
	photo.path	= [[self getCommonCachePath] stringByAppendingPathComponent:
                   [[TTURLCache sharedCache] keyForURL:photoRequest.urlPath]];
    
    return [self addSinglePhoto:photo updateIfExist:YES];
}

-(BOOL)onRecommendGalleryDownloadFinished:(RecommendGalleryRequestItem*)recommendGalleryRequest
{
    RecommendGallery *recommendGallery  = recommendGalleryRequest.recommendGalleryInfo;
    recommendGallery.iconPath   = [[self getCommonCachePath] stringByAppendingPathComponent:
                                   [[TTURLCache sharedCache] keyForURL:recommendGalleryRequest.urlPath]];
    
    return [self addSingleRecommendGallery:recommendGallery updateIfExist:YES];
}

#pragma mark -
#pragma mark ZipArchiveDelegate
-(void) FileUnzipped:(NSString*)filePath fromZipArchive:(ZipArchive*)zip
{
	if ([filePath length] == 0 || zip == nil) {
		return;
	}
	
	if ([filePath rangeOfString:kNewspaperHomePageFlag].location != NSNotFound) {
		_newspaperHomePagePath	= filePath;
	}
}

-(void) ErrorMessage:(NSString*) msg {
    SNDebugLog(SN_String("ERROR: !!!!!!!!!!!!!!!!!!!!!! unzip file error : %@"), msg);
}

@end



