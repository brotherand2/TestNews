//
//  SNTimelineTrendObjects.m
//  sohunews
//
//  Created by jialei on 13-9-11.
//  Copyright (c) 2013年 Sohu.com. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SNTimelineTrendObjects.h"
#import "SNTimelineConfigs.h"
#import "extThree20JSON/NSObject+YAJL.h"
#import "SNLabel.h"
#import "NSAttributedString+Attributes.h"

#define kTrendObjectKeyActObject    @"subAct"
#define kTrendObjectKeyOuterShare   @"outerShare"
#define kTrendObjectKeyApiComment   @"apiComment"
#define kTrendObjectKeyShareInfo    @"shareInfo"    //阅读圈

#define kTrendObjectkeyId       @"actId"
#define kTrendObjectKeyType     @"actTemplate"
#define kTrendObjectKeyContent  @"content"
#define kTrendObjectKeyFloorDic @"comtFloor"
#define kTrendObjectKeyTime     @"actTime"
#define kTrendObjectKeyOrigin   @"originContent"
#define kTrendObjectKeyNickName     @"nickName"
#define kTrendObjcetKeyHeadUrl      @"headUrl"
#define kTrendObjectKeyPid          @"pid"
#define kTrendObjectKeyActTitle     @"actTitle"
#define kTrendObjectKeyGender       @"gender"

#define kAbstractTitleLine 10

@implementation SNTimelineTrendItem

@synthesize trendType;
@synthesize actId = _actId;
@synthesize pid = _pid;
@synthesize userNickName = _userNickName;
@synthesize userHeadUrl = _userHeadUrl;
@synthesize trendTitle = _trendTitle;
@synthesize content = _content;
@synthesize floorContent = _floorContent;
@synthesize time = _time;
@synthesize gender = _gender;
@synthesize originBgImage = _originBgImage;
@synthesize originDefaultImage = _originDefaultImage;
@synthesize subIconBgImage = _subIconBgImage;
@synthesize originContentObj = _originContentObj;

+ (SNTimelineTrendItem *)timelineTrendFromDic:(NSDictionary *)itemDic
{
    SNTimelineTrendItem *item = nil;
    
    if (itemDic)
    {
        item = [[[SNTimelineTrendItem alloc] init] autorelease];
//        item.trendType = type;
        //默认不展开用户发表内容
        item.isOpenUgc = NO;
        item.needOpenUgc = NO;
        item.showAllComment = NO;
        item.actId      = [itemDic stringValueForKey:kTrendObjectkeyId defaultValue:nil];
        item.trendType  = [itemDic intValueForKey:kTrendObjectKeyType defaultValue:0];
        item.trendTitle = [itemDic stringValueForKey:kTrendObjectKeyActTitle defaultValue:nil];
        item.time       = [itemDic stringValueForKey:kTrendObjectKeyTime defaultValue:nil];
        item.hideTop    = ([itemDic intValueForKey:@"hideTop" defaultValue:0] == 1);
        item.hideComment = ([itemDic intValueForKey:@"hideComment" defaultValue:0] == 1);
        
        [SNTimelineTrendItem actorInfoFromDic:itemDic trendItem:item];
        [SNTimelineTrendItem topInfoFromDic:itemDic trendItem:item];
        [SNTimelineTrendItem actInfoFromDic:itemDic trendItem:item];
        [SNTimelineTrendItem commentInfoFromDic:itemDic trendItem:item];
        
        [item sizeToFit];
    }
    return item;
}

//动态作者解析
+ (void)actorInfoFromDic:(NSDictionary *)infoDic trendItem:(SNTimelineTrendItem *)obj {
    NSDictionary *actorDic = [infoDic dictionaryValueForKey:@"actorInfo" defalutValue:nil];
    if (actorDic) {
        obj.userNickName = [actorDic stringValueForKey:kTrendObjectKeyNickName defaultValue:@"搜狐新闻客户端网友"];
//        obj.userNickName = @"搜狐新闻客户端网友";
        obj.userHeadUrl = [actorDic stringValueForKey:kTrendObjcetKeyHeadUrl defaultValue:nil];
        obj.pid = [actorDic stringValueForKey:kTrendObjectKeyPid defaultValue:nil];
        obj.gender = [actorDic stringValueForKey:kTrendObjectKeyGender defaultValue:@"1"];
    }
}

//动态原文解析
+ (void)actInfoFromDic:(NSDictionary *)infoDic trendItem:(SNTimelineTrendItem *)obj {
    NSString *actInfoJson = [infoDic stringValueForKey:@"actInfo" defaultValue:nil];
    NSData *infoJsonData = [actInfoJson dataUsingEncoding:NSUTF8StringEncoding];
    NSDictionary *actInfoDic = [infoJsonData yajl_JSON];
    if (actInfoDic) {
        obj.content = [actInfoDic stringValueForKey:@"content" defaultValue:nil];
//        if (obj.content.length <= 0) {
//            obj.content = obj.trendTitle;
//        }
        obj.content = [obj.content trim];
        obj.ugcBigImageUrl = [actInfoDic stringValueForKey:@"imageBig" defaultValue:nil];
        obj.ugcSmallImageUrl = [actInfoDic stringValueForKey:@"imageSmall" defaultValue:nil];
        obj.ugcAudUrl = [actInfoDic stringValueForKey:@"audUrl" defaultValue:nil];
        obj.ugcAudLen = [actInfoDic intValueForKey:@"audLen" defaultValue:0];
        obj.time = [NSString stringWithFormat:@"%lld", [actInfoDic longlongValueForKey:@"time" defaultValue:0]];
        NSString *actTitle = [actInfoDic stringValueForKey:@"actTitle" defaultValue:nil];
        if (actTitle.length > 0) {
            obj.trendTitle = actTitle;
        }
        obj.originContentObj = [SNTimelineOriginContentObject timelineOriginContentObjFromDic:actInfoDic
                                                                                    trendItem:obj];
    }
}

//动态赞解析
+ (void)topInfoFromDic:(NSDictionary *)infoDic trendItem:(SNTimelineTrendItem *)obj {
    NSDictionary *topDic = [infoDic dictionaryValueForKey:@"topInfo" defalutValue:nil];
    if (topDic) {
        obj.topNum = [topDic intValueForKey:@"allNum" defaultValue:0];
        obj.isTop  = [topDic intValueForKey:@"isTop" defaultValue:0];
        NSArray *topArray = [topDic arrayValueForKey:@"tops" defaultValue:nil];
        NSMutableArray *aParsedTopArray = nil;
        if (topArray && [topArray isKindOfClass:[NSArray class]]) {
            aParsedTopArray = [NSMutableArray array];
            for (NSDictionary *topInfoDic in topArray) {
                SNTimelineTrendTopObject *topInfo = [SNTimelineTrendTopObject timelineTopObjFromDic:topInfoDic];
                if (topInfo) {
                    [aParsedTopArray addObject:topInfo];
                }
            }
        }
        obj.topArray = aParsedTopArray;
    }
}

