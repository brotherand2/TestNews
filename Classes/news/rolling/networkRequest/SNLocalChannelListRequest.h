//
//  SNLocalChannelListRequest.h
//  sohunews
//
//  Created by 李腾 on 2017/2/9.
//  Copyright © 2017年 Sohu.com. All rights reserved.
//

#import "SNDefaultParamsRequest.h"

@interface SNLocalChannelListRequest : SNDefaultParamsRequest

- (instancetype)initWithChannelId:(NSString *)channelId;

@end
