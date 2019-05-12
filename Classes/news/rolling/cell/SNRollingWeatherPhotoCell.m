//
//  SNWeatherPhotoCell.m
//  sohunews
//
//  Created by lhp on 3/13/14.
//  Copyright (c) 2014 Sohu.com. All rights reserved.
//

#import "SNRollingWeatherPhotoCell.h"
#import "SNWebImageView.h"
#import "SNRollingNewsPublicManager.h"
#import "UISwitchCityButton.h"

@interface CityInfoView : UIView {
    UILabel *cityLabel;
    UILabel *dateLabel;
}
- (void)setCityName:(NSString *)nameString
           dateInfo:(NSString *)dateString;
@end

@implementation CityInfoView

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        cityLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 200, 35)];
        cityLabel.backgroundColor = [UIColor clearColor];
        cityLabel.font = [UIFont systemFontOfSize:kThemeFontSizeF];
        cityLabel.textColor = [UIColor whiteColor];
        [self addSubview:cityLabel];
        
        dateLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 35, 100, 10)];
        dateLabel.backgroundColor = [UIColor clearColor];
        dateLabel.textColor = [UIColor whiteColor];
        dateLabel.textAlignment = NSTextAlignmentLeft;
        dateLabel.font = [UIFont systemFontOfSize:kThemeFontSizeA];
        [self addSubview:dateLabel];
    }
    return self;
}

- (void)setCityName:(NSString *)nameString
           dateInfo:(NSString *)dateString {
    cityLabel.text = nameString;
    dateLabel.text = dateString;
    self.accessibilityLabel = [NSString stringWithFormat:@"%@,%@", nameString, dateString];
}

@end


@interface LocalWeatherView : UIView {
    SNWebImageView *weatherImageView;
    UILabel *temperatureLabel;
    UILabel *weatherLabel;
    UIButton *weatherButton;
}

- (void)loadWeatherImageWithUrl:(NSString *)imageUrl;
- (void)weatherButtonAddTarget:(id)target action:(SEL)action forControlEvents:(UIControlEvents)controlEvents;

@end

#define kWeatherImageWidth  (70)
#define kWeatherImageHeight (70)

@implementation LocalWeatherView

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        self.userInteractionEnabled = NO;
        
        weatherImageView = [[SNWebImageView alloc] initWithFrame:CGRectMake(8, 4, kWeatherImageWidth, kWeatherImageHeight)];
        weatherImageView.backgroundColor = [UIColor clearColor];
        [self addSubview:weatherImageView];
        
        temperatureLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 18, 150, 27)];
        temperatureLabel.backgroundColor = [UIColor clearColor];
        temperatureLabel.textColor = [UIColor whiteColor];
        temperatureLabel.font = [UIFont systemFontOfSize:25.0];
        temperatureLabel.textAlignment = NSTextAlignmentLeft;
        temperatureLabel.isAccessibilityElement = NO;
        [self addSubview:temperatureLabel];
        
        weatherLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 200, 14)];
        weatherLabel.backgroundColor = [UIColor clearColor];
        weatherLabel.textColor = [UIColor whiteColor];
        weatherLabel.font = [UIFont systemFontOfSize:11.0];
        weatherLabel.textAlignment = NSTextAlignmentLeft;
        weatherLabel.isAccessibilityElement = NO;
        [self addSubview:weatherLabel];
        
        weatherButton = [UIButton buttonWithType:UIButtonTypeCustom];
        weatherButton.frame = CGRectMake(0, 0, frame.size.width, frame.size.height);
        [self addSubview:weatherButton];
        
        temperatureLabel.left = weatherImageView.right+8;
        weatherLabel.left = weatherImageView.right +8;
        weatherLabel.top = temperatureLabel.bottom + 1;
    }
    return self;
}

- (void)weatherButtonAddTarget:(id)target action:(SEL)action forControlEvents:(UIControlEvents)controlEvents {
    [weatherButton addTarget:target action:action forControlEvents:controlEvents];
}

- (void)setTempHigh:(NSString *)tempHighString tempLow:tempLowString  withWeather:(NSString *)weatherInfo {
    NSString *tempString = [NSString stringWithFormat:@"%@℃~%@℃",tempLowString,tempHighString];
    temperatureLabel.text = tempString;
    weatherLabel.text = weatherInfo;
    weatherButton.accessibilityLabel = [NSString stringWithFormat:@"%@,最高气温%@℃,最低气温%@℃", weatherInfo, tempHighString, tempLowString];
}

- (void)loadWeatherImageWithUrl:(NSString *)imageUrl {
    [weatherImageView loadUrlPath:imageUrl];
}

@end

@interface SNRollingWeatherPhotoCell () {
    UIView *contentView;
    LocalWeatherView *localWeatherView;
    CityInfoView *cityInfoView;
}

@end

#define kWeatherPhotoHeight (410 / 2)
#define kPhotoWidth         (300)
#define kPhotoHeight        (370 / 2)
#define kSwitchCityWidth    (100)

#define kFocusImageRate     (316.f / 640.f)

static CGFloat rowCellHeight = 0.0f;

@implementation SNRollingWeatherPhotoCell

+ (CGFloat)tableView:(UITableView *)tableView
  rowHeightForObject:(id)object {
    if (rowCellHeight == 0.0f) {
        rowCellHeight = roundf(kAppScreenWidth * kFocusImageRate + 7);
    }
    return rowCellHeight;
}

