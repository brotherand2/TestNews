//
//  SNReadCircleCommentCell.m
//  sohunews
//
//  Created by jialei on 13-12-16.
//  Copyright (c) 2013年 Sohu.com. All rights reserved.
//

#import "SNReadCircleCommentCell.h"
#import "SNTimelineObjects.h"
#import "SNHeadIconView.h"
#import "SNUserUtility.h"
#import "UIControl+Blocks.h"
#import "SNBaseEditorViewController.h"

#define kRCCommentTextWidth (kTLCommentsViewTextWidth - 36 - kTLCommentsViewLeftRightMargin)

@interface SNReadCircleCommentCell()
{
    SNHeadIconView  *_headIconView;
    UIImageView     *_sepLineView;
    UILabel         *_userNameLabel;
    SNLabel         *_contentLabel;
    UILabel         *_timeLabel;
    UIImageView     *_bgBgView;
    UIImage         *_lineImage;
    UIButton        *_moreButton;
    
    CGFloat _startX;
    CGFloat _startY;
    CGFloat _topImgHeight;
    CGFloat _bottomImgHeight;
    CGRect  _bgViewFrame;
    CGRect  _userNameButtonFrame;
    CGRect  _timeLabelFrame;
}

@property (nonatomic, strong) UIImage *bgImage;
@property (nonatomic, strong) UIImage *topBgImage;
@property (nonatomic, strong) UIImage *middleBgImage;
@property (nonatomic, strong) UIImage *bottomBgImage;

@end

@implementation SNReadCircleCommentCell

+ (CGFloat)heightForReadCircleComment:(SNTimelineCommentsObject *)cmtObj objIndex:(int)index
{
    CGFloat height = .0f;
    height += kTLCommentsViewTopBottomMargin;
    height += kTLCommentsViewUserNameFontSize + 2 + kTLCommentsViewNameTextMargin;
    NSString *content = cmtObj.content;
    if (cmtObj.fNickName.length > 0) {
        content = [NSString stringWithFormat:@"回复%@：%@", cmtObj.fNickName, content];
    }

    CGFloat maxHeight = [SNLabel heightForContent:content
                                         maxWidth:kRCCommentTextWidth
                                             font:kTLCommentsViewTextFontSize
                                       lineHeight:kTLCommentsViewTextLineHeight
                                     maxLineCount:SNTIMELINE_SHAREINFO_COMMENT_MAX_WIDTHOUT_MORE];
    CGFloat maxHeightWithMore = [SNLabel heightForContent:content
                                                 maxWidth:kRCCommentTextWidth
                                                     font:kTLCommentsViewTextFontSize
                                               lineHeight:kTLCommentsViewTextLineHeight
                                             maxLineCount:SNTIMELINE_SHAREINFO_COMMENT_MAX_WIDTH_MORE];
    CGFloat textHeight = [SNLabel heightForContent:content
                                           maxSize:CGSizeMake(kRCCommentTextWidth, CGFLOAT_MAX_CORE_TEXT)
                                              font:kTLCommentsViewTextFontSize
                                        lineHeight:kTLCommentsViewTextLineHeight
                                     textAlignment:NSTextAlignmentLeft
                                     lineBreakMode:NSLineBreakByCharWrapping];
    CGFloat contentHeight = textHeight;
    CGFloat moreButtonHeight = 0;
    cmtObj.contentHeight = textHeight;
    if(textHeight > maxHeight) {
        cmtObj.needFolder = YES;
        if(cmtObj.isFolder) {
            moreButtonHeight = SNTIMELINE_SHAREINFO_COMMENT_MORE_HEIGHT + kTLCommentsViewNameTextMargin;
            contentHeight = maxHeightWithMore + moreButtonHeight;
            cmtObj.contentHeight = maxHeightWithMore;
        }
    }
    
    height += contentHeight;
    height += kTLCommentsViewTopBottomMargin;
    if (index == SNTimelineCommentBgTypeTop) {
        height += 8;
    }
    
    return height;
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        self.backgroundColor = [UIColor clearColor];
        
        self.topBgImage = [UIImage themeImageNamed:@"timeline_detail_comment_top_bg.png"];
        _topImgHeight = self.topBgImage.size.height;
        if (self.topBgImage && [self.topBgImage respondsToSelector:@selector(resizableImageWithCapInsets:)]) {
            self.topBgImage = [self.topBgImage resizableImageWithCapInsets:UIEdgeInsetsMake(_topImgHeight - 1, 15, 0, 5)];
        }
        else {
            self.topBgImage = [self.topBgImage stretchableImageWithLeftCapWidth:20 topCapHeight:10];
        }
        
        self.middleBgImage = [UIImage themeImageNamed:@"timeline_detail_comment_middle_bg.png"];
        if (self.middleBgImage && [self.middleBgImage respondsToSelector:@selector(resizableImageWithCapInsets:)]) {
            self.middleBgImage = [self.middleBgImage resizableImageWithCapInsets:UIEdgeInsetsMake(1, 15, 0, 1)];
        }
        else {
            self.middleBgImage = [self.middleBgImage stretchableImageWithLeftCapWidth:20 topCapHeight:10];
        }
        
        self.bottomBgImage = [UIImage themeImageNamed:@"timeline_detail_comment_bottom_bg.png"];
        _bottomImgHeight = self.bottomBgImage.size.height;
        if (self.bottomBgImage && [self.bottomBgImage respondsToSelector:@selector(resizableImageWithCapInsets:)]) {
            self.bottomBgImage = [self.bottomBgImage resizableImageWithCapInsets:UIEdgeInsetsMake(0, 10, _bottomImgHeight - 1, 10)];
        }
        else {
            self.bottomBgImage = [self.bottomBgImage stretchableImageWithLeftCapWidth:20 topCapHeight:10];
        }
        
        [SNNotificationManager addObserver:self
                                                 selector:@selector(updateTheme)
                                                     name:kThemeDidChangeNotification
                                                   object:nil];
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)drawRect:(CGRect)rect
{
    [super drawRect:rect];
    [self.bgImage drawInRect:_bgViewFrame];
    if (self.index != SNTimelineCommentBgTypeBottom) {
        [UIView drawCellSeperateLine:_bgViewFrame margin:0];
    }
}

