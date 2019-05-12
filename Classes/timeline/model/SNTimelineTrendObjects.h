//
//  SNTimelineTrendObjects.h
//  sohunews
//
//  Created by jialei on 13-9-11.
//  Copyright (c) 2013年 Sohu.com. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger, SNTimelineItemType)
{
    kSNTimelineItemTypeArticle      = 1,    //文章模版
    kSNTimelineItemTypeSub          = 2,    //订阅模版
    kSNTimelineItemTypePeople       = 3,    //关注模版
    kSNTimelineItemTypeLive         = 4,    //直播模版
    kSNTimelineItemTypeUGC          = 5     //语音ugc模版
};

typedef enum {
    SNTimelineOriginContentTypeSub,
    SNTimelineOriginContentTypeText,
    SNTimelineOriginContentTypeTextAndPics
}SNTimelineOriginContentType;

@class SNTimelineTrendItem;

#pragma mark - SNTimelineOriginalObject
@interface SNTimelineOriginContentObject : NSObject

@property(nonatomic, copy) NSString *referId;
@property(nonatomic, assign) int sourceType; // 参考二代协议 link type http://smc.sohuno.com/wiki/pages/viewpage.action?pageId=2163970
@property(nonatomic, assign) SNTimelineOriginContentType type;
@property(nonatomic, copy) NSString *typeString;
@property(nonatomic, assign) BOOL hasTv;     // 是否有视频

@property(nonatomic, copy) NSString *contentId; // id

@property(nonatomic, copy) NSString *title;     // description
@property(nonatomic, copy) NSString *abstract;  // 新加了一个字段 老的title现在是真正的title了

@property(nonatomic, copy) NSString *link;
@property(nonatomic, copy) NSString *fromLink;
@property(nonatomic, copy) NSString *fromString;
@property(nonatomic, readonly) NSString *fromDisplayString; // from string + type string

@property(nonatomic, copy) NSString *subId;
@property(nonatomic, copy) NSString *subCount;
@property(nonatomic, copy) NSString *subName;
@property(nonatomic, copy) NSString *isSubed;

@property(nonatomic, retain) NSMutableArray *picsArray; // array of image urls
@property(nonatomic, retain) NSMutableArray *attUserArray;  //关注原型列表
@property(nonatomic, copy) NSString *picUrl; // first url in picsArray
@property(nonatomic, copy) NSString *picSize; // "800x600"
@property(nonatomic, readonly) CGSize picFullSize;
@property(nonatomic, readonly) CGSize picDisplaySize;
// cache size
@property(nonatomic, assign) CGFloat titleHeight;
@property(nonatomic, assign) CGFloat fromHeight;
@property(nonatomic, assign) CGFloat abstractHeight;

+ (SNTimelineOriginContentObject *)timelineOriginContentObjFromDic:(NSDictionary *)originInfoDic;
+ (SNTimelineOriginContentObject *)timelineOriginContentObjFromDic:(NSDictionary *)originInfoDic
                                                         trendItem:(SNTimelineTrendItem *)obj;
+ (SNTimelineOriginContentObject *)timelineOriginContentObjFromXMLObj:(TBXMLElement *)xmlElm;
//+ (CGFloat)heightForTimelineOriginalContent:(SNTimelineOriginContentObject *)originContentObj;
- (NSDictionary *)toDictionary;

@end

#pragma mark - SNTimelineCommentsObject
@interface SNTimelineCommentsObject : NSObject

@property(nonatomic,retain) NSString *headUrl;
@property(nonatomic,retain) NSString *time;
@property(nonatomic,assign) int gender;
@property(nonatomic, retain) NSString *actId;
@property(nonatomic, retain) NSString *commentId;
@property(nonatomic, retain) NSString *nickName;
@property(nonatomic, retain) NSMutableAttributedString *attContent;
@property(nonatomic, retain) NSString *content;
//@property(nonatomic, retain) NSString *pid; // passport id
@property(nonatomic, retain) NSString *pid; // 如果是对别人的评论做回复会有这个属性。表现@人的pid
@property(nonatomic, assign) int commentType; // 对分享评论是 1；  对人评论进行回复是2；
//@property(nonatomic, assign)SNTLCommentBgType cmtBgType;
//被回复人信息
@property(nonatomic,retain) NSString *fPid;
@property(nonatomic,retain) NSString *fHeadUrl;
@property(nonatomic,retain) NSString *fNickName;
@property(nonatomic,assign) int fGender;

