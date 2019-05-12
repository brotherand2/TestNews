//
//  SNTimelineTrendCell.m
//  sohunews
//
//  Created by jialei on 13-9-12.
//  Copyright (c) 2013年 Sohu.com. All rights reserved.
//

#import "SNTimelineTrendCell.h"
#import "SNHeadIconView.h"
#import "UIImage+MultiFormat.h"
#import "SNWebImageView.h"
#import "SDImageCache.h"
#import "UIImageView+WebCache.h"
#import "UIControl+Blocks.h"
#import "SNTrendArticleCell.h"
#import "SNTrendPeopleCell.h"
#import "SNTrendLiveCell.h"
#import "SNTrendUgcCell.h"
#import "SNTrendSubScribeCell.h"
#import "SNApprovalButton.h"
#import "SNTrendCommentButton.h"
#import "SNUserHelper.h"
#import "SNTimelinePostService.h"
#import "SNUserManager.h"

//#define kSubViewTagHeadIcon     100
//#define kSubViewTagNameLabel    101
//#define kSubViewTagTimeLabel    102
#define kDownloadBtnTag   (1004)

@interface SNTimelineTrendCell()
{
    FGalleryPhotoView *_photoView;
    UIView *_imageDetailView;
    
    CGSize _sourceLabelSize;
}

@end

@implementation SNTimelineTrendCell

@synthesize timelineTrendObj = _timelineTrendObj;
@synthesize delegate;
@synthesize referFrom;


+ (CGFloat)heightForTimelineTrendObj:(SNTimelineTrendItem *)obj
{
    // 后面减去的大小  是因为ui样式变了，原来时间、分类的一行拆分出两行分别放在最上面最下面一行，所以大概减去一行的高度，尽量不去改计算高度的地方 。。。 by jojo
    return obj.height;
}

+ (Class)cellClassForItem:(SNTimelineItemType)trendType
{
    switch (trendType) {
        case kSNTimelineItemTypeArticle:
            return [SNTrendArticleCell class];
            break;
        case kSNTimelineItemTypeSub:
            return [SNTrendSubScribeCell class];
            break;
        case kSNTimelineItemTypeLive:
            return [SNTrendLiveCell class];
            break;
        case kSNTimelineItemTypePeople:
            return [SNTrendPeopleCell class];
            break;
        case kSNTimelineItemTypeUGC:
            return [SNTrendUgcCell class];
            break;
    }
    return nil;
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        self.needSepLine = YES;
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(updateTheme)
                                                     name:kThemeDidChangeNotification object:nil];
        //各种默认图
//        _originDefaultImage = [UIImage imageNamed:@"timeline_default.png"];
        _subIconBgImage = [UIImage themeImageNamed:@"subinfo_article_iconBg.png"];
        UIImage *bgImage = [UIImage imageNamed:@"timeline_origin_bg.png"];
        if ([bgImage respondsToSelector:@selector(resizableImageWithCapInsets:)]) {
            _originBgImage = [bgImage resizableImageWithCapInsets:UIEdgeInsetsMake(10, 10, 10, 10)];
        }
        else {
            _originBgImage = [bgImage stretchableImageWithLeftCapWidth:20 topCapHeight:10];
        }
        
        UIImage *commentBgImage = [UIImage imageNamed:@"timeline_origin_bg_with_angle.png"];
        if ([commentBgImage respondsToSelector:@selector(resizableImageWithCapInsets:)]) {
            _commentBgImage = [commentBgImage resizableImageWithCapInsets:UIEdgeInsetsMake(10, 10, 10, 10)];
        }
        else {
            _commentBgImage = [commentBgImage stretchableImageWithLeftCapWidth:20 topCapHeight:10];
        }
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)dealloc
{    
    TT_RELEASE_SAFELY(_timelineTrendObj);
    TT_RELEASE_SAFELY(_originalTapview);
    TT_RELEASE_SAFELY(_originalImageView);
    TT_RELEASE_SAFELY(_abstractLabel);
    TT_RELEASE_SAFELY(_userNameLabel);
    TT_RELEASE_SAFELY(_sourceLabel);
    TT_RELEASE_SAFELY(_fromTypeLabel);
    TT_RELEASE_SAFELY(_headIconView);
    TT_RELEASE_SAFELY(_abstractLabel);
    TT_RELEASE_SAFELY(_contentLabel);
    TT_RELEASE_SAFELY(_soundView);
    TT_RELEASE_SAFELY(_picView);
    TT_RELEASE_SAFELY(_originalImageView);
    TT_RELEASE_SAFELY(_videoIconView);
    TT_RELEASE_SAFELY(_moreButton);
    TT_RELEASE_SAFELY(_commentButton);
    TT_RELEASE_SAFELY(_approvalButton);
    TT_RELEASE_SAFELY(_commentsView);
    TT_RELEASE_SAFELY(_cmtNumLabel);
    
    [super dealloc];
}

