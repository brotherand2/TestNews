//
//  SNLiveBannerViewWithMatchInfo.m
//  sohunews
//
//  Created by wang yanchen on 13-5-2.
//  Copyright (c) 2013年 Sohu.com. All rights reserved.
//

#import "SNLiveBannerViewWithMatchInfo.h"
#import "UIColor+ColorUtils.h"
#import "SNLiveRoomConsts.h"

#define kLiveBannerViewWithMatchInfoExHeight                ((244 / 2  + kSystemBarHeight) + 10)
#define kLiveBannerViewWithMatchInfoScaleHeight             ((180 / 2  + kSystemBarHeight) + 10)

// 参与人数
#define kLiveBannerViewWithMatchInfoOnlineCountTopMargin    (126 / 2 + kSystemBarHeight)
#define kLiveBannerViewWithMatchInfoOnlineCountFont         (22 / 2)
#define kLiveBannerViewWithMatchInfoOnlineCountWidth        (300 / 2)
// 比赛状态
#define kLiveBannerViewWithMatchInfoLiveStatusTopMargin     (7 / 2)

// live status
#define kLiveStatusFont             (18 / 2)
#define kLiveStatusBottomMargin     (14 / 2)
#define kLiveStatusTopMargin        (18 / 2)
#define kLiveStatusLeftMargin       (338 / 2)
#define kLiveStatusLeftMargin_S     (338 / 2)

// 比分
#define kLiveBannerViewWithMatchInfoScoreDotsTopMargin      (52 / 2 + kSystemBarHeight)
#define kLiveBannerViewWithMatchInfoScoreDotsFontBig        (60 / 2)
#define kLiveBannerViewWithMatchInfoScoreDotsFontSmall      (44 / 2)
#define kLiveBannerViewWithMatchInfoScoreDotsTopMarginS     (46 / 2 + kSystemBarHeight)

#define kLiveBannerViewWithMatchInfoScoreWidth              (120 / 2)
#define kLiveBannerViewWithMatchInfoScoreWidthWorldCup      (100 / 2)
#define kLiveBannerViewWithMatchInfoScoreSideMargin         (180 / 2 + 6)

#define kLiveBannerViewWithMatchInfoScroeOffset             (2)

#define kLiveBannerViewWithMatchInfoWorldCupTopMargin       (18 + kSystemBarHeight)
#define kLiveBannerViewWithMatchInfoWorldCupTopMarginS      (10)

// 球队名称
#define kLiveBannerViewWithMatchInfoTeamNameWidth           (224 / 2)
#define kLiveBannerViewWithMatchInfoTeamNameFont            (26 / 2)
#define kLiveBannerViewWithMatchInfoTeamNameTopMargin       (144 / 2 + kSystemBarHeight)

#define kLiveBannerViewWithMatchInfoTeamNameWidthS          (106 / 2)
#define kLiveBannerViewWithMatchInfoTeamNameTopMarginS      (58 / 2 + kSystemBarHeight)
#define kLiveBannerViewWithMatchInfoTeamNameFontS           (20 / 2)

// 球队图标
#define kLiveBannerViewWithMatchInfoIconCenterX             (146 / 2)
#define kLiveBannerViewWithMatchInfoIconCenterX_S           (150 / 2)
#define kLiveBannerViewWithMatchInfoIconCenterY             (82 / 2 + kSystemBarHeight)
#define kLiveBannerViewWithMatchInfoIconCenterY_S           (70 / 2 + kSystemBarHeight)
#define kLiveBannerViewWithMatchInfoIconScaleFator          ((float)78 / (float)100)

// up
#define kLiveBannerViewWithMatchInfoUpIconTopMargin         (62 / 2 + kSystemBarHeight)
#define kLiveBannerViewWithMatchInfoUpLabelTopMargin        (94 / 2 + kSystemBarHeight)
#define kLiveBannerViewWithMatchInfoUpLabelFont             (16 / 2)

