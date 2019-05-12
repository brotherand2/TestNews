//
//  SNRollingSohuFeedBigPicCell.m
//  sohunews
//
//  Created by wangyy on 2017/5/3.
//  Copyright © 2017年 Sohu.com. All rights reserved.
//

#import "SNRollingSohuFeedBigPicCell.h"
#import "SNImageView.h"

#define kPhotoImageRate     9 / 16
#define kPlayImageHeight    46
#define kPlayImageTag       100001
#define kQFLiveIconTag      100002

@interface SNRollingSohuFeedBigPicCell ()
@property (nonatomic, strong) SNImageView *cellImageView;
@end

@implementation SNRollingSohuFeedBigPicCell
@synthesize cellImageView = _cellImageView;

+ (CGFloat)tableView:(UITableView *)tableView
  rowHeightForObject:(id)object {
    CGFloat cellHeight = [super tableView:tableView rowHeightForObject:object];
    //by 5.9.4 wangchuanwen modify
    //item间距调整 cellHeight
    return cellHeight + [[self class] getImageWidth] * kPhotoImageRate + SOHUFEEDCELL_ITEM_HEIGHT + 4;
    //modify end
}

+ (CGFloat)getImageWidth {
    return kAppScreenWidth - CONTENT_LEFT * 2;
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)identifier {
    self = [super initWithStyle:style reuseIdentifier:identifier];
    if (self) {
        int imageWidth = [[self class] getImageWidth];
        int imageHeight = imageWidth * kPhotoImageRate;
        self.cellImageView = [[SNImageView alloc] initWithFrame:CGRectMake(CONTENT_LEFT, FEED_CONTENT_IMAGE_TOP, imageWidth, imageHeight)];
        
        UIImageView *playImage = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, kPlayImageHeight, kPlayImageHeight)];
        playImage.tag = kPlayImageTag;
        [playImage setImage:[UIImage imageNamed:@"timeline_videoplay_poster_play_btn.png"]];
        playImage.hidden = YES;
        playImage.center = CGPointMake(self.cellImageView.width / 2, self.cellImageView.height / 2);
        [self.cellImageView addSubview:playImage];
        
        UIImage *qfImage = [UIImage imageNamed:@"icon-direct_seeding-day.png"];
        UIImageView *qfLiveImage = [[UIImageView alloc] initWithFrame:CGRectMake(7, 8, qfImage.size.width, qfImage.size.height)];
        qfLiveImage.tag = kQFLiveIconTag;
        [qfLiveImage setImage:qfImage];
        qfLiveImage.hidden = YES;
        [self.cellImageView addSubview:qfLiveImage];
        
        [self addSubview:self.cellImageView];
    }
    return self;
}

- (void)updateContentView{
    [super updateContentView];
    [self updateImage];
}

- (void)updateImage {
    //by 5.9.4 wangchuanwen modify
    //item间距调整 _cellImageView.top
    _cellImageView.top = FEED_CONTENT_IMAGE_TOP + self.item.titleHeight + ((self.item.titleHeight == 0) ? 5 : FEED_SPACEVALUE - [SNRollingSohuFeedCell feedLineSpace:self.item]) + 3;
    //modify end
    [_cellImageView loadImageWithUrl:self.item.news.picUrl defaultImage:[UIImage imageNamed:@"defaultImageBg.png"]];
    _cellImageView.alpha = themeImageAlphaValue();
    
    UIImageView *playImage = [self.cellImageView viewWithTag:kPlayImageTag];
    UIImageView *qfLiveImage = [self.cellImageView viewWithTag:kQFLiveIconTag];
    if ([self.item.news isSohuFeedVideo]) {
        //视频
        playImage.hidden = NO;
        qfLiveImage.hidden = YES;
    } else if ([self.item.news isSohuFeedLive]) {
        //千帆直播
        playImage.hidden = NO;
        qfLiveImage.hidden = NO;
    } else {
        //图文
        playImage.hidden = YES;
        qfLiveImage.hidden = YES;
    }
}

- (void)updateTheme {
    [super updateTheme];
    _cellImageView.alpha = themeImageAlphaValue();
    [_cellImageView updateDefaultImage:[UIImage themeImageNamed:@"defaultImageBg.png"]];
    
    //视频
    if ([self.item.news isSohuFeedVideo]) {
        UIImageView *playImage = [self.cellImageView viewWithTag:kPlayImageTag];
        [playImage setImage:[UIImage imageNamed:@"timeline_videoplay_poster_play_btn.png"]];
    }
    
    //千帆直播
    if ([self.item.news isSohuFeedLive]) {
        UIImageView *playImage = [self.cellImageView viewWithTag:kPlayImageTag];
        [playImage setImage:[UIImage imageNamed:@"timeline_videoplay_poster_play_btn.png"]];
        
        UIImageView *qfLiveImage = [self.cellImageView viewWithTag:kQFLiveIconTag];
        [qfLiveImage setImage:[UIImage imageNamed:@"icon-direct_seeding-day.png"]];
    }
}

@end
