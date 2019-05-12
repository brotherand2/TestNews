//
//  SNStoryFontAdjustmentView.h
//  FacebookThree20
//
//  Created by chuanwenwang on 16/10/8.
//  Copyright © 2016年 chuanwenwang. All rights reserved.
//

#import <UIKit/UIKit.h>
@class SNStorySlider;

@protocol SNStoryFontAdjustmentViewDelegate <NSObject>

- (void)changeFont:(CGFloat)fontSize;

- (void)changeScreenBrightness:(CGFloat)radio;

@end


@interface SNStoryFontAdjustmentView : UIView

@property(nonatomic, strong)SNStorySlider *slider;

@property(nonatomic, weak) id <SNStoryFontAdjustmentViewDelegate> delegate;
-(instancetype)initWithFrame:(CGRect)frame novelId:(NSString*)novelId;
- (void)updateNovelTheme;
@end
