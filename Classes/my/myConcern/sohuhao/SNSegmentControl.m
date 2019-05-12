//
//  SNSegmentControl.m
//  sohunews
//
//  Created by HuangZhen on 2017/6/8.
//  Copyright © 2017年 Sohu.com. All rights reserved.
//

#import "SNSegmentControl.h"

@interface SNSegmentButton : UIButton

@property (nonatomic, assign) NSInteger index;

@end

@implementation SNSegmentButton

@end

@interface SNSegmentControl(){
    NSArray * _buttonSource;
    NSArray * _segLineSource;
    SNSegmentButton * _lastSelectedButton;
    SNSegmentButton * _currentSelectedButton;
    CGFloat _buttonWidth;
    UIView * _bottomLine;
}

@end

@implementation SNSegmentControl

#pragma mark - public
- (instancetype)initWithFrame:(CGRect)frame  {
    if (self = [super initWithFrame:frame]) {
        self.backgroundColor = [UIColor colorFromString:[[SNThemeManager sharedThemeManager] currentThemeValueForKey:kBackgroundColor]];
        _bottomLine = [[UIView alloc] initWithFrame:CGRectMake(0, frame.size.height - 1, frame.size.width, 0.5)];
        _bottomLine.backgroundColor = SNUICOLOR(kThemeBg1Color);
        [self addSubview:_bottomLine];
    }
    return self;
}

- (void)setTabs:(NSArray *)tabTitles {
    _tabsCount = tabTitles.count;
    if (tabTitles.count > 0) {
        _buttonWidth = self.width/tabTitles.count;
        int i = 0;
        NSMutableArray * m_buttons = [NSMutableArray array];
        NSMutableArray * m_lines = [NSMutableArray array];
        for (NSString * tabTitle in tabTitles) {
            if ([tabTitle isKindOfClass:[NSString class]]) {
                SNSegmentButton * button = [self createButtonWithTitle:tabTitle index:i];
                [self addSubview:button];
                [m_buttons addObject:button];
                if (i == 0) {//默认选中第一个tab
                    button.selected = YES;
                    _lastSelectedButton = button;
                }
                if (i < tabTitles.count - 1) {//最后一个不需要分割线
                    UIView * segLine = [[UIView alloc] initWithFrame:CGRectMake(button.right, 7, 0.5, 46/2.f)];
                    segLine.centerY = self.height/2.f;
                    segLine.backgroundColor = SNUICOLOR(kThemeBg1Color);
                    [self addSubview:segLine];
                    [m_lines addObject:segLine];
                }
            }
            _buttonSource = [NSArray arrayWithArray:m_buttons];
            _segLineSource = [NSArray arrayWithArray:m_lines];
            i++;
        }
    }
}

- (void)updateTheme {
    _bottomLine.backgroundColor = SNUICOLOR(kThemeBg1Color);
    for (UIButton * button in _buttonSource) {
        if ([button isKindOfClass:[UIButton class]]) {
            [button setTitleColor:SNUICOLOR(kThemeText3Color) forState:UIControlStateNormal];
            [button setTitleColor:SNUICOLOR(kThemeRed1Color) forState:UIControlStateSelected];
        }
    }
    for (UIView * line in _segLineSource) {
        if ([line isKindOfClass:[UIView class]]) {
            line.backgroundColor = SNUICOLOR(kThemeBg1Color);
        }
    }
}

- (void)setScrollView:(UIScrollView *)scrollView {
    _scrollView = scrollView;
    [_scrollView addObserver:self
                  forKeyPath:@"contentOffset"
                     options:NSKeyValueObservingOptionNew
                     context:NULL];
    _scrollView.contentSize = CGSizeMake(self.width * _buttonSource.count, _scrollView.height);
    if (_lastSelectedButton) {
        [_scrollView setContentOffset:CGPointMake(self.width * _lastSelectedButton.index, 0)];
    }
}

#pragma mark - Observer
- (void)observeValueForKeyPath:(NSString *)keyPath
                      ofObject:(id)object
                        change:(NSDictionary *)change
                       context:(void *)context {
    if (object == _scrollView &&
        [keyPath isEqualToString:@"contentOffset"]) {
        [self scrollViewDidScroll:_scrollView];
    }
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    CGFloat offsetX = scrollView.contentOffset.x;
    CGFloat tabIndexf = offsetX/scrollView.width;
    if (0.0f == fmodf(tabIndexf, 1.0f)) {
        NSInteger tabIndex = MIN((int)_buttonSource.count - 1, tabIndexf);
        if (tabIndex < _buttonSource.count) {
            SNSegmentButton * button = _buttonSource[tabIndex];
            if ([button isKindOfClass:[SNSegmentButton class]]) {
                if (!button.selected) {
                    button.selected = YES;
                    _lastSelectedButton.selected = NO;
                    _lastSelectedButton = button;
                }
            }
        }
    }
}

#pragma mark - private

- (SNSegmentButton *)createButtonWithTitle:(NSString *)title index:(NSInteger)index {
    SNSegmentButton * button = [SNSegmentButton buttonWithType:UIButtonTypeCustom];
    button.frame = CGRectMake(index * _buttonWidth, 0, _buttonWidth, self.height);
    button.index = index;
    button.titleLabel.font = [UIFont systemFontOfSize:kThemeFontSizeG];
    [button setTitle:title forState:UIControlStateNormal];
    [button setTitleColor:SNUICOLOR(kThemeText3Color) forState:UIControlStateNormal];
    [button setTitleColor:SNUICOLOR(kThemeRed1Color) forState:UIControlStateSelected];
    [button addTarget:self action:@selector(switchTab:) forControlEvents:UIControlEventTouchUpInside];
    return button;
}

- (void)switchTab:(SNSegmentButton *)button {
    if (button.selected) {
        return;
    }
    if (_lastSelectedButton) {
        _lastSelectedButton.selected = NO;
    }
    button.selected = YES;
    _lastSelectedButton = button;
    CGFloat offsetX = button.index * _scrollView.width;
    [_scrollView setContentOffset:CGPointMake(offsetX, 0) animated:YES];
}

- (void)removeListener {
    if (_scrollView) {
        [_scrollView removeObserver:self forKeyPath:@"contentOffset"];
        _scrollView.delegate = nil;
        _scrollView = nil;
    }
}

- (void)dealloc {
    if (_scrollView) {
        [_scrollView removeObserver:self forKeyPath:@"contentOffset"];
        _scrollView.delegate = nil;
        _scrollView = nil;
    }
}

@end
