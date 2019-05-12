//
//  SNRecommendPhotoListOpenAction.m
//  sohunews
//
//  Created by handy wang on 10/15/12.
//  Copyright (c) 2012 Sohu.com Inc. All rights reserved.
//

#import "SNRecommendPhotoListOpenAction.h"

@implementation SNRecommendPhotoListOpenAction

@synthesize myFavoriteRefer = _myFavoriteRefer;
@synthesize contentLevelOneID = _contentLevelOneID;


- (void)dealloc {
    
    _myFavoriteRefer = MYFAVOURITE_REFER_NONE;

    TT_RELEASE_SAFELY(_contentLevelOneID);

    [super dealloc];

}


@end