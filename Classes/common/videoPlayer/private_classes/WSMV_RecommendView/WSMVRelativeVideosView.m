//
//  WSMVRelativeVideosView.m
//  sohunews
//
//  Created by handy wang on 10/26/13.
//  Copyright (c) 2013 Sohu.com. All rights reserved.
//  视频新闻非全屏播放时，显示的相关九宫格视频
//

#import "WSMVRelativeVideosView.h"
#import "WSMVLoadingView.h"
#import "SNVideoObjects.h"
#import "UIViewAdditions+WSMV.h"
#import "SHADConfigs.h"

#define kMaxRowsPerPage                     (2)
#define kMaxItemsPerRow                     ((kAppScreenWidth >= 414)?(4):(3))
#define kMaxItemsPerPage                    (kMaxRowsPerPage*kMaxItemsPerRow)

#define kRelativeVideosViewTitleLabelHeight                             (56.0f/2.0f)//(62.0f/2.0f)
#define kRelativeVideosViewTitleLabelFontSize                           (22.0f/2.0f)

#define kPageControlHeight                                              (56.0f/2.0f)

#define kMarginLeftToScrollViewLeftBorder   (48/2.0f)
#define kMarginLeftToScrollViewRightBorder  (48/2.0f)

#define kMarginTopToScrollViewTopBorder         ((kAppScreenWidth >= 414)?(120.0f/2.0f):((kAppScreenWidth >= 375)?(100.0f/2.0f):(56.0f/2.0f)))//(56.0f/2.0f)
#define kMarginBottomToScrollViewBottomBorder   ((kAppScreenWidth >= 414)?(120.0f/2.0f):((kAppScreenWidth >= 375)?(100.0f/2.0f):(56.0f/2.0f)))//(56.0f/2.0f)

#define kThumbnailViewWidth                 (154.0f/2.0f)
#define kThumbnailViewHeight                (158.0f/2.0f)
#define kThumbnailImageViewHeight           (110.0f/2.0f)

#define kVideoIconWidth                     (26.0f/2.0f)
#define kVideoIconHeight                    (26.0f/2.0f)

#define kTitleLabelHeight                   (48.0f/2.0f)

#define kWillPlayLoadingViewWidth           (50/2.0f)
#define kWillPlayLoadingViewHeight          (50/2.0f)
#define kWillPlayLoadingViewMarginTop       (18/2.0f)

#define kWillPlayMsgLabelPaddingTop         (10/2.0f)
#define kWillPlayMsgLabelHeight             (20/2.0f)
#define kWillPlayMsgLabelFontSize           (18/2.0f)

#define kWillPlayVideoTitle                 (@"即将播放")

@interface WSMVRelativeVideosThumbnailWillPlayIndicator()
@property (nonatomic, strong)WSMVLoadingView *loadingView;
@property (nonatomic, strong)UILabel         *msgLabel;
@property (nonatomic, strong)UIButton        *pauseBtn;
@end

