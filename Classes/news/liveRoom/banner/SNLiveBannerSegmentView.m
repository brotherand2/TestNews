//
//  SNLiveBannerSegmentView.m
//  sohunews
//
//  Created by wang yanchen on 13-5-2.
//  Copyright (c) 2013年 Sohu.com. All rights reserved.
//

#import "SNLiveBannerSegmentView.h"
#import "UIColor+ColorUtils.h"
#import "SNLiveRoomConsts.h"

#define kLiveBannerSegmentViewFontSize                  (28 / 2)
#define kLiveBannerSegmentViewSpace                     (28 / 2)
#define kLiveBannerSegmentViewSideMargin                (20 / 2)
#define kLiveBannerSegmentViewBottomMargin              (16 / 2)

#define kLiveBannerSegmentViewExBtnFont                 (22 / 2)
#define kLiveBannerSegmentViewExBtnBottomMargin         (12 / 2)
#define kLiveBannerSegmentViewExBtnRightMargin          (18 / 2)
#define kLiveBannerSegmentViewExBtnMidSpace             (10 / 2)
#define kLiveBannerSegmentViewExBtnImageRightMargin     (76 / 2)

#define kExpandBtnCenterY 16

@implementation SNLiveBannerSegmentView
@synthesize currentIndex = _currentIndex;
@synthesize hasExpanded = _hasExpanded;

- (id)initWithFrame:(CGRect)frame {
    CGRect appFrame = [[UIScreen mainScreen] applicationFrame];
    CGRect viewFrame = CGRectMake(0, 0,
                                  appFrame.size.width,
                                  kLiveBannerSegmentViewHeight);
    self = [super initWithFrame:viewFrame];
    if (self) {
    }
    return self;
}

- (void)createWithSectionsArray:(NSArray *)sections hasExpandButton:(BOOL)hasExpandButton isExpand:(BOOL)isExpand  {
    self.backgroundColor = [UIColor clearColor];
    //self.clipsToBounds = YES;
    
    UIImage *bottomImage = [UIImage imageNamed: @"live_arrow_line.png"];
    _bottomView = [[UIImageView alloc] initWithImage:bottomImage];
    _bottomView.bottom = self.height - 0.5;
    [self addSubview:_bottomView];
    
    if (self.isWorldCup) {
        UIView *topView = [[UIView alloc] initWithFrame:CGRectMake(0, -2, self.width, self.height - _bottomView.height+2)];
        topView.backgroundColor = [UIColor colorFromString:@"#e24508"];
        [self addSubview:topView];
    }
    
    UIColor *selectColor, *normalColor;
    if (self.isWorldCup) {
        selectColor = kLiveWorldCupWhiteColor;
        normalColor = kLiveWorldCupWhiteAlphaColor;
    } else {
        selectColor = [SNSkinManager color:SkinRed];
        normalColor = [UIColor colorFromString:[[SNThemeManager sharedThemeManager] currentThemeValueForKey:kRollingNewsChannelNormalTextColor]];
    }
    
    UIFont *titleFont = [UIFont systemFontOfSize:kLiveBannerSegmentViewFontSize];
    _segmentViews = [[NSMutableArray alloc] init];
    CGFloat startX = kLiveBannerSegmentViewSideMargin;
    CGFloat startY = kLiveBannerSegmentViewHeight - kLiveBannerSegmentViewFontSize - kLiveBannerSegmentViewBottomMargin;
    CGFloat btnSpace = kLiveBannerSegmentViewSpace;
    int index = 0;
    
    for (NSString *title in sections) {
        CGSize titleSize = [title sizeWithFont:titleFont];
        
        UIButton *btn = [[UIButton alloc] initWithFrame:CGRectMake(startX, startY,
                                                                   titleSize.width,
                                                                   titleSize.height)];
        btn.tag = index;
        [btn setTitle:title forState:UIControlStateNormal];
        [btn setTitleColor:normalColor forState:UIControlStateNormal];
        [btn setTitleColor:selectColor forState:UIControlStateSelected];
        [btn.titleLabel setFont:titleFont];
        
        [btn addTarget:self
                action:@selector(titleTouched:)
      forControlEvents:UIControlEventTouchUpInside];
        
        [_segmentViews addObject:btn];
        [self addSubview:btn];
        
        if (index == 0)
            [btn setSelected:YES];
        
        index++;
        startX += btnSpace + titleSize.width;
    }

    [self moveBottomView:NO];
    
    if (hasExpandButton) {
        self.hasExpanded = isExpand; // 默认伸展状态
        UIImage *arrowImage = [UIImage imageNamed:isExpand?@"live_arrow_up.png":@"live_arrow_down.png"];
        
        _exBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_exBtn setImage:arrowImage forState:UIControlStateNormal];
        [_exBtn setImageEdgeInsets:UIEdgeInsetsMake(5, 30, 0, 0)];
        [_exBtn addTarget:self action:@selector(expandButtonTouched:) forControlEvents:UIControlEventTouchUpInside];
        _exBtn.isAccessibilityElement = NO;
        _exBtn.frame = CGRectMake(self.width - 60, 0, 60, self.height);
        [self addSubview:_exBtn];
    }
}

