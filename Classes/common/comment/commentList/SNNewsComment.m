//
//  SNNewsComment.m
//  sohunews
//
//  Created by Dan on 6/18/11.
//  Copyright 2011 Sohu.com Inc. All rights reserved.
//

#import "SNNewsComment.h"
#import "TBXML.h"
#import "RegexKitLite.h"

#import "SNPostFollow.h"

@implementation SNNewsComment

@synthesize time, author, content;
@synthesize commentId,city,replyNum,digNum,from,ctime,floors,floorNum,topicId,hadDing,cid;
@synthesize passport,linkStyle,spaceLink,pid, isCommentOpen, authorimg, commentImage, commentImageBig, commentImageSmall;
@synthesize newsTitle, newsLink;
@synthesize commentAudLen,commentAudUrl;
@synthesize userComtId;
@synthesize isCache;
@synthesize fromIcon;
@synthesize status;
@synthesize roleType;
@synthesize cmtStatus;
@synthesize cmtHint;

-(NSString *)digNum {
    if (digNum && digNum.length > 0) {
        return digNum;
    } else {
        return @"0";
    }
}

- (BOOL)hasAudio{
    if (commentAudUrl && commentAudUrl.length > 0 && ![commentAudUrl isEqualToString:@""]) {
        return YES;
    }else{
        return NO;
    }
}

- (BOOL)hasImage{
    if(commentImageSmall && [commentImageSmall length] > 0 && ![commentImageSmall isEqualToString:@""]) {
        return YES;
    }else{
        return NO;
    }
}

- (void)dealloc {
    
    _badgeListArray = nil;
    
}

+(BOOL)IsEqualObject:(SNNewsComment*)aObj1 obj2:(SNNewsComment*)aObj2
{
    if(aObj1==nil && aObj2==nil)
        return YES;
    else if(aObj1==nil || aObj2==nil)
        return NO;
    else
    {
        if ([aObj1.userComtId isEqualToString:aObj2.userComtId]) {
            return YES;
        }
        
//        if ((aObj1.userComtId && !aObj2.userComtId) || (!aObj1.userComtId && aObj2.userComtId)) {
//            return NO;
//        }else{
//            if ([aObj1.userComtId isEqualToString:@""] || [aObj2.userComtId isEqualToString:@""]) {
//                return NO;
//            }
//        }
        
        BOOL author = (aObj1.author!=nil && aObj2.author!=nil && [aObj1.author isEqualToString:aObj2.author]);
        //3.4 增加passport作为比较依据，passport非空且相同，则认为是同一人。
        BOOL passport = (aObj1.passport!=nil && aObj2.passport!=nil && [aObj1.passport length]>0 && [aObj1.passport isEqualToString:aObj2.passport]);
        if(passport)
            author = passport;
        
        BOOL content = (aObj1.content!=nil && aObj2.content!=nil && [[aObj1.content stringByReplacingOccurrencesOfString: @"\n" withString:@""] isEqualToString:[aObj2.content stringByReplacingOccurrencesOfString: @"\n" withString:@""]]);
        
        BOOL ctime = NO;
        if(aObj1.ctime!=nil && aObj2.ctime!=nil)
        {
            NSInteger tinyInterval = 10*60; //10分钟
            NSDate* date1 = [NSDate dateWithTimeIntervalSince1970:[aObj1.ctime doubleValue]/1000];
            NSDate* date2 = [NSDate dateWithTimeIntervalSince1970:[aObj2.ctime doubleValue]/1000];
            NSTimeInterval timeinteral = [date1 timeIntervalSinceDate:date2];
            
            if(abs(timeinteral)<tinyInterval)
                ctime = YES;
        }
        return (author && content && ctime);
    }
}

