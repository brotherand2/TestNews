//
//  SNRollingNewsSohuLiveCell.m
//  sohunews
//
//  Created by wangyy on 16/6/15.
//  Copyright © 2016年 Sohu.com. All rights reserved.
//

#import "SNRollingNewsSohuLiveCell.h"
#import "UIFont+Theme.h"

@interface SNRollingNewsSohuLiveCell ()
@property (nonatomic, strong) UIImageView *liveImage;
@property (nonatomic, strong) UILabel *onLineCount;
@property (nonatomic, strong) UILabel *showTime;
@property (nonatomic, strong) UILabel *liveStatus;
@end

@implementation SNRollingNewsSohuLiveCell
@synthesize liveImage = _liveImage;
@synthesize onLineCount = _onLineCount;
@synthesize showTime = _showTime;
@synthesize liveStatus = _liveStatus;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)identifier {
    self = [super initWithStyle:style reuseIdentifier:identifier];
    if (self) {
        [self InitLiveImage];
        [self InitOnLineInfo];
        [self InitNickName];
        [self InitLiveStatus];
    }
    return self;
}

- (void)InitLiveImage {
    UIImage *image = [UIImage themeImageNamed:@"qf_live_ios.png"];
    self.liveImage = [[UIImageView alloc] initWithFrame:CGRectMake(self.cellImageView.right - image.size.width - 4, self.cellImageView.top + 4, image.size.width, image.size.height)];
    [self.liveImage setImage:[UIImage themeImageNamed:@"qf_live_ios.png"]];
    self.liveImage.backgroundColor = [UIColor clearColor];
    [self addSubview:self.liveImage];
}

- (void)InitOnLineInfo {
    self.onLineCount = [[UILabel alloc] initWithFrame:CGRectZero];
    self.onLineCount.backgroundColor = [UIColor clearColor];
    self.onLineCount.textColor = SNUICOLOR(kThemeText3Color);
    self.onLineCount.font = [UIFont systemFontOfSizeType:UIFontSizeTypeB];
    [self addSubview:self.onLineCount];
}

- (void)InitNickName {
//    self.nickName = [[UILabel alloc] initWithFrame:CGRectZero];
//    self.nickName.backgroundColor = [UIColor clearColor];
//    self.nickName.textColor = SNUICOLOR(kThemeText3Color);
////    self.nickName.text = @"搜狐邱先生";
//    self.nickName.font = [UIFont systemFontOfSizeType:UIFontSizeTypeB];
//    [self addSubview:self.nickName];
}

- (void)InitLiveStatus {
    self.showTime = [[UILabel alloc] initWithFrame:CGRectZero];
    self.showTime.backgroundColor = [UIColor clearColor];
    self.showTime.textColor = SNUICOLOR(kThemeText3Color);
    self.showTime.font = [UIFont systemFontOfSizeType:UIFontSizeTypeB];
    [self addSubview:self.showTime];
    
    self.liveStatus = [[UILabel alloc] initWithFrame:CGRectZero];
    self.liveStatus.backgroundColor = [UIColor clearColor];
    self.liveStatus.textColor = SNUICOLOR(kThemeRed1Color);
    self.liveStatus.font = [UIFont systemFontOfSizeType:UIFontSizeTypeB];
    [self addSubview:self.liveStatus];
}

- (void)updateImage {
    self.cellImageView.hidden = [self.item hasImage] ? NO : YES;
    [self.cellImageView updateImageWithUrl:self.item.news.picUrl
                              defaultImage:[UIImage themeImageNamed:kThemeImgPlaceholder3]
                                 showVideo:NO];
    [self.cellImageView updateTheme];
    
    CGRect imageViewRect = CGRectMake(CONTENT_LEFT, IMAGE_TOP, CELL_IMAGE_WIDTH, CELL_IMAGE_HEIGHT);
    self.cellImageView.frame = imageViewRect;
    [self.cellImageView layOutVideoImageView];
    
    self.liveImage.left = self.cellImageView.right - self.liveImage.size.width - 4;
}

