//
//  SNDownloadingProgressBar.h
//  sohunews
//
//  Created by handy wang on 1/22/13.
//  Copyright (c) 2013 Sohu.com Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SNDownloadingProgressBar : UIView {
    CGFloat _currentProgress;
}

- (void)updateProgress:(CGFloat)progress;//progress must be bettween [0 and 1]
- (void)resetProgress;
@end