//动态评论
+ (void)commentInfoFromDic:(NSDictionary *)infoDic trendItem:(SNTimelineTrendItem *)obj {
    NSDictionary *commentDic = [infoDic dictionaryValueForKey:@"commentInfo" defalutValue:nil];
    if (commentDic) {
        obj.commentNum = [commentDic intValueForKey:@"allNum" defaultValue:0];
        obj.commentNextCursor = [commentDic stringValueForKey:@"nextCursor" defaultValue:nil];
        obj.commentPreCursor = [commentDic stringValueForKey:@"preCursor" defaultValue:nil];
        NSArray *commentsArray = [commentDic arrayValueForKey:@"comments" defaultValue:nil];
        NSMutableArray *aParsedArray = nil;
        if (commentsArray && [commentsArray isKindOfClass:[NSArray class]]) {
            aParsedArray = [NSMutableArray array];
            int index = 0;
            for (NSDictionary *cmtDicInfo in commentsArray) {
                SNTimelineCommentsObject *aObj = [SNTimelineCommentsObject timelineCommentObjFromDic:cmtDicInfo];
                if (aObj) {
                    [aParsedArray addObject:aObj];
                }
                index++;
            }
            if (aParsedArray.count > kTimelineMaxCommentDisplayNum) {
                obj.showAllComment = YES;
            }
        }
        obj.commentsArray = aParsedArray;
    }
}


//动态用户ugc高度
+ (CGFloat)heightForTimelineTrendContent:(SNTimelineTrendItem *)timelineItem
{
    if ([timelineItem isKindOfClass:[SNTimelineTrendItem class]])
    {
        // caculate height
        CGFloat contentWidth = TTApplicationFrame().size.width - kTLViewSideMargin - kTLShareInfoViewTextLeftMargin;
        CGFloat maxHeight = SNTIMELINE_SHAREINFO_LINE_MAX_WITHOUT_MORE * kTLShareInfoViewContentLineHeight;
        CGFloat maxHeightWithMore = SNTIMELINE_SHAREINFO_LINE_MAX_WITH_MORE * kTLShareInfoViewContentLineHeight;
        CGFloat height = [SNLabel heightForContent:timelineItem.content
                                           maxSize:CGSizeMake(contentWidth, CGFLOAT_MAX_CORE_TEXT)
                                              font:kTLShareInfoViewContentFontSize
                                        lineHeight:kTLShareInfoViewContentLineHeight
                                     textAlignment:NSTextAlignmentLeft
                                     lineBreakMode:NSLineBreakByCharWrapping];
        if(height > maxHeight) {
            timelineItem.needOpenUgc = YES;
            if(!timelineItem.isOpenUgc) {
                timelineItem.ugcContentHeight = maxHeightWithMore;
                height = maxHeightWithMore + SNTIMELINE_SHAREINFO_MORE_HEIGHT;
            }
            else {
                timelineItem.ugcContentHeight = height;
            }
        }
        else {
            timelineItem.ugcContentHeight = height;
        }
        
        // 图片
        if (timelineItem.ugcSmallImageUrl.length > 0) {
            height += kPicViewHeight + kTLShareInfoViewNameContentMargin;
        }
        // 音频
        else if (timelineItem.ugcAudUrl.length > 0) {
            height += SOUNDVIEW_HEIGHT + kTLShareInfoViewNameContentMargin;
        }
        return height;
    }
    return 0;
}

//动态评论高度
+ (CGFloat)heightForTimeLineTrendComments:(SNTimelineTrendItem *)timelineObj {
    CGFloat viewHeight = .0f;
    if (timelineObj.commentsArray.count > kTimelineMaxCommentDisplayNum) {
        timelineObj.showAllComment = YES;
    }
    if ([timelineObj isKindOfClass:[SNTimelineTrendItem class]]) {
        int index = 0;
        CGFloat commentOffsetY = .0f;
        while (index < timelineObj.commentsArray.count && index < kTimelineMaxCommentDisplayNum) {
            CGFloat commentHeight = .0f;
            CGFloat moreButtonHeight = .0f;
            CGFloat startOffsetY = kTLCommentsViewTopBottomMargin + commentOffsetY;
            if (index == 0) {
                startOffsetY += kTLShareInfoCommentsTopMrigin;
            }
            SNTimelineCommentsObject *cmtObj = [timelineObj.commentsArray objectAtIndex:index];
            viewHeight += CGRectGetHeight(cmtObj.timelabelFrame);
            //用户名点击区域
            CGSize userLabelSize = [cmtObj.nickName sizeWithFont:[UIFont systemFontOfSize:kTLCommentsViewUserNameFontSize]];
            cmtObj.userLabelFrame = CGRectMake(kTLCommentsViewLeftRightMargin,
                                               startOffsetY,
                                               userLabelSize.width,
                                               kTLCommentsViewUserNameFontSize);
            // 计算 height
            NSMutableAttributedString *attributedStr = [cmtObj setCommentAttributedStr];
            cmtObj.attContent = attributedStr;

            //计算高度
            CGFloat maxHeight = [attributedStr getHeightWithWidth:kTLCommentsViewTextWidth
                                                     maxLineCount:SNTIMELINE_SHAREINFO_COMMENT_MAX_WIDTHOUT_MORE];
            CGFloat maxHeightWithMore = [attributedStr getHeightWithWidth:kTLCommentsViewTextWidth
                                                             maxLineCount:SNTIMELINE_SHAREINFO_COMMENT_MAX_WIDTH_MORE];
            CGFloat height = [attributedStr getHeightWithWidth:kTLCommentsViewTextWidth maxHeight:CGFLOAT_MAX_CORE_TEXT];
            
            cmtObj.contentHeight = height;
            if(height > maxHeight) {
                cmtObj.needFolder = YES;
                if(cmtObj.isFolder) {
                    moreButtonHeight = SNTIMELINE_SHAREINFO_COMMENT_MORE_HEIGHT;
                    cmtObj.contentHeight = maxHeightWithMore;
                    height = maxHeightWithMore;
                }
            }
            //评论和用户名区域
            cmtObj.textLabelFrame = CGRectMake(kTLCommentsViewLeftRightMargin, startOffsetY,
                                               kTLCommentsViewTextWidth, height);
            
            commentOffsetY = CGRectGetMaxY(cmtObj.textLabelFrame) + kTLCommentsViewTopBottomMargin;
            commentHeight = commentOffsetY;
            //评论有显示更多加上显示更多按钮高度
            timelineObj.moreCmtBtnFrame = CGRectZero;
            if (moreButtonHeight > 0) {
                commentOffsetY += moreButtonHeight + kTLCommentsViewNameTextMargin;
                commentHeight += moreButtonHeight + kTLCommentsViewNameTextMargin;
                NSString *moreBtnStr = @"显示更多";
                CGSize size = [moreBtnStr sizeWithFont:[UIFont systemFontOfSize:kTLShareInfoViewNameFontSize]];
                cmtObj.moreCmtBtnFrame = CGRectMake(kTLCommentsViewLeftRightMargin,
                                                    CGRectGetMaxY(cmtObj.textLabelFrame) + kTLCommentsViewNameTextMargin,
                                                    size.width, SNTIMELINE_SHAREINFO_COMMENT_MORE_HEIGHT);
            }
            cmtObj.commentFrame = CGRectMake(0, commentOffsetY, kTLOriginalContentWidth, commentHeight + 2);
            cmtObj.commentHeight = commentHeight;
            index++;
        }
        viewHeight = commentOffsetY;
        // 是否需要显示“查看更多”
        if (timelineObj.showAllComment) {
            timelineObj.moreCmtBtnFrame = CGRectMake(0 ,
                                                     commentOffsetY + (kTLCommentsViewMoreCellHeight - kTLCommentsViewTextFontSize) / 2,
                                                     kTLOriginalContentWidth, kTLCommentsViewTextFontSize);
            viewHeight += kTLCommentsViewMoreCellHeight;
        }
    }
    return viewHeight;
}