#pragma mark - draw methods
- (void)drawRect:(CGRect)rect
{
    [super drawRect:rect];
    
    if (self.needSepLine) {
        [UIView drawCellSeperateLine:rect margin:10];
    }
}

- (void)setTrendObject:(SNTimelineTrendItem *)timelineTrendObj
{
    if (!timelineTrendObj)
    {
        return;
    }
    self.timelineTrendObj = timelineTrendObj;
    [self setDfaultImage];
    [self setUserHeadIcon];
    [self setUserNameLabel];
    [self setSourceLabel];
    [self setContent];
    [self setOriginBgImageView];
    [self setOriginTitleAndFrom];
    [self setOriginView];
    [self setOriginalImageView];
    [self setTimeLabel];
    [self setDeleteButton];
    if (!self.timelineTrendObj.hideTop) {
        [self setApprovalButton];
    } else {
        [self setApprovalButtonHidden];
    }
    if (!self.timelineTrendObj.hideComment) {
        [self setCommentButton];
    } else {
        [self setCommentButtonHidden];
    }
    [self setCommentsView];
}

- (void)setDfaultImage
{
    NSString *defautlImgName = [SNUtility getApplicationDelegate].shouldDownloadImagesManually ?
    @"photo_list_click_default.png" :
    @"photo_list_default.png";
    _originDefaultImage = [UIImage themeImageNamed:defautlImgName];
}

- (void)setUserHeadIcon
{
    if (!_headIconView)
    {
        _headIconView = [[SNHeadIconView alloc] initWithFrame:CGRectMake(kTLViewSideMargin,
                                                                         kTLShareInfoViewNameTopMargin,
                                                                         kTLShareInfoViewIconSize,
                                                                         kTLShareInfoViewIconSize)];
        [self addSubview:_headIconView];
    }
    
    [_headIconView setIconUrl:self.timelineTrendObj.userHeadUrl passport:nil gender:0];
    [_headIconView setTarget:self tapSelector:@selector(enterUserCenter:)];
    _headIconView.userPid = self.timelineTrendObj.pid;
    _headIconView.alpha = [[[SNThemeManager sharedThemeManager] currentTheme] isEqualToString:kThemeNight] ? 0.7 : 1;
}

- (void)setUserNameLabel
{
    float width = self.width - kTLViewSideMargin * 2 - kTLShareInfoViewTextLeftMargin;
    if (!_userNameLabel)
    {
        _userNameLabel = [[UILabel alloc] initWithFrame:CGRectMake(kTLShareInfoViewTextLeftMargin,
                                                               kTLShareInfoViewNameTopMargin,
                                                               width,
                                                               kTLShareInfoViewNameFontSize + 2)];
        _userNameLabel.backgroundColor = [UIColor clearColor];
        _userNameLabel.font = [UIFont systemFontOfSize:kTLShareInfoViewNameFontSize];
        _userNameLabel.textColor = SNUICOLOR(kAuthorNameColor);
        _userNameLabel.userInteractionEnabled = YES;
        _userNameLabel.lineBreakMode = NSLineBreakByTruncatingTail;
        _userNameLabel.numberOfLines = 1;
        [self addSubview:_userNameLabel];
        
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(enterUserCenter)];
        [_userNameLabel addGestureRecognizer:tap];
        [tap release];
    }
    if (self.timelineTrendObj.userNickName)
    {
        _userNameLabel.text = self.timelineTrendObj.userNickName;
        float fontWidth = [_userNameLabel.text sizeWithFont:_userNameLabel.font].width;
        _userNameLabel.width = fontWidth > width ? width :fontWidth;
    }
}

- (void)setSourceLabel
{
    if (!_sourceLabel)
    {
        _sourceLabel = [[UILabel alloc] init];
        _sourceLabel.backgroundColor = [UIColor clearColor];
        _sourceLabel.font = [UIFont systemFontOfSize:kTLShareInfoViewTimeFontSize];
        _sourceLabel.textColor = SNUICOLOR(kFloorCommentDateColor);
        _sourceLabel.userInteractionEnabled = YES;
        _sourceLabel.lineBreakMode = NSLineBreakByTruncatingTail;
        _sourceLabel.numberOfLines = 1;
        [self addSubview:_sourceLabel];
    }
    if (self.timelineTrendObj.trendTitle.length > 0)
    {
        _sourceLabel.text = self.timelineTrendObj.trendTitle;
        _sourceLabelSize = [_sourceLabel.text sizeWithFont:[UIFont systemFontOfSize:kTLShareInfoViewTimeFontSize]];
        float width = self.width - kTLViewSideMargin * 2 - kTLShareInfoViewTextLeftMargin - _userNameLabel.width;
        _sourceLabel.frame = CGRectMake(_userNameLabel.right + 10, kTLShareInfoViewNameTopMargin + 1,
                                        width, _sourceLabelSize.height);
    }
}

