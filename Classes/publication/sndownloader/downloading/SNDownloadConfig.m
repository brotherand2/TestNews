//
//  FKDownloadConfig.m
//  FK
//
//  Created by handy wang on 6/11/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "SNDownloadConfig.h"
#import "TTURLCache.h"

@interface SNDownloadConfig()

/**
 * 当前应用程序的documents目录
 *
 * 目录结构: <Application_Home>/Documents/
 * 
 */
+ (NSString *)appDocumentsDir;

/**
 * 当前应用程序的临时目录
 *
 * Structure: <Application_Home>/tmp/
 */
+ (NSString *)appTemporaryDir;

/**
 * 当前应用程序的caches目录
 *
 * 目录结构: <Application_Home>/Library/Caches/
 * 
 */
+ (NSString *)appCachesDir;

/**
 * 如果指定目录在当前应用的目录结构中存在则返回存在的目录路径
 * 如果不存在指根据指定的目录路径创建目录
 */
+ (NSString *)createOrGetDirWithName:(NSString *)dirPathName;

@end


@implementation SNDownloadConfig

#pragma mark - Public methods implementation

+ (NSString *)downloadDestinationDir {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
    NSString *cachesPath = [paths objectAtIndex:0];
    NSString *_downloadDestinationDir = [[self class] createOrGetDirWithName:[cachesPath stringByAppendingPathComponent:@"Newspaper"]];
    return _downloadDestinationDir;
}

+ (NSString *)downloadDestinationPathWithURL:(NSString *)urlParam {
    NSString *_fileName = [[TTURLCache sharedCache] keyForURL:urlParam];
    NSString *_absolutePath = [[[self class] downloadDestinationDir] stringByAppendingPathComponent:_fileName];
    SNDebugLog(SN_String("INFO: %@--%@, zip file will be final download to path [%@]"), NSStringFromClass(self.class), NSStringFromSelector(_cmd), _absolutePath);
    return _absolutePath;
}

+ (NSString *)temporaryFileDownloadDir {
    NSString *_temporaryFileDownloadDir = [[self class] createOrGetDirWithName:[[TTURLCache sharedCache] cachePath]];
    return _temporaryFileDownloadDir;
}

+ (NSString *)temporaryFileDownloadPathWithURL:(NSString *)urlParam {
    NSString *_fileName = [[TTURLCache sharedCache] keyForURL:urlParam];
    NSString *_absolutePath = [[[self class] temporaryFileDownloadDir] stringByAppendingPathComponent:_fileName];
    SNDebugLog(SN_String("INFO: %@--%@, zip file will be temperory download to path [%@]"), NSStringFromClass(self.class), NSStringFromSelector(_cmd), _absolutePath);
    return _absolutePath;
}

+ (NSString *)rollingnewsImagesFileDownloadPathWithURL:(NSString *)urlParam {
    NSString *_fileName = [[TTURLCache sharedCache] keyForURL:urlParam];
    NSString *_absolutePath = [[[self class] temporaryFileDownloadDir] stringByAppendingPathComponent:_fileName];
    SNDebugLog(SN_String("===INFO:Image file will be download to path [%@]"), _absolutePath);
    return _absolutePath;
}


#pragma mark - Private methods implementation

/**
 * 当前应用程序的documents目录
 *
 * 目录结构: <Application_Home>/Documents/
 * 
 */
+ (NSString *)appDocumentsDir {
	
	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
	
	return [paths objectAtIndex:0];
}

/**
 * 当前应用程序的临时目录
 *
 * Structure: <Application_Home>/tmp/
 */
+ (NSString *)appTemporaryDir {
	return NSTemporaryDirectory();
}

/**
 * 当前应用程序的caches目录
 *
 * 目录结构: <Application_Home>/Library/Caches/
 * 
 */
+ (NSString *)appCachesDir {
	
	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
	
	return [paths objectAtIndex:0];
    
}

/**
 * 如果指定目录在当前应用的目录结构中存在则返回存在的目录路径
 * 如果不存在指根据指定的目录路径创建目录
 */
+ (NSString *)createOrGetDirWithName:(NSString *)dirPathName {
	
	NSFileManager *fileManager = [NSFileManager defaultManager];
	NSError *error = nil;
	
	if (![fileManager fileExistsAtPath:dirPathName]) {
		if(![fileManager createDirectoryAtPath:dirPathName withIntermediateDirectories:YES attributes:nil error:&error]) {
			SNDebugLog(@"ERROR: Failed to create dir path %@ with comming message %@ .", dirPathName,[error localizedDescription]);
		}
	}
	return	dirPathName;
}

@end
