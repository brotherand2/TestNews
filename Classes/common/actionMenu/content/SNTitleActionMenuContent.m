//
//  SNTitleActionMenuContent.m
//  sohunews
//
//  Created by Dan Cong on 12/10/13.
//  Copyright (c) 2013 Sohu.com. All rights reserved.
//

#import "SNTitleActionMenuContent.h"

@implementation SNTitleActionMenuContent

- (void)interpretContext:(NSDictionary *)contentDic
{
    [super interpretContext:contentDic];
    
    self.content = [contentDic objectForKey:kShareInfoKeyContent];
    self.title = [contentDic objectForKey:kShareInfoKeyTitle];
    
    if (self.title.length == 0) {
        self.title = NSLocalizedString(@"Sohu share", nil);
    }
}

- (void)dealloc
{
     //(_title);
    
}

@end
