//
//  SNVideoAdMaskHelper.m
//  sohunews
//
//  Created by handy wang on 5/9/14.
//  Copyright (c) 2014 Sohu.com. All rights reserved.
//

#import "SNVideoAdMaskHelper.h"
#import "SNVideoAdMaskConst.h"
#import "WSMVVideoPlayerView.h"
#import "SNVideoAdContext.h"
#import "SNVideoAdDetailInfo.h"
#import "SNLiveRoomBannerVideoPlayerView.h"
#import "SNVideoAdMaskLiveBanner.h"
#import "SNVideoAd.h"

@implementation SNVideoAdMaskHelper

#pragma mark - Public
+ (void)showAdMaskInPlayer:(WSMVVideoPlayerView *)player withAdInfo:(id)adInfo {
    SNVideoAdContextCurrentVideoAdPosition adPosition = [[SNVideoAdContext sharedInstance] getCurrerntVideoAdPosition];
    SNVideoAdMaskType *maskType = SNVideoAdMaskType_Normal;
    switch (adPosition) {
        case SNVideoAdContextCurrentVideoAdPosition_Article: {
            maskType = SNVideoAdMaskType_Normal;
            break;
        }
        case SNVideoAdContextCurrentVideoAdPosition_VideoTimeline: {
            maskType = SNVideoAdMaskType_Normal;
            break;
        }
        case SNVideoAdContextCurrentVideoAdPosition_VideoDetail: {
            maskType = SNVideoAdMaskType_Normal;
            break;
        }
        case SNVideoAdContextCurrentVideoAdPosition_LiveBanner: {
            maskType = SNVideoAdMaskType_LiveBanner;
            break;
        }
        case SNVideoAdContextCurrentVideoAdPosition_Unknown: {
            maskType = SNVideoAdMaskType_Normal;
            break;
        }
    }
    
    //---Cache Ad Info------
    SNVideoAd *videoAd = [[SNVideoAd alloc] init];
    videoAd.duration = [player getMoviePlayer].advertDuration;
    player.playingVideoModel.videoAd = videoAd;
    //----------------------
    
    SNVideoAdMask *videoAdMask = (SNVideoAdMask *)[player viewWithTag:kVideoAdMaskTag];
    if (!videoAdMask) {
        videoAdMask = [SNVideoAdMask maskWithType:maskType];
        videoAdMask.tag = kVideoAdMaskTag;
        [player addSubview:videoAdMask];
    }
    [videoAdMask setUserInteractionEnabled:YES];
    videoAdMask.frame = player.bounds;
    
    SNVideoAdDetailInfo *videAdDetailInfo = [self parseVideoAdDetailInfo:adInfo];
    [videoAdMask setVideoAdDetailInfo:videAdDetailInfo];
    
    [videoAdMask maskWillAppearInVideoPlayer:player];
    [videoAdMask startCountdownInVideoPlayer:player];
}

+ (void)dismissMaskForPlayer:(WSMVVideoPlayerView *)player {
    UIView *subview = [player viewWithTag:kVideoAdMaskTag];
    if (!!subview && [subview isKindOfClass:[SNVideoAdMask class]]) {
        SNVideoAdMask *videoAdMask = (SNVideoAdMask *)subview;
        [videoAdMask stopCountdown];
        [videoAdMask resumeAppVolumeIfNeeded];
        [videoAdMask removeFromSuperview];
    }
}

+ (BOOL)doesTouchOnVideoAdMask:(UIView *)touchedView {
    BOOL rs = [touchedView isKindOfClass:[SNVideoAdMask class]];
    return rs;
}

+ (void)setShowFullscreenButton:(BOOL)show inVideoPlayer:(WSMVVideoPlayerView *)player {
    UIView *subview = [player viewWithTag:kVideoAdMaskTag];
    if (!!subview && [subview isKindOfClass:[SNVideoAdMask class]]) {
        SNVideoAdMask *videoAdMask = (SNVideoAdMask *)subview;
        [videoAdMask setShowFullscreenButton:show];
    }
}

