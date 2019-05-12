//
//  SNWeatherDetailView.m
//  sohunews
//
//  Created by yanchen wang on 12-7-18.
//  Copyright (c) 2012年 Sohu.com Inc. All rights reserved.
//

#import "SNWeatherDetailView.h"
#import "SNWeatherCenter.h"
#import "UIColor+ColorUtils.h"
#import "CacheObjects.h"

#define kBottomBarHeight                (268.0 / 2)
#define kDateInfoTextFont               (28.0 / 2)
#define kDateInfoTopMargin              (10.0 / 2)

#define kWeatherIconTopMargin           (50.0 / 2)
#define kWeatherIconWidth               (370.0 / 2)
#define kWeatherIconHeight              (230.0 / 2)

#define kTempLabelTopSpacing            (24.0 / 2)
#define kTempLabelTextFont              (46.0 / 2)

#define kWeatherInfoLabelTextFont       (25.0 / 2)
#define kWeatherInfoLabelLeftMargin     (34.0 / 2)
#define kWeatherInfoLabelTopMargin      (12.0 / 2)

@implementation SNWeatherDetailView
@synthesize delegate = _delegate;
@synthesize cityGBcode = _cityGBcode;
@synthesize weathers = _weathers;
@synthesize detailButton = _detailButton;
@synthesize isBarHide = _isBarHide;

