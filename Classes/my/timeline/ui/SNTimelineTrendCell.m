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
#import "SNUserUtility.h"
#import "SNTimelinePostService.h"
#import "SNUserManager.h"
#import "SNGalleryPhotoView.h"
#import "SNEmoticonManager.h"
#import "SNCommentConfigs.h"
#import "SNNewAlertView.h"

#define kDownloadBtnTag   (1004)

@interface SNTimelineTrendCell()
{
    SNGalleryPhotoView *_imageDetailView;
    
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
        [SNNotificationManager addObserver:self
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
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wundeclared-selector"
        [SNNotificationManager addObserver:self
                                                 selector:@selector(updateCommentNum)
                                                     name:notificationTimelineCommentSuc object:nil];
#pragma clang diagnostic pop

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
    [SNNotificationManager removeObserver:self];
     //(_timelineTrendObj);
     //(_originalTapview);
     //(_originalImageView);
     //(_abstractLabel);
     //(_userNameLabel);
     //(_sourceLabel);
     //(_fromTypeLabel);
     //(_headIconView);
     //(_abstractLabel);
     //(_contentLabel);
     //(_soundView);
     //(_picView);
     //(_originalImageView);
     //(_videoIconView);
     //(_moreButton);
     //(_commentButton);
     //(_approvalButton);
     //(_commentsView);
     //(_cmtNumLabel);
     //(_imageDetailView);
     //(_deleteButton);
    
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
    
    [self setNeedsDisplay];
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
        _timeLabel.textAlignment = NSTextAlignmentRight;
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
                                                                  kAppScreenWidth - kTLViewSideMargin - kTLShareInfoViewTextLeftMargin,
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
//        //计算表情符号在字符串中的位置
//        NSDictionary *imageRangeDic = [[SNEmoticonManager sharedManager] parseEmoticonImageFromText:self.timelineTrendObj.content];
//        
//        if ([imageRangeDic count] > 0) {
//            [_contentLabel addEmoticons:imageRangeDic];
//        }
//        else {
//            [_contentLabel removeAllEmoticonInfo];
//        }
        
        _viewOffsetY = _contentLabel.bottom;
    }
    else {
        _contentLabel.hidden = YES;
        _viewOffsetY = _userNameLabel.bottom;
    }
    _contentLabel.alpha = themeImageAlphaValue();
    [self setMoreButton];
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
//        [_moreButton setTitle:NSLocalizedString(@"OpenComment", @"") forState:UIControlStateNormal];
        [_moreButton.titleLabel setFont:font];
        _moreButton.width = [NSLocalizedString(@"OpenComment", @"") sizeWithFont:_moreButton.titleLabel.font].width;
        [self addSubview:_moreButton];
    }
    
    if(!self.timelineTrendObj.isOpenUgc && self.timelineTrendObj.needOpenUgc)
    {
        CGSize stringSize = [NSLocalizedString(@"OpenComment", @"") sizeWithFont:font];
        _moreButton.frame = CGRectMake(kTLShareInfoViewTextLeftMargin, _contentLabel.bottom,
                                       stringSize.width, SNTIMELINE_SHAREINFO_MORE_HEIGHT);
        [_moreButton setTitle:NSLocalizedString(@"OpenComment", @"") forState:UIControlStateNormal];
        _viewOffsetY = _moreButton.bottom;
        __weak __typeof(&*self)weakSelf = self;
        [_moreButton setActionBlock:^(UIControl *control) {
            [weakSelf openMoreComment];
        } forControlEvents:UIControlEventTouchUpInside];
    } 
    else
    {
        _moreButton.frame = CGRectZero;
        [_moreButton setTitle:nil forState:UIControlStateNormal];
    }
}

//转发原文
- (void)setOriginView
{
    if (!_originalTapview) {
        _originalTapview = [[UIView alloc] init];
        [self addSubview:_originalTapview];
        
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(openOriginalContentAction:)];
        tap.delegate = self;
        [_originalTapview addGestureRecognizer:tap];
         //(tap);
    } 
    _originalTapview.frame = _originalContentRect;
}

