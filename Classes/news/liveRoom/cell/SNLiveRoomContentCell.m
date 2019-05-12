//
//  SNBroadcastContentCell.m
//  sohunews
//
//  Created by Chen Hong on 12-6-15.
//  Copyright (c) 2012年 Sohu.com Inc. All rights reserved.
//

#import <MediaPlayer/MediaPlayer.h>
#import "SNLiveRoomContentCell.h"
#import "UIColor+ColorUtils.h"
#import "SNLiveRoomTableViewController.h"
#import "SNLiveRoomConsts.h"
#import "SNLiveContentObjects.h"
#import "SNLiveRoomTapView.h"
#import "SNThemeManager.h"
#import "SNSoundManager.h"
#import "SNUserUtility.h"
#import "SNLiveBannerView.h"
#import "SNLiveRoomViewController.h"
#import "UIImageView+WebCache.h"
#import "SNVideoObjects.h"
#import "SNADReport.h"
#import "SNUserManager.h"
#import "SNNewsLoginManager.h"


@implementation SNLiveRoomContentCell
@synthesize contentLabel=_contentLabel;
@synthesize viewController=_viewController;
@synthesize authorColor, timeColor;
@synthesize imgView = _imgView;
@synthesize replyImgView = _replyImgView;
@synthesize bgnImgView = _bgnImgView;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString*)identifier {
	self = [super initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:identifier];
    if (self) {
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        
        [SNNotificationManager addObserver:self
                                                 selector:@selector(updateTheme:)
                                                     name:kThemeDidChangeNotification
                                                   object:nil];
        
        // 背景
        _bgnImgView = [[UIImageView alloc] initWithFrame:CGRectZero];
        UIImage *img = [UIImage imageNamed:@"live_content_bg.png"];
        
        if ([img respondsToSelector:@selector(resizableImageWithCapInsets:)]) {
            _bgnImgView.image = [img resizableImageWithCapInsets:UIEdgeInsetsMake(40, 30, 30, 30)];
        }
        else {
            _bgnImgView.image = [img stretchableImageWithLeftCapWidth:30 topCapHeight:40];
        }
        [self.contentView addSubview:_bgnImgView];
        _bgnImgView.userInteractionEnabled = YES;
        //[_bgnImgView setBackgroundColor:[UIColor greenColor]];
        
        self.authorColor = [UIColor colorFromString:[[SNThemeManager sharedThemeManager] currentThemeValueForKey:kAuthorNameColor]];
        self.timeColor = [UIColor colorFromString:[[SNThemeManager sharedThemeManager] currentThemeValueForKey:kReplyAuthorNameColor]];
        
        _contentLabel = [[SNLabel alloc] initWithFrame:CGRectZero];
        _contentLabel.font = CONTENT_FONT;
        _contentLabel.delegate = self;
        _contentLabel.lineHeight = CONTENT_LINE_HEIGHT;
        _contentLabel.textColor = [UIColor colorFromString:[[SNThemeManager sharedThemeManager] currentThemeValueForKey:kLiveRoomContentColor]];
        
        _timeLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _timeLabel.textAlignment = NSTextAlignmentRight;
        _timeLabel.font = TIME_FONT;
        _timeLabel.textColor = self.timeColor;
        _timeLabel.backgroundColor = [UIColor clearColor];//[UIColor colorWithWhite:1 alpha:0.7];
        [_bgnImgView addSubview:_timeLabel];
        //_timeLabel.backgroundColor = [UIColor cyanColor];
        
        _headIcon = [[SNLiveHeadIconView alloc] initWithFrame:CGRectMake(HEAD_X, HEAD_Y, HEAD_W, HEAD_W)];
        _headIcon.alpha = themeImageAlphaValue();
        [self.contentView addSubview:_headIcon];
        
        _roleLabel = [[UILabel alloc] initWithFrame:CGRectMake(ROLE_X, ROLE_Y, ROLE_W, ROLE_H)];
        _roleLabel.backgroundColor = [UIColor clearColor];
        _roleLabel.font = ROLE_FONT;
        _roleLabel.textAlignment = NSTextAlignmentCenter;
        _roleLabel.adjustsFontSizeToFitWidth = YES;
        [self.contentView addSubview:_roleLabel];

        // 顶部点击响应区域
        _topTapView = [[SNLiveRoomTapView alloc] initWithFrame:CGRectZero];
        _topTapView.cell = self;
        [_bgnImgView addSubview:_topTapView];
        //_topTapView.backgroundColor = [[UIColor redColor] colorWithAlphaComponent:0.2];
        [_bgnImgView addSubview:_contentLabel];

        
        _authorBtn = [[SNNameButton alloc] initWithFrame:CGRectZero];
        _authorBtn.titleLabel.font = AUTHOR_FONT;
        [_authorBtn setTitleColor:self.authorColor forState:UIControlStateNormal];
        [_authorBtn addTarget:self action:@selector(clickNameBtn:) forControlEvents:UIControlEventTouchUpInside];
        [_bgnImgView addSubview:_authorBtn];
        
        _tuiguang = [[UILabel alloc] initWithFrame:CGRectZero];
        _tuiguang.font = [UIFont systemFontOfSize:kThemeFontSizeB];
        _tuiguang.textColor = [[SNThemeManager sharedThemeManager] currentThemeColorForKey:kThemeText3Color];
        _tuiguang.textAlignment = NSTextAlignmentRight;
        _tuiguang.backgroundColor = [UIColor clearColor];
        [_bgnImgView addSubview:_tuiguang];
        
        _authorBadge = [[SNBadgeView alloc] init];
        _authorBadge.delegate = self;
        [_bgnImgView addSubview:_authorBadge];
        
        _showAllContentBtn = [[SNNameButton alloc] initWithFrame:CGRectZero];
        _showAllContentBtn.titleLabel.font = SHOWALL_BTN_FONT;
        [_showAllContentBtn setTitle:@"显示更多" forState:UIControlStateNormal];
        [_showAllContentBtn setTitleColor:self.authorColor forState:UIControlStateNormal];
        [_showAllContentBtn addTarget:self action:@selector(clickShowAllContent:) forControlEvents:UIControlEventTouchUpInside];
        [_bgnImgView addSubview:_showAllContentBtn];
        [_showAllContentBtn sizeToFit];
        
        // 链接
        _linkView = [[SNLiveLinkView alloc] initWithFrame:CGRectMake(0, 0, CONTENT_W, LINK_H)];
        [_bgnImgView addSubview:_linkView];
        
        // 音频
        _soundView = [[SNLiveSoundView alloc] initWithFrame:CGRectZero];
        [_bgnImgView addSubview:_soundView];

        // 图片
        _imgView = [[SNSTFWebImageView alloc] init];
        _imgView.contentMode = UIViewContentModeScaleAspectFill;
        _imgView.clipsToBounds = YES;
        _imgView.layer.cornerRadius = 2.0f;
        _imgView.defaultImage = [self imgViewPlaceholderImage];

        _imgView.layer.borderColor = [UIColor colorFromString:[[SNThemeManager sharedThemeManager] currentThemeValueForKey:kRollingNewsCellPhotoBorderColor]].CGColor;
        
        _imgView.alpha = themeImageAlphaValue();
        [_bgnImgView addSubview:_imgView];
        
        // 时长
        _mediaLengthLabel = [[UILabel alloc] init];
        [_imgView addSubview:_mediaLengthLabel];
        _mediaLengthLabel.textAlignment = NSTextAlignmentLeft;
        _mediaLengthLabel.font = MEDIA_LENGTH_FONT;
        _mediaLengthLabel.textColor = [UIColor whiteColor];
        _mediaLengthLabel.shadowColor = [UIColor blackColor];
        _mediaLengthLabel.backgroundColor = [UIColor clearColor];//[[UIColor greenColor] colorWithAlphaComponent:0.8];
        
        // 视频大小
        _mediaSizeLabel = [[UILabel alloc] init];
        [_imgView addSubview:_mediaSizeLabel];
        _mediaSizeLabel.textAlignment = NSTextAlignmentRight;
        _mediaSizeLabel.font = MEDIA_LENGTH_FONT;
        _mediaSizeLabel.textColor = [UIColor whiteColor];
        _mediaSizeLabel.shadowColor = [UIColor blackColor];
        _mediaSizeLabel.backgroundColor = [UIColor clearColor];//[[UIColor greenColor] colorWithAlphaComponent:0.8];
        
        // 点击按钮
        _maskBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _maskBtn.backgroundColor = [UIColor clearColor];
        _maskBtn.frame = _imgView.frame;
        [_maskBtn addTarget:self action:@selector(onImgClick:) forControlEvents:UIControlEventTouchUpInside];
        [_bgnImgView addSubview:_maskBtn];
        
        // 回复
        UIImage *sepLineImage = [UIImage imageNamed:@"live_reply_line.png"];
        _sepLine = [[UIImageView alloc] initWithImage:[sepLineImage resizableImageWithCapInsets:UIEdgeInsetsMake(0, sepLineImage.size.width / 2 - 1, 0, sepLineImage.size.width / 2 + 1)]];
        _sepLine.size = CGSizeMake(kAppScreenWidth - 90, 7);
        [_bgnImgView addSubview:_sepLine];
        
        _replyContentLabel = [[SNLabel alloc] initWithFrame:CGRectZero];
        _replyContentLabel.font = CONTENT_FONT;
        _replyContentLabel.lineHeight = CONTENT_LINE_HEIGHT;
        _replyContentLabel.delegate = self;
        _replyContentLabel.textColor = self.timeColor;
        
        _replyTimeLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _replyTimeLabel.textAlignment = NSTextAlignmentRight;
        _replyTimeLabel.font = TIME_FONT;
        _replyTimeLabel.textColor = self.timeColor;
        _replyTimeLabel.backgroundColor = [UIColor clearColor];//[UIColor colorWithWhite:1 alpha:0.7];
        [_bgnImgView addSubview:_replyTimeLabel];
        //_replyTimeLabel.backgroundColor = [UIColor cyanColor];
        // 底部点击响应区域
        _bottomTapView = [[SNLiveRoomTapView alloc] initWithFrame:CGRectZero];
        _bottomTapView.cell = self;
        [_bgnImgView addSubview:_bottomTapView];
        
        [_bgnImgView addSubview:_replyContentLabel];
        
        _replyAuthorBtn = [[SNNameButton alloc] initWithFrame:CGRectZero];
        _replyAuthorBtn.titleLabel.font = AUTHOR_FONT;
        [_replyAuthorBtn setTitleColor:self.authorColor forState:UIControlStateNormal];
        [_replyAuthorBtn addTarget:self action:@selector(clickNameBtn:) forControlEvents:UIControlEventTouchUpInside];
        [_bgnImgView addSubview:_replyAuthorBtn];
        
        _replyAuthorBadge = [[SNBadgeView alloc] init];
        _replyAuthorBadge.delegate = self;
        [_bgnImgView addSubview:_replyAuthorBadge];

        _showAllReplyCommentBtn = [[SNNameButton alloc] initWithFrame:CGRectZero];
        _showAllReplyCommentBtn.titleLabel.font = CONTENT_FONT;
        [_showAllReplyCommentBtn setTitle:@"显示更多" forState:UIControlStateNormal];
        [_showAllReplyCommentBtn setTitleColor:self.authorColor forState:UIControlStateNormal];
        [_showAllReplyCommentBtn addTarget:self action:@selector(clickShowAllContent:) forControlEvents:UIControlEventTouchUpInside];
        [_bgnImgView addSubview:_showAllReplyCommentBtn];
        [_showAllReplyCommentBtn sizeToFit];

        _replyLinkView = [[SNLiveLinkView alloc] initWithFrame:CGRectMake(0, 0, CONTENT_W, LINK_H)];
        [_bgnImgView addSubview:_replyLinkView];
        
        _replySoundView = [[SNLiveSoundView alloc] initWithFrame:CGRectZero];
        [_bgnImgView addSubview:_replySoundView];

        // 回复图片
        _replyImgView = [[SNWebImageView alloc] init];
        _replyImgView.contentMode = UIViewContentModeScaleAspectFill;
        _replyImgView.clipsToBounds = YES;
        _replyImgView.layer.cornerRadius = 2.0f;
        _replyImgView.defaultImage = [self imgViewPlaceholderImage];
        _replyImgView.alpha = themeImageAlphaValue();
        [_bgnImgView addSubview:_replyImgView];
        _replyImgView.layer.borderColor = _imgView.layer.borderColor;
        
        // 时长
        _replyMediaLengthLabel = [[UILabel alloc] init];
        [_replyImgView addSubview:_replyMediaLengthLabel];
        _replyMediaLengthLabel.textAlignment = NSTextAlignmentLeft;
        _replyMediaLengthLabel.font = MEDIA_LENGTH_FONT;
        _replyMediaLengthLabel.textColor = [UIColor whiteColor];
        _replyMediaLengthLabel.shadowColor = [UIColor blackColor];
        _replyMediaLengthLabel.backgroundColor = [UIColor clearColor];
        
        // 视频大小
        _replyMediaSizeLabel = [[UILabel alloc] init];
        [_replyImgView addSubview:_replyMediaSizeLabel];
        _replyMediaSizeLabel.textAlignment = NSTextAlignmentRight;
        _replyMediaSizeLabel.font = MEDIA_LENGTH_FONT;
        _replyMediaSizeLabel.textColor = [UIColor whiteColor];
        _replyMediaSizeLabel.shadowColor = [UIColor blackColor];
        _replyMediaSizeLabel.backgroundColor = [UIColor clearColor];
        
        // 回复点击按钮
        _replyMaskBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _replyMaskBtn.backgroundColor = [UIColor clearColor];
        _replyMaskBtn.frame = _replyImgView.frame;
        [_replyMaskBtn addTarget:self action:@selector(onImgClick:) forControlEvents:UIControlEventTouchUpInside];
        [_bgnImgView addSubview:_replyMaskBtn];
    }
    return self;
}