- (void)dealloc
{
    [SNNotificationManager removeObserver:self];
     //(_topBgImage);
     //(_bottomBgImage);
     //(_middleBgImage);
     //(_cmtObj);
     //(_headIconView);
     //(_contentLabel);
     //(_sepLineView);
    
}

- (void)setObject:(SNTimelineCommentsObject *)cmtObj
{
    self.cmtObj = cmtObj;
    _startX = kAppScreenWidth - kTLOriginalContentWidth - 9;
    _startY = kTLCommentsViewTopBottomMargin;
    if (self.index == SNTimelineCommentBgTypeTop) {
        _startY += 8;
    }
    
    [self setSubViewFrame];
    [self setBackgroundView];
    [self setUserHeadIcon];
    [self setUserNameButton];
    [self setTimeLabel];
    [self setContent];
    [self setMoreButton];
}

- (void)setSubViewFrame
{
    _bgViewFrame = CGRectMake(_startX, 0,
                              kTLOriginalContentWidth, [[self class] heightForReadCircleComment:self.cmtObj objIndex:self.index]);
    
    CGSize timeLabelSize = [self.cmtObj.time sizeWithFont:[UIFont systemFontOfSize:kTLCommentsViewTimeLabelFontSize]];
    _userNameButtonFrame = CGRectMake(kTLCommentsViewLeftRightMargin * 2 + kTLCommentsViewIconHeight + _startX,
                                      _startY,
                                      kTLOriginalContentWidth - kTLCommentsViewLeftRightMargin * 4 -
                                      kTLCommentsViewIconHeight - timeLabelSize.width,
                                      kTLCommentsViewUserNameFontSize + 3);
    
    _timeLabelFrame = CGRectMake(_startX + kTLOriginalContentWidth - timeLabelSize.width - kTLCommentsViewTopBottomMargin,
                                 _startY + 2,
                                 timeLabelSize.width, timeLabelSize.height);
}

- (void)setBackgroundView
{
    if (self.index == SNTimelineCommentBgTypeTop) {
        self.bgImage = self.topBgImage;
    }
    else if (self.index== SNTimelineCommentBgTypeBottom) {
        self.bgImage = self.bottomBgImage;
    }
    else {
        self.bgImage = self.middleBgImage;
    }
}

- (void)setUserNameButton
{
    if (!_userNameLabel) {
        _userNameLabel = [[UILabel alloc]initWithFrame:_userNameButtonFrame];
        _userNameLabel.textColor = SNUICOLOR(kAuthorNameColor);
        _userNameLabel.font = [UIFont systemFontOfSize:kTLCommentsViewUserNameFontSize];
        _userNameLabel.backgroundColor = [UIColor clearColor];
        _userNameLabel.textAlignment = NSTextAlignmentLeft;
        _userNameLabel.userInteractionEnabled = YES;
        
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self
                                                                             action:@selector(enterUserCenter)];
        [_userNameLabel addGestureRecognizer:tap];
        
        [self addSubview:_userNameLabel];
    }
    _userNameLabel.text = self.cmtObj.nickName;
    _userNameLabel.frame = _userNameButtonFrame;
}

