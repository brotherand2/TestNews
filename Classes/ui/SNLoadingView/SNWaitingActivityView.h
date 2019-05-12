//
//  UIWaitingActivityView.h
//  RedAnim
//
//  Created by Xiang WeiJia on 12/18/14.
//  Copyright (c) 2014 Xiang WeiJia. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SNWaitingActivityView : UIView

@property (nonatomic) BOOL hidesWhenStopped;  // default is YES.

- (void)startAnimating;
- (void)stopAnimating;
- (BOOL)isAnimating;

- (void)updateTheme;

@end
