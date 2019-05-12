//
//  SNRollingGroupPhotoDataSource.h
//  sohunews
//
//  Created by Dan Cong on 10/26/13.
//  Copyright (c) 2013 Sohu.com. All rights reserved.
//

#import "SNPhotoDataSource.h"

@interface SNRollingGroupPhotoDataSource : SNPhotoDataSource
@property (nonatomic, weak) SNDragRefreshTableViewController *tableController;

- (id)initWithChannelId:(NSString *)channelId;

@end
