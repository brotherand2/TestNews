//
//  SNTagModel.h
//  sohunews
//
//  Created by ivan.qi on 3/12/12.
//  Copyright (c) 2012 Sohu.com Inc. All rights reserved.
//

#import "SNURLRequest.h"

@interface SNTagPhotoModel : TTURLRequestModel {
    NSMutableArray *allTags;
    NSMutableArray *allCategories;
    NSMutableArray *oldCategories;
    SNURLRequest *_request;
    BOOL _isFirst;
    
    BOOL isNotInit;
}

@property(nonatomic,retain)NSMutableArray *allTags;
@property(nonatomic,retain)NSMutableArray *allCategories;
@property(nonatomic,retain)NSMutableArray *oldCategories;

-(void)saveAsCache;
- (NSArray *)subedCategories;

@end
