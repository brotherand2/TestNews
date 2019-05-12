//
//  SNSubCenterAllSubsCell.m
//  sohunews
//
//  Created by wang yanchen on 12-11-22.
//  Copyright (c) 2012年 Sohu.com Inc. All rights reserved.
//

#import "SNSubCenterAllSubsCell.h"
#import "UIColor+ColorUtils.h"
#import "SNStarGradeView.h"
#import "CacheObjects.h"
#import "SNSubCenterSubsHelper.h"
#import "SNWaitingActivityView.h"

#define kSubButtonRightMargin               0//(28 / 2)
#define kSubButtonTopMargin                 (43 / 2)
#define kSubButtonSize                      (100 / 2)

#define kSubIconBgnTopMargin                (18 / 2)
#define kSubIconBgnLeftMargin               (28 / 2)
#define kSubIconBgnSize                     (78 / 2)
#define kSubIconSize                        (74 / 2)

#define kSubNameLabelLeftMargin             (16 / 2)
#define kSubNameLabelTopMargin              (26 / 2)
#define kSubNameLabelRgithMargin            (kSubButtonRightMargin + kSubButtonSize - 5)
#define kSubNameLabelFont                   (30 / 2)

#define kStarGradeViewTopMargin             (4 / 2)

#define kSubPersonCountTopMargin            (4 / 2)
#define kSubPersonCountFont                 (16 / 2)

@implementation SNSubCenterAllSubsCell
@synthesize subObj = _subObj;
@synthesize delegate = _delegate;
@synthesize isRunning = _isRunning;

- (void)dealloc {
    [SNNotificationManager removeObserver:self];
    
    _delegate = nil;
     //(_subObj);
     //(_subButton);
     //(_loadingView);
     //(_sepLine);
     //(_subIconView);
     //(_subIconBgnView);
     //(_subNameLabel);
     //(_starGradeView);
     //(_subPersonCountLabel);
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        [SNNotificationManager addObserver:self selector:@selector(updateTheme) name:kThemeDidChangeNotification object:nil];
    }
    return self;
}

- (void)setSubObj:(SCSubscribeObject *)subObj {
    if (_subObj != subObj) {
         //(_subObj);
        _subObj = subObj;
    }
    
    [self setNeedsLayout];
}

- (void)setIsRunning:(BOOL)isRunning {
    _isRunning = isRunning;
    if (_isRunning) {
        if (!_loadingView) {
            _loadingView = [[SNWaitingActivityView alloc] init];
            [self insertSubview:_loadingView aboveSubview:_subButton];
        }
        
        _loadingView.centerY = _subButton.centerY;
        _loadingView.right = self.width - kSubButtonRightMargin - 14;
        [_loadingView startAnimating];
        _subButton.hidden = YES;
    }
    else {
        [_loadingView stopAnimating];
        _subButton.hidden = NO;
    }
}

- (void)showSelectedBg:(BOOL)show
{
    if (show) {
        if (!_cellSelectedBg) {
            _cellSelectedBg = [[UIImageView alloc] init];
            
            [self insertSubview:_cellSelectedBg atIndex:0];
        }
        _cellSelectedBg.frame = self.bounds;
        _cellSelectedBg.image = [UIImage imageNamed:@"cell-press.png"];
        _cellSelectedBg.alpha = 1;
    } else {
        [UIView beginAnimations:nil context:nil];
        [UIView setAnimationDelay:TT_FAST_TRANSITION_DURATION];
        _cellSelectedBg.alpha = 0;
        [UIView commitAnimations];
    }
}