// for ui cache
@property(nonatomic, retain) NSMutableAttributedString *attriString;
@property(nonatomic, assign) BOOL isFolder;
@property(nonatomic, assign) BOOL needFolder;
@property(nonatomic, assign) CGFloat contentHeight;
@property(nonatomic, assign) CGRect textLabelFrame;
@property(nonatomic, assign) CGRect userIconFrame;
@property(nonatomic, assign) CGRect userLabelFrame;
@property(nonatomic, assign) CGRect timelabelFrame;
@property(nonatomic, assign) CGRect commentFrame;
@property(nonatomic, assign) CGRect moreCmtBtnFrame;
@property(nonatomic, assign) CGRect fuserFrame;
@property(nonatomic, assign) NSRange userNameRange;
@property(nonatomic, assign) NSRange fUserNameRange;
@property(nonatomic, assign) CGFloat commentHeight;
@property(nonatomic, assign) CGRect drawRect;

+ (SNTimelineCommentsObject *)timelineCommentObjFromDic:(NSDictionary *)commentInfoDic;
- (NSMutableAttributedString *)setCommentAttributedStr;
- (NSRange)getTouchRangeWithPoint:(CGPoint)touchPoint frame:(CGRect)rect topGap:(float)gap;

@end

#pragma mark -SNTimelineTrendTopObject
@interface SNTimelineTrendTopObject : NSObject

@property(nonatomic,retain) NSString *time;
@property(nonatomic,retain) NSString *actId;
@property(nonatomic,retain) NSString *headUrl;
@property(nonatomic,retain) NSString *nickName;
@property(nonatomic,retain) NSString *pid;
@property(nonatomic,assign) int gender;
@property(nonatomic,assign) CGRect userIconFrame;


+ (SNTimelineTrendTopObject *)timelineTopObjFromDic:(NSDictionary *)topDic;

@end

#pragma mark - SNTimelineTrendItem
@interface SNTimelineTrendItem : NSObject

@property (nonatomic, assign) BOOL isOpenUgc;
@property (nonatomic, assign) BOOL needOpenUgc;
@property (nonatomic, assign) SNTimelineItemType trendType;
@property (nonatomic, assign) BOOL hideTop;
@property (nonatomic, assign) BOOL hideComment;
@property (nonatomic, assign) SNTimelineOriginContentType uiType;
@property (nonatomic, assign) float    height;
@property (nonatomic, assign) float    ugcContentHeight;
@property (nonatomic, assign) float    ugcHeight;
@property (nonatomic, assign) float    originContentHeight;
@property (nonatomic, assign) float    commentsHeight;
@property (nonatomic, assign) CGRect   moreCmtBtnFrame;

@property (nonatomic, retain) NSString *actId;
@property (nonatomic, retain) NSString *pid;
@property (nonatomic, retain) NSString *userNickName;
@property (nonatomic, retain) NSString *userHeadUrl;
@property (nonatomic, retain) NSString *trendTitle;
@property (nonatomic, retain) NSString *content;
@property (nonatomic, retain) NSString *floorContent;
@property (nonatomic, retain) NSString *time;
@property (nonatomic, retain) NSString *gender;
@property (nonatomic, retain) UIImage *originBgImage;
@property (nonatomic, retain) UIImage *originDefaultImage;
@property (nonatomic, retain) UIImage *subIconBgImage;
@property (nonatomic, retain) SNTimelineOriginContentObject *originContentObj;
@property (nonatomic, assign) int  commentNum;                      //评论数
@property (nonatomic, assign) int  topNum;                          //赞数
@property (nonatomic, assign) BOOL isTop;                           //是否赞过
@property (nonatomic, assign) BOOL showAllComment;
@property (nonatomic, retain) NSMutableArray *commentsArray;        //保存评论数组
@property (nonatomic, retain) NSMutableArray *topArray;             //保存赞数组

@property(nonatomic, copy) NSString *commentNextCursor;
@property(nonatomic, copy) NSString *commentPreCursor;

@property(nonatomic, copy) NSString *ugcBigImageUrl;
@property(nonatomic, copy) NSString *ugcSmallImageUrl;
@property(nonatomic, copy) NSString *ugcAudUrl;
@property(nonatomic, assign) int *ugcAudLen;

+ (SNTimelineTrendItem *)timelineTrendFromDic:(NSDictionary *)itemDic;
//计算动态cell高度
+ (CGFloat)heightForTimelineTrendContent:(SNTimelineTrendItem *)timelineItem;
//展开全部评论
+ (void)SNTimelineTrendCmtsReset:(SNTimelineTrendItem *)item id:(NSString *)cmtId;
//动态发送评论成功
+ (void)SNTimelineTrendSendCmtSuc:(NSArray *)trendItems info:(NSDictionary *)cmtInfo;
+ (SNTimelineCommentsObject *)SNTrendDetailSendCmtSuc:(NSDictionary *)cmtInfo;

- (void)sizeToFit;

@end