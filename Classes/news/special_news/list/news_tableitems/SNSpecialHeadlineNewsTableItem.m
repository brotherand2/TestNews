//
//  SNSpecialHeadlineNewsTableItem.m
//  sohunews
//
//  Created by handy wang on 7/5/12.
//  Copyright (c) 2012 Sohu.com Inc. All rights reserved.
//

#import "SNSpecialHeadlineNewsTableItem.h"

@implementation SNSpecialHeadlineNewsTableItem

@synthesize termId = _termId;
@synthesize headlines = _headlines;
@synthesize excludePhotoNewsIds = _excludePhotoNewsIds;
@synthesize photoNewsIds = _photoNewsIds;
@synthesize allNewsIds = _allNewsIds;
@synthesize snModel = _snModel;
@synthesize dataSource = _dataSource;

- (id)init {
    if (self = [super init]) {
        _headlines = [[NSMutableArray alloc] init];
    }
    return self;
}


@end
