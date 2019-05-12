//
//  SNSegmentControl.h
//  sohunews
//
//  Created by HuangZhen on 2017/6/8.
//  Copyright © 2017年 Sohu.com. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SNSegmentControl : UIView

@property (nonatomic, weak) UIScrollView * scrollView;

@property (nonatomic, assign, readonly) NSUInteger tabsCount;

- (void)setTabs:(NSArray *)tabTitles;

- (void)updateTheme;

- (void)removeListener;

@end