@implementation WSMVRelativeVideosThumbnailWillPlayIndicator
#pragma mark - Lifecycle
- (id)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        self.userInteractionEnabled = YES;//Indicator挡事件为了loading过程中点indicator不触发切换视频
        self.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.6];
        
        //Loading
        CGRect _loadingViewFrame = CGRectMake((self.width-kWillPlayLoadingViewWidth)/2.0f,
                                              kWillPlayLoadingViewMarginTop,
                                              kWillPlayLoadingViewWidth,
                                              kWillPlayLoadingViewHeight);
        self.loadingView = [[WSMVLoadingView alloc] initWithFrame:_loadingViewFrame];
        [self addSubview:self.loadingView];
        self.hidden = self.loadingView.hidden;
        
        //Message label
        self.msgLabel = [[UILabel alloc] initWithFrame:CGRectMake(0,
                                                                  self.loadingView.bottom+kWillPlayMsgLabelPaddingTop,
                                                                  self.width,
                                                                  kWillPlayMsgLabelHeight)];
        self.msgLabel.backgroundColor = [UIColor clearColor];
        self.msgLabel.textAlignment = NSTextAlignmentCenter;
        self.msgLabel.text = kWillPlayVideoTitle;
        self.msgLabel.textColor = [UIColor colorFromString:@"#F8F8F8"];
        self.msgLabel.font = [UIFont systemFontOfSize:kWillPlayMsgLabelFontSize];
        [self addSubview:self.msgLabel];
        
        //Pause button
        self.pauseBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [self.pauseBtn addTarget:self action:@selector(sendNotificationOfCancelAutoPlayRelativeVideos) forControlEvents:UIControlEventTouchUpInside];
        [self.pauseBtn setImage:[UIImage imageNamed:@"wsmv_pause_btn.png"] forState:UIControlStateNormal];
        self.pauseBtn.size = CGSizeMake(kWillPlayLoadingViewWidth, kWillPlayLoadingViewHeight);
        self.pauseBtn.center = self.loadingView.center;
        [self addSubview:self.pauseBtn];
        [self.pauseBtn setImageEdgeInsets:UIEdgeInsetsMake(5, 5, 5, 5)];
    }
    return self;
}


#pragma mark - Public 
- (void)updateToWillPlayUI {
    [self.loadingView startAnimation];
    self.hidden = self.loadingView.hidden;
}

- (void)resetToNormalUI {
    [self.loadingView stopAnimation];
    self.hidden = self.loadingView.hidden;
}

#pragma mark - Private
- (void)sendNotificationOfCancelAutoPlayRelativeVideos {
    [SNNotificationManager postNotificationName:kCancelAutoPlayRelativeVideosNotification object:nil];
}

@end

////////////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////////////

@interface WSMVRelativeVideoThumbnailView()
@property (nonatomic, strong)SNVideoData *video;
@property (nonatomic, strong)UIImageView *bgImageView;
@property (nonatomic, strong)UIImageView *logoImageView;
@property (nonatomic, strong)UIImageView *posterImageView;
@property (nonatomic, strong)UILabel     *titleLabel;
@property (nonatomic, strong)UIImageView *videoIcon;
@property (nonatomic, strong)WSMVRelativeVideosThumbnailWillPlayIndicator *willPlayIndicator;
@end

@implementation WSMVRelativeVideoThumbnailView
- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        
        self.bgImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, self.width, kThumbnailImageViewHeight)];
        self.bgImageView.contentMode = UIViewContentModeScaleAspectFit;
        self.bgImageView.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
        self.bgImageView.backgroundColor = [UIColor colorFromString:@"#333333"];
        self.bgImageView.userInteractionEnabled = NO;
        [self addSubview:self.bgImageView];
        
        CGFloat _rate = 0.7;
        CGFloat _logoImageViewWidth     = self.bgImageView.width*_rate;
        CGFloat _logoImageViewHeight    = self.bgImageView.height*_rate;
        CGFloat _logoImageViewLeft      = (self.bgImageView.width*(1-_rate))/2.0f;
        CGFloat _logoImageViewTop       = (self.bgImageView.height*(1-_rate))/2.0f;
        self.logoImageView = [[UIImageView alloc] initWithFrame:CGRectMake(_logoImageViewLeft,
                                                                            _logoImageViewTop,
                                                                            _logoImageViewWidth,
                                                                            _logoImageViewHeight)];
        self.logoImageView.contentMode = UIViewContentModeScaleAspectFit;
        self.logoImageView.image = [UIImage themeImageNamed:@"app_logo_gray.png"];
        [self addSubview:self.logoImageView];
        
        self.posterImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, self.width, kThumbnailImageViewHeight)];
        self.posterImageView.contentMode = UIViewContentModeScaleAspectFill;
        self.posterImageView.clipsToBounds = YES;
        self.posterImageView.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
