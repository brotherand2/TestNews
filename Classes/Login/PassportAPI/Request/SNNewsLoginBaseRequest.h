//
//  SNNewsLoginBaseRequest.h
//  sohunews
//
//  Created by wang shun on 2017/10/27.
//  Copyright © 2017年 Sohu.com. All rights reserved.
//

#import "SNBaseRequest.h"

#import "SNNewsPPLoginURLHeader.h" //URL表
#import "SNNewsPPLoginHeader.h"    //http header

@interface SNNewsLoginBaseRequest : SNBaseRequest<SNRequestProtocol>

@property (nonatomic,strong) NSString* ppjv;

- (instancetype)initWithDictionary:(NSDictionary *)dict PPJV:(NSString*)ppjv;

- (NSDictionary *)sn_requestHTTPHeader;

+ (NSString*)getSig:(NSDictionary*)dic;

@end
