//
//  SNCorpusVideoCell.m
//  sohunews
//
//  Created by cuiliangliang on 16/5/9.
//  Copyright © 2016年 Sohu.com. All rights reserved.
//

#import "SNCorpusVideoCell.h"
#import "SNTimelineVideoCellContentView.h"
#import "SNVideoAdContext.h"
#import "SNRollingNewsTitleCell.h"
#import <MediaPlayer/MediaPlayer.h>
#import "WSMVLoadingView.h"
#import "SNNewsAd+analytics.h"
#import "WSMVVideoPlayerView.h"
#import "SNTimelineSharedVideoPlayerView.h"
#import "SNImageView.h"
#import "UIFont+Theme.h"

@interface SNCorpusVideoCell ()<SNTimelineVideoCellContentViewDelegate>{

    
    SNTimelineVideoCellContentView *cellContentView;
    SNVideoData *playerData;
    SNNewsVideoInfo *video;
    UILabel *timelabel;
    UILabel *titleLabel;
    UILabel *playNumLabel;
    UIImageView *playNumImageView;
    BOOL _isEditMode;
}

@end


@implementation SNCorpusVideoCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier withDic:(NSDictionary*)newsItemDict{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        
        NSString *title = [newsItemDict objectForKey:kSNTitle];
        float titleH = [[self class] getTitleHeightWithTitle:title];
        
        self.frame = CGRectMake(self.frame.origin.x, self.frame.origin.y, kAppScreenWidth, titleH + 9 + VIDEO_CELL_PLAYERHEIGHT + 30);
        [self initSelectButton];
        
        if (!titleLabel) {
            titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(CONTENT_LEFT,3, 80, 20)];
            titleLabel.textColor = [[SNThemeManager sharedThemeManager] currentThemeColorForKey:kThemeText2Color];
            titleLabel.backgroundColor = [UIColor clearColor];
            titleLabel.font =  [UIFont systemFontOfSizeType:UIFontSizeTypeD];
            titleLabel.textAlignment = NSTextAlignmentLeft;
            titleLabel.frame = CGRectMake(CONTENT_LEFT,3,[[self class] getTitleWidth], [[self class] getTitleHeightWithTitle:title]);
            titleLabel.text = title;
            [self addSubview:titleLabel];
        }
         CGRect cellContentViewFrame = CGRectMake(CONTENT_LEFT, titleH+6, FOCUS_IMAGE_WIDTH, VIDEO_CELL_PLAYERHEIGHT);
        if (!cellContentView) {
            cellContentView = [[SNTimelineVideoCellContentView alloc] initWithFrame:cellContentViewFrame];
            cellContentView.delegate = self;
            cellContentView.frame = CGRectMake(CONTENT_LEFT, titleLabel.frame.size.height, FOCUS_IMAGE_WIDTH, VIDEO_CELL_PLAYERHEIGHT);
            
            [self addSubview:cellContentView];
        }
        [cellContentView resetPlayerViewFrame:cellContentViewFrame hiddenBottom:YES];
        
        
        NSString *linkString = [newsItemDict objectForKey:@"tvUrl"];
        NSString *vid = [newsItemDict objectForKey:@"vid"];
        NSString *tvPlayTime = [newsItemDict stringValueForKey:@"tvPlayTime" defaultValue:nil];
        NSString *tvPlayNum = [newsItemDict stringValueForKey:@"tvPlayNum" defaultValue:nil];
        [SNTimelineSharedVideoPlayerView fakeStop];
        if(nil == playerData){
            playerData = [[SNVideoData alloc] init];
        }
        NSArray *urlarray =[newsItemDict objectForKey:kSNCorpusImageUrl];
        if (urlarray && urlarray.count > 0) {
            playerData.poster = [urlarray objectAtIndex:0];
            playerData.poster_4_3  = [urlarray objectAtIndex:0];
        }
        playerData.vid = vid;
        playerData.videoUrl = [[SNVideoUrl alloc] init];
        playerData.isNewsVideo = YES;
        
        if([linkString hasSuffix:@"mp4"]){
            playerData.videoUrl.mp4 = linkString;
        }else{
            playerData.videoUrl.m3u8 = linkString;
        }
        
        [cellContentView setObject:playerData];

        if (!timelabel) {
            timelabel = [[UILabel alloc] initWithFrame:CGRectMake(cellContentView.frame.size.width-95,cellContentView.frame.size.height-20, 80, 20)];
            timelabel.textColor = [UIColor whiteColor];
            timelabel.backgroundColor = [UIColor clearColor];
            timelabel.hidden = YES;
            timelabel.font =  [UIFont systemFontOfSizeType:UIFontSizeTypeD];
            timelabel.textAlignment = NSTextAlignmentRight;
            [self addSubview:timelabel];
        }
        

        if (!playNumImageView) {
            playNumImageView = [[UIImageView alloc] init];
            playNumImageView.image =[UIImage themeImageNamed:@"icohome_videoviews_v5.png"];
            playNumImageView.frame = CGRectMake(CONTENT_LEFT, self.frame.size.height-20, 11, 11);
            [self addSubview:playNumImageView];
        }
        
        if (!playNumLabel) {
            playNumLabel = [[UILabel alloc] initWithFrame:CGRectMake(CONTENT_LEFT+19,self.frame.size.height-25, 80, 20)];
            playNumLabel.textColor = [[SNThemeManager sharedThemeManager] currentThemeColorForKey:kThemeText6Color];
            playNumLabel.backgroundColor = [UIColor clearColor];
            playNumLabel.font =  [UIFont systemFontOfSizeType:UIFontSizeTypeB];
            playNumLabel.textAlignment = NSTextAlignmentLeft;
            [self addSubview:playNumLabel];
        }
        playNumLabel.text = [self getTvPlayNum:tvPlayNum];
        
        if (tvPlayTime&& tvPlayTime.length > 0) {
            timelabel.text = [self stringToTime:tvPlayTime];
            timelabel.hidden = NO;
        }
        
    }
    return self;
}


