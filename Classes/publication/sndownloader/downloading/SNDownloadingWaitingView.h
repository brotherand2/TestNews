//
//  SNDownloadingWaitingView.h
//  sohunews
//
//  Created by handy wang on 6/25/12.
//  Copyright (c) 2012 Sohu.com Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SNActivityIndicatorView.h"
#import "SNProgressView.h"
#import "SNDownloadConfig.h"

@interface SNDownloadingWaitingView : UIView {
    SNProgressView *_progressView;
    SNActivityIndicatorView *_loadingIndicator;
}

- (void)setDownloadStatus:(SNDownloadStatus)downloadStatus;

- (void)updateProgress:(CGFloat)progressValue animated:(BOOL)animated;

@end