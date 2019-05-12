//
//  SNTimelineItem.h
//  sohunews
//
//  Created by jojo on 13-6-24.
//  Copyright (c) 2013年 Sohu.com. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SNTLComViewBuilder.h"
#import "TBXML.h"

#pragma mark - SNTimelineOriginContentObject

//typedef enum {
//    SNTimelineOriginContentTypeSub,
//    SNTimelineOriginContentTypeText,
//    SNTimelineOriginContentTypeTextAndPics
//}SNTimelineOriginContentType;

//@interface SNTimelineOriginContentObject : NSObject
//
//@property(nonatomic, copy) NSString *referId;
//@property(nonatomic, assign) SNTimelineOriginContentType type;
//@property(nonatomic, assign) int sourceType; // 参考二代协议 link type http://smc.sohuno.com/wiki/pages/viewpage.action?pageId=2163970
//@property(nonatomic, copy) NSString *typeString;
//@property(nonatomic, assign) BOOL hasTv; // 是否有视频
//
//@property(nonatomic, copy) NSString *contentId; // id
//
//@property(nonatomic, copy) NSString *title; // description
//@property(nonatomic, copy) NSString *abstract; // 新加了一个字段 老的title现在是真正的title了
//
//@property(nonatomic, copy) NSString *link;
//@property(nonatomic, copy) NSString *fromLink;
//@property(nonatomic, copy) NSString *fromString;
//@property(nonatomic, readonly) NSString *fromDisplayString; // from string + type string
//
//@property(nonatomic, copy) NSString *subId;
//@property(nonatomic, copy) NSString *subCount;
//@property(nonatomic, copy) NSString *subName;
//@property(nonatomic, copy) NSString *isSubed;
//
//@property(nonatomic, retain) NSMutableArray *picsArray; // array of image urls
//@property(nonatomic, copy) NSString *picUrl; // first url in picsArray
//@property(nonatomic, copy) NSString *picSize; // "800x600"
//@property(nonatomic, readonly) CGSize picFullSize;
//@property(nonatomic, readonly) CGSize picDisplaySize;
//
//// cache size
//@property(nonatomic, assign) CGFloat titleHeight;
//@property(nonatomic, assign) CGFloat fromHeight;
//@property(nonatomic, assign) CGFloat abstractHeight;
//
//+ (SNTimelineOriginContentObject *)timelineOriginContentObjFromDic:(NSDictionary *)originInfoDic;
//+ (SNTimelineOriginContentObject *)timelineOriginContentObjFromXMLObj:(TBXMLElement *)xmlElm;
//+ (CGFloat)heightForTimelineOriginalContent:(SNTimelineOriginContentObject *)timelineObj;
//
//- (NSDictionary *)toDictionary;
//
//@end
//
//#pragma mark - SNTimelineObject
//
//@interface SNTimelineObject : NSObject
//
//@property(nonatomic, copy) NSString *commentNum;
//@property(nonatomic, copy) NSString *content;
//@property(nonatomic, copy) NSString *timelineId;
//@property(nonatomic, copy) NSString *nickName;
//@property(nonatomic, copy) NSString *headIcon;
//@property(nonatomic, assign) int gender;
//@property(nonatomic, copy) NSString *reshareNum;
//@property(nonatomic, copy) NSString *pid; // passport id
//@property(nonatomic, copy) NSString *ctime;
//
//// origin resources
//@property(nonatomic, retain) SNTimelineOriginContentObject *originContentObj;
//
//// comments
//@property(nonatomic, copy) NSString *commentNextCursor;
//@property(nonatomic, copy) NSString *commentPreCursor;
//@property(nonatomic, retain) NSMutableArray *commentsArray; // array of SNTimelineCommentsObject
//
//// size cache
//@property(nonatomic, assign) float heightOriginContent;
//@property(nonatomic, assign) float heightShareInfo;
//@property(nonatomic, assign) float heightShareInfoContent;
//@property(nonatomic, assign) float heightComments;
//@property(nonatomic, assign) BOOL isFolder;
//@property(nonatomic, assign) BOOL needFolder;
//@property(nonatomic, retain) NSMutableAttributedString *attriContent;
//
//+ (SNTimelineObject *)timelineObjFromDic:(NSDictionary *)timelineInfoDic;
//
//+ (CGFloat)heightForTimelineShareInfo:(SNTimelineObject *)timelineObj;
//
//// 计算高度
//- (void)sizeToFit;
//// 重置所有评论高度
//- (void)resetAllCommentHeight;
//@end
