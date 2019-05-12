//
//  SNShareV4UploadRequest.h
//  sohunews
//
//  Created by 李腾 on 2017/1/23.
//  Copyright © 2017年 Sohu.com. All rights reserved.
//

#import "SNBaseRequest.h"

@interface SNShareV4UploadRequest : SNBaseRequest <SNRequestProtocol>

- (instancetype)initWithDictionary:(NSDictionary *)dict isNotRealShare:(BOOL)isNotRealShare andShareImagePath:(NSString *)shareImagePath;

@end
