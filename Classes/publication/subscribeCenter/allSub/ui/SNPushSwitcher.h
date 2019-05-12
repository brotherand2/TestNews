//
//  SNPushSwitcher.h
//  sohunews
//
//  Created by wang yanchen on 12-12-3.
//  Copyright (c) 2012年 Sohu.com Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

#define kPushSettingSwitcherWidth       (114 / 2)
#define kPushSettingSwitcherHeight      (54 / 2)

@interface SNPushSwitcher : UIView {
    UIImageView *_bgSliderView;
    UIImageView *_maskView;
    UIImageView *_handlerView;
    
    int _currentIndex;
    int _lastIndex;
    id __weak _delegate;
    
    BOOL _isTouched;
    BOOL _isMoved;
    BOOL _isOverFlowTapOffset;
    CGPoint _downPt;
    CGFloat _handlerLastX;
}

@property(nonatomic,assign)int currentIndex;
@property(nonatomic, weak) id delegate;
@property(nonatomic, assign) BOOL supportDrag; // default is YES
@property(nonatomic, weak) id scrollViewDelegate; // user for disable scroll
@property(nonatomic, strong)UIImageView *maskView;
@property(nonatomic, strong)UIImageView *bgSliderView;
@property (nonatomic, strong)NSString *switchName;

- (void)setCurrentIndex:(int)index animated:(BOOL)animated inEvent:(BOOL)isInEvent;
- (void)setCurrentIndex:(int)index animated:(BOOL)animated;

@end

@protocol SNPushSwitcherDelegate <NSObject>

@optional
- (void)swither:(SNPushSwitcher *)switcher indexDidChanged:(int)newIndex;

@end
