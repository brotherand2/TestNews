//
//  SNNewsUninterestedService.h
//  sohunews
//
//  Created by lhp on 5/26/14.
//  Copyright (c) 2014 Sohu.com. All rights reserved.
//

#import <UIKit/UIKit.h>
//#import "SNURLRequest.h"

@interface SNNewsUninterestedService : NSObject

+ (SNNewsUninterestedService *)sharedInstance;
- (void)uninterestedNewsWithType:(NSString *) newsType newsId:(NSString *) idString;

@end
