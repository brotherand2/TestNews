//
//  SNTabbarView.h
//  sohunews
//
//  Created by wang yanchen on 13-1-17.
//  Copyright (c) 2013年 Sohu.com Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SNTabBarButton : UIView {
    NSString *_imgSelect;
    NSString *_imgNormal;
    BOOL _isSelected;
}

@property (nonatomic, strong) NSString *imgSelect;
@property (nonatomic, strong) NSString *imgNormal;
@property (nonatomic, copy) NSString *text;
@property (nonatomic, strong) UIButton *maskButton;
@property (nonatomic, strong) UIImageView *tabBarImageView;
@property (nonatomic, strong) UILabel *tabBarLabel;
@property (nonatomic, strong) NSString *channelID;
@property (nonatomic, strong) UIImageView *identifyImageView;
@property (nonatomic, strong) UILabel *identifyLabel;

- (SNTabBarButton *)initWithFrame:(CGRect)frame normalImage:(NSString *)imgNormal selectImage:(NSString *)imgSelect text:(NSString *)text;
- (void)addTarget:(id)target action:(SEL)action forControlEvents:(UIControlEvents)controlEvents;
- (void)updateTheme;
- (void)setIdentifyOnButton;
- (void)removeIdendifyOnButton;

@end
///////////////////////////////////////////////////////
///////////////////////////////////////////////////////
///////////////////////////////////////////////////////
@interface SNTabbarView : UIView {
    NSArray *_viewControllers;
    NSMutableArray *_tabButtons;
    NSInteger _currentSelectedIndex;
    BOOL _isForceClick;
    id __weak _delegate;
    UIImageView *_bgnView;
}

@property(nonatomic, strong) UIImage *bgImage;
@property(nonatomic, strong) NSArray *viewControllers;
@property(weak, nonatomic, readonly) NSArray *tabButtons;
@property(nonatomic, assign) NSInteger currentSelectedIndex;
@property(nonatomic, weak) id delegate;
@property(nonatomic, assign) BOOL isForceClick;
@property(nonatomic, strong) UIView *coverLayer;
@property (nonatomic, strong) UIImageView *tabBackImageView;

+ (SNTabbarView *)tabbarViewWithViewControllers:(NSArray *)viewControllers;
+ (CGFloat)tabBarHeightForiPhoneX;
- (void)updateTheme;
- (void)refreshTabButton;
- (void)tabButtonClicked:(UIButton *)btn;
- (UIImage *)tabSnapShot;
- (void)forceClickAtIndex:(int)index;
- (void)showCoverLayer:(BOOL)show;
- (void)updateTabButtonTitle;
@end

@protocol SNTabbarViewDelegate <NSObject>

@optional
- (void)tabbarViewIndexWillChanged:(NSInteger)index;
- (void)tabbarViewIndexDidChanned:(NSInteger)index;
@end
