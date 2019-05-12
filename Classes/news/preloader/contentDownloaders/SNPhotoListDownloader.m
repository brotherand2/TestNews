//
//  SNPhotoListDownloader.m
//  sohunews
//
//  Created by jojo on 13-11-14.
//  Copyright (c) 2013年 Sohu.com. All rights reserved.
//

#import "SNPhotoListDownloader.h"

@implementation SNPhotoListDownloader
@synthesize channelId = _channelId;
@synthesize newsId = _newsId;
@synthesize downloadWorker = _downloadWorker;

- (void)dealloc {
     //(_channelId);
     //(_newsId);
     //(_downloadWorker);
}

- (void)main {
    [super main];
    
    if (self.channelId && self.newsId) {
        self.downloadWorker = [[SNChannelGroupPhotoNewsContentWorker alloc] init];
        [self.downloadWorker fetchGroupPhotoDataWithChannelId:self.channelId newsId:self.newsId];
    }
}

@end
