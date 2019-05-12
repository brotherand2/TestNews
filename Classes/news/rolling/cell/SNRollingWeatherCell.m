//
//  SNRollingWeatherCell.m
//  sohunews
//
//  Created by lhp on 12/5/13.
//  Copyright (c) 2013 Sohu.com. All rights reserved.
//

#import "SNRollingWeatherCell.h"
#import "NSCellLayout.h"
#import "UIImageView+WebCache.h"
#import "UITableViewCell+ConfigureCell.h"
#import "UIFont+Theme.h"
#import "SNUserLocationManager.h"

#define kAirQualityLabelHeight      (34 / 2.f)
#define kAirQualityLabelWidth       (138 / 2.f)
#define kAlignCenterSpace ([[SNDevice sharedInstance] isMoreThan320] ? (14 / 2.f) : 0)

@interface SNRollingWeatherCell () {
    UIView *weatherContentView;
}

@end

@implementation SNRollingWeatherCell

+ (CGFloat)tableView:(UITableView *)tableView
  rowHeightForObject:(id)object {
    SNRollingNewsTableItem *newsItem = object;
    return [newsItem hiddenMoreButton] ? 65 : WEATHER_CELL_HEIGHT;
}

- (id)initWithStyle:(UITableViewCellStyle)style
    reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:style
                    reuseIdentifier:reuseIdentifier]) {
        [self initWeatherContent];
    }
    return self;
}

- (void)initWeatherContent {
    weatherContentView = [[UIView alloc] initWithFrame:CGRectMake(WEATHER_LEFT, 0, kAppScreenWidth - WEATHER_LEFT * 2, WEATHER_CELL_HEIGHT)];
    weatherContentView.backgroundColor = [UIColor clearColor];
    weatherContentView.centerX = kAppScreenWidth / 2;
    [self.contentView addSubview:weatherContentView];
    
    weatherImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0,(WEATHER_CELL_HEIGHT - WEATHER_CELL_IMAGE_WIDTH) / 2.f, WEATHER_CELL_IMAGE_WIDTH, WEATHER_CELL_IMAGE_WIDTH)];
    weatherImageView.backgroundColor = [UIColor clearColor];
    weatherImageView.alpha = themeImageAlphaValue();
    [weatherContentView addSubview:weatherImageView];
    
    curTemperatureLabel = [[UILabel alloc] initWithFrame:CGRectMake(weatherImageView.right + kAlignCenterSpace, 0, WEATHER_TEMPERATURE_WIDTH, WEATHER_CELL_HEIGHT)];
    curTemperatureLabel.textAlignment = NSTextAlignmentCenter;
    curTemperatureLabel.textColor = [UIColor colorFromString:[[SNThemeManager sharedThemeManager] currentThemeValueForKey:kWeatherInfoTextColor]];
    CGFloat fontSize = [[SNDevice sharedInstance] isPlus] ? (130 / 3) : (70 / 2);
    curTemperatureLabel.font = [UIFont systemFontOfSize:fontSize];
    curTemperatureLabel.textColor = [UIColor colorFromString:[[SNThemeManager sharedThemeManager] currentThemeValueForKey:kThemeText4Color]];
    curTemperatureLabel.backgroundColor = [UIColor clearColor];
    [weatherContentView addSubview:curTemperatureLabel];
    
    CGFloat offsetValue = [[SNDevice sharedInstance] isPlus] ? (40 / 3) : ([[SNDevice sharedInstance] isPhone6] ? (20 / 2) : (10 / 2));
    CGFloat widht = kAppScreenWidth - curTemperatureLabel.right - offsetValue - WEATHER_LEFT * 2;
    weatherLabel = [[UILabel alloc] initWithFrame:CGRectMake(curTemperatureLabel.right + kAlignCenterSpace, 18, widht, 15)];
    weatherLabel.font = [[SNDevice sharedInstance] isMoreThan320] ? [UIFont systemFontOfSizeType:UIFontSizeTypeD] : [UIFont systemFontOfSize:28 / 2.f];
    weatherLabel.textAlignment = NSTextAlignmentLeft;
    weatherLabel.textColor = [UIColor colorFromString:[[SNThemeManager sharedThemeManager] currentThemeValueForKey:kThemeText1Color]];
    weatherLabel.backgroundColor = [UIColor clearColor];
    weatherLabel.numberOfLines = 2;
    [weatherContentView addSubview:weatherLabel];
    
    offsetValue = [[SNDevice sharedInstance] isPhone6] ? (23 / 3) : (12 / 2);
    cityLabel = [[UILabel alloc] initWithFrame:CGRectMake(weatherLabel.left, weatherLabel.bottom + offsetValue, weatherLabel.size.width - 138/2.f, weatherLabel.size.height)];
    cityLabel.font = [UIFont systemFontOfSizeType:UIFontSizeTypeB];
    cityLabel.textAlignment = NSTextAlignmentLeft;
    cityLabel.textColor = [UIColor colorFromString:[[SNThemeManager sharedThemeManager] currentThemeValueForKey:kThemeText4Color]];
    cityLabel.backgroundColor = [UIColor clearColor];
    [weatherContentView addSubview:cityLabel];
 
    airQualityLabel = [[UILabel alloc] initWithFrame:CGRectMake(weatherContentView.width - 144 / 2.f, weatherLabel.bottom + offsetValue, kAirQualityLabelWidth, weatherLabel.size.height)];
    airQualityLabel.font = [UIFont systemFontOfSizeType:UIFontSizeTypeB];
    airQualityLabel.textAlignment = NSTextAlignmentCenter;
    airQualityLabel.textColor = [UIColor colorFromString:[[SNThemeManager sharedThemeManager] currentThemeValueForKey:kThemeText5Color]];
    airQualityLabel.backgroundColor = [UIColor clearColor];
    [weatherContentView addSubview:airQualityLabel];
    
    [SNNotificationManager addObserver:self selector:@selector(updateTheme) name:kThemeDidChangeNotification object:nil];
}

