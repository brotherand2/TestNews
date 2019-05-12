//
//  SNRollingArticleRequest.h
//  sohunews
//
//  Created by 李腾 on 2017/2/7.
//  Copyright © 2017年 Sohu.com. All rights reserved.
//

#import "SNDefaultParamsRequest.h"

@interface SNArticleRequest : SNDefaultParamsRequest

- (instancetype)initWithNewsId:(NSString *)newsId
                     channelId:(NSString *)channelId
                  andCDNParams:(NSDictionary *)CDNParams;

- (instancetype)initWithNewsId:(NSString *)newsId
                        termId:(NSString *)termId
                     CDNParams:(NSDictionary *)CDNParams
              andArticleParams:(NSDictionary *)articleParams;
@end
