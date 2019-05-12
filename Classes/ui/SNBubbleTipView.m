//
//  SNBubbleTipView.m
//  sohunews
//
//  Created by weibin cheng on 13-9-3.
//  Copyright (c) 2013年 Sohu.com. All rights reserved.
//

#import "SNBubbleTipView.h"

#define kSNDefaultBubbleWidth 28
#define kSNDefaultBubbleHeight 16

typedef enum
{
    SNSingleNumber,
    SNDoubleNumber,
    SNMoreNumber
} SNBubbleNumber;

@implementation SNBubbleTipView
@synthesize tipCount = _tipCount;
@synthesize image = _image;
@synthesize defaultHeight = _defaultHeight;
@synthesize alignType = _alignType;

- (id)initWithType:(SNBubbleType)type
{
    self = [super init];
    if(self)
    {
        _type = type;
        _alignType = SNBubbleAlignLeft;
        switch (_type) {
            case SNHeadBubbleType:
            {
                self.image = [UIImage themeImageNamed:@"head_bubble.png"];
                break;
            }
            case SNTableBubbleType:
            {
                self.image = [UIImage themeImageNamed:@"icohome_dot_v5.png"];
                break;
            }
            case SNTabbarBubbleType:
            {
                self.image = [UIImage themeImageNamed:@"icohome_dot_v5.png"];
                break;
            }
        }

        CGFloat width = 2;
        if ([_image respondsToSelector:@selector(resizableImageWithCapInsets:)]) {
            _imageView.image = [_image resizableImageWithCapInsets:UIEdgeInsetsMake(0, width, 0, width)];
        }
        self.userInteractionEnabled = NO;
        _imageView = [[UIImageView alloc] initWithImage:self.image];
        _imageView.hidden = YES;
        [self addSubview:_imageView];
        
        _label = [[UILabel alloc] init];
        _label.backgroundColor = [UIColor clearColor];
        _label.textAlignment = NSTextAlignmentCenter;
        _label.textColor = [UIColor whiteColor];
        if(_type == SNTabbarBubbleType)
        {
            _label.font = [UIFont systemFontOfSize:9];
        }
        else
        {
            _label.font = [UIFont systemFontOfSize:self.defaultHeight-4];
        }
        
        _label.hidden = YES;
        _label.numberOfLines = 1;
        [_imageView addSubview:_label];
        
        [SNNotificationManager addObserver:self selector:@selector(updateTheme) name:kThemeDidChangeNotification object:nil];
    }
    return self;
}

- (void)dealloc
{
    [SNNotificationManager removeObserver:self];
}
/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/
- (int)defaultHeight
{
    if(self.image)
        return self.image.size.height;
    else
        return 0;
}

-(int)defaultWidth
{
    switch (_type) {
        case SNHeadBubbleType:
        {
            return 20;
        }
        case SNTableBubbleType:
        {
            return 28;
        }
        case SNTabbarBubbleType:
        {
            return 28;
        }
        default:
            return 0;
    }
}


- (int)bubbleWidth:(SNBubbleNumber)number
{
    switch (_type) {
        case SNHeadBubbleType:
        {
            if(number == SNSingleNumber)
                return 11;
            else if(number == SNDoubleNumber)
                return 14;
            else
                return 18;
        }
        case SNTableBubbleType:
        {
            if(number == SNSingleNumber)
                return 16;
            else if(number == SNDoubleNumber)
                return 20;
            else
                return 26;
        }
        case SNTabbarBubbleType:
        {
            if(number == SNSingleNumber)
                return 13;
            else if(number == SNDoubleNumber)
                return 16;
            else
                return 20;
        }
        default:
            return 0;
    }
}

- (void)setBubbleImageFrame:(CGRect) imageFrame withImage:(UIImage *) image
{
    _imageView.hidden = NO;
    _imageView.frame = imageFrame;
    _imageView.image = image;
}

