//
//  SNUserPortraitSexSelectBtn.m
//  sohunews
//
//  Created by wang shun on 2017/1/9.
//  Copyright © 2017年 Sohu.com. All rights reserved.
//

#import "SNUserPortraitSexSelectBtn.h"

@implementation SNUserPortraitSexSelectBtn

-(instancetype)initWithFrame:(CGRect)frame WithImage:(NSString *)image{
    if (self = [super initWithFrame:frame]) {
        self.imgUrl = image;
        [self configView];
    }
    return self;
}

-(void)setFrame:(CGRect)frame{
    [super setFrame:frame];
    [_bgImgView setFrame:self.bounds];
    [_btn setFrame:self.bounds];
}

- (void)configView{
    _bgImgView = [[UIImageView alloc] initWithFrame:self.bounds];
    _bgImgView.backgroundColor = [UIColor clearColor];
    _bgImgView.image = [UIImage themeImageNamed:self.imgUrl];
    [self addSubview:_bgImgView];
    
    /*
     [_boy setImage:[UIImage themeImageNamed:@"icofiction_boy_v5.png"] forState:UIControlStateNormal];
     [_boy setImage:[UIImage themeImageNamed:@"icofiction_boypress_v5.png"] forState:UIControlStateHighlighted];
     [_boy setImage:[UIImage themeImageNamed:@"icofiction_boypress_v5.png"] forState:UIControlStateSelected];
     */
    
    _btn = [UIButton buttonWithType:UIButtonTypeCustom];
    _btn.frame = self.bounds;
    [self addSubview:_btn];
    [_btn addTarget:self action:@selector(touchDown:) forControlEvents:UIControlEventTouchDown];
    [_btn addTarget:self action:@selector(touchUp:) forControlEvents:UIControlEventTouchCancel|UIControlEventTouchDragOutside|UIControlEventTouchUpOutside];
    [_btn addTarget:self action:@selector(press:) forControlEvents:UIControlEventTouchUpInside];
}

- (void)touchUp:(UIButton*)btn{
    if (self.selected == NO) {
         NSString* img = [self.imgUrl stringByReplacingOccurrencesOfString:@"press_v5" withString:@"_v5"];
        _bgImgView.image = [UIImage themeImageNamed:img];//@"icofiction_boy_v5.png"];
    }
}
- (void)touchDown:(UIButton*)btn{
    NSString* img = [self.imgUrl stringByReplacingOccurrencesOfString:@"_v5" withString:@"press_v5"];
    _bgImgView.image = [UIImage themeImageNamed:img];//@"icofiction_boypress_v5.png"];
}

- (void)press:(UIButton*)btn{
    if (self.delegate && [self.delegate respondsToSelector:@selector(click:)]) {
        [self.delegate performSelector:@selector(click:) withObject:self];
    }
}

- (void)setSelected:(BOOL)selected{
    _selected = selected;
    if (_selected == YES){
        NSString* img = [self.imgUrl stringByReplacingOccurrencesOfString:@"_v5" withString:@"press_v5"];
        _bgImgView.image = [UIImage themeImageNamed:img];///@"icofiction_boypress_v5.png"];
    }
    else{
        _bgImgView.image = [UIImage themeImageNamed:self.imgUrl];
    }
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
