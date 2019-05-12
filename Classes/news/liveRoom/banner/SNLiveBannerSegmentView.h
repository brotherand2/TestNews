//
//  SNLiveBannerSegmentView.h
//  sohunews
//
//  Created by wang yanchen on 13-5-2.
//  Copyright (c) 2013年 Sohu.com. All rights reserved.
//

#import <UIKit/UIKit.h>

#define kLiveBannerSegmentViewHeight                    (54 / 2)

@interface SNLiveBannerSegmentView : UIControl {
    NSMutableArray *_segmentViews;
    
    UIButton *_exBtn;
    
    UIImageView *_bottomView;
    
    NSMutableDictionary *_newMarkInfoDic;
}

@property(nonatomic, assign) NSInteger currentIndex;
@property(nonatomic, assign) BOOL hasExpanded;
@property(nonatomic, assign) BOOL isWorldCup;

- (void)createWithSectionsArray:(NSArray *)sections hasExpandButton:(BOOL)hasExpandButton isExpand:(BOOL)isExpand;
- (void)scrollViewDidScroll:(UIScrollView *)scrollView;
- (void)resetBtnsState;
- (void)showPopNewMark:(BOOL)show atIndex:(int)index;
- (BOOL)hasNewMarkAtIndex:(int)index;
- (void)updateTheme;

@end
