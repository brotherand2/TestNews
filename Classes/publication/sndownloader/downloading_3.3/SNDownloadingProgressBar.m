//
//  SNDownloadingProgressBar.m
//  sohunews
//
//  Created by handy wang on 1/22/13.
//  Copyright (c) 2013 Sohu.com Inc. All rights reserved.
//

#import "SNDownloadingProgressBar.h"
#import "UIColor+ColorUtils.h"

#define kProgressHeight                             (14/2.0f)
#define kBgImageWidthRateInSelfWidth                (0.83)
#define kInitProgressWidth                          (20/2.0f)

@interface SNDownloadingProgressBar() {
    UIImageView *_bgImageView;
    UIImageView *_progressImageView;
    UILabel *_percentageLabel;
}
@property(nonatomic, strong)UIImageView *bgImageView;
@property(nonatomic, strong)UIImageView *progressImageView;
@property(nonatomic, strong)UILabel *percentageLabel;
@end


@implementation SNDownloadingProgressBar
@synthesize bgImageView = _bgImageView;
@synthesize progressImageView = _progressImageView;
@synthesize percentageLabel = _percentageLabel;

#pragma mark - Lifecycle

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self bgImageView];
        [self percentageLabel];
        [self progressImageView];
        [self updateProgress:0.0];
    }
    return self;
}

- (void)dealloc {
     //(_bgImageView);
     //(_progressImageView);
     //(_percentageLabel);
    
}

#pragma mark - Override

- (UIImageView *)bgImageView {
    if (!_bgImageView) {
        _bgImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0,
                                                                     (self.height-kProgressHeight)/2.0f,
                                                                     self.width*kBgImageWidthRateInSelfWidth,
                                                                     kProgressHeight)
                        ];
        UIImage *_img = [UIImage imageNamed:@"downloading_progressbar_bg.png"];
        if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"5.0")) {
            _img = [_img resizableImageWithCapInsets:UIEdgeInsetsMake(3, 4, 3, 4)];
        } else {
            _img = [_img stretchableImageWithLeftCapWidth:4 topCapHeight:3];
        }
        [_bgImageView setImage:_img];
        [self addSubview:_bgImageView];
    }
    return _bgImageView;
}

- (UILabel *)percentageLabel {
    if (!_percentageLabel) {
        _percentageLabel = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMaxX(self.bgImageView.frame)+2, 0, self.width*(1-kBgImageWidthRateInSelfWidth)-2, self.height)];
        [_percentageLabel setFont:[UIFont systemFontOfSize:11]];
        [_percentageLabel setTextAlignment:NSTextAlignmentRight];
        [_percentageLabel setTextColor:[UIColor colorFromString:[[SNThemeManager sharedThemeManager] currentThemeValueForKey:kDownloadingProgressBarPercentageColor]]];
        [_percentageLabel setBackgroundColor:[UIColor clearColor]];
        [self addSubview:_percentageLabel];
    }
    return _percentageLabel;
}

- (UIImageView *)progressImageView {
    if (!_progressImageView) {
        _progressImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0,
                                                                           (self.height-kProgressHeight)/2.0f,
                                                                           kInitProgressWidth,
                                                                           kProgressHeight)];
        UIImage *_img = [UIImage imageNamed:@"downloading_progressbar_progress.png"];
        if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"5.0")) {
            _img = [_img resizableImageWithCapInsets:UIEdgeInsetsMake(3, 4, 3, 4)];
        } else {
            _img = [_img stretchableImageWithLeftCapWidth:4 topCapHeight:3];
        }
        [_progressImageView setImage:_img];
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
    SNDebugLog(@"################################### progress : %f", progress);
    
//    if (progress < _currentProgress || progress < 0 || progress > 1) {
    if (progress < 0 || progress > 1) {
        return;
    }
    
    _currentProgress = progress;
    CGRect _tempFrame = _progressImageView.frame;
    _tempFrame.size.width = kInitProgressWidth + (_bgImageView.width-kInitProgressWidth)*_currentProgress;
    
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:0.2];
    _progressImageView.frame = _tempFrame;
    [UIView commitAnimations];
    
    SNDebugLog(@"===INFO:===============================update section header progress %@", [NSString stringWithFormat:@"%d%%", (int)(_currentProgress*100)]);
    [_percentageLabel setText:[NSString stringWithFormat:@"%d%%", (int)(_currentProgress*100)]];
}

- (void)resetProgress {
    _currentProgress = 0;
    CGRect _tempFrame = _progressImageView.frame;
    _tempFrame.size.width = kInitProgressWidth + (_bgImageView.width-kInitProgressWidth)*_currentProgress;
    _progressImageView.frame = _tempFrame;
    
    SNDebugLog(@"===INFO:===============================reset section header progress %@", [NSString stringWithFormat:@"%d%%", (int)(_currentProgress*100)]);
    [_percentageLabel setText:[NSString stringWithFormat:@"%d%%", (int)(_currentProgress*100)]];
}

@end
