//
//  SNActionMenuContentFactory.h
//  sohunews
//
//  Created by Dan Cong on 12/10/13.
//  Copyright (c) 2013 Sohu.com. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SNOAuthsActionMenuContent.h"
#import "SNWXActionMenuContent.h"
#import "SNTitleActionMenuContent.h"
#import "SNMailActionMenuContent.h"
#import "SNWebLinkActionMenuContent.h"
#import "SNHtmlActionMenuContent.h"
#import "SNQQActionMenuContent.h"
#import "SNQZoneActionMenuContent.h"
#import "SNSMSActionMenuContent.h"
#import "SNMySohuActionMenuContent.h"
#import "SNAPActionMenuContent.h"

@interface SNActionMenuContentFactory : NSObject

+ (SNActionMenuContent *)getContentOfType:(SNActionMenuOption)type;

@end