- (void)updateNewsContent {
    [super updateNewsContent];
    
    UIFont *textFont = [UIFont systemFontOfSizeType:UIFontSizeTypeB];
    NSString *countStr = [NSString stringWithFormat:@"%d人在线",self.item.news.sohuLive.liveCount];
    if (self.item.news.sohuLive.liveCount >= 10000) {
        countStr = [NSString stringWithFormat:@"%.1f万人在线",self.item.news.sohuLive.liveCount/10000.0];
    }
    CGSize textSize = [countStr sizeWithFont:textFont];

    float markText_y = self.cellImageView.size.height - ICON_HEIGHT + 10 ;
    CGFloat markText_x = TITLE_LEFT;
    //by 5.9.4 wangchuanwen modify
    if (self.item.titlelineCnt > 2) {
        markText_y += 5 + textSize.height;
        markText_x = CONTENT_LEFT;
    } else {
        markText_y += ([SNDevice sharedInstance].isMoreThan320 ? 2 : 4);//图文图片高度改变
    }
    //modify end
    
    self.onLineCount.frame = CGRectMake(markText_x, markText_y, textSize.width, textSize.height);
    self.onLineCount.text = countStr;
    
    NSString *statusStr = @"";
    switch (self.item.news.sohuLive.liveStatus) {
        case 0:
            statusStr = @"即将开始";
            break;
        case 1:
            statusStr = @"直播中";
            break;
        case 2:
            statusStr = @"即将开始";
            break;
        default:
            break;
    }
    
    textSize = [statusStr sizeWithFont:textFont];
    CGFloat xValue = kAppScreenWidth - 14 - textSize.width;
    self.liveStatus.frame = CGRectMake(xValue, self.onLineCount.top, textSize.width, textSize.height);
    self.liveStatus.text = statusStr;
    
    if (self.item.news.sohuLive.liveStatus != 1) {
        NSString *timeStr = self.item.news.sohuLive.showTime;
        textSize = [timeStr sizeWithFont:textFont];
        self.showTime.frame = CGRectMake(self.liveStatus.left - 14 - textSize.width, self.liveStatus.top, textSize.width, textSize.height);
        self.showTime.text = timeStr;
    }
}

- (void)openNews {
    [SNUtility shouldUseSpreadAnimation:YES];
    NSArray *channelList = [[SNDBManager currentDataBase] getNewsChannelList];
    if ([channelList count] > 0) {
        //若已选区最后一个位置，则禁止千帆横屏，避免页面错乱
        NSMutableArray *subedArray = [NSMutableArray arrayWithCapacity:0];
        for (NewsChannelItem *channelItem in channelList) {
            if ([channelItem.isChannelSubed isEqualToString:@"1"]) {
                [subedArray addObject:channelItem];
            }
        }
        NewsChannelItem *subedChannelItem = [subedArray lastObject];
        if ([subedChannelItem.channelId isEqualToString:self.item.news.channelId]) {
            [SNRollingNewsPublicManager sharedInstance].banScreenLandScape = YES;
        } else {
            [SNRollingNewsPublicManager sharedInstance].banScreenLandScape = NO;
        }
    }
    
    [SNUtility openProtocolUrl:self.item.news.link];
    [[SNUtility sharedUtility] setLastOpenUrl:nil];
    
    NSString *newsId = self.item.news.newsId;
    NSString *channel = self.item.news.channelId;
    if (channel != nil && newsId != nil) {
        [SNRollingNewsPublicManager saveReadNewsWithNewsId:newsId ChannelId:channel];
    }
    //内存已读
    self.item.news.isRead = YES;
    [self setReadStyleByMemory];
}

- (void)updateTheme {
    [super updateTheme];
    
    [self.liveImage setImage:[UIImage themeImageNamed:@"qf_live_ios.png"]];
    self.onLineCount.textColor = SNUICOLOR(kThemeText3Color);
    self.showTime.textColor = SNUICOLOR(kThemeText3Color);
    self.liveStatus.textColor = SNUICOLOR(kThemeRed1Color);
}

@end
