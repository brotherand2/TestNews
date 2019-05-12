
//
//  SNComposeCommentController.m
//  sohunews
//
//  Created by Dan on 6/16/11.
//  Copyright 2011 Sohu.com Inc. All rights reserved.
//

#import "SNPostCommentService.h"
#import "SNNotificationCenter.h"
#import "SNDBManager.h"
//#import "SNURLJSONResponse.h"
#import "SNPostFollow.h"
#import "SNStatusBarMessageCenter.h"
//#import "NSObject+YAJL.h"
#import "SNPostConmentRequest.h"
#import "SNNewsComment.h"
//#import "ASIFormDataRequest.h"
//#import "UIImage+MultiFormat.h"
#import "SNSendCommentObject.h"
#import "SNCommentConfigs.h"
#import "SNUserManager.h"
//#import "SNPostCommentOperation.h"

#import "SNSLib.h"
#import "SNMySDK.h"
static SNPostCommentService *__instance = nil;
//#define SNPOSTCOMMENT_QUEUE_MAX     10

@implementation SNPostCommentService

///////////////////////////////////////////////////////////////////////////////////////////////////
+ (SNPostCommentService *)shareInstance {
    static dispatch_once_t oneToken;
    dispatch_once(&oneToken, ^{
        __instance = [[super allocWithZone:NULL] init];
    });
    return __instance;
}

//- (void)dealloc {
//     //(_newsLink);
//}

#pragma mark - Singleton
+ (id)allocWithZone:(NSZone *)zone {
    return [self shareInstance];
}

- (id)copyWithZone:(NSZone *)zone {
    return self;
}

- (id)init {
    if (__instance) {
        return __instance;
    }

    return self;
}


- (void)saveCommentToServer:(SNSendCommentObject *)cmtObj
{
    if (![SNUtility getApplicationDelegate].isNetworkReachable) {
        [SNNotificationCenter showExclamation:NSLocalizedString(@"network error", @"")];
    } else {
        [self saveCommentToServerInNewThread:cmtObj];
    }
}