- (void)setTipCount:(int)tipCount
{
    _tipCount = tipCount;
    CGFloat width = self.image.size.width/2;
    if ([_image respondsToSelector:@selector(resizableImageWithCapInsets:)]) {
        _imageView.image = [_image resizableImageWithCapInsets:UIEdgeInsetsMake(0, width, 0, width)];
    }
    if(tipCount == 0)
    {
        _imageView.hidden = YES;
        _label.hidden = YES;
    }
    else if(tipCount >= 10)
    {
        _imageView.hidden = NO;
        _label.hidden = NO;
        if(tipCount <= 99)
        {
            if(_alignType == SNBubbleAlignLeft)
                _imageView.frame = CGRectMake(0, 0, [self bubbleWidth:SNDoubleNumber], self.defaultHeight);
            else
                _imageView.frame = CGRectMake(self.width - [self bubbleWidth:SNDoubleNumber], 0, [self bubbleWidth:SNDoubleNumber], self.defaultHeight);
            _label.frame = _imageView.bounds;
            _label.text = [NSString stringWithFormat:@"%d",tipCount];
        }
        else
        {
            if(_alignType == SNBubbleAlignLeft)
                _imageView.frame = CGRectMake(0, 0, [self bubbleWidth:SNMoreNumber], self.defaultHeight);
            else
                _imageView.frame = CGRectMake(self.width - [self bubbleWidth:SNMoreNumber], 0, [self bubbleWidth:SNMoreNumber], self.defaultHeight);
            _label.frame = _imageView.bounds;
            _label.text = @"99+";
        }
    }
    else if(tipCount < 0)
    {
        UIImage* image = [UIImage themeImageNamed:@"icohome_dot_v5.png"];
        _imageView.image = image;
        if (_type == SNBubbleAlignRight) {
            _imageView.frame = CGRectMake(self.width+20, self.height, 4, 4);
        }
        else {
            if(_alignType == SNBubbleAlignLeft)
                _imageView.frame = CGRectMake(2, 6, 4, 4);
            else
                _imageView.frame = CGRectMake(self.width - 7, 2, 4, 4);
        }
        
        _label.frame = _imageView.bounds;
        _imageView.hidden = NO;
        _label.hidden = YES;
    }
    else
    {
        if(_alignType == SNBubbleAlignLeft)
            _imageView.frame = CGRectMake(0, 0, [self bubbleWidth:SNSingleNumber], self.defaultHeight);
        else
            _imageView.frame = CGRectMake(self.width - [self bubbleWidth:SNSingleNumber], 0, [self bubbleWidth:SNSingleNumber], self.defaultHeight);
        _label.frame = _imageView.bounds;
        _imageView.hidden = NO;
        _label.hidden = NO;
        _label.text = [NSString stringWithFormat:@"%d",tipCount];
    }
}

- (void)fixDotImageViewPos {
    _imageView.left = self.width - 22;
    _imageView.alpha = 1;
    [UIView animateWithDuration:3
                          delay:0
                        options:UIViewAnimationOptionRepeat|UIViewAnimationOptionAutoreverse
                     animations:^{
                         _imageView.alpha = 0.3;
                     } completion:^(BOOL finished) {
                     }];
}

- (void)updateImage
{
    switch (_type) {
        case SNHeadBubbleType:
        {
            self.image = [UIImage themeImageNamed:@"head_bubble.png"];
            break;
        }
        case SNTableBubbleType:
        {
            self.image = [UIImage themeImageNamed:@"icohome_dot_v5.png"];
            break;
        }
        case SNTabbarBubbleType:
        {
            self.image = [UIImage themeImageNamed:@"icohome_dot_v5.png"];
            break;
        }
        default:{
            self.image = [UIImage themeImageNamed:@"icohome_dot_v5.png"];
            break;
        }
    }
    
    CGFloat width = self.image.size.width/2;
    if ([_image respondsToSelector:@selector(resizableImageWithCapInsets:)]) {
        _imageView.image = [_image resizableImageWithCapInsets:UIEdgeInsetsMake(0, width, 0, width)];
    }
}

- (void)updateTheme
{
    [self updateImage];
}

@end
