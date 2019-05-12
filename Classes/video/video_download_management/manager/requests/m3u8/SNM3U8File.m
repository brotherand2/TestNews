//
//  SNM3U8File.m
//  sohunews
//
//  Created by handy wang on 9/27/13.
//  Copyright (c) 2013 Sohu.com. All rights reserved.
//

#import "SNM3U8File.h"

@implementation SNM3U8File

- (id)init {
    self = [super init];
    if (self) {
        self.playlist = [[SNM3U8Playlist alloc] init];
    }
    return self;
}


@end
