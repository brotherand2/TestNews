//
//  SNDownloadingSectionHeaderView.m
//  sohunews
//
//  Created by handy wang on 1/16/13.
//  Copyright (c) 2013 Sohu.com Inc. All rights reserved.
//

#import "SNDownloadingSectionHeaderView.h"
#import <QuartzCore/QuartzCore.h>
#import "SNDownloadingVController.h"
#import "UIColor+ColorUtils.h"
#import "SNDownloadingProgressBar.h"

#define kIConLeft                               (22/2.0f)
#define kIconWidth                              (36/2.0f)
#define kIconHeight                             (36/2.0f)

#define kTitleMarginLeftToIcon                  (12/2.0f)
#define kTitleWidth                             (80/2.0f)
#define kTitleHeight                            (36/2.0f)
#define kTitleLabelFontSize                     (34/2.0f)

#define kProgressBarWidth                       (396/2.0f)
#define kProgressBarHeight                      (40/2.0f)

#define kActionBtnWidth                         (90/2.0f)
#define kActionBtnHeight                        (90/2.0f)

@interface SNDownloadingSectionHeaderView() {
    UIImageView *_iconView;
    UILabel *_titleLabel;
    UIButton *_arrowBtn;
    SNDownloadingProgressBar *_progressBar;
    UIImageView *_separatorLine;
}

@property(nonatomic, strong)UIImageView *iconView;
@property(nonatomic, strong)UILabel *titleLabel;
@property(nonatomic, strong)UIButton *arrowBtn;
@property(nonatomic, strong)SNDownloadingProgressBar *progressBar;
@property(nonatomic, strong)UIImageView *separatorLine;

@end


@implementation SNDownloadingSectionHeaderView
@synthesize iconView = _iconView;
@synthesize titleLabel = _titleLabel;
@synthesize arrowBtn = _arrowBtn;
@synthesize progressBar = _progressBar;
@synthesize separatorLine = _separatorLine;

#pragma mark - Lifecycle

- (id)initWithFrame:(CGRect)frame icon:(NSString *)iconImageName title:(NSString *)title sectionTag:(NSString *)sectionTag
      seperatorLine:(BOOL)showSeparatorLine delegate:(id)delegateParam {
    self = [super initWithFrame:frame];
    if (self) {
        _delegate = delegateParam;
        _sectionTag = [sectionTag copy];
        
        self.backgroundColor = [UIColor colorFromString:[[SNThemeManager sharedThemeManager] currentThemeValueForKey:kBackgroundColor]];
        [self iconViewWithIconImangeName:iconImageName];
        [self titleLabelWithText:title];
        [self progressBar];
        [self arrowBtn];
        if (showSeparatorLine) {
            [self separatorLine];
        }
        
        UITapGestureRecognizer *_tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapHeader)];
        [self addGestureRecognizer:_tapGestureRecognizer];
         //(_tapGestureRecognizer);

    }
    return self;
}

- (void)dealloc {
    _delegate = nil;
     //(_iconView);
     //(_titleLabel);
     //(_arrowBtn);
     //(_separatorLine);
     //(_sectionTag);
     //(_progressBar);
}

#pragma mark - Override

- (void)iconViewWithIconImangeName:(NSString *)iconImageName {
    if (!iconImageName || [@"" isEqualToString:iconImageName]) {
        iconImageName = @"search_category_sub.png";
    }
    if (!_iconView) {
        _iconView = [[UIImageView alloc] initWithFrame:CGRectMake(kIConLeft,
                                                                  (CGRectGetHeight(self.frame)-(kDownloadingTableViewInsetBottom-kDownloadingTableViewInsetTop)-kIconHeight)/2.0f+(kDownloadingTableViewInsetBottom-kDownloadingTableViewInsetTop),
                                                                  kIconWidth,
                                                                  kIconHeight)];
        _iconView.backgroundColor = [UIColor clearColor];
        _iconView.image = [UIImage imageNamed:iconImageName];
        [self addSubview:_iconView];
    }
}

- (void)titleLabelWithText:(NSString *)text {
    if (!_titleLabel) {
        _titleLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _titleLabel.frame = CGRectMake(CGRectGetMaxX(_iconView.frame)+kTitleMarginLeftToIcon,
                                       0,
                                       kTitleWidth,
                                       kTitleHeight);
        CGPoint _center = _titleLabel.center;
        _center.y = _iconView.center.y+2;
        _titleLabel.center = _center;
        
        _titleLabel.backgroundColor = [UIColor clearColor];
        _titleLabel.textAlignment = NSTextAlignmentLeft;
        _titleLabel.textColor = [UIColor colorFromString:[[SNThemeManager sharedThemeManager] currentThemeValueForKey:kDownloadSettingCellTitleColor]];
        _titleLabel.font = [UIFont systemFontOfSize:kTitleLabelFontSize];
        _titleLabel.text = text;
        [self addSubview:_titleLabel];
    }
}

