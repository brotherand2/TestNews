//
//  SNDownloadUtil.m
//  sohunews
//
//  Created by handy wang on 6/14/12.
//  Copyright (c) 2012 Sohu.com Inc. All rights reserved.
//

#import "SNDownloadUtil.h"
#import "SDWebImageDownloader.h"

@implementation SNDownloadUtil

+ (id)makeUncompressedJsonToObject:(NSData *)data {
    TTURLJSONResponse *_response = [[TTURLJSONResponse alloc] init];
    [_response request:nil processResponse:nil data:data];
    
    id _iRootObj = [_response rootObject];
    _response = nil;
    
    return _iRootObj;
}

// added by chh
// 下载图片
+ (void)downloadImageWithUrl:(NSString *)url {
    NSString *fileName = [[TTURLCache sharedCache] keyForURL:url];
    NSString *filePath = [[[TTURLCache sharedCache] cachePath] stringByAppendingPathComponent:fileName];

    BOOL isDir;
    if (![[NSFileManager defaultManager] fileExistsAtPath:filePath isDirectory:&isDir]) {
        [[SDWebImageDownloader sharedDownloader] downloadImageWithURL:[NSURL URLWithString:url] options:SDWebImageRetryFailed progress:nil completed:^(UIImage *image, NSData *data, NSError *error, BOOL finished) {
            if (finished && data) {
                [[NSFileManager defaultManager] createFileAtPath:filePath contents:data attributes:nil];
            }
        }];
    }
}

@end
