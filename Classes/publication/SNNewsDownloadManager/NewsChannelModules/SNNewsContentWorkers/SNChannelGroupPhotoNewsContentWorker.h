//
//  SNChannelGroupPhotoNewsContentWorker.h
//  sohunews
//
//  Created by handy wang on 1/10/13.
//  Copyright (c) 2013 Sohu.com Inc. All rights reserved.
//

#import "SNNewsContentWorker.h"

@interface SNChannelGroupPhotoNewsContentWorker : SNNewsContentWorker

- (void)fetchGroupPhotoDataWithChannelId:(NSString *)channelId newsId:(NSString *)newsId;

@end
