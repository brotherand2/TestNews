//
//  SNSubItem.m
//  sohunews
//
//  Created by kuanxi zhu on 7/4/11.
//  Copyright 2011 Sohu.com Inc. All rights reserved.
//

#import "SNSubItem.h"


@implementation SNSubItem

- (void)setLastTermLink:(NSString *)newLastTermLink {
	if (newLastTermLink && ![lastTermLink isEqualToString:newLastTermLink]) {
		 //(lastTermLink);

        //redirect表示是否需要重定向url来获取termId，不重定向的话，可以在response header里取termId
		if (NSNotFound == [newLastTermLink rangeOfString:@"&redirect"].location) {
			lastTermLink = [[newLastTermLink stringByAppendingFormat:@"&redirect=%d", 0] copy];
		} else {
			lastTermLink = [newLastTermLink copy];
		}
        
        //nested表示报纸里面是否可以嵌套报纸(paper://)，这里表示新版本支持nested=1
        if (NSNotFound == [lastTermLink rangeOfString:@"&nested"].location) {
			lastTermLink = [[lastTermLink stringByAppendingFormat:@"&nested=%d", 1] copy];
		}
        
        SNDebugLog(@"setLastTermLink %@", lastTermLink);
	}
}

- (id)copyWithZone:(NSZone *)zone {
	id newItem = [super copyWithZone:zone];
	return newItem;
}
@end