//        [self.posterImageView setDefaultImage:nil];
        self.posterImageView.backgroundColor = [UIColor clearColor];
        self.posterImageView.userInteractionEnabled = NO;
        [self addSubview:self.posterImageView];
        
        self.titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(self.bgImageView.frame)+2, self.width, kTitleLabelHeight)];
        self.titleLabel.numberOfLines = 2;
        self.titleLabel.font = [UIFont systemFontOfSize:18/2.0f];
        self.titleLabel.textColor = [UIColor colorFromString:@"#F8F8F8"];
        self.titleLabel.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.4];
        [self addSubview:self.titleLabel];
        
        self.videoIcon = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"icohome_videosmall_v5.png"]];
        self.videoIcon.userInteractionEnabled = NO;
        self.videoIcon.origin = CGPointMake(self.bgImageView.width-kVideoIconWidth-2, self.bgImageView.height-kVideoIconHeight-2);
        self.videoIcon.size = CGSizeMake(kVideoIconWidth, kVideoIconHeight);
        [self addSubview:self.videoIcon];
        
        CGRect _indicatorFrame = CGRectMake(0, 0, self.width, self.bgImageView.height);
        self.willPlayIndicator = [[WSMVRelativeVideosThumbnailWillPlayIndicator alloc] initWithFrame:_indicatorFrame];
        [self addSubview:self.willPlayIndicator];
    }
    return self;
}

- (void)dealloc {
    self.video = nil;
}

#pragma mark - Public
- (void)setVideo:(SNVideoData *)video {
    if (_video != video) {
        _video = nil;
        _video = video;

        [self.posterImageView sd_setImageWithURL:[NSURL URLWithString:_video.poster]];
        self.titleLabel.text = self.video.title;
    }
}

- (void)updateToWillPlayUI {
    self.video.willPlay = YES;
    [self.willPlayIndicator updateToWillPlayUI];
    self.videoIcon.hidden = YES;
}

- (void)resetToNormalUI {
    self.video.willPlay = NO;
    [self.willPlayIndicator resetToNormalUI];
    self.videoIcon.hidden = NO;
}

@end

////////////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////////////
@interface WSMVRelativeVideosView()
@property (nonatomic, strong)UILabel        *titleLabel;
@property (nonatomic, strong)NSMutableArray *thumbnailViews;
@property (nonatomic, strong)UIScrollView   *scrollView;
@property (nonatomic, strong)SNPageControl  *pageControl;
@end

@implementation WSMVRelativeVideosView

#pragma mark - Lifecycle
- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor blackColor];
        self.relativeVideos = [NSMutableArray array];
        self.thumbnailViews = [NSMutableArray array];
        
        self.titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(kMarginLeftToScrollViewLeftBorder,
                                                                     0,
                                                                     self.width-2*kMarginLeftToScrollViewLeftBorder,
                                                                     kRelativeVideosViewTitleLabelHeight)];
        self.titleLabel.text = @"相关推荐";
        self.titleLabel.textColor = [UIColor colorFromString:@"#F8F8F8"];
        self.titleLabel.backgroundColor = [UIColor clearColor];
        self.titleLabel.font = [UIFont systemFontOfSize:kRelativeVideosViewTitleLabelFontSize];
        [self addSubview:self.titleLabel];
        self.titleLabel.hidden = YES;
        
        self.scrollView = [[UIScrollView alloc] initWithFrame:self.bounds];
        self.scrollView.scrollsToTop = NO;
        self.scrollView.bounces = NO;
        self.scrollView.delegate = self;
        self.scrollView.pagingEnabled = YES;
        [self addSubview:self.scrollView];
        
        self.pageControl = [[SNPageControl alloc] initWithFrame:CGRectMake(0, self.height-kPageControlHeight, self.width, kPageControlHeight)];
        self.pageControl.dotColorCurrentPage = [UIColor colorFromString:@"#C8C8C8"];
        self.pageControl.dotColorOtherPage = [UIColor colorFromString:@"#8C8C8C"];
        self.pageControl.hidesForSinglePage = YES;
        self.pageControl.dotsAlignment = NSTextAlignmentCenter;
        [self addSubview:self.pageControl];
        
        [self updateScrollViewContentSizeAndPageControl];
        
        [SNNotificationManager addObserver:self selector:@selector(cancelAutoPlayRelativeVideos) name:kCancelAutoPlayRelativeVideosNotification object:nil];
    }
    return self;
}

