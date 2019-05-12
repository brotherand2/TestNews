//
//  SNEmoticonScrollView.m
//  sohunews
//
//  Created by jialei on 14-5-4.
//  Copyright (c) 2014年 Sohu.com. All rights reserved.
//

#import "SNEmoticonStaticScrollView.h"
#import "SNEmoticonObject.h"

#define SN_EMOTICON_SCROLL_COLUMN   7
#define SN_EMOTICON_SCROLL_ROW      4
#define SN_EMOTICON_ICON_WIDTH          (60 / 2)
#define SN_EMOTICON_START_X             (20 / 2)
#define SN_EMOTICON_START_Y             (40 / 2)
#define SN_EMOTICON_SCROLL_ROW_GAP      (40 / 2)
#define SN_EMOTICON_SCROLL_COLUMN_GAP   ((kAppScreenWidth - SN_EMOTICON_START_X - SN_EMOTICON_START_X - (SN_EMOTICON_ICON_WIDTH * 7))/6)

@interface SNEmoticonStaticScrollView() {
}

@end

@implementation SNEmoticonStaticScrollView

- (id)initWithObjects:(NSArray *)objects frame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        self.delegate = self;
        self.pagingEnabled = YES;
        self.showsHorizontalScrollIndicator = NO;
        self.showsVerticalScrollIndicator = NO;
        self.alwaysBounceHorizontal = YES;
        self.clipsToBounds = YES;
        self.frame = frame;
        
        _emoticonObjects = [[NSArray alloc] initWithArray:objects];
        _emoticonCount = [_emoticonObjects count];
        if (_emoticonCount > 0) {
            SNEmoticonObject *emoticon = [_emoticonObjects objectAtIndex:0];
            self.type = emoticon.type;
        }
        
        [self setRowColumn];
        [self createEmotions];
        [self createEmotionDes];
        [self createPageView];
        [self layoutEmotions];
    }
    return self;
}

