//
//  SNPurchaseListRequest.h
//  sohunews
//
//  Created by HuangZhen on 02/03/2017.
//  Copyright © 2017 Sohu.com. All rights reserved.
//

#import "SNBaseRequest.h"

@interface SNPurchaseListRequest : SNBaseRequest<SNRequestProtocol>

@property (nonatomic, copy) NSString * cursor;

@end