- (void)dealloc {
    [SNNotificationManager removeObserver:self name:kCancelAutoPlayRelativeVideosNotification object:nil];
    
    
    self.scrollView.delegate = nil;
    
}

#pragma mark - Public
- (void)appendRelativeVideos:(NSArray *)relativeVideos {
    if (relativeVideos.count <= 0) {
        return;
    }

    int _currentPageNumber = self.scrollView.contentOffset.x/self.scrollView.width;
    int _willPlayVideoVid = nil;
    for (int i=0; i<self.thumbnailViews.count; i++) {
        WSMVRelativeVideoThumbnailView *thumbnail = [self.thumbnailViews objectAtIndex:i];
        if (thumbnail.video.willPlay) {
            _willPlayVideoVid = thumbnail.video.vid;
        }
    }
    [self.relativeVideos addObjectsFromArray:relativeVideos];
    [self replaceAllRelativeVieos:self.relativeVideos];
    
    for (int i=0; i<self.thumbnailViews.count; i++) {
        WSMVRelativeVideoThumbnailView *thumbnail = [self.thumbnailViews objectAtIndex:i];
        if ([thumbnail.video.vid isEqualToString:[NSString stringWithFormat:@"%d",_willPlayVideoVid]]) {
            [thumbnail updateToWillPlayUI];
        }
    }
    self.scrollView.contentOffset = CGPointMake(_currentPageNumber*self.scrollView.width, 0);
}

- (void)replaceAllRelativeVieos:(NSArray *)videos {
    [self.relativeVideos removeAllObjects];
    for (WSMVRelativeVideoThumbnailView *_v in self.thumbnailViews) {
        [_v resetToNormalUI];
        [_v removeFromSuperview];
    }
    [self.thumbnailViews removeAllObjects];
    
    if (videos.count > 0) {
        [self.relativeVideos addObjectsFromArray:videos];
        [self layoutAllItems];
        [self.scrollView scrollRectToVisible:self.scrollView.bounds animated:NO];
    }
}

- (void)willPlayVideoAfter:(SNVideoData *)video {
    NSInteger _playingThumbnailIndex = NSNotFound;
    for (int i=0; i<self.thumbnailViews.count; i++) {
        WSMVRelativeVideoThumbnailView *thumbnail = [self.thumbnailViews objectAtIndex:i];
        if ([thumbnail.video.vid isEqualToString:video.vid]) {
            _playingThumbnailIndex = i;
        }
    }
    
    NSInteger willPlayThumbnailIndex = 0;
    WSMVRelativeVideoThumbnailView *willPlayThumbnail = nil;
    if (_playingThumbnailIndex != NSNotFound && ((_playingThumbnailIndex+1) < self.thumbnailViews.count)) {
        willPlayThumbnailIndex = _playingThumbnailIndex+1;
        willPlayThumbnail = [self.thumbnailViews objectAtIndex:willPlayThumbnailIndex];
    }
    else if (_playingThumbnailIndex == NSNotFound && self.thumbnailViews.count > 0) {
        willPlayThumbnail = [self.thumbnailViews objectAtIndex:willPlayThumbnailIndex];
    }
    NSInteger _toPage = willPlayThumbnailIndex/kMaxItemsPerPage;
    self.scrollView.contentOffset = CGPointMake(_toPage*self.scrollView.width, 0);
    
    [willPlayThumbnail updateToWillPlayUI];
}

- (void)resetWillPlayThumbnailUI {
    for (int i=0; i<self.thumbnailViews.count; i++) {
        WSMVRelativeVideoThumbnailView *thumbnail = [self.thumbnailViews objectAtIndex:i];
        [thumbnail resetToNormalUI];
    }
}

- (BOOL)isInFirstPage {
    int _currentPageNumber = self.scrollView.contentOffset.x/self.scrollView.width;
    return _currentPageNumber == 0;
}