@implementation SNLiveBannerViewWithMatchInfo

- (id)initWithFrame:(CGRect)frame {
    CGRect appFrame = [[UIScreen mainScreen] applicationFrame];
    frame = CGRectMake(0, 0, appFrame.size.width, kLiveBannerViewWithMatchInfoExHeight);
    self = [super initWithFrame:frame];
    if (self) {
        self.clipsToBounds = YES;
    }
    return self;
}

- (void)createSubviews {
    // 直播状态
    _liveStatusLabel = [[UILabel alloc] initWithFrame:CGRectMake(0,
                                                                 self.height - kLiveStatusBottomMargin - kLiveStatusFont - 1,
                                                                 125,
                                                                 kLiveStatusFont + 1)];
    
    _liveStatusLabel.backgroundColor = [UIColor clearColor];
    _liveStatusLabel.font = [UIFont systemFontOfSize:kLiveStatusFont];
    _liveStatusLabel.textAlignment = NSTextAlignmentLeft;
    _liveStatusLabel.lineBreakMode = NSLineBreakByTruncatingTail;
    [self addSubview:_liveStatusLabel];
    
    // 参与人数
    _onlineCountLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 50, kLiveStatusFont + 1)];
    _onlineCountLabel.backgroundColor = [UIColor clearColor];
    _onlineCountLabel.font = _liveStatusLabel.font;
    _onlineCountLabel.textAlignment = NSTextAlignmentLeft;
    _onlineCountLabel.lineBreakMode = NSLineBreakByTruncatingTail;
    [self addSubview:_onlineCountLabel];    
    
    _dotsLabel = [[UILabel alloc] initWithFrame:CGRectMake(0,
                                                           kLiveBannerViewWithMatchInfoScoreDotsTopMargin - kLiveBannerViewWithMatchInfoScroeOffset,
                                                           10,
                                                           kLiveBannerViewWithMatchInfoScoreDotsFontBig + 1)];
    _dotsLabel.centerX = CGRectGetMidX(self.bounds);
    _dotsLabel.font = [UIFont digitAndLetterFontOfSize:kLiveBannerViewWithMatchInfoScoreDotsFontBig];
    _dotsLabel.backgroundColor = [UIColor clearColor];
    _dotsLabel.textAlignment = NSTextAlignmentCenter;
    _dotsLabel.text = @":";
    [self addSubview:_dotsLabel];
    
    // 主队分数
    _hostScoreLabel = [[UILabel alloc] initWithFrame:CGRectMake(kLiveBannerViewWithMatchInfoScoreSideMargin,
                                                                kLiveBannerViewWithMatchInfoScoreDotsTopMargin,
                                                                kLiveBannerViewWithMatchInfoScoreWidth,
                                                                kLiveBannerViewWithMatchInfoScoreDotsFontBig + 1)];
    _hostScoreLabel.font = [UIFont digitAndLetterFontOfSize:kLiveBannerViewWithMatchInfoScoreDotsFontBig];
    _hostScoreLabel.backgroundColor = [UIColor clearColor];
    _hostScoreLabel.textAlignment = NSTextAlignmentCenter;
    [self addSubview:_hostScoreLabel];
    
    // 主队名称
    _hostNameLabel = [[UILabel alloc] initWithFrame:CGRectMake(0,
                                                               kLiveBannerViewWithMatchInfoTeamNameTopMargin,
                                                               kLiveBannerViewWithMatchInfoTeamNameWidth,
                                                               kLiveBannerViewWithMatchInfoTeamNameFont + 1)];
    _hostNameLabel.backgroundColor = [UIColor clearColor];
    _hostNameLabel.font = [UIFont systemFontOfSize:kLiveBannerViewWithMatchInfoTeamNameFont];
    _hostNameLabel.textAlignment = NSTextAlignmentCenter;
    _hostNameLabel.centerX = kLiveBannerViewWithMatchInfoIconCenterX;
    //_hostNameLabel.adjustsFontSizeToFitWidth = YES;
    //_hostNameLabel.minimumFontSize = 10;
    [self addSubview:_hostNameLabel];
    
    UIImage *iconMaskImage = [UIImage imageNamed:@"live_teamicon_big.png"];
    
    UIImage *defaultTeamIconImage = [UIImage imageNamed:@"live_team_icon.png"];
    
    _hostIconView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, iconMaskImage.size.width, iconMaskImage.size.height)];
    _hostIconView.centerX = kLiveBannerViewWithMatchInfoIconCenterX;
    _hostIconView.centerY = kLiveBannerViewWithMatchInfoIconCenterY;
    [self addSubview:_hostIconView];
    
    UITapGestureRecognizer *hostTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hostIconTapped:)];
    [_hostIconView addGestureRecognizer:hostTap];
     //(hostTap);
    
    _hostIcon = [[SNWebImageView alloc] initWithFrame:CGRectMake(0, 0,
                                                                 _hostIconView.width,
                                                                 _hostIconView.width)];
    _hostIcon.defaultImage = defaultTeamIconImage;
    _hostIcon.showFade = NO;
    _hostIcon.ignorePicMode = YES;
    [self addLayerMask:@"live_teamicon_bigmask.png" forView:_hostIcon];
    [_hostIconView addSubview:_hostIcon];
    
    _hostIconMaskView = [[UIImageView alloc] initWithImage:iconMaskImage];
    [_hostIconView addSubview:_hostIconMaskView];
    
    _hostUpView = [[UIView alloc] initWithFrame:CGRectMake(0, 0,
                                                           _hostIconView.left,
                                                           _hostNameLabel.top)];
    [self addSubview:_hostUpView];
    
    UITapGestureRecognizer *hostUpTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hostUpTapped:)];
    [_hostUpView addGestureRecognizer:hostUpTap];
     //(hostUpTap);
    
    UIImage *hostUpImage = [UIImage imageNamed:@"live_host_up.png"];
    _hostUpIcon = [[UIImageView alloc] initWithImage:hostUpImage];
    _hostUpIcon.top = kLiveBannerViewWithMatchInfoUpIconTopMargin;
    _hostUpIcon.centerX = CGRectGetMidX(_hostUpView.bounds);
    [_hostUpView addSubview:_hostUpIcon];
    
    _hostUpLabel = [[UILabel alloc] initWithFrame:CGRectMake(0,
                                                             kLiveBannerViewWithMatchInfoUpLabelTopMargin,
                                                             _hostUpView.width,
                                                             kLiveBannerViewWithMatchInfoUpLabelFont + 1)];
    _hostUpLabel.backgroundColor = [UIColor clearColor];
    _hostUpLabel.textAlignment = NSTextAlignmentCenter;
    _hostUpLabel.font = [UIFont digitAndLetterFontOfSize:kLiveBannerViewWithMatchInfoUpLabelFont];
    [_hostUpView addSubview:_hostUpLabel];
    
    // 客队
    _visitScoreLabel = [[UILabel alloc] initWithFrame:CGRectMake(self.width - kLiveBannerViewWithMatchInfoScoreSideMargin - _hostScoreLabel.width,
                                                                 _hostScoreLabel.top,
                                                                 _hostScoreLabel.width,
                                                                 _hostScoreLabel.height)];
    _visitScoreLabel.font = _hostScoreLabel.font;
    _visitScoreLabel.backgroundColor = [UIColor clearColor];
    _visitScoreLabel.textAlignment = NSTextAlignmentCenter;
    [self addSubview:_visitScoreLabel];
    
    _visitNameLabel = [[UILabel alloc] initWithFrame:CGRectMake(0,
                                                                _hostNameLabel.top,
                                                                _hostNameLabel.width,
                                                                _hostNameLabel.height)];
    _visitNameLabel.font = _hostNameLabel.font;
    _visitNameLabel.backgroundColor = [UIColor clearColor];
    _visitNameLabel.centerX = self.width - kLiveBannerViewWithMatchInfoIconCenterX;
    _visitNameLabel.textAlignment = NSTextAlignmentCenter;
    //_visitNameLabel.adjustsFontSizeToFitWidth = YES;
    //_visitNameLabel.minimumFontSize = 10;
    [self addSubview:_visitNameLabel];
    
    _visitIconView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, _hostIconView.width, _hostIconView.height)];
    _visitIconView.centerX = self.width - kLiveBannerViewWithMatchInfoIconCenterX;
    _visitIconView.centerY = kLiveBannerViewWithMatchInfoIconCenterY;
    [self addSubview:_visitIconView];
    
    UITapGestureRecognizer *visitTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(visitIconTapped:)];
    [_visitIconView addGestureRecognizer:visitTap];
     //(visitTap);
    
    _visitIcon = [[SNWebImageView alloc] initWithFrame:CGRectMake(0, 0,
                                                                  _visitIconView.width,
                                                                  _visitIconView.width)];
    _visitIcon.defaultImage = defaultTeamIconImage;
    _visitIcon.showFade = NO;
    _visitIcon.ignorePicMode = YES;
    [self addLayerMask:@"live_teamicon_bigmask.png" forView:_visitIcon];
    [_visitIconView addSubview:_visitIcon];
    
    _visitIconMaskView = [[UIImageView alloc] initWithImage:iconMaskImage];
    [_visitIconView addSubview:_visitIconMaskView];
    
    _visitUpView = [[UIView alloc] initWithFrame:CGRectMake(_visitIconView.right, 0,
                                                            _hostUpView.width,
                                                            _hostUpView.height)];
    [self addSubview:_visitUpView];
    
    UITapGestureRecognizer *visitUpTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(visitUpTapped:)];
    [_visitUpView addGestureRecognizer:visitUpTap];
     //(visitUpTap);
    
    UIImage *visitUpImage = [UIImage imageNamed:@"live_visitor_up.png"];
    _visitUpIcon = [[UIImageView alloc] initWithImage:visitUpImage];
    _visitUpIcon.top = kLiveBannerViewWithMatchInfoUpIconTopMargin;
    _visitUpIcon.centerX = CGRectGetMidX(_visitUpView.bounds);
    [_visitUpView addSubview:_visitUpIcon];
    
    _visitUpLabel = [[UILabel alloc] initWithFrame:CGRectMake(0,
                                                              kLiveBannerViewWithMatchInfoUpLabelTopMargin,
                                                              _visitUpView.width,
                                                              kLiveBannerViewWithMatchInfoUpLabelFont + 1)];
    _visitUpLabel.backgroundColor = [UIColor clearColor];
    _visitUpLabel.textAlignment = NSTextAlignmentCenter;
    _visitUpLabel.font = [UIFont digitAndLetterFontOfSize:kLiveBannerViewWithMatchInfoUpLabelFont];
    [_visitUpView addSubview:_visitUpLabel];
    
    [self updateTheme];
    
    // 默认数据
    self.hostScore = @"000";
    self.visitScore = @"000";
    self.hostUp = @"0";
    self.visitUp = @"0";
    
    [self layoutLiveStatusLabel];
}