//原文高度
+ (CGFloat)heightForTimelineOriginalContent:(SNTimelineTrendItem *)trendItem {
    CGFloat height = .0f;
    switch (trendItem.trendType) {
        case kSNTimelineItemTypeArticle:
            height = [SNTimelineTrendItem heightForArticleOriginal:trendItem.originContentObj];
            break;
        case kSNTimelineItemTypeLive:
            height = [SNTimelineTrendItem heightForLiveOriginal:trendItem.originContentObj];
            break;
        case kSNTimelineItemTypeSub:
            height = [SNTimelineTrendItem heightForSubOriginal:trendItem.originContentObj];
            break;
        case kSNTimelineItemTypePeople:
            height = [SNTimelineTrendItem heightForPeopleOriginal:trendItem.originContentObj];
            break;
        case kSNTimelineItemTypeUGC:
            height = 0;
            break;
    }
    return height;
}

+ (CGFloat)heightForArticleOriginal:(SNTimelineOriginContentObject *)originObj {
    CGFloat height = .0f;
    CGFloat width = kTLOriginalContentWidth - 2 * kTLOriginalContentTextSideMargin;
    
    height += kTLOriginalContentTitleTopMargin;
    UIFont *titleFont = [UIFont systemFontOfSize:kTLOriginalContentTitleFontSize];
    CGSize titleSize = [originObj.title sizeWithFont:titleFont
                                   constrainedToSize:CGSizeMake(width, CGFLOAT_MAX)
                                       lineBreakMode:UILineBreakModeCharacterWrap];
    height += titleSize.height;
    originObj.titleHeight = titleSize.height;
    
    height += kTLOriginalContentVerticalMargin;
    UIFont *fromStringFont = [UIFont systemFontOfSize:kTLOriginalContentFromFontSize];
    CGSize fromSize = [originObj.fromDisplayString sizeWithFont:fromStringFont
                                              constrainedToSize:CGSizeMake(width, CGFLOAT_MAX)
                                                  lineBreakMode:UILineBreakModeCharacterWrap];
    height += fromSize.height;
    originObj.fromHeight = fromSize.height;
    
    // 文字最多显示六行
    if (originObj.picsArray.count > 0) {
//        CGFloat maxHeight = 6 * kTLOriginalContentAbstractLineHeight;
        CGFloat maxHeight = [SNLabel heightForContent:originObj.abstract
                                             maxWidth:width
                                                 font:kTLOriginalContentAbstractFontSize
                                           lineHeight:kTLOriginalContentAbstractLineHeight maxLineCount:6];
        CGSize absSize = [SNLabel sizeForContent:originObj.abstract
                                         maxSize:CGSizeMake(width, CGFLOAT_MAX_CORE_TEXT)
                                            font:kTLOriginalContentAbstractFontSize
                                      lineHeight:kTLOriginalContentAbstractLineHeight];
        if (absSize.height > 0) {
            height += kTLOriginalContentVerticalMargin;
            height += MIN(absSize.height,maxHeight);
        }
        
        originObj.abstractHeight = MIN(absSize.height, maxHeight);
        
        height += kTLOriginalContentImageTopMargin;
        height += originObj.picDisplaySize.height;
        height += kTLOriginalContentImageBottomMargin;
//        height -= kTLOriginalContentAbstractLineSpacing;
    }
    // 文字最多显示八行
    else {
        CGFloat maxHeight = [SNLabel heightForContent:originObj.abstract
                                             maxWidth:width
                                                 font:kTLOriginalContentAbstractFontSize
                                           lineHeight:kTLOriginalContentAbstractLineHeight maxLineCount:8];
        CGSize absSize = [SNLabel sizeForContent:originObj.abstract maxSize:CGSizeMake(width, CGFLOAT_MAX_CORE_TEXT) font:kTLOriginalContentAbstractFontSize lineHeight:kTLOriginalContentAbstractLineHeight];
        
        if (absSize.height > 0) {
            height += kTLOriginalContentVerticalMargin;
            height += MIN(maxHeight,absSize.height);
        }
        height += kTLOriginalContentImageBottomMargin;
        originObj.abstractHeight = MIN(maxHeight,absSize.height);
    }
    return height;
}

//订阅类型高度
+ (CGFloat)heightForSubOriginal:(SNTimelineOriginContentObject *)originObj {
    return kTLViewSubViewHeight;
}

+ (CGFloat)heightForLiveOriginal:(SNTimelineOriginContentObject *)originObj {
    CGFloat height = kTLOriginalContentFromTopMargin;
    
    CGFloat width = kTLOriginalContentWidth - 2 * kTLOriginalContentTextSideMargin;
    UIFont *titleFont = [UIFont systemFontOfSize:kTLOriginalContentTitleFontSize];
    CGSize titleSize = [originObj.title sizeWithFont:titleFont
                                   constrainedToSize:CGSizeMake(width, CGFLOAT_MAX)
                                       lineBreakMode:UILineBreakModeCharacterWrap];
    originObj.titleHeight = titleSize.height;
    height += titleSize.height;
    height += kTLOriginalContentFromTopMargin;
    
    UIFont *fromStringFont = [UIFont systemFontOfSize:kTLOriginalContentFromFontSize];
    CGSize fromSize = [originObj.fromDisplayString sizeWithFont:fromStringFont
                                              constrainedToSize:CGSizeMake(width, CGFLOAT_MAX)
                                                  lineBreakMode:UILineBreakModeCharacterWrap];
    originObj.fromHeight = fromSize.height;
    height += fromSize.height;
    height += kTLOriginalContentFromTopMargin;
    
    return height;
}

