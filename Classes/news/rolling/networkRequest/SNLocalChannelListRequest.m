//
//  SNLocalChannelListRequest.m
//  sohunews
//
//  Created by 李腾 on 2017/2/9.
//  Copyright © 2017年 Sohu.com. All rights reserved.
//

#import "SNLocalChannelListRequest.h"
#import "SNUserLocationManager.h"

@interface SNLocalChannelListRequest ()
@property (nonatomic, assign) BOOL isHousePro;
@end

@implementation SNLocalChannelListRequest

- (instancetype)initWithChannelId:(NSString *)channelId
{
    self = [super init];
    if (self) {
        self.isHousePro = [SNUserLocationManager isHouseProLocalTypeWithChannelId:channelId];
    }
    return self;
}

#pragma mark - SNRequestProtocol

- (SNRequestMethod)sn_requestMethod {
    return SNRequestMethodGet;
}

- (NSString *)sn_requestUrl {
    
    if (self.isHousePro) {
        return SNLinks_Path_Channel_HouseChannel;
    } else {
        return SNLinks_Path_Channel_LocalList;
    }
}

- (id)sn_parameters {
    
    return [super sn_parameters];
}

@end
