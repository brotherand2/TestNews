//
//  SNRollingLoadMoreCell.m
//  sohunews
//
//  Created by lhp on 8/5/14.
//  Copyright (c) 2014 Sohu.com. All rights reserved.
//

#import "SNRollingLoadMoreCell.h"
#import "SNRollingNewsPublicManager.h"

#import "SNWaitingActivityView.h"
#import "SNDevice.h"
#import "SNNewsReport.h"
#import "SNUserManager.h"
#import "NSObject+YAJL.h"

#define kLoadMoreCellHeight         (64 / 2)

@interface SNRollingLoadMoreCell () {
    UILabel *titleLabel;
    UILabel *_blueTitleLabel;
    UIImageView *dotImageView;
    SNWaitingActivityView *activityIndicatorView;
}
@end

@implementation SNRollingLoadMoreCell
@synthesize loadMoreItem;

+ (CGFloat)tableView:(UITableView *)tableView
  rowHeightForObject:(id)object {
    return kLoadMoreCellHeight;
}

- (id)initWithStyle:(UITableViewCellStyle)style
    reuseIdentifier:(NSString *)identifier {
	self = [super initWithStyle:style reuseIdentifier:identifier];
    if (self) {
        self.showSlectedBg = NO;
        self.backgroundColor = [UIColor clearColor];
        self.contentView.backgroundColor = [UIColor clearColor];
        [self initAllSubviews];
    }
    return self;
}

- (void)initAllSubviews {
    titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 8, kAppScreenWidth, kThemeFontSizeC + 1)];
    titleLabel.font = [UIFont systemFontOfSize:kThemeFontSizeC];
    titleLabel.backgroundColor = [UIColor clearColor];
    titleLabel.textColor = SNUICOLOR(kThemeText6Color);
    titleLabel.textAlignment = NSTextAlignmentCenter;
    [self addSubview:titleLabel];
    
    _blueTitleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 8, 0, 0)];
    _blueTitleLabel.font = [UIFont systemFontOfSize:kThemeFontSizeC];
    _blueTitleLabel.backgroundColor = [UIColor clearColor];
    _blueTitleLabel.textColor = SNUICOLOR(kThemeBlue1Color);
    _blueTitleLabel.textAlignment = NSTextAlignmentCenter;
    [self addSubview:_blueTitleLabel];

    activityIndicatorView = [[SNWaitingActivityView alloc] initWithFrame:CGRectMake(0, 0, 12, 12)];
    CGFloat xValue = [SNDevice sharedInstance].isPlus ? 125.0 : 110.0;
    activityIndicatorView.center = CGPointMake(xValue , kLoadMoreCellHeight / 2);
    [self addSubview:activityIndicatorView];
    
    dotImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0.0f, 8.0f, 4, 4)];
    [dotImageView setImage:[UIImage imageNamed:@"icohome_dot_v5.png"]];
    [dotImageView setHidden:YES];
    [self addSubview:dotImageView];
}

- (NSString *)getLoadMoreTips {
    return self.loadMoreItem.news.title;
}

- (void)setObject:(id)object {
    if (!object) {
        return;
    }
    
    if (self.loadMoreItem != object) {
        self.loadMoreItem = (SNRollingLoadMoreItem *)object;
        self.loadMoreItem.delegate = self;
        self.loadMoreItem.selector = @selector(loadMoreNews);
        NSString *loadMoreTips = [self getLoadMoreTips];
        if (loadMoreTips.length > 0) {
            [self resetLabelLocation];
            dotImageView.hidden = !self.loadMoreItem.news.showUpdateTips;
            CGSize titleSize = [loadMoreTips sizeWithFont:[UIFont systemFontOfSize:kThemeFontSizeC]];
            dotImageView.left = kAppScreenWidth / 2 + titleSize.width / 2 + 10;
            
//            [self setArrowButtonImage];
        }
    }
    NSString *loadMoreTips = [self getLoadMoreTips];
    if ([loadMoreTips isEqualToString:@"展开，继续看今日要闻"]) {
        if (self.loadMoreItem.isLoadingNews) {
            [activityIndicatorView startAnimating];
        } else {
            [activityIndicatorView stopAnimating];
        }
    }
    
    if ([SNUtility customSettingChange]) {
        [self setNeedsDisplay];
    }
}

- (void)setHighlighted:(BOOL)highlighted animated:(BOOL)animated {
//    arrowImageView.highlighted = highlighted;
    if (highlighted) {
        titleLabel.textColor = [[SNThemeManager sharedThemeManager] currentThemeColorForKey:kPostTextViewBgColor];
        _blueTitleLabel.textColor = SNUICOLOR(kThemeHighBlue1Color);
    } else {
        titleLabel.textColor = [[SNThemeManager sharedThemeManager] currentThemeColorForKey:kThemeText3Color];
        _blueTitleLabel.textColor = SNUICOLOR(kThemeBlue1Color);
    }
}

