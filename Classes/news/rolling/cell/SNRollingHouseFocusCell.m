//
//  SNRollingHouseFocusCell.m
//  sohunews
//
//  Created by wangyy on 15/5/27.
//  Copyright (c) 2015年 Sohu.com. All rights reserved.
//

#import "SNRollingHouseFocusCell.h"
#import "UISwitchCityButton.h"

@interface SNRollingHouseFocusCell (){
    UILabel *houseInfoLabel;
}

@property (nonatomic, strong) UILabel *houseInfoLabel;

@end

static CGFloat rowCellHeight = 0.0f;
static CGFloat rowCellHeight1 = 0.0f;

@implementation SNRollingHouseFocusCell
@synthesize houseInfoLabel;

+ (CGFloat)tableView:(UITableView *)tableView rowHeightForObject:(id)object {
    SNRollingNewsTableItem *newsItem = object;
    if (newsItem.subscribeAdObject) {
        if (rowCellHeight1 == 0.0f) {
            rowCellHeight1 = roundf(kAppScreenWidth * kFocusImageRate);
        }
        //NSLog(@"房产频道焦点图 rowCellHeight1 ----%f",rowCellHeight);
        return rowCellHeight1;
    }
    
    if (rowCellHeight == 0.0f) {
        rowCellHeight = roundf(kAppScreenWidth * kFocusImageRate + 7);
    }
    //NSLog(@"房产频道焦点图 ----%f",rowCellHeight);
    return rowCellHeight;
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        [self initHousePhotoView];
        topMarkView.hidden = NO;
        lineView.hidden = YES; //@qz 2017.10.24 这个cell不需要分割线吧
    }
    return self;
}

- (void)initHousePhotoView {
    UISwitchCityButton *switchCityButton = [[UISwitchCityButton alloc] initWithFrame:CGRectMake(0, 0, kSwitchCityWidth, 36)];
    switchCityButton.left = kAppScreenWidth - kSwitchCityWidth;
    switchCityButton.accessibilityLabel = @"切换城市";
    [switchCityButton addTarget:self action:@selector(switchCity) forControlEvents:UIControlEventTouchUpInside];
    [focusImageView addSubview:switchCityButton];
    switchCityButton.tag = 10001;
    
    self.houseInfoLabel = [[UILabel alloc] initWithFrame:CGRectMake(CONTENT_LEFT, 0, 200, 36)];
    self.houseInfoLabel.backgroundColor = [UIColor clearColor];
    self.houseInfoLabel.font = [UIFont systemFontOfSize:kThemeFontSizeC];
    self.houseInfoLabel.textColor = [UIColor whiteColor];
    [focusImageView addSubview:self.houseInfoLabel];
}

- (void)updateContentView {
    [super updateContentView];
    if (item.news.city == nil || item.news.city.length == 0) {
        self.houseInfoLabel.text = @"北京";
    } else {
        self.houseInfoLabel.text = item.news.city;
    }
    
    moreButton.hidden = YES;
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

@end