- (void)setTimeLabel
{
    if (!_timeLabel) {
        _timeLabel = [[UILabel alloc] initWithFrame:CGRectMake(kTLShareInfoViewTextLeftMargin,
                                                              _viewOffsetY + kTLShareInfoVIewOriginalTimeMargin,
                                                              100,
                                                              kTLShareInfoViewTimeFontSize + 1)];
        _timeLabel.backgroundColor = [UIColor clearColor];
        _timeLabel.font = [UIFont systemFontOfSize:kTLShareInfoViewTimeFontSize];
        _timeLabel.textAlignment = UITextAlignmentRight;
        _timeLabel.textColor = SNUICOLOR(kFloorCommentDateColor);
//        _timeLabel.tag = kSubViewTagTimeLabel;
        [self addSubview:_timeLabel];
    }
    if (self.timelineTrendObj.time.length  > 0)
    {
        _timeLabel.top = CGRectGetMaxY(_originalContentRect) + kTLShareInfoVIewOriginalTimeMargin;
        _timeLabel.text = [NSDate relativelyDate:self.timelineTrendObj.time];
        CGSize size = [_timeLabel.text sizeWithFont:[UIFont systemFontOfSize:kTLShareInfoViewTimeFontSize]];
        _timeLabel.size = CGSizeMake(size.width + 2, size.height);
    }
}

- (void)setContent
{
    if (!_contentLabel)
    {
        _contentLabel = [[SNLabel alloc] initWithFrame:CGRectMake(kTLShareInfoViewTextLeftMargin,
                                                                  _userNameLabel.bottom + kTLShareInfoViewNameContentMargin,
                                                                  self.width - kTLViewSideMargin - kTLShareInfoViewTextLeftMargin,
                                                                  0)];
        
        _contentLabel.textColor = SNUICOLOR(kFloorViewCommentContentColor);
        _contentLabel.lineHeight = kTLShareInfoViewContentLineHeight;
        _contentLabel.font = [UIFont systemFontOfSize:kTLShareInfoViewContentFontSize];
        _contentLabel.delegate = self;
        [self addSubview:_contentLabel];
    }
    if (self.timelineTrendObj.content.length > 0) {
        _contentLabel.hidden = NO;
        _contentLabel.top = _userNameLabel.bottom + 8;
        _contentLabel.height = self.timelineTrendObj.ugcContentHeight;
        _contentLabel.text = self.timelineTrendObj.content;
        _viewOffsetY = _contentLabel.bottom;
    }
    else {
        _contentLabel.hidden = YES;
        _viewOffsetY = _userNameLabel.bottom;
    }
    
    [self setMoreButton];
}

//折行显示过长用户发表内容
- (void)setMoreButton
{
    // more cell
    UIFont *font = [UIFont systemFontOfSize:kTLShareInfoViewNameFontSize];
    if(!_moreButton){
        
        _moreButton = [[UIButton alloc]initWithFrame:CGRectZero];
        NSString *strColor = [[SNThemeManager sharedThemeManager] currentThemeValueForKey:kAuthorNameColor];
        _moreButton.exclusiveTouch = YES;
        _moreButton.titleLabel.textAlignment = NSTextAlignmentLeft;
        [_moreButton setTitleColor:[UIColor colorFromString:strColor] forState:UIControlStateNormal];
        [_moreButton setTitle:NSLocalizedString(@"OpenComment", @"") forState:UIControlStateNormal];
        [_moreButton.titleLabel setFont:font];
        _moreButton.width = [NSLocalizedString(@"OpenComment", @"") sizeWithFont:_moreButton.titleLabel.font].width;
        [self addSubview:_moreButton];
    }
    
    if(!self.timelineTrendObj.isOpenUgc && self.timelineTrendObj.needOpenUgc)
    {
        CGSize stringSize = [NSLocalizedString(@"OpenComment", @"") sizeWithFont:font];
        _moreButton.frame = CGRectMake(kTLShareInfoViewTextLeftMargin, _contentLabel.bottom,
                                       stringSize.width, SNTIMELINE_SHAREINFO_MORE_HEIGHT);
        _viewOffsetY = _moreButton.bottom;
        
        [_moreButton setActionBlock:^(UIControl *control) {
            [self openMoreComment];
        } forControlEvents:UIControlEventTouchUpInside];
    } 
    else
    {
        _moreButton.frame = CGRectZero;
    }
}

