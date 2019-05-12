//
//  UIView+Utility.h
//  sohunews
//
//  Created by lhp on 9/26/13.
//  Copyright (c) 2013 Sohu.com. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIView(Utility)

- (void) moveAnimationWithCenter:(CGPoint) center stopSelector:(SEL)selector animationDelegate:(id)delegate;

// custom drawing
+ (void)drawVoteSeperateDashLine:(CGRect)bounds margin:(float)margin;
+ (void)drawVoteSeperateSolidLine:(CGRect)bounds margin:(float)margin;

+ (void)drawCellSeperateLine:(CGRect)bounds;
+ (void)drawCellSeperateLine:(CGRect)bounds margin:(float)margin;
+ (void)drawCellSeperateLine:(CGRect)bounds context:(CGContextRef) context;

+ (void)drawTextWithString:(NSMutableAttributedString *) textString
                  textRect:(CGRect) textRect
                   context:(CGContextRef) context;

+ (void)drawTextWithString:(NSMutableAttributedString *) textString
                  textRect:(CGRect) textRect
                viewHeight:(float) viewHeight
                   context:(CGContextRef) context;

@end
