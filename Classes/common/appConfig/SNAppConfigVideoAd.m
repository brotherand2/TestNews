//
//  SNAppConfigVideoAd.m
//  sohunews
//
//  Created by handy wang on 5/14/14.
//  Copyright (c) 2014 Sohu.com. All rights reserved.
//

#import "SNAppConfigVideoAd.h"

static NSString *const keyIsAppVideoAdvOn               = @"smc.client.videoAdv.isOpen";
static NSString *const keyNewsChannelIDsOfVideoAdvOn    = @"smc.client.videoAdv.isOpen.newsChannels";
static NSString *const keyVideoChannelIDsOfVideoAdvOn   = @"smc.client.videoAdv.isOpen.videoChannels";
static NSString *const keySubIDsOfVideoAdOn             = @"smc.client.videoAdv.isOpen.subIds";

@implementation SNAppConfigVideoAd

- (void)updateWithDic:(NSDictionary *)configDic {
    self.isAppVideoAdvOn = [configDic[keyIsAppVideoAdvOn] isEqualToString:@"1"] ? YES : NO;
    self.newsChannelIDsOfVideoAdvOn = [configDic[keyNewsChannelIDsOfVideoAdvOn] componentsSeparatedByString:@","];
    self.videoChannelIDsOfVideoAdvOn = [configDic[keyVideoChannelIDsOfVideoAdvOn] componentsSeparatedByString:@","];
    self.subIDsOfVideoOn = [configDic[keySubIDsOfVideoAdOn] componentsSeparatedByString:@","];
}

- (NSString *)description {
    NSString *isAppVideoAdvOn = [NSString stringWithFormat:@"%d", _isAppVideoAdvOn];
    NSString *newsChannelIDs = [_newsChannelIDsOfVideoAdvOn componentsJoinedByString:@","];
    NSString *videoChannelIDs = [_videoChannelIDsOfVideoAdvOn componentsJoinedByString:@","];
    NSString *subIDs = [_subIDsOfVideoOn componentsJoinedByString:@","];
    
    NSDictionary *desc = @{keyIsAppVideoAdvOn:(isAppVideoAdvOn ?: @""),
                           keyNewsChannelIDsOfVideoAdvOn:(newsChannelIDs.length > 0 ? newsChannelIDs : @""),
                           keyVideoChannelIDsOfVideoAdvOn:(videoChannelIDs.length > 0 ? videoChannelIDs : @""),
                           keySubIDsOfVideoAdOn:(subIDs.length > 0 ? subIDs : @"")
                           };
    return [desc description];
}

- (void)dealloc {
    _isAppVideoAdvOn = NO;
    
    
    
    
}

@end