- (void)addLayerMask:(NSString *)maskImageName forView:(UIView *)view {
    UIImage *mask = [UIImage imageNamed:maskImageName];
    CALayer *maskLayer = [CALayer layer];
    maskLayer.frame = CGRectMake(0, 1, view.width, view.height);
    maskLayer.contents = (id)mask.CGImage;
    view.layer.mask = maskLayer;
    view.layer.masksToBounds = YES;
}

- (void)layoutLiveStatusLabel {
    /*
     * 不参与动画了 v5.2.0
    if (_segmentView.hasExpanded) {
        _liveStatusLabel.frame = CGRectMake((self.width - _liveStatusLabel.width)/2,
                                            kLiveBannerViewWithMatchInfoScoreDotsTopMargin +
                                            kLiveBannerViewWithMatchInfoScoreDotsFontBig + 1 +
                                            kLiveStatusTopMargin - 7 + (self.isWorldCup ? 5 : 0),
                                            _liveStatusLabel.width,
                                            _liveStatusLabel.height);
        _onlineCountLabel.frame = CGRectMake((self.width - _onlineCountLabel.width)/2,
                                             _liveStatusLabel.bottom + 3,
                                             _onlineCountLabel.width,
                                             _onlineCountLabel.height);
    } else {
        float w = _liveStatusLabel.width + _onlineCountLabel.width + 2.5;
        _liveStatusLabel.frame = CGRectMake((self.width - w)/2,
                                            40 + kLiveStatusTopMargin + kSystemBarHeight,
                                            _liveStatusLabel.width,
                                            _liveStatusLabel.height);
        _onlineCountLabel.frame = CGRectMake(_liveStatusLabel.right + 2.5,
                                             _liveStatusLabel.top,
                                             _onlineCountLabel.width,
                                             _onlineCountLabel.height);
    }
     */
    
    CGFloat left = 11.0;
    
    // 判断 独家 显示
    if (self.infoObj.pubType.integerValue == 1) {
        if (!_pubTypeLabel) {
            _pubTypeLabel = [[UILabel alloc] initWithFrame:CGRectZero];
            _pubTypeLabel.backgroundColor = [UIColor clearColor];
            _pubTypeLabel.font = _liveStatusLabel.font;
            _pubTypeLabel.textColor = [SNSkinManager color:SkinRed];
            _pubTypeLabel.text = kPubTypeName;
            [self addSubview:_pubTypeLabel];
            [_pubTypeLabel sizeToFit];
        }
        
        _pubTypeLabel.hidden = NO;
        
        _pubTypeLabel.left = left;
        _onlineCountLabel.left = _pubTypeLabel.right + 6;
        
    } else {
        _pubTypeLabel.hidden = YES;
        
        _onlineCountLabel.left = left;
    }
    
    _onlineCountLabel.bottom = _segmentView.top;
    _liveStatusLabel.left = _onlineCountLabel.right + 6;
    _liveStatusLabel.bottom = _onlineCountLabel.bottom;
    _pubTypeLabel.bottom = _onlineCountLabel.bottom;
}