+ (void)updateFullscreenButtonStateInVideoPlayer:(WSMVVideoPlayerView *)player {
    UIView *subview = [player viewWithTag:kVideoAdMaskTag];
    if (!!subview && [subview isKindOfClass:[SNVideoAdMask class]]) {
        SNVideoAdMask *videoAdMask = (SNVideoAdMask *)subview;
        [videoAdMask updateFullscreenButtonState:[player isFullScreen]];
    }
}

+ (void)expandLiveBannerPlayerMask:(SNLiveRoomBannerVideoPlayerView *)player {
    UIView *v = [player viewWithTag:kVideoAdMaskTag];
    if ([v isKindOfClass:[SNVideoAdMaskLiveBanner class]]) {
        SNVideoAdMaskLiveBanner *mask = (SNVideoAdMaskLiveBanner *)v;
        [mask setIsShrinked:NO];
    }
}

+ (void)shrinkLiveBannerPlayerMask:(SNLiveRoomBannerVideoPlayerView *)player {
    UIView *v = [player viewWithTag:kVideoAdMaskTag];
    if ([v isKindOfClass:[SNVideoAdMaskLiveBanner class]]) {
        SNVideoAdMaskLiveBanner *mask = (SNVideoAdMaskLiveBanner *)v;
        [mask setIsShrinked:YES];
    }
}

+ (BOOL)isAdPlayingInVideoPlayer:(WSMVVideoPlayerView *)player {
    if (!([player getMoviePlayer].isLoadAdvert)) {//没有广告
        return NO;
    }
    
    SHAdvertPlayState adPlayState = [player getMoviePlayer].advertCurrentPlayState;
    return (adPlayState == SHAdvertPlayStatePlaying);
}

#pragma mark - Private
/**
    videoAdDetailInfoString规则如下：
    iOS端 视频广告详情URL的各种情况及相应规则的确认：
    1)空串
        新闻客户端会不显示详情按钮（视频SDK和广告SDK方可无视），所以此种情况不会有跳转，
    2)以http://打头
        示例：http://tv.sohu.com/s2014/rgwan/
 
    3)以sv://打头，具体规则同Android
        示例：sv://action.cmd?action=3&url=http%3a%2f%2ftsingtao1903.ctharmony.com.cn%2fsohuapp_test%2f
            这个链接,sv这种协议是与投放后台约定好的，需解析出action的值，action=2代表用内置浏览器打开，action=3代表用外置浏览器打开。如果新闻准备都用内置浏览器打开就无需关心action的值，只需解析url对应的value就可以。上面的跳转链接是http%3a%2f%2ftsingtao1903.ctharmony.com.cn%2fsohuapp_test%2f
 
    4)以mediaplayer: 打头，后面跟URL
        示例：mediaplayer:http://xxx.com   去掉“mediaplayer:”后，再跳转至后面的“http://xxx.com”链接
 
    另，第4种情况推荐是以App外打开，第2、3情况在App内打开。
    以上各情况中包含的url都是真实的网页地址，而不是某个文件的下载地址。
 */
+ (SNVideoAdDetailInfo *)parseVideoAdDetailInfo:(NSString *)videoAdDetailInfoString {
    if (videoAdDetailInfoString.length <= 0) {
        return nil;
    }
    
    NSString *adDetailString = [videoAdDetailInfoString URLDecodedString];
    
    SNVideoAdDetailInfo *videoAdDetailInfo = [[SNVideoAdDetailInfo alloc] init];
    //if ([[adDetailString lowercaseString] startWith:@"http://"]) {
    if([SNAPI isWebURL:adDetailString]){
        videoAdDetailInfo.url = adDetailString;
        videoAdDetailInfo.isOpenInApp = YES;
    }
    else if ([[adDetailString lowercaseString] startWith:@"sv://"]) {
        NSRange tmpRange = [adDetailString rangeOfString:@"url="];
        NSString *url = [adDetailString substringFromIndex:(tmpRange.location+tmpRange.length)];
        videoAdDetailInfo.url = url;
        videoAdDetailInfo.isOpenInApp = YES;
    }
    else if ([[adDetailString lowercaseString] startWith:@"mediaplayer:"]) {
        videoAdDetailInfo.url = [adDetailString substringFromIndex:@"mediaplayer:".length];
        videoAdDetailInfo.isOpenInApp = NO;
    }
    return videoAdDetailInfo;
}

@end