+(SNNewsComment*)GetProperObject:(SNNewsComment*)aObj1 obj2:(SNNewsComment*)aObj2
{
    if(aObj1==nil && aObj2==nil)
        return nil;
    else if(aObj1!=nil)
        return aObj1;
    else if(aObj2!=nil)
        return aObj2;
    else
    {
        if(aObj1.passport!=aObj2.passport)
        {
            if(aObj1.passport!=nil && aObj2.passport==nil)
                return aObj1;
            else if(aObj2.passport!=nil && aObj1.passport==nil)
                return aObj2;
        }
        
        if(aObj1.time!=aObj2.time)
        {
            if(aObj1.time!=nil && aObj2.time==nil)
                return aObj1;
            else if(aObj2.time!=nil && aObj1.time==nil)
                return aObj2;
            else
            {
                NSDateFormatter* formatter = [[NSDateFormatter alloc] init];
                [formatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
                NSDate* date1 = [formatter dateFromString:aObj1.ctime];
                NSDate* date2 = [formatter dateFromString:aObj2.ctime];
                NSTimeInterval timeinteral = [date1 timeIntervalSinceDate:date2];
                
                if(timeinteral<0)
                    return aObj2;
                else
                    return aObj1;
            }
        }
        
        //随便回一个
        return aObj1;
    }
}

+(BOOL)commentHadDing:(NSString *)commId dingComments:(NSMutableArray*)hadDingComments;
{
    BOOL hadDing = NO;
    for (CommentFloor *comJson in hadDingComments)
    {
        if (comJson.commentId.length > 0 &&
            [comJson.commentId isEqualToString:commId])
        {
            hadDing = YES;
            break;
        }
    }
    return hadDing;
}

+(SNNewsComment *)createReplyComment:(SNNewsComment *)beRepliedCmt replyType:(SNCommentSendType)type
{
    SNNewsComment *comment = nil;
    if (beRepliedCmt) {
        comment = [[SNNewsComment alloc] init];
        comment.ctime    = [NSString stringWithFormat:@"%f", [[NSDate date] timeIntervalSince1970]*1000];
        comment.author   = [SNPostFollow currentUserName];
        comment.topicId  = beRepliedCmt.topicId;
        comment.commentId = beRepliedCmt.commentId;
        comment.pid = beRepliedCmt.pid;
        comment.busiCode = beRepliedCmt.busiCode;
        comment.newsId = beRepliedCmt.newsId;

        if (type == kCommentSendTypeReply)
        {
            NSMutableArray *floors = [NSMutableArray array];
            [floors addObjectsFromArray:beRepliedCmt.floors];
            SNNewsComment *floorComment = [[SNNewsComment alloc] init];
            floorComment.commentId  = beRepliedCmt.commentId;
            floorComment.city       = beRepliedCmt.city ? beRepliedCmt.city :@"";
            floorComment.replyNum   = beRepliedCmt.replyNum ? beRepliedCmt.replyNum : @"0";
            floorComment.digNum     = beRepliedCmt.digNum ? beRepliedCmt.digNum : @"0";
            floorComment.from       = beRepliedCmt.from ? beRepliedCmt.from : @"";
            floorComment.ctime      = beRepliedCmt.ctime;
            floorComment.topicId    = beRepliedCmt.topicId;
            floorComment.author     = beRepliedCmt.author ? beRepliedCmt.author : [SNPostFollow currentUserName];
            floorComment.content    = beRepliedCmt.content ? beRepliedCmt.content : @"";
            floorComment.commentImageSmall  = beRepliedCmt.commentImageSmall ? beRepliedCmt.commentImageSmall : @"";
            floorComment.commentImage       = beRepliedCmt.commentImage ? beRepliedCmt.commentImage : @"";
            floorComment.commentImageBig    = beRepliedCmt.commentImageBig ? beRepliedCmt.commentImageBig : @"";
            floorComment.commentAudLen = beRepliedCmt.commentAudLen ? beRepliedCmt.commentAudLen : 0;
            floorComment.commentAudUrl = beRepliedCmt.commentAudUrl ? beRepliedCmt.commentAudUrl : @"";
            floorComment.pid = beRepliedCmt.pid ? beRepliedCmt.pid : @"";
            [floors addObject:floorComment];
            comment.floors = floors;
        }
        else if (type == kCommentSendTypeReplyFloor)
        {
            NSMutableArray *floors = [NSMutableArray array];
            for (SNNewsComment *floorComment in beRepliedCmt.floors) {
                if ([floorComment.commentId isEqualToString:beRepliedCmt.commentId]) {
                    [floors addObject:floorComment];
                    break;
                }
                else {
                    [floors addObject:floorComment];
                }
            }
            comment.floors = floors;
        }
    }
    return comment;
}

@end