- (void)updateTheme:(NSNotification *)notification {
    // 背景
    if ([self.object isKindOfClass:[SNLiveContentObject class]]) {
        UIImage *img = [UIImage imageNamed:@"live_content_bg.png"];
        
        if ([img respondsToSelector:@selector(resizableImageWithCapInsets:)]) {
            _bgnImgView.image = [img resizableImageWithCapInsets:UIEdgeInsetsMake(40, 30, 30, 30)];
        }
        else {
            _bgnImgView.image = [img stretchableImageWithLeftCapWidth:30 topCapHeight:40];
        }
    }
    
    float alpha = themeImageAlphaValue();
    _headIcon.alpha = alpha;
    NSString *headDefaultImageName;
    if ([self.object isKindOfClass:[SNLiveContentObject class]]) {
        headDefaultImageName = (self.object.authorInfo.gender == GenderFemale ? @"live_female_head.png" : @"live_cell_head.png");
    } else {
        headDefaultImageName = (self.object.authorInfo.gender == GenderFemale ? kDftImageKeyFemale : kDftImageKeyMale);
    }
    [_headIcon setDefaultImage:[UIImage imageNamed:headDefaultImageName]];
    [_headIcon updateTheme];
    
    NSString *strColor = [[SNThemeManager sharedThemeManager] currentThemeValueForKey:kAuthorNameColor];
    self.authorColor = [UIColor colorFromString:strColor];
    strColor = [[SNThemeManager sharedThemeManager] currentThemeValueForKey:kReplyAuthorNameColor];
    self.timeColor = [UIColor colorFromString:strColor];

    [_authorBtn setTitleColor:self.authorColor forState:UIControlStateNormal];
    [_showAllContentBtn setTitleColor:self.authorColor forState:UIControlStateNormal];
    [_showAllReplyCommentBtn setTitleColor:self.authorColor forState:UIControlStateNormal];
    
    strColor = [[SNThemeManager sharedThemeManager] currentThemeValueForKey:kLiveRoomContentColor];
    _contentLabel.textColor = [UIColor colorFromString:strColor];
    
    _timeLabel.textColor = self.timeColor;
    
    NSString *borderColor = [[SNThemeManager sharedThemeManager] currentThemeValueForKey:kRollingNewsCellPhotoBorderColor];
    _imgView.layer.borderColor = [UIColor colorFromString:borderColor].CGColor;
    _imgView.alpha = alpha;
    _imgView.defaultImage = [self imgViewPlaceholderImage];
    
    _replyImgView.layer.borderColor = _imgView.layer.borderColor;
    _replyImgView.alpha = _imgView.alpha;
    _replyImgView.defaultImage = [self imgViewPlaceholderImage];
    
    [_replyAuthorBtn setTitleColor:self.authorColor forState:UIControlStateNormal];
    
    _replyContentLabel.textColor = self.timeColor;
    
    _replyTimeLabel.textColor = self.timeColor;
    
    _sepLine.image = [UIImage imageNamed:@"live_reply_line.png"];
    
    [_linkView updateTheme];
    [_replyLinkView updateTheme];
    [_soundView updateTheme];
    [_replySoundView updateTheme];
    [_maskBtn setImage:[UIImage imageNamed:@"timeline_videoplay_poster_play_btn.png"] forState:UIControlStateNormal];
    [_replyMaskBtn setImage:[UIImage imageNamed:@"timeline_videoplay_poster_play_btn.png"] forState:UIControlStateNormal];
    
    _tuiguang.textColor = [[SNThemeManager sharedThemeManager] currentThemeColorForKey:kThemeText3Color];
}

