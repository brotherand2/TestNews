//
//  SNBarButtonItem.h
//  sohunews
//
//  Created by Dan on 7/18/11.
//  Copyright 2011 Sohu.com Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum
{
    SNBarButtonItemStyleTitleOnly,
    SNBarButtonItemStyleImageOnly,
    SNBarButtonItemStyleStyleBoth
}  SNBarButtonItemStyle;

@interface SNBarButtonItem : UIBarButtonItem {
@protected
	UIButton *_btn;
    SNBarButtonItemStyle _buttonStyle;
}
- (id)initWithNomalImage:(UIImage *)nomalImage pressImage:(UIImage*)pressImage  target:(id)target action:(SEL)action frame:(CGRect)rect;
- (id)initWithImage:(UIImage *)image target:(id)target action:(SEL)action frame:(CGRect)rect;
- (id)initWithTitle:(NSString *)title target:(id)target action:(SEL)action;
- (id)initWithImage:(UIImage *)image target:(id)target action:(SEL)action;

- (id)initWithStyle:(SNBarButtonItemStyle)style AndImage:(UIImage *)image AndTitle:(NSString *)title target:(id)target action:(SEL)action;
- (id)initWithStyle:(SNBarButtonItemStyle)style AndImage:(UIImage *)image  AndImageHl:(UIImage*)imageHl  AndTitle:(NSString *)title target:(id)target action:(SEL)action;

- (UIImage *)image;
- (void)setTitle:(NSString *)title;
- (void)setHidden:(BOOL)isHidden;

// 无头化  只需要把button拿出
- (UIButton *)btn;

@end