//关注类型模版frame
+ (CGFloat)heightForPeopleOriginal:(SNTimelineOriginContentObject *)originObj {
    CGFloat height = 0;
    height += kTLOriginalContentFromTopMargin;
    int index = 0;
    
    for (SNTimelineTrendTopObject __unused *topObj in originObj.attUserArray) {
        if ((index % kTLOriginalPeopleViewLineNum) == 0) {
            height += kTLOriginalContentFromTopMargin + kTLOriginalPeopleViewHeadIconSize;
        }
        index++;
    }
    
    return height;
}

+ (void)SNTimelineTrendCmtsReset:(SNTimelineTrendItem *)item id:(NSString *)cmtId
{
    for (SNTimelineCommentsObject *cmtObj in item.commentsArray) {
        if ([cmtObj.commentId isEqualToString:cmtId]) {
            cmtObj.isFolder = NO;
            cmtObj.needFolder = NO;
            item.commentsHeight = 0.0f;
            item.height = .0f;
        }
    }
    [item sizeToFit];
}

+ (void)SNTimelineTrendSendCmtSuc:(NSArray *)trendItems info:(NSDictionary *)cmtInfo
{
    NSString *actId = [cmtInfo objectForKey:@"actId"];
    for (SNTimelineTrendItem *item in trendItems) {
        if (actId.length > 0 && [item.actId isEqualToString:actId]) {
            SNTimelineCommentsObject *cmt = [[SNTimelineCommentsObject new] autorelease];
            cmt.actId = actId;
            cmt.nickName = [cmtInfo objectForKey:@"author"];
            cmt.fNickName = [cmtInfo objectForKey:@"fnickName"];
            cmt.pid = [cmtInfo objectForKey:@"pid"];
            cmt.fPid = [cmtInfo objectForKey:@"fpid"];
            cmt.content = [cmtInfo objectForKey:@"content"];
            cmt.commentId = [cmtInfo objectForKey:@"dataId"];
            if (item.commentsArray) {
                [item.commentsArray insertObject:cmt atIndex:0];
            }
            else {
                item.commentsArray = [NSMutableArray array];
                [item.commentsArray addObject:cmt];
            }
            //添加假评论后对评论数加一
            ++item.commentNum;
            item.height = 0;
            item.commentsHeight = 0;
            [item sizeToFit];
        }
    }
}

+ (SNTimelineCommentsObject *)SNTrendDetailSendCmtSuc:(NSDictionary *)cmtInfo
{
    SNTimelineCommentsObject *cmt = [[SNTimelineCommentsObject new] autorelease];
    NSString *actId = [cmtInfo objectForKey:@"actId"];
    cmt.actId = actId;
    cmt.nickName = [cmtInfo objectForKey:@"author"];
    cmt.fNickName = [cmtInfo objectForKey:@"fnickName"];
    cmt.pid = [cmtInfo objectForKey:@"pid"];
    cmt.fPid = [cmtInfo objectForKey:@"spid"];
    cmt.content = [cmtInfo objectForKey:@"content"];
    cmt.commentId = [cmtInfo objectForKey:@"dataId"];
    cmt.headUrl = [cmtInfo objectForKey:@"headUrl"];

    return cmt;
}

- (void)sizeToFit
{
    if (self.height == 0) {
        if (self.originContentHeight == 0) {
            self.originContentHeight = [[self class]heightForTimelineOriginalContent:self];
        }
        if (self.ugcHeight == 0) {
            self.ugcHeight = [[self class]heightForTimelineTrendContent:self];
            if (self.ugcHeight > 0) {
                self.ugcHeight += kTLCellTopBottomMargin;
            } else {
                self.ugcHeight += 4;
            }
        }
        if (self.commentsHeight == 0) {
            self.commentsHeight = [[self class]heightForTimeLineTrendComments:self];
        }
        self.height = kTLCellTopBottomMargin + kTLCellUserNameHeight + kTLCellTopBottomMargin +
                        self.ugcHeight + self.originContentHeight +
                        kTLShareInfoCommentButtonHeight + kTLShareInfoViewOriginalCommentsMrigin +
                        self.commentsHeight + kTLCellTopBottomMargin;
    }
}

- (void)dealloc
{
    TT_RELEASE_SAFELY(_content);
    TT_RELEASE_SAFELY(_floorContent);
    TT_RELEASE_SAFELY(_time);
    TT_RELEASE_SAFELY(_trendTitle);
    TT_RELEASE_SAFELY(_actId);
    TT_RELEASE_SAFELY(_pid);
    TT_RELEASE_SAFELY(_userHeadUrl);
    TT_RELEASE_SAFELY(_userNickName);
    TT_RELEASE_SAFELY(_originContentObj);
    TT_RELEASE_SAFELY(_gender);
    TT_RELEASE_SAFELY(_originBgImage);
    TT_RELEASE_SAFELY(_originDefaultImage);
    TT_RELEASE_SAFELY(_subIconBgImage);
    TT_RELEASE_SAFELY(_commentsArray);
    TT_RELEASE_SAFELY(_ugcAudUrl);
    TT_RELEASE_SAFELY(_ugcBigImageUrl);
    TT_RELEASE_SAFELY(_ugcSmallImageUrl);
    
    [super dealloc];
}
@end

