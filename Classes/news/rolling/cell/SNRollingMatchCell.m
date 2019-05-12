//
//  SNRollingMatchCell.m
//  sohunews
//
//  Created by lhp on 5/8/14.
//  Copyright (c) 2014 Sohu.com. All rights reserved.
//

#import "SNRollingMatchCell.h"
#import "SNThemeManager.h"
#import "SNDevice.h"

@interface SNRollingMatchCell () {
    SNImageView *bgImageView;
    UIView *coverView;
}

@end

static CGFloat rowCellHeight = 0.0f;

@implementation SNRollingMatchCell

+ (CGFloat)tableView:(UITableView *)tableView
  rowHeightForObject:(id)object {
    SNRollingNewsTableItem *aItem = object;
    //by 5.9.4 wangchuanwen modify
    return IMAGE_TOP + aItem.titleHeight + FEED_SPACEVALUE + [self getImageHeight] + COMMENT_BOTTOM + CELLITEM_HEIGHT;
    //modify end
}

+ (BOOL)isMultiLineTitleWithItem:(SNRollingNewsTableItem *)item {
    //比分频道默认传NO
    return NO;
}

+ (int)getImageHeight {
    int imageHeight = 122 / 2;
    UIDevicePlatform plat = [[SNDevice sharedInstance] devicePlat];
    switch (plat) {
        case UIDevice6PlusiPhone:
        case UIDevice7PlusiPhone:
        case UIDevice8PlusiPhone:
            imageHeight = 242 / 3;
            break;
        case UIDevice6iPhone:
        case UIDevice7iPhone:
        case UIDevice8iPhone:
            imageHeight = 146 / 2;
            break;
        default:
            break;
    }
    return imageHeight;
}

- (id)initWithStyle:(UITableViewCellStyle)style
    reuseIdentifier:(NSString *)identifier {
	self = [super initWithStyle:style reuseIdentifier:identifier];
    if (self) {
        [self initWithContent];
    }
    return self;
}

- (void)initWithContent {
    int contentWidth = kAppScreenWidth - 2 * CONTENT_LEFT;
    int contentHeight = [[self class] getImageHeight];
    CGRect contentRect = CGRectMake(CONTENT_LEFT, CONTENT_IMAGE_TOP, contentWidth, contentHeight);
    bgImageView = [[SNImageView alloc] initWithFrame:contentRect];
    bgImageView.backgroundColor = [[SNThemeManager sharedThemeManager] currentThemeColorForKey:kThemeBg2Color];
    [self addSubview:bgImageView];
    
    coverView = [[UIView alloc] initWithFrame:contentRect];
    coverView.backgroundColor = [UIColor blackColor];
    coverView.alpha = 0.4;
    [self addSubview:coverView];
    
    matchContentView = [[SNCellMatchContentView alloc] initWithFrame:contentRect];
    [self addSubview:matchContentView];
    
    UIImage *videoImage = [UIImage imageNamed:@"icohome_videosmall_v5.png"];
    videoImageView = [[UIImageView alloc] initWithFrame:CGRectMake(CONTENT_LEFT + 3,0,videoImage.size.width, videoImage.size.height)];
    videoImageView.image = videoImage;
    videoImageView.bottom = bgImageView.bottom - 3;
    videoImageView.hidden = YES;
    videoImageView.alpha = themeImageAlphaValue();
    [self addSubview:videoImageView];
}

- (void)updateNewsContent {
    [super updateNewsContent];
    [self updateMatchContent];
}

- (void)updateMatchContent {
    matchContentView.hostTeamName = self.item.news.match.hostTeam;
    matchContentView.visitorTeamName = self.item.news.match.visitorTeam;
    matchContentView.hostTotal = self.item.news.match.hostTotal;
    matchContentView.visitorTotal = self.item.news.match.visitorTotal;
    matchContentView.matchName = @"";
    matchContentView.liveStatus = self.item.news.liveStatus;
    [matchContentView updateWithHostTeamUrl:self.item.news.match.hostIcon visitorTeamUrl:self.item.news.match.visitorIcon];
    [matchContentView setNeedsDisplay];
    [bgImageView loadImageWithUrl:self.item.news.picUrl
                     defaultImage:nil];
    //by 5.9.4 wangchuanwen modify
    //item间距调整 cellHeight
    bgImageView.top = self.item.titleHeight + 12;
    //modify end
    matchContentView.top = bgImageView.top;
    coverView.top = bgImageView.top;
    
    videoImageView.hidden = !self.item.hasVideo;
}

- (void)updateTheme {
    [super updateTheme];
    bgImageView.backgroundColor = [[SNThemeManager sharedThemeManager] currentThemeColorForKey:kThemeBg2Color];
    [matchContentView updateTheme];
    [matchContentView updateWithHostTeamUrl:self.item.news.match.hostIcon visitorTeamUrl:self.item.news.match.visitorIcon];
    videoImageView.alpha = themeImageAlphaValue();
}

- (void)updateImage {
    [bgImageView loadImageWithUrl:self.item.news.picUrl
                     defaultImage:nil];
    
    [matchContentView updateTheme];
    [matchContentView updateWithHostTeamUrl:self.item.news.match.hostIcon visitorTeamUrl:self.item.news.match.visitorIcon];
}

@end