- (void)setUserHeadIcon
{
    if (!_headIconView)
    {
        _headIconView = [[SNHeadIconView alloc] initWithFrame:CGRectMake(kTLViewSideMargin + _startX,
                                                                         _startY,
                                                                         kTLShareInfoViewIconSize,
                                                                         kTLShareInfoViewIconSize)];
        _headIconView.backgroundColor = [UIColor clearColor];
        UITapGestureRecognizer* tapGes = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(enterUserCenter)];
        [_headIconView addGestureRecognizer:tapGes];
        [self addSubview:_headIconView];
    }
    _headIconView.top = _startY;
    _headIconView.alpha = [[[SNThemeManager sharedThemeManager] currentTheme] isEqualToString:kThemeNight] ? 0.7 : 1;
}

- (void)setTimeLabel
{
    if (!_timeLabel) {
        _timeLabel = [[UILabel alloc]initWithFrame:_timeLabelFrame];
        _timeLabel.font = [UIFont systemFontOfSize:kTLCommentsViewTimeLabelFontSize];
        _timeLabel.textColor = SNUICOLOR(kFloorCommentDateColor);
        _timeLabel.backgroundColor = [UIColor clearColor];
  
        [self addSubview:_timeLabel];
    }
    _timeLabel.text = self.cmtObj.time;
    _timeLabel.frame = _timeLabelFrame;
}

- (void)setContent
{
    if (!_contentLabel) {
        _contentLabel = [[SNLabel alloc]init];
        _contentLabel.lineHeight = kTLCommentsViewTextLineHeight;
        _contentLabel.font = [UIFont systemFontOfSize:kTLCommentsViewTextFontSize];
        _contentLabel.textColor = SNUICOLOR(kFloorViewCommentContentColor);
//        _contentLabel.linkColor = SNUICOLOR(kAuthorNameColor);
        _contentLabel.delegate = self;
        _contentLabel.tapEnable = YES;
        [self addSubview:_contentLabel];
    }

    [_headIconView setIconUrl:self.cmtObj.headUrl passport:nil gender:0];
    CGRect rect = CGRectMake(_startX + kTLCommentsViewLeftRightMargin * 2 + kTLCommentsViewIconHeight,
                             _userNameLabel.bottom + kTLCommentsViewNameTextMargin,
                             kRCCommentTextWidth, self.cmtObj.contentHeight);
    NSString *text = self.cmtObj.content;
    if (self.cmtObj.fNickName.length > 0) {
        text = [NSString stringWithFormat:@"回复%@：%@", self.cmtObj.fNickName, self.cmtObj.content];
        _contentLabel.text = text;
        
        NSRange range = NSMakeRange(2, self.cmtObj.fNickName.length);
        if (range.location + range.length < _contentLabel.text.length) {
            _contentLabel.linkColor = SNUICOLOR(kAuthorNameColor);
            [_contentLabel addHighlightText:self.cmtObj.fNickName inRange:range];
        }
    }
    else {
       [_contentLabel removeAllHighlightInfo];
        _contentLabel.text = text;
    }
    _contentLabel.frame = rect;
    _contentLabel.alpha = themeImageAlphaValue();
}

//折行显示过长用户发表内容
- (void)setMoreButton
{
    // more cell
    UIFont *font = [UIFont systemFontOfSize:kTLShareInfoViewNameFontSize];
    if(!_moreButton){
        
        _moreButton = [[UIButton alloc]initWithFrame:CGRectZero];
        _moreButton.exclusiveTouch = YES;
        _moreButton.titleLabel.textAlignment = NSTextAlignmentLeft;
        [_moreButton setTitleColor:[UIColor colorFromString:[[SNThemeManager sharedThemeManager] currentThemeValueForKey:kAuthorNameColor]] forState:UIControlStateNormal];
        [_moreButton setTitle:NSLocalizedString(@"OpenComment", @"") forState:UIControlStateNormal];
        [_moreButton.titleLabel setFont:font];
        _moreButton.width = [NSLocalizedString(@"OpenComment", @"") sizeWithFont:_moreButton.titleLabel.font].width;
        [self addSubview:_moreButton];
    }
    
    if(self.cmtObj.isFolder && self.cmtObj.needFolder) {
        CGSize stringSize = [NSLocalizedString(@"OpenComment", @"") sizeWithFont:font];
        _moreButton.frame = CGRectMake(_contentLabel.left, _contentLabel.bottom + kTLCommentsViewNameTextMargin,
                                       stringSize.width, SNTIMELINE_SHAREINFO_MORE_HEIGHT);
        __weak __typeof(&*self)weakSelf = self;

        [_moreButton setActionBlock:^(UIControl *control) {
            if (weakSelf.delegate && [weakSelf.delegate respondsToSelector:@selector(snTrendCmtBtnOpenMore:)]) {
                [weakSelf.delegate snTrendCmtBtnOpenMore:weakSelf.cmtObj.commentId];
            }
        } forControlEvents:UIControlEventTouchUpInside];
    }
    else {
        _moreButton.frame = CGRectZero;
    }
}