//转发原文
- (void)setOriginView
{
    if (!_originalTapview) {
        _originalTapview = [[UIView alloc] init];
        [self addSubview:_originalTapview];
        
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(openOriginalContentAction:)];
        [_originalTapview addGestureRecognizer:tap];
        TT_RELEASE_SAFELY(tap);
    }
    _originalTapview.frame = _originalContentRect;
}

- (void)setOriginBgImageView
{
    CGSize originSize = CGSizeMake(kTLOriginalContentWidth, llroundf(self.timelineTrendObj.originContentHeight));
    _originalContentRect = CGRectMake(self.width - originSize.width - 9,
                                      _viewOffsetY + kTLshareInfoViewContentOriginalMargin,
                                      originSize.width,
                                      originSize.height);
    
    if (!_originalBgView) {
        _originalBgView = [[UIImageView alloc] initWithImage:_originBgImage];
        [self addSubview:_originalBgView];
    }
    [_originalBgView setFrame:_originalContentRect];
    _viewOffsetY = _originalBgView.bottom;
}

//
- (void)setOriginalImageView
{
}

- (void)setOriginTitleAndFrom
{
    if (!_originTitleLabel) {
        _originTitleLabel = [[UILabel alloc] init];
        _originTitleLabel.backgroundColor = [UIColor clearColor];
        _originTitleLabel.lineBreakMode = NSLineBreakByWordWrapping;
        _originTitleLabel.numberOfLines = NSIntegerMax;
        [self addSubview:_originTitleLabel];
    }
    _originTitleLabel.textColor = SNUICOLOR(kTLViewTitleTextColor);
    
    if (!_originFromLabel) {
        _originFromLabel = [[UILabel alloc] init];
        _originFromLabel.backgroundColor = [UIColor clearColor];
        _originFromLabel.textColor = SNUICOLOR(kTLViewFromTextColor);
        _originFromLabel.lineBreakMode = NSLineBreakByTruncatingTail;
        [self addSubview:_originFromLabel];
    }
}

//删除
- (void)setDeleteButton
{
    //删除动态
    NSString *pid = [SNUserManager getPid];
    if ([pid isEqualToString:self.timelineTrendObj.pid]) {
        NSString *pid = [SNUserManager getPid];
        if ([pid isEqualToString:self.timelineTrendObj.pid] && !_deleteButton) {
            UIFont *deleteFont = [UIFont systemFontOfSize:kTLShareInfoViewDeleteBtnFontSize];
            NSString *buttonTitle = NSLocalizedString(@"trend_deleteButtonTitle", @"");
            CGSize titleSize = [buttonTitle sizeWithFont:deleteFont];
            
            _deleteButton = [UIButton buttonWithType:UIButtonTypeCustom];
            _deleteButton.titleLabel.font = deleteFont;
            _deleteButton.backgroundColor = [UIColor clearColor];
            _deleteButton.size = CGSizeMake(titleSize.width + 4, titleSize.height + 2);
            _deleteButton.alpha = .8;
            [_deleteButton setTitle:buttonTitle forState:UIControlStateNormal];
            [_deleteButton setTitleColor:SNUICOLOR(kAuthorNameColor) forState:UIControlStateNormal];
            [_deleteButton addTarget:self action:@selector(deleteAction:) forControlEvents:UIControlEventTouchUpInside];
            
            [self addSubview:_deleteButton];
        }
        _deleteButton.top = _timeLabel.top;
        _deleteButton.left = _timeLabel.right + 30 / 2;
        _deleteButton.hidden = NO;
    }
    else {
        _deleteButton.hidden = YES;
    }
}

//赞
- (void)setApprovalButton {
    if (!_approvalButton) {
        CGFloat right = self.width - kTLShareInfoViewApprovalCommentBtnMrigin * 2 - kSNTLTrendApprovalWidth;
        _approvalButton = [[SNApprovalButton alloc] initWithFrame:CGRectMake(0, 0,
                                                                          kSNTLTrendApprovalWidth, kSNTLTrendApprovalHeight)];
        _approvalButton.right = right;
        
        [self addSubview:_approvalButton];
    }
    CGFloat top = CGRectGetMaxY(_originalContentRect) + kTLOriginalContentCommentBtnTopMargin;
    _approvalButton.hidden = NO;
    _approvalButton.top = top;
    _approvalButton.trendItem = self.timelineTrendObj;
    _approvalButton.actId = self.timelineTrendObj.actId;
    _approvalButton.hasApproval = self.timelineTrendObj.isTop;
    _approvalButton.topNumbers = self.timelineTrendObj.topNum;
    [_approvalButton setNeedsDisplay];
}

- (void)setApprovalButtonHidden {
    _approvalButton.hidden = YES;
}

