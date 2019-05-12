//
//  SNTagTableItem.m
//  sohunews
//
//  Created by ivan on 3/12/12.
//  Copyright (c) 2012 Sohu.com Inc. All rights reserved.
//

#import "SNTagPhotoTableItem.h"

@implementation SNTagPhotoTableItem

@synthesize allTags, allCategories, indexPath, controller,row;

-(void)dealloc {
    TT_RELEASE_SAFELY(allTags);
    TT_RELEASE_SAFELY(allCategories);
    TT_RELEASE_SAFELY(indexPath);
    [super dealloc];
}

@end
