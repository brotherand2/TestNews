//
//  SNDownloadingWaitingView.m
//  sohunews
//
//  Created by handy wang on 6/25/12.
//  Copyright (c) 2012 Sohu.com Inc. All rights reserved.
//

#import "SNDownloadingWaitingView.h"
#import "UIColor+ColorUtils.h"

#define SELF_PROGRESS_SLIDER                                    (10.0f)

@implementation SNDownloadingWaitingView

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        UIColor *_downloadingWaitingViewBgColor = [UIColor colorFromString:[[SNThemeManager sharedThemeManager] currentThemeValueForKey:kDownloadingWaitingViewBgColor]];
        CGColorRef colorref = CGColorCreateCopyWithAlpha(_downloadingWaitingViewBgColor.CGColor, 0.8);
        _downloadingWaitingViewBgColor = [UIColor colorWithCGColor:colorref];
        CGColorRelease(colorref);
        self.backgroundColor = _downloadingWaitingViewBgColor;

        _progressView = [[SNProgressView alloc] initWithFrame:CGRectMake(
                                                                     (self.frame.size.width*0.1)/2.0f,
                                                                     self.frame.size.height, 
                                                                     self.frame.size.width*0.9, 
                                                                     SELF_PROGRESS_SLIDER)];
        [self addSubview:_progressView];
        
        _loadingIndicator = [[SNActivityIndicatorView alloc] init];
        CGRect _tmpFrame = _loadingIndicator.frame;
        _tmpFrame.origin.x = (self.bounds.size.width - _tmpFrame.size.width)/2.0f;
        _tmpFrame.origin.y = (self.bounds.size.height - _tmpFrame.size.height)/2.0f;
        _loadingIndicator.frame = _tmpFrame;
        UIColor *_loadingIndicatorColor = [UIColor colorFromString:
                                        [[SNThemeManager sharedThemeManager] currentThemeValueForKey:kDownloadingCellProgressLoadingColor]];
        _loadingIndicator.color = _loadingIndicatorColor;
        [_loadingIndicator startAnimating];
        
//        _loadingIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
//        CGRect _tmpFrame = _loadingIndicator.frame;
//        _tmpFrame.origin.x = (self.bounds.size.width - _tmpFrame.size.width)/2.0f;
//        _tmpFrame.origin.y = (self.bounds.size.height - _tmpFrame.size.height)/2.0f;
//        _loadingIndicator.frame = _tmpFrame;
//        
//        [_loadingIndicator startAnimating];

        [self addSubview:_loadingIndicator];
    }
    return self;
}

- (void)setDownloadStatus:(SNDownloadStatus)downloadStatus {
    switch (downloadStatus) {
        case SNDownloadWait: {
            [_progressView updateProgress:0 animated:NO];
            _loadingIndicator.hidden = NO;
            self.hidden = YES;
            break;
        }
        case SNDownloadRunning: {
            _loadingIndicator.hidden = NO;
            self.hidden = NO;
            break;
        }
        case SNDownloadFail: {
            _loadingIndicator.hidden = YES;
            self.hidden = NO;
            break;
        }
        case SNDownloadSuccess: {
            [_progressView updateProgress:0 animated:NO];
            _loadingIndicator.hidden = NO;
            self.hidden = YES;
            break;
        }
        default: {
            [_progressView updateProgress:0 animated:NO];
            _loadingIndicator.hidden = NO;
            self.hidden = YES;
            break;
        }
    }
}

- (void)updateProgress:(CGFloat)progressValue animated:(BOOL)animated {
    [_progressView updateProgress:progressValue animated:animated];
}

- (void)dealloc {
    _progressView = nil;
    
    _loadingIndicator = nil;
    
}

@end