//写评论
- (void)setCommentButton
{
    if (!_commentButton) {
        _commentButton = [[SNTrendCommentButton alloc] initWithFrame:CGRectMake(0, 0,
                                                                                kSNTLTrendApprovalWidth, kSNTLTrendApprovalHeight)];
        _commentButton.right = self.width - kTLShareInfoViewApprovalCommentBtnMrigin;
        [self addSubview:_commentButton];
    }
    
    _commentButton.referFrom = self.referFrom;
    _commentButton.hidden = NO;
    _commentButton.actId = self.timelineTrendObj.actId;
    _commentButton.pid = self.timelineTrendObj.pid;
    _commentButton.top = CGRectGetMaxY(_originalContentRect) + kTLOriginalContentCommentBtnTopMargin;
    [_commentButton setNeedsDisplay];
}

//设置评论数
- (void)setCommentNum
{
    NSString *cmtNum = [NSString stringWithFormat:@"共有%d条评论", self.timelineTrendObj.commentNum];
    CGSize size = [cmtNum sizeWithFont:[UIFont systemFontOfSize:kTLShareInfoViewTimeFontSize]];
    CGFloat x = self.width - kTLOriginalContentTitleTopMargin - size.width;
    if (!self.cmtNumLabel) {
        self.cmtNumLabel = [[[UILabel alloc] initWithFrame:CGRectMake(x,
                                                                     CGRectGetMaxY(_originalContentRect) +
                                                                     kTLShareInfoVIewOriginalTimeMargin,
                                                                     size.width, size.height)] autorelease];
        [self.cmtNumLabel setText:cmtNum];
        [self.cmtNumLabel setTextColor:SNUICOLOR(kFloorCommentDateColor)];
        [self.cmtNumLabel setFont:[UIFont systemFontOfSize:kTLShareInfoViewTimeFontSize]];
        [self.cmtNumLabel setBackgroundColor:[UIColor clearColor]];
        
        [self addSubview:self.cmtNumLabel];
    }
    if (cmtNum.length > 0) {
        CGRect rect = CGRectMake(x,
                                 CGRectGetMaxY(_originalContentRect) +
                                 kTLShareInfoVIewOriginalTimeMargin,
                                 size.width, size.height);
        [self.cmtNumLabel setText:cmtNum];
        [self.cmtNumLabel setFrame:rect];
    }
}

- (void)setCommentButtonHidden {
    _commentButton.hidden = YES;
}

- (void)setCommentsView {
    if (self.timelineTrendObj.commentsArray.count > 0) {
        if (!_commentsView) {
            _commentsView = [[SNTrendCommentsView alloc] init];
            [self addSubview:_commentsView];
        }
        _commentsView.referFrom = self.referFrom;
        _commentsView.hidden = NO;
        _commentsView.delegate = self;
        CGRect rect = CGRectMake(_originalContentRect.origin.x,
                                 _approvalButton.bottom + kTLShareInfoViewApprovalCommentsMrigin,
                                 _originalContentRect.size.width,
                                 self.timelineTrendObj.commentsHeight);
        _commentsView.frame = rect;
        _commentsView.timelineObj = self.timelineTrendObj;
        _commentsView.moreBtnFrame = self.timelineTrendObj.moreCmtBtnFrame;
        _commentsView.commentsData = self.timelineTrendObj.commentsArray;
        _commentsView.indexPath = self.indexPath;
        [_commentsView setNeedsDisplay];
    }
    else {
        _commentsView.hidden = YES;
    }
}

#pragma mark - trendAction
- (void)openMoreComment
{
    self.timelineTrendObj.isOpenUgc = YES;
    self.timelineTrendObj.ugcHeight = .0f;
    self.timelineTrendObj.ugcContentHeight = .0f;
    self.timelineTrendObj.height = .0f;
    [self.timelineTrendObj sizeToFit];
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(timelineCellExpandComment)]) {
        [self.delegate performSelector:@selector(timelineCellExpandComment)];
    }
}

- (void)enterUserCenter:(NSMutableDictionary *)dic
{
    if (self.canEnterCenter) {
        NSString *pid = [dic objectForKey:kHeadIconKeyPid];
        [self openUserWithPid:pid];
    }
}

- (void)enterUserCenter
{
    if (self.canEnterCenter) {
        [self openUserWithPid:self.timelineTrendObj.pid];
    }
}

- (void)openUserWithPid:(NSString *)pid
{
    if (pid.length > 0) {
        [SNUserHelper openUserWithPassport:nil
                                 spaceLink:nil
                                 linkStyle:nil
                                       pid:self.timelineTrendObj.pid];
    }
}

- (void)clickImageView
{
    NSString *imageUrl = self.timelineTrendObj.ugcSmallImageUrl;
    NSString *imageBigUrl = self.timelineTrendObj.ugcBigImageUrl;
    
    if (![[SDImageCache sharedImageCache] imageFromDiskCacheForKey:imageUrl]) {
        // 加载失败后，点击加载小图
        if (imageUrl.length > 0) {
            //是本地url加载本地图片
            [_picView loadUrlPath:imageUrl];
        }
    }
    else {            // 显示大图
        NSString *sourceUrl = imageBigUrl;
        if (sourceUrl && sourceUrl.length > 0) {
            [self showImageWithUrl:sourceUrl];
        }
    }
}

