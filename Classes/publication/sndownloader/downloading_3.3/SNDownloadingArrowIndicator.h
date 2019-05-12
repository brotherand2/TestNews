//
//  SNDownloadingArrowIndicator.h
//  sohunews
//
//  Created by handy wang on 1/23/13.
//  Copyright (c) 2013 Sohu.com Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SNDownloadingArrowIndicator : UIView

- (id)initWithPosition:(CGPoint)position;
- (void)startAnimation;
- (void)stopAnimation;

@end