//
//  SNLiveToolbar.h
//  sohunews
//
//  Created by chenhong on 13-6-29.
//  Copyright (c) 2013年 Sohu.com. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol SNLiveToolbarDelegate <NSObject>

@optional
- (void)liveToolBarBack;
- (void)liveToolBarInput;
- (BOOL)liveToolBarCanRec:(BOOL)showMsg;
- (void)liveToolBarStat;
- (void)liveToolBarShare;
- (void)liveToolBarRecBtnLongPressBegin;
- (void)liveToolBarRecBtnLongPressEnd;

@end

@interface SNLiveToolbar : UIView<UIGestureRecognizerDelegate> {
    id<SNLiveToolbarDelegate> __weak delegate;
}

@property(nonatomic,weak)id<SNLiveToolbarDelegate> delegate;

- (void)setPlaceholderForWorldCup;
- (void)setupWithStatBtn:(BOOL)bHasStatBtn recMode:(BOOL)mode;
- (BOOL)isRecMode;
- (BOOL)hasStatBtn;
- (void)updateTheme;
- (void)hideAllBtns:(BOOL)bHide;

- (void)onRecBtn:(id)sender;

@end
