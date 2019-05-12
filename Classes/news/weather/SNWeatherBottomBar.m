//
//  SNWeatherBottomBar.m
//  sohunews
//
//  Created by yanchen wang on 12-7-18.
//  Copyright (c) 2012年 Sohu.com Inc. All rights reserved.
//

#import "SNWeatherBottomBar.h"
#import "SNWeatherCenter.h"
#import "SNThemeManager.h"
#import "UIColor+ColorUtils.h"
#import "CacheObjects.h"
#import "SNWebImageView.h"


#define kRefreshViewHeight          (20.0)

#define kLabelTopMargin             (39.0 / 2)
#define kIconMargin                 (22.0 / 2)

#define kIconWidth                  (140.0 / 2)
#define kIconHeight                 (90.0 / 2)

#define kWeekDayTextFont            (28.0 / 2)
#define kTempretureTextFont         (26.0 / 2)

@interface SNWeatherBottomBarButton : UIButton {
    SNWebImageView *_weatherIcon;
    UILabel *_weekDay;
    UILabel *_tempreture;
    
    WeatherReport *_weather;
}

@property(nonatomic, strong)WeatherReport *weather;

@end

@implementation SNWeatherBottomBarButton
@synthesize weather = _weather;

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        _weekDay = [[UILabel alloc] initWithFrame:CGRectMake(0, kLabelTopMargin, frame.size.width, kWeekDayTextFont + 1)];
        _weekDay.backgroundColor = [UIColor clearColor];
        _weekDay.font = [UIFont systemFontOfSize:kWeekDayTextFont];
        _weekDay.textAlignment = NSTextAlignmentCenter;
        _weekDay.textColor = [UIColor colorFromString:[[SNThemeManager sharedThemeManager] currentThemeValueForKey:kWeatherWidgetTextColor]];
        [self addSubview:_weekDay];
        
        _weatherIcon = [[SNWebImageView alloc] initWithFrame:CGRectMake((frame.size.width - kIconWidth) / 2,
                                                                     _weekDay.bottom + kIconMargin, 
                                                                     kIconWidth, 
                                                                     kIconHeight)];
        _weatherIcon.backgroundColor = [UIColor clearColor];
        _weatherIcon.contentMode = UIViewContentModeScaleAspectFill;
        _weatherIcon.alpha = themeImageAlphaValue();
        _weatherIcon.defaultImage = [UIImage imageNamed:@"yin370.png"];
        _weatherIcon.showFade = NO;
        _weatherIcon.userInteractionEnabled = NO;
        [self addSubview:_weatherIcon];
        
        _tempreture = [[UILabel alloc] initWithFrame:CGRectMake(0, _weatherIcon.bottom + kIconMargin, frame.size.width, kTempretureTextFont + 1)];
        _tempreture.backgroundColor = [UIColor clearColor];
        _tempreture.font = [UIFont fontWithName:kDigitAndLetterFontFimalyName size:kTempretureTextFont];
        _tempreture.textAlignment = NSTextAlignmentCenter;
        _tempreture.textColor = [UIColor colorFromString:[[SNThemeManager sharedThemeManager] currentThemeValueForKey:kWeatherWidgetTextColor]];
        [self addSubview:_tempreture];
        
        self.showsTouchWhenHighlighted = YES;
    }
    return self;
}

- (void)dealloc {
     //(_weekDay);
     //(_weatherIcon);
     //(_tempreture);
     //(_weather);
}

- (void)setWeather:(WeatherReport *)aWeather {
    if (_weather != aWeather) {
         //(_weather);
        _weather = aWeather;
        if (_weather) {
            _weekDay.text = [SNWeatherCenter weekDayOfWeatherWeatherReport:_weather];
            [_weatherIcon loadUrlPath:_weather.weatherIconUrl];
            NSString *tempStr = @"";
            if ([_weather.tempHigh length] > 0 && [_weather.tempLow length] > 0) {
                tempStr = [NSString stringWithFormat:@"%@%@ ~ %@%@", _weather.tempLow, kTemperatureMark, _weather.tempHigh, kTemperatureMark];
            }
            _tempreture.text = tempStr;
            
            self.accessibilityLabel = [NSString stringWithFormat:@"%@, %@, 最高温度%@%@, 最低温度%@%@",
                                       _weekDay.text,
                                       _weather.weather,
                                       _weather.tempHigh, kTemperatureMark,
                                       _weather.tempLow, kTemperatureMark];
        }
    }
}
@end


