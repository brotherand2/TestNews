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

@property(nonatomic,strong)NSMutableArray *allTags;
@property(nonatomic,strong)NSMutableArray *allCategories;
@property(nonatomic,strong)NSMutableArray *oldCategories;

-(void)saveAsCache;
- (NSArray *)subedCategories;

@end
