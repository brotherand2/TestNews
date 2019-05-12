//
//  SNGeneratePaymentIdRequest.h
//  sohunews
//
//  Created by HuangZhen on 02/03/2017.
//  Copyright © 2017 Sohu.com. All rights reserved.
//

#import "SNBaseRequest.h"

@interface SNGeneratePaymentIdRequest : SNBaseRequest<SNRequestProtocol>

/**
 产品id
 */
@property (nonatomic, copy) NSString * productId;

@end
