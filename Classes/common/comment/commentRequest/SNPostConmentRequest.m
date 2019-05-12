//
//  SNPostConmentRequest.m
//  sohunews
//
//  Created by 李腾 on 2017/1/17.
//  Copyright © 2017年 Sohu.com. All rights reserved.
//

#import "SNPostConmentRequest.h"
#import "SNSendCommentObject.h"
#import "SNUserManager.h"
#import "SNPostFollow.h"
#import "SNUserLocationManager.h"

@interface SNPostConmentRequest ()

@property (nonatomic, strong) NSData *sendImageData;
@property (nonatomic, strong) NSData *sendAudioData;

@end

@implementation SNPostConmentRequest

- (instancetype)initWithCommentObject:(SNSendCommentObject *)cmtObj andRefer:(NSInteger)refer
{
    self = [super init];
    if (self) {
        
        NSMutableDictionary *params = [NSMutableDictionary dictionaryWithCapacity:20];
        self.needNetSafeParameters = YES;
        
        NSString *userName = [SNPostFollow currentUserName];
        
        NSString *sendText          = cmtObj.cmtText;
        NSString *sendAudioPath     = cmtObj.cmtAudioPath;
        UIImage  *sendImage         = [UIImage rotateImage:cmtObj.cmtImgae];
        
        SNNewsComment *replyComment = cmtObj.replyComment;
        NSString *replyCommentId    = cmtObj.replyComment.commentId;
        NSString *replyType         = cmtObj.replyType;
        NSString *fPid              = cmtObj.replyComment.pid;

        NSMutableDictionary *newslinkInfo = nil;
        if (replyComment.newsLink.length > 0) {
            if ([replyComment.newsLink hasPrefix:kProtocolNews]) {
                newslinkInfo = [SNUtility parseURLParam:replyComment.newsLink schema:kProtocolNews];
                if (newslinkInfo) {
                    cmtObj.newsId = [newslinkInfo stringValueForKey:@"newsId" defaultValue:nil];
                }
            }
            else if ([replyComment.newsLink hasPrefix:kProtocolPhoto]) {
                newslinkInfo = [SNUtility parseURLParam:replyComment.newsLink schema:kProtocolPhoto];
                if (newslinkInfo) {
                    cmtObj.gid = [newslinkInfo stringValueForKey:@"gid" defaultValue:nil];
                    if (!cmtObj.gid) {
                        cmtObj.newsId = [newslinkInfo stringValueForKey:@"newsId" defaultValue:nil];
                    }
                }
            }
        }
        
        //评论属性：1用户评论，2灌水评论，3、语音UGC
        [params setValue:@(cmtObj.comtProp) forKey:@"comtProp"];
        
        NSString *localBusiCode = nil;
        
        if (cmtObj.newsId.length > 0 || cmtObj.replyComment.newsId.length > 0) {
            if (refer == REFER_WEIHOT) {
                localBusiCode = @"4";
            } else {
                localBusiCode = @"2";
            }
            
            if (cmtObj.newsId.length > 0) {
                [params setValue:cmtObj.newsId forKey:@"id"];
            } else {
                [params setValue:cmtObj.replyComment.newsId forKey:@"id"];
            }
        } else if (cmtObj.gid.length > 0 || cmtObj.replyComment.newsId.length > 0) {
            localBusiCode = @"3";
            [params setValue:cmtObj.gid forKey:@"id"];
        }
        if (cmtObj.channelId.length > 0) {
            [params setValue:cmtObj.channelId forKey:@"channelId"];
        }
        
        if (cmtObj.topicId.length > 0) {
            [params setValue:cmtObj.topicId forKey:@"topicid"];
        }
        
        if (cmtObj.busiCode.length > 0) {
            [params setValue:cmtObj.busiCode forKey:@"busiCode"];
        } else if(cmtObj.replyComment.busiCode.length > 0) {
            [params setValue:cmtObj.replyComment.busiCode forKey:@"busiCode"];
        } else if (localBusiCode.length > 0){
            [params setValue:localBusiCode forKey:@"busiCode"];
        }
        
        if (sendText) { 
            [params setValue:sendText forKey:@"cont"];
        }
        
        if (userName) {
            [params setValue:userName forKey:@"author"];
        }
        
        if (replyCommentId) {
            [params setValue:[replyCommentId trim] forKey:@"replyId"];
            if (replyType) {
                [params setValue:replyType forKey:@"replyType"];
            } else {
                [params setValue:@"1" forKey:@"replyType"];
            }
        }
        
        if (fPid.length > 0) {
            [params setValue:fPid forKey:@"replyPid"];
        }
        
        // 评论来源统计(关闭)
        if (refer > 0) {
            [params setValue:[NSString stringWithFormat:@"%zd", refer] forKey:@"refer"];
        }
        
        if (sendImage != nil) {
            NSData* data = UIImageJPEGRepresentation(sendImage, 0.8f);
            self.sendImageData = data;
            if (data) {
                [params setValue:@"img" forKey:@"contType"];
            }
        }
        else if (sendAudioPath && [[NSFileManager defaultManager] fileExistsAtPath:sendAudioPath]) {
            NSData* data = [NSData dataWithContentsOfFile:sendAudioPath];
            self.sendAudioData = data;
            if (data) {
                [params setValue:@"aud" forKey:@"contType"];
            }
        }
        else {
            [params setValue:@"text" forKey:@"contType"];
        }
        self.parametersDict = params;
    }
    return self;
}

- (instancetype)initWithDictionary:(NSDictionary *)dict withCommentImageData:(NSData *)imageData andCommentAudioData:(NSData *)audioData
{
    self = [super initWithDictionary:dict];
    if (self) {
        self.needNetSafeParameters = YES;
        
        self.sendImageData = imageData;
        self.sendAudioData = audioData;
        
        if (imageData != nil) {
            [self.parametersDict setValue:@"img" forKey:@"contType"];
        }
        if (audioData != nil) {
            [self.parametersDict setValue:@"aud" forKey:@"contType"];
        }
    }
    return self;
}

- (instancetype)initWithDictionary:(NSDictionary *)dict
{
    self = [super initWithDictionary:dict];
    if (self) {
        self.needNetSafeParameters = YES;
    }
    return self;
}


#pragma mark - SNRequestProtocol

- (SNRequestMethod)sn_requestMethod {
    return SNRequestMethodUpload;
}

- (NSString *)sn_requestUrl {
    return SNLinks_Path_Comment_UserComment;
}

- (id)sn_parameters {
    NSString *passport = [SNUserManager getUserId];
    if (passport.length > 0) {
        [self.parametersDict setValue:passport forKey:kPassport];
    }
    return [super sn_parameters];
}

- (NSString *)sn_requestWithNewManager {
    return SNNet_Request_CommentManager;
}

- (void)sn_appendFileDataWith:(id<AFMultipartFormData>)formData {
    
    if (self.sendImageData) {
        [formData appendPartWithFileData:self.sendImageData name:@"comtFile" fileName:@"commentFile" mimeType:@"image/jpeg"];
    }
    if (self.sendAudioData) {
        [formData appendPartWithFileData:self.sendAudioData name:@"comtFile" fileName:@"commentFile" mimeType:@"audio/basic"];
    }
}

@end
