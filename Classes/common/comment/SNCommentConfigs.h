//
//  SNCommentConfigs.h
//  sohunews
//
//  Created by jialei on 14-2-13.
//  Copyright (c) 2014年 Sohu.com. All rights reserved.
//

#ifndef sohunews_SNCommentConfigs_h
#define sohunews_SNCommentConfigs_h

typedef NS_ENUM(NSInteger, SNCommentItemType)
{
    SNCommentItemTypeComment = 0,
    SNCommentItemTypeOpenHotComment = 1,
    SNCommentItemTypeCommentSection = 2,
    SNCommentItemTypeRecommendSection = 3
};

typedef NS_ENUM(NSInteger, SNCommentRequestIdType)
{
    SNCommentRequestTypeNewsId = 1,
    SNCommentRequestTypeGid = 2
};

typedef NS_ENUM(NSInteger, SNCommentSendType)
{
    kCommentSendTypeComment = 0,
    kCommentSendTypeReply = 1,
    kCommentSendTypeReplyFloor
};

typedef NS_ENUM(NSInteger, SNMyMessageType)
{
    kMyMessageSociale = 0,
    kMyMessageComment = 1
};

typedef enum {
    SNMessageTypeApiMsg = 0,
    SNMessageTypeCircleMsg = 1,
    SNMessageTypeCircleMsgReply = 2,
    SNMessageTypeApiLive = 4
}SNMessageType;

typedef NS_OPTIONS(NSUInteger, SNCommentEditorViewType)
{
    SNComment        = 0,
    SNReplyComment   = 1
};

typedef NS_ENUM(NSUInteger, SNCommentStatus)
{
    SNCommentStatusNormal   = 1,
    SNCommentStatusDelete = 2
};

typedef NS_ENUM(NSInteger, SNCommentRequestType)
{
    NSCommentRequestTypeHot = 0,
    NSCommentRequestTypeNew = 1
};

typedef NS_ENUM(NSInteger, SNCommentMediaType)
{
    SNCommentMediaTypeVip = 1,
    SNCommentMediaTypeOrganization = 2,
    SNCommentMediaTypeVideo = 3,
    SNCommentMediaTypeGovernment = 4
};

#define kHotCommentFirstPageSize    10
#define kNewCommentFirstPageSize    10
#define kHotCommentNextPageSize        20
#define kNewCommentNextPageSize        10
#define kSHowOpenHotCommentCellLimitNum 10

#define kComment							(@"comment")
#define kMyComment                          (@"myComment")
#define kTotal								(@"total")
#define kCtime								(@"ctime")
#define kFromIcon                           (@"fromIcon")
#define kStatus                             (@"status")
#define kCmtStatus                          (@"comtStatus")
#define kCmtHint                            (@"comtHint")
#define kCmtBusiCode                        (@"busiCode")
#define kCmtAttachList                      (@"attach")
#define kCmtRemarkTips                      (@"comtRemarkTips")
#define kOrgHomePage                        (@"egHomePage")
#define kNewsMark                           (@"newsMark")
#define kOriginFrom                         (@"originFrom")
#define kOriginTitle                        (@"originTitle")
#define kTime								(@"time")
#define kAuthor								(@"author")
#define kBadgeList                          (@"signList")
#define kMediaType                          (@"mediaType")

#pragma mark- sendComment
static NSString *const commentBusicodeLiveRoom = @"1";
static NSString *const commentBusicodeNews = @"2";
static NSString *const commentBusicodePhoto = @"3";
static NSString *const commentBusicodeWeibo = @"4";


#define kCLKeyNewsId    (@"kCLKeyNewsId")
#define kCLKeyGid       (@"kCLKeyGid")
#define kCLKeyIsAuthor  (@"kCLKeyIsAuthor")
#define kCLKeySubId     (@"kCLKeySubId")