#pragma mark - private
- (NSInteger)numberOfPages {
    return self.relativeVideos.count/kMaxItemsPerPage + ((self.relativeVideos.count%kMaxItemsPerPage == 0) ? 0 : 1);
}

- (void)updateScrollViewContentSizeAndPageControl {
    self.scrollView.contentSize = CGSizeMake(self.width*[self numberOfPages], self.height);
    self.pageControl.numberOfPages = [self numberOfPages];
    self.pageControl.currentPage = self.scrollView.contentOffset.x/self.scrollView.width;
}

- (CGRect)frameWithVideo:(SNVideoData *)video {
    if (kMaxRowsPerPage <= 0 || kMaxItemsPerRow <= 0) {
        return CGRectZero;
    }
    
    NSInteger _index = [self.relativeVideos indexOfObject:video];
    if (_index == NSNotFound) {
        return CGRectZero;
    }
    else {
        NSInteger _pageNum    = _index/kMaxItemsPerPage;//第一页_pageNum等0
        int _rowNum     = _index/kMaxItemsPerRow%kMaxRowsPerPage;
        int _columnNum  = _index%kMaxItemsPerRow;
        
        CGFloat _left = 0;
        CGFloat _top = 0;
        if (kMaxItemsPerRow > 1) {
            CGFloat _hPadding = (self.scrollView.width-(kMarginLeftToScrollViewLeftBorder+kMarginLeftToScrollViewRightBorder)
                         - kThumbnailViewWidth*kMaxItemsPerRow)/(kMaxItemsPerRow-1);
            CGFloat _vPadding = (self.scrollView.height-(kMarginTopToScrollViewTopBorder+kMarginBottomToScrollViewBottomBorder)
                         - kThumbnailViewHeight*kMaxRowsPerPage)/(kMaxRowsPerPage-1);
            
            _left = kMarginLeftToScrollViewLeftBorder + _columnNum*(kThumbnailViewWidth+_hPadding) + _pageNum*self.scrollView.width;
            _top  = kMarginTopToScrollViewTopBorder + _rowNum*(kThumbnailViewHeight+_vPadding);
        }
        else {
            _left = (self.scrollView.width-kThumbnailViewWidth)/2.0f;
            _top  = (self.scrollView.height-kThumbnailViewHeight)/2.0f;
        }
        CGRect _frame = CGRectMake(_left, _top, kThumbnailViewWidth, kThumbnailViewHeight);
//        SNDebugLog(@"Row %d, Column %d, In page %d, frame %@", _rowNum, _columnNum, _pageNum, NSStringFromCGRect(_frame));
        return _frame;
    }
}

- (void)layoutAllItems {
    [self updateScrollViewContentSizeAndPageControl];
    
    for (SNVideoData *_video in self.relativeVideos) {
        CGRect _frame = [self frameWithVideo:_video];
        WSMVRelativeVideoThumbnailView *_thumbnailView = [[WSMVRelativeVideoThumbnailView alloc] initWithFrame:_frame];
        [_thumbnailView setVideo:_video];
        [_thumbnailView addTarget:self action:@selector(didTapThumbnail:) forControlEvents:UIControlEventTouchUpInside];
        [self.thumbnailViews addObject:_thumbnailView];
        [self.scrollView addSubview:_thumbnailView];
        _thumbnailView = nil;
    }
}

- (void)didTapThumbnail:(WSMVRelativeVideoThumbnailView *)thumbnailView {
    if ([self.delegate respondsToSelector:@selector(didTapRelativeVideo:)]) {
        [self.delegate didTapRelativeVideo:thumbnailView.video];
    }
}

#pragma mark - UIScrollViewDelegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    [self cancelAutoPlayRelativeVideos];
}

- (void)cancelAutoPlayRelativeVideos {
    self.pageControl.currentPage = self.scrollView.contentOffset.x/self.scrollView.width;
    
    [self resetWillPlayThumbnailUI];
    if ([self.delegate respondsToSelector:@selector(didScrollRelativeVideosView)]) {
        [self.delegate didScrollRelativeVideosView];
    }
}

@end