#pragma mark - SNTimelineOriginalObject
@implementation SNTimelineOriginContentObject
+ (SNTimelineOriginContentObject *)timelineOriginContentObjFromDic:(NSDictionary *)originInfoDic
{
    SNTimelineOriginContentObject *aObj = nil;
    if (originInfoDic && [originInfoDic isKindOfClass:[NSDictionary class]]) {
        aObj = [[SNTimelineOriginContentObject new] autorelease];
        aObj.referId = [originInfoDic stringValueForKey:@"referId" defaultValue:nil];
        aObj.contentId = [NSString stringWithFormat:@"%lld", [originInfoDic longlongValueForKey:@"id" defaultValue:0]];
        aObj.sourceType = [originInfoDic intValueForKey:@"sourceType" defaultValue:0];
        aObj.title = [originInfoDic stringValueForKey:@"title" defaultValue:nil];
        aObj.abstract = [originInfoDic stringValueForKey:@"description" defaultValue:nil];
        
        // 微热议 没有title的情况 title字段用摘要
        if (aObj.sourceType == 13 && aObj.title.length == 0) {
            if (aObj.abstract.length > kAbstractTitleLine) {
                NSString *title = [NSString stringWithFormat:@"%@...", [aObj.abstract substringToIndex:kAbstractTitleLine]];
                aObj.title = title;
            } else {
                aObj.title = aObj.abstract;
            }
        }
        
        // pics 字段 服务器可能会给多个  ， 分割
        NSString *picsString = [originInfoDic stringValueForKey:@"pics" defaultValue:nil];
        if (picsString.length > 0) {
            NSArray *imagesUrl = [picsString componentsSeparatedByString:@","];
            if (imagesUrl.count > 0) {
                aObj.picsArray = [NSMutableArray arrayWithArray:imagesUrl];
                aObj.picUrl = imagesUrl[0];
            }
        }
        
        aObj.picSize = [originInfoDic stringValueForKey:@"picSize" defaultValue:nil];
        if (aObj.picSize.length == 0 && aObj.picsArray.count > 0) aObj.picSize = @"490x340";
        
        aObj.link = [originInfoDic stringValueForKey:@"link" defaultValue:nil];
        aObj.fromLink = [originInfoDic stringValueForKey:@"fromLink" defaultValue:nil];
        aObj.fromString = [originInfoDic stringValueForKey:@"from" defaultValue:nil];
        aObj.hasTv = ([originInfoDic intValueForKey:@"hasTV" defaultValue:0] == 1);
        aObj.subId = [originInfoDic stringValueForKey:@"subId" defaultValue:nil];
        aObj.subCount = [originInfoDic stringValueForKey:@"subCount" defaultValue:nil];
    }
    
    return aObj;
}

+ (SNTimelineOriginContentObject *)timelineOriginContentObjFromDic:(NSDictionary *)originInfoDic
                                                         trendItem:(SNTimelineTrendItem *)obj {
    switch (obj.trendType) {
        case kSNTimelineItemTypeArticle:
        case kSNTimelineItemTypeLive:
        case kSNTimelineItemTypeSub:
            return [SNTimelineOriginContentObject timelineArticleOriginalObjFromDic:originInfoDic];
        case kSNTimelineItemTypePeople:
            return [SNTimelineOriginContentObject timelinePeopleOriginalObjFromDic:originInfoDic];
        case kSNTimelineItemTypeUGC:
            return [SNTimelineOriginContentObject timelineUGCOriginalObjFromDic:originInfoDic trendItem:obj];
    }
    return nil;
}

+ (SNTimelineOriginContentObject *)timelineArticleOriginalObjFromDic:(NSDictionary *)originInfo
{
    SNTimelineOriginContentObject *aObj = nil;
    NSDictionary *originInfoDic = nil;
    if ([originInfo dictionaryValueForKey:@"originContent" defalutValue:nil]) {
        originInfoDic = [originInfo dictionaryValueForKey:@"originContent" defalutValue:nil];
    }
    else if ([originInfo stringValueForKey:@"originContent" defaultValue:nil]) {
        NSString *originStr = [originInfo stringValueForKey:@"originContent" defaultValue:nil];
        NSData *infoJsonData = [originStr dataUsingEncoding:NSUTF8StringEncoding];
        originInfoDic = [infoJsonData yajl_JSON];
    }
    if (originInfoDic && [originInfoDic isKindOfClass:[NSDictionary class]]) {
        aObj = [[SNTimelineOriginContentObject new] autorelease];
        aObj.referId = [originInfoDic stringValueForKey:@"referId" defaultValue:nil];
        aObj.contentId = [NSString stringWithFormat:@"%lld", [originInfoDic longlongValueForKey:@"id" defaultValue:0]];
        aObj.sourceType = [originInfoDic intValueForKey:@"sourceType" defaultValue:0];
        aObj.title = [originInfoDic stringValueForKey:@"title" defaultValue:nil];
        aObj.abstract = [originInfoDic stringValueForKey:@"description" defaultValue:nil];
        
        // 微热议 没有title的情况 title字段用摘要
        if (aObj.sourceType == 13 && aObj.title.length == 0) {
            if (aObj.abstract.length > kAbstractTitleLine) {
                NSString *title = [NSString stringWithFormat:@"%@...", [aObj.abstract substringToIndex:kAbstractTitleLine]];
                aObj.title = title;
            } else {
                aObj.title = aObj.abstract;
            }
        }
        
        // pics 字段 服务器可能会给多个  ， 分割
        NSString *picsString = [originInfoDic stringValueForKey:@"pics" defaultValue:nil];
        if (picsString.length > 0) {
            NSArray *imagesUrl = [picsString componentsSeparatedByString:@","];
            if (imagesUrl.count > 0) {
                aObj.picsArray = [NSMutableArray arrayWithArray:imagesUrl];
                aObj.picUrl = imagesUrl[0];
            }
        }
        
        aObj.picSize = [originInfoDic stringValueForKey:@"picSize" defaultValue:nil];
        if (aObj.picSize.length == 0 && aObj.picsArray.count > 0) aObj.picSize = @"490x340";
        
        aObj.link = [originInfoDic stringValueForKey:@"link" defaultValue:nil];
        aObj.fromLink = [originInfoDic stringValueForKey:@"fromLink" defaultValue:nil];
        aObj.fromString = [originInfoDic stringValueForKey:@"from" defaultValue:nil];
        aObj.hasTv = ([originInfoDic intValueForKey:@"hasTV" defaultValue:0] == 1);
        aObj.subId = [originInfoDic stringValueForKey:@"subId" defaultValue:nil];
        aObj.subCount = [originInfoDic stringValueForKey:@"subCount" defaultValue:nil];
    }
    
    return aObj;
}

+ (SNTimelineOriginContentObject *)timelinePeopleOriginalObjFromDic:(NSDictionary *)originInfo
{
    SNTimelineOriginContentObject *aObj = nil;
    NSArray *originInfoDic = [originInfo arrayValueForKey:@"originContent" defaultValue:nil];
    if (originInfoDic && [originInfoDic isKindOfClass:[NSArray class]]) {
        aObj = [[SNTimelineOriginContentObject new] autorelease];
        NSMutableArray *attArray = [NSMutableArray array];
        for (NSDictionary *peopleInforDic in originInfoDic) {
            SNTimelineTrendTopObject *aTopObj = [[SNTimelineTrendTopObject new] autorelease];
            aTopObj.headUrl = [peopleInforDic stringValueForKey:@"headUrl" defaultValue:nil];
            aTopObj.nickName = [peopleInforDic stringValueForKey:@"nickName" defaultValue:nil];
            aTopObj.pid = [NSString stringWithFormat:@"%lld", [peopleInforDic longlongValueForKey:@"pid" defaultValue:0]];
            aTopObj.gender = [peopleInforDic intValueForKey:@"gender" defaultValue:0];
            if (aObj) {
                [attArray addObject:aTopObj];
            }
        }
        aObj.attUserArray = attArray;
    }
    
    return aObj;
}

