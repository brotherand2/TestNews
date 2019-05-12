//
//  SNUserTrack.h
//  sohunews
//
//  Created by jojo on 13-12-25.
//  Copyright (c) 2013年 Sohu.com. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SNAnalyticsConsts.h"

@interface SNUserTrack : NSObject

@property (nonatomic, copy) NSString *link2;
@property (nonatomic, assign) SNCCPVPage page;

+ (SNUserTrack *)trackWithPage:(SNCCPVPage)page link2:(NSString *)link2;

- (NSString *)toFormatString;

@end
