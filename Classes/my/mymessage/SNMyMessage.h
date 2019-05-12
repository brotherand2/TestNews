//
//  SNMyMessage.h
//  sohunews
//
//  Created by jialei on 13-7-18.
//  Copyright (c) 2013年 Sohu.com. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SNTimelineTrendObjects.h"
#import "SNCommentConfigs.h"

#import "SNMyMessageTableController.h"

@interface SNMyMessage : NSObject
{
    NSString *content;          //回复的内容
    NSString *myContent;        //我的原评论
    NSString *commentType;
    NSString *fromLink;         //原文连接
    NSString *shareId;          //分享原文的id
    NSString *nickName;
    NSString *msgId;
    NSString *gender;           //性别0，未知 1，男  2，女
    NSString *pid;
    NSString *headUrl;
    NSString *ctime;
    NSString *city;
//    NSString *userActUrl;       //阅读圈详情页二代协议
//    SNTimelineCommentsObject *replyComment; //被回复的评论
//    SNTimelineCommentsObject *actComment;   //回复评论
//    SNTimelineOriginContentObject *shareObj;
    
    BOOL     isCommentOpen;
}

@property (nonatomic, copy)NSString *content;
@property (nonatomic, copy)NSString *commentType;
@property (nonatomic, copy)NSString *fromLink;
@property (nonatomic, copy)NSString *shareId;
@property (nonatomic, copy)NSString *myContent;
@property (nonatomic, copy)NSString *nickName;
@property (nonatomic, copy)NSString *msgId;
@property (nonatomic, copy)NSString *gender;
@property (nonatomic, copy)NSString *pid;
@property (nonatomic, copy)NSString *headUrl;
@property (nonatomic, copy)NSString *ctime;
@property (nonatomic, copy)NSString *city;
@property (nonatomic, copy)NSString *cmtStatus;
@property (nonatomic, copy)NSString *cmtHint;
@property (nonatomic, copy)NSString *userActUrl;
@property (nonatomic, strong)SNTimelineCommentsObject *replyComment; //被回复的评论
@property (nonatomic, strong)SNTimelineCommentsObject *actComment;   //回复评论
@property (nonatomic, strong)SNTimelineOriginContentObject *shareObj;
@property (nonatomic, assign)BOOL isCommentOpen;
@property (nonatomic, assign)BOOL isCommentFloorOpen;
@property (nonatomic, assign)BOOL enableEnterProtocal;

@end


@interface SNMyMessageItem : TTTableItem
{
}

@property (nonatomic, strong) SNMyMessage *socialMsg;
@property (nonatomic, assign) NSInteger   rowIndex;
@property (nonatomic, assign) CGFloat     actCommentHeight;
@property (nonatomic, assign) CGFloat     replayCommentHeight;
@property (nonatomic, assign) SNMyMessageType dataType;


@end






