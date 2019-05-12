//
//  SNCorpusChannelTopBar.m
//  sohunews
//
//  Created by TengLi on 2017/9/21.
//  Copyright © 2017年 Sohu.com. All rights reserved.
//

#import "SNCorpusChannelTopBar.h"
#import "NSCellLayout.h"

#define kPadding                    (34 / 2)

#pragma mark - SNCorpusChannelScrollTab

@interface SNCorpusChannelScrollTab : UIControl
@property (nonatomic, strong) SNCorpusChannelTopBarItem *tabItem;
@property (nonatomic, strong) UILabel *titleLabel;


- (id)initWithItem:(SNCorpusChannelTopBarItem *)tabItem;
- (CGSize)titleSize;

@end

@implementation SNCorpusChannelScrollTab

- (id)initWithItem:(SNCorpusChannelTopBarItem *)tabItem {
    self = [super init];
    if (self) {
        self.tabItem = tabItem;
        self.backgroundColor = [UIColor clearColor];
        
        UIColor *normalColor = SNUICOLOR(kThemeTextUpdateColor);
        
        self.titleLabel = [[UILabel alloc] init];
        self.titleLabel.font = [UIFont systemFontOfSize:kThemeFontSizeE];
        self.titleLabel.textColor = normalColor;
        self.titleLabel.textAlignment = NSTextAlignmentCenter;
        self.titleLabel.backgroundColor = [UIColor clearColor];
        self.titleLabel.text = self.tabItem.title;
        [self addSubview:self.titleLabel];

    }
    return self;
}

- (CGSize)titleSize {
    if (self.titleLabel.text) {
        return [self.titleLabel.text sizeWithFont:[UIFont systemFontOfSize:kThemeFontSizeE]];
    } else {
        return CGSizeZero;
    }
}

- (void)setSelected:(BOOL)selected {
    [super setSelected:selected];
    
    UIColor *normalColor = SNUICOLOR(kThemeTextUpdateColor);
    UIColor *selectedColor = SNUICOLOR(kThemeRed1Color);
    if (selected) {
        if (self.size.width > 0) {
            self.transform = CGAffineTransformMakeScale(1.06, 1.06);
        }
        self.titleLabel.textColor = selectedColor;
    } else {
        self.transform = CGAffineTransformIdentity;
        self.titleLabel.textColor = normalColor;
    }
}

@end

#pragma mark - SNCorpusChannelTopBar

typedef void(^SNEditBtnHandle)(UIButton *editbtn);

@interface SNCorpusChannelTopBar() <UIScrollViewDelegate>
@property (nonatomic, copy) SNEditBtnHandle editHandle;
@property (nonatomic, strong) UIScrollView *scrollView;
@property (nonatomic, strong) UIButton *editButton; // 右侧管理按钮
@property (nonatomic, strong) NSMutableArray *tabViews;
@property (nonatomic, strong) UIImageView *channelSelectedImageView;
@property (nonatomic, assign) BOOL contentSizeCached;
@property (nonatomic, assign) NSInteger currentSelectedTabIndex;
@property (nonatomic, assign) NSInteger lastSelectedTabIndex;
@property (nonatomic, assign) CGPoint scrollViewContentOffset;
@property (nonatomic, assign) CGSize contentSize;
@end

@implementation SNCorpusChannelTopBar

+ (CGFloat)channelBarHeight {
    if (UIDevice6PlusiPhone == [[UIDevice currentDevice] platformTypeForScreen]) {
        return 132 / 3 + kSystemBarHeight;
    } else {
        return (88 / 2 + kSystemBarHeight);
    }
}

- (instancetype)initWithEditHandle:(void(^)(UIButton *editBtn))handle
{
    self = [super initWithFrame:CGRectMake(0, 0, kAppScreenWidth, [SNChannelScrollTabBar channelBarHeight])];
    if (self) {
        self.editHandle = handle;
        self.backgroundColor = [UIColor clearColor];
        self.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        _selectedTabIndex = NSIntegerMax;
        _tabViews = [[NSMutableArray alloc] init];
        [self initAllSubviews];
    }
    return self;
}

