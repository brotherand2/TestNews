//
//  SNNavigationBar.m
//  sohunews
//
//  Created by lhp on 9/27/13.
//  Copyright (c) 2013 Sohu.com. All rights reserved.
//

#import "SNNavigationBar.h"

@interface SNNavigationBar ()
@property (nonatomic, weak) UIToolbar *bgView;
@end

@implementation SNNavigationBar

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        UIToolbar *bgView = [[UIToolbar alloc] initWithFrame:CGRectMake(0, 0, frame.size.width, frame.size.height)];
        self.bgView = bgView;
        [self addSubview:bgView];
        _coverView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, frame.size.width, frame.size.height)];
        [self addSubview:_coverView];
        [self setCoverViewBackground];
        
        [SNNotificationManager addObserver:self selector:@selector(updateTheme) name:kThemeDidChangeNotification object:nil];
    }
    return self;
}

- (void)hideBlur {
    self.bgView.translucent = NO;
}


- (void)updateTheme
{
    [self setCoverViewBackground];
}
- (void)setCoverViewBackground {
    
//    if (([[[UIDevice currentDevice] systemVersion] floatValue] < 7.0)) {
//        //BOOL isNight = [[[SNThemeManager sharedThemeManager] currentTheme] isEqualToString:kThemeDefault] ? NO : YES;
//        //_coverView.backgroundColor = isNight?RGBCOLOR(62,62,62):RGBCOLOR(255,255,255);
//        _coverView.backgroundColor = [[SNThemeManager sharedThemeManager] currentThemeColorForKey:kThemeBg4Color];
//    }else {
        float coverAlpha = [[SNThemeManager sharedThemeManager] isNightTheme]? 0.85f:0.0f;
        //效果渐变调整 wangyy
//        _coverView.backgroundColor = [UIColor blackColor];
//        _coverView.alpha = coverAlpha;
        _coverView.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:coverAlpha];
        _coverView.opaque = NO;
    //}
}
- (void)dealloc
{
    [SNNotificationManager removeObserver:self];
     //(_coverView);
}

@end
