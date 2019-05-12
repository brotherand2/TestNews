//
//  SNActionMenuContentFactory.m
//  sohunews
//
//  Created by Dan Cong on 12/10/13.
//  Copyright (c) 2013 Sohu.com. All rights reserved.
//

#import "SNActionMenuContentFactory.h"

@implementation SNActionMenuContentFactory

+ (SNActionMenuContent *)getContentOfType:(SNActionMenuOption)type
{
    Class cls = nil;
    switch (type) {
        case SNActionMenuOptionOAuths:
            cls = [SNOAuthsActionMenuContent class];
            break;
        case SNActionMenuOptionWXSession:
        case SNActionMenuOptionWXTimeline:
            cls = [SNWXActionMenuContent class];
            break;
        case SNActionMenuOptionQQ:
            cls = [SNQQActionMenuContent class];
            break;
        case SNActionMenuOptionQZone:
            cls = [SNQZoneActionMenuContent class];
            break;
        case SNActionMenuOptionMail:
            cls = [SNMailActionMenuContent class];
            break;
        case SNActionMenuOptionSMS:
            cls = [SNSMSActionMenuContent class];
            break;
        case SNActionMenuOptionWebLink:
            cls = [SNWebLinkActionMenuContent class];
            break;
        case SNActionMenuOptionMySOHU:
            cls = [SNMySohuActionMenuContent class];
            break;
        case SNActionMenuOptionAliPaySession:
            cls = [SNAPActionMenuContent class];
            break;
        case SNActionMenuOptionAliPayLifeCircle:
            cls = [SNAPActionMenuContent class];
            break;
        default:
            break;
    }
    
    if (cls) {
        SNActionMenuContent *content = [[cls alloc] init];
        content.type = type;
        return content;
    } else {
        return nil;
    }
}

@end