- (void)updateTheme {//kSubCellHeight
    [self setNeedsDisplay];
    
    _subIconBgnView.alpha = themeImageAlphaValue();
    UIEdgeInsets insets = UIEdgeInsetsMake(2, 2, 2, 2);
    UIImage *subIconBgImg = [[UIImage themeImageNamed:@"bgsquare_journal_v5.png"] resizableImageWithCapInsets:insets resizingMode:UIImageResizingModeStretch];
    _subIconBgnView.image = subIconBgImg;
    _subIconView.defaultImage = [UIImage imageNamed:kThemeImgPlaceholder2/*@"defaulticon.png"*/];
    _subNameLabel.textColor = [UIColor colorFromString:[[SNThemeManager sharedThemeManager] currentThemeValueForKey:kSubCenterAllSubNameTextColor]];
    
    if (_starGradeView) {
        SNStarGradeView *aNewGradeView = [[SNStarGradeView alloc] initWithStyle:SNStarGradeViewStyleSmall canEdit:NO];
        aNewGradeView.frame = _starGradeView.frame;
        aNewGradeView.grade = _starGradeView.grade;
        
        [self addSubview:aNewGradeView];
        
        [_starGradeView removeFromSuperview];
         //(_starGradeView);
        _starGradeView = aNewGradeView;
    }
    
    _subPersonCountLabel.textColor = [UIColor colorFromString:[[SNThemeManager sharedThemeManager] currentThemeValueForKey:kSubCenterAllSubPersonCountTextColor]];
    
    if ([@"1" isEqualToString:_subObj.isSubscribed]) {
        [_subButton setImageEdgeInsets:UIEdgeInsetsMake(0, 20, 0, 0)];
        [_subButton setTitle:@"已关注" forState:UIControlStateNormal];
        [_subButton setTitleColor:SNUICOLOR(kThemeText4Color) forState:UIControlStateNormal];
        _subButton.centerY = CGRectGetMidY(self.bounds);
        _subButton.right = self.width - kSubButtonRightMargin;
        [_subButton setAccessibilityLabel:@"已经关注"];
    }
    else {
//        UIImage *btnImage = [UIImage imageNamed:@"subcenter_allsub_addsub.png"];
        [_subButton setImageEdgeInsets:UIEdgeInsetsZero];
        [_subButton setTitle:@"关注" forState:UIControlStateNormal];
        [_subButton setTitleColor:SNUICOLOR(kThemeGreen1Color) forState:UIControlStateNormal];
        _subButton.centerY = CGRectGetMidY(self.bounds);
        _subButton.right = self.width - kSubButtonRightMargin;
//        [_subButton setImage:btnImage forState:UIControlStateNormal];
        //        [_subButton setImage:[UIImage themeImageNamed:@"subcenter_allsub_addsub.png"] forState:UIControlStateHighlighted];
        [_subButton setAccessibilityLabel:@"添加关注"];
    }
}

- (void)setHighlighted:(BOOL)highlighted animated:(BOOL)animated {
    [self showSelectedBg:highlighted];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    // Configure the view for the selected state
    [self showSelectedBg:selected];
}

