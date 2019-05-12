//
//  SNAppConfigService.h
//  sohunews
//
//  Created by handy wang on 5/4/14.
//  Copyright (c) 2014 Sohu.com. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SNAppConfigService : NSObject
@property (nonatomic, weak) id delegate;

- (void)requestConfigAsync;
- (void)requestConfigSync;
- (void)cancel;
@end


@protocol SNAppConfigServiceDelegate <NSObject>
- (void)didSucceedToRequestConfig:(SNAppConfig *)config;
- (void)didFailedToRequestConfigFromServerWithError:(NSError *)error andLocalConfig:(SNAppConfig *)localConfig;
@end
