//
//  SNSkinManager.m
//  sohunews
//
//  Created by Xiang Wei Jia on 2/12/15.
//  Copyright (c) 2015 Sohu.com. All rights reserved.
//

#import "SNSkinManager.h"

#define kSkinTypeKey @"SkinModelTypeValueKey"

@interface SNSkinManager()

@property (nonatomic, strong) NSArray *colors;
@property (nonatomic, strong) NSArray *fontSize;
@property (nonatomic) SkinType skin;
@property (nonatomic) int fontIndex;

@end

@implementation SNSkinManager

- (instancetype) init
{
    self = [super init];
    
    _colors = [[NSArray alloc] initWithObjects:[NSMutableArray new], [NSMutableArray new],nil];
    _fontSize = [[NSArray alloc] initWithObjects:[NSMutableArray new], [NSMutableArray new],nil];
    
    // 如果之前没有存过皮肤，会返回0，那就是默认的日间的皮肤
    //_skin = (SkinType)[[NSUserDefaults standardUserDefaults] integerForKey:kSkinTypeKey];
    
    _skin = ([[SNThemeManager sharedThemeManager] isNightTheme] ? SkinNight : SkinDay);
    
    NSMutableArray *dayColor = _colors[SkinDay];
    
    // 文字颜色
    [dayColor addObject:[UIColor colorFromString:@"#000000"]];
    [dayColor addObject:[UIColor colorFromString:@"#c8c8c8"]];
    [dayColor addObject:[UIColor colorFromString:@"#454545"]];
    [dayColor addObject:[UIColor colorFromString:@"#929292"]];
    [dayColor addObject:[UIColor colorFromString:@"#e2e2e2"]];
    [dayColor addObject:[UIColor colorFromString:@"#929292"]];
    [dayColor addObject:[UIColor colorFromString:@"#e2e2e2"]];
    [dayColor addObject:[UIColor colorFromString:@"#ffffff"]];
    [dayColor addObject:[UIColor colorFromString:@"#696969"]];
    
    // 分割线
    [dayColor addObject:[UIColor colorFromString:@"#dadada"]];
    [dayColor addObject:[UIColor colorFromString:@"#f1f1f1"]];
    [dayColor addObject:[UIColor colorFromString:@"#f9f9f9"]];
    [dayColor addObject:[UIColor colorFromString:@"#ffffff"]];
    
    // 彩色
    [dayColor addObject:[UIColor colorFromString:@"#ee2f10"]];
    [dayColor addObject:[UIColor colorFromString:@"#f9cfcb"]];
    [dayColor addObject:[UIColor colorFromString:@"#3d5699"]];
    [dayColor addObject:[UIColor colorFromString:@"#59d141"]];
    [dayColor addObject:[UIColor colorFromString:@"#fdd536"]];

    // icon
    [dayColor addObject:[UIColor colorFromString:@"#b1b1b1"]];
    [dayColor addObject:[UIColor colorFromString:@"#dadata"]];

    NSMutableArray *nightColor = _colors[SkinNight];
    
    // 文字颜色
    [nightColor addObject:[UIColor colorFromString:@"#4e4e4e"]];
    [nightColor addObject:[UIColor colorFromString:@"#363636"]];
    [nightColor addObject:[UIColor colorFromString:@"#4e4e4e"]];
    [nightColor addObject:[UIColor colorFromString:@"#5c5c5c"]];
    [nightColor addObject:[UIColor colorFromString:@"#252525"]];
    [nightColor addObject:[UIColor colorFromString:@"#343434"]];
    [nightColor addObject:[UIColor colorFromString:@"#252525"]];
    [nightColor addObject:[UIColor colorFromString:@"#5e5e5e"]];
    [nightColor addObject:[UIColor colorFromString:@"#343434"]];
    
    // 分割线
    [nightColor addObject:[UIColor colorFromString:@"#343434"]];
    [nightColor addObject:[UIColor colorFromString:@"#1a1a1a"]];
    [nightColor addObject:[UIColor colorFromString:@"#1f1f1f"]];
    [nightColor addObject:[UIColor colorFromString:@"#1f1f1f"]];
    
    // 彩色
    [nightColor addObject:[UIColor colorFromString:@"#6e2a2a"]];
    [nightColor addObject:[UIColor colorFromString:@"#432a2a"]];
    [nightColor addObject:[UIColor colorFromString:@"#282f43"]];
    [nightColor addObject:[UIColor colorFromString:@"#35662b"]];
    [nightColor addObject:[UIColor colorFromString:@"#645414"]];
    
    // icon
    [nightColor addObject:[UIColor colorFromString:@"#4e4e4e"]];
    [nightColor addObject:[UIColor colorFromString:@"#343434"]];
    
    // 640宽的手机
    NSMutableArray *font640 = _fontSize[0];
    
    [font640 addObject:@(18 / 2)];
    [font640 addObject:@(22 / 2)];
    [font640 addObject:@(26 / 2)];
    [font640 addObject:@(32 / 2)];
    [font640 addObject:@(36 / 2)];
    [font640 addObject:@(44 / 2)];
    [font640 addObject:@(28 / 2)];
    [font640 addObject:@(13)];
    
    // 720及以上宽的手机
    NSMutableArray *font720 = _fontSize[1];

    [font720 addObject:@(20)];
    [font720 addObject:@(35 / 3)];
    [font720 addObject:@(48 / 3)];
    [font720 addObject:@(50 / 3)];
    [font720 addObject:@(55 / 3)];
    [font720 addObject:@(72 / 3)];
    [font720 addObject:@(42 / 3)];
    [font720 addObject:@(13)];
    
    float width = [UIScreen mainScreen].bounds.size.width;

    if (320 == width || 375 == width) {
        _fontIndex = 0;
    }
    else {
        _fontIndex = 1;
    }
    
    return self;
}


