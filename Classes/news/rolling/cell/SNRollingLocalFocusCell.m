//
//  SNRollingLocalFocusCell.m
//  sohunews
//
//  Created by wangyy on 15/5/27.
//  Copyright (c) 2015年 Sohu.com. All rights reserved.
//

#import "SNRollingLocalFocusCell.h"
#import "UISwitchCityButton.h"

@interface SNRollingLocalFocusCell () {
    UILabel *weatherLabel;
    UIButton *weatherButton;
}

@property (nonatomic, strong) UILabel *weatherLabel;
@property (nonatomic, strong) UIButton *weatherButton;

@end

static CGFloat rowCellHeight = 0.0f;
static CGFloat rowCellHeight1 = 0.0f;

@implementation SNRollingLocalFocusCell

@synthesize weatherLabel;
@synthesize weatherButton;

+ (CGFloat)tableView:(UITableView *)tableView
  rowHeightForObject:(id)object {
    SNRollingNewsTableItem *newsItem = object;
    if (newsItem.subscribeAdObject) {
        if (rowCellHeight1 == 0.0f) {
            rowCellHeight1 = roundf(kAppScreenWidth * kFocusImageRate);
        }
        return rowCellHeight1;
    }
    
    if (rowCellHeight == 0.0f) {
        rowCellHeight = roundf(kAppScreenWidth * kFocusImageRate + 7);
    }
    return rowCellHeight;
}

- (id)initWithStyle:(UITableViewCellStyle)style
    reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:style
                    reuseIdentifier:reuseIdentifier]) {
        [self initLocalPhotoView];
        topMarkView.hidden = NO;
    }
    return self;
}

- (void)initLocalPhotoView {
    UISwitchCityButton *switchCityButton = [[UISwitchCityButton alloc] initWithFrame:CGRectMake(0, 0, kSwitchCityWidth, 40)];
    switchCityButton.left = kAppScreenWidth - kSwitchCityWidth;
    switchCityButton.accessibilityLabel = @"切换城市";
    [switchCityButton addTarget:self action:@selector(switchCity) forControlEvents:UIControlEventTouchUpInside];
    [focusImageView addSubview:switchCityButton];
    switchCityButton.tag = 10001;
    
    self.weatherButton =[UIButton buttonWithType:UIButtonTypeCustom];
    self.weatherButton.frame = CGRectMake(CONTENT_LEFT, 0, 200, 35);
    self.weatherButton.backgroundColor = [UIColor clearColor];
    self.weatherButton.titleLabel.font = [UIFont systemFontOfSize:kThemeFontSizeC];
    [self.weatherButton addTarget:self action:@selector(openWeather) forControlEvents:UIControlEventTouchUpInside];
    [focusImageView addSubview:self.weatherButton];
}

- (void)updateContentView {
    @autoreleasepool {
        [super updateContentView];
        NSString *weatherInfo = [NSString stringWithFormat:@"%@ %@/%@℃", item.news.weather, item.news.tempLow, item.news.tempHigh];
        [self.weatherButton setTitle:weatherInfo forState:UIControlStateNormal];
        [self.weatherButton setTitle:weatherInfo forState:UIControlStateHighlighted];
        self.weatherButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
        moreButton.hidden = YES;
    }
}

- (void)updateTheme {
    [super updateTheme];
    
    id subview = [focusImageView viewWithTag:10001];
    if ([subview isKindOfClass:[UISwitchCityButton class]] ) {
        UISwitchCityButton *button = (UISwitchCityButton *)subview;
        [button updateTheme];
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

- (void)openWeather {
    [SNUtility shouldUseSpreadAnimation:YES];
    NSMutableDictionary *weatherDic = [NSMutableDictionary dictionary];
    if (item.news.gbcode) {
        [weatherDic setObject:item.news.gbcode forKey:kGbcode];
    }
    if (item.news.city) {
        [weatherDic setObject:item.news.city forKey:kCity];
    }
    TTURLAction *urlAction = [[[TTURLAction actionWithURLPath:@"tt://weather"] applyQuery:weatherDic] applyAnimated:YES];
    [[TTNavigator navigator] openURLAction:urlAction];
}

@end
