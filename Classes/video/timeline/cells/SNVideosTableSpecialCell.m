//
//  SNVideosTableSpecialCell.m
//  sohunews
//
//  Created by jialei on 13-11-21.
//  Copyright (c) 2013年 Sohu.com. All rights reserved.
//

#import "SNVideosTableSpecialCell.h"
#import "SNWebImageView.h"
#import "SNVideoObjects.h"
#import "WSMVVideoTitleView.h"
#import "SNTimelineSharedVideoPlayerView.h"

#define SNVedioSpecial_ImageFrame (CGRectMake(kTimelineVideoCellSubContentViewsSideMargin, kTimelineVideoCellSubContentViewsTopMargin, 300, kVideosSpecialCellHeight))
#define NSSpecialTitleLineNum   3


@interface SNVideosTableSpecialCell()

@property (nonatomic, strong)UIImageView *bgImageView;
@property (nonatomic, strong)UIView *defaultView;
@property (nonatomic, strong)SNWebImageView *activityImageView;
@property (nonatomic, strong)UIImageView *maskImageView;
@property (nonatomic, strong)UILabel *titleView;
@property (nonatomic, strong)UITapGestureRecognizer *tapGesture;

@end

@implementation SNVideosTableSpecialCell

#pragma mark - Lifecycle
- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        self.backgroundColor = [UIColor clearColor];
        
        //Bg imageview
        CGRect bgViewFrame = CGRectMake(kTimelineCellBgViewSideMargin,
                                        kTimelineVideoCellSubContentViewsTopMargin,
                                        320-2*kTimelineCellBgViewSideMargin,
                                        [[self class] height]-2*kTimelineVideoCellSubContentViewsTopMargin);
        _bgImageView = [[UIImageView alloc] initWithFrame:bgViewFrame];
        _bgImageView.image = [[UIImage imageNamed:@"timeline_videoplay_cellbg.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(16, 16, 16, 16)];
        [self addSubview:_bgImageView];
        
        //Tap gesture
        _tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(openIt)];
        [self addGestureRecognizer:_tapGesture];
    }
    return self;
}

- (void)dealloc {
     //(_bgImageView);
     //(_activityImageView);
     //(_maskImageView);
     //(_titleView);
    self.tapGesture.delegate = nil;
    
}

#pragma mark - Override
- (void)setHighlighted:(BOOL)highlighted animated:(BOOL)animated {}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {}

+ (CGFloat)height {
    return kVideosActivityCellHeight;
}

- (void)setObject:(SNVideoData *)object {
    BOOL needUpdate = (!!object && (object != self.object));
    [super setObject:object];
    
    if (needUpdate) {
        [self updateActivityImageView];
        [self setMaskImageView];
        [self setTitleView];
        
        if (self.object.title.length <= 0) {
            self.maskImageView.hidden = YES;
        }
        else {
            self.maskImageView.hidden = NO;
        }
    }
}

- (void)updateActivityImageView {
    if (!(self.activityImageView)) {
        CGRect activityImageViewFrame = CGRectMake(kTimelineVideoCellSubContentViewsSideMargin,
                                                   kTimelineVideoCellSubContentViewsTopMargin,
                                                   kTimelineContentViewWidth,
                                                   kVideosActivityContentHeight);
        
        _activityImageView = [[SNWebImageView alloc] initWithFrame:activityImageViewFrame];
        _activityImageView.clipsToBounds = YES;
        [self addSubview:self.activityImageView];
        
        _defaultView = [[UIView alloc] initWithFrame:_activityImageView.frame];
        _defaultView.backgroundColor = [UIColor colorFromString:@"#e5e5e5"];
        UIImageView *defaultImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"photo_list_default2.png"]];
        defaultImageView.backgroundColor = [UIColor clearColor];
        [_defaultView addSubview:defaultImageView];
        defaultImageView.center = _defaultView.center;
        [self addSubview:_defaultView];
    }
    __weak __typeof(&*self)weakSelf = self;
    [_activityImageView setUrlPath:self.object.templatePicUrl completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType) {
        weakSelf.activityImageView.contentMode = UIViewContentModeScaleAspectFit;
        weakSelf.defaultView.hidden = YES;
    }];
}

- (void)setMaskImageView {
    if (!self.maskImageView) {
        UIImage *image = [[UIImage imageNamed:@"timeline_videoplay_titleviewbg_nonfullscreen.png"]
                          resizableImageWithCapInsets:UIEdgeInsetsMake(0, 1, 0, 1)];
        self.maskImageView = [[UIImageView alloc] initWithImage:image];
        self.maskImageView.contentMode = UIViewContentModeScaleToFill;
        self.maskImageView.clipsToBounds = YES;
        self.maskImageView.frame = SNVedioSpecial_ImageFrame;
        self.maskImageView.backgroundColor = [UIColor clearColor];
        self.maskImageView.userInteractionEnabled = NO;
        
        [self addSubview:self.maskImageView];
    }
}

- (void)setTitleView {
    UIFont *titleFont = [UIFont systemFontOfSize:kHeadlineTitleFontSize_NonFullScreen];
    if (!self.titleView) {
        self.titleView = [[UILabel alloc] init];
        self.titleView.backgroundColor = [UIColor clearColor];
        self.titleView.textAlignment   = NSTextAlignmentLeft;
        self.titleView.textColor = SNUICOLOR(kRollingHeadLineTextColor);
        self.titleView.numberOfLines = NSSpecialTitleLineNum;
        self.titleView.font = titleFont;
        
        [self addSubview:self.titleView];
    }
    self.titleView.text = self.object.title;
    CGSize titleSize = [self.titleView.text sizeWithFont:titleFont
                                       constrainedToSize:CGSizeMake(self.width - kTimelineVideoCellSubContentViewsSideMargin * 2, NSSpecialTitleLineNum * titleFont.lineHeight)
                                           lineBreakMode:NSLineBreakByCharWrapping];
    
    self.titleView.frame = CGRectMake(kTimelineVideoCellSubContentViewsSideMargin * 2, kTimelineVideoCellSubContentViewsSideMargin,
                                      self.width - kTimelineVideoCellSubContentViewsSideMargin * 4, titleSize.height + 2);
}

- (void)openIt {
    [SNTimelineSharedVideoPlayerView fakeStop];
    [SNTimelineSharedVideoPlayerView forceStop];
    
    if (self.object.link2.length > 0) {
        [SNUtility openProtocolUrl:self.object.link2];
        
        // 统计cc
        SNUserTrack *curPage = [SNUserTrack trackWithPage:tab_video link2:nil];
        SNUserTrack *toPage = [SNUserTrack trackWithPage:video_activities link2:self.object.link2];
        NSString *paramString = [NSString stringWithFormat:kAnalyticsUrlCC, [curPage toFormatString], [toPage toFormatString], f_open];
        [SNNewsReport reportADotGifWithTrack:paramString];
        
        // banner 点击量统计
        paramString = [NSString stringWithFormat:kAnalyticsUrlCC, [[SNUserTrack trackWithPage:video_banner link2:nil] toFormatString], [toPage toFormatString], f_open];
        [SNNewsReport reportADotGifWithTrack:paramString];
    }
}

@end
