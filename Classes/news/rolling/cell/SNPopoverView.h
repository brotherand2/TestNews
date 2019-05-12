//
//  SNPopoverView.h
//  sohunews
//
//  Created by wangyy on 15/11/26.
//  Copyright © 2015年 Sohu.com. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SNPopoverView : UIView

@property (nonatomic, assign) float endInterval;
@property (nonatomic, copy) UIColor *borderColor;;

- (id)initWithPoint:(CGPoint)point size:(CGSize)size;
- (id)initWithTitle:(NSString *)title Point:(CGPoint)point size:(CGSize)size leftImageName:(NSString *)leftImageName;
- (id)initWithDownTitle:(NSString *)title Point:(CGPoint)point size:(CGSize)size leftImageName:(NSString *)leftImageName;

/**
 默认展示在keyWindow上
 */
-(void)show;

/**
 展示在指定的view上

 @param view customView
 */
-(void)showView:(UIView *)view;
-(void)dismiss;
-(void)dismiss:(BOOL)animated;
- (void)updateTheme;

@end