- (void)initAllSubviews {
    UIImageView *middleBG = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0.f, self.width, 44 + kSystemBarHeight)];
    middleBG.image = [UIImage imageNamed:@"channel_middle_bg.png"];
    [self addSubview:middleBG];
    
    self.backgroundColor = [UIColor clearColor];
    middleBG.hidden = NO;
    
    UIImage *image = [UIImage themeImageNamed:@"icotitlebar_shadow_v5.png"];
    image = [image stretchableImageWithLeftCapWidth:5 topCapHeight:0];
    UIImageView *shadowImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 44 + kSystemBarHeight, kAppScreenWidth, 2)];
    shadowImageView.image = image;
    [self addSubview:shadowImageView];
    
    _scrollView = [[UIScrollView alloc] init];
    _scrollView.scrollEnabled = YES;
    _scrollView.scrollsToTop = NO;
    _scrollView.alwaysBounceHorizontal = YES;
    _scrollView.showsVerticalScrollIndicator = NO;
    _scrollView.showsHorizontalScrollIndicator = NO;
    _scrollView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    _scrollView.delegate = self;
    _scrollView.backgroundColor = [UIColor clearColor];
    _scrollView.contentInset = UIEdgeInsetsMake(0, 0, 0, 80);
    [self addSubview:_scrollView];
    
    _channelSelectedImageView = [[UIImageView alloc] initWithFrame:CGRectMake(CONTENT_LEFT, 42, 16, 2)];
    UIImage *markImage = [UIImage imageNamed:@"icotitlebar_redstripe_v5.png"];
    markImage = [markImage stretchableImageWithLeftCapWidth:2 topCapHeight:2];
    _channelSelectedImageView.image = markImage;
    [_scrollView addSubview:_channelSelectedImageView];

    
    UIImageView *rightCoverImageView = [[UIImageView alloc] initWithFrame:CGRectMake(kAppScreenWidth - 64 , kSystemBarHeight, 64, 44)];
    UIImage *newImage = [UIImage imageNamed:@"bgtitlebar_v5.png"];
    rightCoverImageView.frame = CGRectMake(kAppScreenWidth - newImage.size.width, kSystemBarHeight, newImage.size.width, 44);
    _scrollView.contentInset = UIEdgeInsetsMake(0, 0, 0, 80 + 40);
    rightCoverImageView.image = newImage;
    [self addSubview:rightCoverImageView];
    
    UIButton *editBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    self.editButton = editBtn;
    editBtn.adjustsImageWhenDisabled = NO;
    editBtn.adjustsImageWhenHighlighted = NO;
    //    editBtn.frame = CGRectMake(kAppScreenWidth - 52, 0, 52, 44);
    editBtn.backgroundColor = [UIColor clearColor];
    [editBtn addTarget:self action:@selector(editBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    [self.editButton setTitle:@"管理" forState:UIControlStateNormal];
    self.editButton.titleLabel.font = [UIFont systemFontOfSize:kThemeFontSizeD];
    [self.editButton setTitleColor:SNUICOLOR(kThemeRed1Color) forState:UIControlStateNormal];
    [self.editButton setTitleColor:SNUICOLOR(kThemeText3Color) forState:UIControlStateDisabled];
    [self.editButton sizeToFit];
    self.editButton.width += 30;
    self.editButton.height = 44;
    self.editButton.left = kAppScreenWidth - self.editButton.width;
    self.editButton.centerY = (self.height + kSystemBarHeight)/2;
    [self addSubview:editBtn];
    
    //底部加一根投影线
    UIView *lineView = [[UIView alloc]initWithFrame:CGRectMake(0, self.height, kAppScreenWidth, 0.5)];
    lineView.backgroundColor = SNUICOLOR(kThemeTextUpdateColor);
    lineView.alpha = 0.1;
    [self addSubview:lineView];
}

- (void)editBtnClick:(UIButton *)sender {
    if (self.editHandle) {
        self.editHandle(sender);
    }
}

- (void)editButtonEnabled:(BOOL)enable {
    self.editButton.enabled = enable;
}


- (void)reloadChannels {
    NSInteger itemNum = 0;
    int index = 0;
    NSMutableArray *tabItemsArray = [NSMutableArray array];
    
    if (_dataSource) {
        itemNum = [_dataSource numberOfItemsForTabBar:self];
        while (index < itemNum) {
            SNCorpusChannelTopBarItem *tabItem = [_dataSource tabBar:self tabBarItemForIndex:index];
            [tabItemsArray addObject:tabItem];
            index++;
        }
    }
    
    self.tabItems = tabItemsArray;
}

- (void)reloadChannels:(NSInteger)index {

    [self reloadChannels];

    _selectedTabIndex = NSIntegerMax; //强制刷新
    [self setSelectedTabIndex:index];
    
    [self toScrollingAnimation:index haveAnimation:YES];
}

- (void)toScrollingAnimation:(NSInteger)index
               haveAnimation:(BOOL)haveAnimation {
    NSMutableArray *arrayM = [NSMutableArray array];
    for (SNCorpusChannelScrollTab *label in self.scrollView.subviews) {
        if ([label isKindOfClass:[SNCorpusChannelScrollTab class]]) {
            [arrayM addObject:label];
        }
    }
    if (arrayM.count <= index) {
        return;
    }
    SNCorpusChannelScrollTab *scrollTab = arrayM[index];
    CGFloat offsetx = scrollTab.center.x - self.scrollView.width * 0.5;
    CGFloat offsetMax = self.scrollView.contentSize.width - (self.scrollView.width-80-40);

    // 在最左和最右时，标签没必要滚动到中间位置。
    if (offsetx > offsetMax) {
        offsetx = offsetMax;
    }
    if (offsetx < 0) {
        offsetx = 0;
    }
    if (haveAnimation) {
        [self.scrollView setContentOffset:CGPointMake(offsetx, 0) animated:YES];
        // 下划线滚动
        [UIView animateWithDuration:0.5 animations:^{
            self.channelSelectedImageView.centerX = scrollTab.centerX;
        }];
    }
    else {
        [self.scrollView setContentOffset:CGPointMake(offsetx, 0) animated:NO];
        self.channelSelectedImageView.centerX = scrollTab.centerX;
    }
}

- (void)addTab:(SNCorpusChannelScrollTab*)tab {
    [_scrollView addSubview:tab];
    _contentSizeCached = NO;
}

- (void)moveTriangleGapToSelectedTab:(BOOL)needAutoscroll {
    SNCorpusChannelScrollTab *selectedTabView = [self selectedTabView];
    
    if (needAutoscroll) {
        CGPoint ptOffset = _scrollView.contentOffset;
        CGFloat xOffset = ptOffset.x;
        int paddLeft = kPadding;
        int paddRight = kAppScreenWidth - 80;
        
        if (selectedTabView.left < xOffset + paddLeft) {
            int offset =  MAX(selectedTabView.left - paddLeft, 0);
            if (_scrollViewContentOffset.x != 0 && _currentSelectedTabIndex == _selectedTabIndex) {
                _scrollView.contentOffset = _scrollViewContentOffset;
            } else {
                _scrollView.contentOffset = CGPointMake(offset, ptOffset.y);
            }
        } else if (selectedTabView.right > xOffset + paddRight) {
            if (_scrollViewContentOffset.x != 0 && _currentSelectedTabIndex == _selectedTabIndex) {
                _scrollView.contentOffset = _scrollViewContentOffset;
            } else {
                if ([[[UIDevice currentDevice] systemVersion] floatValue] < 7.0 || kAppScreenWidth == 320.0) {
                    _scrollView.contentOffset = CGPointMake(selectedTabView.right - paddRight, ptOffset.y);
                } else {
                    _scrollView.contentOffset = CGPointMake(selectedTabView.right - paddRight - 20.0, ptOffset.y);
                }
            }
        } else {
            if (_selectedTabIndex == 0) {
                if (_scrollViewContentOffset.x != 0 || _currentSelectedTabIndex == _selectedTabIndex) {
                    _scrollView.contentOffset = _scrollViewContentOffset;
                }
                else {
                    _scrollView.contentOffset = CGPointZero;
                }
            }
            else {
                if (_scrollViewContentOffset.x != 0 && _currentSelectedTabIndex == _selectedTabIndex) {
                    _scrollView.contentOffset = _scrollViewContentOffset;
                }
            }
        }
    }
    
    if (selectedTabView.tabItem.title.length > 0) {
        _channelSelectedImageView.width = 16;
    }
    
    _channelSelectedImageView.centerX = selectedTabView.centerX;
    _currentSelectedTabIndex = _selectedTabIndex;
}

- (void)layoutTriangleGapToSelectedTab {
    _lastSelectedTabIndex = _selectedTabIndex;
}

- (CGSize)layoutTabsSize {
    CGFloat x = kPadding;
    int distance = ( UIDevice6PlusiPhone == [[UIDevice currentDevice] platformTypeForScreen]) ? 13 : 15;
    for (int i = 0; i < _tabViews.count; ++i) {
        SNCorpusChannelScrollTab* tab = [_tabViews objectAtIndex:i];
        CGSize tabSize = CGSizeMake([tab titleSize].width, self.height-kSystemBarHeight);
        tab.frame = CGRectMake(x, 0, tabSize.width, tabSize.height);
        tab.titleLabel.frame = CGRectMake(0, 0, tabSize.width, tabSize.height);
        x = tab.frame.origin.x + tab.frame.size.width + distance;
    }
    return CGSizeMake(x, self.frame.size.height);
}

- (CGSize)layoutTabs {
    if (_contentSizeCached) {
        return _contentSize;
    }
    
    CGSize size = [self layoutTabsSize];
    _scrollView.frame = CGRectMake(0.f, kSystemBarHeight, self.width, [SNChannelScrollTabBar channelBarHeight] - kSystemBarHeight);
    _scrollView.contentSize = CGSizeMake(size.width - 40.0, self.frame.size.height - kSystemBarHeight);
    
    
    SNCorpusChannelScrollTab *selectedTabView = [self selectedTabView];
    if (selectedTabView) {
        _channelSelectedImageView.centerX = selectedTabView.centerX;
    } else {
        _channelSelectedImageView.left = CONTENT_LEFT;
    }
    
    _contentSize = size;
    _contentSizeCached = YES;
    
    return size;
}

- (void)scrollToSelectedIndex {
    [_scrollView scrollRectToVisible:self.selectedTabView.frame animated:NO];
}


- (void)layoutSubviews {
    [super layoutSubviews];
    
    [self layoutTabs];
//    [self scrollToSelectedIndex];
    [self layoutTriangleGapToSelectedTab];

}

- (void)setTabItems:(NSArray *)tabItems {
    _tabItems = tabItems;
    
    for (int i = 0; i < _tabViews.count; ++i) {
        @autoreleasepool {
            SNCorpusChannelScrollTab *tab = [_tabViews objectAtIndex:i];
            [tab removeFromSuperview];
        }
    }
    
    [_tabViews removeAllObjects];
    @synchronized (_tabItems) {
        for (int i = 0; i < _tabItems.count; ++i) {
            @autoreleasepool {
                SNCorpusChannelTopBarItem *tabItem = [_tabItems objectAtIndex:i];
                SNCorpusChannelScrollTab *tab = [[SNCorpusChannelScrollTab alloc] initWithItem:tabItem];
                tab.alpha = 1.0;
                [tab addTarget:self
                        action:@selector(tabTouchedUp:)
              forControlEvents:UIControlEventTouchUpInside];
                
                [self addTab:tab];
                [_tabViews addObject:tab];
                
            }
        }
    }
    
    _contentSizeCached = NO;
    [self layoutSubviews];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {

    _scrollViewContentOffset = scrollView.contentOffset;
}

#pragma mark - Private
- (void)tabTouchedUp:(SNCorpusChannelScrollTab *)tab {

    _currentSelectedTabIndex = [_tabViews indexOfObject:tab];
    self.selectedTabView = tab;
    
    [self toScrollingAnimation:_currentSelectedTabIndex haveAnimation:YES];

}


- (SNCorpusChannelScrollTab *)selectedTabView {
    if (_selectedTabIndex != NSIntegerMax && _selectedTabIndex < _tabViews.count) {
        return [_tabViews objectAtIndex:_selectedTabIndex];
    }
    return nil;
}

- (void)setSelectedTabView:(SNCorpusChannelScrollTab *)tab {
    self.selectedCorpusTabItem = tab.tabItem;
    self.selectedTabIndex = [_tabViews indexOfObject:tab];
}


- (void)setSelectedTabIndex:(NSInteger)selectedTabIndex {
    if (selectedTabIndex == 0 && _currentSelectedTabIndex != selectedTabIndex) {
        _scrollViewContentOffset = CGPointZero;
    }
    
    if (selectedTabIndex != _selectedTabIndex && (nil != _tabViews && [_tabViews count] > selectedTabIndex && selectedTabIndex >= 0)) {
        if (_selectedTabIndex != NSIntegerMax) {
            self.selectedTabView.selected = NO;
        }
        
        _selectedTabIndex = selectedTabIndex;
        self.selectedTabView = [self selectedTabView];
        if (_selectedTabIndex != NSIntegerMax) {
            self.selectedTabView.selected = YES;
        }
        
        [self moveTriangleGapToSelectedTab:NO];

        if ([_delegate respondsToSelector:@selector(tabBar:tabSelected:)]) {
            [_delegate tabBar:self tabSelected:_selectedTabIndex];
        }
        
    } else if (_selectedTabIndex == 0 && selectedTabIndex == 0) {
        _scrollView.contentOffset = CGPointZero;
        _scrollViewContentOffset = CGPointZero;
    }
}

- (void)dealloc {
    _delegate = nil;
    _dataSource = nil;
}

@end


