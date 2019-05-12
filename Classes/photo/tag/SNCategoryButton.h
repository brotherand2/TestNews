//
//  SNTagButton.h
//  sohunews
//
//  Created by  on 12-3-15.
//  Copyright (c) 2012年 Sohu.com Inc. All rights reserved.
//

#import "CacheObjects.h"
#import <UIKit/UIKit.h>

@interface SNCategoryButton : UIButton {
    CategoryItem *category;
}

@property(nonatomic,retain)CategoryItem *category;
@end
