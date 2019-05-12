//
//  SNTimelineConfigs.h
//  sohunews
//
//  Created by jojo on 13-6-24.
//  Copyright (c) 2013年 Sohu.com. All rights reserved.
//

#ifndef sohunews_SNTimelineConfigs_h
#define sohunews_SNTimelineConfigs_h

#import "UIColor+ColorUtils.h"
#import "NSDate-Utilities.h"

typedef NS_ENUM(NSInteger, SNCommentErrorCode)
{
    kCommentErrorNoError     =  0,
    kCircleDetailErrorDelete =  9116,
    kCommentErrorCodeNoData  =  1000,
    kCommentErrorCodeDisconnect = -1009,
    kCommentErrorCodeTimeOut = -1001,
    kCommentErrorCancel      =  250
};

typedef NS_ENUM(NSInteger, SNMoreCellState)
{
    kRCMoreCellStateLoadingMore,
    kRCMoreCellStateDragRefresh,
    kRCMoreCellStateEnd
};

typedef NS_ENUM(NSInteger, SNTimelineActType)
{
    SNTimelineActTypeUGCPublic    = 501,
    SNTimelineActTypeUGCShareSina   = 502,
    SNTimelineActTypeUGCShareWieXin = 503,
    SNTimelineActTypeUGCShareQQ     = 504
};


static NSString * const notificationTimelineCommentSuc  = @"timelineCommentSuc";

#define kDeleteCellKeyCell                      (@"kDeleteCellKeyCell")
#define kDeleteCellKeyIndex                     (@"kDeleteCellKeyIndex")
#define kDeleteCellKeyActId                     (@"actId")
#define kSNTLTrendKeyActId                      (@"actId")                

#define kTimelineMaxCommentDisplayNum           (5)

// time line origin content common view
#define kTLViewSideMargin                       (20 / 2)

#define kTLViewTitleFontSize                    (30 / 2)
#define kTLViewTitleTopMargin                   (24 / 2)

#define kTLViewFromBottomMargin                 (22 / 2)
#define kTLViewFromFontSize                     (22 / 2)

#define kTLViewImageWidth                       (170 / 2)
#define kTLViewImageHeight                      (121 / 2)
#define kTLViewImageTopMarigin                  (21 / 2)
#define kTLViewTextLeftMargin                   (kTLViewSideMargin + kTLViewImageWidth + 16 / 2)

#define kTLViewWidth                            (kAppScreenWidth - 56) //(528 / 2)
#define kTLViewWidthForShare                    (kAppScreenWidth - 14) //(612 / 2)

#define kTLViewViewMinHeight                    (128 / 2)
#define kTLViewViewMaxHeight                    (162 / 2)

#define kTLViewViewLiveOriginalHeight           (112 / 2)
#define kTLViewViewPeopleOriginalHeight         (0)
// sub
#define kTLViewSubViewHeight                    (138 / 2)
#define kTLViewSubIconTopMargin                 (21 / 2)
#define kTLViewSubIconSize                      (98 / 2)
#define kTLViewSubTextLeftMargin                (kTLViewSideMargin + kTLViewSubIconSize + 16 / 2)
#define kTLViewSubNameTopMargin                 (24 / 2)
#define kTLViewSubCountBottomMargin             (22 / 2)

// timeline cell
#define kTLCellOriginContentTopMargin           (12 / 2)
#define kTLCellUserNameHeight                   (30 / 2)
#define kTLCellTopBottomMargin                  (20 / 2)
#define kDeleteAndCommentButtonGap              (30 / 2)

// share info view
#define kTLShareInfoViewIconSize                (72 / 2)
#define kTLShareInfoViewIconTopMargin           (16 / 2)

#define kTLShareInfoViewTextLeftMargin          (kTLViewSideMargin + kTLShareInfoViewIconSize + kTLViewSideMargin)

#define kTLShareInfoViewNameTopMargin           (20 / 2)
#define kTLShareInfoViewNameContentMargin       (20 / 2)
#define kTLshareInfoViewContentOriginalMargin   (20 / 2)
#define kTLShareInfoVIewOriginalTimeMargin      (28 / 2)
#define kTLShareInfoViewOriginalCommentsMrigin  (16 / 2)
#define kTLShareInfoCommentButtonHeight         (46 / 2)
#define kTLShareInfoViewNameFontSize            (30 / 2)
#define kTLShareInfoViewDeleteBtnFontSize       (22 / 2)
#define kTLShareInfoViewApprovalCommentBtnMrigin   (20 / 2)
#define kTLShareInfoViewApprovalCommentsMrigin  (6 / 2)
#define kTLShareInfoCommentsTopMrigin           (6 / 2)

