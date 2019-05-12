//
//  SNSohuHaoChannelContentRequest.h
//  sohunews
//
//  Created by HuangZhen on 2017/6/12.
//  Copyright © 2017年 Sohu.com. All rights reserved.
//

#import "SNBaseRequest.h"

@interface SNSohuHaoChannelContentRequest : SNBaseRequest<SNRequestProtocol>

@property (nonatomic, copy) NSString * channelId;
@property (nonatomic, copy) NSString * page;

@end