- (void)updateContentView {
    [super updateContentView];
    self.item.delegate = self;
    self.item.selector = @selector(openWeather);
    [self updateWeatherContent];
}

- (void)updateWeatherContent {
    [weatherImageView sd_setImageWithURL:[NSURL URLWithString:self.item.news.weatherIoc] placeholderImage:nil];
    weatherImageView.alpha = themeImageAlphaValue();
    
    NSString *weather = [NSString stringWithFormat:@"%@  %@~%@°", self.item.news.weather, self.item.news.tempLow, self.item.news.tempHigh];
    [weatherLabel setText:weather];
    
    if ([self.item.news.liveTemperature length] != 0) {
        curTemperatureLabel.text = [NSString stringWithFormat:@"%@°", self.item.news.liveTemperature];
    }
    CGSize weatherInfoSize = CGSizeZero;
    if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"7.0")) {
        weatherInfoSize = [weather sizeWithAttributes:@{NSFontAttributeName:[UIFont systemFontOfSizeType:UIFontSizeTypeD]}];
    } else {
        weatherInfoSize = [weather sizeWithFont:[UIFont systemFontOfSizeType:UIFontSizeTypeD] forWidth:kAppScreenWidth / 2 lineBreakMode:NSLineBreakByTruncatingTail];
    }

    NSString *cityInfo = [NSString stringWithFormat:@"%@  %@", self.item.news.city, self.item.news.wind];
    [cityLabel setText:cityInfo];
    
    CGFloat space = 18 / 2.f;
        
    //城市
    CGSize cityInfoSize = CGSizeZero;
    if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"7.0")) {
        cityInfoSize = [cityInfo sizeWithAttributes:@{NSFontAttributeName:[UIFont systemFontOfSizeType:UIFontSizeTypeB]}];
    } else {
        cityInfoSize = [cityInfo sizeWithFont:[UIFont systemFontOfSizeType:UIFontSizeTypeB] forWidth:kAppScreenWidth/2 lineBreakMode:NSLineBreakByTruncatingTail];
    }
    
    [cityLabel setFrame:CGRectMake(cityLabel.origin.x, cityLabel.origin.y, cityInfoSize.width, cityLabel.size.height)];
        
    //AIQ
    NSString * airQualityInfo = [NSString stringWithFormat:@"%@ %@",self.item.news.pm25,[self qualityLevelWithPM2_5:self.item.news.pm25]];
    CGSize pm25Size = CGSizeZero;
    if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"7.0")) {
        pm25Size = [airQualityInfo sizeWithAttributes:@{NSFontAttributeName:[UIFont systemFontOfSizeType:UIFontSizeTypeB]}];
    } else {
        pm25Size = [airQualityInfo sizeWithFont:[UIFont systemFontOfSizeType:UIFontSizeTypeB] forWidth:kAppScreenWidth/2 lineBreakMode:NSLineBreakByTruncatingTail];
    }
        
    [airQualityLabel setFrame:CGRectMake(cityLabel.origin.x + cityInfoSize.width + space, airQualityLabel.origin.y, pm25Size.width, airQualityLabel.size.height)];
    
    airQualityLabel.textColor = [UIColor colorFromString:[self colorStringWithPM2_5:self.item.news.pm25]];
    
    [airQualityLabel setText:airQualityInfo];

    if (weatherInfoSize.width > (cityInfoSize.width + space + pm25Size.width)) {
        [self layoutAlignCenterWithWidth:(WEATHER_CELL_IMAGE_WIDTH + kAlignCenterSpace + WEATHER_TEMPERATURE_WIDTH + kAlignCenterSpace + weatherInfoSize.width)];
    } else {
        [self layoutAlignCenterWithWidth:(WEATHER_CELL_IMAGE_WIDTH + kAlignCenterSpace + WEATHER_TEMPERATURE_WIDTH + kAlignCenterSpace + (cityInfoSize.width + space + pm25Size.width))];
    }
}

