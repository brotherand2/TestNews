//
//  SNTimelineItem.m
//  sohunews
//
//  Created by jojo on 13-6-24.
//  Copyright (c) 2013年 Sohu.com. All rights reserved.
//

#import "SNTimelineObjects.h"
#import "SNTLComViewOnlyTextBuilder.h"
#import "SNTLComViewTextAndPicsBuilder.h"
#import "SNTLComViewSubscribeBuilder.h"
#import "NSDictionaryExtend.h"
#import "SNDBManager.h"
#import "SNTimelineCell.h"
#import "NSAttributedString+Attributes.h"
#import "SNLabel.h"

#define kAbstractTitleLine 10

#pragma mark - SNTimelineCommentsObject

//@implementation SNTimelineCommentsObject
//@synthesize commentId = _commentId;
//@synthesize nickName = _nickName;
//@synthesize content = _content;
//@synthesize pid = _pid;
//@synthesize fpid = _fpid;
//@synthesize fnickName = _fnickName;
//@synthesize commentType = _commentType;
//@synthesize attriString = _attriString;
//@synthesize textHeight;
//@synthesize authorRangeString = _authorRangeString;
//@synthesize replyRangeString = _replyRangeString;
//@synthesize isFolder;
//@synthesize needFolder;
//@synthesize stringToCaculate = _stringToCaculate;

//+ (SNTimelineCommentsObject *)timelineCommentObjFromDic:(NSDictionary *)commentInfoDic {
//    SNTimelineCommentsObject *aObj = nil;
//    if (commentInfoDic && [commentInfoDic isKindOfClass:[NSDictionary class]]) {
//        aObj = [[SNTimelineCommentsObject new] autorelease];
//        NSString *timeString = [NSString stringWithFormat:@"%lf", [[NSDate date] timeIntervalSince1970]*1000];
//        aObj.time = [commentInfoDic stringValueForKey:@"time" defaultValue:timeString];
//        aObj.content = [commentInfoDic stringValueForKey:@"content" defaultValue:nil];
//        aObj.commentId = [NSString stringWithFormat:@"%lld", [commentInfoDic longlongValueForKey:@"id" defaultValue:0]];
//        aObj.commentType = [commentInfoDic intValueForKey:@"commentType" defaultValue:0];
//        NSDictionary *userDic = [commentInfoDic dictionaryValueForKey:@"user" defalutValue:nil];
//        if (userDic) {
//            aObj.headUrl = [commentInfoDic stringValueForKey:@"headUrl" defaultValue:nil];
//            aObj.nickName = [commentInfoDic stringValueForKey:@"nickName" defaultValue:nil];
//            aObj.pid = [NSString stringWithFormat:@"%lld", [commentInfoDic longlongValueForKey:@"pid" defaultValue:0]];
//            aObj.gender = [commentInfoDic intValueForKey:@"gender" defaultValue:0];
//            aObj.fpid = [commentInfoDic stringValueForKey:@"fpid" defaultValue:nil];
//            aObj.fnickName = [commentInfoDic stringValueForKey:@"fnickName" defaultValue:nil];
//        }
//    }
//    //默认折叠
//    aObj.isFolder = YES;
//    return aObj;
//}

//- (void)dealloc {
//    TT_RELEASE_SAFELY(_commentId);
//    TT_RELEASE_SAFELY(_nickName);
//    TT_RELEASE_SAFELY(_content);
//    TT_RELEASE_SAFELY(_pid);
//    TT_RELEASE_SAFELY(_fpid);
//    TT_RELEASE_SAFELY(_fnickName);
//    TT_RELEASE_SAFELY(_attriString);
//    TT_RELEASE_SAFELY(_authorRangeString);
//    TT_RELEASE_SAFELY(_replyRangeString);
//    TT_RELEASE_SAFELY(_stringToCaculate);
//    TT_RELEASE_SAFELY(_headUrl);
//    TT_RELEASE_SAFELY(_time);
//    
//    [super dealloc];
//}

//@end

