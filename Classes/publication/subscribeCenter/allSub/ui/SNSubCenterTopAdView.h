//
//  SNSubCenterTopAdView.h
//  sohunews
//
//  Created by wang yanchen on 12-11-27.
//  Copyright (c) 2012年 Sohu.com Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SNPageControl.h"
#import "SNAdDataCarrier.h"

@interface SNSubCenterTopAdView : UIView<UIScrollViewDelegate> {
    NSArray *_adListArray;
    UIScrollView *_scrollView;
    UIView *_pageOne;
    UIView *_pageTwo;
    
    SNPageControl *_pageControl;
    
    UIImageView *_bottomSepLine;
    NSInteger _pageNum;
}

@property (nonatomic, strong) NSArray *adListArray;
@property (nonatomic, strong) NSMutableArray *adDataCarriers;

/*广告数据展示曝光统计
 *对于在当前scrollView滑动出现的广告数据进行展示曝光统计
 */
- (void)reportAdExporeData;
- (void)appendAdDataCarriers:(SNAdDataCarrier *)adDataCarrier;
- (void)updateTheme;

@end
