//
//  SNCheckFollowRequest.h
//  sohunews
//
//  Created by HuangZhen on 2017/5/10.
//  Copyright © 2017年 Sohu.com. All rights reserved.
//

#import "SNBaseRequest.h"

@interface SNCheckFollowRequest : SNBaseRequest<SNRequestProtocol>

@property (nonatomic, copy) NSString * subId;

@end
