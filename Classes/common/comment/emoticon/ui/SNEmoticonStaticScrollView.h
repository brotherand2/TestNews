//
//  SNEmoticonScrollView.h
//  sohunews
//
//  Created by jialei on 14-5-4.
//  Copyright (c) 2014年 Sohu.com. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SNEmoticonManager.h"

@class SNEmoticonObject;

@interface SNEmoticonStaticScrollView : UIScrollView<UIScrollViewDelegate>
{
    int _rowCount;
    int _columnCount;
    
    NSInteger _emoticonCount;
    int _emoticonsPerPage;
    int _pageCount;
    BOOL _pageControlUsed;
    UIPageControl *_pageControl;
    
    NSMutableArray *_emoticonImageViews;
    NSMutableArray *_emoticonDes;
    NSArray *_emoticonObjects;
}

@property (nonatomic, weak) id <SNEmoticonScrollViewDelegate>emoticonDelegate;
@property (nonatomic, assign) SNEmoticonType type;

- (id)initWithObjects:(NSArray *)objects frame:(CGRect)frame;
- (void)createEmotions;
- (void)createEmotionDes;

@end
