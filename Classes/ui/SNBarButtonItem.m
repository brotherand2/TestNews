//
//  SNBarButtonItem.m
//  sohunews
//
//  Created by Dan on 7/18/11.
//  Copyright 2011 Sohu.com Inc. All rights reserved.
//

#import "SNBarButtonItem.h"

#define kButtonDefaultWidth (100/2)
#define kButtonDefaultHeight (60/2)


@implementation SNBarButtonItem
- (id)initWithImage:(UIImage *)image target:(id)target action:(SEL)action {
	UIButton *btn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, kButtonDefaultWidth, kButtonDefaultHeight)];
	[btn setExclusiveTouch:YES];
	[btn setImage:image forState:UIControlStateNormal];
    self = [super initWithCustomView:btn];
    _btn = btn;
    if (self) {
		[_btn addTarget:target action:action forControlEvents:UIControlEventTouchUpInside];
	}
//    _customStyle = NO;
    return self;
}

- (id)initWithImage:(UIImage *)image target:(id)target action:(SEL)action frame:(CGRect)rect{
    UIButton *btn = [[UIButton alloc] initWithFrame:rect];
	[btn setExclusiveTouch:YES];
	[btn setImage:image forState:UIControlStateNormal];
    self = [super initWithCustomView:btn];
    _btn = btn;
    if (self) {
		[_btn addTarget:target action:action forControlEvents:UIControlEventTouchUpInside];
	}
//    _customStyle = NO;
    return self;
}

- (id)initWithNomalImage:(UIImage *)nomalImage pressImage:(UIImage*)pressImage  target:(id)target action:(SEL)action frame:(CGRect)rect{
    UIButton *btn = [[UIButton alloc] initWithFrame:rect];
	[btn setExclusiveTouch:YES];
	[btn setImage:nomalImage forState:UIControlStateNormal];
    [btn setImage:pressImage forState:UIControlStateHighlighted];
    self = [super initWithCustomView:btn];
    _btn = btn;
    if (self) {
		[_btn addTarget:target action:action forControlEvents:UIControlEventTouchUpInside];
	}
//    _customStyle = NO;
    return self;
}

- (id)initWithTitle:(NSString *)title target:(id)target action:(SEL)action {
	UIButton *btn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, kButtonDefaultWidth, kButtonDefaultHeight)];
	[btn setExclusiveTouch:YES];
	[btn.titleLabel setFont:[UIFont boldSystemFontOfSize:14]];
	[btn.titleLabel setShadowOffset:CGSizeMake(0, -1)];

    self = [super initWithCustomView:btn];
    _btn = btn;
    [self setTitle:title];
    if (self) {
		[_btn addTarget:target action:action forControlEvents:UIControlEventTouchUpInside];
	}
//    _customStyle = NO;
    return self;
}

- (id)initWithStyle:(SNBarButtonItemStyle)style AndImage:(UIImage *)image AndTitle:(NSString *)title target:(id)target action:(SEL)action {
    _buttonStyle = style;
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    btn.frame = CGRectMake(0, 0, kButtonDefaultWidth, kButtonDefaultHeight);
    [btn setExclusiveTouch:YES];
    [btn.titleLabel setFont:[UIFont digitAndLetterFontOfSize:24]];
    btn.titleLabel.textAlignment = NSTextAlignmentRight;
//    btn.layer.borderWidth = 1;
//    btn.layer.borderColor = [UIColor blueColor].CGColor;
    [btn setImage:image forState:UIControlStateNormal];
    
    self = [super initWithCustomView:btn];
    _btn = btn;
    [self setTitle:title];
    
//    btn.imageEdgeInsets = UIEdgeInsetsMake(-4, kButtonDefaultWidth-image.size.width-4, image.size.height, 0);
//    btn.titleEdgeInsets = UIEdgeInsetsMake(0, -image.size.width, 0, image.size.width);
    
    if (self) {
		[_btn addTarget:target action:action forControlEvents:UIControlEventTouchUpInside];
	}
//    _customStyle = YES;
    return self;
}

- (id)initWithStyle:(SNBarButtonItemStyle)style AndImage:(UIImage *)image  AndImageHl:(UIImage*)imageHl  AndTitle:(NSString *)title target:(id)target action:(SEL)action {
    _buttonStyle = style;
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    btn.frame = CGRectMake(0, 0,kButtonDefaultWidth,kButtonDefaultHeight);
    [btn setExclusiveTouch:YES];
    [btn.titleLabel setFont:[UIFont digitAndLetterFontOfSize:24]];
    btn.titleLabel.textAlignment = NSTextAlignmentRight;
    [btn setImage:image forState:UIControlStateNormal];
    [btn setImage:imageHl forState:UIControlStateHighlighted];
    self = [super initWithCustomView:btn];
    _btn = btn;
    [self setTitle:title];
    if (self) {
		[_btn addTarget:target action:action forControlEvents:UIControlEventTouchUpInside];
	}

    return self;
}

- (UIImage *)image {

    return nil;
}

- (NSString *)title {
	return _btn.titleLabel.text;
}

- (void)setTitle:(NSString *)title {
    
    NSString *strColor = [[SNThemeManager sharedThemeManager] currentThemeValueForKey:kBarBtnItemTextColor];
    [_btn setTitleColor:[UIColor colorFromString:strColor] forState:UIControlStateNormal];
    
	[_btn setTitle:title forState:UIControlStateNormal];
	
	CGSize textSize = [title sizeWithFont:_btn.titleLabel.font 
										  constrainedToSize:CGSizeMake(TTScreenBounds().size.width / 2, kButtonDefaultHeight)];
	
	if (textSize.width + _btn.imageView.frame.size.width+10 > kButtonDefaultWidth) {
        float w = textSize.width+_btn.imageView.frame.size.width+10;
		[_btn setFrame:CGRectMake(TTScreenBounds().size.width - 5 - w/*_btn.frame.origin.x*/, _btn.frame.origin.y, w, kButtonDefaultHeight)];
	}
    

    float right = 2*_btn.imageView.frame.size.width-(_btn.frame.size.width-textSize.width)+12-8;
    _btn.imageEdgeInsets = UIEdgeInsetsMake(-6, _btn.frame.size.width-_btn.imageView.frame.size.width-9, _btn.imageView.frame.size.height, 5);
    _btn.titleEdgeInsets = UIEdgeInsetsMake(0, -_btn.imageView.frame.size.width, 0, right);

	[_btn setBackgroundImage:self.image forState:UIControlStateNormal];
}


- (void)setHidden:(BOOL)isHidden {
	[_btn setHidden:isHidden];
}

- (UIButton *)btn {
    return _btn;
}
	 

@end