#pragma mark - action
- (void)enterUserCenter
{
    if (self.cmtObj.pid.length > 0) {
        [SNUserUtility openUserWithPassport:nil
                                 spaceLink:nil
                                 linkStyle:nil
                                       pid:self.cmtObj.pid
                                       push:@"0" refer:nil];
    }
}

#pragma mark - SNLabelDelegate
- (void)tapOnLink:(NSString *)link
{
    SNDebugLog(@"link : %@",link);
    if ([link length] > 0) {
        if ([link hasPrefix:@"link://"]) {
            NSString *pid = [link substringFromIndex:7];
            
            TTURLAction* urlAction = [[[TTURLAction actionWithURLPath:@"tt://userCenter"] applyQuery:@{@"pid" : pid}] applyAnimated:YES];
            [[TTNavigator navigator] openURLAction:urlAction];
        } else {
            NSMutableDictionary *query = [NSMutableDictionary dictionary];
            
            [query setObject:link forKey:@"address"];
            
            TTURLAction *urlAction = [[[TTURLAction actionWithURLPath:@"tt://simpleWebBrowser"] applyAnimated:YES] applyQuery:query];
            [[TTNavigator navigator] openURLAction:urlAction];
            
        }
    }
}

- (void)tapOnNotLink:(SNLabel *)label
{
    NSMutableDictionary* dic = [NSMutableDictionary dictionary];
    if (self.cmtObj.actId.length) {
        [dic setObject:self.cmtObj.actId forKey:kCircleCommentKeyActId];
    }
    
    if (self.cmtObj.pid.length > 0)
        [dic setObject:self.cmtObj.pid forKey:kCircleCommentKeyFpid];
    
    if (self.cmtObj.nickName.length > 0) {
        [dic setObject:self.cmtObj.nickName forKey:kCircleCommentKeyFname];
    }
    if (self.cmtObj.commentId.length > 0) {
        [dic setObject:self.cmtObj.commentId forKey:kCircleCommentKeyCommentId];
    }
    
    TTURLAction *action = [[[TTURLAction actionWithURLPath:@"tt://modalCircleCommentEditor"] applyAnimated:YES]
                           applyQuery:dic];
    [[TTNavigator navigator] openURLAction:action];
}

- (void)updateTheme
{
    //重新设置背景图
    self.topBgImage = [UIImage themeImageNamed:@"timeline_detail_comment_top_bg.png"];
    _topImgHeight = self.topBgImage.size.height;
    if (self.topBgImage && [self.topBgImage respondsToSelector:@selector(resizableImageWithCapInsets:)]) {
        self.topBgImage = [self.topBgImage resizableImageWithCapInsets:UIEdgeInsetsMake(_topImgHeight - 1, 15, 0, 5)];
    }
    else {
        self.topBgImage = [self.topBgImage stretchableImageWithLeftCapWidth:20 topCapHeight:10];
    }
    
    self.middleBgImage = [UIImage themeImageNamed:@"timeline_detail_comment_middle_bg.png"];
    if (self.middleBgImage && [self.middleBgImage respondsToSelector:@selector(resizableImageWithCapInsets:)]) {
        self.middleBgImage = [self.middleBgImage resizableImageWithCapInsets:UIEdgeInsetsMake(1, 15, 0, 1)];
    }
    else {
        self.middleBgImage = [self.middleBgImage stretchableImageWithLeftCapWidth:20 topCapHeight:10];
    }
    
    self.bottomBgImage = [UIImage themeImageNamed:@"timeline_detail_comment_bottom_bg.png"];
    _bottomImgHeight = self.bottomBgImage.size.height;
    if (self.bottomBgImage && [self.bottomBgImage respondsToSelector:@selector(resizableImageWithCapInsets:)]) {
        self.bottomBgImage = [self.bottomBgImage resizableImageWithCapInsets:UIEdgeInsetsMake(0, 10, _bottomImgHeight - 1, 10)];
    }
    else {
        self.bottomBgImage = [self.bottomBgImage stretchableImageWithLeftCapWidth:20 topCapHeight:10];
    }
    [self setBackgroundView];
    
    //字体颜色
    _timeLabel.textColor = SNUICOLOR(kFloorCommentDateColor);
    _contentLabel.textColor = SNUICOLOR(kFloorViewCommentContentColor);
    _userNameLabel.textColor = SNUICOLOR(kAuthorNameColor);
    _contentLabel.alpha = themeImageAlphaValue();
    
    //头像遮罩
    _headIconView.alpha = [[[SNThemeManager sharedThemeManager] currentTheme] isEqualToString:kThemeNight] ? 0.7 : 1;
    
    [self setNeedsDisplay];
}

@end
