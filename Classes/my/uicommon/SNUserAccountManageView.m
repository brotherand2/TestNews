//
//  SNUserAccountManageView.m
//  sohunews
//
//  Created by yangln on 14-10-1.
//  Copyright (c) 2014年 Sohu.com. All rights reserved.
//

#import "SNUserAccountManageView.h"

#define IMAGE_TAG       202
#define TEXT_FIELD_TAG  204
#define pointX 82

@implementation SNUserAccountManageView

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        _pointY = 0;
        _currentItems = 1;
        self.backgroundColor = [UIColor clearColor];
    }
    
    return self;
}

- (void)addItemImage:(SNWebImageView*)aImage text:(NSString*)aText {
    //头像
    UIImage* defaultimage = [UIImage imageNamed:@"userinfo_default_headimage.png"];
    
    CGRect baseRect = CGRectMake(14, 15, 54, 54);
    aImage.frame = baseRect;
    aImage.tag = IMAGE_TAG;
    aImage.contentMode= UIViewContentModeScaleAspectFit;
    aImage.backgroundColor = [UIColor clearColor];
    aImage.userInteractionEnabled = YES;
    aImage.defaultImage = defaultimage;
    aImage.layer.cornerRadius = 27;
    [self addSubview:aImage];
    
    UILabel *nameLabel = [[UILabel alloc] init];
    nameLabel.text = aText;
    
    CGPoint point = CGPointMake(pointX, 32.5);
    nameLabel = [self setDownLabel:nameLabel point:point];
    
    [self addSubview:nameLabel];
}

- (void)addItemTextField:(UITextField *)aTextField upText:(NSString *)aText {
    CGPoint point = CGPointMake(pointX, _pointY+17);
    UILabel *label = [self setUpLabel:aText point:point coloString:kThemeText4Color];
    label.tag = NICK_NAME_TAG;
    [self addSubview:label];
    
    _pointY = label.bottom + 7;
    
    aTextField.frame = CGRectMake(pointX, _pointY, kAppScreenWidth-pointX, 19);
    aTextField.textAlignment = NSTextAlignmentLeft;
    
    aTextField.textColor = SNUICOLOR(kThemeText1Color);
    aTextField.returnKeyType = UIReturnKeyDone;
    aTextField.tag = TEXT_FIELD_TAG;
    aTextField.font = [UIFont fontWithName:kDigitAndLetterFontFimalyName size:16.0];
    aTextField.backgroundColor = [UIColor clearColor];
    aTextField.exclusiveTouch = YES;
    aTextField.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
    [self addSubview:aTextField];
    
    _pointY = aTextField.bottom + 17;
}

- (void)addItemUpDownText:(NSString *)aUp downText:(UILabel *)aDownLabel {
    CGPoint point = CGPointMake(pointX, _pointY);
    UILabel *label = [self setUpLabel:aUp point:point coloString:kThemeText4Color];
    if ([aUp isEqualToString:@"性别"]) {
        label.tag = GENDER_TAG;
    }
    else if ([aUp isEqualToString:@"所在地"]) {
        label.tag = LOCATION_TAG;
    }
    else if ([aUp isEqualToString:@"手机绑定"]) {
        label.tag = MOBILE_BIND_TAG;
    }
    [self addSubview:label];
    
    aDownLabel = [self setDownLabel:aDownLabel point:CGPointMake(pointX, label.bottom+7)];
    aDownLabel.tag = _currentItems;
    
    _currentItems++;
    _pointY = aDownLabel.bottom+17;
} 

- (UILabel *)setUpLabel:(NSString *)text point:(CGPoint)point coloString:(NSString *)coloString{
    UILabel *label = [[UILabel alloc] init];
    label.font = [UIFont systemFontOfSize:13];
    label.text = text;
    label.backgroundColor = [UIColor clearColor];
    label.textColor = SNUICOLOR(coloString);
    [label sizeToFit];
    label.origin = point;
    return label;
}

- (UILabel *)setDownLabel:(UILabel *)label point:(CGPoint)point {
    label.font = [UIFont systemFontOfSize:16];
    label.textColor = SNUICOLOR(kThemeText1Color);
    label.backgroundColor = [UIColor clearColor];
    [label sizeToFit];
    label.origin = point;
    label.size = CGSizeMake(self.frame.size.width-pointX, 19);
    label.userInteractionEnabled = YES;
    [self addSubview:label];
    
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapUILabelGesture:)];
    UIView *view = [tapGesture view];
    view.tag = label.tag;
    [label addGestureRecognizer:tapGesture];
    return label;
}

- (void)addSingleItem:(NSString *)aText {
    CGPoint point = CGPointMake(pointX, 11);
    UILabel *label = [self setUpLabel:aText point:point coloString:kThemeBlue1Color];
    label.userInteractionEnabled = YES;
    [self addSubview:label];
    
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapUILabelGesture:)];
    [label addGestureRecognizer:tapGesture];
}

- (void)tapUILabelGesture:(UITapGestureRecognizer *)gesture {
    UIView *view = [gesture view];
    if ([_delegate respondsToSelector:@selector(tapUILabelIndex:tag:)]) {
        [_delegate tapUILabelIndex:view.tag tag:self.tag];
    }
}

- (void)drawSeperateLine:(CGRect)rect {
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:rect];
    imageView.image = [[UIImage imageNamed:@"divider_line_v5.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(0, 2, 0, 0)];
    [self addSubview:imageView];
}

@end