- (void)deleteAction:(id)sender {
    // cc 统计
    if (self.referFrom == REFER_MORE) {
        SNUserTrack *curPage = [SNUserTrack trackWithPage:tab_me link2:nil];
        [[SNAnalytics sharedInstance] realtimeReportCCAnalyzeWithCurrentPage:curPage
                                                                      toPage:curPage
                                                              byUserFunction:f_delete
                                                                 otherParams:nil];
    }
    
    SNActionSheet *commentActionSheet = [[SNActionSheet alloc] initWithTitle:NSLocalizedString(@"trend_deleteButtonTitle", @"")
                                                                    delegate:self
                                                                   iconImage:[UIImage imageNamed:@"act_default_icon.png"]
                                                                     content:NSLocalizedString(@"trend_deleteTip", @"")
                                                                  actionType:SNActionSheetTypeDefault
                                                           cancelButtonTitle:NSLocalizedString(@"trend_deleteCancel", @"")
                                                      destructiveButtonTitle:NSLocalizedString(@"trend_deleteButtonTitle", @"")
                                                           otherButtonTitles:nil];
    [[TTNavigator navigator].window addSubview:commentActionSheet];
    [commentActionSheet showActionViewAnimation];
    [commentActionSheet release];
}

- (void)actionSheet:(SNActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex == 1)
    {
        NSMutableDictionary *dic = [NSMutableDictionary dictionary];
        [dic setObject:self forKey:kDeleteCellKeyCell];
        NSNumber *num = [NSNumber numberWithInt:self.indexPath];
        [dic setObject:num forKey:kDeleteCellKeyIndex];
        if (self.timelineTrendObj.actId.length > 0) {
            [dic setObject:self.timelineTrendObj.actId forKey:kDeleteCellKeyActId];
        }
        [[SNTimelinePostService sharedService]timelineDeleteTrend:self.timelineTrendObj.actId
                                                              pid:self.timelineTrendObj.pid
                                                         userInfo:dic];
    }
}


- (void)openOriginalContentAction:(id)sender {
    [[SNSoundManager sharedInstance] stopAll];
    if (self.timelineTrendObj.originContentObj.link.length > 0) {
        [SNUtility openProtocolUrl:self.timelineTrendObj.originContentObj.link context:nil];
    }
}

- (void)imageViewTapped:(id)sender {
    [self setOriginalImageUrl:self.timelineTrendObj.originContentObj.picUrl isRelyNetwork:NO];
    _originalImageView.userInteractionEnabled = NO;
}

#pragma mark - SNTrendCmtBtnDelegate
- (void)snTrendCmtBtnOpenMore:(NSString *)cmtId
{
    [SNTimelineTrendItem SNTimelineTrendCmtsReset:self.timelineTrendObj id:cmtId];
    if (self.delegate && [self.delegate respondsToSelector:@selector(timelineCellExpandComment)]) {
        [self.delegate performSelector:@selector(timelineCellExpandComment)];
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
    if (label == _abstractLabel) {
        [self openOriginalContentAction:nil];
    }
}

- (void)setOriginalImageUrl:(NSString *)urlPath isRelyNetwork:(BOOL)isDownload
{
    if (urlPath == nil) {
        _originalImageView.userInteractionEnabled = YES;
        [_originalImageView setImageWithURL:nil placeholderImage:_originalImageView.defaultImage];
    }
    else if ([[SDImageCache sharedImageCache] imageFromDiskCacheForKey:urlPath]) {
        _originalImageView.userInteractionEnabled = NO;
        [_originalImageView setImageWithURL:[NSURL URLWithString:urlPath] placeholderImage:_originalImageView.defaultImage];
    }
    else if (!isDownload || ![SNUtility getApplicationDelegate].shouldDownloadImagesManually) {
        [_originalImageView setImageWithURL:[NSURL URLWithString:urlPath]
                           placeholderImage:_originalImageView.defaultImage
                                    options:SDWebImageRetryFailed
                                  completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType) {
                                      if (image) {
                                          UIImageView *maskImageView = [[UIImageView alloc] initWithImage:_originalImageView.defaultImage];
                                          maskImageView.frame = CGRectMake(0, 0, _originalImageView.width, _originalImageView.height);
                                          maskImageView.alpha = _originalImageView.alpha;
                                          maskImageView.image = _originalImageView.defaultImage;
                                          [_originalImageView addSubview:maskImageView];
                                          
                                          // 下载完成
                                          BOOL enabled = (image == nil);
                                          _originalImageView.userInteractionEnabled = enabled;
                                          
                                          // Fade动画
                                          [UIView animateWithDuration:.3 animations:^{
                                              maskImageView.alpha = 0;
                                          } completion:^(BOOL finished) {
                                              [maskImageView removeFromSuperview];
                                          }];
                                      }
                                  }];
    } else {
        _originalImageView.userInteractionEnabled = YES;
        [_originalImageView setImageWithURL:nil placeholderImage:_originalImageView.defaultImage];
    }
}

