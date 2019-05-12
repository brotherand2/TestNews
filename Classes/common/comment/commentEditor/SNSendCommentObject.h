//
//  SNSendCommentObject.h
//  sohunews
//
//  Created by jialei on 14-2-11.
//  Copyright (c) 2014年 Sohu.com. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SNNewsComment.h"

typedef NS_ENUM(NSInteger, SNCmtPropType)
{
    SNCmtPropTypeUserComment = 1,
    SNCmtPropTypeIrrigation = 2,
    SNCmtPropTypeTrendUgc = 3
};

@interface SNSendCommentObject : NSObject

@property (nonatomic, copy)NSString *newsId;
@property (nonatomic, copy)NSString *gid;
@property (nonatomic, copy)NSString *topicId;
@property (nonatomic, copy)NSString *busiCode;
@property (nonatomic, copy)NSString *commentId;
@property (nonatomic, copy)NSString *fPid;
@property (nonatomic, copy)NSString *replyType;
@property (nonatomic, copy)NSString *replyName;
@property (nonatomic, strong)SNNewsComment *replyComment;
@property (nonatomic, assign)int refer;
@property (nonatomic, assign)int comtProp;

@property (nonatomic, copy)NSString *cmtText;
@property (nonatomic, copy)NSString *cmtImagePath;
@property (nonatomic, copy)UIImage  *cmtImgae;
@property (nonatomic, copy)NSString *cmtAudioPath;
@property (nonatomic, copy)NSString *cmtAudioDuration;
@property (nonatomic, assign) BOOL isNovelComment;//小说评论
@property (nonatomic, copy)NSString *channelId;

@end