- (void)dealloc {
    [SNNotificationManager removeObserver:self];
    _authorBadge.delegate = nil;
    [_imgView sd_cancelCurrentImageLoad];
    _replyAuthorBadge.delegate = nil;
    [_replyImgView sd_cancelCurrentImageLoad];
}

+ (CGFloat)tableView:(UITableView*)tableView rowHeightForObject:(id)object {
    SNLiveContentObject* data = object;
    CGFloat top = kGap;
    top += AUTHOR_Y + 17 + AUTHOR_CONTENT_GAP;
    
    if (data.action.length > 0) {
        if (data.contentH1 <= 0) {
            CGSize contentSize = [SNLabel sizeForContent:data.action maxSize:CGSizeMake(CONTENT_W, CGFLOAT_MAX_CORE_TEXT) font:CONTENT_FONT.pointSize lineHeight:CONTENT_LINE_HEIGHT];
            data.contentH1 = contentSize.height;
        }
        
        if (data.showAllContent) {
            top += data.contentH1 + AUTHOR_CONTENT_GAP;
        } else {
            if (data.contentH2 <= 0) {                
                CGSize newSize = [SNLabel sizeForContent:data.action maxSize:CGSizeMake(CONTENT_W, CONTENT_H) font:CONTENT_FONT.pointSize lineHeight:CONTENT_LINE_HEIGHT];
                data.contentH2 = newSize.height;
            }
            
            if (data.contentH1 > data.contentH2 + CONTENT_H_2) {
                top += data.contentH2 + SHOW_MORE_GAP;
                top += SHOW_MORE_H + AUTHOR_CONTENT_GAP;
            } else {
                data.showAllContent = YES;
                top += data.contentH1 + AUTHOR_CONTENT_GAP;
            }
        }
    }

    // 链接
    if (data.link.length > 0) {
        top += LINK_H + AUTHOR_CONTENT_GAP;
    }
    
    // 音频
    else if ([data hasSound]) {
        top += SOUND_H + AUTHOR_CONTENT_GAP;
    }
    
    // 视频
    if ([data hasVideo]) {
        top += IMG_H + AUTHOR_CONTENT_GAP;
    }
    
    // 图片
    else if ([data hasGIF] || data.contentPic.length) {
    
        if([data isKindOfClass:[SNLiveRollAdContentObject class]]){
            top += IMG_W/2 + AUTHOR_CONTENT_GAP;
        }else{
            top += IMG_H + AUTHOR_CONTENT_GAP;
        }
    }
    
    if ([data hasReply]) {
        top += REPLY_LINE_H + AUTHOR_CONTENT_GAP;
        top += 17 + AUTHOR_CONTENT_GAP;
        if (data.replyComment.content.length > 0) {
            if (data.replyComment.contentH1 <= 0) {
                CGSize contentSize = [SNLabel sizeForContent:data.replyComment.content maxSize:CGSizeMake(CONTENT_W, CGFLOAT_MAX_CORE_TEXT) font:CONTENT_FONT.pointSize lineHeight:CONTENT_LINE_HEIGHT];
                data.replyComment.contentH1 = contentSize.height;
            }
            
            if (data.replyComment.showAllComment) {
                top += data.replyComment.contentH1 + AUTHOR_CONTENT_GAP;
            } else {
                if (data.replyComment.contentH2 <= 0) {
                    CGSize contentSize = [SNLabel sizeForContent:data.replyComment.content maxSize:CGSizeMake(CONTENT_W, CONTENT_H) font:CONTENT_FONT.pointSize lineHeight:CONTENT_LINE_HEIGHT];
                    data.replyComment.contentH2 = contentSize.height;
                }
                
                if (data.replyComment.contentH1 > data.replyComment.contentH2 + CONTENT_H_2) {
                    top += data.replyComment.contentH2 + SHOW_MORE_GAP;
                    top += SHOW_MORE_H + AUTHOR_CONTENT_GAP;
                } else {
                    data.replyComment.showAllComment = YES;
                    top += data.replyComment.contentH1 + AUTHOR_CONTENT_GAP;
                }
            }
        }
        
        if ([data.replyComment hasSound]) {
            top += SOUND_H + AUTHOR_CONTENT_GAP;
        }
        
        if (data.replyComment.imageUrl.length) {
            top += IMG_H + AUTHOR_CONTENT_GAP;
        }
    }
    
    // 回复直播员
    else if ([data hasReplyCont]) {
        top += REPLY_LINE_H + AUTHOR_CONTENT_GAP;
        top += 17 + AUTHOR_CONTENT_GAP;
        if (data.replyContent.action.length > 0) {
            if (data.replyContent.contentH1 <= 0) {
                CGSize contentSize = [SNLabel sizeForContent:data.replyContent.action maxSize:CGSizeMake(CONTENT_W, CGFLOAT_MAX_CORE_TEXT) font:CONTENT_FONT.pointSize lineHeight:CONTENT_LINE_HEIGHT];
                data.replyContent.contentH1 = contentSize.height;
            }
            
            if (data.replyContent.showAllContent) {
                top += data.replyContent.contentH1 + AUTHOR_CONTENT_GAP;
            } else {
                if (data.replyContent.contentH2 <= 0) {
                    CGSize contentSize = [SNLabel sizeForContent:data.replyContent.action maxSize:CGSizeMake(CONTENT_W, CONTENT_H) font:CONTENT_FONT.pointSize lineHeight:CONTENT_LINE_HEIGHT];
                    data.replyContent.contentH2 = contentSize.height;
                }
                
                if (data.replyContent.contentH1 > data.replyContent.contentH2 + CONTENT_H_2) {
                    top += data.replyContent.contentH2 + SHOW_MORE_GAP;
                    top += SHOW_MORE_H + AUTHOR_CONTENT_GAP;
                } else {
                    data.replyContent.showAllContent = YES;
                    top += data.replyContent.contentH1 + AUTHOR_CONTENT_GAP;
                }
            }
        }
        
        // 链接
        if (data.replyContent.link.length > 0) {
            top += LINK_H + AUTHOR_CONTENT_GAP;
        }
        
        // 音频
        else if ([data.replyContent hasSound]) {
            top += SOUND_H + AUTHOR_CONTENT_GAP;
        }
        
        // 视频
        if ([data.replyContent hasVideo]) {
            top += IMG_H + AUTHOR_CONTENT_GAP;
        }
        
        // 图片
        else if ([data.replyContent hasGIF] || data.replyContent.contentPic.length) {
            top += IMG_H + AUTHOR_CONTENT_GAP;
        }
    }

    
    return top + BOTTOM_GAP;
}

- (void)prepareForReuse {
    [super prepareForReuse];
    _timeLabel.text = nil;
    _authorBtn.titleLabel.text = @"";
    _authorBadge.hidden = YES;
    _contentLabel.text = @"";
    _contentLabel.hidden = YES;
    _linkView.hidden = YES;
    _soundView.hidden = YES;
 
    _imgView.hidden = YES;
    _maskBtn.hidden = YES;
    _gifIcon.hidden = YES;
    [_maskBtn setImage:nil forState:UIControlStateNormal];
    
    _showAllContentBtn.hidden = YES;
    
    _sepLine.hidden = YES;
    
    _replyTimeLabel.text = nil;
    _replyTimeLabel.hidden = YES;
    _replyAuthorBtn.titleLabel.text = @"";
    _replyAuthorBtn.hidden = YES;
    _replyAuthorBadge.hidden = YES;
    _replyContentLabel.text = @"";
    _replyContentLabel.hidden = YES;
    _replyLinkView.hidden = YES;
    _replySoundView.hidden = YES;
//    [_replyImgView unsetImage];
//    _replyImgView.urlPath = nil;
    _replyImgView.hidden = YES;
    _replyMaskBtn.hidden = YES;
    _replyGifIcon.hidden = YES;
    
    _showAllReplyCommentBtn.hidden = YES;
}

- (void)hideBottom {
    _sepLine.hidden = YES;
    _replyAuthorBtn.hidden = YES;
    _replyContentLabel.hidden = YES;
    _replyTimeLabel.hidden = YES;
    _replyImgView.hidden = YES;
    _replySoundView.hidden = YES;
    _replyLinkView.hidden = YES;
    _replyMaskBtn.hidden = YES;
    _replyGifIcon.hidden = YES;
    _showAllReplyCommentBtn.hidden = YES;
    [_replyMaskBtn setImage:nil forState:UIControlStateNormal];
}