- (NSString *)getTvPlayNum:(NSString*)tvPlayNum
{
    NSString *tvnumString = @"";
    if (tvPlayNum && tvPlayNum.length >0) {
        if ([tvPlayNum intValue] > 1000000) {
            tvnumString = [NSString stringWithFormat:@"%.0f万",[tvPlayNum intValue]/10000.0f];
        } else if ([tvPlayNum intValue] > 10000) {
            tvnumString = [NSString stringWithFormat:@"%.1f万",[tvPlayNum intValue]/10000.0f];
            tvnumString = [tvnumString stringByReplacingOccurrencesOfString:@".0" withString:@""];
        }else {
            tvnumString = tvPlayNum;
            tvnumString = [tvnumString isEqualToString:@"0"] ? @"" : tvnumString;
        }
    }
    return tvnumString;
}

+ (int)getTitleWidth
{
    int titleWidth = kAppScreenWidth - 2*CONTENT_LEFT;
    return titleWidth;
}
+ (BOOL)isMultiLineTitleWithTitle:(NSString*)title
{
    int titleWidth = [[self class] getTitleWidth];
    UIFont *titleFont = [SNUtility getNewsTitleFont];
    if (title && ![title isEqualToString:@""]) {
        CGSize titleSize = [title sizeWithFont:titleFont];
        if (titleSize.width > titleWidth) {
            return YES;
        }
    }
    return NO;
}
+ (int)getTitleHeightWithTitle:(NSString*)title
{
    int titleHeight;
    CGRect sizeRect;
    int titleWidth = [[self class] getTitleWidth];
    UIFont *titleFont = [SNUtility getNewsTitleFont];
    if (title && ![title isEqualToString:@""]) {
        sizeRect = [title boundingRectWithSize:CGSizeMake(titleWidth, CGFLOAT_MAX) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:titleFont} context:nil];
        if (sizeRect.size.height > 40 ) {
            return 40;
        }else{
            return sizeRect.size.height;
        }
    }
    return 20;
}

