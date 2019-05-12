//
//  SNHeadSelectView.h
//  sohunews
//
//  Created by wang yanchen on 12-9-20.
//  Modify by cheng weibin on 13-7-1
//  Copyright (c) 2012年 Sohu.com Inc. All rights reserved.
//
#import "SNBubbleTipView.h"


#define kHeadBottomWidth            (1280 / 2)
#define kHeadBottomHeight           (0 / 2)
#define kHeaderHeight               44
#define kHeaderTotalHeight          (kHeaderHeight + kSystemBarHeight)
#define kHeaderHeightWithoutBottom  (kHeaderTotalHeight - kHeadBottomHeight)
#define kSystemBarHeight            ([[SNDevice sharedInstance] isPhoneX]?(44):(20))

@interface SNHeadItemView : UIView {
    UILabel *_title;
    UIButton *_maskBtn;
    UIImageView *_dotView;
    id _delegate;
    BOOL _isSelected;
    SNBubbleTipView *_tipView;
}

@property(nonatomic, assign) BOOL isSelected;
@property(nonatomic, assign) int viewIndex;
@property(nonatomic, assign) CGFloat textFont;
@property(nonatomic, assign) CGFloat textSideMargin;

- (id)initWithFrame:(CGRect)frame itemTitle:(NSString *)title delegate:(id)delegate;
- (void)updateTheme;
- (void)setTipCount:(int)count;
@end


@interface SNHeadSelectView : UIView {
    NSArray *_sections;
    NSMutableArray *_sectionViews;
    
    // view parts
    UIImageView *_backgroundView;
    UIImageView *_bottomView;
    
    
//    int _currentIndex;
    id __weak _delegate;
    id _offsetListenObj;
}

@property (nonatomic, strong) NSArray *sections;
@property (nonatomic, strong) NSMutableArray *sectionViews;
@property (nonatomic, assign) BOOL unanimated;
@property (nonatomic, weak  ) id delegate;
@property (nonatomic, assign) int currentIndex;
@property (nonatomic, assign) CGFloat textFont;
@property (nonatomic, assign) CGFloat textSideMargin;
@property (nonatomic, strong) UIView *backgroundView;
@property (nonatomic, strong) UIImageView *bottomView;
@property (nonatomic, strong) UIImageView *bottomLineImageView;
@property (nonatomic, strong) UIImageView *shadowImageView;

- (void)setSections:(NSArray *)sections withItemViewClass:(Class)clazz;

- (void)setCurrentIndex:(int)index animated:(BOOL)animated;
- (void)updateTheme;

- (CGFloat)realHeight;

- (void)moveBottomViewToPosX:(CGFloat)x;

- (void)sectionViewTapped:(SNHeadItemView *)itemView;

- (void)registerOffsetListener:(id)listenObj; // listen obj -- > contentOffset
- (void)resignOffsetListener;
- (void)setTipCount:(int)count withIndex:(int)index;

- (void)setBottomLineForHeaderView:(CGRect)rect;

@end

@protocol SNHeadSelectViewDelegate <NSObject>

@optional
- (void)headView:(SNHeadSelectView *)headView didSelectIndex:(int)index;

@end
