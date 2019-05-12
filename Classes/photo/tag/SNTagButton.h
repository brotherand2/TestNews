//
//  SNTagLabel.h
//  sohunews
//
//  Created by  on 12-3-15.
//  Copyright (c) 2012年 Sohu.com Inc. All rights reserved.
//

#import "CacheObjects.h"
#import <UIKit/UIKit.h>

@interface SNTagButton : UIButton {
    TagItem *tagItem;
}

@property(nonatomic,retain)TagItem *tagItem;

- (CGFloat)tagWidth;

@end
