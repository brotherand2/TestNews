//
//  SNBubbleBadgeService.h
//  sohunews
//
//  Created by weibin cheng on 13-9-5.
//  Copyright (c) 2013年 Sohu.com. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SNBubbleBadgeService : NSObject/*<TTURLRequestDelegate>*/
{
//    SNURLRequest* _badgeRequest;
    BOOL _isRuning;
}

+(SNBubbleBadgeService*)shareInstance;

-(void)requestNewBadge;

@end