- (void)setTopWithContentObj:(SNLiveContentObject *)data {
    if (self.object.authorInfo.gender == GenderFemale) {
        [_headIcon setDefaultImage:[UIImage imageNamed:@"live_female_head.png"]];
    } else {
        [_headIcon setDefaultImage:[UIImage imageNamed:@"live_cell_head.png"]];
    }
    [_headIcon setIconUrl:data.authorInfo.authorimg passport:data.authorInfo.passport gender:data.authorInfo.gender];
    [_headIcon setTarget:self tapSelector:@selector(clickHeadIcon:)];
    
    if (data.authorInfo && data.authorInfo.role != UINT8_MAX) {
        SNLiveRoomRole *role = [_viewController.infoObject.allRoles objectAtIndexWithRangeCheck:data.authorInfo.role];
        if (role) {
            _roleLabel.hidden = NO;
            _roleLabel.text = role.rName;
            
            //lijian 2015.04.03
            if([data isKindOfClass:[SNLiveRollAdContentObject class]]){
                _roleLabel.text = data.author;
            }
            
            BOOL isNightMode = [[SNThemeManager sharedThemeManager] isNightTheme];
            _roleLabel.textColor = [UIColor colorFromString:isNightMode ? role.nColor : role.dColor];
        } else {
            _roleLabel.hidden = YES;
        }
    } else {
        _roleLabel.hidden = YES;
    }
    
    [_authorBtn setTitle:data.author forState:UIControlStateNormal];
    [_authorBtn sizeToFit];
    
    _contentLabel.text =  data.action;
    _contentLabel.hidden = (data.action.length == 0);
    _topTapView.canCopy = !_contentLabel.hidden;
    
    if (data.actionTime) {
        NSDate* date = [NSDate dateWithTimeIntervalSince1970:([data.actionTime doubleValue] / 1000)];
        _timeLabel.text = [date formatTimeString];
        [_timeLabel sizeToFit];
    }
    
    if (data.authorInfo.signList) {
        [_authorBadge reloadBadges:data.authorInfo.signList maxHeight:AUTHOR_H - 2];
    } else {
        _authorBadge.hidden = YES;
    }

    if (data.showAllContent || data.contentH1 == 0) {
        _showAllContentBtn.hidden = YES;
    } else {
        _showAllContentBtn.hidden = NO;
    }
    
    // 链接
    _linkView.hidden = (data.link.length == 0);
    [_linkView setLink:data.link];
    
    // 音频
    _soundView.hidden = !(_linkView.hidden && [data hasSound]);
    if (!_soundView.hidden) {
        [_soundView loadIfNeeded];
        _soundView.commentID = [data.contentId stringValue];
        _soundView.url = data.mediaInfo.mediaUrl;
        _soundView.duration = [data.mediaInfo.mediaLength intValue];
        _soundView.liveId = _viewController.parentController.liveId;
    }
    
    // 图片、视频
    if ([data hasVideo] || [data hasGIF] || data.contentPic.length) {
        _imgView.hidden = NO;
        _maskBtn.hidden = NO;
        _gifIcon.hidden = YES;
        
        NSString *imgUrl;
        if ([data hasVideo]) {
            imgUrl = data.mediaInfo.mediaImage;
        } else if ([data hasGIF]) {
            imgUrl = data.mediaInfo.mediaImage;
        } else {
            imgUrl = data.contentPic;
        }
        
        //lijian 2015.04.03
        if([data isKindOfClass:[SNLiveRollAdContentObject class]]){
            [_imgView setDefaultImage:[UIImage themeImageNamed:kThemeImgPlaceholder10]];
        }
        
        [self updateImageView:_imgView withUrl:imgUrl];
        
        if ([data hasVideo]) {
            [_maskBtn setImage:[UIImage imageNamed:@"timeline_videoplay_poster_play_btn.png"] forState:UIControlStateNormal];
            int duration = [data.mediaInfo.mediaLength intValue];
            _mediaLengthLabel.text = [self formatStrForMediaLength:duration];
            
            int mediaSize= [data.mediaInfo.mediaSize intValue];
            _mediaLengthLabel.text = [self formatStrForMediaSize:mediaSize];
        }
        else {
            if ([data hasGIF]) {
                if (!_gifIcon) {
                    _gifIcon = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"gif_icon.png"]];
                    [_bgnImgView addSubview:_gifIcon];
                }
                _gifIcon.bottom = _imgView.bottom;
                _gifIcon.right = _imgView.right;
                _gifIcon.hidden = NO;
            }
            
            _mediaSizeLabel.text = nil;
            _mediaLengthLabel.text = nil;
            [_maskBtn setImage:nil forState:UIControlStateNormal];
        }
    } else {
        _imgView.hidden = YES;
        _maskBtn.hidden = YES;
        _gifIcon.hidden = YES;
        [_maskBtn setImage:nil forState:UIControlStateNormal];
    }
    
    //lijian 2015.04.03
    if([data isKindOfClass:[SNLiveRollAdContentObject class]]){
        [_topTapView setMenuInvalid];
    }
}

- (void)setTopWithCommentObj:(SNLiveCommentObject *)data {
    if (self.object.authorInfo.gender == GenderFemale) {
        [_headIcon setDefaultImage:[UIImage imageNamed:kDftImageKeyFemale]];
    } else {
        [_headIcon setDefaultImage:[UIImage imageNamed:kDftImageKeyMale]];
    }
    [_headIcon setIconUrl:data.authorInfo.authorimg passport:data.authorInfo.passport gender:data.authorInfo.gender];
    [_headIcon setTarget:self tapSelector:@selector(clickHeadIcon:)];
    
    _roleLabel.hidden = YES;
    
    [_authorBtn setTitle:data.author forState:UIControlStateNormal];
    [_authorBtn sizeToFit];
    
    _contentLabel.text = data.content;
    _contentLabel.hidden = (data.content.length == 0);
    _topTapView.canCopy = !_contentLabel.hidden;
    
    if (data.createTime) {
        NSDate* date = [NSDate dateWithTimeIntervalSince1970:([data.createTime doubleValue] / 1000)];
        _timeLabel.text = [date formatTimeString];
        [_timeLabel sizeToFit];
    }
    
    if (data.authorInfo.signList) {
        [_authorBadge reloadBadges:data.authorInfo.signList maxHeight:AUTHOR_H - 2];
    } else {
        _authorBadge.hidden = YES;
    }
    
    if (data.showAllComment || data.contentH1 == 0) {
        _showAllContentBtn.hidden = YES;
    } else {
        _showAllContentBtn.hidden = NO;
    }
    
    if ([data hasSound]) {
        [_soundView loadIfNeeded];
        _soundView.hidden = NO;
        _soundView.commentID = data.commentId;
        _soundView.url = data.audUrl;
        _soundView.duration = [data.audLen intValue];
        _soundView.liveId = _viewController.parentController.liveId;
    } else {
        _soundView.hidden = YES;
    }
    
    if (data.imageUrl.length > 0) {
        [self updateImageView:_imgView withUrl:data.imageUrl];
        _imgView.hidden = NO;
        _maskBtn.hidden = NO;
    } else {
        _imgView.hidden = YES;
        _maskBtn.hidden = YES;
    }
    
    _linkView.hidden = YES;
}