- (void)setCellInfoWithDic:(NSDictionary*)newsItemDict isEditMode:(BOOL)isEditMode  isItemSelected:(BOOL)isItemSelected{
    NSString *title = [newsItemDict objectForKey:kSNTitle];
    titleLabel.frame = CGRectMake(CONTENT_LEFT,0,[[self class] getTitleWidth], [[self class] getTitleHeightWithTitle:title]);
    titleLabel.text = title;
    cellContentView.frame = CGRectMake(CONTENT_LEFT, titleLabel.frame.size.height, FOCUS_IMAGE_WIDTH, VIDEO_CELL_PLAYERHEIGHT);
    _selectButton.selected = isItemSelected;
    NSString *linkString = [newsItemDict objectForKey:kLink];
    NSString *tvPlayTime = [newsItemDict stringValueForKey:@"tvPlayTime" defaultValue:nil];
    if(nil != playerData){
        [cellContentView resetPlayerViewFrame:CGRectMake(CONTENT_LEFT, titleLabel.frame.size.height+8, FOCUS_IMAGE_WIDTH, VIDEO_CELL_PLAYERHEIGHT/*VIDEO_CELL_HEIGHT - CONTENT_IMAGE_TOP - moreButton.frame.size.height*/) hiddenBottom:YES];
        
        if([cellContentView isPaused]){
            return;
        }
    }

    [SNTimelineSharedVideoPlayerView fakeStop];
    if(nil == playerData){
        playerData = [[SNVideoData alloc] init];
    }
//    playerData.poster = self.item.news.picUrl;
//    playerData.poster_4_3  = self.item.news.picUrl;
//    playerData.vid = self.item.news.playVid;
    playerData.videoUrl = [[SNVideoUrl alloc] init];
    
    if([linkString hasSuffix:@"mp4"]){
        playerData.videoUrl.mp4 = linkString;
    }else{
        playerData.videoUrl.m3u8 = linkString;
    }
    
    [cellContentView setObject:playerData];
    
    if (tvPlayTime&& tvPlayTime.length > 0) {
        timelabel.text = [self stringToTime:tvPlayTime];
        timelabel.hidden = NO;
    }
    _isEditMode = isEditMode;
    if (_isEditMode) {
        [self setEditMode];
    }
    else {
        [self setNormalMode];
    }
    _selectButton.selected = isItemSelected;
}

- (void)setEditMode {
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    _selectButton.centerY = self.height/2.f;
    cellContentView.userInteractionEnabled = NO;
    [cellContentView pause];
    _selectButton.left = kSelectButtonLeftDistance;
    cellContentView.left = _selectButton.right + kSelectButtonLeftDistance;
    titleLabel.left = _selectButton.right + kSelectButtonLeftDistance;
    playNumImageView.left = _selectButton.right + kSelectButtonLeftDistance;
    playNumLabel.left = playNumImageView.right + kSelectButtonLeftDistance;
    [SNTimelineSharedVideoPlayerView sharedInstance].left = _selectButton.right + kSelectButtonLeftDistance;
}

- (void)setNormalMode {
    self.selectionStyle = UITableViewCellSelectionStyleDefault;
    _selectButton.centerY = self.height/2.f;
    [UIView animateWithDuration:kCellAnimationDuration animations:^(void){
        _selectButton.right = 0;
        cellContentView.left = CONTENT_LEFT;
        titleLabel.left = CONTENT_LEFT;
        playNumLabel.left = CONTENT_LEFT+19;
        playNumImageView.left  = CONTENT_LEFT;
        [SNTimelineSharedVideoPlayerView sharedInstance].left = CONTENT_LEFT;
        //        _titleLabel.width = kAppScreenWidth - 2*CONTENT_LEFT;
    } completion:^(BOOL finished){
        cellContentView.userInteractionEnabled = YES;
    }];
}