- (void)dealloc {
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    CGFloat offsetX = scrollView.contentOffset.x;
    
    if (_segmentViews.count > 1) {
        CGFloat viewWidth = scrollView.width;
        CGFloat contentWidth = viewWidth * _segmentViews.count;
        CGRect nextViewFrame = CGRectZero;
        CGRect offsetLineViewFrame = CGRectZero;
        CGRect currentViewFrame = CGRectZero;
        CGFloat nextViewMidX = 0;
        CGFloat offsetLineViewMidX = 0;
        CGFloat midX = 0;
        int offsetLineIndex = (int)offsetX / (int)viewWidth;
        
        offsetLineIndex = MAX(0, offsetLineIndex);
        offsetLineIndex = MIN((int)_segmentViews.count - 2, offsetLineIndex);
        
        if (offsetX <= 0) {
            currentViewFrame = [[_segmentViews objectAtIndex:0] frame];
            midX = CGRectGetMidX(currentViewFrame);
        }
        else if (offsetX >= contentWidth - viewWidth) {
            currentViewFrame = [[_segmentViews lastObject] frame];
            midX = CGRectGetMidX(currentViewFrame);
        }
        else {
            nextViewFrame = [[_segmentViews objectAtIndex:offsetLineIndex + 1] frame];
            nextViewMidX = CGRectGetMidX(nextViewFrame);
            
            offsetLineViewFrame = [[_segmentViews objectAtIndex:offsetLineIndex] frame];
            offsetLineViewMidX = CGRectGetMidX(offsetLineViewFrame);
            
            midX = offsetLineViewMidX + (nextViewMidX - offsetLineViewMidX) * ((offsetX - offsetLineIndex * viewWidth) / viewWidth);
        }
        
        if (midX != 0) {
            _bottomView.centerX = midX;
        }
    }
}

- (void)showPopNewMark:(BOOL)show atIndex:(int)index {
    if (index < _segmentViews.count) {
        if (!_newMarkInfoDic) {
            _newMarkInfoDic = [[NSMutableDictionary alloc] initWithCapacity:_segmentViews.count];
        }
        
        [_newMarkInfoDic setValue:[NSNumber numberWithBool:show] forKey:[NSString stringWithFormat:@"%d", index]];
        
        [self showOrHideNewMark];
    }
}

- (BOOL)hasNewMarkAtIndex:(int)index {
    BOOL bRet = NO;
    if (_newMarkInfoDic) {
        bRet = [[_newMarkInfoDic objectForKey:[NSString stringWithFormat:@"%d", index]] boolValue];
    }
    return bRet;
}