- (void)setBottomWithContentObj:(SNLiveContentObject *)data {
    _sepLine.hidden = NO;
    [_replyAuthorBtn setTitle:data.author forState:UIControlStateNormal];
    [_replyAuthorBtn sizeToFit];
    
    _replyContentLabel.text = data.action;
    _replyContentLabel.hidden = (data.action.length == 0);
    _bottomTapView.canCopy = !_replyContentLabel.hidden;
    
    if (data.showAllContent || data.contentH1 == 0) {
        _showAllReplyCommentBtn.hidden = YES;
    } else {
        _showAllReplyCommentBtn.hidden = NO;
    }
    
    if (data.actionTime) {
        NSDate* date = [NSDate dateWithTimeIntervalSince1970:([data.actionTime doubleValue] / 1000)];
        _replyTimeLabel.text = [date formatTimeString];
        [_replyTimeLabel sizeToFit];
    }
    _replyAuthorBtn.hidden = NO;
    _replyTimeLabel.hidden = NO;
    
    if (data.authorInfo.signList) {
        [_replyAuthorBadge reloadBadges:data.authorInfo.signList maxHeight:AUTHOR_H - 2];
    } else {
        _replyAuthorBadge.hidden = YES;
    }
    
    // 链接
    _replyLinkView.hidden = (data.link.length == 0);
    [_replyLinkView setLink:data.link];
    
    if ([data hasSound]) {
        [_replySoundView loadIfNeeded];
        _replySoundView.hidden = NO;
        _replySoundView.url = data.mediaInfo.mediaUrl;
        _replySoundView.duration = [data.mediaInfo.mediaLength intValue];
    } else {
        _replySoundView.hidden = YES;
    }
    
    _replyGifIcon.hidden = YES;
    
    if ([data hasVideo] || [data hasGIF] ||data.contentPic.length) {
        _replyImgView.hidden = NO;
        _replyMaskBtn.hidden = NO;
        
        NSString *imgUrl;
        if ([data hasVideo]) {
            imgUrl = data.mediaInfo.mediaImage;
        } else if ([data hasGIF]) {
            imgUrl = data.mediaInfo.mediaImage;
        } else {
            imgUrl = data.contentPic;
        }

        [self updateImageView:_replyImgView withUrl:imgUrl];
        
        if ([data hasVideo]) {
            [_replyMaskBtn setImage:[UIImage imageNamed:@"timeline_videoplay_poster_play_btn.png"] forState:UIControlStateNormal];
            int duration = [data.mediaInfo.mediaLength intValue];
            _replyMediaLengthLabel.text = [self formatStrForMediaLength:duration];
            
            int mediaSize= [data.mediaInfo.mediaSize intValue];
            _replyMediaLengthLabel.text = [self formatStrForMediaSize:mediaSize];
        } else {
            if ([data hasGIF]) {
                if (!_replyGifIcon) {
                    _replyGifIcon = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"gif_icon.png"]];
                    [_bgnImgView addSubview:_replyGifIcon];
                }
                _replyGifIcon.bottom = _imgView.bottom;
                _replyGifIcon.right = _imgView.right;
                _replyGifIcon.hidden = NO;
            }
            _replyMediaSizeLabel.text = nil;
            _replyMediaLengthLabel.text = nil;
            [_replyMaskBtn setImage:nil forState:UIControlStateNormal];
        }
    } else {
        _replyImgView.hidden = YES;
        _replyMaskBtn.hidden = YES;
        [_replyMaskBtn setImage:nil forState:UIControlStateNormal];
    }
}

- (void)setBottomWithCommentObj:(SNLiveCommentObject *)data {
    _sepLine.hidden = NO;
    [_replyAuthorBtn setTitle:data.author forState:UIControlStateNormal];
    [_replyAuthorBtn sizeToFit];
    
    _replyContentLabel.text = data.content;
    _replyContentLabel.hidden = (data.content.length == 0);
    _bottomTapView.canCopy = !_replyContentLabel.hidden;
    
    if (data.showAllComment || data.contentH1 == 0) {
        _showAllReplyCommentBtn.hidden = YES;
    } else {
        _showAllReplyCommentBtn.hidden = NO;
    }
    
    if (data.createTime) {
        NSDate* date = [NSDate dateWithTimeIntervalSince1970:([data.createTime doubleValue] / 1000)];
        _replyTimeLabel.text = [date formatTimeString];
        [_replyTimeLabel sizeToFit];
    }
    _replyAuthorBtn.hidden = NO;
    _replyTimeLabel.hidden = NO;
    
    if (data.authorInfo.signList) {
        [_replyAuthorBadge reloadBadges:data.authorInfo.signList maxHeight:AUTHOR_H - 2];
    } else {
        _replyAuthorBadge.hidden = YES;
    }
    
    if ([data hasSound]) {
        [_replySoundView loadIfNeeded];
        _replySoundView.hidden = NO;
        _replySoundView.url = data.audUrl;
        _replySoundView.duration = [data.audLen intValue];
    } else {
        _replySoundView.hidden = YES;
    }
    
    _replyLinkView.hidden = YES;
    
    if (data.imageUrl.length) {
        _replyImgView.hidden = NO;
        _replyMaskBtn.hidden = NO;
        [self updateImageView:_replyImgView withUrl:data.imageUrl];
    } else {
        _replyImgView.hidden = YES;
        _replyMaskBtn.hidden = YES;
    }
}

- (void)setObject:(id)object {
	if (_object != object) {
		[super setObject:object];
		
        if ([object isKindOfClass:[SNLiveContentObject class]]) {
            SNLiveContentObject* data = object;
            
            // 主持人
            [self setTopWithContentObj:data];
            
            // 回复网友
            if ([data hasReply]) {
                if ([data.replyComment hasSound]) {
                    _replySoundView.commentID = [data.contentId stringValue];
                }
                [self setBottomWithCommentObj:data.replyComment];
            }
            // 回复主持人
            else if ([data hasReplyCont]) {
                if ([data.replyContent hasSound]) {
                    _replySoundView.commentID = [data.contentId stringValue];
                }
                [self setBottomWithContentObj:data.replyContent];
            }
            else {
                [self hideBottom];
            }
        }
	}
}

- (CGFloat)layoutReplyComment:(SNLiveCommentObject *)data left:(CGFloat)left top:(CGFloat)top {
    _sepLine.origin = CGPointMake(left, top);
    top += _sepLine.height + AUTHOR_CONTENT_GAP - 2;
    
    _replyAuthorBtn.frame = CGRectMake(left, top, (_replyAuthorBtn.width > AUTHOR_W ? AUTHOR_W : _replyAuthorBtn.width), AUTHOR_H);
    
    _replyTimeLabel.frame = CGRectMake(_bgnImgView.width - TIME_RIGHT_GAP - _replyTimeLabel.width/*TIME_W*/, _replyAuthorBtn.frame.origin.y, _replyTimeLabel.width/*TIME_W*/, _replyAuthorBtn.frame.size.height);
    top += 17 + AUTHOR_CONTENT_GAP;
    
    [self layoutBottomBadgeView];
    
    // 回复内容
    if (_replyContentLabel.text.length > 0) {
        if (data.showAllComment) {
            _replyContentLabel.frame = CGRectMake(left, top, CONTENT_W, data.contentH1);
            top += data.contentH1 + AUTHOR_CONTENT_GAP;
        } else {
            _replyContentLabel.frame = CGRectMake(left, top, CONTENT_W, data.contentH2);
            top += data.contentH2 + SHOW_MORE_GAP;
            
            _showAllReplyCommentBtn.frame = CGRectMake(left, top, _showAllReplyCommentBtn.width, SHOW_MORE_H);
            top += SHOW_MORE_H + AUTHOR_CONTENT_GAP;
        }
    } else {
        _showAllReplyCommentBtn.hidden = YES;
    }
    
    if ([data hasSound]) {
        _replySoundView.frame = CGRectMake(left - SOUND_OFFSETX, top, CONTENT_W, SOUND_H);
        top += SOUND_H + AUTHOR_CONTENT_GAP;
    }
    
    _bottomTapView.frame = CGRectMake(left, _replyAuthorBtn.top, CONTENT_W, top - _replyAuthorBtn.top);
    
    if (data.imageUrl.length) {
        _replyImgView.frame = CGRectMake(left, top, IMG_W, IMG_H);
        _replyMaskBtn.frame = _replyImgView.frame;
        top += IMG_H + AUTHOR_CONTENT_GAP;
    }
    
    return top;
}

- (CGFloat)layoutReplyContent:(SNLiveContentObject *)data left:(CGFloat)left top:(CGFloat)top {
    _sepLine.origin = CGPointMake(left, top);
    top += _sepLine.height + AUTHOR_CONTENT_GAP - 2;
    
    _replyAuthorBtn.frame = CGRectMake(left, top, (_replyAuthorBtn.width > AUTHOR_W ? AUTHOR_W : _replyAuthorBtn.width), AUTHOR_H);
    
    _replyTimeLabel.frame = CGRectMake(_bgnImgView.width - TIME_RIGHT_GAP - _replyTimeLabel.width/*TIME_W*/, _replyAuthorBtn.frame.origin.y, _replyTimeLabel.width/*TIME_W*/, _replyAuthorBtn.frame.size.height);
    top += 17 + AUTHOR_CONTENT_GAP;
    
    [self layoutBottomBadgeView];
    
    // 回复内容
    if (_replyContentLabel.text.length > 0) {
        
        if (data.showAllContent) {
            _replyContentLabel.frame = CGRectMake(left, top, CONTENT_W, data.contentH1);
            top += data.contentH1 + AUTHOR_CONTENT_GAP;
        } else {
            _replyContentLabel.frame = CGRectMake(left, top, CONTENT_W, data.contentH2);
            top += data.contentH2 + SHOW_MORE_GAP;
            
            _showAllReplyCommentBtn.frame = CGRectMake(left, top, _showAllReplyCommentBtn.width, SHOW_MORE_H);
            top += SHOW_MORE_H + AUTHOR_CONTENT_GAP;
        }
    } else {
        _showAllReplyCommentBtn.hidden = YES;
    }
    
    // 链接
    if (data.link.length) {
        _replyLinkView.frame = CGRectMake(left, top, CONTENT_W, LINK_H);
        top += LINK_H + AUTHOR_CONTENT_GAP;
    }
    // 音频
    else if ([data hasSound]) {
        _replySoundView.frame = CGRectMake(left - SOUND_OFFSETX, top, CONTENT_W, SOUND_H);
        top += SOUND_H + AUTHOR_CONTENT_GAP;
    }
    
    _bottomTapView.frame = CGRectMake(left, _replyAuthorBtn.top, CONTENT_W, top - _replyAuthorBtn.top);
    
    // 图片
    if ([data hasVideo] || data.contentPic.length) {
        _replyImgView.frame = CGRectMake(left, top, IMG_W, IMG_H);
        _replyMaskBtn.frame = _replyImgView.frame;
        top += IMG_H + AUTHOR_CONTENT_GAP;
        if ([data hasVideo]) {
            _replyMediaLengthLabel.frame = CGRectMake(4, IMG_H - 14, 70, 12);
            _replyMediaSizeLabel.frame = CGRectMake(IMG_W -4 -70, IMG_H - 14, 70, 12);
        }
    }
    
    return top;
}

