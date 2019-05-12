//
//  SNM3U8Playlist.m
//  sohunews
//
//  Created by handy wang on 9/4/13.
//  Copyright (c) 2013 Sohu.com. All rights reserved.
//

#import "SNM3U8Playlist.h"

@implementation SNM3U8Playlist

- (id)init {
    self = [super init];
    if (self) {
        self.segments = [NSMutableArray array];
    }
    return self;
}


@end
