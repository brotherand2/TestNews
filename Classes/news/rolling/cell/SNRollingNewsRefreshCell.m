//
//  SNRollingNewsRefreshCell.m
//  sohunews
//
//  Created by wangyy on 15/12/7.
//  Copyright © 2015年 Sohu.com. All rights reserved.
//

#import "SNRollingNewsRefreshCell.h"
#import "SNRollingNewsPublicManager.h"
#import "NSCellLayout.h"

#define kTopicCellHeight (84.f / 2)

@interface SNRollingNewsRefreshCell ()
@property (nonatomic, strong) UIImageView *iconImageView;
@property (nonatomic, strong) UILabel *topicLabel;
@property (nonatomic, strong) UIView *lineView;
@property (nonatomic, strong) UIView *backgroundColorView;
@end

@implementation SNRollingNewsRefreshCell

@synthesize topicLabel = _topicLabel;
@synthesize refreshItem = _refreshItem;
@synthesize lineView = _lineView;

+ (CGFloat)tableView:(UITableView *)tableView
  rowHeightForObject:(id)object {
    return kTopicCellHeight + IMAGE_TOP * 2;
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        self.showSlectedBg = NO;
        [self initContentView];
    }
    return self;
}

- (void)initContentView {
    self.backgroundColorView = [[UIView alloc] initWithFrame:CGRectMake(0, IMAGE_TOP + 2, kAppScreenWidth, kTopicCellHeight)];
    self.backgroundColorView.backgroundColor = SNUICOLOR(kThemeBg5Color);
    [self addSubview:self.backgroundColorView];
    
    [self setCellBackgroundColor];
    
    self.topicLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, kAppScreenWidth, kTopicCellHeight)];
    self.topicLabel.text = @"上次看到这里，点击刷新";
    
    self.topicLabel.font = [UIFont systemFontOfSize:kThemeFontSizeC];
    self.topicLabel.textColor = [[SNThemeManager sharedThemeManager] currentThemeColorForKey:kThemeBlue1Color];
    
    CGSize maximumLabelSize = CGSizeMake(kAppScreenWidth, FLT_MAX);
    CGRect textRect = [self.topicLabel.text boundingRectWithSize:maximumLabelSize options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:self.topicLabel.font} context:nil];
    
    self.topicLabel.width = textRect.size.width;
    
    self.topicLabel.backgroundColor = [UIColor clearColor];
    self.topicLabel.textAlignment = NSTextAlignmentCenter;
    
    UIImage *iconImage = [UIImage imageNamed:@"icohome_refresh_v5"];
    self.iconImageView = [[UIImageView alloc] initWithFrame:CGRectMake(self.topicLabel.width + 5, 0, iconImage.size.width, iconImage.size.height)];
    self.iconImageView.image = iconImage;
    
    UIView *centerView = [[UIView alloc] initWithFrame:CGRectZero];
    centerView.backgroundColor = [UIColor clearColor];
    centerView.size = CGSizeMake(self.topicLabel.width + 5.0 + iconImage.size.width, kTopicCellHeight);
    centerView.center = self.backgroundColorView.center;
    
    [centerView addSubview:self.topicLabel];
    [centerView addSubview:self.iconImageView];
    
    self.topicLabel.centerY = self.centerY;
    self.iconImageView.centerY = self.centerY;
    [self addSubview:centerView];
    
    //去掉线
    /*self.lineView = [[UIView alloc] initWithFrame:CGRectMake(0, kTopicCellHeight - 0.5f, kAppScreenWidth, 0.5f)];
    self.lineView.backgroundColor = SNUICOLOR(kThemeBg1Color);
    self.lineView.clipsToBounds = NO;
    [self addSubview:self.lineView];*/
}

- (void)setCellBackgroundColor {
    self.backgroundColorView.backgroundColor = SNUICOLOR(kRefreshBgColor);
}

- (void)setIconImage:(BOOL)isHighLight {
    if (isHighLight) {
        self.iconImageView.image = [UIImage themeImageNamed:@"icohome_refreshpress_v5.png"];
    } else {
        self.iconImageView.image = [UIImage themeImageNamed:@"icohome_refresh_v5.png"];
    }
}

- (void)setLabelAttributeText:(BOOL)isHighLight {
    //添加icon的一种方式
    /*NSTextAttachment *attachment = [[NSTextAttachment alloc] init];
    if ([[SNThemeManager sharedThemeManager] isNightTheme]) {
        if (isHighLight) {
            attachment.image = [UIImage imageNamed:@"night_icohome_refreshpress_v5"];
        } else {
            attachment.image = [UIImage imageNamed:@"night_icohome_refresh_v5"];
        }
    } else {
        if (isHighLight) {
            attachment.image = [UIImage imageNamed:@"icohome_refreshpress_v5"];
        } else {
            attachment.image = [UIImage imageNamed:@"icohome_refresh_v5"];
        }
    }
    
    attachment.bounds = CGRectMake(5, -1,
                                   attachment.image.size.width,
                                   attachment.image.size.height);
    
    NSAttributedString *attachmentString = [NSAttributedString attributedStringWithAttachment:attachment];
    
    NSString *text = @"上次看到这里，点击刷新";
    NSMutableAttributedString *textString = [[NSMutableAttributedString alloc] initWithString:text];
    [textString appendAttributedString:attachmentString];
    
    CGSize maximumLabelSize = CGSizeMake(kAppScreenWidth, FLT_MAX);
    CGRect textRect = [text boundingRectWithSize:maximumLabelSize
                                         options:NSStringDrawingUsesLineFragmentOrigin
                                      attributes:@{NSFontAttributeName:self.topicLabel.font}
                                         context:nil];

    self.topicLabel.attributedText = textString;*/
}

- (void)setObject:(id)object {
    if (!object) {
        return;
    }
    if (self.refreshItem != object) {
        self.refreshItem = object;
        self.refreshItem.delegate = self;
        self.refreshItem.selector = @selector(refreshAction);
    }
}

- (void)refreshAction {
    [SNRollingNewsPublicManager sharedInstance].newsSource = SNRollingNewsSourceRefresh;
    [SNRollingNewsPublicManager sharedInstance].refreshChannelId = self.refreshItem.news.channelId;
    [SNRollingNewsPublicManager sharedInstance].userAction = SNRollingNewsUserOnlyRefresh;
    [SNNotificationManager postNotificationName:kToastRefreshNotification object:nil];
}

- (void)updateTheme {
    [super updateTheme];
    self.topicLabel.textColor = [[SNThemeManager sharedThemeManager] currentThemeColorForKey:kThemeBlue1Color];
    self.lineView.backgroundColor = SNUICOLOR(kThemeBg1Color);
    
    [self setIconImage:NO];
    [self setCellBackgroundColor];
}

- (void)setHighlighted:(BOOL)highlighted animated:(BOOL)animated {
    if (highlighted) {
        self.topicLabel.textColor = [[SNThemeManager sharedThemeManager] currentThemeColorForKey:kThemeHighBlue1Color];
        [self setIconImage:YES];
    } else {
        self.topicLabel.textColor = [[SNThemeManager sharedThemeManager] currentThemeColorForKey:kThemeBlue1Color];
        [self setIconImage:NO];
    }
}

@end
