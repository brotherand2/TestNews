//
//  SNActionMenuContent.h
//  sohunews
//
//  Created by Dan Cong on 12/10/13.
//  Copyright (c) 2013 Sohu.com. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SNDatabase_ReadCircle.h"
#import "SNAnalytics.h"
#import "SNUnifyShareServer.h"
#import "SNNewsReport.h"

typedef enum {
    ShareSubTypeTextOnly,//纯文字
    ShareSubTypeQuoteCard,//原文引用卡片
    ShareSubTypeComment,//评论加缩略图
    ShareSubTypeQuoteText//部分文字加缩略图
}ShareSubType;//分享方式

typedef uint64_t SNActionMenuOptions;

typedef NS_ENUM(uint64_t, SNActionMenuOption) {
    SNActionMenuOptionUnknown          = 0 <<  0, //no option，保持队形，小清新
	SNActionMenuOptionOAuths           = 1 <<  0, //微博等基于OAuth协议的一键分享
	SNActionMenuOptionWXSession        = 1 <<  1, //微信好友
    SNActionMenuOptionWXTimeline       = 1 <<  2, //微信朋友圈
	SNActionMenuOptionMail             = 1 <<  3, //邮件
    SNActionMenuOptionSMS              = 1 <<  4, //短信
    SNActionMenuOptionQQ               = 1 <<  5, //QQ
    SNActionMenuOptionQZone            = 1 <<  6, //QZone
    SNActionMenuOptionEvernote         = 1 <<  7, //印象笔记
    SNActionMenuOptionWebLink          = 1 <<  8, //复制web链接
    SNActionMenuOptionDownload         = 1 <<  9, //下载loading页图片
    SNActionMenuOptionMySOHU           = 1 <<  10, //搜狐我的 //5.2.0新加的需求 2015.4.23

    //区分收藏的3种样式
    SNActionMenuOptionUnliked           = 1 << 11, //已收藏
    SNActionMenuOptionLiked             = 1 << 12, //未收藏
    SNActionMenuOptionLikeDisabled      = 1 << 13, //禁用收藏
    SNActionMenuOptionAliPaySession     = 1 << 14, //支付宝回话
    SNActionMenuOptionAliPayLifeCircle  = 1 << 15, //支付宝生活圈
    SNActionMenuOptionScreenshotShare   = 1 << 16, //截屏
};
#define   SNShareToThirdPartTypeSina            (@"1")
#define   SNShareToThirdPartTypeWeiXinFriend    (@"71")
#define   SNShareToThirdPartTypeWeiXinTimeline  (@"72")
#define   SNShareToThirdPartTypeQQ              (@"80")
#define   SNShareToThirdPartTypeQZone           (@"6")
#define   SNShareToThirdPartTypeMySohu          (@"19")
#define   SNShareToThirdPartTypeAlipay          (@"31")
#define   SNShareToThirdPartTypeLifeCircle      (@"32")

@interface SNActionMenuContent : NSObject

@property (nonatomic) ShareType contentType;

@property(nonatomic)ShareSubType shareSubType;

@property(nonatomic, weak)id delegate;

@property(nonatomic, assign)SNActionMenuOption type;
@property(nonatomic, assign)int sourceType;

@property(nonatomic)SNTimelineContentType timelineContentType;
@property(nonatomic, strong)NSString *timelineContentId;

@property(nonatomic, strong)NSString *newsLink;
@property(nonatomic, strong)NSDictionary *shareContentDic;
//log
@property(nonatomic)ShareTargetType shareTarget;
@property(nonatomic, strong)NSString *shareLogId;
@property (nonatomic, copy) NSString *shareLogType;
@property(nonatomic, strong)NSString *shareLogContent;
@property(nonatomic, strong)NSString *shareLogSudId;
@property (nonatomic, strong)NSString *shaereTargetName;

@property(nonatomic, strong)NSString *content;

//comment
@property(nonatomic, strong)NSString *shareTitle;
@property(nonatomic, strong)NSString *comment;

@property(nonatomic, assign)BOOL isVideoShare;
@property(nonatomic, assign)BOOL isQianfanShare;

- (void)interpretContext:(NSDictionary *)contentDic;
- (void)share;

- (NSString *)removeLinkFromString:(NSString *)content;
- (NSString *)getLinkFromString:(NSString *)content;
- (NSString *)removeAtTailFromString:(NSString *)content;
- (NSString*)getShareContent:(NSString*)strContent;

//protocol
@property (nonatomic, copy) NSString * protocoUrl;

- (void)useShareCommentAsContent;

- (void)log;

@end
