//
//  SNActionMenu.m
//  sohunews
//
//  Created by Dan Cong on 2/14/14.
//  Copyright (c) 2014 Sohu.com. All rights reserved.
//

#import "SNActionMenu.h"

#define kSemiModalAnimationDuration     (0.4f)

#define kContentBottomMargin            (71 / 2)
#define kSheetBtnWidth                  (560 / 2)
#define kSheetBtnHeight                 (84 / 2)
#define kSheetBtnTopMargin              (56 / 2)
#define kSheetBtnMidSpacing             (16 / 2)

#define kBtmBtnTopSpacing               (22 / 2)
#define kBtmBtnWidth                    (92)
#define kBtmBtnHeight                   (72 / 2)

#define kSmsBtnLeftMargin               (102 / 2)
#define kLikeBtnRightMargin             (101 / 2)

#define kSheetBtnTitleFont              (32 / 2)
#define kActionMenuViewTag              (3764)

#define kActionViewPointerWidth         (82 / 2)
#define kActionViewPointerHeight        (44 / 2)

#define kShareButtonDistance_X          (60 / 2)
#define kShareButtonDistance_Y          (26 / 2)
#define kShareViewHeight                (494 / 2)
#define kShareButtonWidth               ((kAppScreenWidth -  kShareButtonDistance_X * 4)/3) // (124 / 2)  ps:3列 4间距 目前写死
#define kShareButtonHeight              (kShareButtonWidth + 20) // (164 / 2)

#define kShareVideoLoginViewHeight      (462 / 2)
#define kShareButtonVideoDistance_X     (146 / 2)
#define kShareButtonVideoDistance_Y     (84 / 2)

#define kCancelBtnHeight                (60)
#define kCancelBtnSpaceHeight           (47)

#define kShareButtonTag                 (7777)
#define kShareOverlayViewTag            (7778)

#define kLikeBtnTag                     (6)
#define ITEM_MAX_COUNT_PER_PAGE         (8)
#define ITEM_MAX_COUNT_PER_LINE         (4)

#define kShareButtonSize


@interface SNActionMenu ()

- (void)initCommonUI;
- (void)resetSubViewsLayout;
- (void)presentModelView;
- (void)dismissModalView;

@end

@implementation SNActionMenu

@synthesize cancelButton = _cancelButton;

- (id)init
{
    self = [super init];
    if (self) {
        
        CGSize size = [[UIScreen mainScreen] applicationFrame].size;
        self.frame = CGRectMake(0, 0, size.width, size.height);
        _items = [[NSMutableArray alloc] initWithCapacity:0];
        _containerScrollViews = [[NSMutableArray alloc] initWithCapacity:0];
        [self initCommonUI];
        [self resetSubViewsLayout];
    }
    return self;
}


- (id)initWithFrame:(CGRect)frame items:(NSArray *)items
{
    if(self = [super initWithFrame:frame]){
        _items = [[NSMutableArray alloc] initWithArray:items];
        _containerScrollViews = [[NSMutableArray alloc] initWithCapacity:0];
        [self initCommonUI];
        [self resetSubViewsLayout];
    }
    return self;
}


- (void)setItems:(NSMutableArray *)items
{
    for(SNActionMenuItem *item in _items){
        [item.containView removeFromSuperview];
    }
    
    [_items removeAllObjects];
    [_items addObjectsFromArray:items];
    
    [self resetSubViewsLayout];
    
}

- (void)initCommonUI
{
    _containerBgView = [[SNNavigationBar alloc] initWithFrame:self.bounds];
    [self addSubview:_containerBgView];
    
    if (!_cancelButton) {
        self.cancelButton  = [UIButton buttonWithType:UIButtonTypeCustom];
    }
    _cancelButton.frame = CGRectMake(0, self.frame.size.height-kCancelBtnHeight, self.frame.size.width, kCancelBtnHeight);
    _cancelButton.backgroundColor = [UIColor clearColor];
    [_cancelButton addTarget:self action:@selector(dismissModalView) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:_cancelButton];
    UIImage* image = [UIImage themeImageNamed:@"icofloat_close_v5.png"];
    UIImageView* imageView = [[UIImageView alloc] initWithImage:image];
    imageView.frame = CGRectMake((self.frame.size.width-image.size.width)/2, 0, image.size.width, image.size.height);
    [_cancelButton addSubview:imageView];
    [SNNotificationManager addObserver:self
                                             selector:@selector(dismissModalView)
                                                 name:kHideActionMenuViewNotification
                                               object:nil];
}