- (void)saveCommentToServerInNewThread:(SNSendCommentObject *)cmtObj
{
    
    NewsCommentItem *cmtItem = [self makeCacheComment:cmtObj];
    
//    request.userInfo = [NSDictionary dictionaryWithObjectsAndKeys:@(cmtObj.comtProp), @"commentType",
//                        cmtItem, @"newsCommentItem", nil];
    
    self.newsLink = cmtObj.replyComment.newsLink;
    
//    [self startPostOprationWithRequest:request obj:cmtObj];
    if (cmtObj && cmtObj != self.commentObj) {
        _commentObj = cmtObj;
    }
    [[[SNPostConmentRequest alloc] initWithCommentObject:cmtObj andRefer:_refer] send:^(SNBaseRequest *request, id responseObject) {
        
        BOOL bSuccess = NO;
        NSString *errCode = nil;
        
        if (responseObject && [responseObject isKindOfClass:[NSDictionary class]]) {
            SNDebugLog(@"%@", responseObject);
            
            NSString *isSuccess = [responseObject stringValueForKey:@"isSuccess" defaultValue:nil];
            errCode = [responseObject stringValueForKey:@"error" defaultValue:@"messageSendFailed"];
            if ([isSuccess caseInsensitiveCompare:@"S"] == NSOrderedSame) {
                bSuccess = YES;
                NSDictionary *response = [responseObject dictionaryValueForKey:@"response" defalutValue:nil];
                NSString *userCommentId = [response stringValueForKey:@"userCommentId" defaultValue:nil];
                NewsCommentItem *newsCommentItem = cmtItem;
                if (newsCommentItem && userCommentId) {
                    SNDebugLog(@"%@", userCommentId);
                    newsCommentItem.userComtId = userCommentId;
                    newsCommentItem.commentId = userCommentId;
                    [SNNotificationManager postNotificationName:kPostCommentSuccessNotifiaction
                                                         object:newsCommentItem];
                }
            } else if ([isSuccess caseInsensitiveCompare:@"F"] == NSOrderedSame) {
                bSuccess = NO;
            }
        }
        
        SNCmtPropType propType = cmtObj.comtProp;
        if (bSuccess) {
            if (propType == SNCmtPropTypeTrendUgc) {
                [[SNCenterToast shareInstance] showCenterToastWithTitle:@"动态发表成功"
                                                                  toUrl:nil
                                                                   mode:SNCenterToastModeSuccess];
            } else {
                [SNUtility requestRedPackerAndCoupon:[self.newsLink URLEncodedString] type:@"3"];
                
                [[SNCenterToast shareInstance] showCenterToastToProfileViewWithTitle:NSLocalizedString(@"messageSent", @"messageSent") toProfile:!cmtObj.isNovelComment userInfo:nil mode:SNCenterToastModeSuccess callBack:^{
                    NSString *pid = [SNUserManager getPid];
                    NSString *passport = [SNUserManager getUserId];
                    NSDictionary *arg = @{
                                          @"pid":pid?pid:@"",
                                          @"profileUserId":passport?passport:@"",
                                          @"type":kProtocolUserInfoProfile,
                                          @"fromPush":@"0"
                                          };
                    NSMutableDictionary * referInfo = [NSMutableDictionary dictionary];
                    
                    if (self.commentObj.newsId.length > 0) {
                        [referInfo setObject:self.commentObj.newsId forKey:kReferValue];
                        [referInfo setObject:@"Newsid" forKey:kReferType];
                    }
                    if (self.commentObj.gid.length > 0) {
                        [referInfo setObject:self.commentObj.gid forKey:kReferValue];
                        [referInfo setObject:@"gid" forKey:kReferType];
                    }
                    [referInfo setObject:[NSNumber numberWithInt:SNProfileRefer_Article_CommentUser] forKey:kRefer];
                    
                    [referInfo setValuesForKeysWithDictionary:arg];
                    
                    [SNSLib pushToProfileViewControllerWithDictionary:referInfo];
                    [[SNMySDK sharedInstance] updateAppTheme];
                    
                }];
            }
        } else {
            if (propType == SNCmtPropTypeTrendUgc) {
                [[SNCenterToast shareInstance] showCenterToastWithTitle:@"动态发表失败" toUrl:nil mode:SNCenterToastModeSuccess];
            }
            if (errCode && errCode.length > 0) {
                [[SNCenterToast shareInstance] showCenterToastWithTitle:NSLocalizedString(errCode, errCode) toUrl:nil mode:SNCenterToastModeOnlyText];
            } else {
                [[SNCenterToast shareInstance] showCenterToastWithTitle:NSLocalizedString(@"messageSendFailed", @"messageSendFailed") toUrl:nil mode:SNCenterToastModeOnlyText];
            }
        }

    } failure:^(SNBaseRequest *request, NSError *error) {
        [[SNCenterToast shareInstance] showCenterToastWithTitle:NSLocalizedString(@"messageSendFailed", @"messageSendFailed") toUrl:nil mode:SNCenterToastModeOnlyText];
    }];
}

