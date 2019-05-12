//
//  SNCorpusTitleCell.m
//  sohunews
//
//  Created by Scarlett on 15/9/1.
//  Copyright (c) 2015年 Sohu.com. All rights reserved.
//

#import "SNCorpusTitleCell.h"
#import "NSCellLayout.h"
#import "SNCollectStateView.h"

#define kTitleLableTopDistance 36/2.0

@interface SNCorpusTitleCell () {

    UILabel *_titleLabel;
    UILabel *_timeLabel;
    SNCollectStateView *_collectStateView;
    CGFloat _titleLabelWidth;
    BOOL _isEditMode;
}

@end

@implementation SNCorpusTitleCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.selectionStyle = UITableViewCellSelectionStyleDefault;
        UIView *bgImageView = [[UIView alloc] init];
        bgImageView.backgroundColor = SNUICOLOR(kThemeBg2Color);
        [self setSelectedBackgroundView:bgImageView];
        [self setCellFrame];
        
        [self initSelectButton];
        [self initTitleLabel];
        [self initTimeLabel];
        [self initStateView];
    }
    return self;
}


- (void)initTitleLabel {
    if (!_titleLabel) {
        _titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, kAppScreenWidth-CONTENT_LEFT*2, [SNUtility getNewsTitleFontSize]*3)];
        _titleLabel.left = CONTENT_LEFT;
        _titleLabel.top = CONTENT_LEFT-4;
        _titleLabel.backgroundColor = [UIColor clearColor];
        _titleLabel.textColor = SNUICOLOR(kThemeTextRIColor);
        _titleLabel.numberOfLines = 2;
        _titleLabel.font = [SNUtility getNewsTitleFont];
        _titleLabel.textAlignment = NSTextAlignmentLeft;
        [self addSubview:_titleLabel];
    }
}

- (void)initTimeLabel {
    if (!_timeLabel) {
        _timeLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, kAppScreenWidth-CONTENT_LEFT*2, CONTENT_LEFT)];
        _timeLabel.right = kAppScreenWidth - CONTENT_LEFT;
        _timeLabel.backgroundColor = [UIColor clearColor];
        _timeLabel.textColor = SNUICOLOR(kThemeText3Color);
        _timeLabel.font = [UIFont systemFontOfSize:kThemeFontSizeB];
        _timeLabel.textAlignment = NSTextAlignmentRight;
        [self addSubview:_timeLabel];
    }
}

- (void)initStateView {
    if (_collectStateView == nil) {
        _collectStateView = [[SNCollectStateView alloc] initWithFrame:CGRectMake(CONTENT_LEFT, 0, kAppScreenWidth - _timeLabel.width, 0)];
        _collectStateView.bottom = self.height;
        [self addSubview:_collectStateView];
    }
}


- (void)setCellInfoWithTitle:(NSString *)title time:(NSString *)time ids:(NSString *)ids isEditMode:(BOOL)isEditMode link:(NSString *)link isItemSelected:(BOOL)isItemSelected hideStateView:(BOOL)hide status:(NSString *)status remark:(NSString *)remark {
    _collectStateView.hidden = hide;
    if ([status isEqualToString:@"2"]) {
        _collectStateView.collectState = SNCollectStatePublished;
    } else {
        _collectStateView.collectState = SNCollectStateUnaudited;
    }
    if (remark.length > 0) {
        _collectStateView.stateMessage = remark;
    }
    _titleLabel.text = title;
    _timeLabel.text = [NSDate relativelyDate:time];
    [_timeLabel sizeToFit];
     _timeLabel.right = kAppScreenWidth - CONTENT_LEFT;
    [self resetLabel];
    
    self.idsString = ids;
    self.linkString = link;
    _isEditMode = isEditMode;
    if (_isEditMode) {
        [self setEditMode];
    }
    else {
        [self setNormalMode];
    }
    _selectButton.centerY = self.height/2;
    _selectButton.selected = isItemSelected;
}

- (void)resetLabel {
    _titleLabel.font = [SNUtility getNewsTitleFont];
    [_titleLabel sizeToFit];
    _titleLabel.width = kAppScreenWidth - 2*CONTENT_LEFT;
    
    [self setCellFrame];
    
    _timeLabel.bottom = _titleLabel.bottom + kTitleLableTopDistance;
    _collectStateView.centerY = _timeLabel.centerY;
}

- (void)setCellFrame {
    self.frame = CGRectMake(self.frame.origin.x, self.frame.origin.y, kAppScreenWidth, kTitleLableTopDistance*2 + _titleLabel.height);
}

+ (CGFloat)getCellHeight:(NSString *)title {
    UILabel *label = [[UILabel alloc] init];
    label.font = [SNUtility getNewsTitleFont];
    label.text = title;
    label.numberOfLines = 2;
    label.width  = kAppScreenWidth-CONTENT_LEFT*2;
    [label sizeToFit];
    
    return kTitleLableTopDistance*2 + label.height ;
}

- (void)setEditMode {
    
    _selectButton.left = kSelectButtonLeftDistance;
    _titleLabel.left = _selectButton.right + kSelectButtonLeftDistance;
    _titleLabel.width = kAppScreenWidth - CONTENT_LEFT - _selectButton.right - kSelectButtonLeftDistance;}

- (void)setNormalMode {
    
    _selectButton.right = 0;
    _titleLabel.left = CONTENT_LEFT;
    _titleLabel.width = kAppScreenWidth - 2*CONTENT_LEFT;
}

- (void)updateTheme {
    [super updateTheme];
    _titleLabel.textColor = SNUICOLOR(kThemeTextRIColor);
    _timeLabel.textColor = SNUICOLOR(kThemeText3Color);
}

@end
