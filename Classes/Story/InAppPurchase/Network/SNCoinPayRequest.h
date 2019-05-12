//
//  SNCoinPayRequest.h
//  sohunews
//
//  Created by HuangZhen on 02/03/2017.
//  Copyright © 2017 Sohu.com. All rights reserved.
//

#import "SNBaseRequest.h"

@interface SNCoinPayRequest : SNBaseRequest<SNRequestProtocol>

@property (nonatomic, copy) NSString * bookId;

@property (nonatomic, copy) NSString * chapterIds;

@end
