//
//  SNRollingNewsMySubscribeCell.m
//  sohunews
//
//  Created by ZhaoQing on 15/7/9.
//  Copyright (c) 2015年 Sohu.com. All rights reserved.
//

#import "SNRollingNewsMySubscribeCell.h"
#import "SNImageView.h"
#import "NSCellLayout.h"
#import "SNDBManager.h"
#import "SNSubscribeCenterService.h"
#import "SNUserManager.h"
#import "SNNewsReport.h"

@interface SNRollingNewsMySubscribeCell() {
    SNImageView *iconImageView;
    UILabel *titleLabel;
    UILabel *timeLabel;
    UILabel *newsTitleLabel;
    UIImageView *iconCoverImageView;
    UIImageView *unReadImageView;
    UILabel *unReadCountLabel;
}
@end

#define kNewsMySubscribeCellHeight ((kAppScreenWidth > 375) ? 280 / 3 : 171 / 2)

#define kIconImageViewTop ((kAppScreenWidth > 375) ? 54 / 3 : 33 / 2)
#define kIconImageViewWidth ((kAppScreenWidth > 375) ? 172 / 3 : 105 / 2)

#define kTitleLeft ((kAppScreenWidth > 375) ? 31 / 3 : 17 / 2)
#define kTitleTop ((kAppScreenWidth > 375) ? 67 / 3 : 39 / 2)
#define kTitleBottom ((kAppScreenWidth > 375) ? 47 / 3 : 26 / 2)
#define kTimeTop ((kAppScreenWidth > 375) ? 82 / 3 : 49 / 2)
#define kTimeRight ((kAppScreenWidth > 375) ? 57 / 3 : 35 / 2)
#define kUnReadImageViewwidth ((kAppScreenWidth > 375) ? 60 / 3 : 36 / 2)
#define kUnReadImageViewLeft ((kAppScreenWidth > 375) ? 176 / 3 : 108 / 2)
#define kUnReadImageViewBottom ((kAppScreenWidth > 375) ? 122 / 3 : 72 / 2)

@implementation SNRollingNewsMySubscribeCell

+ (CGFloat)tableView:(UITableView *)tableView
  rowHeightForObject:(id)object {
    return kNewsMySubscribeCellHeight;
}

- (id)initWithStyle:(UITableViewCellStyle)style
    reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:style
                    reuseIdentifier:reuseIdentifier]) {
        self.showSlectedBg = YES;
        [self initContentView];
    }
    return self;
}

