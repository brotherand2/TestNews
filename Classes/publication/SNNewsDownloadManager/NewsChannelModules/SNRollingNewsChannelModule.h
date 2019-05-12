//
//  SNRollingNewsChannelModule.h
//  sohunews
//
//  Created by handy wang on 1/8/13.
//  Copyright (c) 2013 Sohu.com Inc. All rights reserved.
//

#import "SNNewsChannelModule.h"

@interface SNRollingNewsChannelModule : SNNewsChannelModule {
    NSInteger _totalDownloadCount;
    SNASIRequest *_rollingNewsRequest;
}

@end
