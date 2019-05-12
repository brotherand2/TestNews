//
//  SNTableAutoLoadMoreCell.h
//  sohunews
//
//  Created by Cong Dan on 4/9/12.
//  Copyright (c) 2012 Sohu.com Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SNTwinsMoreView.h"
#import "SNWaitingActivityView.h"

@interface SNTableAutoLoadMoreCell : TTTableSubtitleItemCell
{
    SNTwinsMoreView *_moreAnimationView;
    SNWaitingActivityView*  _activityIndicatorView;
    BOOL                      _animating;
}

@property (nonatomic, readonly, strong) SNWaitingActivityView*  activityIndicatorView;
@property (nonatomic)                   BOOL                      animating;

@end