#define kTLShareInfoViewTimeTopMargin           (20 / 2)
#define kTLShareInfoViewTimeFontSize            (24 / 2)
#define kApprovalFontSize                       (22 / 2)

#define kTLShareInfoViewContentTopMargin        (kTLShareInfoViewIconTopMargin + kTLShareInfoViewIconSize + 16 / 2)
#define kTLShareInfoViewContentFontSize         (30 / 2)
#define kTLShareInfoViewContentLineSpacing      (15 / 2)
#define kTLShareInfoViewContentLineHeight       (kTLShareInfoViewContentLineSpacing + kTLShareInfoViewContentFontSize)

//for 折叠
#define SNTIMELINE_SHAREINFO_LINE_MAX_WITH_MORE    (6)
#define SNTIMELINE_SHAREINFO_LINE_MAX_WITHOUT_MORE (8)
#define SNTIMELINE_SHAREINFO_MORE_HEIGHT           ([UIFont systemFontOfSize:kTLShareInfoViewNameFontSize].lineHeight + 2)


// comment array view
#define kTLCommentsViewIconHeight               (72 / 2)
#define kTLCommentsViewMoreCellHeight           (72 / 2)
#define kTLCommentsViewTopBottomMargin          (12 / 2)
#define kTLCommentsViewLeftRightMargin          (16 / 2)
#define kTLCommentsViewNameTextMargin           (12 / 2)
#define kTLCommentsViewTextWidth                (kAppScreenWidth - 78)
#define kTLCommentsViewTextLineSpacing          (8.0 / 2)
#define kTLCommentsViewTextLineHeight           (kTLCommentsViewTextFontSize + kTLCommentsViewTextLineSpacing)

#define kTLCommentsViewTextFontSize             (28 / 2)
#define kTLCommentsViewUserNameFontSize         (30 / 2)
#define kTLCommentsViewTimeLabelFontSize        (22 / 2)

//for 折叠        
#define SNTIMELINE_SHAREINFO_COMMENT_MAX_WIDTH_MORE    (6)
#define SNTIMELINE_SHAREINFO_COMMENT_MAX_WIDTHOUT_MORE (8)
#define SNTIMELINE_SHAREINFO_COMMENT_MORE_HEIGHT       (kTLShareInfoViewNameFontSize + 1)

// 加长版 动态  新ui布局
//#define kTLOriginalContentWidth                 (506 / 2)
#define kTLOriginalContentWidth                 (kAppScreenWidth - 67)

#define kTLOriginalContentTextSideMargin        (16 / 2)
#define kTLOriginalContentVerticalMargin        (16 / 2)

#define kTLOriginalContentTitleFontSize         (30 / 2)
#define kTLOriginalContentTitleTopMargin        (20 / 2)

#define kTLOriginalContentFromFontSize          (22 / 2)
#define kTLOriginalContentFromTopMargin         (20 / 2)

#define kTLOriginalContentAbstractFontSize      (30 / 2)
#define kTLOriginalContentAbstractLineSpacing   (12 / 2)
#define kTLOriginalContentAbstractLineHeight    (kTLOriginalContentAbstractFontSize + kTLOriginalContentAbstractLineSpacing)
#define kTLOriginalContentAbstractTopMargin     (8)

#define kTLOriginalContentImageTopMargin        (20 / 2)
#define kTLOriginalContentImageBottomMargin     (16 / 2)
#define kTLOriginalContentImageSideMargin       (14 / 2)
#define kTLOriginalContentImageWidth            (kTLOriginalContentWidth - 2 * kTLOriginalContentImageSideMargin)
#define kTLOriginalContentIamgeMaxHeight        (680 / 2)

#define kTLOriginalContentCommentBtnTopMargin   (16 / 2)
#define kTLOriginalPeopleViewHeadIconSize       (82 / 2)
#define kTLOriginalPeopleViewLineNum            (kAppScreenWidth == 320 ? 5 : (kAppScreenWidth == 375 ? 6 : 7))

// 动态 发表图片  语音
#define kPicViewWidth                                (54)
#define kPicViewHeight                               (54)

#define SOUNDVIEW_WIDTH 232
#define SOUNDVIEW_HEIGHT  38
#define SOUNDVIEW_SPACE 8

#define kTimelineDetailCommentPageNum                (10)

#pragma mark- detailView
#define kCircleDetailKeyPid     (@"kCircleDetailKeyPid")
#define kCircleDetailKeyActId   (@"actId")
#define kCircleDetailKeyAvlNum  (@"kCircleDetailKeyAvlNum")
#define kCircleDetailKeyIndex   (@"kCircleDetailKeyIndex")

#endif