- (void)dealloc {
     //(_hostName);
     //(_hostIconUrl);
     //(_hostUp);
     //(_hostScore);
    
     //(_visitName);
     //(_visitIconUrl);
     //(_visitUp);
     //(_visitScore);
    
     //(_onlineCountLabel);
     //(_liveStatusLabel);
     //(_dotsLabel);
//     //(_worldCupIcon);
    
     //(_hostScoreLabel);
     //(_hostNameLabel);
     //(_hostIconView);
     //(_hostIcon);
     //(_hostIconMaskView);
     //(_hostUpView);
     //(_hostUpLabel);
     //(_hostUpIcon);
    
     //(_visitScoreLabel);
     //(_visitNameLabel);
     //(_visitIconView);
     //(_visitIcon);
     //(_visitIconMaskView);
     //(_visitUpView);
     //(_visitUpLabel);
     //(_visitUpIcon);
    
     //(_pubTypeLabel);
    
}

- (void)setInfoObj:(SNLiveContentMatchInfoObject *)infoObj {
    [super setInfoObj:infoObj];
    self.hostName = self.infoObj.homeTeamTitle;
    self.hostIconUrl = self.infoObj.homeTeamIconURL;
    self.hostScore = self.infoObj.homeTeamScore;
    self.hostUp = self.infoObj.homeTeamSupportNum.length > 0 ? self.infoObj.homeTeamSupportNum : @"0";
    
    self.visitName = self.infoObj.visitingTeamTitle;
    self.visitIconUrl = self.infoObj.visitingTeamIconURL;
    self.visitScore = self.infoObj.visitingTeamScore;
    self.visitUp = self.infoObj.visitingTeamSupportNum.length > 0 ? self.infoObj.visitingTeamSupportNum : @"0";
    [_liveStatusLabel sizeToFit];
    [_onlineCountLabel sizeToFit];

    [self layoutLiveStatusLabel];
}

