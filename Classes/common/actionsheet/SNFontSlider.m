//
//  SNFontSlider.m
//  sohunews
//
//  Created by lhp on 9/29/13.
//  Copyright (c) 2013 Sohu.com. All rights reserved.
//

#import "SNFontSlider.h"

@interface SNFontSlider ()

@end

@implementation SNFontSlider

- (id)initWithFrame:(CGRect)frame setterCnt:(int)count
{
    self = [super initWithFrame:frame];
    if (self) {        
        fontIndex = -1;
        setterCnt = count;
        self.minimumTrackTintColor = [UIColor clearColor];
        self.maximumTrackTintColor = [UIColor clearColor];
        self.minimumValue = 0;
        self.maximumValue = 60;
        [self addTarget:self action:@selector(changeSliderValue) forControlEvents:UIControlEventValueChanged];
        [self addTarget:self action:@selector(changeSliderIndex) forControlEvents:UIControlEventTouchUpInside];
        
        UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self
                                                                                     action:@selector(tapGestureAction:)];
        [self addGestureRecognizer:tapGesture];
        
        //第一次启动，获取云端字体大小
        [SNNotificationManager addObserver:self
                                  selector:@selector(setSliderWithIndex) name:kFontModeChangeNotification object:nil];
    }
    return self;
}

- (void)setSliderWithIndex{
    NSString *savedFontClass = [SNUtility getNewsFontSizeClass];
    
    if ([savedFontClass isEqualToString:kWordMoreBig])
    {
        [self changeSliderWithIndex:3 andNotify:NO];
    }
    else if ([savedFontClass isEqualToString:kWordBig])
    {
        [self changeSliderWithIndex:2 andNotify:NO];
    }
    else if ([savedFontClass isEqualToString:kWordMiddle])
    {
        [self changeSliderWithIndex:1 andNotify:NO];
    }
    else if ([savedFontClass isEqualToString:kWordSmall] || [savedFontClass isEqualToString:kWordSmall1]){
        [self changeSliderWithIndex:0 andNotify:NO];
    }
}

- (void)tapGestureAction:(UITapGestureRecognizer *) tapGesture {
    
    CGPoint tapPoint = [tapGesture locationInView:self];
    int sliderIndex = 0;
    if (self.frame.size.width > 0) {
        sliderIndex = tapPoint.x / (self.frame.size.width/setterCnt);
    }
    [self changeSliderWithIndex:sliderIndex];
}

- (void)changeSliderWithIndex:(int)index
{
    [self changeSliderWithIndex:index andNotify:YES];
}

- (void)changeSliderWithIndex:(int)index andNotify:(BOOL)notify {
    
    [self setValue:(self.maximumValue / (setterCnt-1))*index animated:YES];

    if (fontIndex == index) {
        return;
    } else {
        fontIndex = index;
        int fontSize = fontIndex + 2;
        [self changeThumbImageWithIndex:fontIndex];
        
        [self saveFontSize:[NSNumber numberWithInt:fontSize]];
    }
}

- (void)saveFontSize:(NSNumber *)fontSize
{
    [SNUtility setNewsFontSize:[fontSize intValue]];
}

- (void)changeThumbImageWithIndex:(int) index{
    if (self.sliderDelegate && [self.sliderDelegate respondsToSelector:@selector(changeFontSliderIndex:)]) {
        [self.sliderDelegate changeFontSliderIndex:index];
    }
    [self setThumbImage:[UIImage imageNamed:@"icofloat_handle_v5.png"] forState:UIControlStateNormal];
}

- (int)getSliderIndex {
    int sliderValue = self.value;
    int sliderIndex = 0;
    sliderIndex = sliderValue / (self.maximumValue/setterCnt);
    sliderIndex = MIN(sliderIndex, (setterCnt - 1));
    return sliderIndex;
}

- (void)changeSliderValue {
    [self changeThumbImageWithIndex:[self getSliderIndex]];
}

- (void)changeSliderIndex {
    [self changeSliderWithIndex:[self getSliderIndex]];
}

- (void)dealloc{
    [SNNotificationManager removeObserver:self name:kFontModeChangeNotification object:nil];
}

- (void)updateTheme{
    [self setThumbImage:[UIImage imageNamed:@"icofloat_handle_v5.png"] forState:UIControlStateNormal];
}

@end
