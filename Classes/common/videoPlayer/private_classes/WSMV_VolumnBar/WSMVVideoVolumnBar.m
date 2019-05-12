//
//  WSVideoVolumnBar.m
//  WeSee
//
//  Created by handy wang on 9/10/13.
//  Copyright (c) 2013 handy. All rights reserved.
//

#import "WSMVVideoVolumnBar.h"
#import "UIViewAdditions+WSMV.h"
#import "WSMVVideoPlayerView.h"

@interface WSMVVideoVolumnBar()
@property (nonatomic, strong)UIImageView    *backgroundView;
@end

@implementation WSMVVideoVolumnBar

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        self.userInteractionEnabled = YES;
        
        self.backgroundView = [[UIImageView alloc] initWithFrame:CGRectMake((self.width-kVolumnBarWidth)/2.0f,
                                                                             (self.height-kVolumnBarHeight)/2.0f,
                                                                             kVolumnBarWidth,
                                                                             kVolumnBarHeight)];
        self.backgroundView.image = [UIImage themeImageNamed:@"wsmv_volumn_bar_bg.png"];
        [self addSubview:self.backgroundView];
        
        CGFloat _sliderWidth    = self.height-2*5;//5表示slider在top和bottom留出5像素
        CGFloat _sliderHeight   = _sliderWidth;
        self.slider = [[WSMVVideoVolumnSlider alloc] initWithFrame:CGRectMake((self.width-_sliderWidth)/2.0f,
                                                                  (self.height-_sliderHeight)/2.0f,
                                                                  _sliderWidth,
                                                                  _sliderHeight)];
        self.slider.enabled = YES;
        self.slider.transform = CGAffineTransformMakeRotation(-M_PI/2);
        [self addSubview:self.slider];
    }
    return self;
}


@end
