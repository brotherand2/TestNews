//
//  SNDownloadingStatusLabel.m
//  sohunews
//
//  Created by handy wang on 6/25/12.
//  Copyright (c) 2012 Sohu.com Inc. All rights reserved.
//

#import "SNDownloadingStatusLabel.h"
#import "UIColor+ColorUtils.h"

#define SELF_FONT                                                                   (24/2.0f)

#define SELF_ACTIONBTN_WIDTH                                                        (60/2.0f)
#define SELF_ACTIONBTN_HEIGHT                                                       (60/2.0f)

#define SELF_MSGLABEL_WIDTH                                                         (50.0f)
#define SELF_MSGLABEL_HEIGHT                                                        (60.0f/2.0f)
#define SELF_MSGLABEL_OFFSET_ACTIONBTN_X                                            (0.0f)

@interface SNDownloadingStatusLabel()

- (void)retry;

- (void)cancel;

@end


@implementation SNDownloadingStatusLabel
@synthesize delegate = _delegate;

- (id)initWithFrame:(CGRect)frame andDelegate:(id)delegateParam {
    self = [super initWithFrame:frame];
    if (self) {
        _delegate = delegateParam;
        
        self.userInteractionEnabled = YES;
        
        _cancelBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _cancelBtn.frame = CGRectMake(self.bounds.size.width-SELF_ACTIONBTN_WIDTH, 0, SELF_ACTIONBTN_WIDTH, SELF_ACTIONBTN_HEIGHT);
        [_cancelBtn setBackgroundImage:[UIImage imageNamed:@"cancel_download.png"] forState:UIControlStateNormal];
        [_cancelBtn addTarget:self action:@selector(cancel) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:_cancelBtn];
        
        _retryBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _retryBtn.frame = CGRectMake(self.bounds.size.width-SELF_ACTIONBTN_WIDTH, 0, SELF_ACTIONBTN_WIDTH, SELF_ACTIONBTN_HEIGHT);
        [_retryBtn setBackgroundImage:[UIImage imageNamed:@"refresh_download.png"] forState:UIControlStateNormal];
        _retryBtn.hidden = YES;
        [_retryBtn addTarget:self action:@selector(retry) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:_retryBtn];
        
        _msgLabel = [[UILabel alloc] initWithFrame:CGRectMake(_cancelBtn.frame.origin.x-SELF_MSGLABEL_WIDTH-SELF_MSGLABEL_OFFSET_ACTIONBTN_X,
                                                              0, 
                                                              SELF_MSGLABEL_WIDTH, 
                                                              SELF_MSGLABEL_HEIGHT)];
        _msgLabel.textAlignment = NSTextAlignmentRight;
        _msgLabel.font = [UIFont systemFontOfSize:SELF_FONT];
        UIColor *_msgLabelTextColor = [UIColor colorFromString:
                                        [[SNThemeManager sharedThemeManager] currentThemeValueForKey:kDownloadingCellStatusColor]];
        _msgLabel.textColor = _msgLabelTextColor;
        _msgLabel.backgroundColor = [UIColor clearColor];
        [self addSubview:_msgLabel];
    }
    return self;
}

- (void)setDownloadStatus:(SNDownloadStatus)downloadStatus {
    switch (downloadStatus) {
        case SNDownloadWait: {
            UIColor *_msgLabelTextColor = [UIColor colorFromString:
                                           [[SNThemeManager sharedThemeManager] currentThemeValueForKey:kDownloadingCellStatusColor]];
            _msgLabel.textColor = _msgLabelTextColor;
            _cancelBtn.hidden = NO;
            _retryBtn.hidden = YES;
            _msgLabel.text = NSLocalizedString(@"waiting_downloading", @"");
            break;
        }
        case SNDownloadRunning: {
            UIColor *_msgLabelTextColor = [UIColor colorFromString:
                                           [[SNThemeManager sharedThemeManager] currentThemeValueForKey:kDownloadingCellProgressPercentColor]];
            _msgLabel.textColor = _msgLabelTextColor;
            _cancelBtn.hidden = NO;
            _retryBtn.hidden = YES;
            _msgLabel.text = @"";
            break;
        }
        case SNDownloadFail: {
            UIColor *_msgLabelTextColor = [UIColor colorFromString:
                                           [[SNThemeManager sharedThemeManager] currentThemeValueForKey:kDownloadingCellStatusColor]];
            _msgLabel.textColor = _msgLabelTextColor;
            _cancelBtn.hidden = YES;
            _retryBtn.hidden = NO;
            _msgLabel.text = NSLocalizedString(@"failed_to_download", @"");
            break;
        }
        case SNDownloadSuccess: {
            UIColor *_msgLabelTextColor = [UIColor colorFromString:
                                           [[SNThemeManager sharedThemeManager] currentThemeValueForKey:kDownloadingCellStatusColor]];
            _msgLabel.textColor = _msgLabelTextColor;
            _msgLabel.text = NSLocalizedString(@"finish_downloading", @"");
            break;
        }
        default: {
            UIColor *_msgLabelTextColor = [UIColor colorFromString:
                                           [[SNThemeManager sharedThemeManager] currentThemeValueForKey:kDownloadingCellStatusColor]];
            _msgLabel.textColor = _msgLabelTextColor;
            _cancelBtn.hidden = YES;
            _retryBtn.hidden = YES;
            _msgLabel.text = NSLocalizedString(@"waiting_downloading", @"");
            break;
        }
    }
}

- (void)updateProgress:(CGFloat)progressValue animated:(BOOL)animated {
    _msgLabel.text = [NSString stringWithFormat:@"%d%%", (int)(progressValue*100)];
}

- (void)dealloc {
    _cancelBtn = nil;
    
    _retryBtn = nil;
    
    _msgLabel = nil;
    
}

#pragma mark - Private methods implementation

- (void)retry {
    if ([_delegate respondsToSelector:@selector(retryDownload)]) {
        [_delegate retryDownload];
    }
}

- (void)cancel {
    if ([_delegate respondsToSelector:@selector(cancelDownload)]) {
        [_delegate cancelDownload];
    }
}

@end