#pragma mark - SNLiveBannerSegmentView - actions
- (void)titleTouched:(id)sender {
    BOOL needMove = self.currentIndex != [(UIView *)sender tag];
    self.currentIndex = [(UIView *)sender tag];
    if (needMove) {
        //        [self moveBottomView:YES];
        [self sendActionsForControlEvents:UIControlEventValueChanged];
    }
    [self sendActionsForControlEvents:UIControlEventTouchUpInside];
}

- (void)expandButtonTouched:(id)sender {
    self.hasExpanded = !self.hasExpanded;
     UIImage *img = self.hasExpanded ? [UIImage imageNamed:@"live_arrow_up.png"] : [UIImage imageNamed:@"live_arrow_down.png"];
    [_exBtn setImage:img forState:UIControlStateNormal];
}

#pragma mark - SNLiveBannerSegmentView - private
- (void)moveBottomView:(BOOL)animated {
    UIButton *currentView = [_segmentViews objectAtIndex:self.currentIndex];
    CGFloat currentCur = currentView.centerX;
    
    if (animated) {
        [UIView animateWithDuration:0.3 animations:^{
            _bottomView.centerX = currentCur;
        } completion:^(BOOL finished) {
            [self resetBtnsState];
        }];
    }
    else {
        _bottomView.centerX = currentCur;
        [self resetBtnsState];
    }
}

- (void)resetBtnsState {
    for (int i = 0; i < _segmentViews.count; ++i) {
        UIButton *btn = [_segmentViews objectAtIndex:i];
        btn.selected = (i == self.currentIndex);
        btn.userInteractionEnabled = i != self.currentIndex;
    }
}

- (void)showOrHideNewMark {
    for (NSString *key in _newMarkInfoDic.allKeys) {
        BOOL bShow = [[_newMarkInfoDic objectForKey:key] boolValue];
        int index = [key intValue];
        
        if (bShow) {
            UIImageView *dotImage = (UIImageView *)[self viewWithTag:index + 100];
            UIImage *dImage = [UIImage imageNamed:@"dot.png"];
            if (!dotImage) {
                dotImage = [[UIImageView alloc] initWithImage:dImage];
                dotImage.tag = index + 100;
                dotImage.top = 0;
                UIButton *btn = [_segmentViews objectAtIndex:index];
                dotImage.left = btn.right + 4;
                [self addSubview:dotImage];
            }
            dotImage.image = dImage;
        }
        else {
            UIImageView *dotImage = (UIImageView *)[self viewWithTag:index + 100];
            if (dotImage) {
                [dotImage removeFromSuperview];
            }
        }
    }
}

- (void)updateTheme {
    NSString *selectColorStr = [[SNThemeManager sharedThemeManager] currentThemeValueForKey:kRollingNewsChannelSelectedTextColor];
    NSString *normalColorStr = [[SNThemeManager sharedThemeManager] currentThemeValueForKey:kRollingNewsChannelNormalTextColor];
    UIColor *selectColor = [UIColor colorFromString:selectColorStr];
    UIColor *normalColor = [UIColor colorFromString:normalColorStr];
    
    UIImage *bottomImage = [UIImage imageNamed:@"live_arrow_line.png"];
    _bottomView.image = bottomImage;
    
    int index = 0;
    for (UIButton *btn in _segmentViews) {
        [btn setTitleColor:normalColor forState:UIControlStateNormal];
        [btn setTitleColor:selectColor forState:UIControlStateSelected];
        [self showPopNewMark:[self hasNewMarkAtIndex:index] atIndex:index];
        index++;
    }
    
    [self resetBtnsState];
    
    if (_exBtn) {
        UIImage *img = self.hasExpanded ? [UIImage imageNamed:@"live_arrow_up.png"] : [UIImage imageNamed:@"live_arrow_down.png"];
        [_exBtn setImage:img forState:UIControlStateNormal];
    }
}

@end