-(NSString*)stringToTime:(NSString*)time{
    if (time) {
        NSInteger _time = [time integerValue];
        NSInteger s=0,m=0,h=0;
        
        s = _time%60;
        
        if (_time >= 60) {
            
            m = (_time/60)%60;
            
            if (_time/60 >= 60) {
                
                h = (_time/60)/60;
                
            }
        }
        if (h > 0) {
            return [NSString stringWithFormat:@"%02d:%02d:%02d",h,m,s];
        }
        return [NSString stringWithFormat:@"%02d:%02d",m,s];
    }
    return nil;
}

#pragma mark - 屏幕旋转
#pragma mark - Private
#pragma mark - Rotation
- (void)beginMonitorDeviceOrientationChange {
    UIDevice *device = [UIDevice currentDevice]; //Get the device object
    [device beginGeneratingDeviceOrientationNotifications]; //Tell it to start monitoring the accelerometer for orientation
    [SNNotificationManager addObserver:self//Add self as an observer
                                             selector:@selector(orientationChanged:)
                                                 name:UIDeviceOrientationDidChangeNotification
                                               object:device];
}

- (void)endMonitorDeviceOrientationChange {
    UIDevice *device = [UIDevice currentDevice];
    [SNNotificationManager removeObserver:self name:UIDeviceOrientationDidChangeNotification object:device];
    [device endGeneratingDeviceOrientationNotifications];
}

- (void)orientationChanged:(NSNotification *)notification {
    //是否要响应旋转
    //---
    id obj = notification.object;
    if ([obj isKindOfClass:[UIDevice class]]) {
        UIDeviceOrientation o = [(UIDevice *)obj orientation];
        switch (o) {
            case UIDeviceOrientationPortrait: {
                NSLogError(@"##################Vertically, home button bottom");
                break;
            }
            case UIDeviceOrientationPortraitUpsideDown: {
                NSLogError(@"##################Vertically, home button top");
                break;
            }
            case UIDeviceOrientationLandscapeLeft: {
                NSLogError(@"##################Horizontally, home button right");
                break;
            }
            case UIDeviceOrientationLandscapeRight: {
                NSLogError(@"##################Horizontally, home button left");
                break;
            }
            default:
                break;
        }
        
        //没有播放则不能自动全屏
        BOOL isStopped = !([SNTimelineSharedVideoPlayerView sharedInstance].playingVideoModel);
        if (isStopped) {
            SNDebugLog(@"Neednt rotate, player view is stopped.");
            return;
        }
        
        //已转为横屏：
        if ((o == UIDeviceOrientationLandscapeLeft || o == UIDeviceOrientationLandscapeRight)
            && ![cellContentView isFullScreen]
            && ([cellContentView isPlaying] || [cellContentView isPaused] || [cellContentView isLoading])) {
            [cellContentView videoToFullScreen];
        }
        
        //已转为竖屏：如果当前是全屏，则变为竖屏时则自动恢复到非全屏
        if ((o == UIDeviceOrientationPortrait || o == UIDeviceOrientationPortraitUpsideDown)
            && [cellContentView isFullScreen]) {
            [cellContentView videoExitFullScreen];
        }
    }
}

- (void)fullScreenMode
{
    if([cellContentView isPaused] || [cellContentView isPlaying] || [cellContentView isLoading]){
        [cellContentView videoToFullScreen];
    }else {
        [cellContentView fullscreenAction:nil];
        //广告点击曝光
        //        if (self.item.type == NEWS_ITEM_TYPE_AD) {
        //            [self.item.news.newsAd reportAdClick:self.item.news];
        //        }
    }
}


- (void)autoPlayInWifi{
    BOOL isWifi = ((![SNUtility isNetworkWWANReachable]) && [SNUtility isNetworkReachable]);
    if (isWifi) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, NSEC_PER_MSEC * 500), dispatch_get_main_queue(), ^{
            
            [cellContentView playVideoManually];
            
        });
        MPMusicPlayerController *mpc = [MPMusicPlayerController applicationMusicPlayer];
        mpc.volume = 0;
        
    }
}
- (void)fullScreenEnjoy {
    [self fullScreenMode];
}


@end
