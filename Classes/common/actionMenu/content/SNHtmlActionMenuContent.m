//
//  SNHtmlActionMenuContent.m
//  sohunews
//
//  Created by Dan Cong on 2/7/14.
//  Copyright (c) 2014 Sohu.com. All rights reserved.
//

#import "SNHtmlActionMenuContent.h"

@implementation SNHtmlActionMenuContent


- (void)interpretContext:(NSDictionary *)contentDic
{
    [super interpretContext:contentDic];
    
    self.shareLogContent = self.content;
    
    NSString *html = [contentDic objectForKey:kShareInfoKeyHtmlContent];
    if (html) {
        self.content = html;
    }
}


@end
