//
//  SNMoreActionSwitch.m
//  sohunews
//
//  Created by weibin cheng on 14-10-21.
//  Copyright (c) 2014年 Sohu.com. All rights reserved.
//

#import "SNMoreActionSwitch.h"
#import "SNThemeManager.h"

#import "SNConsts.h"

#define INDICATOR_OFFSET_X (5)  //_indicator的图片有透明色，5像素是看不到的所以加了偏移

@implementation SNMoreActionSwitch

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        _button = [UIButton buttonWithType:UIButtonTypeCustom];
        _button.frame = self.bounds;
        _button.backgroundColor = [UIColor clearColor];
        [_button addTarget:self action:@selector(onClick) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:_button];
        _button.clipsToBounds = NO;

        
        UIImage* image = [UIImage themeImageNamed:@"icofloat_offline_v5.png"];
        _line = [[UIImageView alloc] initWithImage:image];
        _line.frame = CGRectMake(0, frame.size.height/2-1, frame.size.width, 2);
        [_button addSubview:_line];
        
        image = [UIImage themeImageNamed:@"icofloat_offbottom_v5.png"];
        _indicator =  [[UIImageView alloc] initWithImage:image];
        _indicator.frame = CGRectMake((-INDICATOR_OFFSET_X), (frame.size.height-image.size.height)/2, image.size.width, image.size.height);
        [_button addSubview:_indicator];
        
    }
    return self;
}

- (void)dealloc
{
     //(_button);
     //(_line);
     //(_indicator);
}

- (void)setOpen:(BOOL)open
{
    _open = open;
    if(!_open)
    {
        _indicator.left = (-INDICATOR_OFFSET_X);
        _line.image = [UIImage themeImageNamed:@"icofloat_offline_v5.png"];
        _indicator.image = [UIImage themeImageNamed:@"icofloat_offbottom_v5.png"];
    }
    else
    {
        _line.image = [UIImage themeImageNamed:@"icofloat_openline_v5.png"];
        _indicator.image = [UIImage themeImageNamed:@"icofloat_openbottom_v5.png"];
        _indicator.left = self.frame.size.width - _indicator.image.size.width + INDICATOR_OFFSET_X;
    }
}

- (void)onClick
{
    float timer = 0.3f;
    
    /*
    if(_open){
        _line.alpha = 1.0f;
    }else{
        _line.alpha = 0.2f;
    }
    */
    //lijian 2014.12.17 全屏浮层中开关的动画效果修改
    [UIView animateWithDuration:timer animations:^{
        if(_open){
            _indicator.left = (-INDICATOR_OFFSET_X);

            NSArray *myImages = [NSArray arrayWithObjects:
                                 [UIImage themeImageNamed:@"icofloat_openbottom_light_v5.png"],
                                 [UIImage themeImageNamed:@"icofloat_offbottom_light_v5.png"],nil];
            
            
            _indicator.animationImages = myImages;
            _indicator.animationDuration = timer + 0.1;
            _indicator.animationRepeatCount = 1;
            [_indicator startAnimating];
            
            //_line.image = [UIImage themeImageNamed:@"icofloat_offline_v5.png"];
            //_line.alpha = 0.2f;
            
        
            NSArray *myImages1 = [NSArray arrayWithObjects:
                                  [UIImage themeImageNamed:@"icofloat_openline_v5.png"],
                                  [UIImage themeImageNamed:@"icofloat_offline_v5.png"],nil];
            
            _line.animationImages = myImages1;
            _line.animationDuration = timer + 0.1;
            _line.animationRepeatCount = 1;
            [_line startAnimating];
        }
        else{
            _indicator.left = (self.frame.size.width - _indicator.image.size.width + (INDICATOR_OFFSET_X));

            NSArray *myImages = [NSArray arrayWithObjects:
                                 [UIImage themeImageNamed:@"icofloat_offbottom_light_v5.png"],
                                 [UIImage themeImageNamed:@"icofloat_openbottom_light_v5.png"],nil];
            
            _indicator.animationImages = myImages;
            _indicator.animationDuration = timer+ 0.1;
            _indicator.animationRepeatCount = 1;
            [_indicator startAnimating];
            
            
            //_line.image = [UIImage themeImageNamed:@"icofloat_openline_v5.png"];
            //_line.alpha = 1.0f;
            
            NSArray *myImages1 = [NSArray arrayWithObjects:
                                  [UIImage themeImageNamed:@"icofloat_offline_v5.png"],
                                  [UIImage themeImageNamed:@"icofloat_openline_v5.png"],nil];
            
            _line.animationImages = myImages1;
            _line.animationDuration = timer + 0.1;
            _line.animationRepeatCount = 1;
            [_line startAnimating];
        }
        
    } completion:^(BOOL finished) {
        _open = !_open;
        [_indicator stopAnimating];
        [_line stopAnimating];
        if(!_open)
        {
            _indicator.image = [UIImage themeImageNamed:@"icofloat_offbottom_v5.png"];
            _line.image = [UIImage themeImageNamed:@"icofloat_offline_v5.png"];
            //_line.alpha = 1.0f;
        }
        else
        {
            _indicator.image = [UIImage themeImageNamed:@"icofloat_openbottom_v5.png"];
            _line.image = [UIImage themeImageNamed:@"icofloat_openline_v5.png"];
        }
        if(_delegate && [_delegate respondsToSelector:@selector(moreActionSwitch:didChanged:)])
            [_delegate moreActionSwitch:self didChanged:_open];
    }];

}

- (void)updateTheme
{
    if(!_open)
    {
        _line.image = [UIImage themeImageNamed:@"icofloat_offline_v5.png"];
        _indicator.image = [UIImage themeImageNamed:@"icofloat_offbottom_v5.png"];
    }
    else
    {
        _line.image = [UIImage themeImageNamed:@"icofloat_openline_v5.png"];
        _indicator.image = [UIImage themeImageNamed:@"icofloat_openbottom_v5.png"];
    }
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
