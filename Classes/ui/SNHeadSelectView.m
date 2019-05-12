//
//  SNHeadSelectView.m
//  sohunews
//
//  Created by wang yanchen on 12-9-20.
//  Copyright (c) 2012年 Sohu.com Inc. All rights reserved.
//

#import "SNHeadSelectView.h"
#import "UIColor+ColorUtils.h"
#import "SNThemeManager.h"

#define kHeadTitleFontSize          (43 / 2)
#define kHeadTitleSideMargin        (10)

@implementation SNHeadItemView
@synthesize isSelected = _isSelected;
@synthesize viewIndex = _viewIndex;
@synthesize textFont, textSideMargin;

- (id)initWithFrame:(CGRect)frame itemTitle:(NSString *)title delegate:(id)delegate {
    self = [super initWithFrame:frame];
    if (self) {
        _delegate = delegate;
        
        float padding = (frame.size.height == kHeaderTotalHeight) ? kSystemBarHeight : 0.f;
        CGRect viewBounds = CGRectMake(16.0, 0+padding, [UIScreen mainScreen].bounds.size.width-20, frame.size.height-padding); // v5.2.2 10 - 16.0
        
        UIColor *viewColor = [UIColor clearColor];
        
        CGFloat fontSize = self.textFont > 0 ? self.textFont : kThemeFontSizeE;
        // title
        _title = [[UILabel alloc] initWithFrame:viewBounds];
        _title.font = [UIFont systemFontOfSize:fontSize];
        _title.backgroundColor = viewColor;
        _title.text = title;
        _title.textAlignment = NSTextAlignmentLeft;
        [self addSubview:_title];
        
        // mask button
        _maskBtn = [[UIButton alloc] initWithFrame:viewBounds];
        _maskBtn.backgroundColor = viewColor;
        [_maskBtn addTarget:self action:@selector(viewTapped) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:_maskBtn];
        
        //@Dan: tell what to read for blind people
        _maskBtn.accessibilityLabel = title;
        
        _tipView = [[SNBubbleTipView alloc] initWithType:SNHeadBubbleType];
        _tipView.frame = CGRectMake(frame.size.width-_tipView.defaultWidth+8*2, 5+kSystemBarHeight, _tipView.defaultWidth, _tipView.defaultHeight);
        [self addSubview:_tipView];
        
        self.backgroundColor = viewColor;
        [self updateTheme];
    }
    return self;
}

- (void)setTextFont:(CGFloat)font {
    textFont = font;
    _title.font = [UIFont systemFontOfSize:textFont];
}

- (void)viewTapped {
    if (_delegate && [_delegate respondsToSelector:@selector(sectionViewTapped:)]) {
        [_delegate sectionViewTapped:self];
    }
}

- (void)setIsSelectedState:(BOOL)isSelected {
    _isSelected = isSelected;
    
    // change color of title label
    [self updateTheme];
}

- (void)updateTheme {
    if (_isSelected) {
        _title.textColor = SNUICOLOR(kThemeRed1Color);//[UIColor colorFromString:[[SNThemeManager sharedThemeManager] currentThemeValueForKey:kRollingNewsChannelSelectedTextColor]];
    }
    else {
        _title.textColor = [UIColor colorFromString:[[SNThemeManager sharedThemeManager] currentThemeValueForKey:kRollingNewsChannelNormalTextColor]];
    }
}

- (void)addDot
{
    UIImage* docImage = [UIImage imageNamed:@"dot.png"];
    CGRect rect = CGRectMake(self.width-docImage.size.width-5, 8, docImage.size.width, docImage.size.height);
    if(!_dotView)
    {
        _dotView = [[UIImageView alloc] initWithImage:docImage];
        _dotView.frame = rect;
        [self addSubview:_dotView];
    }
}

- (void)removeDot
{
    if(_dotView)
    {
        [_dotView removeFromSuperview];
         //(_dotView);
    }
}
- (void)setTipCount:(int)count
{
    if (count > 0) {
        count = -1;
    }
    [_tipView setTipCount:count];
}
- (void)dealloc {
    _delegate = nil;
     //(_title);
     //(_maskBtn);
     //(_dotView);
     //(_tipView);
}

@end

////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////

@interface SNHeadSelectView ()

- (void)initSections:(Class)itemViewClazz;
- (void)moveBottomView;
- (void)changeViewsSelectionState;
- (void)moveAnimationDidStoped;


@end

@implementation SNHeadSelectView
@synthesize sections = _sections;
@synthesize sectionViews = _sectionViews;
@synthesize delegate = _delegate;
@synthesize textFont, textSideMargin;
@synthesize backgroundView = _backgroundView;
@synthesize bottomView = _bottomView;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        
        _backgroundView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, frame.size.width, frame.size.height - kHeadBottomHeight)];
        
        [self addSubview:_backgroundView];
        
        _bottomView = [[UIImageView alloc] initWithFrame:CGRectMake(0, frame.size.height - kHeadBottomHeight, kHeadBottomWidth, kHeadBottomHeight)];
        [self addSubview:_bottomView];
        
        self.clipsToBounds = YES;
        self.backgroundColor = [UIColor clearColor];
        [self updateTheme];
        [SNNotificationManager addObserver:self selector:@selector(updateTheme) name:kThemeDidChangeNotification object:nil];
    }
    return self;
}

