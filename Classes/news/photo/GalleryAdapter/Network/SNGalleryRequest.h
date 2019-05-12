//
//  SNGalleryRequest.h
//  sohunews
//
//  Created by HuangZhen on 22/02/2017.
//  Copyright © 2017 Sohu.com. All rights reserved.
//

#import "SNBaseRequest.h"

@interface SNGalleryRequest : SNBaseRequest<SNRequestProtocol>

@property (nonatomic, copy) NSString * gid;
@property (nonatomic, copy) NSString * newsId;
@property (nonatomic, copy) NSString * channelId;

@end