#pragma mark -notification updateTheme
- (void)updateTheme {
    if ([self.timelineTrendObj.gender isEqualToString:@"2"]) {
        _headIconView.icon.defaultImage = [UIImage themeImageNamed:@"female_default_icon.png"];
    } else {
        _headIconView.icon.defaultImage = [UIImage themeImageNamed:@"login_user_defaultIcon.png"];
    }
    
    BOOL bNightMode = [[[SNThemeManager sharedThemeManager] currentTheme] isEqualToString:kThemeNight];
    _headIconView.alpha = bNightMode ? 0.7 : 1;
    _picView.alpha = bNightMode ? 0.7 : 1;
    [_soundView updateTheme];
    
    _userNameLabel.textColor = SNUICOLOR(kAuthorNameColor);
    _timeLabel.textColor = SNUICOLOR(kFloorCommentDateColor);
    _fromTypeLabel.textColor = SNUICOLOR(kFloorCommentDateColor);
    _contentLabel.textColor = SNUICOLOR(kFloorViewCommentContentColor);
    if (_abstractLabel) {
        _abstractLabel.textColor = SNUICOLOR(kRollingNewsCellDetailTextUnreadColor);
    }
//    obj.originDefaultImage = [UIImage imageNamed:@"timeline_default.png"];
    UIImage *bgImage = [UIImage imageNamed:@"timeline_origin_bg.png"];
    if ([bgImage respondsToSelector:@selector(resizableImageWithCapInsets:)]) {
        _originalBgView.image = [bgImage resizableImageWithCapInsets:UIEdgeInsetsMake(10, 10, 10, 10)];
    }
    else {
        _originalBgView.image = [bgImage stretchableImageWithLeftCapWidth:20 topCapHeight:10];
    }
    _originalImageView.alpha = [[[SNThemeManager sharedThemeManager] currentTheme] isEqualToString:kThemeNight] ? 0.7 : 1;
    
    if (_commentsView) {
        [_commentsView updateTheme];
    }
    
    if (_approvalButton) {
        [_approvalButton updateTheme];
    }
    
    if (_commentButton) {
        [_commentButton updateTheme];
    }
    
    [self setNeedsDisplay];
}