- (void)layoutAlignCenterWithWidth:(CGFloat)contentWidth {
    CGFloat left = (weatherContentView.width - contentWidth) / 2.f;
    [weatherImageView setFrame:CGRectMake(left, weatherImageView.origin.y, weatherImageView.width, weatherImageView.height)];
    [curTemperatureLabel setFrame:CGRectMake(weatherImageView.right + kAlignCenterSpace, curTemperatureLabel.origin.y, curTemperatureLabel.width, curTemperatureLabel.height)];
    [weatherLabel setFrame:CGRectMake(curTemperatureLabel.right + kAlignCenterSpace, weatherLabel.origin.y, weatherLabel.width, weatherLabel.height)];
    [cityLabel setFrame:CGRectMake(curTemperatureLabel.right + kAlignCenterSpace, cityLabel.origin.y, cityLabel.width, cityLabel.height)];
    
    [airQualityLabel setFrame:CGRectMake(cityLabel.origin.x + cityLabel.width + ([[SNDevice sharedInstance] isMoreThan320] ? 18 /2.f : 8 / 2.f), airQualityLabel.origin.y, airQualityLabel.width, airQualityLabel.height)];
}

- (NSString *)qualityLevelWithPM2_5:(NSString *)pm25 {
    if (pm25.length == 0) {
        return @"";
    }
    NSInteger pm25_integerValue = [pm25 integerValue];
    
    if ((0 <= pm25_integerValue) && (pm25_integerValue <= 50)) {
        return @"空气优";
    } else if ((50 < pm25_integerValue) && (pm25_integerValue <= 100)){
        return @"空气良";
    } else if ((100 < pm25_integerValue) && (pm25_integerValue <= 150)){
        return @"轻度污染";
    } else if ((150 < pm25_integerValue) && (pm25_integerValue <= 200)){
        return @"中度污染";
    } else if ((200 < pm25_integerValue) && (pm25_integerValue <= 300)){
        return @"重度污染";
    } else if (300 < pm25_integerValue){
        return @"严重污染";
    } else {
        return @"";
    }
}

- (NSString *)colorStringWithPM2_5:(NSString *)pm25 {
    if (pm25.length == 0) {
        return @"";
    }
    NSInteger pm25_integerValue = [pm25 integerValue];

    BOOL isNightTheme = [[SNThemeManager sharedThemeManager] isNightTheme];
    
    if ((0 <= pm25_integerValue) && (pm25_integerValue <= 50)) {
        return isNightTheme ? @"#1c3e16" : @"#5ecf4b";
    }
    else if ((50 < pm25_integerValue) && (pm25_integerValue <= 100)){
        return isNightTheme ? @"#2a3c0c" : @"#8dca29";
    }
    else if ((100 < pm25_integerValue) && (pm25_integerValue <= 150)){
        return isNightTheme ? @"#4a380f" : @"#f9bb31";
    }
    else if ((150 < pm25_integerValue) && (pm25_integerValue <= 200)){
        return isNightTheme ? @"#4b220a" : @"#fd7222";
    }
    else if ((200 < pm25_integerValue) && (pm25_integerValue <= 300)){
        return isNightTheme ? @"#470e05" : @"#ee2f10";
    }
    else if (300 < pm25_integerValue){
        return isNightTheme ? @"#862718" : @"#c21e1b";
    }
    else {
        return @"";
    }
}

- (void)updateTheme {
    [super updateTheme];
    cityLabel.textColor = [UIColor colorFromString:[[SNThemeManager sharedThemeManager] currentThemeValueForKey:kThemeText4Color]];
    weatherLabel.textColor = [UIColor colorFromString:[[SNThemeManager sharedThemeManager] currentThemeValueForKey:kThemeText1Color]];
    airQualityLabel.textColor = [UIColor colorFromString:[self colorStringWithPM2_5:self.item.news.pm25]];
    curTemperatureLabel.textColor = [UIColor colorFromString:[[SNThemeManager sharedThemeManager] currentThemeValueForKey:kThemeText4Color]];
    weatherImageView.alpha = themeImageAlphaValue();
    [self setNeedsDisplay];
}

- (void)openWeather {
    [SNUtility shouldUseSpreadAnimation:YES];
    NSMutableDictionary *weatherDic = [NSMutableDictionary dictionary];
    if (item.news.gbcode) {
        [weatherDic setObject:item.news.gbcode forKey:kGbcode];
    }
    if (item.news.city) {
        [weatherDic setObject:item.news.city forKey:kCity];
    }
    if ([[SNUserLocationManager sharedInstance] localChannelId]) {
        [weatherDic setObject:[[SNUserLocationManager sharedInstance] localChannelId] forKey:kChannelId];
    }
    if (item.news.link.length > 0) {
        [SNUtility openProtocolUrl:item.news.link context:weatherDic];
    } else {
        [SNUtility shouldUseSpreadAnimation:NO];
        TTURLAction *urlAction = [[[TTURLAction actionWithURLPath:@"tt://weather"] applyQuery:weatherDic] applyAnimated:YES];
        [[TTNavigator navigator] openURLAction:urlAction];
    }
}

- (void)dealloc {
    [SNNotificationManager removeObserver:self];
    [weatherImageView sd_cancelCurrentImageLoad];
}

@end
