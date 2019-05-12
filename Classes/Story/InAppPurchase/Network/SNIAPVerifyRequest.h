//
//  SNIAPVerifyRequest.h
//  sohunews
//
//  Created by HuangZhen on 02/03/2017.
//  Copyright © 2017 Sohu.com. All rights reserved.
//

#import "SNBaseRequest.h"

@interface SNIAPVerifyRequest : SNBaseRequest<SNRequestProtocol>

@property (nonatomic, copy) NSString * transactionId;

@property (nonatomic, strong) NSData * receipt;

@end