- (void)setOriginBgImageView
{
    CGSize originSize = CGSizeMake(kTLOriginalContentWidth, llroundf(self.timelineTrendObj.originContentHeight));
    _originalContentRect = CGRectMake(kAppScreenWidth - originSize.width - 9,
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
        _originFromLabel.lineBreakMode = NSLineBreakByTruncatingTail;
        [self addSubview:_originFromLabel];
    }
    _originFromLabel.textColor = SNUICOLOR(kTLViewFromTextColor);
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
            
            if (!_deleteButton) {
                _deleteButton = [UIButton buttonWithType:UIButtonTypeCustom];
                _deleteButton.titleLabel.font = deleteFont;
                _deleteButton.backgroundColor = [UIColor clearColor];
            }
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
        CGFloat right = kAppScreenWidth - kTLShareInfoViewApprovalCommentBtnMrigin * 2 - kSNTLTrendApprovalWidth;
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
        _commentButton.right = kAppScreenWidth - kTLShareInfoViewApprovalCommentBtnMrigin;
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
        self.cmtNumLabel = [[UILabel alloc] initWithFrame:CGRectMake(x,
                                                                     CGRectGetMaxY(_originalContentRect) +
                                                                     kTLShareInfoVIewOriginalTimeMargin,
                                                                     size.width, size.height)];
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
            _commentsView.alpha = themeImageAlphaValue();
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
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wundeclared-selector"
    if (self.delegate && [self.delegate respondsToSelector:@selector(timelineCellExpandComment)]) {
        [self.delegate performSelector:@selector(timelineCellExpandComment)];
    }
#pragma clang diagnostic pop

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
        [SNUserUtility openUserWithPassport:nil
                                 spaceLink:nil
                                 linkStyle:nil
                                       pid:self.timelineTrendObj.pid
                                       push:@"0" refer:nil];
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
        NSString *paramString = [NSString stringWithFormat:kAnalyticsUrlCC, [curPage toFormatString], [curPage toFormatString], f_delete];
        [SNNewsReport reportADotGifWithTrack:paramString];
    }
    
//    SNConfirmFloatView* confirmView = [[SNConfirmFloatView alloc] init];
//    confirmView.message = NSLocalizedString(@"trend_deleteTip", @"");
//    [confirmView setConfirmText:NSLocalizedString(@"trend_deleteButtonTitle", @"") andBlock:^{
//        [self deleteDynamicState];
//    }];
//    if (![SNBaseFloatView isFloatViewShowed]) {
//        [confirmView show];
//    }
    SNNewAlertView *alert = [[SNNewAlertView alloc] initWithTitle:nil message:NSLocalizedString(@"trend_deleteTip", @"") cancelButtonTitle:@"取消" otherButtonTitle:NSLocalizedString(@"trend_deleteButtonTitle", @"")];
    [alert show];
    [alert actionWithBlocksCancelButtonHandler:^{
        
    } otherButtonHandler:^{
        [self deleteDynamicState];
    }];
    
}

- (void)deleteDynamicState {
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
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wundeclared-selector"
    [SNTimelineTrendItem SNTimelineTrendCmtsReset:self.timelineTrendObj id:cmtId];
    if (self.delegate && [self.delegate respondsToSelector:@selector(timelineCellExpandComment)]) {
        [self.delegate performSelector:@selector(timelineCellExpandComment)];
    }
#pragma clang diagnostic pop

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
        [_originalImageView sd_setImageWithURL:nil placeholderImage:_originalImageView.defaultImage];
    }
    else if ([[SDImageCache sharedImageCache] imageFromDiskCacheForKey:urlPath]) {
        _originalImageView.userInteractionEnabled = NO;
        [_originalImageView sd_setImageWithURL:[NSURL URLWithString:urlPath] placeholderImage:_originalImageView.defaultImage];
    }
    else if (!isDownload || ![SNUtility getApplicationDelegate].shouldDownloadImagesManually) {
        [_originalImageView sd_setImageWithURL:[NSURL URLWithString:urlPath]
                           placeholderImage:_originalImageView.defaultImage
                                    options:SDWebImageRetryFailed
                                  completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
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
        [_originalImageView sd_setImageWithURL:nil placeholderImage:_originalImageView.defaultImage];
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
    _contentLabel.alpha = themeImageAlphaValue();
    _sourceLabel.textColor = SNUICOLOR(kFloorCommentDateColor);
    _originTitleLabel.textColor = SNUICOLOR(kTLViewTitleTextColor);
    _originFromLabel.textColor = SNUICOLOR(kTLViewFromTextColor);
    [_deleteButton setTitleColor:SNUICOLOR(kAuthorNameColor) forState:UIControlStateNormal];
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
        _commentsView.alpha = themeImageAlphaValue();
    }
    
    if (_approvalButton) {
        [_approvalButton updateTheme];
    }
    
    if (_commentButton) {
        [_commentButton updateTheme];
    }
}

#pragma mark - bigImageView
- (void)showImageWithUrl:(NSString *)urlPath {
    if (_imageDetailView == nil) {
        CGRect applicationFrame     = [[UIScreen mainScreen] bounds];
        _imageDetailView   = [[SNGalleryPhotoView alloc] initWithFrame:applicationFrame];
    }
    [_imageDetailView loadImageWithUrlPath:urlPath];
    
    [[UIApplication sharedApplication].keyWindow addSubview:_imageDetailView];
    
    _imageDetailView.alpha = 0;
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:0.2];
    _imageDetailView.alpha = 1.0;
    [UIView commitAnimations];
}

- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer
{
    return YES;
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch
{
    if ([gestureRecognizer.view isKindOfClass:[UIButton class]]) {
        return NO;
    }
    return YES;
}

@end