- (void)drawBackgroundColorWithRect:(CGRect)rect {
    CGContextRef context = UIGraphicsGetCurrentContext();
    //5.9.3 wangchuanwen update
    //UIColor *grayColor = SNUICOLOR(kThemeBg3Color);
    UIColor *grayColor = SNUICOLOR(kThemeBgRIColor);
    CGContextSetFillColorWithColor(context, grayColor.CGColor);
    CGContextFillRect(context, rect);
}

- (void)drawRect:(CGRect)rect {
    [self drawBackgroundColorWithRect:rect];
    [UIView drawCellSeperateLine:rect margin:0];
}

- (void)updateTheme {
    [super updateTheme];
    self.backgroundColor = [UIColor clearColor];
    self.contentView.backgroundColor = [UIColor clearColor];
//    [self setArrowButtonImage];
    dotImageView.image = [UIImage themeImageNamed:@"icohome_dot_v5.png"];
    titleLabel.textColor = SNUICOLOR(kThemeText6Color);
    _blueTitleLabel.textColor = SNUICOLOR(kThemeBlue1Color);
    [activityIndicatorView updateTheme];
    
    [self setNeedsDisplay];
}

- (void)loadMoreNews {
    if (![SNUtility getApplicationDelegate].isNetworkReachable) {
        [[SNCenterToast shareInstance] showCenterToastWithTitle:NSLocalizedString(@"network error", @"") toUrl:nil mode:SNCenterToastModeError];
        return;
    }
    if (self.loadMoreItem.dataSource) {
        if (self.loadMoreItem.news.morePageNum > 0) {
            if (self.loadMoreItem.news.morePageNum == 1) {
//                [SNRollingNewsPublicManager sharedInstance].homeADCount = 0;
                if ([self.loadMoreItem.news.title isEqualToString:kHomePageEditModeText]) {
                    [SNRollingNewsPublicManager sharedInstance].isClickTodayImportNews = YES;
                    [SNRollingNewsPublicManager sharedInstance].isRollingEditNewsShow = YES;
                }
                [SNNotificationManager postNotificationName:kRecommendToEidtModeNotification object:nil];
                //首页频道流改版, 无需发此通知
                //[SNNotificationManager postNotificationName:kRecommendReadMoreDidClickNotification object:nil];
                
                self.loadMoreItem.isLoadingNews = YES;

                [SNNewsReport reportADotGif:@"_act=toeditflow&_tp=pv&channelid=1"];
            } else {
                [SNRollingNewsPublicManager sharedInstance].isRollingEditNewsShow = YES;
                BOOL isLoad = [self.loadMoreItem.dataSource.newsModel loadMoreEditNewsWithPage:self.loadMoreItem.news.morePageNum];
                self.loadMoreItem.isLoadingNews = isLoad;
                if (isLoad) {
//                    arrowImageView.hidden = YES;
                    dotImageView.hidden = YES;
                    titleLabel.text = @"正在加载";
                    _blueTitleLabel.hidden = YES;
                    activityIndicatorView.right = titleLabel.left + 20.0;
                    [activityIndicatorView startAnimating];
                }
            }
        }
    }
}

- (void)endLoadAnimation {
    self.loadMoreItem.isLoadingNews = NO;
//    arrowImageView.hidden = NO;
    _blueTitleLabel.hidden = NO;
    dotImageView.hidden = !self.loadMoreItem.news.showUpdateTips;
    [self resetLabelLocation];
    [activityIndicatorView stopAnimating];
}

//- (void)setArrowButtonImage {
//    NSString *imageName = @"icohome_open_v5.png";
//    NSString *highlightedImageName = @"icohome_openpress_v5.png";
//    if (self.loadMoreItem.dataSource && [titleLabel.text isEqualToString:kHomePageEditModeText]) {
//        if (self.loadMoreItem.news.morePageNum > 0) {
//            if (self.loadMoreItem.news.morePageNum == 1){
//                imageName = @"icohome_return_v5.png";
//                highlightedImageName = @"icohome_returnpress_v5.png";
//            }
//        }
//        [SNRollingNewsPublicManager sharedInstance].isRecommendAfterEditNews = NO;
//    } else {
//        [SNRollingNewsPublicManager sharedInstance].isRecommendAfterEditNews = YES;
//    }
//    
////    arrowImageView.image = [UIImage themeImageNamed:imageName];
////    arrowImageView.highlightedImage = [UIImage themeImageNamed:highlightedImageName];
//}

- (void)resetLabelLocation {
    titleLabel.text = [self getLoadMoreTips];
    [titleLabel sizeToFit];
    _blueTitleLabel.text = self.loadMoreItem.news.blueTitle;
    [_blueTitleLabel sizeToFit];
//
//    CGFloat pointX = (kAppScreenWidth - arrowImageView.width - titleLabel.width - _blueTitleLabel.width - 10.0) / 2.0;
//    arrowImageView.left = pointX;
//    titleLabel.left = arrowImageView.right + 8.0;;
//    _blueTitleLabel.left = titleLabel.right + 2.0;
    
    titleLabel.left = (kAppScreenWidth - titleLabel.width - _blueTitleLabel.width - 10.0) / 2.0;
    _blueTitleLabel.left = titleLabel.right + 2.0;

}

@end