CGFloat fkLabelFrame(UILabel *label, CGFloat viewTop) {
    label.size = CGSizeMake(label.superview.width, label.font.lineHeight);
    [label sizeToFit];
    label.top = viewTop;
    return label.bottom;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        _contentView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, frame.size.width, frame.size.height)];
        [self addSubview:_contentView];
        
        _dateInfoLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 44 + kDateInfoTopMargin, frame.size.width, kDateInfoTextFont + 1)];
        _dateInfoLabel.backgroundColor = [UIColor clearColor];
        _dateInfoLabel.textAlignment = NSTextAlignmentCenter;
        _dateInfoLabel.font = [UIFont systemFontOfSize:kDateInfoTextFont];
        _dateInfoLabel.textColor = [UIColor colorFromString:[[SNThemeManager sharedThemeManager] currentThemeValueForKey:kWeatherWidgetTextColor]];
        [_contentView addSubview:_dateInfoLabel];
        
        _weatherIconView = [[SNWebImageView alloc] initWithFrame:CGRectMake((frame.size.width - kWeatherIconWidth) / 2, 44 + kWeatherIconTopMargin,
                                                                         kWeatherIconWidth, kWeatherIconHeight)];
        _weatherIconView.backgroundColor = [UIColor clearColor];
        _weatherIconView.contentMode = UIViewContentModeScaleAspectFill;
        _weatherIconView.alpha = themeImageAlphaValue();
        _weatherIconView.defaultImage = [UIImage imageNamed:@"yin370.png"];
        _weatherIconView.showFade = NO;
        _weatherIconView.userInteractionEnabled = NO;
        [_contentView addSubview:_weatherIconView];
        
        _tempretureLabel = [[UILabel alloc] initWithFrame:CGRectMake(kWeatherInfoLabelLeftMargin, _weatherIconView.bottom + kTempLabelTopSpacing, 
                                                                     frame.size.width - kWeatherInfoLabelLeftMargin * 2, kTempLabelTextFont + 1)];
        _tempretureLabel.backgroundColor = [UIColor clearColor];
        _tempretureLabel.textAlignment = NSTextAlignmentLeft;
        _tempretureLabel.font = [UIFont fontWithName:kDigitAndLetterFontFimalyName size:kTempLabelTextFont];
        _tempretureLabel.textColor = [UIColor colorFromString:[[SNThemeManager sharedThemeManager] currentThemeValueForKey:kWeatherWidgetTextColor]];
        [_contentView addSubview:_tempretureLabel];
        
        self.detailButton = [UIButton buttonWithType:UIButtonTypeCustom];
        self.detailButton.frame = CGRectMake(150, _tempretureLabel.top, 50, kTempLabelTextFont + 1);
        [self.detailButton setImage:[UIImage themeImageNamed:@"icoweath_in.png"] forState:UIControlStateNormal];
        [self.detailButton setImage:[UIImage themeImageNamed:@"icoweath_inpress.png"] forState:UIControlStateHighlighted];
        UIColor *color = [[SNThemeManager sharedThemeManager] currentThemeColorForKey:kWeatherWidgetTextColor];
        [self.detailButton setTitleColor:color forState:UIControlStateNormal];
        self.detailButton.titleLabel.font = [UIFont systemFontOfSize:kThemeFontSizeC];
        self.detailButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
        [self.detailButton setImageEdgeInsets:UIEdgeInsetsMake(0, self.detailButton.width - self.detailButton.imageView.size.width, 0, 0)];
        [self.detailButton setTitleEdgeInsets:UIEdgeInsetsMake(0, -3, 0, 0)];
        [self.detailButton addTarget:self action:@selector(showDetailWeather) forControlEvents:UIControlEventTouchUpInside];
        self.detailButton.hidden = YES;
        [_contentView addSubview:self.detailButton];
        
        _weatherInfoLabel = [[UILabel alloc] initWithFrame:CGRectMake(kWeatherInfoLabelLeftMargin, _tempretureLabel.bottom + kWeatherInfoLabelTopMargin, 
                                                                      _tempretureLabel.width, kWeatherInfoLabelTextFont + 1)];
        _weatherInfoLabel.backgroundColor = [UIColor clearColor];
        _weatherInfoLabel.textAlignment = NSTextAlignmentLeft;
        _weatherInfoLabel.font = [UIFont systemFontOfSize:kWeatherInfoLabelTextFont];
        _weatherInfoLabel.textColor = [UIColor colorFromString:[[SNThemeManager sharedThemeManager] currentThemeValueForKey:kWeatherWidgetTextColor]];
        [_contentView addSubview:_weatherInfoLabel];
        
        _weatherItemsScrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(kWeatherInfoLabelLeftMargin, _weatherInfoLabel.bottom + kWeatherInfoLabelTopMargin, 
                                                                                 _tempretureLabel.width, 
                                                                                 frame.size.height - kBottomBarHeight - _weatherInfoLabel.bottom - kWeatherInfoLabelTopMargin - 20 - 44)];
        if (frame.size.height == kIPHONE_6_HEIGHT) {
            _weatherItemsScrollView.frame = CGRectMake(kWeatherInfoLabelLeftMargin, _weatherInfoLabel.bottom + kWeatherInfoLabelTopMargin,
                                                       _tempretureLabel.width,
                                                       frame.size.height - kBottomBarHeight - _weatherInfoLabel.bottom - kWeatherInfoLabelTopMargin - 20 - 44 - 11);
        }
        _weatherItemsScrollView.backgroundColor = [UIColor clearColor];
        _weatherItemsScrollView.showsVerticalScrollIndicator = NO;
        _weatherItemsScrollView.showsHorizontalScrollIndicator = NO;
        _weatherItemsScrollView.bounces = YES;
        [_contentView addSubview:_weatherItemsScrollView];
        
        CGFloat y = 0;
        _wuranLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, y, _weatherItemsScrollView.width, kWeatherInfoLabelTextFont + 1)];
        _wuranLabel.backgroundColor = [UIColor clearColor];
        _wuranLabel.textAlignment = NSTextAlignmentLeft;
        _wuranLabel.numberOfLines = 0;
        _wuranLabel.font = [UIFont systemFontOfSize:kWeatherInfoLabelTextFont];
        _wuranLabel.textColor = [UIColor colorFromString:[[SNThemeManager sharedThemeManager] currentThemeValueForKey:kWeatherWidgetTextColor]];
        _wuranLabel.lineBreakMode = NSLineBreakByWordWrapping;
        [_weatherItemsScrollView addSubview:_wuranLabel];
        
        y = _wuranLabel.bottom + kWeatherInfoLabelTopMargin;
        
        _jiaotongLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, y, _weatherItemsScrollView.width, kWeatherInfoLabelTextFont + 1)];
        _jiaotongLabel.backgroundColor = [UIColor clearColor];
        _jiaotongLabel.textAlignment = NSTextAlignmentLeft;
        _jiaotongLabel.numberOfLines = 0;
        _jiaotongLabel.font = [UIFont systemFontOfSize:kWeatherInfoLabelTextFont];
        _jiaotongLabel.textColor = [UIColor colorFromString:[[SNThemeManager sharedThemeManager] currentThemeValueForKey:kWeatherWidgetTextColor]];
        _jiaotongLabel.lineBreakMode = NSLineBreakByWordWrapping;
        [_weatherItemsScrollView addSubview:_jiaotongLabel];
        
        y = _jiaotongLabel.bottom + kWeatherInfoLabelTopMargin;
        
        _windLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, y, _weatherItemsScrollView.width, kWeatherInfoLabelTextFont + 1)];
        _windLabel.backgroundColor = [UIColor clearColor];
        _windLabel.textAlignment = NSTextAlignmentLeft;
        _windLabel.numberOfLines = 0;
        _windLabel.font = [UIFont systemFontOfSize:kWeatherInfoLabelTextFont];
        _windLabel.textColor = [UIColor colorFromString:[[SNThemeManager sharedThemeManager] currentThemeValueForKey:kWeatherWidgetTextColor]];
        _windLabel.lineBreakMode = NSLineBreakByWordWrapping;
        [_weatherItemsScrollView addSubview:_windLabel];
        
        y = _windLabel.bottom + kWeatherInfoLabelTopMargin;
        
        _chuanyiLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, y, _weatherItemsScrollView.width, kWeatherInfoLabelTextFont + 1)];
        _chuanyiLabel.backgroundColor = [UIColor clearColor];
        _chuanyiLabel.textAlignment = NSTextAlignmentLeft;
        _chuanyiLabel.numberOfLines = 0;
        _chuanyiLabel.font = [UIFont systemFontOfSize:kWeatherInfoLabelTextFont];
        _chuanyiLabel.textColor = [UIColor colorFromString:[[SNThemeManager sharedThemeManager] currentThemeValueForKey:kWeatherWidgetTextColor]];
        _chuanyiLabel.lineBreakMode = NSLineBreakByWordWrapping;
        [_weatherItemsScrollView addSubview:_chuanyiLabel];
        
        y = _chuanyiLabel.bottom + kWeatherInfoLabelTopMargin;
        
        _lvyouLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, y, _weatherItemsScrollView.width, kWeatherInfoLabelTextFont + 1)];
        _lvyouLabel.backgroundColor = [UIColor clearColor];
        _lvyouLabel.textAlignment = NSTextAlignmentLeft;
        _lvyouLabel.numberOfLines = 0;
        _lvyouLabel.font = [UIFont systemFontOfSize:kWeatherInfoLabelTextFont];
        _lvyouLabel.textColor = [UIColor colorFromString:[[SNThemeManager sharedThemeManager] currentThemeValueForKey:kWeatherWidgetTextColor]];
        _lvyouLabel.lineBreakMode = NSLineBreakByWordWrapping;
        [_weatherItemsScrollView addSubview:_lvyouLabel];
        
        y = _lvyouLabel.bottom + kWeatherInfoLabelTopMargin;
        
        _ganmaoLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, y, _weatherItemsScrollView.width, kWeatherInfoLabelTextFont + 1)];
        _ganmaoLabel.backgroundColor = [UIColor clearColor];
        _ganmaoLabel.textAlignment = NSTextAlignmentLeft;
        _ganmaoLabel.numberOfLines = 0;
        _ganmaoLabel.font = [UIFont systemFontOfSize:kWeatherInfoLabelTextFont];
        _ganmaoLabel.textColor = [UIColor colorFromString:[[SNThemeManager sharedThemeManager] currentThemeValueForKey:kWeatherWidgetTextColor]];
        _ganmaoLabel.lineBreakMode = NSLineBreakByWordWrapping;
        [_weatherItemsScrollView addSubview:_ganmaoLabel];
        
        y = _ganmaoLabel.bottom + kWeatherInfoLabelTopMargin;
        
        _yundongLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, y, _weatherItemsScrollView.width, kWeatherInfoLabelTextFont + 1)];
        _yundongLabel.backgroundColor = [UIColor clearColor];
        _yundongLabel.textAlignment = NSTextAlignmentLeft;
        _yundongLabel.numberOfLines = 0;
        _yundongLabel.font = [UIFont systemFontOfSize:kWeatherInfoLabelTextFont];
        _yundongLabel.textColor = [UIColor colorFromString:[[SNThemeManager sharedThemeManager] currentThemeValueForKey:kWeatherWidgetTextColor]];
        _yundongLabel.lineBreakMode = NSLineBreakByWordWrapping;
        [_weatherItemsScrollView addSubview:_yundongLabel];
        
        y = _yundongLabel.bottom;
        
        _weatherItemsScrollView.contentSize = CGSizeMake(_weatherItemsScrollView.width, y);
        
        _btmBar = [[SNWeatherBottomBar alloc] initWithFrame:CGRectMake(0, frame.size.height - kBottomBarHeight - 20 - 44, frame.size.width, kBottomBarHeight)];
        if([[UIDevice currentDevice] platformTypeForSohuNews] == UIDeviceiPhoneX){
            _btmBar.frame = CGRectMake(0, frame.size.height - kBottomBarHeight - 20 - 44 - 40, frame.size.width, kBottomBarHeight);
        }
        _btmBar.delegate = self;
        [self addSubview:_btmBar];
        
        _emptyRefreshBtn = [[UIButton alloc] initWithFrame:CGRectMake(_weatherIconView.left, _weatherIconView.top, _weatherIconView.width, _weatherIconView.height)];
        _emptyRefreshBtn.backgroundColor = [UIColor clearColor];
        _emptyRefreshBtn.adjustsImageWhenHighlighted = NO;
        [_emptyRefreshBtn addTarget:self action:@selector(reloadWeather) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:_emptyRefreshBtn];
        _emptyRefreshBtn.hidden = YES;

        UITapGestureRecognizer *tapGes = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(viewTaped)];
        [_contentView addGestureRecognizer:tapGes];
    }
    return self;
}

