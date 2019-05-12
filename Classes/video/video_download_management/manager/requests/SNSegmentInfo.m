//
//  SNSegmentInfo.m
//  sohunews
//
//  Created by handy wang on 9/4/13.
//  Copyright (c) 2013 Sohu.com. All rights reserved.
//

#import "SNSegmentInfo.h"

@implementation SNSegmentInfo

- (id)init {
    self = [super init];
    if (self) {
        self.state = SNVideoDownloadState_Waiting;
    }
    return self;
}

- (void)setValue:(id)value forUndefinedKey:(NSString *)key {
    //Do nothing
    SNDebugLog(@"INFO: Property %@ doesnt exist in %@", key, NSStringFromClass(self.class));
}

@end
