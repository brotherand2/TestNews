//
//  SNRollingNewsConst.h
//  sohunews
//
//  Created by handy wang on 5/28/14.
//  Copyright (c) 2014 Sohu.com. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger, SNRollingNewsVideoPosition) {
    SNRollingNewsVideoPosition_Unknown,
    SNRollingNewsVideoPosition_RecommVideoLink2,
    SNRollingNewsVideoPosition_RecommVideoNews,
    SNRollingNewsVideoPosition_NormalVideoLink2,
    SNRollingNewsVideoPosition_NormalVideoNews
};

static NSString *const kRollingNewsVideoPosition = @"kRollingNewsVideoPosition";