- (void)initContentView {
    UIEdgeInsets insets = UIEdgeInsetsMake(2, 2, 2, 2);
    UIImage *subIconBgImg = [[UIImage themeImageNamed:@"bgsquare_journal_v5.png"] resizableImageWithCapInsets:insets resizingMode:UIImageResizingModeStretch];
    iconCoverImageView = [[UIImageView alloc] initWithFrame:CGRectMake(kIconImageViewTop, kIconImageViewTop, kIconImageViewWidth, kIconImageViewWidth)];
    iconCoverImageView.image = subIconBgImg;
    iconCoverImageView.alpha = themeImageAlphaValue();
    iconCoverImageView.layer.masksToBounds = YES;
    iconCoverImageView.layer.cornerRadius = 3.0f;
    [self addSubview:iconCoverImageView];
    
    iconImageView = [[SNImageView alloc] initWithFrame:CGRectMake(0, 0, kIconImageViewWidth, kIconImageViewWidth)];
    iconImageView.ignorePictureMode = YES;
    iconImageView.alpha = themeImageAlphaValue();
    iconImageView.center = iconCoverImageView.center;
    iconImageView.layer.masksToBounds = YES;
    iconImageView.layer.cornerRadius = 3.0f;
    [self addSubview:iconImageView];
    
    unReadImageView = [[UIImageView alloc] initWithFrame:CGRectMake(kUnReadImageViewLeft, iconImageView.bottom - kUnReadImageViewBottom - kUnReadImageViewwidth, kUnReadImageViewwidth, kUnReadImageViewwidth)];
    unReadImageView.image = [UIImage imageNamed:@"ico_hongdian_v5.png"];
    unReadImageView.hidden = YES;
    [self addSubview:unReadImageView];
    
    unReadCountLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 1, kUnReadImageViewwidth, kUnReadImageViewwidth-1)];
    unReadCountLabel.backgroundColor = [UIColor clearColor];
    unReadCountLabel.font = [UIFont systemFontOfSize:kThemeFontSizeB];
    unReadCountLabel.textColor = SNUICOLOR(kThemeText5Color);
    unReadCountLabel.textAlignment = NSTextAlignmentCenter;
    [unReadImageView addSubview:unReadCountLabel];


    titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(iconImageView.right + kTitleLeft, kTitleTop, kAppScreenWidth - kIconImageViewTop - iconImageView.width - kTitleLeft - 80 - kTimeRight, [SNUtility getNewsTitleFontSize] + 2)];
    titleLabel.backgroundColor = [UIColor clearColor];
    titleLabel.font = [SNUtility getNewsTitleFont];
    titleLabel.textColor = [[SNThemeManager sharedThemeManager] currentThemeColorForKey:kThemeText1Color];
    [self addSubview:titleLabel];

    timeLabel = [[UILabel alloc] initWithFrame:CGRectMake(kAppScreenWidth - kTimeRight - 80, kTimeTop, 80, kThemeFontSizeB)];
    timeLabel.backgroundColor = [UIColor clearColor];
    timeLabel.font = [UIFont systemFontOfSize:kThemeFontSizeB];
    timeLabel.textAlignment = NSTextAlignmentRight;
    timeLabel.textColor = [[SNThemeManager sharedThemeManager] currentThemeColorForKey:kThemeText4Color];
    [self addSubview:timeLabel];
    
    newsTitleLabel = [[UILabel alloc] initWithFrame:CGRectMake(iconImageView.right + kTitleLeft, titleLabel.bottom - 2 + kTitleBottom, kAppScreenWidth - kIconImageViewTop * 2 - iconImageView.width - kTitleLeft, [SNUtility getNewsTitleFontSize] + 1)];
    newsTitleLabel.backgroundColor = [UIColor clearColor];
    newsTitleLabel.font = [SNUtility getNewsTitleFont];
    if ([SNUtility getNewsFontSizeIndex] == 3) {
        newsTitleLabel.top = titleLabel.bottom - 2 + kTitleBottom - 5;
    } else if ([SNUtility getNewsFontSizeIndex] == 4) {
        newsTitleLabel.top = titleLabel.bottom - 2 + kTitleBottom - 8;
    }
    newsTitleLabel.textColor = [[SNThemeManager sharedThemeManager] currentThemeColorForKey:kThemeText4Color];
    [self addSubview:newsTitleLabel];
}

- (void)setObject:(id)object
{
    if (!object) {
        return;
    }
    if (self.subscribeItem != object) {
        self.subscribeItem = object;
        self.subscribeItem.delegate = self;
        self.subscribeItem.selector = @selector(openSubscribe);
    }
    [self updateContentView];
}

- (void)updateContentView {
    titleLabel.text = self.subscribeItem.subscribeObject.subName;
    titleLabel.font = [SNUtility getNewsTitleFont];
    titleLabel.height = [SNUtility getNewsTitleFontSize] + 2;
    iconImageView.ignorePictureMode = YES;
    [iconImageView loadImageWithUrl:self.subscribeItem.subscribeObject.subIcon
                       defaultImage:[UIImage imageNamed:kThemeImgPlaceholder1]];
    if (self.subscribeItem.subscribeObject.unReadCount) {
        if (![self.subscribeItem.subscribeObject.unReadCount isEqualToString:@"0"]) {
            unReadImageView.hidden = NO;
            if (self.subscribeItem.subscribeObject.unReadCount.intValue > 99) {
                unReadCountLabel.text = @"⋯";
            } else {
                unReadCountLabel.text = self.subscribeItem.subscribeObject.unReadCount;
            }
        } else {
            unReadImageView.hidden = YES;
        }
    }
    if (self.subscribeItem.subscribeObject.topNewsArray && self.subscribeItem.subscribeObject.topNewsArray.count > 0) {
        NSDictionary *dict = [self.subscribeItem.subscribeObject.topNewsArray objectAtIndex:0];
        timeLabel.text = [NSDate relativelyDate:[dict objectForKey:@"publishTime"]];
        newsTitleLabel.text = [dict objectForKey:@"title"];
        newsTitleLabel.font = [SNUtility getNewsTitleFont];
        newsTitleLabel.height = [SNUtility getNewsTitleFontSize] + 1;
        if ([SNUtility getNewsFontSizeIndex] == 3) {
            newsTitleLabel.top = titleLabel.bottom - 2 + kTitleBottom - 5;
        } else if ([SNUtility getNewsFontSizeIndex] == 4) {
            newsTitleLabel.top = titleLabel.bottom - 2 + kTitleBottom - 8;
        }
    }
}

