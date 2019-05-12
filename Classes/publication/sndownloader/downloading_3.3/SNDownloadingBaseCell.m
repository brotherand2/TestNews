//
//  SNDownloadingBaseCell.m
//  sohunews
//
//  Created by handy wang on 1/16/13.
//  Copyright (c) 2013 Sohu.com Inc. All rights reserved.
//

#import "SNDownloadingBaseCell.h"
#import "UIColor+ColorUtils.h"

#define kCancelAndFinishMarkWidth                   (80/2.0f)
#define kCancelAndFinishMarkHeight                  (80/2.0f)

#define kRetryBtnWidth                              (60/2.0f)
#define kRetryBtnHeight                             (60/2.0f)

@interface SNDownloadingBaseCell() {
    UIImageView *_bgImageView;
    UIImageView *_seperatorView;
}
@property(nonatomic, strong)UIImageView *bgImageView;
@property(nonatomic, strong)UIImageView *seperatorView;
@end

@implementation SNDownloadingBaseCell
@synthesize delegate = _delegate;
@synthesize data = _data;
@synthesize bgImageView = _bgImageView;
@synthesize titleLabel = _titleLabel;
@synthesize downloadingIndicator = _downloadingIndicator;
@synthesize finishMark = _finishMark;
@synthesize cancelBtn = _cancelBtn;
@synthesize seperatorView = _seperatorView;
@synthesize order;
@synthesize retryBtn = _retryBtn;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier delegate:(id)delegateParam {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        _delegate = delegateParam;
        [self setSelectionStyle:UITableViewCellSelectionStyleNone];
        
        [self bgImageView];
        [self titleLabel];
        //[self downloadingIndicator];
        [self cancelBtn];
        [self finishMark];
        [self seperatorView];
        [self retryBtn];
    }
    return self;
}

- (UIImageView *)bgImageView {
    if (!_bgImageView) {
        _bgImageView = [[UIImageView alloc] initWithFrame:CGRectMake(10, 0, CGRectGetWidth(self.frame)-20, CGRectGetHeight(self.frame))];
        [_bgImageView setAutoresizingMask:UIViewAutoresizingFlexibleHeight];
        [self addSubview:_bgImageView];
    }
    return _bgImageView;
}

- (UILabel *)titleLabel {
    if (!_titleLabel) {
        _titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(10+14, 0, CGRectGetWidth(self.frame)-14-90, CGRectGetHeight(self.frame))];
        _titleLabel.backgroundColor = [UIColor clearColor];
        _titleLabel.textColor = [UIColor colorWithRed:79/255.0f green:79/255.0f blue:79/255.0f alpha:1];
        _titleLabel.font = [UIFont systemFontOfSize:15];
        [_titleLabel setAutoresizingMask:UIViewAutoresizingFlexibleHeight];
        [self addSubview:_titleLabel];
    }
    return _titleLabel;
}

- (SNDownloadingArrowIndicator *)downloadingIndicator {
    if (!_downloadingIndicator) {
        _downloadingIndicator = [[SNDownloadingArrowIndicator alloc] initWithPosition:CGPointMake(self.width-10-kCancelAndFinishMarkWidth-14,
                                                                                                  self.titleLabel.center.y-5)];
        [self addSubview:_downloadingIndicator];
    }
    return _downloadingIndicator;
}

- (UIButton *)cancelBtn {
    if (!_cancelBtn) {
        _cancelBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _cancelBtn.accessibilityLabel = @"取消下载";
        _cancelBtn.hidden = YES;
        _cancelBtn.frame = CGRectMake(self.width-10-kCancelAndFinishMarkWidth,
                                      self.titleLabel.center.y-kCancelAndFinishMarkHeight/2.0f+3,
                                      kCancelAndFinishMarkWidth,
                                      kCancelAndFinishMarkHeight);
        [_cancelBtn setBackgroundImage:[UIImage imageNamed:@"downloading_canceldownload.png"] forState:UIControlStateNormal];
        [_cancelBtn setBackgroundImage:[UIImage imageNamed:@"downloading_canceldownload_press.png"] forState:UIControlStateHighlighted];
        [_cancelBtn setBackgroundColor:[UIColor clearColor]];
        [_cancelBtn addTarget:self action:@selector(cancelDownload) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:_cancelBtn];
    }
    return _cancelBtn;
}