//////////////////////////////////////////////////////////////////////////////////////
@interface SNWeatherBottomBar () {
    NSMutableArray *_barButtonItems;
    NSArray *_weathers;
    UIImageView *_bgImageView;
    NSInteger _selectIndex;
}

@property(nonatomic, strong)NSMutableArray *barButtonItems;

@end

@implementation SNWeatherBottomBar

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        self.barButtonItems = [NSMutableArray arrayWithCapacity:3];
        
        _bgImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, frame.size.width, frame.size.height)];
        _bgImageView.backgroundColor = [UIColor clearColor];
        _bgImageView.contentMode = UIViewContentModeScaleAspectFill;
        [self addSubview:_bgImageView];
        
        _bgImageView.image = [UIImage imageNamed:@"weather_bg_bottombar.png"];
        
        CGFloat x = 0;
        CGFloat y = 0;//为天气h5外链入口腾出空间的话可改为-15
        CGFloat btnWidth = frame.size.width / 3;
        CGFloat btnHeight = frame.size.height + y;
        SNWeatherBottomBarButton *btn1 = [[SNWeatherBottomBarButton alloc] initWithFrame:CGRectMake(x, y, btnWidth, btnHeight)];
        btn1.tag = 0;
        btn1.accessibilityLabel = @"今天天气";
        [btn1 addTarget:self action:@selector(btnSelected:) forControlEvents:UIControlEventTouchUpInside];
        [btn1 setBackgroundColor:[UIColor clearColor]];
        [self addSubview:btn1];
        [_barButtonItems addObject:btn1];
        x += btnWidth;
        
        SNWeatherBottomBarButton *btn2 = [[SNWeatherBottomBarButton alloc] initWithFrame:CGRectMake(x, y, btnWidth, btnHeight)];
        btn2.tag = 1;
        btn2.accessibilityLabel = @"明天天气";
        [btn2 addTarget:self action:@selector(btnSelected:) forControlEvents:UIControlEventTouchUpInside];
        [btn2 setBackgroundColor:[UIColor clearColor]];
        [self addSubview:btn2];
        [_barButtonItems addObject:btn2];
        x += btnWidth;
        
        SNWeatherBottomBarButton *btn3 = [[SNWeatherBottomBarButton alloc] initWithFrame:CGRectMake(x, y, btnWidth, btnHeight)];
        btn3.tag = 2;
        btn3.accessibilityLabel = @"后天天气";
        [btn3 addTarget:self action:@selector(btnSelected:) forControlEvents:UIControlEventTouchUpInside];
        [btn3 setBackgroundColor:[UIColor clearColor]];
        [self addSubview:btn3];
        [_barButtonItems addObject:btn3];
        
       //5.2.0 暂时不做，下版本有可能上，暂时注释掉 ---黄震
//        UIButton * h5WeatherBtn = [UIButton buttonWithType:UIButtonTypeCustom];
//        h5WeatherBtn.frame = CGRectMake(0, btnHeight , frame.size.width, 15);
//        [h5WeatherBtn setTitle:@"查看更多天气报告 > " forState:UIControlStateNormal];
//        h5WeatherBtn.titleLabel.font = [UIFont systemFontOfSize:12];
//        [h5WeatherBtn addTarget:self action:@selector(goH5Weather) forControlEvents:UIControlEventTouchUpInside];
//        h5WeatherBtn.showsTouchWhenHighlighted = YES;
//        [self addSubview:h5WeatherBtn];
    }
    return self;
}

- (void)goH5Weather{
    //5.2 跳H5天气外链
}

- (void)dealloc {
//     //(_refreshView);
     //(_bgImageView);
     //(_barButtonItems);
     //(_weathers);
}

- (void)setWeathers:(NSArray *)weathers {
    if (_weathers != weathers) {
         //(_weathers);
        _weathers = weathers;
        
        if (_weathers && _weathers.count > 0) {
            for (int i = 0; i < _weathers.count; ++i) {
                if (i >= _barButtonItems.count) {
                    break;
                }
                SNWeatherBottomBarButton *btn = [_barButtonItems objectAtIndex:i];
                WeatherReport *report = [_weathers objectAtIndex:i];
                btn.weather = report;
            }
        }
    }
}

- (void)btnSelected:(id)sender {
    NSInteger index = ((UIButton *)sender).tag;
    if (_selectIndex == index) {
        return;
    }
    
    _selectIndex = index;
    if ([_delegate respondsToSelector:@selector(barSelectionChangedTo:)]) {
        [_delegate barSelectionChangedTo:index];
    }
    SNDebugLog(@"btnSelected %d", index);
}

@end