- (SNDownloadingProgressBar *)progressBar {
    if (!_progressBar) {
        _progressBar = [[SNDownloadingProgressBar alloc] initWithFrame:CGRectMake(CGRectGetMaxX(_titleLabel.frame)+5,
                                                                                  CGRectGetMidY(_titleLabel.frame)-kProgressBarHeight/2.0f-1,
                                                                                  kProgressBarWidth,
                                                                                  kProgressBarHeight)];
        [self addSubview:_progressBar];
    }
    return _progressBar;
}

- (UIButton *)arrowBtn {
    if (!_arrowBtn) {
        _arrowBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _arrowBtn.backgroundColor = [UIColor clearColor];
        _arrowBtn.frame = CGRectMake(CGRectGetWidth(self.frame)-kActionBtnWidth, 0, kActionBtnWidth, kActionBtnHeight);
        CGPoint _center = _arrowBtn.center;
        _center.y = _iconView.center.y;
        _arrowBtn.center = _center;
        
        BOOL _isFolded = NO;
        if ([kDownloadingSubSectionDataTag isEqualToString:_sectionTag]) {//刊物section
            _isFolded = [[NSUserDefaults standardUserDefaults] boolForKey:kDownloadingSubSectionHeaderIsFolded];
        }
        else if ([kDownloadingNewsSectionDataTag isEqualToString:_sectionTag]) {//新闻section
            _isFolded = [[NSUserDefaults standardUserDefaults] boolForKey:kDownloadingNewsSectionHeaderIsFolded];
        }
        [self foldArrow:_isFolded];
        [self addSubview:_arrowBtn];
    }
    return _arrowBtn;
}

- (UIImageView *)separatorLine {
    if (!_separatorLine) {
        _separatorLine = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"download_setting_cellseperatorbg.png"]];
        _separatorLine.frame = CGRectMake(10, 0, CGRectGetWidth(self.frame)-20, 1);
        [self addSubview:_separatorLine];
    }
    return _separatorLine;
}

#pragma mark - Public methods

- (void)updateProgres:(CGFloat)progress {
    [self.progressBar updateProgress:progress];
}

- (void)resetProgress {
    [self.progressBar resetProgress];
}

#pragma mark - Private methods

- (void)foldArrow:(BOOL)folded {
    if (!!_arrowBtn) {
        [_arrowBtn removeTarget:self action:@selector(fold) forControlEvents:UIControlEventTouchUpInside];
        [_arrowBtn removeTarget:self action:@selector(unfold) forControlEvents:UIControlEventTouchUpInside];
        if ([kDownloadingSubSectionDataTag isEqualToString:_sectionTag]) {//刊物section
            [[NSUserDefaults standardUserDefaults] setBool:folded forKey:kDownloadingSubSectionHeaderIsFolded];
            [[NSUserDefaults standardUserDefaults] synchronize];
        }
        else if ([kDownloadingNewsSectionDataTag isEqualToString:_sectionTag]) {//新闻section
            [[NSUserDefaults standardUserDefaults] setBool:folded forKey:kDownloadingNewsSectionHeaderIsFolded];
            [[NSUserDefaults standardUserDefaults] synchronize];
        }
        if (folded) {
            [_arrowBtn setImage:[UIImage imageNamed:@"download_setting_folded.png"] forState:UIControlStateNormal];
            [_arrowBtn addTarget:self action:@selector(unfold) forControlEvents:UIControlEventTouchUpInside];
        } else {
            [_arrowBtn setImage:[UIImage imageNamed:@"download_setting_unfolded.png"] forState:UIControlStateNormal];
            [_arrowBtn addTarget:self action:@selector(fold) forControlEvents:UIControlEventTouchUpInside];
        }
    }
}

- (void)tapHeader {
    BOOL _isFolded = NO;
    if ([kDownloadingSubSectionDataTag isEqualToString:_sectionTag]) {//刊物section
        _isFolded = [[NSUserDefaults standardUserDefaults] boolForKey:kDownloadingSubSectionHeaderIsFolded];
    }
    else if ([kDownloadingNewsSectionDataTag isEqualToString:_sectionTag]) {//新闻section
        _isFolded = [[NSUserDefaults standardUserDefaults] boolForKey:kDownloadingNewsSectionHeaderIsFolded];
    }
    if (_isFolded) {
        [self unfold];
    } else {
        [self fold];
    }
}

- (void)fold {
    [self foldArrow:YES];
    if ([_delegate respondsToSelector:@selector(foldAtSectionTag:)]) {
        [_delegate foldAtSectionTag:_sectionTag];
    }
}

- (void)unfold {
    [self foldArrow:NO];
    if ([_delegate respondsToSelector:@selector(unfoldAtSectionTag:)]) {
        [_delegate unfoldAtSectionTag:_sectionTag];
    }
}

@end