- (void)setHostScore:(NSString *)hostScore {
    if (_hostScore != hostScore) {
         //(_hostScore);
        _hostScore = [hostScore copy];
    }
    
    _hostScoreLabel.text = _hostScore;
}

- (void)setVisitScore:(NSString *)visitScore {
    if (_visitScore != visitScore) {
         //(_visitScore);
        _visitScore = [visitScore copy];
    }
    
    _visitScoreLabel.text = _visitScore;
}

- (void)setHostName:(NSString *)hostName {
    if (_hostName != hostName) {
         //(_hostName);
        _hostName = [hostName copy];
    }
    
    _hostNameLabel.text = _hostName;
}

- (void)setVisitName:(NSString *)visitName {
    if (_visitName != visitName) {
         //(_visitName);
        _visitName = [visitName copy];
    }
    
    _visitNameLabel.text = _visitName;
}

- (void)setHostUp:(NSString *)hostUp {
    if (hostUp && _hostUp && [hostUp intValue] <= [_hostUp intValue]) {
        return;
    }
    
    if (_hostUp != hostUp) {
         //(_hostUp);
        _hostUp = [hostUp copy];
    }

//    _hostUpLabel.text = _hostUp;
    _hostUpLabel.text = [SNUtility statisticsDataChangeType:_hostUp];
}

