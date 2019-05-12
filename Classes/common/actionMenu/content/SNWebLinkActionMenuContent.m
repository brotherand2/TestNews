//
//  SNWebLinkActionMenuContent.m
//  sohunews
//
//  Created by Dan Cong on 12/11/13.
//  Copyright (c) 2013 Sohu.com. All rights reserved.
//

#import "SNWebLinkActionMenuContent.h"

@implementation SNWebLinkActionMenuContent

- (void)interpretContext:(NSDictionary *)contentDic
{
    [super interpretContext:contentDic];
    
    self.content = [contentDic objectForKey:kShareInfoKeyShareLink];
}

@end
