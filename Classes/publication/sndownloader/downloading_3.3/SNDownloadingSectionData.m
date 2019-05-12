//
//  SNDownloadingSectionData.m
//  sohunews
//
//  Created by handy wang on 1/21/13.
//  Copyright (c) 2013 Sohu.com Inc. All rights reserved.
//

#import "SNDownloadingSectionData.h"

@implementation SNDownloadingSectionData
@synthesize arrayData = _arrayData;
@synthesize tag = _tag;

- (id)init {
    if (self = [super init]) {
        _arrayData = [NSMutableArray array];
    }
    return self;
}

- (void)dealloc {
     //(_arrayData);
     //(_tag);
    
}

@end
