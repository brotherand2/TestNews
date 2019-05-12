//
//  SNVideoDownloadProgressBar.m
//  sohunews
//
//  Created by handy wang on 1/22/13.
//  Copyright (c) 2013 Sohu.com Inc. All rights reserved.
//

#import "SNVideoDownloadProgressBar.h"
#import "UIColor+ColorUtils.h"

#define kProgressHeight                             (14/2.0f)
#define kBgImageWidthRateInSelfWidth                (1)
#define kInitProgressWidth                          (4/2.0f)

@interface SNVideoDownloadProgressBar() {
    UIImageView *_bgImageView;
    UIImageView *_progressImageView;
}
@property(nonatomic, strong)UIImageView *bgImageView;
@property(nonatomic, strong)UIImageView *progressImageView;
@end


@implementation SNVideoDownloadProgressBar
@synthesize bgImageView = _bgImageView;
@synthesize progressImageView = _progressImageView;

#pragma mark - Lifecycle

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self bgImageView];
        [self progressImageView];
        [self updateProgress:0.0];
    }
    return self;
}

- (void)dealloc {
     //(_bgImageView);
     //(_progressImageView);
    
}

#pragma mark - Override

- (UIImageView *)bgImageView {
    if (!_bgImageView) {
        _bgImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0,
                                                                     0,
                                                                     self.width*kBgImageWidthRateInSelfWidth,
                                                                     self.height)
                        ];
        _bgImageView.layer.cornerRadius = 1;
        _bgImageView.backgroundColor                = [UIColor colorFromString:[[SNThemeManager sharedThemeManager] currentThemeValueForKey:kDownloadVideoProgressBar_BgColor]];
        [self addSubview:_bgImageView];
    }
    return _bgImageView;
}

- (UIImageView *)progressImageView {
    if (!_progressImageView) {
        _progressImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0,
                                                                           0,
                                                                           kInitProgressWidth,
                                                                           self.height)];
        _progressImageView.layer.cornerRadius = 1;
        _progressImageView.backgroundColor                        = [UIColor colorFromString:[[SNThemeManager sharedThemeManager] currentThemeValueForKey:kDownloadVideoProgressBar_ProgressColor]];
        [self addSubview:_progressImageView];
    }
    return _progressImageView;
}

#pragma mark - Public methods

/*
 |<----------------------------------------------------self width---------------------------------------------------------------------->|
 
  --------------------------------------------------------------------------------------------------------------------------------------
 |                     |                                                                                             |                  |
  --------------------------------------------------------------------------------------------------------------------------------------
 
 |<-initprogresswidth->|
 |<---------------------------------proress imageview total width(width rate)--------------------------------------->|<-perecent label->|
 
 */
- (void)updateProgress:(CGFloat)progress {
    SNDebugLog(@"################################### video download progress : %f", progress);

    if (progress < 0 || progress > 1) {
        return;
    }
    
    _currentProgress = progress;
    
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:0.2];
    _progressImageView.width = kInitProgressWidth + (_bgImageView.width-kInitProgressWidth)*_currentProgress;
    [UIView commitAnimations];
    
    SNDebugLog(@"===INFO:===============================Updating video download progress %@", [NSString stringWithFormat:@"%.2f%%", _currentProgress*100]);
}

- (void)resetProgress {
    _currentProgress = 0;
    _progressImageView.width = kInitProgressWidth + (_bgImageView.width-kInitProgressWidth)*_currentProgress;
    
    SNDebugLog(@"===INFO:===============================reset video download progress %@", [NSString stringWithFormat:@"%d%%", (int)(_currentProgress*100)]);
}

@end