+ (SNTimelineOriginContentObject *)timelineUGCOriginalObjFromDic:(NSDictionary *)originInfo
                                                       trendItem:(SNTimelineTrendItem *)obj
{
    SNTimelineOriginContentObject *aObj = nil;
    NSDictionary *originInfoDic = [originInfo dictionaryValueForKey:@"originContent" defalutValue:nil];
    if (originInfoDic && [originInfoDic isKindOfClass:[NSDictionary class]]) {
        aObj = [[SNTimelineOriginContentObject new] autorelease];
        aObj.referId = [originInfoDic stringValueForKey:@"referId" defaultValue:nil];
        aObj.sourceType = [originInfoDic intValueForKey:@"sourceType" defaultValue:0];
        aObj.abstract = [originInfoDic stringValueForKey:@"shareContent" defaultValue:nil];
        aObj.link   = [originInfoDic stringValueForKey:@"link" defaultValue:nil];              //语言地址
        aObj.fromLink = [originInfoDic stringValueForKey:@"shareLink" defaultValue:nil];       //用于分享到外部的链接地址

        obj.ugcAudUrl = [originInfoDic stringValueForKey:@"link" defaultValue:nil];
        obj.ugcAudLen = [originInfoDic intValueForKey:@"audLen" defaultValue:0];
    }
    
    return aObj;
}

+ (SNTimelineOriginContentObject *)timelineOriginContentObjFromXMLObj:(TBXMLElement *)xmlElm {
    SNTimelineOriginContentObject *obj = nil;
    if (xmlElm) {
        obj = [[SNTimelineOriginContentObject new] autorelease];
        obj.contentId = [TBXML textForElement:[TBXML childElementNamed:@"id" parentElement:xmlElm]];
        obj.sourceType = [[TBXML textForElement:[TBXML childElementNamed:@"sourceType" parentElement:xmlElm]] intValue];
        obj.hasTv = [[TBXML textForElement:[TBXML childElementNamed:@"hasTV" parentElement:xmlElm]] isEqualToString:@"1"];
        obj.title = [[TBXML textForElement:[TBXML childElementNamed:@"title" parentElement:xmlElm]] stringByRemovingHTMLTags];
        obj.abstract = [[TBXML textForElement:[TBXML childElementNamed:@"description" parentElement:xmlElm]] stringByRemovingHTMLTags];
        obj.link = [[TBXML textForElement:[TBXML childElementNamed:@"link" parentElement:xmlElm]] stringByRemovingHTMLTags];
        obj.fromLink = [[TBXML textForElement:[TBXML childElementNamed:@"fromLink" parentElement:xmlElm]] stringByRemovingHTMLTags];
        obj.fromString = [[TBXML textForElement:[TBXML childElementNamed:@"from" parentElement:xmlElm]] stringByRemovingHTMLTags];
        obj.subId = [TBXML textForElement:[TBXML childElementNamed:@"subId" parentElement:xmlElm]];
        obj.subCount = [TBXML textForElement:[TBXML childElementNamed:@"subCount" parentElement:xmlElm]];
        
        NSString *picUrl = [TBXML textForElement:[TBXML childElementNamed:@"pics" parentElement:xmlElm]];
        if (picUrl) {
            NSArray *imageUrls = [picUrl componentsSeparatedByString:@","];
            if (imageUrls.count > 0) {
                obj.picsArray = [NSMutableArray arrayWithArray:imageUrls];
            }
        }
        
        obj.picSize = [TBXML textForElement:[TBXML childElementNamed:@"picSize" parentElement:xmlElm]];
        if (obj.picSize.length == 0 && obj.picsArray.count > 0) obj.picSize = @"490x340";
        
        // 微热议 没有title的情况 title字段用摘要
        if (obj.sourceType == 13 && obj.title.length == 0)
            obj.title = obj.abstract;
    }
    
    return obj;
}

- (void)setSourceType:(int)sourceType {
    _sourceType = sourceType;
    switch (_sourceType) {
        case 3:
        case 6:
        case 7:
            self.typeString = @"新闻";
            break;
        case 4:
            self.typeString = @"组图";
            break;
        case 12:
            self.typeString = @"投票";
            break;
        case 9:
            self.typeString = @"直播";
            break;
        case 8:
        case 37:
            self.typeString = @"链接";
            break;
        case 30:
            self.typeString = @"订阅";
            break;
        case 11:
        case 32:
            self.typeString = @"刊物";
            break;
        case 10:
            self.typeString = @"专题";
            break;
        case 13:
            self.typeString = @"微热议";
            break;
        case 33:
            self.typeString = @"新闻频道列表";
            break;
        case 34:
            self.typeString = @"微热议频道列表";
            break;
        case 35:
            self.typeString = @"组图频道列表";
            break;
        case 36:
            self.typeString = @"直播频道列表";
            break;

        default:
            self.typeString = nil;
            break;
    }
}

- (NSString *)picUrl
{
    if (_picUrl) {
        return _picUrl;
    } else if (_picsArray.count > 0) {
        return _picsArray[0];
    }
    return nil;
}

- (SNTimelineOriginContentType)type {
    switch (_sourceType) {
        case 11: // paper
        case 30: // 刊物
        case 31: // ?
        case 32: // dataFollow
        case 33: // news channel
        case 34: // weibo channel
        case 35: // group PicChannel
        case 36: // live channel
        case 38: // 功能插件
        case 39: // 政企
            if (self.subId.length > 0)
                _type = SNTimelineOriginContentTypeSub;
            else if (self.picsArray.count > 0 || self.picUrl.length > 0)
                _type = SNTimelineOriginContentTypeTextAndPics;
            else
                _type = SNTimelineOriginContentTypeText;
            break;

        default:
            if (self.picsArray.count > 0 || self.picUrl.length > 0)
                _type = SNTimelineOriginContentTypeTextAndPics;
            else
                _type = SNTimelineOriginContentTypeText;
            break;
    }
    return _type;
}

