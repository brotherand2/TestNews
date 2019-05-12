//
//  SNDownloadSettingSectionHeaderView.m
//  sohunews
//
//  Created by handy wang on 1/16/13.
//  Copyright (c) 2013 Sohu.com Inc. All rights reserved.
//

#import "SNDownloadSettingSectionHeaderView.h"
#import <QuartzCore/QuartzCore.h>
#import "SNDownloadSettingViewController.h"
#import "UIColor+ColorUtils.h"

#define kIConLeft                               (22/2.0f)
#define kIconWidth                              (36/2.0f)
#define kIconHeight                             (36/2.0f)

#define kTitleMarginLeftToIcon                  (12/2.0f)
#define kTitleWidth                             (80/2.0f)
#define kTitleHeight                            (36/2.0f)
#define kTitleLabelFontSize                     (34/2.0f)

#define kCountLabelMarginToRightSide            ((174-90)/2.0f)
#define kCountLabelWidth                        (200/2.0f)
#define kCountLabelHeight                       (30/2.0f)
#define kCountLabelFontSize                     (28/2.0f)

#define kActionBtnWidth                         (90/2.0f)
#define kActionBtnHeight                        (90/2.0f)

@interface SNDownloadSettingSectionHeaderView() {
    UIImageView *_iconView;
    UILabel *_titleLabel;
    UILabel *_countLabel;
    UIButton *_checkBox;
    UIButton *_arrowBtn;
    UIImageView *_separatorLine;
}

@property(nonatomic, strong)UIImageView *iconView;
@property(nonatomic, strong)UILabel *titleLabel;
@property(nonatomic, strong)UILabel *countLabel;
@property(nonatomic, strong)UIButton *checkBox;
@property(nonatomic, strong)UIButton *arrowBtn;
@property(nonatomic, strong)UIImageView *separatorLine;

@end


@implementation SNDownloadSettingSectionHeaderView
@synthesize iconView = _iconView;
@synthesize titleLabel = _titleLabel;
@synthesize countLabel = _countLabel;
@synthesize checkBox = _checkBox;
@synthesize arrowBtn = _arrowBtn;
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
        [self countLabel];
        [self checkBox];
        //[self arrowBtn];
        if (showSeparatorLine) {
            [self separatorLine];
        }
        
        UITapGestureRecognizer *_tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapHeader)];
        [_tapGestureRecognizer setDelegate:self];
        [self addGestureRecognizer:_tapGestureRecognizer];
         //(_tapGestureRecognizer);
    }
    return self;
}

- (void)dealloc {
    _delegate = nil;
     //(_iconView);
     //(_titleLabel);
     //(_countLabel);
     //(_checkBox);
     //(_arrowBtn);
     //(_separatorLine);
     //(_sectionTag);
}

#pragma mark - Override