- (void)updateTheme {
    [super updateTheme];
    UIEdgeInsets insets = UIEdgeInsetsMake(2, 2, 2, 2);
    UIImage *subIconBgImg = [[UIImage themeImageNamed:@"bgsquare_journal_v5.png"] resizableImageWithCapInsets:insets resizingMode:UIImageResizingModeStretch];
    iconCoverImageView.image = subIconBgImg;
    iconImageView.alpha = themeImageAlphaValue();
    iconCoverImageView.alpha = themeImageAlphaValue();
    iconCoverImageView.image = [UIImage imageNamed:@"icobooking_publication_v5.png"];
    titleLabel.textColor = [[SNThemeManager sharedThemeManager] currentThemeColorForKey:kThemeText1Color];
    timeLabel.textColor = SNUICOLOR(kThemeText4Color);
    newsTitleLabel.textColor = SNUICOLOR(kThemeText4Color);
    unReadImageView.image = [UIImage imageNamed:@"ico_hongdian_v5.png"];
    unReadCountLabel.textColor = SNUICOLOR(kThemeText5Color);
}

- (void)unreadClear {
    [self.subscribeItem.subscribeObject setUnReadCount:@"0"];
    NSDictionary *dict = [NSDictionary dictionaryWithObject:@"0" forKey:TB_SUB_CENTER_ALL_SUB_UN_READ_COUNT];
    [[SNDBManager currentDataBase] updateSubscribeCenterSubscribeObjectByPubId:self.subscribeItem.subscribeObject.pubIds withValuePairs:dict];
    unReadImageView.hidden = YES;
    [SNNotificationManager removeObserver:self name:kUnreadClearNotification object:nil];
}

- (void)openSubscribe {
    if (self.subscribeItem.subscribeObject.link.length > 0) {
        [SNNewsReport reportADotGif:[NSString stringWithFormat:@"_act=subbed&_tp=pv&subid=%@", self.subscribeItem.subscribeObject.subId]];

        if (self.subscribeItem.subscribeObject.unReadCount && ![self.subscribeItem.subscribeObject.unReadCount isEqualToString:@"0"]) {
            [SNNotificationManager addObserver:self selector:@selector(unreadClear) name:kUnreadClearNotification object:nil];

            [[SNSubscribeCenterService defaultService] unreadClearSubId:self.subscribeItem.subscribeObject.subId];
        }
        BOOL redRefresh = [[NSUserDefaults standardUserDefaults] boolForKey:@"redRefresh"];
        if (redRefresh) {
            //订阅频道有红点，进入订阅频道，且点击了里面的刊物，记录下是消费了
            [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"kIsConsumption"];
            [[NSUserDefaults standardUserDefaults] synchronize];
        }
        NSMutableDictionary * referInfo = [NSMutableDictionary dictionary];
        [referInfo setObject:@"0" forKey:kReferValue];
        [referInfo setObject:@"0" forKey:kReferType];
        [referInfo setObject:[NSNumber numberWithInt:SNProfileRefer_Subscribe_MeMedia] forKey:kRefer];

        [SNUtility openProtocolUrl:self.subscribeItem.subscribeObject.link context:referInfo];
    }
}

@end
