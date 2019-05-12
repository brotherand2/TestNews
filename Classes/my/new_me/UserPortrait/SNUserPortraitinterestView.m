//
//  SNUserPortraitinterestView.m
//  sohunews
//
//  Created by iOS_D on 2016/12/23.
//  Copyright © 2016年 Sohu.com. All rights reserved.
//

#import "SNUserPortraitinterestView.h"

@implementation SNUserPortraitinterestView


-(instancetype)initWithFrame:(CGRect)frame{
    if (self = [super initWithFrame:frame]) {
        [self configView];
    }
    return self;
}

- (void)configView{
    CGFloat r = self.bounds.size.width/2;
    _bgView = [[UIView alloc] initWithFrame:self.bounds];
    [self addSubview:_bgView];
    _bgView.layer.cornerRadius = r;
    _bgView.layer.borderColor = SNUICOLOR(kThemeText3Color).CGColor;
    _bgView.layer.borderWidth = 1;
    
    CGFloat f = self.bounds.size.width/3.0;
    _contentLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, f*2, f*2)];
    _contentLabel.numberOfLines = 0;
    _contentLabel.textAlignment = NSTextAlignmentCenter;
    _contentLabel.backgroundColor = [UIColor clearColor];
    _contentLabel.center = CGPointMake(r, r);
    _contentLabel.font = [UIFont systemFontOfSize:f-5];
    _contentLabel.textColor = SNUICOLOR(kThemeText3Color);
    _contentLabel.text = @"";
    [self addSubview:_contentLabel];
    
    CGFloat b_yes_f = _bgView.bounds.size.width/119.0;
    CGFloat b_yes_w = b_yes_f * 23;
    CGFloat b_yes_x = b_yes_f * 85;
    CGFloat b_yes_y = b_yes_f * 96;
    
    _yesView = [[UIImageView alloc] initWithFrame:CGRectMake(b_yes_x+CGRectGetMinX(_bgView.frame), b_yes_y, b_yes_w, b_yes_w)];
    [_yesView setImage:[UIImage themeImageNamed:@"icofiction_xz_v5.png"]];
    _yesView.hidden = YES;
    [self addSubview:_yesView];
}

- (void)setContentData:(NSString*)content{
    [_contentLabel setText:content];
}

-(void)setInfo:(NSDictionary *)info{
    if (self.info != info) {
        _info = info;
    }
    
    NSString* each_title = [self.info objectForKey:@"tagName"];
    [self setContentData:each_title];
}

-(void)setIsSelected:(BOOL)isSelected{
    _isSelected = isSelected;

    if (_isSelected) {//选中
        _contentLabel.textColor = SNUICOLOR(kThemeRed1Color);
        _bgView.layer.borderColor = SNUICOLOR(kThemeRed1Color).CGColor;
        _yesView.hidden = NO;
    }
    else{
        _contentLabel.textColor = SNUICOLOR(kThemeText3Color);
        _bgView.layer.borderColor = SNUICOLOR(kThemeText3Color).CGColor;
        _yesView.hidden = YES;
    }
}




//SNUICOLOR(kThemeRed1Color)

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