#pragma mark - bigImageView
- (void)showImageWithUrl:(NSString *)urlPath {
    if (_imageDetailView == nil) {
        CGRect applicationFrame     = [[UIScreen mainScreen] bounds];
//        applicationFrame.size.height = kAppScreenHeight;
        _imageDetailView   = [[UIView alloc] initWithFrame:applicationFrame];
        _imageDetailView.backgroundColor   = [UIColor blackColor];
        _imageDetailView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        
        _photoView = [[FGalleryPhotoView alloc] initWithFrame:CGRectMake(0, 0, _imageDetailView.width, _imageDetailView.height)];
        _photoView.photoDelegate = self;
        _photoView.imageView.defaultImage = [UIImage imageNamed:@"app_logo_gray.png"];
        _photoView.imageView.centerX = CGRectGetMidX(_photoView.bounds);
        _photoView.imageView.centerY = CGRectGetMidY(_photoView.bounds) + 30;
        [_imageDetailView addSubview:_photoView];
        
        NSRange range = [urlPath rangeOfString:kCommentImageFolderId];
        if (range.location != NSNotFound && range.length != 0) {
            NSData *imageData = [NSData dataWithContentsOfFile:urlPath];
            UIImage *image = [UIImage imageWithData:imageData];
            
            _photoView.imageView.frame = CGRectMake(0, 0,
                                                    _imageDetailView.frame.size.width,
                                                    _imageDetailView.frame.size.width / image.size.width * image.size.height);
            _photoView.contentSize = _photoView.imageView.size;
            if (_photoView.imageView.height < _photoView.height) {
                _photoView.imageView.centerY = CGRectGetMidY(_photoView.bounds);
            }
            _photoView.imageView.defaultImage  = image;
            
        } else {
            if (!_photoView.imageView.hasLoaded) {
                [_photoView.activity startAnimating];
            }
            
            [_photoView.imageView loadUrlPath:urlPath completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType){
                [_photoView.activity stopAnimating];
                if (image) {
                    _photoView.imageView.frame = CGRectMake(0, 0,
                                                            _imageDetailView.frame.size.width,
                                                            _imageDetailView.frame.size.width / image.size.width * image.size.height);
                    _photoView.contentSize = _photoView.imageView.size;
                    if (_photoView.imageView.height < _photoView.height) {
                        _photoView.imageView.centerY = CGRectGetMidY(_photoView.bounds);
                    }
                }
                if (error) {
                    [SNNotificationCenter showMessage:NSLocalizedString(@"PhotoDownloadFail", @"Photo Download Failed")];
                }
            }];
        }
        
        CGFloat alphaToShow = [[[SNThemeManager sharedThemeManager] currentTheme] isEqualToString:kThemeNight] ? 0.7 : 1;
        NSString *backImageString = [[SNThemeManager sharedThemeManager] themeFileName:@"photo_slideshow_back.png"];
        UIImage *backImage = [[UIImage imageNamed:backImageString] scaledImage];
        UIButton *btn = [[UIButton alloc] initWithFrame:CGRectMake(0,
                                                                   _imageDetailView.height - backImage.size.height,
                                                                   backImage.size.width,
                                                                   backImage.size.height)];
        if (backImage) {
            [btn setImage:backImage forState:UIControlStateNormal];
        }
        btn.alpha = alphaToShow;
        [btn addTarget:self action:@selector(cancelViewSharedImage:) forControlEvents:UIControlEventTouchUpInside];
        [_imageDetailView addSubview:btn];
        [btn release];
        
        NSString *downloadImageString = [[SNThemeManager sharedThemeManager] themeFileName:@"photo_slideshow_download.png"];
        UIImage *downloadImage = [[UIImage imageNamed:downloadImageString] scaledImage];
        
        UIButton *btn1 = [[UIButton alloc] initWithFrame:CGRectMake(_imageDetailView.width - downloadImage.size.width,
                                                                    _imageDetailView.size.height - downloadImage.size.height,
                                                                    downloadImage.size.width,
                                                                    downloadImage.size.height)];
        btn1.tag = kDownloadBtnTag;
        if (downloadImage) {
            [btn1 setImage:downloadImage forState:UIControlStateNormal];
        }
        btn1.alpha = alphaToShow;
        [btn1 addTarget:self action:@selector(downloadViewSharedImage:) forControlEvents:UIControlEventTouchUpInside];
        [_imageDetailView addSubview:btn1];
        [btn1 release];
    }
    [[UIApplication sharedApplication].keyWindow addSubview:_imageDetailView];
    
    _imageDetailView.alpha = 0;
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:0.2];
    _imageDetailView.alpha = 1.0;
    [UIView commitAnimations];
}

- (void)viewTaped:(UIGestureRecognizer *)rcg {
    if (_imageDetailView.alpha == 1.0) {
        [self cancelViewSharedImage:nil];
    }
}

- (void)didTapPhotoView:(FGalleryPhotoView*)photoView {
    if (_imageDetailView.alpha == 1.0) {
        [self cancelViewSharedImage:nil];
    }
}

- (void)cancelViewSharedImage:(id)sender {
    if (_imageDetailView != nil)
    {
        if (_imageDetailView.alpha > 0) {
            [UIView beginAnimations:nil context:nil];
            [UIView setAnimationDuration:0.2];
            [UIView setAnimationDelegate:self];
            [UIView setAnimationDidStopSelector:@selector(removeAnimationDidStop:finished:context:)];
            _imageDetailView.alpha = 0;
            [UIView commitAnimations];
        } else {
            [_imageDetailView removeFromSuperview];
            TT_RELEASE_SAFELY(_imageDetailView);
        }
    }
}

#pragma mark -  photoView action
- (void)downloadViewSharedImage:(id)sender {
    UIButton *btn = (UIButton *)[_imageDetailView viewWithTag:kDownloadBtnTag];
    SNWebImageView *imageView = _photoView.imageView;
    if (btn) {
        UIImageWriteToSavedPhotosAlbum(imageView.image, [SNUtility getApplicationDelegate], @selector(image:didFinishSavingWithError:contextInfo:), nil);
    }
}

- (void)image:(UIImage *)image didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo {
	SNDebugLog(@"照片失败%@", [error localizedDescription]);
    //    [ setButton:kDownloadBtnTag enabled:YES];
    //    _downloadButton.enabled = YES;
	[[SNUtility getApplicationDelegate] image:image didFinishSavingWithError:error contextInfo:contextInfo];
}

- (void)removeAnimationDidStop:(NSString *)animationID finished:(NSNumber *)finished context:(void *)context;
{
    TT_RELEASE_SAFELY(_photoView);
    [_imageDetailView removeFromSuperview];
    TT_RELEASE_SAFELY(_imageDetailView);
}


@end
