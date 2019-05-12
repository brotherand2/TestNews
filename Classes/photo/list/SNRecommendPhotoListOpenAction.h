//
//  SNRecommendPhotoListOpenAction.h
//  sohunews
//
//  Created by handy wang on 10/15/12.
//  Copyright (c) 2012 Sohu.com Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SNMyFavourite.h"

@interface SNRecommendPhotoListOpenAction : NSObject {

    MYFAVOURITE_REFER _myFavoriteRefer;
    
    NSString *_contentLevelOneID;

}

@property(nonatomic, assign)MYFAVOURITE_REFER myFavoriteRefer;
@property(nonatomic, copy)NSString *contentLevelOneID;

@end