- (void)setVisitUp:(NSString *)visitUp {
    if (visitUp && _visitUp && [visitUp intValue] <= [_visitUp intValue]) {
        return;
    }

    if (_visitUp != visitUp) {
         //(_visitUp);
        _visitUp = [visitUp copy];
    }
    
//    _visitUpLabel.text = _visitUp;
    _visitUpLabel.text = [SNUtility statisticsDataChangeType:_visitUp];
}

- (void)setHostIconUrl:(NSString *)hostIconUrl {
    if (_hostIconUrl != hostIconUrl) {
         //(_hostIconUrl);
        _hostIconUrl = [hostIconUrl copy];
    }
    
    [_hostIcon setUrlPath:_hostIconUrl];
}

- (void)setVisitIconUrl:(NSString *)visitIconUrl {
    if (_visitIconUrl != visitIconUrl) {
         //(_visitIconUrl);
        _visitIconUrl = [visitIconUrl copy];
    }
    
    [_visitIcon setUrlPath:_visitIconUrl];
}

#pragma mark - override super 
- (void)initOnlineCountLabel {
    _onlineCountLabel.text = [NSString stringWithFormat:@"%@人参与", [SNUtility statisticsDataChangeType:self.onlineCount]];
}

- (void)initLiveStatusLabel {
    _liveStatusLabel.text = self.liveStatus;
}

- (CGFloat)viewExpandHeight {
    return kLiveBannerViewWithMatchInfoExHeight;
}

- (CGFloat)viewShrinkHeight {
    return kLiveBannerViewWithMatchInfoScaleHeight;
}

