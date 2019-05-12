//
//  SNNewsShareDrawBoardSlider.h
//  testSlider
//
//  Created by wang shun on 2017/7/14.
//  Copyright © 2017年 wang shun. All rights reserved.
//

#import <UIKit/UIKit.h>
@protocol SNNewsShareDrawBoardSliderDelegate;
@interface SNNewsShareDrawBoardSlider : UIView

@property (nonatomic,weak) id <SNNewsShareDrawBoardSliderDelegate> delegate;
@property (nonatomic,strong) UIColor* bgColor;

- (instancetype)initWithFrame:(CGRect)frame WithBgColor:(UIColor*)bgColor;

@end

@protocol SNNewsShareDrawBoardSliderDelegate <NSObject>

- (void)selectedColor:(UIColor*)color WithPoint:(CGPoint)point WithNumber:(NSInteger)n;

- (void)drawBroardStartTouch:(id)sender;
- (void)drawBroardEndTouch:(id)sender;

@end
