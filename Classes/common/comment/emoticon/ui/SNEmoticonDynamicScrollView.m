//
//  SNEmoticonDynamicScrollView.m
//  sohunews
//
//  Created by jialei on 14-5-13.
//  Copyright (c) 2014年 Sohu.com. All rights reserved.
//

#import "SNEmoticonDynamicScrollView.h"
#import "SNEmoticonObject.h"
#import "SNEmoticonButton.h"

#define SN_EMOTICON_SCROLL_COLUMN   (kAppScreenWidth > 320 ? 5 : 4)
#define SN_EMOTICON_SCROLL_ROW      2
#define SN_EMOTICON_SCROLL_ROW_GAP      (30 / 2)
#define SN_EMOTICON_ICON_WIDTH          (90 / 2)
#define SN_EMOTICON_DES_GAP             (6 / 2)
#define SN_EMOTICON_START_X             (46 / 2)
#define SN_EMOTICON_START_Y             (30 / 2)
#define SN_EMOTICON_SCROLL_COLUMN_GAP   ((kAppScreenWidth - SN_EMOTICON_START_X * 2 - (SN_EMOTICON_ICON_WIDTH * SN_EMOTICON_SCROLL_COLUMN)) / (SN_EMOTICON_SCROLL_COLUMN - 1)) // (62 / 2) 表情间隙 =  (屏幕宽度 - 左右间隙 - 每个表情宽度 * 列数) / (列数 - 1)

#define SN_EMOTICON_BUTTON_HEIGHT   (SN_EMOTICON_ICON_WIDTH + SN_EMOTICON_DES_GAP + 14)

@implementation SNEmoticonDynamicScrollView

- (id)initWithObjects:(NSArray *)objects frame:(CGRect)frame
{
    self = [super initWithObjects:objects frame:frame];
    if (self) {

    }
    return self;
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
        CGRect frame = CGRectMake(0, 0, SN_EMOTICON_ICON_WIDTH, SN_EMOTICON_BUTTON_HEIGHT);
		SNEmoticonButton *emoticonButton = [[SNEmoticonButton alloc] initWithEmoticon:emoticon frame:frame];
        
        __block typeof(self) _wself = self;
        emoticonButton.clickedBlock = ^(SNEmoticonObject *obj) {
            if(_wself.emoticonDelegate && [_wself.emoticonDelegate respondsToSelector:@selector(emoticonDidSelect:)]) {
                [_wself.emoticonDelegate emoticonDidSelect:obj];
            }
        };
        
		[self addSubview:emoticonButton];
		[_emoticonImageViews addObject:emoticonButton];
	}
}

- (void)layoutEmotions
{
	self.contentOffset = CGPointMake(0, 0);
    
    int index = 0;
    int emoticonX = SN_EMOTICON_START_X;
    int emoticonY = SN_EMOTICON_START_Y;
    
    for (NSUInteger page = 0; page < _pageCount; page++) {
		
		// 重置x, y值.
        emoticonX = page * self.bounds.size.width + SN_EMOTICON_START_X;
        emoticonY = SN_EMOTICON_START_Y;
        
        for (int rowIndex = 0; rowIndex < _rowCount; rowIndex++) {
            for (int colIndex = 0; colIndex < _columnCount; colIndex++) {
                if (index >= _emoticonCount) {
                    break;
                }
                // 更新表情ImageView的frame.
                SNEmoticonButton *emoticonButton = [_emoticonImageViews objectAtIndex:index];
                emoticonButton.frame = CGRectMake(emoticonX, emoticonY, emoticonButton.width, emoticonButton.height);
                
                index++;
                // 增长x.
                emoticonX += SN_EMOTICON_ICON_WIDTH + SN_EMOTICON_SCROLL_COLUMN_GAP;
            }
            emoticonX = page * self.bounds.size.width + SN_EMOTICON_START_X;
            emoticonY += SN_EMOTICON_BUTTON_HEIGHT + SN_EMOTICON_SCROLL_ROW_GAP;
        }
    }
}

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

@end
