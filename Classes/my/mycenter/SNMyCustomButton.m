//
//  SNMyCustomButton.m
//  sohunews
//
//  Created by weibin cheng on 13-12-9.
//  Copyright (c) 2013年 Sohu.com. All rights reserved.
//

#import "SNMyCustomButton.h"


@implementation SNMyCustomButton
@synthesize text = _text;
@synthesize clickSelector = _clickSelector;
@synthesize delegate = _delegate;
@synthesize iconName = _iconName;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        // Initialization code
        self.backgroundColor = [UIColor clearColor];
//        _button = [[UIButton buttonWithType:UIButtonTypeCustom] retain];
//        _button.frame = self.bounds;
//        _button.backgroundColor = [UIColor clearColor];
//        _button.showsTouchWhenHighlighted = YES;
//        [_button addTarget:self action:@selector(clickButton) forControlEvents:UIControlEventTouchUpInside];
//        [self addSubview:_button];
        
        _imageView = [[UIImageView alloc] initWithFrame:CGRectZero];
        _imageView.backgroundColor = [UIColor clearColor];
        [self addSubview:_imageView];
        
        _label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 80.0, 45)];
        _label.backgroundColor = [UIColor clearColor];
        _label.textColor = SNUICOLOR(kThemeText1Color);
        _label.font = [UIFont systemFontOfSize:13];
        _label.textAlignment = NSTextAlignmentLeft;
        [self addSubview:_label];
        
        _bubbleView = [[SNBubbleTipView alloc] initWithType:SNBubbleAlignRight];
        _bubbleView.frame = CGRectZero;
        [self addSubview:_bubbleView];
        
        [SNNotificationManager addObserver:self selector:@selector(updateTheme) name:kThemeDidChangeNotification object:nil];
    }
    return self;
}
-(void)dealloc
{
//     //(_button);
     //(_imageView);
     //(_label);
     //(_text);
     //(_bubbleView);
     //(_iconName);
    [SNNotificationManager removeObserver:self];
}

-(void)clickButton
{
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
    if(_delegate && _clickSelector && [_delegate respondsToSelector:_clickSelector])
       [_delegate performSelector:_clickSelector withObject:self];
#pragma clang diagnostic pop
}

-(void)setIconName:(NSString *)iconName
{
    if(_iconName != iconName)
    {
        _iconName = iconName;
    }
    UIImage* icon = [UIImage themeImageNamed:_iconName];
    CGRect rect;
    rect.origin.x = 14;
    rect.origin.y = 11;
    rect.size = icon.size;
    _imageView.image = icon;
    _imageView.frame = rect;
    _bubbleView.frame = CGRectMake(_imageView.right, 3, _bubbleView.defaultWidth, _bubbleView.defaultHeight);
    _label.left = _imageView.right + 14;
}

-(void)setText:(NSString *)text
{
    if(_text != text)
    {
        _text = text;
    }
    _label.text = text;
//    _button.accessibilityLabel = text;
}
-(void)setTipCount:(NSInteger)count
{
//    if(_bubbleView)
//        [_bubbleView setTipCount:count];
    if (_bubbleView && count!=0) {
        UIImage *icon = [UIImage themeImageNamed:_iconName];
        UIImage *dotImage = [UIImage imageNamed:@"icohome_dot_v5.png"];
        [_bubbleView setBubbleImageFrame:CGRectMake(icon.size.width+26, 26-2*dotImage.size.width, dotImage.size.width, dotImage.size.height) withImage:dotImage];
    }
    else {
        [_bubbleView setTipCount:0];
    }
}

- (void)fixDotImageViewPos {
    if (_bubbleView) {
        [_bubbleView fixDotImageViewPos];
    }
}

-(void)updateTheme
{
    _imageView.image = [UIImage themeImageNamed:_iconName];
    _label.textColor = SNUICOLOR(kThemeText1Color);
}

- (void)resetImageViewAndLabelOrigin {
    _imageView.origin = CGPointMake(14, 22);
    _label.origin = CGPointMake(_label.origin.x, 11);
    _bubbleView.origin = CGPointMake(_imageView.right, 14);
}

@end