- (void)doExpandAnimation {
    [super doExpandAnimation];
    //_onlineCountLabel.alpha = 1;
    //_liveStatusLabel.alpha = 1;
//    _liveStatusLabel.frame = CGRectMake(kLiveStatusLeftMargin,
//                                        self.height - kLiveStatusBottomMargin - _liveStatusLabel.height,
//                                        _liveStatusLabel.width,
//                                        _liveStatusLabel.height);
    
    _dotsLabel.layer.transform = CATransform3DIdentity;
    _dotsLabel.top = kLiveBannerViewWithMatchInfoScoreDotsTopMargin - kLiveBannerViewWithMatchInfoScroeOffset;
    
//    _worldCupIcon.layer.transform = CATransform3DIdentity;
//    _worldCupIcon.top = kLiveBannerViewWithMatchInfoWorldCupTopMargin;
    
    _hostScoreLabel.layer.transform = CATransform3DIdentity;
    _hostScoreLabel.top = kLiveBannerViewWithMatchInfoScoreDotsTopMargin;
    
    _visitScoreLabel.layer.transform = CATransform3DIdentity;
    _visitScoreLabel.top = kLiveBannerViewWithMatchInfoScoreDotsTopMargin;
    
    //_hostNameLabel.center = CGPointMake(kLiveBannerViewWithMatchInfoIconCenterX,
    //                                    kLiveBannerViewWithMatchInfoTeamNameTopMargin + (kLiveBannerViewWithMatchInfoTeamNameFont + 1) / 2);
    //_hostNameLabel.layer.transform = CATransform3DIdentity;
    _hostNameLabel.font = [UIFont systemFontOfSize:kLiveBannerViewWithMatchInfoTeamNameFont];
    _hostNameLabel.frame = CGRectMake(kLiveBannerViewWithMatchInfoIconCenterX-kLiveBannerViewWithMatchInfoTeamNameWidth/2,
                                      kLiveBannerViewWithMatchInfoTeamNameTopMargin,
                                      kLiveBannerViewWithMatchInfoTeamNameWidth,
                                      kLiveBannerViewWithMatchInfoTeamNameFont + 2);
    
    //_visitNameLabel.center = CGPointMake(self.width - kLiveBannerViewWithMatchInfoIconCenterX,
    //                                     _hostNameLabel.centerY);
    //_visitNameLabel.layer.transform = CATransform3DIdentity;
    _visitNameLabel.font = _hostNameLabel.font;
    _visitNameLabel.frame = CGRectMake(self.width - kLiveBannerViewWithMatchInfoIconCenterX - kLiveBannerViewWithMatchInfoTeamNameWidth/2,
                                       _hostNameLabel.top,
                                       _hostNameLabel.width,
                                       kLiveBannerViewWithMatchInfoTeamNameFont + 2);
    
    _hostIconView.center = CGPointMake(kLiveBannerViewWithMatchInfoIconCenterX,
                                       kLiveBannerViewWithMatchInfoIconCenterY);
    _hostIconView.layer.transform = CATransform3DIdentity;
    
    _visitIconView.center = CGPointMake(self.width - kLiveBannerViewWithMatchInfoIconCenterX,
                                        kLiveBannerViewWithMatchInfoIconCenterY);
    _visitIconView.layer.transform = CATransform3DIdentity;
    
    _hostUpView.alpha = 1;
    _visitUpView.alpha = 1;
    
    [self layoutLiveStatusLabel];
}

