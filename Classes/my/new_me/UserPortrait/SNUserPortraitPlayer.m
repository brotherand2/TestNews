//
//  SNUserPortraitPlayer.m
//  sohunews
//
//  Created by wang shun on 2017/3/1.
//  Copyright © 2017年 Sohu.com. All rights reserved.
//

#import "SNUserPortraitPlayer.h"
#import <SVVideoForNews/SVVideoForNews.h>

@interface SNUserPortraitPlayer ()

@property (nonatomic,strong) SNVideoData* v_data;

@end

@implementation SNUserPortraitPlayer

- (id)initWithData:(NSDictionary *)data{
    if (self = [self initWithFrame:[UIScreen mainScreen].bounds andDelegate:self]) {
        self.videoWindowType = SNVideoWindowType_full;
        self.vplayer_info = data;

//        videoFullScreen://site2=0&playById=1&vid=222222&site=2&url=***&tvid=&posInfo={x:1,y:1,width:1,height:1}
//        NSString* pic  = @"http://images.sohu.com/saf/a2017/0228/ChAKr1i1KimAVQDIAADCVAkxwkw729656x370.jpg";
//        NSString* link = @"http://data.vod.itc.cn/?prod=rtb&new=/85/94/NCj4u9SWogvPxDlGR7XFFE.mp4";
        
        NSMutableDictionary* mDic = [NSMutableDictionary dictionaryWithDictionary:data];

        //TODO:
        SNVideoData* v_d  = [[SNVideoData alloc] initWithDict:mDic];
        SNVideoSiteInfo* info = [[SNVideoSiteInfo alloc] initWithDict:mDic];
        SNVideoUrl* v_url = [[SNVideoUrl alloc] initWithDict:mDic];

        v_d.siteInfo    = info;
        v_d.videoUrl    = v_url;
        
        self.v_data = v_d;
        
        self.supportSwitchVideoByLRGestureInNonFullscreenMode = NO;
        self.supportRelativeVideosViewInNonFullscreenMode = NO;
        self.videoPlayerRefer = WSMVVideoPlayerRefer_NewsArticle;
        
        [self initPlaylist:[NSArray arrayWithObject:self.v_data] initPlayingIndex:0];
        
    }
    return self;
}

- (id)initWithFrame:(CGRect)frame andDelegate:(id)delegate {
    if (self = [super initWithFrame:frame andDelegate:delegate]) {
        
    }
    return self;
}

- (void)playUserPortraitVideo{

    [super didTapPlayBtnInControlBarToPlay];
    [self toFullScreen];
}

- (SHMedia*)getSHMedia{
    SHMedia* shMedia = [[SHMedia alloc] init];
    
    shMedia.site = [self.v_data.siteInfo.site integerValue];
    shMedia.poid = @"16";
    shMedia.expandMemo = @{@"channeled":@"1300030002", @"type":@"1"};
    shMedia.vid = self.v_data.vid;
    shMedia.sourceType = 101;
    return shMedia;
}

- (void)exitFullScreen {
    [self stop];
    [self forceStop];
    
    [self.moviePlayer.view removeFromSuperview];
    [self removeFromSuperview];
    
    self.fullscreenWindow.hidden = YES;
    self.bottomWindow.hidden = YES;
}

- (void)videoToFullScreen {
    [self toFullScreen];
}


- (void)createFullScreenControllBar {
    if (!self.controlBarFullScreen) {
        CGRect _controlBarFrameFullScreen = CGRectMake(0, CGRectGetHeight(self.bounds) - (94.0f/2.0f), self.bounds.size.width, (94.0f/2.0f));
        self.controlBarFullScreen = [[WSMVVideoControlBar_FullScreen alloc] initWithFrame:_controlBarFrameFullScreen];
        self.controlBarFullScreen.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleTopMargin;
        self.controlBarFullScreen.delegate = self;
        self.controlBarFullScreen.alpha = 0;

        [self.controlBarFullScreen.fullscreenBtn setImage:[UIImage themeImageNamed:@"icovideo_close_v5_hl.png"] forState:UIControlStateHighlighted];
        [self.controlBarFullScreen.fullscreenBtn setImage:[UIImage themeImageNamed:@"icovideo_close_v5.png"] forState:UIControlStateNormal];
        
        [self addSubview:self.controlBarFullScreen];
    }
}



/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