- (id)initWithStyle:(UITableViewCellStyle)style
    reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:style
                    reuseIdentifier:reuseIdentifier]) {
        [self initWeatherPhotoView];
    }
    return self;
}

- (void)initWeatherPhotoView {
    contentView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kAppScreenWidth, kWeatherPhotoHeight)];
    contentView.backgroundColor = [UIColor clearColor];
    contentView.alpha = themeImageAlphaValue();
    [self addSubview:contentView];
    
    photoImageView = [[SNWebImageView alloc] initWithFrame:CGRectMake(0, 0,kAppScreenWidth,kAppScreenWidth * kFocusImageRate)];
    [photoImageView setDefaultImage:[UIImage themeImageNamed:@"default_bg_600_290.png"]];
    [photoImageView setContentMode:UIViewContentModeScaleToFill];
    photoImageView.showFade = YES;
    [contentView addSubview:photoImageView];
    
    cityInfoView = [[CityInfoView alloc] initWithFrame:CGRectMake(14, 0, 150, 50)];
    cityInfoView.center = CGPointMake(90, 30);
    [contentView addSubview:cityInfoView];
    
    localWeatherView = [[LocalWeatherView alloc] initWithFrame:CGRectMake(10, kAppScreenWidth * kFocusImageRate -kWeatherImageHeight - 5, 200, 96)];
    [contentView addSubview:localWeatherView];
    
    UIButton *photoButton = [UIButton buttonWithType:UIButtonTypeCustom];
    photoButton.frame = photoImageView.frame;
    [photoButton addTarget:self action:@selector(openWeather) forControlEvents:UIControlEventTouchUpInside];
    [contentView addSubview:photoButton];
    
    UISwitchCityButton *switchCityButton = [[UISwitchCityButton alloc] initWithFrame:CGRectMake(0, 0, kSwitchCityWidth, 40)];
    switchCityButton.left = kAppScreenWidth - kSwitchCityWidth;
    switchCityButton.accessibilityLabel = @"切换城市";
    [switchCityButton addTarget:self action:@selector(switchCity) forControlEvents:UIControlEventTouchUpInside];
    switchCityButton.tag = 10001;
    [contentView addSubview:switchCityButton];
}

- (void)updateTheme {
    [super updateTheme];
    contentView.alpha = themeImageAlphaValue();
    
    id subview = [contentView viewWithTag:10001];
    if ([subview isKindOfClass:[UISwitchCityButton class]] ) {
        UISwitchCityButton *button = (UISwitchCityButton *)subview;
        [button updateTheme];
    }
}

- (void)openWeather {
    if ([[NSUserDefaults standardUserDefaults] boolForKey:kSpreadAnimationStartKey]) {
        return;
    }
    [[NSUserDefaults standardUserDefaults] setDouble:100.0 forKey:kRememberCellOriginYInScreen];
    [[NSUserDefaults standardUserDefaults] synchronize];
    [SNUtility shouldUseSpreadAnimation:YES];
    [SNUtility shouldAddAnimationOnSpread:NO];
    NSMutableDictionary *weatherDic = [NSMutableDictionary dictionary];
    if (item.news.gbcode) {
        [weatherDic setObject:item.news.gbcode forKey:kGbcode];
    }
    if (item.news.city) {
        [weatherDic setObject:item.news.city forKey:kCity];
    }
    if (item.news.link.length > 0) {
        [SNUtility openProtocolUrl:item.news.link context:weatherDic];
    } else {
        TTURLAction *urlAction = [[[TTURLAction actionWithURLPath:@"tt://weather"] applyQuery:weatherDic] applyAnimated:YES];
        [[TTNavigator navigator] openURLAction:urlAction];
    }
}

- (void)switchCity {
    NSMutableDictionary *cityDic = [NSMutableDictionary dictionary];
    
    if (item.news.city) {
        [cityDic setObject:item.news.city forKey:kCity];
    }

    if (item.news.channelId.length > 0) {
        [cityDic setObject:item.news.channelId forKey:@"channelId"];
    }
    
    TTURLAction *urlAction = [[[TTURLAction actionWithURLPath:@"tt://localChannelList"] applyAnimated:YES] applyQuery:cityDic];
    [[TTNavigator navigator] openURLAction:urlAction];
}

- (void)updateContentView {
    [super updateContentView];
    UIImage *defaultImage = [UIImage themeImageNamed:@"default_bg_600_290.png"];
    [photoImageView setDefaultImage:defaultImage];
    [photoImageView setContentMode:UIViewContentModeScaleToFill];
    [photoImageView setUrlPath:item.news.picUrl];
    
    [localWeatherView setTempHigh:item.news.tempHigh tempLow:item.news.tempLow withWeather:[self weatherDetail]];
    if (nil == item.news.localIoc || [item.news.localIoc isEqualToString:@""]) {
        [localWeatherView loadWeatherImageWithUrl:item.news.weatherIoc];
    } else {
        [localWeatherView loadWeatherImageWithUrl:item.news.localIoc];
    }
    [cityInfoView setCityName:item.news.city dateInfo:item.news.date];
    contentView.alpha = themeImageAlphaValue();
}

- (NSString *)weatherDetail {
    NSMutableString *detail = [NSMutableString stringWithString:self.item.news.weather];
    if (self.item.news.pm25.length > 0) {
        [detail appendFormat:@"    PM2.5"];
    }
    if (self.item.news.quality.length > 0) {
        [detail appendFormat:@"    %@", self.item.news.quality];
    }
    return detail;
}

@end
