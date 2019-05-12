//
//  SNTimelinePostService.h
//  sohunews
//
//  Created by jojo on 13-6-28.
//  Copyright (c) 2013年 Sohu.com. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SNTimelineTrendObjects.h"
#import "SNTimelineCircleModel.h"

@interface SNTimelinePostService : NSObject<TTURLRequestDelegate>

+ (SNTimelinePostService *)sharedService;

// 分享内容到阅读圈
//
// @content : 用户输入的内容 可以为空
// @originContent : 不能为空
// @shareId : 自己发起的分享这个传nil，如果是转发别人的分享 这里传分享的id
//
- (void)timelineShareWithContent:(NSString *)content
                     originContent:(SNTimelineOriginContentObject *)originContent
                       fromShareId:(NSString *)shareId;


/*
 
 {
 baseInfo:{ version:"", userId:"grgwertwe@", p1:"351fhwe5y2==",gid:"24234",pid: 123123, token:"sdfasdfa" },//通用参数里面的保存一致
 content: "胡说八道！！12",
 shareId: "1",
 commentType: "1",
 commentId: "3243",//被回复的那条评论的id    （如果是对分享做的原始评论，则没有这个节点）
 fpid: "89867857689758"  //被回复的那条评论的pid   （如果是对分享做的原始评论，则没有这个节点）
 }
 
 */

// 阅读圈发表评论 参数都不能为空
//
// 参数 必选：
// @commentContent 评论内容
// @shareId 具体评论的分享内容 id
// @spid 分享发起人的pid
// 
- (void)timelinePostComment:(NSString *)commentContent
                      actId:(NSString *)shareId
                       spid:(NSString *)spid;

// 阅读圈 回复某人的评论
//
// 参数 必选:
// @replyContent 回复内容
// @shareId 具体评论的分享内容 id
// @commentId 被回复的那条评论的id
// @fpid 被回复的那条评论的pid
// @fnickName 被回复的那条评论的nickName 为了本地假数据用的
//
- (void)timelineReplyComment:(NSString *)replyContent
                       actId:(NSString *)shareId
                        spid:(NSString *)spid
                   commentId:(NSString *)commentId
                        fpid:(NSString *)fpid
                   fnickName:(NSString *)fnickName;

//删除自己的某条动态
//
//参数：
//@actid   动态id
//@pid     用户id
- (void)timelineDeleteTrend:(NSString *)actId
                        pid:(NSString *)pid
                   userInfo:(NSDictionary *)dic;

/*
 *赞某一条动态
 *param:actid 动态id
 *      pid
 *      type
 */
- (void)timelineTrendApproval:(NSString *)actId
                         spid:(NSString *)spid
                 approvalType:(int)type;
@end