- (void)layoutTopBadgeView {
    if (_timeLabel.left > _authorBtn.right) {
        if (_timeLabel.left - _authorBtn.right - 10 < _authorBadge.totalWidth) {
            _authorBtn.width = _timeLabel.left - 10 - _authorBadge.totalWidth - _authorBtn.left;
        }
        _authorBadge.frame = CGRectMake(_authorBtn.right + 5,
                                        _authorBtn.centerY - _authorBadge.totalHeight/2,
                                        _authorBadge.totalWidth,
                                        _authorBadge.totalHeight);
    }
}

- (void)layoutBottomBadgeView {
    if (_replyTimeLabel.left > _replyAuthorBtn.right) {
        if (_replyTimeLabel.left - _replyAuthorBtn.right - 10 < _replyAuthorBadge.totalWidth) {
            _replyAuthorBtn.width = _replyTimeLabel.left - 10 - _replyAuthorBadge.totalWidth - _replyAuthorBtn.left;
        }
        _replyAuthorBadge.frame = CGRectMake(_replyAuthorBtn.right + 5,
                                             _replyAuthorBtn.centerY - _replyAuthorBadge.totalHeight/2,
                                             _replyAuthorBadge.totalWidth,
                                             _replyAuthorBadge.totalHeight);
    }    
}

- (void)layoutSubviews {
	[super layoutSubviews];
    
    SNLiveContentObject *data = (SNLiveContentObject *)self.object;
    if (![_object isKindOfClass:[SNLiveContentObject class]]) {
        return;
    }
    
    CGFloat width = self.contentView.width - 2*kTableCellMargin;
    _bgnImgView.width = width - _headIcon.width;
    
    _authorBtn.frame = CGRectMake(AUTHOR_X, AUTHOR_Y, (_authorBtn.width > AUTHOR_W ? AUTHOR_W : _authorBtn.width), AUTHOR_H);
    CGFloat top = AUTHOR_Y + 17 + AUTHOR_CONTENT_GAP;
    
    if (_timeLabel.text.length) {
        _timeLabel.frame = CGRectMake(_bgnImgView.width - TIME_RIGHT_GAP - _timeLabel.width/*TIME_W*/, _authorBtn.frame.origin.y, _timeLabel.width/*TIME_W*/, _authorBtn.frame.size.height);
    }
    
    [self layoutTopBadgeView];

    // 内容
    if (_contentLabel.text.length > 0) {
        if (data.showAllContent) {
            _contentLabel.frame = CGRectMake(AUTHOR_X, top, CONTENT_W, data.contentH1);
            top += data.contentH1 + AUTHOR_CONTENT_GAP;
        } else {
            _contentLabel.frame = CGRectMake(AUTHOR_X, top, CONTENT_W, data.contentH2);
            top += data.contentH2 + SHOW_MORE_GAP;
            
            _showAllContentBtn.frame = CGRectMake(AUTHOR_X, top, _showAllContentBtn.width, SHOW_MORE_H);
            top += SHOW_MORE_H + AUTHOR_CONTENT_GAP;
        }
        
    } else {
        _showAllContentBtn.hidden = YES;
    }
    
    // 链接
    if (data.link.length) {
        _linkView.frame = CGRectMake(AUTHOR_X, top, CONTENT_W, LINK_H);
        top += LINK_H + AUTHOR_CONTENT_GAP;
    }
    
    // 音频
    else if ([data hasSound]) {
        [_soundView loadIfNeeded];
        _soundView.frame = CGRectMake(SOUND_X, top, CONTENT_W, SOUND_H);
        top += SOUND_H + AUTHOR_CONTENT_GAP;
    }
    
    _topTapView.frame = CGRectMake(AUTHOR_X, AUTHOR_Y, CONTENT_W, top - AUTHOR_Y);

    // 视频、图片
    if ([data hasVideo] || [data hasGIF] || !_imgView.hidden) {
        _imgView.frame = CGRectMake(AUTHOR_X, top, IMG_W, IMG_H);
        
        if([data isKindOfClass:[SNLiveRollAdContentObject class]]){
            _imgView.frame = CGRectMake(AUTHOR_X, top, IMG_W, IMG_W/2);
        }
        
        _maskBtn.frame = _imgView.frame;
        top += _imgView.height + AUTHOR_CONTENT_GAP;
        if ([data hasVideo]) {
            _mediaLengthLabel.frame = CGRectMake(4, IMG_H - 14, 70, 12);
            _mediaSizeLabel.frame = CGRectMake(IMG_W -4 -70, IMG_H - 14, 70, 12);
        } else if ([data hasGIF]) {
            _gifIcon.bottom = _imgView.bottom;
            _gifIcon.right = _imgView.right;
        }
    }
        
    // 回复
    if ([data hasReply]) {
        top = [self layoutReplyComment:data.replyComment left:AUTHOR_X top:top];
    }
    
    // 回复主持人
    else if ([data hasReplyCont]) {
        top = [self layoutReplyContent:data.replyContent left:AUTHOR_X top:top];
    }

    else {
        _bottomTapView.frame = CGRectZero;
        _showAllReplyCommentBtn.hidden = YES;
    }

    
    // 气泡背景
    _bgnImgView.frame = CGRectMake(_headIcon.right, _headIcon.top - 4, width - _headIcon.width, top + BOTTOM_GAP);
    
    //流内广告的推广
    if([data isKindOfClass:[SNLiveRollAdContentObject class]]){
        SNLiveRollAdContentObject *obj = (SNLiveRollAdContentObject *)data;
        _tuiguang.text = [NSString stringWithFormat:@"%@广告", obj.adInfo.dsp_source ? : @""];
        CGSize size = [_tuiguang.text sizeWithFont:_tuiguang.font];
        _tuiguang.frame = CGRectMake(0, 0, size.width, size.height);
        _tuiguang.bottom = _authorBtn.bottom;
        _tuiguang.right = _contentLabel.right;
        [_bgnImgView addSubview:_tuiguang];
    }else{
        [_tuiguang removeFromSuperview];
    }
}

#if 0
- (void)drawRect:(CGRect)rect {
	[super drawRect:rect];
	
    [SNUtility drawCellSeperateLine:rect];
}
#endif

