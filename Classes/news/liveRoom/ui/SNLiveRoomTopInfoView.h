//
//  SNLiveRoomTopInfoView.h
//  sohunews
//
//  Created by wang yanchen on 13-5-10.
//  Copyright (c) 2013年 Sohu.com. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SNLiveContentObjects.h"
#import "SNWebImageView.h"

#define kSNLiveRoomTopInfoViewAnimationDuration             (0.3f)

@protocol SNLiveRoomTopInfoViewDelegate <NSObject>

- (void)expandTopInfoViewFromHeight:(CGFloat)fromH toHeight:(CGFloat)toH;

@end

@interface SNLiveRoomTopInfoView : UIView<UIGestureRecognizerDelegate> {
    SNWebImageView *_imageView;
    UIButton *_linkButton;
    id<SNLiveRoomTopInfoViewDelegate> __weak delegate;
}

@property(nonatomic, strong) SNLiveRoomTopObject *topObj;
@property(nonatomic, strong) SNWebImageView *imageView;
@property(nonatomic, strong) UIButton *linkButton;
@property(nonatomic, weak) id<SNLiveRoomTopInfoViewDelegate> delegate;
@property(nonatomic, assign) BOOL hasExpanded;

- (id)initWithTopObject:(SNLiveRoomTopObject *)topObj;
- (void)updateTheme;

@end