- (NewsCommentItem *)makeCacheComment:(SNSendCommentObject *)cmtObj
{
    NewsCommentItem *newsCommentItem = [[NewsCommentItem alloc] init];
    newsCommentItem.newsId = (cmtObj.newsId ? cmtObj.newsId : (cmtObj.gid ? cmtObj.gid : cmtObj.topicId));
    newsCommentItem.author = [SNPostFollow currentUserName];
    newsCommentItem.channelId = cmtObj.channelId ? cmtObj.channelId : @"";
    //2017-03-25 wangchuanwen 5.8.7 begin
    //小说要传毫秒，而正文页传秒(正文页的评论时间和H5单独给iOS做处理了)
    if (cmtObj.isNovelComment) {
        newsCommentItem.ctime  = [NSString stringWithFormat:@"%f", [[NSDate date] timeIntervalSince1970]*1000];
    } else {
        newsCommentItem.ctime  = [NSString stringWithFormat:@"%d", (long long int)[[NSDate date] timeIntervalSince1970]];
    }
    //2017-03-25 wangchuanwen 5.8.7 end

    newsCommentItem.imagePath = cmtObj.cmtImagePath;
    
    if ([SNUserManager getHeadImageUrl]) {
        newsCommentItem.authorImage = [SNUserManager getHeadImageUrl];
    }
    newsCommentItem.passport = [SNUserManager getUserId];
    newsCommentItem.pid      = [SNUserManager getPid] ? [SNUserManager getPid] : @"";
    NSMutableDictionary *commentDic = [NSMutableDictionary dictionary];
    [commentDic setObject:newsCommentItem.ctime forKey:@"ctime"];
    if ([cmtObj.cmtText length] > 0) {
        [commentDic setObject:cmtObj.cmtText forKey:@"content"];
    }
    [commentDic setObject:newsCommentItem.author forKey:@"author"];
    [commentDic setObject:newsCommentItem.authorImage ? newsCommentItem.authorImage : @"" forKey:kAuthorimg];
    [commentDic setObject:newsCommentItem.passport ? newsCommentItem.passport : @"" forKey:kPassport];
    [commentDic setObject:cmtObj.cmtImagePath ? cmtObj.cmtImagePath : @"" forKey:kCommentImageSmall];
    [commentDic setObject:cmtObj.cmtImagePath ? cmtObj.cmtImagePath : @"" forKey:kCommentImageBig];
    [commentDic setObject:cmtObj.cmtImagePath ? cmtObj.cmtImagePath : @"" forKey:kCommentImage];
    
    if (cmtObj.cmtAudioPath) {
        [commentDic setObject:cmtObj.cmtAudioPath forKey:kCommentAudUrl];
        newsCommentItem.audioPath = cmtObj.cmtAudioPath;
    }
    if (cmtObj.cmtAudioDuration) {
        [commentDic setObject:cmtObj.cmtAudioDuration forKey:kCommentAudLen];
        newsCommentItem.audioDuration = cmtObj.cmtAudioDuration;
    }
    
    if (cmtObj.replyComment.floors.count > 0) {
        NSMutableArray *array = [NSMutableArray array];
        for (SNNewsComment *floorComment in cmtObj.replyComment.floors) {
            NSNumber *digNum = floorComment.digNum ? [NSNumber numberWithInt:[floorComment.digNum intValue]] : [NSNumber numberWithInt:0];
            NSNumber *replyNum = floorComment.replyNum ? [NSNumber numberWithInt:[floorComment.digNum intValue]] : [NSNumber numberWithInt:0];
            NSMutableDictionary *floorDic = [NSMutableDictionary dictionary];
            
            [floorDic setObject:floorComment.ctime ? floorComment.ctime : @"" forKey:@"ctime"];
            [floorDic setObject:floorComment.content ? floorComment.content : @"" forKey:@"content"];
            [floorDic setObject:floorComment.author ? floorComment.author : kDefaultUserName forKey:@"author"];
            [floorDic setObject:floorComment.topicId ? floorComment.topicId : @"" forKey:@"topicId"];
            [floorDic setObject:floorComment.from ? floorComment.from : @"" forKey:@"from"];
            [floorDic setObject:digNum forKey:@"digNum"];
            [floorDic setObject:replyNum forKey:@"replyNum"];
            [floorDic setObject:floorComment.city ? floorComment.city : @"" forKey:@"city"];
            [floorDic setObject:floorComment.commentId ? floorComment.commentId : @"" forKey:@"commentId"];
            [floorDic setObject:floorComment.commentImageSmall ? floorComment.commentImageSmall : @"" forKey:kCommentImageSmall];
            [floorDic setObject:floorComment.commentImage ? floorComment.commentImage : @"" forKey:kCommentImage];
            [floorDic setObject:floorComment.commentImageBig ? floorComment.commentImageBig : @"" forKey:kCommentImageBig];
            [floorDic setObject:floorComment.commentAudLen ? [NSNumber numberWithInt:floorComment.commentAudLen] : [NSNumber numberWithInt:0] forKey:kCommentAudLen];
            [floorDic setObject:floorComment.commentAudUrl ? floorComment.commentAudUrl : @"" forKey:kCommentAudUrl];
            [floorDic setObject:floorComment.pid ? floorComment.pid : @"" forKey:kPid];
            [array addObject:floorDic];
        }
        [commentDic setObject:array forKey:@"floors"];
        newsCommentItem.content = [commentDic translateDictionaryToJsonString];
        newsCommentItem.type = @"reply";
    } else {
        newsCommentItem.content = cmtObj.cmtText;
        newsCommentItem.type = @"";
    }
    
    SNDebugLog(@"newsCommentItem.content %@", newsCommentItem.content);
    
    return newsCommentItem;
}

//- (void)notificateUserCenter
//{
//    [SNNotificationManager postNotificationName:NotificationAudioSend object:nil];
//}

@end

