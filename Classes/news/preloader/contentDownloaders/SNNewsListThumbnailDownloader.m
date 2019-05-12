//
//  SNNewsListThumbnailDownloader.m
//  sohunews
//
//  Created by jojo on 13-11-19.
//  Copyright (c) 2013年 Sohu.com. All rights reserved.
//

#import "SNNewsListThumbnailDownloader.h"
#import "UIImage+MultiFormat.h"
#import "SDWebImageManager.h"
#import "ASIHTTPRequest.h"

@interface SNNewsListThumbnailDownloader ()

@property (nonatomic, strong) ASIHTTPRequest *downloadReq;

@end

@implementation SNNewsListThumbnailDownloader
@synthesize imageUrl = _imageUrl;
@synthesize downloadReq = _downloadReq;

+ (id)downloader {
    SNNewsListThumbnailDownloader * selfDownloader = [super downloader];
    [selfDownloader setQueuePriority:NSOperationQueuePriorityVeryHigh];
    return selfDownloader;
}

- (void)main {
    [super main];
    
    if (self.imageUrl && ![[SNUtility getApplicationDelegate] shouldDownloadImagesManually]) {
        UIImage* cachedImage = [[TTURLCache sharedCache] imageForURL:self.imageUrl];
        if (!cachedImage) {
            // start download
            
            NSURL *url = [NSURL URLWithString:self.imageUrl];
            /*
            self.downloadReq = [ASIHTTPRequest requestWithURL:url];
            [self.downloadReq setDelegate:self];
            [self.downloadReq setTimeOutSeconds:30];
            [self.downloadReq startSynchronous];
            
            [self cacheImage:self.downloadReq];
            */
            // 改为SDWebImage 下载
            
            [[SDWebImageManager sharedManager] downloadImageWithURL:url options:SDWebImageRetryFailed progress:NULL completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, BOOL finished, NSURL *imageURL) {
                // do nothing
            }];
        }
        else {
//            SNDebugLog(@"image already cached !\n %@", self.imageUrl);
        }
    }
}

- (void)dealloc {
    if (self.downloadReq) {
        [self.downloadReq clearDelegatesAndCancel];
         //(_downloadReq);
    }
     //(_imageUrl);
}

- (void)cacheImage:(ASIHTTPRequest *)req {
    @autoreleasepool {
        NSData *imageData = req.responseData;
        NSString *URL = req.url.absoluteString;
        UIImage *image = [[TTURLCache sharedCache] imageForURL:URL fromDisk:NO];
        if (nil == image) {
            image = [UIImage sd_imageWithData:imageData];
            image = [UIImage rotateImage:image];
            
            if (image != nil) {
                //store to disk
                UIImage *diskImage = [[TTURLCache sharedCache] imageForURL:URL fromDisk:YES];
                if (nil == diskImage) {
                    [[TTURLCache sharedCache] storeData:imageData forURL:URL];
                }
                //store to memory
                [[TTURLCache sharedCache] storeImage:image forURL:URL];
            }
        }
    }
}

@end