- (void)dealloc {
    self.delegate = nil;
     //(_cityGBcode);
     //(_btmBar);
     //(_contentView);
     //(_dateInfoLabel);
     //(_weatherIconView);
     //(_tempretureLabel);
     //(_weatherInfoLabel);
     //(_weatherItemsScrollView);
     //(_wuranLabel);
     //(_jiaotongLabel);
     //(_windLabel);
     //(_chuanyiLabel);
     //(_lvyouLabel);
     //(_ganmaoLabel);
     //(_yundongLabel);
     //(_weathers);
     //(_emptyRefreshBtn);
     //(_detailButton);
    
}

- (void)setWeatherInfoLabelText:(WeatherReport *)report {
    
    if (report.weather.length > 0) {
        NSMutableString *text = [NSMutableString stringWithString:report.weather];
        if (report.pm25.length > 0) {
            [text appendFormat:@"    PM2.5 %@", report.pm25];
        }
        if (report.quality.length > 0) {
            [text appendFormat:@"    %@", report.quality];
        }
        _weatherInfoLabel.text = text;
    }
}

- (void)initWeatherData {
    WeatherReport *report = nil;
    if (_selectedIndex < _weathers.count) {
        report = [_weathers objectAtIndex:_selectedIndex];
    }
    if (report) {
        _dateInfoLabel.text = [SNWeatherCenter dateInfoStringByWeatherReport:report];
        [_weatherIconView loadUrlPath:report.weatherIconUrl];
        
        NSString *tempString = [NSString stringWithFormat:@"%@%@ ~ %@%@", report.tempLow, kTemperatureMark, report.tempHigh, kTemperatureMark];
        _tempretureLabel.text = tempString;
        CGSize tempStringSize = [tempString sizeWithAttributes:@{NSFontAttributeName:[UIFont fontWithName:kDigitAndLetterFontFimalyName size:kTempLabelTextFont]}];
        //_weatherInfoLabel.text = report.weather;
        [self setWeatherInfoLabelText:report];
        
        if (report.wuran.length > 0) {
            _wuranLabel.hidden = NO;
            _wuranLabel.text = [NSString stringWithFormat:@"污染  %@", report.wuran];
        }
        else {
            _wuranLabel.hidden = YES;
        }
        
        if (report.jiaotong.length > 0) {
            _jiaotongLabel.hidden = NO;
            _jiaotongLabel.text = [NSString stringWithFormat:@"交通  %@", report.jiaotong];
        }
        else {
            _jiaotongLabel.hidden = YES;
        }
        
        if (report.wind.length > 0) {
            _windLabel.hidden = NO;
            _windLabel.text = [NSString stringWithFormat:@"风力  %@", report.wind];
        }
        else {
            _windLabel.hidden = YES;
        }
        
        if (report.chuanyi.length > 0) {
            _chuanyiLabel.hidden = NO;
            _chuanyiLabel.text = [NSString stringWithFormat:@"穿衣  %@", report.chuanyi];
        }
        else {
            _chuanyiLabel.hidden = YES;
        }
        
        if (report.lvyou.length > 0) {
            _lvyouLabel.hidden = NO;
            _lvyouLabel.text = [NSString stringWithFormat:@"旅游  %@", report.lvyou];
        }
        else {
            _lvyouLabel.hidden = YES;
        }
        
        if (report.ganmao.length > 0) {
            _ganmaoLabel.hidden = NO;
            _ganmaoLabel.text = [NSString stringWithFormat:@"感冒  %@", report.ganmao];
        }
        else {
            _ganmaoLabel.hidden = YES;
        }
        
        if (report.yundong.length > 0) {
            _yundongLabel.hidden = NO;
            _yundongLabel.text = [NSString stringWithFormat:@"运动  %@", report.yundong];
        }
        else {
            _yundongLabel.hidden = YES;
        }
        
        if ([report.morelink length] > 0) {
            self.detailButton.hidden = NO;
            self.detailButton.frame = CGRectMake(_tempretureLabel.origin.x + tempStringSize.width + 5, _tempretureLabel.top, 50, kTempLabelTextFont + 1);
            [self.detailButton setTitle:report.copywriting forState:UIControlStateNormal];
            [self.detailButton setTitle:report.copywriting forState:UIControlStateHighlighted];
        }
        else{
            self.detailButton.hidden = YES;
        }
    }
    else {
        // 空内容 提示
    }
    
    [self setNeedsLayout];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    CGFloat y = _wuranLabel.top;
    if (!_wuranLabel.isHidden) {
        y = fkLabelFrame(_wuranLabel, y);
        y += kWeatherInfoLabelTopMargin;
    }
    
    if (!_jiaotongLabel.isHidden) {
        y = fkLabelFrame(_jiaotongLabel, y);
        y += kWeatherInfoLabelTopMargin;
    }
    
    if (!_windLabel.isHidden) {
        y = fkLabelFrame(_windLabel, y);
        y += kWeatherInfoLabelTopMargin;
    }
    
    if (!_chuanyiLabel.isHidden) {
        y = fkLabelFrame(_chuanyiLabel, y);
        y += kWeatherInfoLabelTopMargin;
    }
    
    if (!_lvyouLabel.isHidden) {
        y = fkLabelFrame(_lvyouLabel, y);
        y += kWeatherInfoLabelTopMargin;
    }
    
    if (!_ganmaoLabel.isHidden) {
        y = fkLabelFrame(_ganmaoLabel, y);
        y += kWeatherInfoLabelTopMargin;
    }
    
    if (!_yundongLabel.isHidden) {
        y = fkLabelFrame(_yundongLabel, y);
    }
    
    _weatherItemsScrollView.contentSize = CGSizeMake(_weatherItemsScrollView.width, y);
}