- (void)dealloc {
     //(_sections);
     //(_sectionViews);
     //(_backgroundView);
     //(_bottomView);
     //(_bottomLineImageView);
     //(_shadowImageView)
    _delegate = nil;
}

- (void)layoutSubviews {
    [super layoutSubviews];
}

#pragma mark - public methods
- (void)setCurrentIndex:(int)index animated:(BOOL)animated {
    _currentIndex = index;
    if (animated) {
        [UIView beginAnimations:@"moveSelection" context:NULL];
        [UIView setAnimationDuration:0.3];
        [UIView setAnimationDelegate:self];
        [UIView setAnimationDidStopSelector:@selector(moveAnimationDidStoped)];
    }
    
    [self moveBottomView];
    
    if (animated) {
        [UIView commitAnimations];
    }
    else {
        [self changeViewsSelectionState];
    }
    if(_currentIndex>=0 && _currentIndex < [_sectionViews count])
    {
        SNHeadItemView* itemView = [_sectionViews objectAtIndex:index];
        [itemView removeDot];
        [itemView setTipCount:0];
    }
}

- (void)updateTheme
{
    _bottomView.image = [UIImage themeImageNamed:@"head_line.png"];
    if (SYSTEM_VERSION_LESS_THAN(@"7.0"))
    {
        _backgroundView.backgroundColor = [UIColor colorFromString:[[SNThemeManager sharedThemeManager] currentThemeValueForKey:kBackgroundColor]];
    }
    else
    {
        _backgroundView.image = [UIImage themeImageNamed:@"channel_middle_bg.png"];
    }

    [self changeViewsSelectionState];
    
    UIImage *image = [UIImage themeImageNamed:@"icotitlebar_redstripe_v5.png"];
    image = [image stretchableImageWithLeftCapWidth:2 topCapHeight:2];
    _bottomLineImageView.image = image;
}

- (CGFloat)realHeight {
    return self.height - _bottomView.height;
}

- (void)setSections:(NSArray *)sections {
    if (_sections != sections) {
        _sections = sections;
        
        [self initSections:[SNHeadItemView class]];
    }
}

- (void)setSections:(NSArray *)sections withItemViewClass:(Class)clazz {
    if (_sections != sections) {
        _sections = sections;
        
        [self initSections:clazz];
    }
}

- (NSMutableArray *)sectionViews {
    if (!_sectionViews) {
        _sectionViews = [[NSMutableArray alloc] init];
    }
    return _sectionViews;
}

- (void)addDotForIndexSection:(int)index
{
    if(index < 0 || index >= [_sectionViews count])
    {
        return;
    }
    SNHeadItemView* itemView = [_sectionViews objectAtIndex:index];
    [itemView addDot];
}

- (void)setTipCount:(int)count withIndex:(int)index
{
    if(index < 0 || index >= [_sectionViews count])
    {
        return;
    }
    SNHeadItemView* itemView = [_sectionViews objectAtIndex:index];
    [itemView setTipCount:count];
}
#pragma mark - private methods

- (void)initSections:(Class)itemViewClazz {
    CGFloat fontSize = self.textFont > 0 ? self.textFont : kHeadTitleFontSize;
    CGFloat sideMargin = self.textSideMargin > 0 ? self.textSideMargin : kHeadTitleSideMargin;
    
    UIFont *titleFont = [UIFont systemFontOfSize:fontSize];
    CGFloat startX = 0;
    CGFloat viewWidth = 0;
    
    for (SNHeadItemView *view in self.sectionViews) {
        [view removeFromSuperview];
    }
    
    [self.sectionViews removeAllObjects];
    int index = 0;
    for (id section in _sections) {
        if ([section isKindOfClass:[NSString class]]) {
            NSString *title = (NSString *)section;
            CGSize titleSize = [title sizeWithFont:titleFont];
            viewWidth = titleSize.width + 2 * sideMargin;
            
            CGRect frame = CGRectMake(startX, 0, viewWidth, self.height);
            SNHeadItemView *aNewView = [[itemViewClazz alloc] initWithFrame:frame itemTitle:title delegate:self];
            if (self.textFont > 0) {
                aNewView.textFont = self.textFont;
            }
            aNewView.viewIndex = index;
            [self addSubview:aNewView];
            [self.sectionViews addObject:aNewView];
            startX += viewWidth;
            index++;
        }
    }
    
    [self setCurrentIndex:0 animated:NO];
}

- (void)moveBottomView {
    if (self.sectionViews.count > 1) {
        CGRect selectViewFrame = [[self.sectionViews objectAtIndex:_currentIndex] frame];
        CGFloat x = CGRectGetMidX(selectViewFrame);
        if (x > self.width) {
            x = self.width;
        }
        
        _bottomView.center = CGPointMake(x, _bottomView.center.y);
    }
    else {
        _bottomView.center = CGPointMake(30, _bottomView.center.y);
    }
}

