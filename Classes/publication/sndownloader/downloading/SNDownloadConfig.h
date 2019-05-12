//
//  FKDownloadConfig.h
//  FK
//
//  Created by handy wang on 6/11/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum {
    SNDownloadWait,
    SNDownloadRunning,
    SNDownloadFail,
    SNDownloadSuccess,
    SNDownloadCancel
} SNDownloadStatus;

#define MaxConcurrentDownloadCount                                              (1)
#define HttpSucceededResponseStatusCode                                         (200)
#define kSNDownloaderAppearNotification                                         (@"kSNDownloaderAppearNotification")
#define kSNDownloaderDisappearNotification                                      (@"kSNDownloaderDisappearNotification")
#define kStatusBarMessageDuration                                               (2.0)
#define kToBeDownloadingData                                                    (@"kToBeDownloadingData")

@interface SNDownloadConfig : NSObject

+ (NSString *)downloadDestinationDir;

+ (NSString *)downloadDestinationPathWithURL:(NSString *)urlParam;

+ (NSString *)temporaryFileDownloadDir;

+ (NSString *)temporaryFileDownloadPathWithURL:(NSString *)urlParam;

+ (NSString *)rollingnewsImagesFileDownloadPathWithURL:(NSString *)urlParam;

@end