- (void)onImgClick:(id)sender {
    SNWebImageView *imgView = nil;
    NSString *imageUrl = nil;
    
    SNLiveContentObject *data = (SNLiveContentObject *)self.object;

    BOOL bClickTop = (sender == _maskBtn);
    
    if (bClickTop) {
        imgView = _imgView;
        imageUrl = [self topImageViewUrl];
    } else {
        imgView = _replyImgView;
        imageUrl = [self bottomImageViewUrl];
    }
    
    if (imgView.image == [self imgViewPlaceholderImage]) {
        [self loadImageView:imgView withUrl:imageUrl];
    } else {
        if (!imgView.isLoading && !imgView.isLoaded) {
            [self loadImageView:imgView withUrl:imageUrl];
        }
        // 图片
        else {
            //触发 单独发的或回复的内容部分
            if (bClickTop) {
                
                //lijian 2015.04.03
                if([data isKindOfClass:[SNLiveRollAdContentObject class]]){
                    if(data.contentPicLink){
                        SNLiveRollAdContentObject *obj = (SNLiveRollAdContentObject *)data;
                        
                        
                        if ([SNUtility openProtocolUrl:data.contentPicLink] && data.contentPicLink.length > 0) {
                            [SNADReport reportClick:obj.adInfo.reportID];
                        }
                        
                        return;
                    }
                }
                
                if ([data hasVideo]) {
                    [self showVideoControllerWithUrl:data.mediaInfo.mediaUrl poster:imageUrl videoPlaceHolderFrame:_imgView.frame];
                } else if (imgView.isLoaded) {
                    // 显示大图
                    if ([_viewController respondsToSelector:@selector(showImageWithUrl:)]) {
                        if ([data hasGIF]) {
                            imageUrl = data.mediaInfo.mediaUrl;
                        }
                        [_viewController showImageWithUrl:imageUrl];
                    }
                }
            }
            //触发 被回复的内容部分
            else {
                if ([data hasReply]) {//被回复内容是网友发的 即 回复网友
                    if (imgView.isLoaded) {
                        // 显示大图
                        if ([_viewController respondsToSelector:@selector(showImageWithUrl:)]) {
                            [_viewController showImageWithUrl:imageUrl];
                        }
                    }
                } else if ([data hasReplyCont]) {//被回复的内容是主持人发的 即 回复主持人
                    if ([data.replyContent hasVideo]) {
                        [self showVideoControllerWithUrl:data.replyContent.mediaInfo.mediaUrl poster:imageUrl videoPlaceHolderFrame:_replyImgView.frame];
                    } else if (imgView.isLoaded) {
                        // 显示大图
                        if ([_viewController respondsToSelector:@selector(showImageWithUrl:)]) {
                            if ([data hasGIF]) {
                                imageUrl = data.mediaInfo.mediaUrl;
                            }
                            [_viewController showImageWithUrl:imageUrl];
                        }
                    }
                }
            }
        }
    }
}

- (void)showVideoControllerWithUrl:(NSString *)urlPath poster:(NSString *)posterUrl
             videoPlaceHolderFrame:(CGRect)videoPlaceHolderFrame  {
    
    if (urlPath.length > 0) {
        //---
        SNVideoData *videoData = [[SNVideoData alloc] init];
        videoData.vid        = nil;
        videoData.messageId  = nil;
        videoData.title      = @"";
        videoData.abstract   = nil;
        videoData.columnName = nil;
        videoData.link2      = nil;
        
        videoData.poster     = posterUrl;
        videoData.poster_4_3 = nil;
        videoData.smallImageUrl  = nil;
        videoData.wapUrl         = nil;
        
        SNVideoUrl *videoURL = [[SNVideoUrl alloc] init];
        videoURL.m3u8 = urlPath;
        videoData.videoUrl   = videoURL;
        videoData.author     = nil;
        videoData.share      = nil;
        videoData.siteInfo   = nil;
        
        videoData.type       = nil;
        videoData.status     = nil;
        videoData.columnId   = nil;
        videoData.duration   = nil;
        videoData.action     = nil;
        videoData.playType   = WSMVVideoPlayType_Native;
        videoData.playCount  = nil;
        videoData.downloadType = WSMVVideoDownloadType_CantDownload;
        
        videoData.templatePicUrl = nil;
        videoData.multipleType = nil;
        videoData.mediaLink = nil;//视频媒体页
        //---
        [self.viewController.parentController showContentVideo:videoData fromCell:self videoPlaceHolderFrame:videoPlaceHolderFrame];
         //(videoData);
    }
    return;
}

- (BOOL)keyboardShow {
    if (_viewController && [_viewController respondsToSelector:@selector(keyboardShow)]) {
        return (BOOL)[_viewController performSelector:@selector(keyboardShow)];
    }
    return NO;
}

- (void)copyContent:(SNLiveRoomTapView *)sender {
    UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];

    if (sender == _topTapView) {
        if (_contentLabel.text) {
            pasteboard.string = _contentLabel.text;
        }
    } else if (sender == _bottomTapView) {
        if (_replyContentLabel.text) {
            pasteboard.string = _replyContentLabel.text;
        }
    }
}

- (void)replyComment:(SNLiveRoomTapView *)sender {
    if (![SNUserManager isLogin]) {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wundeclared-selector"
        NSValue* method = [NSValue valueWithPointer:@selector(loginSuccess)];
#pragma clang diagnostic pop
        NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:method, @"method", kLoginFromLive, kLoginFromKey, nil];
        //[SNUtility openLoginViewWithDict:dict];
        
        //wangshun login open
        [SNNewsLoginManager loginData:nil Successed:^(NSDictionary *info) {//111直播间实况直播回复评论
            
        } Failed:nil];
        
//#pragma clang diagnostic push
//#pragma clang diagnostic ignored "-Wundeclared-selector"
//        NSValue* method = [NSValue valueWithPointer:@selector(loginSuccess)];
//#pragma clang diagnostic pop
//
//        TTURLAction *_urlAction = [[[TTURLAction actionWithURLPath:@"tt://loginRegister"] applyAnimated:YES] applyQuery:[NSDictionary dictionaryWithObjectsAndKeys:method, @"method", kLoginFromLive, kLoginFromKey, nil]];
//        [[TTNavigator navigator] openURLAction:_urlAction];

        [SNUtility setUserDefaultSourceType:kUserActionIdForLiveChat keyString:kLoginSourceTag];
        return;
    }
    else {
//        SNUserinfoEx *userInfoEx = [SNUserinfoEx userinfoEx];
//        if (!userInfoEx.isRealName) {
//            NSDictionary* dic = [NSDictionary dictionaryWithObjectsAndKeys:@"手机绑定", @"headTitle", @"立即绑定", @"buttonTitle",  nil];
//            TTURLAction *_urlAction = [[[TTURLAction actionWithURLPath:@"tt://mobileNumBindLogin"] applyAnimated:YES] applyQuery:dic];
//            [[TTNavigator navigator] openURLAction:_urlAction];
//            return;
//        }
    }
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wundeclared-selector"
    if (_viewController && [_viewController respondsToSelector:@selector(replyComment:type:name:pid:)]) {
        if ([self.object isKindOfClass:[SNLiveContentObject class]]) {
            SNLiveContentObject *data = (SNLiveContentObject *)self.object;
            
            NSString *rid = nil, *type = nil, *replyName = nil, *replyPid = nil;
            if (sender == _topTapView) {
                // 回复主持人
                rid = [NSString stringWithFormat:@"%lld", [data.contentId longLongValue]];
                type = kReplyLiveContent;
                replyName = data.author;
                replyPid = data.authorInfo.pid;
            } else if (sender == _bottomTapView) {
                // 回复网友
                if ([data hasReply]) {
                    rid = [NSString stringWithFormat:@"%lld", [data.replyComment.rid longLongValue]];
                    type = kReplyLiveComment;
                    replyName = data.replyComment.author;
                    replyPid = data.replyComment.authorInfo.pid;
                }
                else if ([data hasReplyCont]) {
                    // 回复主持人
                    rid = [NSString stringWithFormat:@"%lld", [data.replyContent.contentId longLongValue]];
                    type = kReplyLiveContent;
                    replyName = data.replyContent.author;
                    replyPid = data.replyContent.authorInfo.pid;
                }
            }
            // chh: 设置replyType 网友回复网友：1；网友回复直播员：2
            [_viewController performSelector:@selector(replyComment:type:name:pid:) withObject:rid withObject:type withObject:replyName withObject:replyPid];
        }
    }
}

- (void)shareContent:(SNLiveRoomTapView *)sender {
    if (_viewController && [_viewController respondsToSelector:@selector(shareCommentWithDic:)]) {
        NSString *comment = nil;
        NSString *imageUrl = nil;
        if (sender == _topTapView) {
            comment = _contentLabel.text;
            imageUrl = [self topImageViewUrl];
        } else if (sender == _bottomTapView) {
            comment = _replyContentLabel.text;
            imageUrl = [self bottomImageViewUrl];
        }
        
        if ([self.object isKindOfClass:[SNLiveContentObject class]]) {
            SNLiveContentObject *data = (SNLiveContentObject *)self.object;
            _commentId = [NSString stringWithFormat:@"%@",data.contentId];
        }else if([self.object isKindOfClass:[SNLiveCommentObject class]]) {
            SNLiveCommentObject *data = (SNLiveCommentObject *)self.object;
            _commentId = [NSString stringWithFormat:@"%@",data.commentId?:data.rid];
        }
        NSMutableDictionary *dicInfo = [NSMutableDictionary dictionary];
        if (_commentId.length > 0) {
            [dicInfo setObject:_commentId forKey:@"commentId"];
        }
        if (comment)
            [dicInfo setObject:comment forKey:@"commentContent"];
        
        if (imageUrl)
            [dicInfo setObject:imageUrl forKey:@"commentImageUrl"];
        
        [_viewController performSelector:@selector(shareCommentWithDic:) withObject:dicInfo];
    }
#pragma clang diagnostic pop

}

