//
//  SNPaymentStatusRequest.h
//  sohunews
//
//  Created by HuangZhen on 02/03/2017.
//  Copyright © 2017 Sohu.com. All rights reserved.
//

#import "SNBaseRequest.h"

@interface SNPaymentStatusRequest : SNBaseRequest<SNRequestProtocol>

@property(nonatomic, copy) NSString * orderId;

@end