- (NSString *)fromDisplayString {
    NSString *fromTextToDraw = nil;
    if (self.fromString.length > 0) {
        fromTextToDraw = [self.fromString stringByAppendingFormat:@"  %@", self.typeString.length > 0 ? self.typeString : @""];
    }
    else if (self.typeString.length > 0){
        fromTextToDraw = self.typeString;
    } else {
        fromTextToDraw = @"搜狐新闻";
    }
    return fromTextToDraw;
}

- (NSDictionary *)toDictionary {
    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
    
    [dic setObject:[NSString stringWithFormat:@"%d", self.sourceType] forKey:@"sourceType"];
    
    [dic setObject:self.hasTv ? @"1" : @"0" forKey:@"hasTV"];
    
    if (self.title)
        [dic setObject:self.title forKey:@"title"];
    else
        [dic setObject:@"" forKey:@"title"];
    
    if (self.abstract)
        [dic setObject:self.abstract forKey:@"description"];
    else
        [dic setObject:@"" forKey:@"description"];
    
    if (self.link)
        [dic setObject:self.link forKey:@"link"];
    
    if (self.fromLink)
        [dic setObject:self.fromLink forKey:@"fromLink"];
    
    if (self.fromString)
        [dic setObject:self.fromString forKey:@"from"];
    
    if (self.picsArray.count > 0)
        [dic setObject:self.picsArray[0] forKey:@"pics"];
    else
        [dic setObject:@"" forKey:@"pics"];
    
    if (self.picSize)
        [dic setObject:self.picSize forKey:@"picSize"];
    else
        [dic setObject:@"" forKey:@"picSize"];
    
    if (self.subId && [self.subId longLongValue] != 0)
        [dic setObject:self.subId forKey:@"subId"];
    
    if (self.subCount && [self.subCount longLongValue] != 0)
        [dic setObject:self.subCount forKey:@"subCount"];
    
    return dic;
}

- (void)setPicSize:(NSString *)picSize {
    if (_picSize != picSize) {
        TT_RELEASE_SAFELY(_picSize);
        _picSize = [picSize copy];
        
        _picFullSize = CGSizeZero;
        _picDisplaySize = CGSizeZero;
        
        if (_picSize.length > 0) {
            NSArray *sizeArray = [_picSize componentsSeparatedByString:@"*"];
            if (sizeArray.count < 2)
                sizeArray = [_picSize componentsSeparatedByString:@"x"];
            if (sizeArray.count < 2)
                sizeArray = [_picSize componentsSeparatedByString:@"X"];
            
            if (sizeArray.count >= 2) {
                _picFullSize = CGSizeMake([sizeArray[0] floatValue], [sizeArray[1] floatValue]);
                CGFloat dHeight = MIN(kTLOriginalContentImageWidth * _picFullSize.height /
                                      _picFullSize.width, kTLOriginalContentIamgeMaxHeight);
                _picDisplaySize = CGSizeMake(kTLOriginalContentImageWidth, dHeight);
            }
        }
    }
}

- (void)dealloc {
    TT_RELEASE_SAFELY(_referId);
    TT_RELEASE_SAFELY(_typeString);
    TT_RELEASE_SAFELY(_contentId);
    TT_RELEASE_SAFELY(_title);
    TT_RELEASE_SAFELY(_abstract);
    TT_RELEASE_SAFELY(_link);
    TT_RELEASE_SAFELY(_fromLink);
    TT_RELEASE_SAFELY(_fromString);
    TT_RELEASE_SAFELY(_picsArray);
    TT_RELEASE_SAFELY(_picUrl);
    TT_RELEASE_SAFELY(_picSize);
    TT_RELEASE_SAFELY(_subId);
    TT_RELEASE_SAFELY(_subCount);
    TT_RELEASE_SAFELY(_subName);
    TT_RELEASE_SAFELY(_isSubed);
    [super dealloc];
}


@end

#pragma mark - SNTimelineCommentsObject
@implementation SNTimelineCommentsObject
+ (SNTimelineCommentsObject *)timelineCommentObjFromDic:(NSDictionary *)commentInfoDic {
    SNTimelineCommentsObject *aObj = nil;
    if (commentInfoDic && [commentInfoDic isKindOfClass:[NSDictionary class]]) {
        aObj = [[SNTimelineCommentsObject new] autorelease];
        NSString *timeString = [NSString stringWithFormat:@"%lf", [[NSDate date] timeIntervalSince1970]*1000];
        aObj.time = [commentInfoDic stringValueForKey:@"time" defaultValue:timeString];
        aObj.time = [NSDate relativelyDate:aObj.time];
        aObj.content = [commentInfoDic stringValueForKey:@"content" defaultValue:nil];
        aObj.actId = [commentInfoDic stringValueForKey:@"actId" defaultValue:nil];
        aObj.commentId = [commentInfoDic stringValueForKey:@"id" defaultValue:nil];
        aObj.commentType = [commentInfoDic intValueForKey:@"commentType" defaultValue:0];
        NSDictionary *userDic = [commentInfoDic dictionaryValueForKey:@"user" defalutValue:nil];
        if (userDic) {
            aObj.headUrl = [userDic stringValueForKey:@"headUrl" defaultValue:nil];
            aObj.nickName = [userDic stringValueForKey:@"nickName" defaultValue:@"搜狐新闻客户端网友"];
            aObj.pid = [userDic stringValueForKey:@"pid" defaultValue:nil];
            aObj.gender = [userDic intValueForKey:@"gender" defaultValue:0];
//            aObj.fpid = [userDic stringValueForKey:@"fpid" defaultValue:nil];
        }
        NSDictionary *fUserDic = [commentInfoDic dictionaryValueForKey:@"fuser" defalutValue:nil];
        if (fUserDic) {
            aObj.fHeadUrl = [fUserDic stringValueForKey:@"headUrl" defaultValue:nil];
            aObj.fNickName = [fUserDic stringValueForKey:@"nickName" defaultValue:nil];
            aObj.fPid = [fUserDic stringValueForKey:@"pid" defaultValue:nil];
            aObj.fGender = [fUserDic intValueForKey:@"gender" defaultValue:0];
        }
    }
    //默认折叠
    aObj.isFolder = YES;
    return aObj;
}

//计算range
- (NSRange)getTouchRangeWithPoint:(CGPoint)touchPoint frame:(CGRect)rect topGap:(float)gap
{
    CFIndex stringIndex = -1;
    NSRange	range = NSMakeRange(0, 0);
    stringIndex = [self getStringIndexInFrameWith:touchPoint frame:(CGRect)rect topGap:gap] - 1;
    
    if (stringIndex >= 0) {
        [self.attContent attributesAtIndex:stringIndex effectiveRange:&range];
    }
    
    return range;
}

