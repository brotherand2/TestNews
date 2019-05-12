//
//  SNNewsComment.h
//  sohunews
//
//  Created by Dan on 6/18/11.
//  Copyright 2011 Sohu.com Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SNCommentConfigs.h"

//评论状态（0未审核、1正常、2删除）
typedef enum {
	SNNewsCommentStatusInReview,
	SNNewsCommentStatusNormal,
	SNNewsCommentStatusDeleted
} SNNewsCommentStatus;

typedef NS_ENUM(NSInteger, SNNewsCommentRole)
{
    SNNewsCommentRoleAuthor = 1
};

@interface SNNewsComment : NSObject {
	NSInteger cid;
	NSString *time;
	NSString *author;
	NSString *content;
    
    NSString *commentId;
    NSString *city;
    NSString *replyNum;
    NSString *digNum;
    NSString *from;
    NSString *ctime;
    NSString *topicId;
    NSString *passport;
    NSString *linkStyle;            //点击用户打开的方式：0 space 、1 native
    NSString *spaceLink;            //用户空间的链接
    NSString *pid;                  //用户pid
    NSString *newsTitle;            //新闻标题
    NSString *newsLink;             //二代协议的链接
    NSString *authorimg;            //获取评论者头像地址的服务接口地址，会302到真正的头像地址
    NSString *commentImage;         //图片评论对应的原图
    NSString *commentImageSmall;    //图片评论对应的小图
    NSString *commentImageBig;      //图片评论对应的大图
    
    NSString *commentFromNewsTitle; //评论的新闻的标题
    NSString *commentFromNewsLink;  //评论的新闻的链接
    int commentAudLen;              //评论语音长度
    NSString *commentAudUrl;        //评论语音地址
    NSString *userComtId;           //服务端假显示
    NSString *fromIcon;             //评论头像地址
    int status;                     //评论状态（0未审核、1正常、2删除）
    
    NSMutableArray *floors;
    int floorNum;
    BOOL hadDing;
    BOOL isCommentOpen;
    BOOL isCache;
}

@property(nonatomic, copy)NSString *time;
@property(nonatomic, copy)NSString *author;
@property(nonatomic, copy)NSString *content;

@property(nonatomic, copy)NSString *commentId;
@property(nonatomic, copy)NSString *newsId;
@property(nonatomic, copy)NSString *city;
@property(nonatomic, copy)NSString *replyNum;
@property(nonatomic, copy)NSString *digNum;
@property(nonatomic, copy)NSString *from;
@property(nonatomic, copy)NSString *ctime;
@property(nonatomic, copy)NSString *topicId;
@property(nonatomic, copy)NSString *passport;
@property(nonatomic, copy)NSString *linkStyle;
@property(nonatomic, copy)NSString *spaceLink;
@property(nonatomic, copy)NSString *pid;
@property(nonatomic, copy)NSString* authorimg;
@property(nonatomic, copy)NSString* commentImage;
@property(nonatomic, copy)NSString* commentImageSmall;
@property(nonatomic, copy)NSString* commentImageBig;
@property(nonatomic, strong)NSMutableArray *floors;
@property(nonatomic, readwrite)int floorNum;
@property(nonatomic, readwrite)BOOL hadDing;
@property(nonatomic, readwrite)NSInteger cid;
@property(nonatomic, assign)BOOL isCommentOpen;
@property(nonatomic, copy)NSString* newsTitle;
@property(nonatomic, copy)NSString* newsLink;
@property(nonatomic, assign)int commentAudLen;
@property(nonatomic, copy)NSString *commentAudUrl;
@property(nonatomic, copy)NSString *userComtId;
@property(nonatomic, assign)BOOL isCache;
@property(nonatomic, strong)NSString *fromIcon;
@property(nonatomic, assign)int status;
@property(nonatomic, assign)BOOL isAuthor;
@property(nonatomic, strong)NSArray *badgeListArray;
@property(nonatomic, assign)int roleType;
@property (nonatomic, copy)NSString *cmtStatus;
@property (nonatomic, copy)NSString *cmtHint;
@property (nonatomic, copy)NSString *orgHomePage;
@property (nonatomic, copy)NSString *busiCode;
@property (nonatomic, copy)NSArray *attachList;
@property (nonatomic, assign)SNCommentMediaType mediaType;

+(BOOL)IsEqualObject:(SNNewsComment*)aObj1 obj2:(SNNewsComment*)aObj2;
+(SNNewsComment*)GetProperObject:(SNNewsComment*)aObj1 obj2:(SNNewsComment*)aObj2;
+(BOOL)commentHadDing:(NSString *)commId dingComments:(NSMutableArray*)hadDingComments;

+(SNNewsComment *)createReplyComment:(NSDictionary *)beRepliedCmt;
//生成被回复的评论
+(SNNewsComment *)createReplyComment:(SNNewsComment *)beRepliedCmt replyType:(SNCommentSendType)type;
- (BOOL)hasAudio;
- (BOOL)hasImage;

@end