- (void)drawRect:(CGRect)rect {
	[super drawRect:rect];
//    [UIView drawCellSeperateLine:rect margin:0];
	
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    if (!_subIconBgnView) {
        _subIconBgnView = [[UIImageView alloc] initWithFrame:CGRectMake(kSubIconBgnLeftMargin,
                                                                        (kSubCellHeight-kSubIconBgnSize)/2.0f,
                                                                        kSubIconBgnSize,
                                                                        kSubIconBgnSize)];
        UIEdgeInsets insets = UIEdgeInsetsMake(2, 2, 2, 2);
        UIImage *subIconBgImg = [[UIImage themeImageNamed:@"bgsquare_journal_v5.png"] resizableImageWithCapInsets:insets resizingMode:UIImageResizingModeStretch];
        _subIconBgnView.image = subIconBgImg;
        [self addSubview:_subIconBgnView];
    }
    
    if (!_subIconView) {
        _subIconView = [[SNWebImageView alloc] initWithFrame:CGRectMake((kSubIconBgnSize-kSubIconSize)/2.0f,
                                                                        (kSubIconBgnSize-kSubIconSize)/2.0f,
                                                                        kSubIconSize,
                                                                        kSubIconSize)];
        _subIconView.contentMode = UIViewContentModeScaleAspectFit;
        _subIconView.showFade = NO;
        _subIconView.defaultImage = [UIImage imageNamed:kThemeImgPlaceholder2/*@"defaulticon.png"*/];
        [_subIconBgnView addSubview:_subIconView];
        _subIconView.center = CGPointMake(_subIconBgnView.width / 2, _subIconBgnView.height / 2);
    }
    
    [_subIconView unsetImage];
    if ([_subObj.subIcon length] > 0) {
        [_subIconView loadUrlPath:_subObj.subIcon];
    }
    else {
        _subIconView.defaultImage = [UIImage imageNamed:kThemeImgPlaceholder2/*@"defaulticon.png"*/];
    }
    
    CGFloat subNameLabelHeight = kSubNameLabelFont + 2;
    CGFloat subPersonCountLabelHeight =  kSubPersonCountFont + 2;
    CGFloat subNameLabelTop = (kSubCellHeight-subNameLabelHeight-kStarGradeViewTopMargin-kGradeViewHeightSmall-kSubPersonCountTopMargin-subPersonCountLabelHeight)/2.0f;
    if (!_subNameLabel) {
        _subNameLabel = [[UILabel alloc] initWithFrame:CGRectMake(_subIconBgnView.right + kSubNameLabelLeftMargin,
                                                                  subNameLabelTop,
                                                                  self.width - _subIconBgnView.right - kSubNameLabelLeftMargin - kSubNameLabelRgithMargin,
                                                                  subNameLabelHeight)];
        _subNameLabel.backgroundColor = [UIColor clearColor];
        _subNameLabel.font = [UIFont systemFontOfSize:kThemeFontSizeC];
        _subNameLabel.textColor = [UIColor colorFromString:[[SNThemeManager sharedThemeManager] currentThemeValueForKey:kThemeText1Color]];
        [self addSubview:_subNameLabel];
    }
    
    _subNameLabel.text = _subObj.subName;
    
    if (!_starGradeView) {
        _starGradeView = [[SNStarGradeView alloc] initWithStyle:SNStarGradeViewStyleSmall canEdit:NO];
        _starGradeView.top = _subNameLabel.bottom + kStarGradeViewTopMargin;
        _starGradeView.left = _subNameLabel.left;
        [self addSubview:_starGradeView];
    }
    
    _starGradeView.grade = [_subObj.starGrade floatValue];
    
    if (!_subPersonCountLabel) {
        _subPersonCountLabel = [[UILabel alloc] initWithFrame:CGRectMake(_subNameLabel.left,
                                                                         _starGradeView.bottom + kSubPersonCountTopMargin,
                                                                         _subNameLabel.width,
                                                                         subPersonCountLabelHeight)];
        _subPersonCountLabel.backgroundColor = [UIColor clearColor];
        _subPersonCountLabel.font = [UIFont systemFontOfSize:kThemeFontSizeA];
        _subPersonCountLabel.textColor = [UIColor colorFromString:[[SNThemeManager sharedThemeManager] currentThemeValueForKey:kThemeText4Color]];
        
        [self addSubview:_subPersonCountLabel];
    }
    
    _subPersonCountLabel.text = _subObj.countShowText;
    
    if (!_subButton) {
        _subButton = [[UIButton alloc] initWithFrame:CGRectMake(self.width - kSubButtonRightMargin - kSubButtonSize, (self.height - kSubButtonSize) / 2, kSubButtonSize, kSubButtonSize)];
        [_subButton addTarget:self action:@selector(subBtnClick) forControlEvents:UIControlEventTouchUpInside];
        _subButton.exclusiveTouch = YES;
        _subButton.backgroundColor =  [UIColor clearColor];
        [_subButton.titleLabel setFont:[UIFont systemFontOfSize:kThemeFontSizeC]];
        [self addSubview:_subButton];
    }
    
    if ([@"1" isEqualToString:_subObj.isSubscribed]) {
        [_subButton setTitle:@"已关注" forState:UIControlStateNormal];
        [_subButton setTitleColor:SNUICOLOR(kThemeText4Color) forState:UIControlStateNormal];
        _subButton.centerY = CGRectGetMidY(self.bounds);
        _subButton.right = self.width - kSubButtonRightMargin;

        [_subButton setAccessibilityLabel:@"已经关注"];
    }
    else {
//        UIImage *btnImage = [UIImage imageNamed:@"subcenter_allsub_addsub.png"];
//        [_subButton setImageEdgeInsets:UIEdgeInsetsZero];
        [_subButton setTitle:@"关注" forState:UIControlStateNormal];
        [_subButton setTitleColor:SNUICOLOR(kThemeGreen1Color) forState:UIControlStateNormal];
        _subButton.centerY = CGRectGetMidY(self.bounds);
        _subButton.right = self.width - kSubButtonRightMargin;
//        [_subButton setImage:btnImage forState:UIControlStateNormal];
//        [_subButton setImage:[UIImage themeImageNamed:@"subcenter_allsub_addsub.png"] forState:UIControlStateHighlighted];
        [_subButton setAccessibilityLabel:@"添加关注"];
    }
    
//    if (!_sepLine) {
//        _sepLine = [[UIImageView alloc] initWithImage:[UIImage themeImageNamed:@"subcenter_allsub_cellsepline.png"]];
//        _sepLine.left = 0;
//        _sepLine.top = self.height;
//        [self addSubview:_sepLine];
//    }
}

- (void)subBtnClick {
    if ([@"1" isEqualToString:_subObj.isSubscribed]) {
        // 已经订阅的情况下  这里什么也不做
    }
    else {
        // 非订阅情况下，触发订阅的操作
        if ([_delegate respondsToSelector:@selector(allSubCellWillAddMySub:)]) {
            [_delegate allSubCellWillAddMySub:self.subObj];
        }
//        if ([_delegate respondsToSelector:@selector(allSubCell:willAddMySub:)]) {
//            [_delegate allSubCell:self willAddMySub:self.subObj];
//        }
    }
}

@end
