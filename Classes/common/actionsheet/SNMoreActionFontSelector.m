//
//  SNMoreActionFontSelector.m
//  sohunews
//
//  Created by weibin cheng on 14-10-21.
//  Copyright (c) 2014年 Sohu.com. All rights reserved.
//

#import "SNMoreActionFontSelector.h"
#import "SNThemeManager.h"
#import "SNConsts.h"


//static const CGFloat kFontSelectorButtonWidth = 25;
//static const CGFloat kFontSelectorButtonInterval = 30;

@implementation SNMoreActionFontSelector

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        //CGFloat starx = 0;
        CGSize largeSize;
        CGSize normalSize;
        CGSize smallSize;
        _largeButton = [UIButton buttonWithType:UIButtonTypeCustom];
        //_largeButton.frame = CGRectMake(starx, 0, kFontSelectorButtonWidth, frame.size.height);
        _largeButton.titleLabel.font = [UIFont systemFontOfSize:kThemeFontSizeF];
        [_largeButton setTitle:@"大" forState:UIControlStateNormal];
        [_largeButton setTitleColor:[[SNThemeManager sharedThemeManager] currentThemeColorForKey:kThemeText1Color]forState:UIControlStateNormal];
        //[_largeButton setTitleColor:[[SNThemeManager sharedThemeManager] currentThemeColorForKey:kThemeRed1Color]forState:UIControlStateHighlighted];
        _largeButton.backgroundColor = [UIColor clearColor];
        [_largeButton addTarget:self action:@selector(onClickButton:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:_largeButton];
        largeSize = [_largeButton.titleLabel.text sizeWithFont:_largeButton.titleLabel.font];
        
        
        //starx += kFontSelectorButtonWidth + kFontSelectorButtonInterval;
        _normalButton = [UIButton buttonWithType:UIButtonTypeCustom];
        //_normalButton.frame = CGRectMake(starx, 0, kFontSelectorButtonWidth, frame.size.height);
        _normalButton.titleLabel.font = [UIFont systemFontOfSize:kThemeFontSizeE];
        [_normalButton setTitle:@"中" forState:UIControlStateNormal];
        [_normalButton setTitleColor:[[SNThemeManager sharedThemeManager] currentThemeColorForKey:kThemeText1Color]forState:UIControlStateNormal];
        //[_normalButton setTitleColor:[[SNThemeManager sharedThemeManager] currentThemeColorForKey:kThemeRed1Color]forState:UIControlStateHighlighted];
        _normalButton.backgroundColor = [UIColor clearColor];
        [_normalButton addTarget:self action:@selector(onClickButton:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:_normalButton];
        normalSize = [_normalButton.titleLabel.text sizeWithFont:_normalButton.titleLabel.font];
        
        //starx += kFontSelectorButtonWidth + kFontSelectorButtonInterval;
        _smallButton = [UIButton buttonWithType:UIButtonTypeCustom];
        //_smallButton.frame = CGRectMake(starx, 0, kFontSelectorButtonWidth, frame.size.height);
        _smallButton.titleLabel.font = [UIFont systemFontOfSize:kThemeFontSizeD];
        [_smallButton setTitle:@"小" forState:UIControlStateNormal];
        [_smallButton setTitleColor:[[SNThemeManager sharedThemeManager] currentThemeColorForKey:kThemeText1Color]forState:UIControlStateNormal];
        //[_smallButton setTitleColor:[[SNThemeManager sharedThemeManager] currentThemeColorForKey:kThemeRed1Color]forState:UIControlStateHighlighted];
        _smallButton.backgroundColor = [UIColor clearColor];
        [_smallButton addTarget:self action:@selector(onClickButton:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:_smallButton];
        
        smallSize = [_smallButton.titleLabel.text sizeWithFont:_smallButton.titleLabel.font];
        
        //lijian 2014.12.16 自动完美平均计算大中小三个字的排列位置
        NSInteger offsetX = (self.frame.size.width - (largeSize.width + normalSize.width + smallSize.width))/2;
        _largeButton.frame = CGRectMake(0,
                                        (self.frame.size.height - largeSize.height)/2,
                                        largeSize.width,
                                        largeSize.height);
        //_largeButton.backgroundColor = [UIColor redColor];
        //_largeButton.titleLabel.backgroundColor = [UIColor yellowColor];
        
        _normalButton.frame = CGRectMake(_largeButton.frame.origin.x + _largeButton.frame.size.width + offsetX,
                                         (_largeButton.bottom - normalSize.height - 2),
                                         normalSize.width,
                                         normalSize.height);
        //_normalButton.backgroundColor = [UIColor redColor];
        //_normalButton.titleLabel.backgroundColor = [UIColor yellowColor];
        
        _smallButton.frame = CGRectMake(_normalButton.frame.origin.x + _normalButton.frame.size.width + offsetX,
                                        (_largeButton.bottom - smallSize.height - 2),
                                        smallSize.width,
                                        smallSize.height);
        //_smallButton.backgroundColor = [UIColor redColor];
        //_smallButton.titleLabel.backgroundColor = [UIColor yellowColor];
        
        NSString *savedFontClass = [SNUtility getNewsFontSizeClass];
        [self changeSelectorWithFontString:savedFontClass andNotify:NO];
    }
    return self;
}

- (void)dealloc
{
     //(_largeButton);
     //(_normalButton);
     //(_smallButton);
}

- (void)onClickButton:(id)sender
{
    UIButton* button = (UIButton*)sender;
    NSString *savedFontClass = [SNUtility getNewsFontSizeClass];
    if(button == _largeButton)
    {
        if(![savedFontClass isEqualToString:kWordMoreBig])
        {
            [self changeSelectorWithFontString:kWordMoreBig andNotify:YES];

            [SNUtility sendSettingModeType:SNUserSettingFontMode mode:@"0"];
        }
    }
    else if(button == _normalButton)
    {
        if(![savedFontClass isEqualToString:kWordBig])
        {
            [self changeSelectorWithFontString:kWordBig andNotify:YES];

            [SNUtility sendSettingModeType:SNUserSettingFontMode mode:@"1"];
        }
    }
    else if(button == _smallButton)
    {
        if(![savedFontClass isEqualToString:kWordMiddle])
        {
            [self changeSelectorWithFontString:kWordMiddle andNotify:YES];

            [SNUtility sendSettingModeType:SNUserSettingFontMode mode:@"2"];
        }
    }
}

- (void)changeSelectorWithFontString:(NSString*)font andNotify:(BOOL)notify
{
    if([font isEqualToString:kWordMoreBig])
    {
        [_largeButton setTitleColor:[[SNThemeManager sharedThemeManager] currentThemeColorForKey:kThemeRed1Color]forState:UIControlStateNormal];
        [_normalButton setTitleColor:[[SNThemeManager sharedThemeManager] currentThemeColorForKey:kThemeText1Color]forState:UIControlStateNormal];
        [_smallButton setTitleColor:[[SNThemeManager sharedThemeManager] currentThemeColorForKey:kThemeText1Color]forState:UIControlStateNormal];
    }
    else if([font isEqualToString:kWordBig])
    {
        [_largeButton setTitleColor:[[SNThemeManager sharedThemeManager] currentThemeColorForKey:kThemeText1Color]forState:UIControlStateNormal];
        [_normalButton setTitleColor:[[SNThemeManager sharedThemeManager] currentThemeColorForKey:kThemeRed1Color]forState:UIControlStateNormal];
        [_smallButton setTitleColor:[[SNThemeManager sharedThemeManager] currentThemeColorForKey:kThemeText1Color]forState:UIControlStateNormal];
    }
    else if([font isEqualToString:kWordMiddle] || [font isEqualToString:kWordSmall])
    {
        [_largeButton setTitleColor:[[SNThemeManager sharedThemeManager] currentThemeColorForKey:kThemeText1Color]forState:UIControlStateNormal];
        [_normalButton setTitleColor:[[SNThemeManager sharedThemeManager] currentThemeColorForKey:kThemeText1Color]forState:UIControlStateNormal];
        [_smallButton setTitleColor:[[SNThemeManager sharedThemeManager] currentThemeColorForKey:kThemeRed1Color]forState:UIControlStateNormal];
    }
    
    if(notify)
    {
        NSString* fontSize = font;
        if([font isEqualToString:kWordSmall])
            fontSize = kWordMiddle;
        [self saveFontSize:fontSize];
    }
}

- (void)saveFontSize:(NSString *)fontSize
{
    [[NSUserDefaults standardUserDefaults] setObject:fontSize
                                              forKey:kNewsFontClass];
    [[NSUserDefaults standardUserDefaults] synchronize];
    [SNNotificationManager postNotificationName:kFontModeChangeNotification object:nil];
}

- (void)updateTheme
{
    NSString *savedFontClass = [SNUtility getNewsFontSizeClass];
    [self changeSelectorWithFontString:savedFontClass andNotify:NO];
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