- (void)handleOffsetChanged:(CGFloat)offsetX {
    if (self.sectionViews.count > 1) {
        CGFloat viewWidth = [(UIView *)_offsetListenObj width];
        CGFloat contentWidth = viewWidth * _sections.count;
        CGRect nextViewFrame = CGRectZero;
        CGRect offsetLineViewFrame = CGRectZero;
        CGRect currentViewFrame = CGRectZero;
        CGFloat nextViewMidX = 0;
        CGFloat offsetLineViewMidX = 0;
        CGFloat midX = 0;
        int offsetLineIndex = (int)offsetX / (int)viewWidth;
        
        offsetLineIndex = MAX(0, offsetLineIndex);
        offsetLineIndex = MIN((int)self.sectionViews.count - 2, offsetLineIndex);
        
        if (offsetX <= 0) {
            currentViewFrame = [[self.sectionViews objectAtIndex:0] frame];
            midX = CGRectGetMidX(currentViewFrame);
        }
        else if (offsetX >= contentWidth - viewWidth) {
            currentViewFrame = [[self.sectionViews lastObject] frame];
            midX = CGRectGetMidX(currentViewFrame);
        }
        else {
            nextViewFrame = [[self.sectionViews objectAtIndex:offsetLineIndex + 1] frame];
            nextViewMidX = CGRectGetMidX(nextViewFrame);
            
            offsetLineViewFrame = [[self.sectionViews objectAtIndex:offsetLineIndex] frame];
            offsetLineViewMidX = CGRectGetMidX(offsetLineViewFrame);
            
            midX = offsetLineViewMidX + (nextViewMidX - offsetLineViewMidX) * ((offsetX - offsetLineIndex * viewWidth) / viewWidth);
        }
        
        if (midX != 0) {
            _bottomView.center = CGPointMake(midX, _bottomView.center.y);
        }
    }
}

- (void)moveBottomViewToPosX:(CGFloat)x {
    _bottomView.center = CGPointMake(x, _bottomView.center.y);
}

- (void)changeViewsSelectionState {
    for (int i = 0; i < self.sectionViews.count; ++i) {
        [[self.sectionViews objectAtIndex:i] setIsSelectedState:i == _currentIndex];
    }
}

- (void)moveAnimationDidStoped {
    [self changeViewsSelectionState];
}

- (void)sectionViewTapped:(SNHeadItemView *)itemView {
    if (_delegate && [_delegate respondsToSelector:@selector(headView:didSelectIndex:)] && !itemView.isSelected)
    {
        [_delegate headView:self didSelectIndex:itemView.viewIndex];
    }
    [itemView removeDot];
    [itemView setTipCount:0];
    if (!itemView.isSelected) {
        
        [self setCurrentIndex:itemView.viewIndex animated:!self.unanimated];
    }
}

- (void)registerOffsetListener:(id)listenObj {
    if (_offsetListenObj != listenObj) {
        [_offsetListenObj removeObserver:self forKeyPath:@"contentOffset"];
        [listenObj addObserver:self forKeyPath:@"contentOffset" options:NSKeyValueObservingOptionNew context:NULL];
        _offsetListenObj = listenObj;
    }
}

- (void)resignOffsetListener {
    if (_offsetListenObj) {
        [_offsetListenObj removeObserver:self forKeyPath:@"contentOffset"];
        _offsetListenObj = nil;
    }
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    if (_offsetListenObj == object) {
        if ([keyPath isEqualToString:@"contentOffset"]) {
            NSValue *newValue = [change objectForKey:NSKeyValueChangeNewKey];
            CGPoint offset = [newValue CGPointValue];
            [self handleOffsetChanged:offset.x];
        }
    }
}

- (void)setBottomLineForHeaderView:(CGRect)rect {
    [self setHeaderViewShadow];//设置上边栏阴影
    if (!_bottomLineImageView) {
        _bottomLineImageView = [[UIImageView alloc] init];
        [self addSubview:_bottomLineImageView];
    }
    
    rect.origin.x = 14.0f; // v5.2.2
    _bottomLineImageView.frame = rect;
    UIImage *image = [UIImage themeImageNamed:@"icotitlebar_redstripe_v5.png"];
    image = [image stretchableImageWithLeftCapWidth:2 topCapHeight:2];
    _bottomLineImageView.image = image;
}

- (void)setHeaderViewShadow {
    if (!_shadowImageView) {
        _shadowImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 44 + kSystemBarHeight, kAppScreenWidth, 2)];
        [self.superview addSubview:_shadowImageView];
    }
    UIImage *image = [UIImage themeImageNamed:@"icotitlebar_shadow_v5.png"];
    image = [image stretchableImageWithLeftCapWidth:5 topCapHeight:0];
    _shadowImageView.image = image;
}

@end