- (void)clickHeadIcon:(id)sender {
    if ([self.object isKindOfClass:[SNLiveContentObject class]]) {
        SNLiveContentObject *data = (SNLiveContentObject *)self.object;
        NSMutableDictionary * referInfo = [NSMutableDictionary dictionary];
        [referInfo setObject:@"0" forKey:kReferValue];
        [referInfo setObject:@"0" forKey:kReferType];
        [referInfo setObject:[NSNumber numberWithInt:SNProfileRefer_Live_UserName] forKey:kRefer];
        if (data.authorInfo) {
            [SNUserUtility openUserWithPassport:data.authorInfo.passport
                                     spaceLink:data.authorInfo.spaceLink
                                     linkStyle:data.authorInfo.linkStyle
                                           pid:data.authorInfo.pid
                                           push:@"0" refer:referInfo];
        }
    }
}

- (void)clickNameBtn:(id)sender {
    if ([self.object isKindOfClass:[SNLiveContentObject class]]) {
        SNLiveContentObject *data = (SNLiveContentObject *)self.object;
        NSMutableDictionary * referInfo = [NSMutableDictionary dictionary];
        [referInfo setObject:@"0" forKey:kReferValue];
        [referInfo setObject:@"0" forKey:kReferType];
        [referInfo setObject:[NSNumber numberWithInt:SNProfileRefer_Live_UserName] forKey:kRefer];

        if (sender == _authorBtn) {
            if (data.authorInfo) {
                [SNUserUtility openUserWithPassport:data.authorInfo.passport
                                         spaceLink:data.authorInfo.spaceLink
                                         linkStyle:data.authorInfo.linkStyle
                                               pid:data.authorInfo.pid
                                               push:@"0" refer:referInfo];
            }
        }
        else if (sender == _replyAuthorBtn) {
            if (data.replyComment.authorInfo) {
                [SNUserUtility openUserWithPassport:data.replyComment.authorInfo.passport
                                         spaceLink:data.replyComment.authorInfo.spaceLink
                                         linkStyle:data.replyComment.authorInfo.linkStyle
                                               pid:data.replyComment.authorInfo.pid
                                               push:@"0" refer:referInfo];
            }
        }
    }
}

- (void)clickShowAllContent:(id)sender {
    [_topTapView resignFirstResponder];
    if ([self.object isKindOfClass:[SNLiveContentObject class]]) {
        SNLiveContentObject *data = (SNLiveContentObject *)self.object;

        if (sender == _showAllContentBtn) {
            data.showAllContent = YES;
            [self.viewController reloadRowByContentObj:data];
        } else if (sender == _showAllReplyCommentBtn) {
            if ([data hasReply]) {
                data.replyComment.showAllComment = YES;
            } else if ([data hasReplyCont]) {
                data.replyContent.showAllContent = YES;
            }

            [self.viewController reloadRowByContentObj:data];
        }
    }
    else if ([self.object isKindOfClass:[SNLiveCommentObject class]]) {
        SNLiveCommentObject *data = (SNLiveCommentObject *)self.object;
        
        if (sender == _showAllContentBtn) {
            data.showAllComment = YES;
            [self.viewController reloadRowByContentObj:data];
        } else if (sender == _showAllReplyCommentBtn) {
            if ([data hasReply]) {
                data.replyComment.showAllComment = YES;
            } else if ([data hasReplyCont]) {
                data.replyContent.showAllContent = YES;
            }
            [self.viewController reloadRowByContentObj:data];
        }
    }
}

- (NSString *)formatStrForMediaLength:(int)duration {
    NSString *str = nil;
    //duration = arc4random() % 10000;
    if (duration >= 3600) {
        str = [NSString stringWithFormat:@"%02d:%02d:%02d", duration/3600, (duration%3600)/60, duration%60];
    } else if (duration > 0) {
        str = [NSString stringWithFormat:@"%02d:%02d", (duration%3600)/60, duration%60];
    }
    return str;
}

- (NSString *)formatStrForMediaSize:(int)mediaSize {
    NSString *str = nil;
    //mediaSize = arc4random() % 10000;
    if (mediaSize >= 1024 * 1024) {
        str = [NSString stringWithFormat:@"%.1fMB", mediaSize/(1024.0f*1024.0f)];
    } else if (mediaSize >= 1024) {
        str = [NSString stringWithFormat:@"%.1fKB", mediaSize/1024.0f];
    } else if (mediaSize > 0) {
        str = [NSString stringWithFormat:@"%dB", mediaSize];
    }
    return str;
}

- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event
{
    BOOL flag = NO;
    if (!_contentLabel.hidden) {
        for (UIView *btn in _contentLabel.subviews) {
            CGRect rect = [self convertRect:btn.frame fromView:_contentLabel];
            if (CGRectContainsPoint(rect, point)) {
                //flag = YES;
                return [super hitTest:point withEvent:event];
            }
        }
        if (!flag && CGRectContainsPoint(_contentLabel.frame, point)) {
            return _topTapView;
        }
    }

    if (!_replyContentLabel.hidden) {
        for (UIView *btn in _replyContentLabel.subviews) {
            CGRect rect = [self convertRect:btn.frame fromView:_replyContentLabel];
            if (CGRectContainsPoint(rect, point)) {
                //flag = YES;
                return [super hitTest:point withEvent:event];
            }
        }
        if (!flag && CGRectContainsPoint(_replyContentLabel.frame, point)) {
            return _bottomTapView;
        }
    }
    
    return [super hitTest:point withEvent:event];
}

- (UIImage *)imgViewPlaceholderImage {
    UIImage *placeholder = nil;
    if (![SNUtility getApplicationDelegate].shouldDownloadImagesManually) {
        placeholder = [UIImage imageNamed:@"photo_list_default.png"];
    } else {
        placeholder = [UIImage imageNamed:@"photo_list_click_default.png"];
    }
    return placeholder;
}

// 是否下载与网络环境有关
- (void)updateImageView:(SNWebImageView *)imgView withUrl:(NSString *)urlPath {
    imgView.urlPath = urlPath;
}

// 下载图片，无论网络环境
- (void)loadImageView:(SNWebImageView *)imgView withUrl:(NSString *)urlPath {
    [imgView loadUrlPath:urlPath];
}

- (NSString *)topImageViewUrl {
    NSString *imageUrl = nil;
    if ([self.object isKindOfClass:[SNLiveContentObject class]]) {
        SNLiveContentObject *data = (SNLiveContentObject *)self.object;
        imageUrl = ([data hasVideo] || [data hasGIF]) ? data.mediaInfo.mediaImage : data.contentPic;
    } else if ([self.object isKindOfClass:[SNLiveCommentObject class]]) {
        SNLiveCommentObject *data = (SNLiveCommentObject *)self.object;
        imageUrl = data.imageUrl;
    }
    return imageUrl;
}

- (NSString *)bottomImageViewUrl {
    NSString *imageUrl = nil;
    if ([self.object isKindOfClass:[SNLiveContentObject class]]) {
        SNLiveContentObject *data = (SNLiveContentObject *)self.object;
        if ([data hasReply]) {
            imageUrl = data.replyComment.imageUrl;
        } else if ([data hasReplyCont]) {
            imageUrl = ([data.replyContent hasVideo] || [data.replyContent hasGIF]) ? data.replyContent.mediaInfo.mediaImage : data.replyContent.contentPic;
        }
    } else if ([self.object isKindOfClass:[SNLiveCommentObject class]]) {
        SNLiveCommentObject *data = (SNLiveCommentObject *)self.object;
        if ([data hasReply]) {
            imageUrl = data.replyComment.imageUrl;
        } else if ([data hasReplyCont]) {
            imageUrl = ([data.replyContent hasVideo] || [data.replyContent hasVideo]) ? data.replyContent.mediaInfo.mediaImage : data.replyContent.contentPic;
        }
    }
    return imageUrl;
}


#pragma mark - SNBadgeView delegate

- (void)badgeViewWidth:(float)width height:(float)height badgeView:(SNBadgeView *)badgeView {
    if (badgeView == _authorBadge) {
        if (width > 0) {
            _authorBadge.hidden = NO;
            [self layoutTopBadgeView];
        } else {
            _authorBadge.hidden = YES;
        }
    } else if (badgeView == _replyAuthorBadge) {
        if (width > 0) {
            _replyAuthorBadge.hidden = NO;
            [self layoutBottomBadgeView];
        } else {
            _replyAuthorBadge.hidden = YES;
        }
    }
}

@end