- (UIImageView *)finishMark {
    if (!_finishMark) {
        _finishMark = [[UIImageView alloc] initWithFrame:CGRectMake(self.width-10-kCancelAndFinishMarkWidth,
                                                                    self.cancelBtn.center.y-kCancelAndFinishMarkHeight/2.0f,
                                                                    kCancelAndFinishMarkWidth,
                                                                    kCancelAndFinishMarkHeight)];
        _finishMark.image = [UIImage imageNamed:@"download_setting_checkmark.png"];
        _finishMark.hidden = YES;
        [self addSubview:_finishMark];
    }
    return _finishMark;
}

- (UIImageView *)seperatorView {
    if (!_seperatorView) {
        _seperatorView = [[UIImageView alloc] init];
        _seperatorView.frame = CGRectMake(11, CGRectGetHeight(self.frame)-1, CGRectGetWidth(self.frame)-22, 1);
        [_seperatorView setAutoresizingMask:UIViewAutoresizingFlexibleTopMargin];
        [self addSubview:_seperatorView];
    }
    return _seperatorView;
}

- (UIButton *)retryBtn {
    if (!_retryBtn) {
        _retryBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _retryBtn.accessibilityLabel = @"重新下载";
        _retryBtn.hidden = YES;
        _retryBtn.frame = CGRectMake(CGRectGetMinX(self.cancelBtn.frame)-kRetryBtnWidth,
                                     CGRectGetMidY(self.cancelBtn.frame)-kRetryBtnHeight/2.0f,
                                     kRetryBtnWidth,
                                     kRetryBtnHeight);
        [_retryBtn setBackgroundImage:[UIImage imageNamed:@"refresh_download.png"] forState:UIControlStateNormal];
        [_retryBtn setBackgroundColor:[UIColor clearColor]];
        [_retryBtn addTarget:self action:@selector(retryDownload) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:_retryBtn];
    }
    return _retryBtn;
}

- (void)dealloc {
     //(_data);
     //(_bgImageView);
     //(_downloadingIndicator);
     //(_titleLabel);
     //(_finishMark);
     //(_cancelBtn);
     //(_seperatorView);
     //(_retryBtn);
}

#pragma mark - Override

- (void)layoutSubviews {
    [super layoutSubviews];
    
    [_downloadingIndicator removeFromSuperview];
     //(_downloadingIndicator);
    
    _finishMark.image = [UIImage imageNamed:@"download_setting_checkmark.png"];
    [_retryBtn setBackgroundImage:[UIImage imageNamed:@"refresh_download.png"] forState:UIControlStateNormal];
    [_cancelBtn setBackgroundImage:[UIImage imageNamed:@"downloading_canceldownload.png"] forState:UIControlStateNormal];
    [_cancelBtn setBackgroundImage:[UIImage imageNamed:@"downloading_canceldownload_press.png"] forState:UIControlStateHighlighted];
    
    switch (self.order) {
        case SNDownloadingCellOrder_OnlyOne:
            self.bgImageView.image = [UIImage imageNamed:@"download_setting_cellbg_onlyone.png"];
            self.seperatorView.image = nil;
            break;
        case SNDownloadingCellOrder_First:
            self.bgImageView.image = [UIImage imageNamed:@"download_setting_cellbg_first.png"];
            self.seperatorView.image = [UIImage imageNamed:@"download_setting_cellseperatorbg.png"];
            break;
        case SNDownloadingCellOrder_Last:
            self.bgImageView.image = [UIImage imageNamed:@"download_setting_cellbg_last.png"];
            self.seperatorView.image = nil;
            break;
        default://SNDownloadingCellOrder_Middle
            self.bgImageView.image = [UIImage imageNamed:@"download_setting_cellbg_middle.png"];
            self.seperatorView.image = [UIImage imageNamed:@"download_setting_cellseperatorbg.png"];
            break;
    }
}

#pragma mark - Public methods

- (void)cancelDownload {
    [[SNDownloadScheduler sharedInstance] cancelDownload:self.data];
}

- (void)retryDownload {
    [[SNDownloadScheduler sharedInstance] retryDownload:self.data];
}

#pragma mark - Private methods

@end