- (void)iconViewWithIconImangeName:(NSString *)iconImageName {
    if (!iconImageName || [@"" isEqualToString:iconImageName]) {
        iconImageName = @"search_category_sub.png";
    }
    if (!_iconView) {
        _iconView = [[UIImageView alloc] initWithFrame:CGRectMake(kIConLeft,
                                                                  (CGRectGetHeight(self.frame)-(kDownloadSettingTableViewInsetBottom-kDownloadSettingTableViewInsetTop)-kIconHeight)/2.0f+(kDownloadSettingTableViewInsetBottom-kDownloadSettingTableViewInsetTop),
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

- (UILabel *)countLabel {
    if (!_countLabel) {
        
        NSInteger x = CGRectGetWidth(self.frame)-kActionBtnWidth-2-2+10-kCountLabelWidth;
        _countLabel = [[UILabel alloc] initWithFrame:CGRectMake(x, 0, kCountLabelWidth, kCountLabelHeight)];
        CGPoint _center = _countLabel.center;
        _center.y = _iconView.center.y+2;
        _countLabel.center = _center;
        
        _countLabel.backgroundColor = [UIColor clearColor];
        _countLabel.textAlignment = NSTextAlignmentRight;
        _countLabel.textColor = [UIColor colorFromString:[[SNThemeManager sharedThemeManager] currentThemeValueForKey:kDownloadSettingSelectCountColor]];
        _countLabel.font = [UIFont systemFontOfSize:kCountLabelFontSize];
        //_countLabel.text = @"已选0/0个";
        [self addSubview:_countLabel];
    }
    return _countLabel;
}

- (UIButton *)checkBox {
    if (!_checkBox) {
        _checkBox = [UIButton buttonWithType:UIButtonTypeCustom];
        _checkBox.backgroundColor = [UIColor clearColor];
        _checkBox.frame = CGRectMake(CGRectGetWidth(self.frame)-kActionBtnWidth-2-2, 0, kActionBtnWidth, kActionBtnHeight);
        CGPoint _center = _checkBox.center;
        _center.y = _iconView.center.y+1;
        _checkBox.center = _center;
        [self addSubview:_checkBox];
    }
    return _checkBox;
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
        if ([kDownloadSettingSubSectionDataTag isEqualToString:_sectionTag]) {//刊物section
            _isFolded = [[NSUserDefaults standardUserDefaults] boolForKey:kDownloadSettingSubSectionHeaderIsFolded];
        }
        else if ([kDownloadSettingNewsSectionDataTag isEqualToString:_sectionTag]) {//新闻section
            _isFolded = [[NSUserDefaults standardUserDefaults] boolForKey:kDownloadSettingNewsSectionHeaderIsFolded];
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

- (void)selectCheckBox:(BOOL)selectted {
    if (!!_checkBox) {
        _checkBox.selected = selectted;
        [_checkBox removeTarget:self action:@selector(selectAll) forControlEvents:UIControlEventTouchUpInside];
        [_checkBox removeTarget:self action:@selector(unselectAll) forControlEvents:UIControlEventTouchUpInside];
        if (_checkBox.selected) {
            _checkBox.accessibilityLabel = @"全部内容";
            [_checkBox setImage:[UIImage imageNamed:@"download_setting_all_selected.png"] forState:UIControlStateNormal];
            [_checkBox addTarget:self action:@selector(unselectAll) forControlEvents:UIControlEventTouchUpInside];
        } else {
            _checkBox.accessibilityLabel = @"已选定0个内容";
            [_checkBox setImage:[UIImage imageNamed:@"download_setting_atleastone_unselected.png"] forState:UIControlStateNormal];
            [_checkBox addTarget:self action:@selector(selectAll) forControlEvents:UIControlEventTouchUpInside];
        }
    }
}

- (void)setSelectedCount:(NSInteger)selectedCount allCount:(NSInteger)allCount {
    if (!!_countLabel) {
        if (allCount!=0 && (selectedCount==allCount)) {
            [_countLabel setText:NSLocalizedString(@"download_setting_selectedall_title", nil)];
        } else {
            [_countLabel setText:[NSString stringWithFormat:NSLocalizedString(@"download_setting_hadselected_title", nil), selectedCount, allCount]];
        }
    }
}

- (void)foldArrow:(BOOL)folded {
    if (!!_arrowBtn) {
        [_arrowBtn removeTarget:self action:@selector(fold) forControlEvents:UIControlEventTouchUpInside];
        [_arrowBtn removeTarget:self action:@selector(unfold) forControlEvents:UIControlEventTouchUpInside];
        if ([kDownloadSettingSubSectionDataTag isEqualToString:_sectionTag]) {//刊物section
            [[NSUserDefaults standardUserDefaults] setBool:folded forKey:kDownloadSettingSubSectionHeaderIsFolded];
            [[NSUserDefaults standardUserDefaults] synchronize];
        }
        else if ([kDownloadSettingNewsSectionDataTag isEqualToString:_sectionTag]) {//新闻section
            [[NSUserDefaults standardUserDefaults] setBool:folded forKey:kDownloadSettingNewsSectionHeaderIsFolded];
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

#pragma mark - Private methods 

- (void)unselectAll {
    [self selectCheckBox:NO];
    if ([_delegate respondsToSelector:@selector(unselectAllAtSectionTag:)]) {
        [_delegate unselectAllAtSectionTag:_sectionTag];
    }
}

- (void)selectAll {
    [self selectCheckBox:YES];
    if ([_delegate respondsToSelector:@selector(selectAllAtSectionTag:)]) {
        [_delegate selectAllAtSectionTag:_sectionTag];
    }
}

- (void)tapHeader {
    BOOL _isFolded = NO;
    if ([kDownloadSettingSubSectionDataTag isEqualToString:_sectionTag]) {//刊物section
        _isFolded = [[NSUserDefaults standardUserDefaults] boolForKey:kDownloadSettingSubSectionHeaderIsFolded];
    }
    else if ([kDownloadSettingNewsSectionDataTag isEqualToString:_sectionTag]) {//新闻section
        _isFolded = [[NSUserDefaults standardUserDefaults] boolForKey:kDownloadSettingNewsSectionHeaderIsFolded];
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

#pragma mark - UIGestureRecognizerDelegate

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch {
    if ([touch.view isKindOfClass:[UIButton class]]) {
        return NO;
    }
    return YES;
}

@end
