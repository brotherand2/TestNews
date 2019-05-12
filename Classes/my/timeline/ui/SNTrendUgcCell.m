//
//  SNTrendUgcCell.m
//  sohunews
//
//  Created by jialei on 14-3-27.
//  Copyright (c) 2014年 Sohu.com. All rights reserved.
//

#import "SNTrendUgcCell.h"
#import "SNShareManager.h"
#import "SNTimelineConfigs.h"

@interface SNTrendUgcCell()
{
    SNLiveSoundView *_originSoundView;
}

@end

@implementation SNTrendUgcCell

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    
    [SNNotificationManager addObserver:self
                                             selector:@selector(resignActiveFunction)
                                                 name:UIApplicationDidEnterBackgroundNotification object:nil];
    return self;
}

- (void)dealloc
{
    [SNNotificationManager removeObserver:self];
     //(_originSoundView);
    
}

#pragma mark - ViewCell
//动态原文
- (void)setOriginTitleAndFrom
{
    [super setOriginTitleAndFrom];
    
    CGFloat startX = CGRectGetMinX(_originalContentRect);
    CGFloat startY = CGRectGetMinY(_originalContentRect);
    CGFloat textWidth = kTLOriginalContentWidth - 2 * kTLOriginalContentTextSideMargin;
    
    //title
    UIFont *titleFont = [UIFont systemFontOfSize:kTLOriginalContentTitleFontSize];
    _originTitleLabel.frame = CGRectMake(kTLOriginalContentTextSideMargin + startX,
                                         kTLOriginalContentTitleTopMargin + startY,
                                         textWidth,
                                         self.timelineTrendObj.originContentObj.titleHeight);
    _originTitleLabel.text = self.timelineTrendObj.originContentObj.title;
    _originTitleLabel.font = titleFont;
    
    //from
    startY = _originTitleLabel.bottom + kTLOriginalContentVerticalMargin;
    UIFont *fromFont = [UIFont systemFontOfSize:kTLOriginalContentFromFontSize];
    _originFromLabel.frame = CGRectMake(kTLOriginalContentTextSideMargin + startX,
                                        startY,
                                        textWidth,
                                        self.timelineTrendObj.originContentObj.fromHeight);
    _originFromLabel.text = self.timelineTrendObj.originContentObj.fromDisplayString;
    _originFromLabel.font = fromFont;
}

- (void)setOriginView
{
    [super setOriginView];
    if (!_originSoundView) {
        CGRect rect = CGRectMake(0, 0,
                                 SOUNDVIEW_WIDTH,
                                 SOUNDVIEW_HEIGHT);
        _originSoundView = [[SNLiveSoundView alloc] initWithFrame:rect];
        
        [self addSubview:_originSoundView];
    }
    
    if (self.timelineTrendObj.originContentObj.ugcAudUrl.length > 0) {
        [_originSoundView loadIfNeeded];
        _originSoundView.left = CGRectGetMinX(_originalContentRect) + kTLOriginalContentTextSideMargin,
        _originSoundView.top = _originFromLabel.bottom + kTLOriginalContentTextSideMargin;
        _originSoundView.duration = self.timelineTrendObj.originContentObj.ugcAudLen;
        _originSoundView.commentID = self.timelineTrendObj.actId;
        _originSoundView.url = self.timelineTrendObj.originContentObj.ugcAudUrl;
        
        _originSoundView.hidden = NO;
        _originalTapview.hidden = NO;
    }
    else {
        _originSoundView.hidden = YES;
        _originalTapview.hidden = YES;
    }
}

//通过二代协议打开动态原文页
- (void)openOriginalContentAction:(id)sender {
    
    [[SNSoundManager sharedInstance] stopAll];
    NSMutableDictionary *dic = [NSMutableDictionary dictionary];

    if (self.timelineTrendObj.pid.length > 0) {
        [dic setObject:self.timelineTrendObj.pid forKey:kCircleDetailKeyPid];
    }
    [dic setObject:@(self.indexPath) forKey:kCircleDetailKeyIndex];
    [dic setObject:@(self.timelineTrendObj.topNum) forKey:kCircleDetailKeyAvlNum];
    
    [SNUtility openProtocolUrl:self.timelineTrendObj.originContentObj.link context:dic];
}

#pragma mark - background
- (void)resignActiveFunction
{
    [[SNSoundManager sharedInstance] stopAmr];
}

- (void)updateTheme
{
    [_originSoundView updateTheme];
    [super updateTheme];
}

@end
