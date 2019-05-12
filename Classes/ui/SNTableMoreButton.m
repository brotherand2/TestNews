//
//  SNTableMoreButton.m
//  sohunews
//
//  Created by kuanxi zhu on 8/24/11.
//  Copyright 2011 Sohu.com Inc. All rights reserved.
//

#import "SNTableMoreButton.h"


@implementation SNTableMoreButton
@synthesize title = _title, animating;

+ (id)itemWithText:(NSString*)text {
	SNTableMoreButton* item = [[super alloc] init];
	item.title = text;
	return item;
}

- (void)dealloc {
	 //(_title);
}
@end