//计算attribute中的index
- (CFIndex)getStringIndexInFrameWith:(CGPoint)touchPoint frame:(CGRect)rect topGap:(float)gap
{
    CFIndex lineIndex = -1;
    CFIndex stringIndex = -1;
    
    //转换为相对frame pos
    CGMutablePathRef path = CGPathCreateMutable();
    CTFramesetterRef framesetter = CTFramesetterCreateWithAttributedString((CFAttributedStringRef)self.attContent);
    CGPathAddRect(path, &CGAffineTransformIdentity, rect);
    CTFrameRef frameRef = CTFramesetterCreateFrame(framesetter, CFRangeMake(0, self.attContent.length), path, nil);
    
    CGPathRef pathRef = CTFrameGetPath(frameRef);
    CGRect frameRect = CGPathGetBoundingBox(pathRef);
    CGPoint locatePoint;
    locatePoint.x = touchPoint.x-frameRect.origin.x;
    locatePoint.y = touchPoint.y - gap;
    
    //
    NSArray *linesArray = (NSArray *) CTFrameGetLines(frameRef);
    CGPoint origins[[linesArray count]];
    CTFrameGetLineOrigins(frameRef, CFRangeMake(0, 0), origins);
    
    float last_y = 0.0;
    for (int i = 0; i < [linesArray count]; i++)
    {
        //计算点击位置起始值
        float line_y = frameRect.size.height - origins[i].y + 4;
        
        if (locatePoint.y > last_y && locatePoint.y <= line_y)
        {
            lineIndex = i;
            break;
        }
        last_y = line_y;
    }
    
    //获取stringIndex
    if (lineIndex >= 0)
    {
        CTLineRef touchLine	= (CTLineRef) [linesArray objectAtIndex:lineIndex];
        
        CFRange	lineRange = CTLineGetStringRange(touchLine);
        stringIndex	= CTLineGetStringIndexForPosition(touchLine, locatePoint);
        if( stringIndex > (lineRange.location + lineRange.length - 1))
        {
            stringIndex = -1;
        }
        else{
            stringIndex+=0;
        }
    }
    TT_RELEASE_CF_SAFELY(frameRef);
    TT_RELEASE_CF_SAFELY(framesetter);
    CGPathRelease(path);
    
    return stringIndex;
}

- (NSMutableAttributedString *)setCommentAttributedStr
{
    NSMutableAttributedString *attributedStr = nil;
    
    NSString *userStr = [NSString stringWithFormat:@"%@ : ", self.nickName];
    if (self.fNickName.length > 0) {
        userStr = [NSString stringWithFormat:@"%@回复%@ : ", self.nickName, self.fNickName];
    }
    NSString *attContent = [NSString stringWithFormat:@"%@%@", userStr, self.content];
    if (attContent.length <= 0) {
        attContent = @"评论";
    }
    
    attributedStr = [[[NSMutableAttributedString alloc] initWithString:attContent] autorelease];
    [attributedStr setNewsTitelParagraphStyleWithFont:[UIFont systemFontOfSize:kTLCommentsViewTextFontSize]
                                        lineBreakMode:NSLineBreakByCharWrapping
                                            lineSpace:kTLCommentsViewTextLineSpacing];
    //设置字体颜色，区分用户名和评论文字
    UIColor *textColor = SNUICOLOR(kFloorViewCommentContentColor);
    UIColor *userColor = SNUICOLOR(kAuthorNameColor);
    //计算颜色范围
    NSRange userRange = NSMakeRange(0, userStr.length);
    self.userNameRange = NSMakeRange(0, 0);
    self.fUserNameRange = NSMakeRange(0, 0);
    //没有被回复对象时，回复名称range+3
    if (self.nickName.length > 0) {
        self.userNameRange = NSMakeRange(0, self.nickName.length + 3);
    }
    NSRange textRagne = NSMakeRange(userStr.length, attContent.length - userStr.length);
    NSRange replayedUserRange = NSMakeRange(0, 0);
    if (self.fNickName.length > 0) {
        replayedUserRange = NSMakeRange(self.nickName.length, 2);
        self.fUserNameRange = NSMakeRange(replayedUserRange.location + 2, self.fNickName.length + 3);
        self.userNameRange = NSMakeRange(0, self.nickName.length);
    }
    
    [attributedStr setTextColor:userColor range:userRange];
    if (textRagne.length + textRagne.location <= attContent.length) {
        [attributedStr setTextColor:textColor range:textRagne];
    }
    if (replayedUserRange.length > 0 && replayedUserRange.length <  attContent.length) {
        [attributedStr setTextColor:textColor range:replayedUserRange];
    }
    
    return attributedStr;
}

- (void)dealloc {
    TT_RELEASE_SAFELY(_headUrl);
    TT_RELEASE_SAFELY(_time);
    TT_RELEASE_SAFELY(_actId);
    TT_RELEASE_SAFELY(_commentId);
    TT_RELEASE_SAFELY(_nickName);
    TT_RELEASE_SAFELY(_content);
    TT_RELEASE_SAFELY(_attContent);
    TT_RELEASE_SAFELY(_fNickName);
    TT_RELEASE_SAFELY(_fPid);
    TT_RELEASE_SAFELY(_fHeadUrl);

    [super dealloc];
}

@end

@implementation SNTimelineTrendTopObject
+ (SNTimelineTrendTopObject *)timelineTopObjFromDic:(NSDictionary *)topDic {
    SNTimelineTrendTopObject *aObj = nil;
    if (topDic && [topDic isKindOfClass:[NSDictionary class]]) {
        aObj = [[SNTimelineTrendTopObject new] autorelease];
        NSString *timeString = [NSString stringWithFormat:@"%lf", [[NSDate date] timeIntervalSince1970]*1000];
        aObj.time = [topDic stringValueForKey:@"time" defaultValue:timeString];
        aObj.actId = [topDic stringValueForKey:@"actId" defaultValue:nil];
        NSDictionary *userDic = [topDic dictionaryValueForKey:@"user" defalutValue:nil];
        if (userDic) {
            aObj.headUrl = [topDic stringValueForKey:@"headUrl" defaultValue:nil];
            aObj.nickName = [topDic stringValueForKey:@"nickName" defaultValue:nil];
            aObj.pid = [NSString stringWithFormat:@"%lld", [topDic longlongValueForKey:@"pid" defaultValue:0]];
            aObj.gender = [topDic intValueForKey:@"gender" defaultValue:0];
        }
    }
    return aObj;
}

- (void)dealloc {
    TT_RELEASE_SAFELY(_time);
    TT_RELEASE_SAFELY(_actId);
    TT_RELEASE_SAFELY(_headUrl);
    TT_RELEASE_SAFELY(_nickName);
    TT_RELEASE_SAFELY(_pid);
    
    [super dealloc];
}

@end