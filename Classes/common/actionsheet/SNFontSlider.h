//
//  SNFontSlider.h
//  sohunews
//
//  Created by lhp on 9/29/13.
//  Copyright (c) 2013 Sohu.com. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol SNFontSliderDelegate <NSObject>

- (void)changeFontSliderIndex:(int)index;

@end

@interface SNFontSlider : UISlider {
    
    int fontIndex;
    int setterCnt;
}

@property (nonatomic, weak) id<SNFontSliderDelegate> sliderDelegate;

- (id)initWithFrame:(CGRect)frame setterCnt:(int)count;
- (void)setSliderWithIndex;
- (void)changeSliderWithIndex:(int)index;
- (void)changeSliderWithIndex:(int)index andNotify:(BOOL)notify;
- (void)updateTheme;

@end
