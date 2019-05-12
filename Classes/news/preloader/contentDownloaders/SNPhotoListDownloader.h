//
//  SNPhotoListDownloader.h
//  sohunews
//
//  Created by jojo on 13-11-14.
//  Copyright (c) 2013年 Sohu.com. All rights reserved.
//

#import "SNContentDownloader.h"
#import "SNChannelGroupPhotoNewsContentWorker.h"

@interface SNPhotoListDownloader : SNContentDownloader

@property (nonatomic, copy) NSString *channelId;
@property (nonatomic, copy) NSString *newsId;
@property (nonatomic, strong) SNChannelGroupPhotoNewsContentWorker *downloadWorker;

@end