- (void)setCityGBcode:(NSString *)cityGBcode {
    if (_cityGBcode != cityGBcode) {
        _cityGBcode = [cityGBcode copy];
        
        self.weathers = [NSArray arrayWithArray:[SNWeatherCenter weatherReportsByCityGbcode:_cityGBcode]];
        _selectedIndex = 0;
//        [self initWeatherData];
        
//        if (nil == _weathers || 0 == _weathers.count) {
//            if ([_delegate respondsToSelector:@selector(weatherDetailNeedRefresh:)]) {
//                [_delegate weatherDetailNeedRefresh:self.cityGBcode];
//            }
//        }
    }
}

- (void)setWeathers:(NSArray *)newWeathers {
     //(_weathers);
    _weathers = newWeathers;
    _btmBar.weathers = _weathers;
    _selectedIndex = 0;
    _emptyRefreshBtn.hidden = (_weathers.count != 0);
    [self initWeatherData];
}

- (void)viewTaped {
    if ([_delegate respondsToSelector:@selector(viewTaped:)]) {
        [_delegate viewTaped:self];
    }
    
    self.isBarHide = !self.isBarHide;
}

- (void)showBottomBar:(BOOL)show animated:(BOOL)animated {
    if (animated) {
        [UIView beginAnimations:@"barAnimation" context:nil];
        [UIView setAnimationDuration:0.3];
        [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
    }
    
    if (show) {
        CGRect frame = _btmBar.frame;
        frame.origin = CGPointMake(0, self.height - kBottomBarHeight - 20 - 44);
        _btmBar.frame = frame;
        
        frame = _weatherItemsScrollView.frame;
        if (self.frame.size.height == kIPHONE_6_HEIGHT) {
            frame.size.height = _btmBar.top - _weatherItemsScrollView.top - 11;
        }else {
            frame.size.height = _btmBar.top - _weatherItemsScrollView.top;
        }
        _weatherItemsScrollView.frame = frame;
        
        _dateInfoLabel.frame = CGRectMake(0, 44 + kDateInfoTopMargin, self.width, kDateInfoTextFont + 1);
    }
    else {
        CGRect frame = _btmBar.frame;
        frame.origin = CGPointMake(0, self.height);
        _btmBar.frame = frame;
        
        frame = _weatherItemsScrollView.frame;
        frame.size.height = _btmBar.top - _weatherItemsScrollView.top - 40;
        _weatherItemsScrollView.frame = frame;
        
        _dateInfoLabel.frame = CGRectMake(0, 20 + kDateInfoTopMargin, self.width, kDateInfoTextFont + 1);
    }
    
    if (animated) {
        [UIView commitAnimations];
    }
}

- (WeatherReport *)weather {
    WeatherReport *report = nil;
    if (_selectedIndex < _weathers.count) {
        report = [_weathers objectAtIndex:_selectedIndex];
    }
    return report;
}

- (NSString *)weatherDetail {
    NSString *weather = @"";
    
    WeatherReport *report = nil;
    if (_selectedIndex < _weathers.count) {
        report = [_weathers objectAtIndex:_selectedIndex];
    }
    if (report) {
        weather = [NSString stringWithString:report.weather];
    }
    
    return weather;
}

- (NSString *)weatherShareString {
    NSString *shareStr = @"";
    WeatherReport *rpt = nil;
    if (_selectedIndex < _weathers.count) {
        rpt = [_weathers objectAtIndex:_selectedIndex];
    }
//
//    if (rpt) {
//        shareStr = [NSString stringWithFormat:@"%@:%@ %@%@~%@%@ 污染 %@ 交通 %@",
//                    rpt.city, _weatherInfoLabel.text,
//                    rpt.tempLow, kTemperatureMark, rpt.tempHigh, kTemperatureMark, 
//                    rpt.wuran, rpt.jiaotong];
//    }
    //使用服务器返回字段，4.3.2
    if (rpt) {
        shareStr = rpt.shareContent;
    }
    return shareStr;
}

- (NSString *)weatherShareLinkString {
    NSString *shareLink = @"";
    WeatherReport *rpt = nil;
    if (_selectedIndex < _weathers.count) {
        rpt = [_weathers objectAtIndex:_selectedIndex];
    }
    
    if (rpt) {
        shareLink = rpt.shareLink;
    }
    return shareLink;
}

- (int)weatherShareLimitWord {
    int ugcWordLimit = 0;
    WeatherReport *rpt = nil;
    if (_selectedIndex < _weathers.count) {
        rpt = [_weathers objectAtIndex:_selectedIndex];
    }
    
    if (rpt) {
        ugcWordLimit = rpt.ugcWordLimit;
    }
    
    return ugcWordLimit;
}

- (void)reloadWeather {
    if ([_delegate respondsToSelector:@selector(weatherDetailNeedRefresh:)]) {
        [_delegate weatherDetailNeedRefresh:self.cityGBcode];
    }
}

- (void)refreshWeatherForce {
    if ([_delegate respondsToSelector:@selector(weatherDetailNeedForceRefresh:)]) {
        [_delegate weatherDetailNeedForceRefresh:self.cityGBcode];
    }
}

- (void)barSelectionChangedTo:(NSInteger)index {
    _selectedIndex = index;
    
    [self initWeatherData];
    
    if ([_delegate respondsToSelector:@selector(barSelectionChangedTo:)]) {
        [_delegate barSelectionChangedTo:_selectedIndex];
    }
}

- (void)showDetailWeather{
    if (self.isBarHide == YES) {
        if ([_delegate respondsToSelector:@selector(viewTaped:)]) {
            [_delegate viewTaped:self];
        }
    }
    
    WeatherReport *report = nil;
    if (_selectedIndex < _weathers.count) {
        report = [_weathers objectAtIndex:_selectedIndex];
    }
    
    [SNUtility openProtocolUrl:report.morelink context:nil];
}

@end