- (void)doShrinkAnimation {
    [super doShrinkAnimation];
    CGFloat scoreScaleFator = (float)kLiveBannerViewWithMatchInfoScoreDotsFontSmall / (float)kLiveBannerViewWithMatchInfoScoreDotsFontBig;
    CATransform3D transform = CATransform3DMakeScale(scoreScaleFator, scoreScaleFator, 1);
    
    _dotsLabel.centerY = 31 + kSystemBarHeight;
    _dotsLabel.layer.transform = transform;
  
    _hostScoreLabel.centerY = 33 + kSystemBarHeight;
    _hostScoreLabel.layer.transform = transform;
    
    _visitScoreLabel.centerY = 33 + kSystemBarHeight;
    _visitScoreLabel.layer.transform = transform;
    
    
    CGFloat teamNameScalFator = (float)kLiveBannerViewWithMatchInfoTeamNameFontS / (float)kLiveBannerViewWithMatchInfoTeamNameFont;
    CGFloat scaledVerticleLine = 29;

    _hostNameLabel.font = [UIFont systemFontOfSize:kLiveBannerViewWithMatchInfoTeamNameFontS];
    _hostNameLabel.frame = CGRectMake(scaledVerticleLine-kLiveBannerViewWithMatchInfoTeamNameWidthS/2,
                                      33-kLiveBannerViewWithMatchInfoTeamNameFontS/2 + kSystemBarHeight,
                                      kLiveBannerViewWithMatchInfoTeamNameWidthS,
                                      kLiveBannerViewWithMatchInfoTeamNameFontS+2);
    
    _visitNameLabel.font = _hostNameLabel.font;
    _visitNameLabel.frame = CGRectMake(self.width - scaledVerticleLine - kLiveBannerViewWithMatchInfoTeamNameWidthS/2,
                                       _hostNameLabel.top,
                                       kLiveBannerViewWithMatchInfoTeamNameWidthS,
                                       kLiveBannerViewWithMatchInfoTeamNameFontS+2);
    
    _hostIconView.center = CGPointMake(kLiveBannerViewWithMatchInfoIconCenterX_S,
                                       kLiveBannerViewWithMatchInfoIconCenterY_S);
    _hostIconView.layer.transform = CATransform3DMakeScale(kLiveBannerViewWithMatchInfoIconScaleFator, kLiveBannerViewWithMatchInfoIconScaleFator, 1);
    
    _visitIconView.center = CGPointMake(self.width - kLiveBannerViewWithMatchInfoIconCenterX_S,
                                        kLiveBannerViewWithMatchInfoIconCenterY_S);
    _visitIconView.layer.transform = CATransform3DMakeScale(kLiveBannerViewWithMatchInfoIconScaleFator, kLiveBannerViewWithMatchInfoIconScaleFator, 1);
    
    _hostUpView.alpha = 0;
    _visitUpView.alpha = 0;
    
    [self layoutLiveStatusLabel];
}

- (void)updateTheme {
    [super updateTheme];
    
    UIColor *onlineColor = self.isWorldCup ? kLiveWorldCupWhiteColor : [SNSkinManager color:SkinText4];
    _onlineCountLabel.textColor = onlineColor;
    _liveStatusLabel.textColor = onlineColor;
    _hostUpLabel.textColor = onlineColor;
    _visitUpLabel.textColor = onlineColor;
    
    UIColor *scoreColor = self.isWorldCup ? kLiveWorldCupWhiteColor : [UIColor colorFromString:[[SNThemeManager sharedThemeManager] currentThemeValueForKey:kLiveGameScoreTextColor]];
    _dotsLabel.textColor = scoreColor;
    _hostScoreLabel.textColor = scoreColor;
    _visitScoreLabel.textColor = scoreColor;
    
    UIColor *titleColor = self.isWorldCup ? kLiveWorldCupWhiteColor : [UIColor colorFromString:[[SNThemeManager sharedThemeManager] currentThemeValueForKey:kLiveGameInfoTextColor]];
    _hostNameLabel.textColor = titleColor;
    _visitNameLabel.textColor = titleColor;
    
    _hostIconMaskView.image = [UIImage imageNamed:@"live_teamicon_big.png"];
    _visitIconMaskView.image = [UIImage imageNamed:@"live_teamicon_big.png"];
}

#pragma mark - actions

- (void)hostIconTapped:(id)sender {
    if (_delegate && [_delegate respondsToSelector:@selector(bannerTappedHostIcon)]) {
        [_delegate bannerTappedHostIcon];
    }
}

- (void)visitIconTapped:(id)sender {
    if (_delegate && [_delegate respondsToSelector:@selector(bannerTappedVisitIcon)]) {
        [_delegate bannerTappedVisitIcon];
    }
}

- (void)hostUpTapped:(id)sender {
    if (_delegate && [_delegate respondsToSelector:@selector(bannerTappedHostUp)]) {
        [_delegate bannerTappedHostUp];
    }
}

- (void)visitUpTapped:(id)sender {
    if (_delegate && [_delegate respondsToSelector:@selector(bannerTappedVisitUp)]) {
        [_delegate bannerTappedVisitUp];
    }
}

@end
