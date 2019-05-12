//
//  SNWeatherDetailView.h
//  sohunews
//
//  Created by yanchen wang on 12-7-18.
//  Copyright (c) 2012年 Sohu.com Inc. All rights reserved.
//
#import "SNWeatherBottomBar.h"

@class SNWebImageView;

@interface SNWeatherDetailView : UIView<SNWeatherBottomBarDelegate> {
    id __weak _delegate;
    NSString *_cityGBcode;
    
    SNWeatherBottomBar *_btmBar;
    UIView *_contentView;
    
    UILabel *_dateInfoLabel;
    SNWebImageView *_weatherIconView;
    UILabel *_tempretureLabel;
    UILabel *_weatherInfoLabel;
    
    UIScrollView *_weatherItemsScrollView;
    UILabel *_wuranLabel;
    UILabel *_jiaotongLabel;
    UILabel *_windLabel;
    UILabel *_chuanyiLabel;
    UILabel *_lvyouLabel;
    UILabel *_ganmaoLabel;
    UILabel *_yundongLabel;
    
    NSArray *_weathers;
    
    NSInteger _selectedIndex;
    
    UIButton *_emptyRefreshBtn;
}

@property(nonatomic, weak)id delegate;
@property(nonatomic, copy)NSString *cityGBcode;
@property(nonatomic, strong)NSArray *weathers;
@property (nonatomic, strong) UIButton *detailButton;
@property (nonatomic, assign) BOOL isBarHide;

- (void)showBottomBar:(BOOL)show animated:(BOOL)animated;

- (WeatherReport *)weather;
- (NSString *)weatherDetail;
- (NSString *)weatherShareString;
- (NSString *)weatherShareLinkString;
- (int)weatherShareLimitWord;
- (void)reloadWeather;
- (void)refreshWeatherForce;

@end


// protocol

@protocol SNWeatherDetailViewDelegate <NSObject>

@required
- (void)weatherDetailNeedRefresh:(NSString *)gbcode;
- (void)weatherDetailNeedForceRefresh:(NSString *)gbcode;

@optional
- (void)viewTaped:(SNWeatherDetailView *)weatherView;
- (void)barSelectionChangedTo:(NSInteger)index;

@end