- (void) setSkin:(SkinType)skin
{
    _skin = skin;
    [[NSUserDefaults standardUserDefaults] setInteger:skin forKey:kSkinTypeKey];
}

-(float) skinFont:(SkinManagerFontSize)size
{
    NSNumber *f = (_fontSize[_fontIndex])[size];
    
    return f.floatValue;
}

-(UIColor *) skinColor:(SkinManagerColors)color
{
    return (_colors[_skin])[color];
}

+(SkinType) skinType
{
    return [SNSkinManager skinInstance].skin;
}

+(void) setSkinType:(SkinType)type
{
    [SNSkinManager skinInstance].skin = type;
}

+(float) skinAlpha:(SkinAlpha)alpha
{
    if ([SNSkinManager skinType] == SkinDay) {
        return 1;
    }
    
    switch (alpha) {
        case SkinAlpha5:
            return 0.5f;
        case SkinAlpha7:
            return 0.7f;
    }
}

+(SNSkinManager *) skinInstance
{
    static SNSkinManager *instance;
    static dispatch_once_t dispatch;
    
    dispatch_once(&dispatch, ^(){
        instance = [[SNSkinManager alloc] init];
    });
    
    return instance;
}

+(float) fontSize:(SkinManagerFontSize)size
{
    return [[SNSkinManager skinInstance] skinFont:size];
}

+(UIFont*) font:(SkinManagerFontSize)size
{
    return [UIFont systemFontOfSize:[[SNSkinManager skinInstance] skinFont:size]];
}

+(UIFont*) fontBold:(SkinManagerFontSize)size
{
    return [UIFont boldSystemFontOfSize:[[SNSkinManager skinInstance] skinFont:size]];
}

+(UIColor *) color:(SkinManagerColors)color
{
    return [[SNSkinManager skinInstance] skinColor:color];
}

- (void)updateCurrentTheme {
    _skin = ([[SNThemeManager sharedThemeManager] isNightTheme] ? SkinNight : SkinDay);
}

@end