#pragma mark - SNTimelineOriginContentObject

//@implementation SNTimelineOriginContentObject
//@synthesize type = _type;
//@synthesize sourceType = _sourceType;
//@synthesize typeString = _typeString;
//@synthesize hasTv = _hasTv;
//@synthesize contentId = _contentId;
//@synthesize title = _title;
//@synthesize abstract = _abstract;
//@synthesize link = _link;
//@synthesize fromLink = _fromLink;
//@synthesize fromString = _fromString;
//@synthesize picsArray = _picsArray;
//@synthesize picUrl = _picUrl;
//@synthesize subId = _subId;
//@synthesize subCount = _subCount;
//@synthesize subName = _subName;
//@synthesize isSubed = _isSubed;
//@synthesize picSize = _picSize;
//@synthesize picFullSize = _picFullSize;
//@synthesize picDisplaySize = _picDisplaySize;
//@synthesize titleHeight = _titleHeight;
//@synthesize fromHeight = _fromHeight;
//@synthesize abstractHeight = _abstractHeight;
//@dynamic fromDisplayString;

//+ (SNTimelineOriginContentObject *)timelineOriginContentObjFromDic:(NSDictionary *)originInfoDic {
//    SNTimelineOriginContentObject *aObj = nil;
//    if (originInfoDic && [originInfoDic isKindOfClass:[NSDictionary class]]) {
//        aObj = [[SNTimelineOriginContentObject new] autorelease];
//        aObj.referId = [originInfoDic stringValueForKey:@"referId" defaultValue:nil];
//        aObj.contentId = [NSString stringWithFormat:@"%lld", [originInfoDic longlongValueForKey:@"id" defaultValue:0]];
//        aObj.sourceType = [originInfoDic intValueForKey:@"sourceType" defaultValue:0];
//        aObj.title = [originInfoDic stringValueForKey:@"title" defaultValue:nil];
//        aObj.abstract = [originInfoDic stringValueForKey:@"description" defaultValue:nil];
//        
//        // 微热议 没有title的情况 title字段用摘要
//        if (aObj.sourceType == 13 && aObj.title.length == 0) {
//            if (aObj.abstract.length > kAbstractTitleLine) {
//                NSString *title = [NSString stringWithFormat:@"%@...", [aObj.abstract substringToIndex:kAbstractTitleLine]];
//                aObj.title = title;
//            } else {
//                aObj.title = aObj.abstract;
//            }
//        }
//        
//        // pics 字段 服务器可能会给多个  ， 分割
//        NSString *picsString = [originInfoDic stringValueForKey:@"pics" defaultValue:nil];
//        if (picsString.length > 0) {
//            NSArray *imagesUrl = [picsString componentsSeparatedByString:@","];
//            if (imagesUrl.count > 0) {
//                aObj.picsArray = [NSMutableArray arrayWithArray:imagesUrl];
//            }
//        }
//        
//        aObj.picSize = [originInfoDic stringValueForKey:@"picSize" defaultValue:nil];
//        if (aObj.picSize.length == 0 && aObj.picsArray.count > 0) aObj.picSize = @"490x340";
//        
//        aObj.link = [originInfoDic stringValueForKey:@"link" defaultValue:nil];
//        aObj.fromLink = [originInfoDic stringValueForKey:@"fromLink" defaultValue:nil];
//        aObj.fromString = [originInfoDic stringValueForKey:@"from" defaultValue:nil];
//        aObj.hasTv = ([originInfoDic intValueForKey:@"hasTV" defaultValue:0] == 1);
//        aObj.subId = [originInfoDic stringValueForKey:@"subId" defaultValue:nil];
//        aObj.subCount = [originInfoDic stringValueForKey:@"subCount" defaultValue:nil];
//    }
//    return aObj;
//}
//
//+ (SNTimelineOriginContentObject *)timelineOriginContentObjFromXMLObj:(TBXMLElement *)xmlElm {
//    SNTimelineOriginContentObject *obj = nil;
//    if (xmlElm) {
//        obj = [[SNTimelineOriginContentObject new] autorelease];
//        obj.contentId = [TBXML textForElement:[TBXML childElementNamed:@"id" parentElement:xmlElm]];
//        obj.sourceType = [[TBXML textForElement:[TBXML childElementNamed:@"sourceType" parentElement:xmlElm]] intValue];
//        obj.hasTv = [[TBXML textForElement:[TBXML childElementNamed:@"hasTV" parentElement:xmlElm]] isEqualToString:@"1"];
//        obj.title = [[TBXML textForElement:[TBXML childElementNamed:@"title" parentElement:xmlElm]] stringByRemovingHTMLTags];
//        obj.abstract = [[TBXML textForElement:[TBXML childElementNamed:@"description" parentElement:xmlElm]] stringByRemovingHTMLTags];
//        obj.link = [[TBXML textForElement:[TBXML childElementNamed:@"link" parentElement:xmlElm]] stringByRemovingHTMLTags];
//        obj.fromLink = [[TBXML textForElement:[TBXML childElementNamed:@"fromLink" parentElement:xmlElm]] stringByRemovingHTMLTags];
//        obj.fromString = [[TBXML textForElement:[TBXML childElementNamed:@"from" parentElement:xmlElm]] stringByRemovingHTMLTags];
//        obj.subId = [TBXML textForElement:[TBXML childElementNamed:@"subId" parentElement:xmlElm]];
//        obj.subCount = [TBXML textForElement:[TBXML childElementNamed:@"subCount" parentElement:xmlElm]];
//        
//        NSString *picUrl = [TBXML textForElement:[TBXML childElementNamed:@"pics" parentElement:xmlElm]];
//        if (picUrl) {
//            NSArray *imageUrls = [picUrl componentsSeparatedByString:@","];
//            if (imageUrls.count > 0) {
//                obj.picsArray = [NSMutableArray arrayWithArray:imageUrls];
//            }
//        }
//                
//        obj.picSize = [TBXML textForElement:[TBXML childElementNamed:@"picSize" parentElement:xmlElm]];
//        if (obj.picSize.length == 0 && obj.picsArray.count > 0) obj.picSize = @"490x340";
//        
//        // 微热议 没有title的情况 title字段用摘要
//        if (obj.sourceType == 13 && obj.title.length == 0)
//            obj.title = obj.abstract;
//    }    
//    
//    return obj;
//}
//
//+ (CGFloat)heightForTimelineOriginalContent:(SNTimelineOriginContentObject *)originContentObj {
//    CGFloat height = 0;
//    
//    if (originContentObj.type != SNTimelineOriginContentTypeSub) {
//        // 计算高度  要考虑到图片的大小  文字最多显示的行数
//        CGFloat width = kTLOriginalContentWidth - 2 * kTLOriginalContentTextSideMargin;
//        
//        height += kTLOriginalContentTitleTopMargin;
//        UIFont *titleFont = [UIFont systemFontOfSize:kTLOriginalContentTitleFontSize];
//        CGSize titleSize = [originContentObj.title sizeWithFont:titleFont
//                                                          constrainedToSize:CGSizeMake(width, CGFLOAT_MAX)
//                                                              lineBreakMode:UILineBreakModeCharacterWrap];
//        height += titleSize.height;
//        originContentObj.titleHeight = titleSize.height;
//        
//        height += kTLOriginalContentFromTopMargin;
//        UIFont *fromStringFont = [UIFont systemFontOfSize:kTLOriginalContentFromFontSize];
//        CGSize fromSize = [originContentObj.fromDisplayString sizeWithFont:fromStringFont
//                                                                     constrainedToSize:CGSizeMake(width, CGFLOAT_MAX)
//                                                                         lineBreakMode:UILineBreakModeCharacterWrap];
//        height += fromSize.height;
//        originContentObj.fromHeight = fromSize.height;
//        
//        // 文字最多显示六行
//        if (originContentObj.picsArray.count > 0) {
//            CGFloat maxHeight = 6 * kTLOriginalContentAbstractLineHeight;
//            CGSize absSize = [SNLabel sizeForContent:originContentObj.abstract maxSize:CGSizeMake(width, CGFLOAT_MAX_CORE_TEXT) font:kTLOriginalContentAbstractFontSize lineHeight:kTLOriginalContentAbstractLineHeight];
//            if (absSize.height > 0) {
//                height += kTLOriginalContentAbstractTopMargin;
//                height += MIN(absSize.height,maxHeight);
//            }
//            
//            originContentObj.abstractHeight = MIN(absSize.height,maxHeight);
//            
//            height += kTLOriginalContentImageTopMargin;
//            height += originContentObj.picDisplaySize.height;
//            height += kTLOriginalContentImageBottomMargin;
//            height -= kTLOriginalContentAbstractLineSpacing;
//        }
//        // 文字最多显示八行
//        else {
//            CGFloat maxHeight = 8 * kTLOriginalContentAbstractLineHeight;
//            CGSize absSize = [SNLabel sizeForContent:originContentObj.abstract maxSize:CGSizeMake(width, CGFLOAT_MAX_CORE_TEXT) font:kTLOriginalContentAbstractFontSize lineHeight:kTLOriginalContentAbstractLineHeight];
//            
//            if (absSize.height > 0) {
//                height += kTLOriginalContentAbstractTopMargin;
//                height += MIN(maxHeight,absSize.height);
//            }
//            
//            originContentObj.abstractHeight = MIN(maxHeight,absSize.height);
//        }
//    }
//    else {
//        height += kTLViewSubViewHeight;
//    }
//    
//    return height;
//}
//
//- (NSDictionary *)toDictionary {
//    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
//    
//    [dic setObject:[NSString stringWithFormat:@"%d", self.sourceType] forKey:@"sourceType"];
//    
//    [dic setObject:self.hasTv ? @"1" : @"0" forKey:@"hasTV"];
//
//    if (self.title)
//        [dic setObject:self.title forKey:@"title"];
//    else
//        [dic setObject:@"" forKey:@"title"];
//    
//    if (self.abstract)
//        [dic setObject:self.abstract forKey:@"description"];
//    else
//        [dic setObject:@"" forKey:@"description"];
//
//    if (self.link)
//        [dic setObject:self.link forKey:@"link"];
//    
//    if (self.fromLink)
//        [dic setObject:self.fromLink forKey:@"fromLink"];
//    
//    if (self.fromString)
//        [dic setObject:self.fromString forKey:@"from"];
//    
//    if (self.picsArray.count > 0)
//        [dic setObject:self.picsArray[0] forKey:@"pics"];
//    else
//        [dic setObject:@"" forKey:@"pics"];
//    
//    if (self.picSize)
//        [dic setObject:self.picSize forKey:@"picSize"];
//    else
//        [dic setObject:@"" forKey:@"picSize"];
//    
//    if (self.subId && [self.subId longLongValue] != 0)
//        [dic setObject:self.subId forKey:@"subId"];
//    
//    if (self.subCount && [self.subCount longLongValue] != 0)
//        [dic setObject:self.subCount forKey:@"subCount"];
//    
//    return dic;
//}
//
//- (void)setPicSize:(NSString *)picSize {
//    if (_picSize != picSize) {
//        TT_RELEASE_SAFELY(_picSize);
//        _picSize = [picSize copy];
//        
//        _picFullSize = CGSizeZero;
//        _picDisplaySize = CGSizeZero;
//        
//        if (_picSize.length > 0) {
//            NSArray *sizeArray = [_picSize componentsSeparatedByString:@"*"];
//            if (sizeArray.count < 2)
//                sizeArray = [_picSize componentsSeparatedByString:@"x"];
//            if (sizeArray.count < 2)
//                sizeArray = [_picSize componentsSeparatedByString:@"X"];
//            
//            if (sizeArray.count >= 2) {
//                _picFullSize = CGSizeMake([sizeArray[0] floatValue], [sizeArray[1] floatValue]);
//                CGFloat dHeight = MIN(kTLOriginalContentImageWidth * _picFullSize.height / _picFullSize.width, kTLOriginalContentIamgeMaxHeight);
//                _picDisplaySize = CGSizeMake(kTLOriginalContentImageWidth, dHeight);
//            }
//        }
//    }
//}
//
//- (void)setSubId:(NSString *)subId {
//    if (_subId != subId) {
//        TT_RELEASE_SAFELY(_subId);
//        _subId = [subId copy];
//    }
//    NSString *picUrlFromShareRead = self.picsArray.count > 0 ? self.picsArray[0] : nil;
//    
//    SCSubscribeObject *subObj = [[SNDBManager currentDataBase] getSubscribeCenterSubscribeObjectBySubId:_subId];
//    if (subObj && self.type == SNTimelineOriginContentTypeSub) {
//        self.subName = subObj.subName;
//        self.picUrl = subObj.subIcon.length > 0 ? subObj.subIcon : picUrlFromShareRead;
//        self.isSubed = subObj.isSubscribed;
//    }
//    else {
//        self.subName = self.title;
//        self.picUrl = picUrlFromShareRead;
//    }
//}
//
//- (void)setSourceType:(int)sourceType {
//    _sourceType = sourceType;
//    switch (_sourceType) {
//        case 3:
//        case 6:
//        case 7:
//            self.typeString = @"新闻";
//            break;
//        case 4:
//            self.typeString = @"组图";
//            break;
//        case 12:
//            self.typeString = @"投票";
//            break;
//        case 9:
//            self.typeString = @"直播";
//            break;
//        case 8:
//        case 37:
//            self.typeString = @"链接";
//            break;
//        case 30:
//            self.typeString = @"订阅";
//            break;
//        case 11:
//        case 32:
//            self.typeString = @"刊物";
//            break;
//        case 10:
//            self.typeString = @"专题";
//            break;
//        case 13:
//            self.typeString = @"微热议";
//            break;
//        case 33:
//            self.typeString = @"新闻频道列表";
//            break;
//        case 34:
//            self.typeString = @"微热议频道列表";
//            break;
//        case 35:
//            self.typeString = @"组图频道列表";
//            break;
//        case 36:
//            self.typeString = @"直播频道列表";
//            break;
//            
//        default:
//            self.typeString = nil;
//            break;
//    }
//}
//
//- (SNTimelineOriginContentType)type {
//    switch (_sourceType) {
//        case 11: // paper
//        case 30: // 刊物
//        case 31: // ?
//        case 32: // dataFollow
//        case 33: // news channel
//        case 34: // weibo channel
//        case 35: // group PicChannel
//        case 36: // live channel
//        case 38: // 功能插件
//        case 39: // 政企
//            if (self.subId.length > 0)
//                _type = SNTimelineOriginContentTypeSub;
//            else if (self.picsArray.count > 0)
//                _type = SNTimelineOriginContentTypeTextAndPics;
//            else
//                _type = SNTimelineOriginContentTypeText;
//            break;
//            
//        default:
//            if (self.picsArray.count > 0)
//                _type = SNTimelineOriginContentTypeTextAndPics;
//            else
//                _type = SNTimelineOriginContentTypeText;
//            break;
//    }
//    return _type;
//}
//
//- (NSString *)fromDisplayString {
//    NSString *fromTextToDraw = nil;
//    if (self.fromString.length > 0) {
//        fromTextToDraw = [self.fromString stringByAppendingFormat:@"  %@", self.typeString.length > 0 ? self.typeString : @""];
//    }
//    else {
//        fromTextToDraw = self.typeString;
//    }
//    return fromTextToDraw;
//}
//
//- (void)dealloc {
//    TT_RELEASE_SAFELY(_referId);
//    TT_RELEASE_SAFELY(_typeString);
//    TT_RELEASE_SAFELY(_contentId);
//    TT_RELEASE_SAFELY(_title);
//    TT_RELEASE_SAFELY(_abstract);
//    TT_RELEASE_SAFELY(_link);
//    TT_RELEASE_SAFELY(_fromLink);
//    TT_RELEASE_SAFELY(_fromString);
//    TT_RELEASE_SAFELY(_picsArray);
//    TT_RELEASE_SAFELY(_picUrl);
//    TT_RELEASE_SAFELY(_picSize);
//    TT_RELEASE_SAFELY(_subId);
//    TT_RELEASE_SAFELY(_subCount);
//    TT_RELEASE_SAFELY(_subName);
//    TT_RELEASE_SAFELY(_isSubed);
//    [super dealloc];
//}
//
//@end
//
//#pragma mark - SNTimelineObject
//
////@implementation SNTimelineObject
////@synthesize commentNum, content, timelineId, nickName, headIcon, gender, reshareNum, pid, ctime, originContentObj = _originContentObj;
////@synthesize heightComments, heightOriginContent, heightShareInfo, heightShareInfoContent;
////@synthesize isFolder;
////@synthesize needFolder;
////@synthesize commentsArray = _commentsArray;
////@synthesize commentNextCursor = _commentNextCursor;
////@synthesize commentPreCursor = _commentPreCursor;
////@synthesize attriContent = _attriContent;
//
////+ (SNTimelineObject *)timelineObjFromDic:(NSDictionary *)actsInfoDic {
////    SNTimelineObject *aObj = nil;
////    if (actsInfoDic && [actsInfoDic isKindOfClass:[NSDictionary class]]) {
////        NSDictionary *shareInfoDic = [actsInfoDic dictionaryValueForKey:@"shareInfo" defalutValue:nil];
////        if (shareInfoDic) {
////            aObj = [[SNTimelineObject new] autorelease];
////            aObj.commentNum = [NSString stringWithFormat:@"%lld", [shareInfoDic longlongValueForKey:@"commentNum" defaultValue:0]];
////            aObj.content = [shareInfoDic stringValueForKey:@"content" defaultValue:nil];
////            aObj.timelineId = [NSString stringWithFormat:@"%lld", [shareInfoDic longlongValueForKey:@"id" defaultValue:0]];
////            aObj.nickName = [shareInfoDic stringValueForKey:@"nickName" defaultValue:nil];
////            aObj.headIcon = [shareInfoDic stringValueForKey:@"headUrl" defaultValue:nil];
////            aObj.gender = [shareInfoDic intValueForKey:@"gender" defaultValue:1];
////            aObj.reshareNum = [NSString stringWithFormat:@"%lld", [shareInfoDic longlongValueForKey:@"reshareNum" defaultValue:0]];
////            aObj.pid = [NSString stringWithFormat:@"%lld", [shareInfoDic longlongValueForKey:@"pid" defaultValue:0]];
////            aObj.ctime = [NSString stringWithFormat:@"%lld", [shareInfoDic longlongValueForKey:@"ctime" defaultValue:0]];
////                        
////            // origin content
////            NSDictionary *originObjInfo = [shareInfoDic dictionaryValueForKey:@"originContent" defalutValue:nil];
////            aObj.originContentObj = [SNTimelineOriginContentObject timelineOriginContentObjFromDic:originObjInfo];
////            
////            // comments
////            aObj.commentNextCursor = [NSString stringWithFormat:@"%lld", [shareInfoDic longlongValueForKey:@"commentNextCursor" defaultValue:0]];
////            aObj.commentPreCursor = [NSString stringWithFormat:@"%lld", [shareInfoDic longlongValueForKey:@"commentPreCursor" defaultValue:0]];
////            NSArray *commentsArray = [shareInfoDic arrayValueForKey:@"comments" defaultValue:nil];
////            aObj.commentsArray = [self parseCommentsArray:commentsArray];
////            
////            // 默认折叠
////            aObj.isFolder = YES;
////            
////            // cache size
////            [aObj sizeToFit];
////        }
////    }
////    return aObj;
////}
//
////+ (NSMutableArray *)parseCommentsArray:(NSArray *)commentsObjArray {
////    NSMutableArray *aParsedArray = nil;
////    if (commentsObjArray && [commentsObjArray isKindOfClass:[NSArray class]]) {
////        aParsedArray = [NSMutableArray array];
////        for (NSDictionary *cmtDicInfo in commentsObjArray) {
////            SNTimelineCommentsObject *aObj = [SNTimelineCommentsObject timelineCommentObjFromDic:cmtDicInfo];
////            if (aObj) [aParsedArray addObject:aObj];
////        }
////    }
////    return aParsedArray;
////}
//
////+ (CGFloat)heightForTimelineShareInfo:(SNTimelineObject *)timelineObj {
////    if ([timelineObj isKindOfClass:[SNTimelineObject class]]) {
////        // use cache first
////        if (timelineObj.heightShareInfo!= 0) {
////            return timelineObj.heightShareInfo;
////        }
////        
////        // caculate height
////        CGFloat contentWidth = TTApplicationFrame().size.width - kTLViewSideMargin - kTLShareInfoViewTextLeftMargin;
////        CGFloat maxHeight = SNTIMELINE_SHAREINFO_LINE_MAX_WITHOUT_MORE*kTLShareInfoViewContentLineHeight;
////        CGFloat maxHeightWithMore = SNTIMELINE_SHAREINFO_LINE_MAX_WITH_MORE*kTLShareInfoViewContentLineHeight;
////        CGFloat height = [SNLabel heightForContent:timelineObj.content
////                                           maxSize:CGSizeMake(contentWidth, CGFLOAT_MAX_CORE_TEXT)
////                                              font:kTLShareInfoViewContentFontSize
////                                        lineHeight:kTLShareInfoViewContentLineHeight
////                                     textAlignment:NSTextAlignmentLeft
////                                     lineBreakMode:NSLineBreakByCharWrapping];
////        
////        if(height>maxHeight) {
////            timelineObj.needFolder = YES;
////            if(timelineObj.isFolder) {
////                timelineObj.heightShareInfoContent = maxHeightWithMore;
////                height = maxHeightWithMore + SNTIMELINE_SHAREINFO_MORE_HEIGHT;
////            }
////            else {
////               timelineObj.heightShareInfoContent = height;
////            }
////        }
////        else {
////            timelineObj.heightShareInfoContent = height;
////        }
////       
////        timelineObj.heightShareInfo = height + kTLShareInfoViewContentTopMargin;
////        return height + kTLShareInfoViewContentTopMargin;
////    }
////    return 0;
////}
//
////+ (CGFloat)heightForTimelineOriginalContent:(SNTimelineObject *)timelineObj {
////    if ([timelineObj isKindOfClass:[SNTimelineObject class]]) {
////        // use cache first
////        if (timelineObj.heightOriginContent != 0) return timelineObj.heightOriginContent;
////        
////        if (timelineObj.originContentObj.type != SNTimelineOriginContentTypeSub) {
////            // 计算高度  要考虑到图片的大小  文字最多显示的行数
////            CGFloat width = kTLOriginalContentWidth - 2 * kTLOriginalContentTextSideMargin;
////            CGFloat height = 0;
////            
////            height += kTLOriginalContentTitleTopMargin;
////            UIFont *titleFont = [UIFont systemFontOfSize:kTLOriginalContentTitleFontSize];
////            CGSize titleSize = [timelineObj.originContentObj.title sizeWithFont:titleFont
////                                                              constrainedToSize:CGSizeMake(width, CGFLOAT_MAX)
////                                                                  lineBreakMode:UILineBreakModeCharacterWrap];
////            height += titleSize.height;
////            timelineObj.originContentObj.titleHeight = titleSize.height;
////            
////            height += kTLOriginalContentFromTopMargin;
////            UIFont *fromStringFont = [UIFont systemFontOfSize:kTLOriginalContentFromFontSize];
////            CGSize fromSize = [timelineObj.originContentObj.fromDisplayString sizeWithFont:fromStringFont
////                                                                         constrainedToSize:CGSizeMake(width, CGFLOAT_MAX)
////                                                                             lineBreakMode:UILineBreakModeCharacterWrap];
////            height += fromSize.height;
////            timelineObj.originContentObj.fromHeight = fromSize.height;
////            
////            // 文字最多显示六行
////            if (timelineObj.originContentObj.picsArray.count > 0) {
////                CGFloat maxHeight = 6 * kTLOriginalContentAbstractLineHeight;
////                CGSize absSize = [SNLabel sizeForContent:timelineObj.originContentObj.abstract maxSize:CGSizeMake(width, CGFLOAT_MAX_CORE_TEXT) font:kTLOriginalContentAbstractFontSize lineHeight:kTLOriginalContentAbstractLineHeight];
////                if (absSize.height > 0) {
////                    height += kTLOriginalContentAbstractTopMargin;
////                    height += MIN(absSize.height,maxHeight);
////                }
////                
////                timelineObj.originContentObj.abstractHeight = MIN(absSize.height,maxHeight);
////                
////                height += kTLOriginalContentImageTopMargin;
////                height += timelineObj.originContentObj.picDisplaySize.height;
////                height += kTLOriginalContentImageBottomMargin;
////                height -= kTLOriginalContentAbstractLineSpacing;
////            }
////            // 文字最多显示八行
////            else {
////                CGFloat maxHeight = 8 * kTLOriginalContentAbstractLineHeight;
////                CGSize absSize = [SNLabel sizeForContent:timelineObj.originContentObj.abstract maxSize:CGSizeMake(width, CGFLOAT_MAX_CORE_TEXT) font:kTLOriginalContentAbstractFontSize lineHeight:kTLOriginalContentAbstractLineHeight];
////                
////                if (absSize.height > 0) {
////                    height += kTLOriginalContentAbstractTopMargin;
////                    height += MIN(maxHeight,absSize.height);
////                }
////                
////                timelineObj.originContentObj.abstractHeight = MIN(maxHeight,absSize.height);
////            }
////            
////            return height;
////        }
////        else {
////            return kTLViewSubViewHeight;
////        }
////    }
////    return 0;
////}
//
////- (void)sizeToFit {
////    if (self.heightComments == 0)
////        self.heightComments = [[self class] heightForTimeLineComments:self];
////    if (self.heightShareInfo == 0)
////        self.heightShareInfo = [[self class] heightForTimelineShareInfo:self];
////    if (self.heightOriginContent == 0)
////        self.heightOriginContent = [[self class] heightForTimelineOriginalContent:self];
////}
////
////- (void)resetAllCommentHeight {
////    for(SNTimelineCommentsObject* object in self.commentsArray) {
////        object.textHeight = 0.0f;
////    }
////    self.heightComments = 0.0f;
////}
//
////- (void)setOriginContentObj:(SNTimelineOriginContentObject *)originContentObj {
////    if (_originContentObj != originContentObj) {
////        TT_RELEASE_SAFELY(_originContentObj);
////        _originContentObj = [originContentObj retain];
////    }
////}
//
////- (void)dealloc {
////    TT_RELEASE_SAFELY(commentNum);
////    TT_RELEASE_SAFELY(content);
////    TT_RELEASE_SAFELY(timelineId);
////    TT_RELEASE_SAFELY(nickName);
////    TT_RELEASE_SAFELY(headIcon);
////    TT_RELEASE_SAFELY(reshareNum);
////    TT_RELEASE_SAFELY(pid);
////    TT_RELEASE_SAFELY(ctime);
////    
////    TT_RELEASE_SAFELY(_originContentObj);
////    
////    TT_RELEASE_SAFELY(_commentsArray);
////    TT_RELEASE_SAFELY(_commentNextCursor);
////    TT_RELEASE_SAFELY(_commentPreCursor);
////    
////    TT_RELEASE_SAFELY(_attriContent);
////    
////    [super dealloc];
////}
////
////@end