- (void)resetSubViewsLayout
{
    CGRect rect = [UIScreen mainScreen].bounds;
    if(rect.size.height == self.frame.size.width)
    {
        [self resetLanscapeSubViewsLayout];
    }
    else
    {
        [self resetPortraitSubViewsLayout];
    }
}

- (void)resetLanscapeSubViewsLayout
{
    CGFloat allShareHeight = (kShareButtonHeight + kShareButtonDistance_Y) * 2;
    CGFloat distancex = (self.frame.size.width - 4*kShareButtonWidth) / 5;
    CGFloat starty = (self.frame.size.height - allShareHeight) / 2;
    CGFloat startx = distancex;
    
    for (NSInteger index = 0; index < self.items.count; ++index)
    {
        SNActionMenuItem *item = (SNActionMenuItem *)[_items objectAtIndex:index];
        item.index = index;
        [item addTarget:self action:@selector(click:) forControlEvents:UIControlEventTouchUpInside];
        
        NSInteger row = index / 4;
        NSInteger cloumn = index % 4;
        NSInteger x = startx + cloumn * (distancex + kShareButtonWidth);
        NSInteger y = starty + row * (kShareButtonDistance_Y + kShareButtonHeight);
        item.containView.frame = CGRectMake(x, y, kShareButtonWidth, kShareButtonHeight);
        [_containerBgView addSubview:item.containView];
    }
}

- (void)resetPortraitSubViewsLayout
{
    CGFloat allShareHeight = (kShareButtonHeight + kShareButtonDistance_Y) * 3;
    CGFloat distancex = (self.frame.size.width - 3 * kShareButtonWidth) / 4;
    CGFloat starty = (self.frame.size.height - allShareHeight) / 2;
    CGFloat startx = distancex;
    
    for (NSInteger index = 0; index < self.items.count; ++index)
    {
        SNActionMenuItem *item = (SNActionMenuItem *)[_items objectAtIndex:index];
        item.index = index;
        [item addTarget:self action:@selector(click:) forControlEvents:UIControlEventTouchUpInside];
        
        NSInteger row = index / 3;
        NSInteger cloumn = index % 3;
        NSInteger x = startx + cloumn * (distancex + kShareButtonWidth);
        NSInteger y = starty + row * (kShareButtonDistance_Y + kShareButtonHeight);
        item.containView.frame = CGRectMake(x, y, kShareButtonWidth, kShareButtonHeight);
        [_containerBgView addSubview:item.containView];
    }
}

- (void)scrollViewDidScroll:(UIScrollView *) aScrollView
{
	CGPoint offset = aScrollView.contentOffset;
	_pageControl.currentPage = offset.x / _containerView.bounds.size.width;
}

- (void)setTintColor:(UIColor *)tintColor
{
    if(_tintColor){
        _tintColor = nil;
    }
    
    _tintColor = tintColor;
    self.backgroundColor = _tintColor;
}

- (void)show {
    [self presentModelView];
}

- (void)dismiss
{
    [self dismissModalView];
}


- (void)presentModelView {
    UIView *presentFromView = _presentFromView ? _presentFromView : [SNUtility getApplicationDelegate].window;
    if (![presentFromView.subviews containsObject:self] &&
        nil == [presentFromView viewWithTag:kSNActionMenuViewTag]) {
        [presentFromView addSubview:self];
        self.transform = CGAffineTransformMakeScale(0.2,0.2);
        
        [UIView animateWithDuration:0.2 delay:0 options:UIViewAnimationOptionCurveEaseIn animations:^{
            self.transform = CGAffineTransformMakeScale(1,1);
        } completion:^(BOOL finished) {
        }];
    }
}

- (void)dismissModalView {
    self.transform = CGAffineTransformMakeScale(1,1);
    [UIView animateWithDuration:0.2 delay:0 options:UIViewAnimationOptionCurveEaseIn animations:^{
        self.transform = CGAffineTransformMakeScale(0.2,0.2);
    } completion:^(BOOL finished) {
        [self removeFromSuperview];
    }];
}

- (void)pageControlPageDidChange:(SNPageControl *)pageControl {
}

- (void)click:(id)sender {
    [self removeFromSuperview];
    
    UIControl *item = (UIControl *)sender;
    if ([_delegate respondsToSelector:@selector(actionMenu:didSelectAtIndex:)]) {
        [_delegate actionMenu:self didSelectAtIndex:(int)item.tag];

    }
}

- (void)dealloc {
    _items = nil;
    _tintColor = nil;
    _pageControl = nil;
    _containerView = nil;
    _containerScrollViews = nil;
    
    [SNNotificationManager removeObserver:self name:kHideActionMenuViewNotification object:nil];
}

@end
