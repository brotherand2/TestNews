//
//  SNSubCenterMoreCell.h
//  sohunews
//
//  Created by wang yanchen on 12-11-27.
//  Copyright (c) 2012年 Sohu.com Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SNTableViewCell.h"
#import "SNTwinsMoreView.h"
#import "SNWaitingActivityView.h"

#define kTLUserCenterMoreCellHeight     60

@interface SNSubCenterMoreCell : SNTableViewCell {
    UILabel *_promtLabel;
    SNWaitingActivityView *_actView;
    SNTwinsMoreView *_moreAnimationView;
}

- (void)showLoading:(BOOL)bShow;
- (void)updateTheme;

@end
