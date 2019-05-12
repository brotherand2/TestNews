//
//  SNDatabase_ReadCircle.h
//  sohunews
//
//  Created by jojo on 13-7-2.
//  Copyright (c) 2013年 Sohu.com. All rights reserved.
//

#import "SNDatabase.h"
#import "SNTimelineTrendObjects.h"

/*
 type 按照二代协议 划分
 具体的参考wiki：http://smc.sohuno.com/wiki/pages/viewpage.action?pageId=2163970
*/

typedef enum {
    SNTimelineContentTypeNews = 1,
    SNTimelineContentTypePhoto,
    SNTimelineContentTypeLive,
    SNTimelineContentTypePaper,
    SNTimelineContentTypeSpecial,
    SNTimelineContentTypeWeibo,
    SNTimelineContentTypeDataFollow,
    SNTimelineContentTypeNewsChannel,
    SNTimelineContentTypeWeiboChannel,
    SNTimelineContentTypeGroupPicChannel,
    SNTimelineContentTypeLiveChannel,
}SNTimelineContentType;

typedef enum {
    SNTimelineGetDataTypeTimeline = 1,      // 获取所有关注人的所有动态
    SNTimelineGetDataTypeUserActs,          // 获取某个人自己的动态
}SNTimelineGetDataType;

@interface SNDatabase(ReadCircle)

// 分享内容相关
- (BOOL)addOrReplaceOneTimelineOriginObj:(SNTimelineOriginContentObject *)originObj withContentType:(SNTimelineContentType)type contentId:(NSString *)contentId;
- (SNTimelineOriginContentObject *)getTimelineOriginObjByType:(SNTimelineContentType)type contentId:(NSString *)contentId;
- (BOOL)clearAllTimelineOriginObjs;

// timeline相关
- (BOOL)setTimelineObjs:(NSArray *)timelineJsonObjs withGetType:(SNTimelineGetDataType)type pid:(NSString *)pid;
- (BOOL)addOrReplaceOneTimelineObj:(NSString *)timelineJsonObj withShareId:(NSString *)shareId getType:(SNTimelineGetDataType)type pid:(NSString *)pid;
// @return ： array of SNTimelineObject
- (NSArray *)getTimelineObjsByGetType:(SNTimelineGetDataType)type pid:(NSString *)pid;
- (BOOL)clearAllTimelineObjs;

@end