- (void)dealloc
{
     //(_emoticonImageViews);
     //(_emoticonObjects);
    
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

- (void)setRowColumn
{
    _rowCount = SN_EMOTICON_SCROLL_ROW;
    _columnCount = SN_EMOTICON_SCROLL_COLUMN;
}

- (void)createEmotions
{
    if (_emoticonImageViews) {
		 //(_emoticonImageViews);
		for (UIView *subView in self.subviews) {
			[subView removeFromSuperview];
		}
	}
	
	_emoticonImageViews = [[NSMutableArray alloc] initWithCapacity:_emoticonCount];
	
	for (NSUInteger i = 0; i < _emoticonCount; i++) {
		SNEmoticonObject *emoticon = [_emoticonObjects objectAtIndex:i];
		
		// 创建表情ImageView.
		UIImageView *emoticonImageView = [[UIImageView alloc] init];
        emoticonImageView.size = CGSizeMake(SN_EMOTICON_ICON_WIDTH, SN_EMOTICON_ICON_WIDTH);
        
		emoticonImageView.image = [emoticon emoticonImage];
		emoticonImageView.contentMode = UIViewContentModeCenter;
        emoticonImageView.alpha = themeImageAlphaValue();
		[self addSubview:emoticonImageView];
		[_emoticonImageViews addObject:emoticonImageView];
	}
}

- (void)createPageView
{
    _pageControl = [[UIPageControl alloc] init];
    _pageControl.pageIndicatorTintColor = RGBCOLOR(248, 248, 248);
    [_pageControl addTarget:self action:@selector(changePage:) forControlEvents:UIControlEventValueChanged];
    [self addSubview:_pageControl];
    
    _emoticonsPerPage = _rowCount * _columnCount;
    _pageCount = ceil(1.0 * _emoticonCount / _emoticonsPerPage);
    _pageControl.numberOfPages = _pageCount;
	_pageControl.currentPage = 0;
    self.contentSize = CGSizeMake(self.bounds.size.width * _pageCount, self.bounds.size.height);
    if (_pageCount > 1) {
        _pageControl.frame  = CGRectMake(0, self.bounds.size.height - 20, self.bounds.size.width, 20);
    } else {
        _pageControl.frame  = CGRectMake(0, self.bounds.size.height - 20, self.bounds.size.width, 20);
    }
}

- (void)createEmotionDes
{
}

- (void)calculateEmotionsSpace
{
}

- (void)layoutEmotions
{
    int index = 0;
    int emoticonX = SN_EMOTICON_START_X;
    int emoticonY = SN_EMOTICON_START_Y;
    
    for (NSUInteger page = 0; page < _pageCount; page++) {
		
		// 重置x, y值.
        emoticonX = page * self.bounds.size.width + SN_EMOTICON_START_X;
        emoticonY = SN_EMOTICON_START_Y;
        for (int rowIndex = 0; rowIndex < _rowCount; rowIndex++) {
            for (int colIndex = 0; colIndex < _columnCount; colIndex++) {
                // 如果index已经越界则退出循环,并添加删除按钮.
                if (index >= _emoticonCount) {
                    break;
                }
                
                // 更新表情ImageView的frame.
                UIImageView *emoticonImageView = [_emoticonImageViews objectAtIndex:index];
                emoticonImageView.frame = CGRectMake(emoticonX, emoticonY, SN_EMOTICON_ICON_WIDTH, SN_EMOTICON_ICON_WIDTH);
                index++;
                
                // 增长x.
                emoticonX += SN_EMOTICON_ICON_WIDTH + SN_EMOTICON_SCROLL_COLUMN_GAP;
            }
            if (index < _emoticonCount) {
                emoticonX = SN_EMOTICON_START_X;
                emoticonY += SN_EMOTICON_ICON_WIDTH + SN_EMOTICON_SCROLL_ROW_GAP;
            }
        }
        
        //lijian 2015.03.02 plus在上面涉及的计算是整数操作，是有误差的，把这个误差也减掉。
        int distX = SN_EMOTICON_SCROLL_COLUMN_GAP;
        int offsetX = self.frame.size.width - (_columnCount * SN_EMOTICON_ICON_WIDTH + (_columnCount - 1) * distX + SN_EMOTICON_START_X * 2);
        
        [self createDeleteButtonAtPoint:CGPointMake(self.frame.size.width - SN_EMOTICON_ICON_WIDTH - SN_EMOTICON_START_X - offsetX,
                                                    emoticonY + 2)];
    }
}

- (void)createDeleteButtonAtPoint:(CGPoint)point
{
    UIImage *image = [UIImage themeImageNamed:@"emo_delete.png"];
    UIButton *deleteButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [deleteButton setImage:image forState:UIControlStateNormal];
    [deleteButton addTarget:self action:@selector(deleteEmoticon) forControlEvents:UIControlEventTouchUpInside];
    deleteButton.origin = point;
    deleteButton.size = image.size;
    
    [self addSubview:deleteButton];
}

#pragma mark - Touch Events
- (void)deleteEmoticon
{
//    [SNNotificationManager postNotificationName:notificationEmoticonDelete object:nil];
    if (self.emoticonDelegate && [self.emoticonDelegate respondsToSelector:@selector(emoticonDidDelete)]) {
        [self.emoticonDelegate emoticonDidDelete];
    }
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
	[super touchesBegan:touches withEvent:event];
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
	NSUInteger emoticonIndex = [self emoticonIndexForTouch:[touches anyObject]];
    if (emoticonIndex != NSNotFound) {
        SNEmoticonObject *emoticon = [[SNEmoticonManager sharedManager] emoticonAtIndex:emoticonIndex];
        if(self.emoticonDelegate && [self.emoticonDelegate respondsToSelector:@selector(emoticonDidSelect:)]) {
            [self.emoticonDelegate emoticonDidSelect:emoticon];
        }
    }
	else {
        [super touchesEnded:touches withEvent:event];
    }
}

#pragma mark - cacluate emoticonIndex
- (NSUInteger)emoticonIndexForTouch:(UITouch *)touch
{
	if (touch != nil) {
		return [self emoticonIndexForPoint:[touch locationInView:self]];
	}
	
	return NSNotFound;
}

- (NSUInteger)emoticonIndexForPoint:(CGPoint)point
{
	// 映射point到当前页的相对位置.
//	point.x = (int)point.x % (int)self.bounds.size.width;
//	point.y = (int)point.y % (int)self.bounds.size.height;
	// 如果触摸的区域在边框处, 则返回不存在.
	if ((point.x <= SN_EMOTICON_START_X || point.x >= self.bounds.size.width - SN_EMOTICON_START_X) ||
		(point.y <= SN_EMOTICON_START_Y || point.y >= self.bounds.size.height - SN_EMOTICON_START_Y)) {
		return NSNotFound;
	}
	
	// 计算当前point的行列值.
	int column = (int)(point.x - SN_EMOTICON_START_X) / (SN_EMOTICON_ICON_WIDTH + SN_EMOTICON_SCROLL_COLUMN_GAP);
	int row = (int)(point.y - SN_EMOTICON_START_Y) / (SN_EMOTICON_ICON_WIDTH + SN_EMOTICON_SCROLL_ROW_GAP);
	
	if (column >= _columnCount || row >= _rowCount) {
		return NSNotFound;
	}
	
	int emoticonIndex = row * _columnCount + column;
    
    if (emoticonIndex >= _emoticonCount) {
        return NSNotFound;
    }
	
	return emoticonIndex >= 0 ? emoticonIndex : NSNotFound;
}

#pragma mark - UIScrollView Delegate Methods
- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    // We don't want a "feedback loop" between the UIPageControl and the scroll delegate in
    // which a scroll event generated from the user hitting the page control triggers updates from
    // the delegate method. We use a boolean to disable the delegate logic when the page control is used.
    if (_pageControlUsed) {
        // do nothing - the scroll was initiated from the page control, not the user dragging
        return;
    }
	
    // Switch the indicator when more than 50% of the previous/next page is visible
    CGFloat pageWidth = scrollView.frame.size.width;
    int page = floor((scrollView.contentOffset.x - pageWidth / 2) / pageWidth) + 1;
    _pageControl.currentPage = page;
	_pageControl.left = scrollView.contentOffset.x;
}

// At the end of scroll animation, reset the boolean used when scrolls originate from the UIPageControl
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    _pageControlUsed = NO;
}

#pragma mark - Page Control Action

- (void)changePage:(id)sender
{
	NSInteger page = _pageControl.currentPage;
	
	[UIView beginAnimations:@"PageChangedAnimation" context:nil];
	[UIView setAnimationDelegate:self];
	[UIView setAnimationDidStopSelector:@selector(animationDidStop:finished:context:)];
	
	// Update the scroll view to the appropriate page, animated.
	self.contentOffset = CGPointMake(self.bounds.size.width * page, 0);
	_pageControl.left = self.contentOffset.x;
	
	[UIView commitAnimations];
	
    // Set the boolean used when scrolls originate from the UIPageControl. See scrollViewDidScroll: above.
    _pageControlUsed = YES;
}

- (void)animationDidStop:(NSString *)animationID finished:(NSNumber *)finished context:(void *)context
{
	if ([animationID isEqualToString:@"PageChangedAnimation"]) {
		_pageControlUsed = NO;
	}
}


@end
