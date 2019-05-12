//
//  SNMobileLoginRequest.h
//  sohunews
//
//  Created by 李腾 on 2017/2/13.
//  Copyright © 2017年 Sohu.com. All rights reserved.
//

#import "SNHeaderScookieRequest.h"

@interface SNMobileLoginRequest : SNHeaderScookieRequest

- (instancetype)initWithDictionary:(NSDictionary *)dict andUrl:(NSString *)url;

@end