#define kEditorKeyViewType      @"kEidtorKeyViewType"
#define kCommentToolBarType     @"kCommentToolBarType"
#define kEditorKeyNewsId        @"kEditorKeyNewsId"
#define kEditorKeyReplayName    @"kEditorKeyReplayName"
#define kEditorKeyComtStatus    @"kEditorKeyComtStatus"
#define kEditorKeyComtHint      @"kEditorKeyComtHint"
#define kEditorKeySendCmtObj    @"kEditorKeySendCmtObj"
#define kEditorKeyShareCmtObj   @"kEditorKeyShareCmtObj"
#define kEditorKeyCacheComment  @"kEditorKeyCacheComment"
//#define kEditorKeyDelegate      @"kEditorKeyDelegate"

static NSString *const shareAppStatusBinded  = @"0";         //绑定

#define kDownloadBtnTag                     (1004)

#define SNCLLoadMoreBuf     40

#pragma mark - commentEditor
#define kDeleteButtonGap            3
#define kDeleteButtonWidth          (66/2)
#define kDeleteButtonHeight         (66/2)
#define kMaxRecordTime              59
#define kMediaViewGapY              5
#define kMediaViewGapX              10
//#define kRecordViewOriginY          38
#define kInputSoundViewWidth        (128/2)
#define kInputSoundViewHeight       (68/2)
#define kCEAnimationDuration        0.25
#define kCommentKeyboardHeight  216

#define kPicViewLeft            (28 + 16)/2
#define kPicViewTop             (130)/2

#define kCommentMoreCellHeight      54
#define kTipButtonLeftGap   (28 / 2)

#pragma mark - shareCommentToolBar
#define kCommentToolBarHeight               50

#define KSNCS_TOOLBAR_TITLE_FONT            (32 / 2)
#define KSNCS_TOOLBAR_HEIGHT                (88/2)
#define KSNCS_TOOLBAR_STARTPOSITION         (44 / 2)
#define KSNCS_TOOLBAR_ICON_WIDTH            (26/2)
#define KSNCS_TOOLBAR_ICON_SPACE            (22/2)
#define KSNCS_TOOLBAR_TITLE_TOP             (28/2)

#pragma mark - openCommentCell

#define kOpenHotCommentCellHeight           50
#define kNewCommentTitleSectionHeight       30
#define kCommentEmptyClickedViewHeight      200

#pragma mark - commentListCell UI
//评论
#define kFLOOR_COMMENT_LEFT_RIGHT_MARGIN              (22 / 2)
#define kFLOOR_COMMENT_TOP_MARGIN                     (6.5)
#define kFLOOR_COMMENT_USER_INFO_HEIGHT               (16)
#define kFLOOR_COMMENT_FLOOR_NUM_WIDTH                (30)
#define kFLOOR_COMMENT_CONTENT_FONT                   ([SNUtility newsContentFontSize])
#define kFLOOR_COMMENT_CONTENT_TOP_MARGIN             (9)
#define kFLOOR_COMMENT_CONTENT_BOTTOM_MARGIN          (18.5)
#define KFLOOR_COMMENT_NEWSTITLE_TOP_MARGIN           (20/2)
#define KFLOOR_COMMENT_NEWSTITLE_HEIGHT               (74/2)
#define KFLOOR_COMMENT_NEWSTITLE_LABEL_HEIGHT         (60 / 2)
#define KFLOOR_COMMENT_NEWSTITLE_BOTTOM_MARGIN        (18/2)
#define CELL_CONTENT_LEFT_MARGIN                      (108.0f / 2)
#define CELL_EXPAND_FONT                              ([SNUtility newsContentFontSize])
#define CEll_CONTENT_LINE_HEIGHT                      ([SNUtility newsContentFontLineheight])
#define CELL_RIGHT_MARGIN                             (28 / 2)
#define CELL_TOP_MARGIN                               (22.0f/2)
#define CELL_BOTTOM_MARGIN                            (22.0f/2)
#define CELL_USER_INFO_HEIGHT                         (28.0f/2)
#define CELL_OPEN_BTN_MARGIN                          (26.0f)
#define KCOMMENT_THUMBNAIL_LINENUM                    (8)
#define kCommentUserInfoTopBottomMargin                4
#define kTitlePicOffset                               (34 / 2)

#endif
