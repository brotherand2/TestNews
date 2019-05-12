//
//  SNRollingNewsTopicCell.m
//  sohunews
//
//  Created by lhp on 3/31/15.
//  Copyright (c) 2015 Sohu.com. All rights reserved.
//

#import "SNRollingNewsTopicCell.h"
#import "SNAppConfigManager.h"
#import "SNRedPacketManager.h"
#import "SNCellImageView.h"
#import "NSDictionaryExtend.h"

static NSString * const kPullString = @"下拉，去看兴趣推荐";

@interface SNRollingNewsTopicCell() {
    UILabel *topicLabel;
    SNImageView *topicImage;
}

@property (nonatomic, strong) SNImageView *topicImage;
@property (nonatomic, strong) UIView *centerView;
@end

@implementation SNRollingNewsTopicCell

@synthesize topicImage;
@synthesize newsItem = _newsItem;

#define kTopicCellHeight (56.f / 2)

+ (CGFloat)tableView:(UITableView *)tableView
  rowHeightForObject:(id)object {
    return kTopicCellHeight;
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        self.showSlectedBg = NO;
        [self initContentView];
        
        [SNNotificationManager addObserver:self selector:@selector(couponReceiveSucces:) name:kJoinRedPacketsStateChanged object:nil];
        
        [SNNotificationManager addObserver:self selector:@selector(showRedPacketTheme:) name:kShowRedPacketThemeNotification object:nil];
    }
    return self;
}

- (void)initContentView {
    self.topicImage = [[SNImageView alloc] initWithFrame:CGRectMake(0.0, 4.0, 18.0, 18.0)];
    self.topicImage.hidden = YES;

    topicLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, kAppScreenWidth, kTopicCellHeight)];
    topicLabel.backgroundColor = [UIColor clearColor];
    topicLabel.textAlignment = NSTextAlignmentCenter;
    topicLabel.font = [UIFont systemFontOfSize:kThemeFontSizeC];
    topicLabel.textColor = SNUICOLOR(kThemeText6Color);
    
    self.centerView = [[UIView alloc] initWithFrame:CGRectZero];
    self.centerView.backgroundColor = [UIColor clearColor];
    
    [self.centerView addSubview:self.topicImage];
    [self.centerView addSubview:topicLabel];
    
    [self addSubview:self.centerView];
}

- (void)setObject:(id)object {
    if (self.newsItem == object) {
        return;
    }
    if ([object isKindOfClass:[SNRollingNewsTableItem class]]) {
        self.newsItem = (SNRollingNewsTableItem *)object;
    }
    [self updateContentView];
}

//更新显示图片效果
- (void)updateNewsContent:(NSString *)content
             withImageURL:(NSString *)imageURL
      withDefaultImageURL:(NSString *)defualtImageURL {
    UIImage *iconImage = [UIImage imageNamed:defualtImageURL];
    self.topicImage.frame = CGRectMake(0, 0, iconImage.size.width, iconImage.size.height);
    [self.topicImage loadBySystemRequest:imageURL defaultImage:iconImage];
    
    CGSize maximumLabelSize = CGSizeMake(kAppScreenWidth, FLT_MAX);
    CGRect textRect = [content
                       boundingRectWithSize:maximumLabelSize options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:topicLabel.font} context:nil];
    
    topicLabel.frame = CGRectMake(self.topicImage.right + 7, 0, textRect.size.width, kTopicCellHeight);
    
    self.centerView.size = CGSizeMake(topicLabel.width + 7.0 + iconImage.size.width, kTopicCellHeight);
    self.centerView.centerX = kAppScreenWidth / 2;
    self.centerView.centerY = topicLabel.centerY;
    
    topicLabel.centerY = topicLabel.centerY;
    self.topicImage.centerY = topicLabel.centerY;
}

- (void)updateContentView {
    NSString *content = kPullString;
    
    BOOL hasImage = NO;
    if (self.newsItem != nil) {
        content = self.newsItem.news.title;

        if (self.newsItem.news.picUrl.length == 0) {
            if ([[SNRedPacketManager sharedInstance] showRedPacketActivityTheme]) {
                hasImage = YES;
            }
        } else {
            hasImage = YES;
        }
    }
    
    topicLabel.text = content;
    if (hasImage) {
        //显示红包图片
        NSString *imageURL = nil;
        
        self.topicImage.hidden = NO;
        if ([[SNThemeManager sharedThemeManager] isNightTheme]) {
            imageURL = @"night_icohome_hb_v5.png";
        } else {
            imageURL = @"icohome_hb_v5.png";
        }
        [self updateNewsContent:content withImageURL:self.newsItem.news.picUrl withDefaultImageURL:imageURL];
    } else {
        //显示推荐图片
        self.topicImage.hidden = YES;
        if ([content isEqualToString:kPullString]) {
            self.topicImage.hidden = NO;
            NSString *imageString = nil;
            if ([[SNThemeManager sharedThemeManager] isNightTheme]) {
                imageString = @"night_icohome_arrow_down_v5.png";
            } else {
                imageString = @"icohome_arrow_down_v5.png";
            }
            [self updateNewsContent:content withImageURL:nil
                withDefaultImageURL:imageString];
        }
    }
}

- (void)dealloc {
    [SNNotificationManager removeObserver:self];
}

- (void)updateTheme {
    [super updateTheme];
    topicLabel.textColor = SNUICOLOR(kThemeText6Color);
    
    if (self.topicImage.hidden == NO) {
        [self.topicImage setDefaultImage:[UIImage themeImageNamed:@"icohome_hb_v5.png"]];
    }
    
    [self updateContentView];
}

- (void)couponReceiveSucces:(NSNotification *)notification {
    dispatch_async(dispatch_get_main_queue(), ^{
        [self updateContentView];
    });
}

- (void)showRedPacketTheme:(NSNotification *)notification {
    [self updateContentView];
}

@end
