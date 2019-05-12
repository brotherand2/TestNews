//
//  SNLiveInviteModel.m
//  sohunews
//
//  Created by chenhong on 13-12-10.
//  Copyright (c) 2013年 Sohu.com. All rights reserved.
//

#import "SNLiveInviteModel.h"
//#import "SNURLJSONResponse.h"
//#import "ASIFormDataRequest.h"
//#import "NSObject+YAJL.h"
#import "DesBase64EncryptUtil.h"
#import "SNUserManager.h"
#import "SNLiveInviteStatusRequest.h"
#import "SNLiveInviteAnswerRequest.h"

#define kInviteStatusTag    1
#define kInviteFeedbackTag  2

#define kPassportEncryptKey @"sohunews"


@implementation SNLiveInviteStatusObj

- (id)initWithDict:(NSDictionary *)dict {
    self = [super init];
    if (self) {
        _liveId     = [[dict stringValueForKey:@"liveId" defaultValue:nil] copy];
        _passport   = [[dict stringValueForKey:@"passport" defaultValue:nil] copy];
        _showmsg    = [[dict stringValueForKey:@"showMsg" defaultValue:nil] copy];
        _inviteStatus = [NSNumber numberWithInt:[dict intValueForKey:@"inviteStatus" defaultValue:0]];
    }
    return self;
}


- (NSString *)description {
    return [NSString stringWithFormat:@"liveId: %@ passport: %@ showmsg: %@ inviteStatus: %@",
            _liveId, _passport, _showmsg, _inviteStatus];
}

@end

@implementation SNLiveInviteModel {
//    SNURLRequest *_inviteStatusRequest;
//    ASIFormDataRequest *_inviteFeedbackRequest;
}

- (void)dealloc {
    [[TTURLRequestQueue mainQueue] cancelRequestsWithDelegate:self];
//    [_inviteStatusRequest cancel];
     //(_inviteStatusRequest);

//    [_inviteFeedbackRequest setDelegate:nil];
     //(_inviteFeedbackRequest);
    
    
}

//- (void)requestInviteStatusByLiveId:(NSString *)liveId passport:(NSString *)passport {
//    if (_inviteStatusRequest) {
//        [_inviteStatusRequest cancel];
//    }
//    
//    NSString *url = [NSString stringWithFormat:SNLinks_Path_Live_InviteStatus, liveId, passport];
//    if (_userInfo) {
//        NSString *params = [_userInfo toUrlString];
//        if (params.length > 0) {
//            url = [url stringByAppendingFormat:@"%@", params];
//        }
//    }
//    _inviteStatusRequest = [SNURLRequest requestWithURL:url delegate:self];
//    _inviteStatusRequest.cachePolicy = TTURLRequestCachePolicyNoCache;
//    _inviteStatusRequest.isShowNoNetWorkMessage = YES;
//    _inviteStatusRequest.response = [[SNURLJSONResponse alloc] init];
//    _inviteStatusRequest.userInfo = @(kInviteStatusTag);
//    [_inviteStatusRequest send];
//}
// ?liveId=%@&passport=%@
- (void)requestInviteStatusByLiveId:(NSString *)liveId passport:(NSString *)passport {
    if (![SNUtility getApplicationDelegate].isNetworkReachable) {
        [SNNotificationCenter showExclamation:NSLocalizedString(@"network error", @"")];
        return;
    }
    
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithCapacity:2];
    [params setValue:liveId forKey:@"liveId"];
    [params setValue:passport forKey:@"passport"];
    [_userInfo enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        if ([key isKindOfClass:[NSString class]] && [key isEqualToString:kOpenProtocolOriginalLink2]) {
            return;
        }
        [params setValue:obj forKey:key];
    }];
    
    [[[SNLiveInviteStatusRequest alloc] initWithDictionary:params] send:^(SNBaseRequest *request, id responseObject) {
        BOOL bOK = NO;
        SNLiveInviteStatusObj *statusObj = nil;
        
        if ([responseObject isKindOfClass:[NSDictionary class]]) {
            NSDictionary *root = responseObject;
            NSString *isSuccess = [root stringValueForKey:@"isSuccess" defaultValue:nil];
            if ([isSuccess caseInsensitiveCompare:@"S"] == NSOrderedSame) {
                bOK = YES;
                NSDictionary *response = [root objectForKey:@"response"];
                if ([response isKindOfClass:[NSDictionary class]]) {
                    statusObj = [[SNLiveInviteStatusObj alloc] initWithDict:response];
                }
            }
        }
        
        if (bOK) {
            if ([_delegate respondsToSelector:@selector(requestInviteStatusFinished:)]) {
                [_delegate requestInviteStatusFinished:statusObj];
            }
        } else {
            if ([_delegate respondsToSelector:@selector(requestInviteStatusFailedWithError:)]) {
                [_delegate requestInviteStatusFailedWithError:nil];
            }
        }

    } failure:^(SNBaseRequest *request, NSError *error) {
        if ([_delegate respondsToSelector:@selector(requestInviteStatusFailedWithError:)]) {
            [_delegate requestInviteStatusFailedWithError:error];
        }
    }];
}

//直播邀请应答
//- (void)sendInviteFeedback:(SNLiveInviteFeedbackEnum)feedback
//                withLiveId:(NSString *)liveId
//                  passport:(NSString *)passport {
//    
//    NSString *pid = [SNUserManager getPid];
//    NSString *p1 = [SNUserManager getP1];
//    
//    [_inviteFeedbackRequest setDelegate:nil];
//     //(_inviteFeedbackRequest);
//    
//    ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:[NSURL URLWithString:SNLinks_Path_Live_InviteAnswer]];
//    request.timeOutSeconds = 30;
//    [request setNumberOfTimesToRetryOnTimeout:3];
//    request.delegate = self;
//    if (p1) {
//        [request addPostValue:p1 forKey:@"p1"];
//        SNDebugLog(@"p1 = %@", p1);
//    }
//    if (pid) {
//        [request addPostValue:pid forKey:@"pid"];
//        SNDebugLog(@"pid = %@", pid);
//    }
//    if (passport.length > 0) {
//        NSString *passportEnc = [DesBase64EncryptUtil encryptWithText:passport key:kPassportEncryptKey];
//        [request addPostValue:passportEnc forKey:kPassport];
//        SNDebugLog(@"passport = %@\t enc = %@", passport, passportEnc);
//    }
//    if (liveId.length) {
//        [request addPostValue:liveId forKey:@"liveId"];
//        SNDebugLog(@"liveId = %@", liveId);
//    }
//    [request addPostValue:[NSString stringWithFormat:@"%d", feedback] forKey:@"invtAnsr"];
//    SNDebugLog(@"invtAnsr = %d", feedback);
//
//    [request startAsynchronous];
//    
//    _inviteFeedbackRequest = request;
//}

- (void)sendInviteFeedback:(SNLiveInviteFeedbackEnum)feedback
                withLiveId:(NSString *)liveId
                  passport:(NSString *)passport {
    
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithCapacity:3];
    if (passport.length > 0) {
        NSString *passportEnc = [DesBase64EncryptUtil encryptWithText:passport key:kPassportEncryptKey];
        [params setValue:passportEnc forKey:kPassport];
        SNDebugLog(@"passport = %@\t enc = %@", passport, passportEnc);
    }
    if (liveId.length) {
        [params setValue:liveId forKey:@"liveId"];
        SNDebugLog(@"liveId = %@", liveId);
    }
    [params setValue:[NSString stringWithFormat:@"%d", feedback] forKey:@"invtAnsr"];
    SNDebugLog(@"invtAnsr = %d", feedback);

    [[[SNLiveInviteAnswerRequest alloc] initWithDictionary:params] send:^(SNBaseRequest *request, id rootData) {

        BOOL bSuccess = NO;
        NSString *errCode = nil;
        SNLiveInviteStatusObj *statusObj = nil;
        
        if (rootData && [rootData isKindOfClass:[NSDictionary class]]) {
            SNDebugLog(@"%@", rootData);
            NSString *isSuccess = [rootData stringValueForKey:@"isSuccess" defaultValue:nil];
            if ([isSuccess caseInsensitiveCompare:@"S"] == NSOrderedSame) {
                bSuccess = YES;
                SNDebugLog(@"success");
                NSDictionary *response = [rootData objectForKey:@"response"];
                if ([response isKindOfClass:[NSDictionary class]]) {
                    statusObj = [[SNLiveInviteStatusObj alloc] initWithDict:response];
                    SNDebugLog(@"statusObj %@", statusObj);
                }
            } else if ([isSuccess caseInsensitiveCompare:@"F"] == NSOrderedSame) {
                bSuccess = NO;
                errCode = [rootData stringValueForKey:@"error" defaultValue:nil];
                SNDebugLog(@"fail %@", errCode);
            }
        }
        
        if (bSuccess) {
            if ([_delegate respondsToSelector:@selector(sendInviteFeedbackFinished:)]) {
                [_delegate sendInviteFeedbackFinished:statusObj];
            }
        } else {
            if ([_delegate respondsToSelector:@selector(sendInviteFeedbackFailedWithError:)]) {
                [_delegate sendInviteFeedbackFailedWithError:nil];
            }
        }

    } failure:^(SNBaseRequest *request, NSError *error) {
        if ([_delegate respondsToSelector:@selector(sendInviteFeedbackFailedWithError:)]) {
            [_delegate sendInviteFeedbackFailedWithError:nil];
        }
    }];
}

//#pragma mark - TTURLRequestDelegate
//- (void)requestDidFinishLoad:(TTURLRequest*)request {
//    BOOL bOK = NO;
//    SNLiveInviteStatusObj *statusObj = nil;
//    
//    SNURLJSONResponse *json = request.response;
//    SNDebugLog(@"%@", json.rootObject);
//    if ([json.rootObject isKindOfClass:[NSDictionary class]]) {
//        NSDictionary *root = json.rootObject;
//        NSString *isSuccess = [root stringValueForKey:@"isSuccess" defaultValue:nil];
//        if ([isSuccess caseInsensitiveCompare:@"S"] == NSOrderedSame) {
//            bOK = YES;
//            NSDictionary *response = [root objectForKey:@"response"];
//            if ([response isKindOfClass:[NSDictionary class]]) {
//                statusObj = [[SNLiveInviteStatusObj alloc] initWithDict:response];
//            }
//        }
//    }
//    
//    if ([request.userInfo integerValue] == kInviteStatusTag) {
//        if (bOK) {
//            if ([_delegate respondsToSelector:@selector(requestInviteStatusFinished:)]) {
//                [_delegate requestInviteStatusFinished:statusObj];
//            }
//        } else {
//            if ([_delegate respondsToSelector:@selector(requestInviteStatusFailedWithError:)]) {
//                [_delegate requestInviteStatusFailedWithError:nil];
//            }
//        }
//    } else if ([request.userInfo integerValue] == kInviteFeedbackTag) {
//        
//    }
//}

//- (void)request:(TTURLRequest*)request didFailLoadWithError:(NSError*)error {
//    if ([request.userInfo integerValue] == kInviteStatusTag) {
//        if ([_delegate respondsToSelector:@selector(requestInviteStatusFailedWithError:)]) {
//            [_delegate requestInviteStatusFailedWithError:error];
//        }
//    } else if ([request.userInfo integerValue] == kInviteFeedbackTag) {
//        if ([_delegate respondsToSelector:@selector(sendInviteFeedbackFailedWithError:)]) {
//            [_delegate sendInviteFeedbackFailedWithError:error];
//        }
//    }
//}

//#pragma mark - asi delegate
//
//- (void)requestFinished:(ASIHTTPRequest *)request {
//    SNDebugLog(@"%d, %@", request.responseStatusCode, request.responseString);
//    BOOL bSuccess = NO;
//    NSString *errCode = nil;
//    SNLiveInviteStatusObj *statusObj = nil;
//    
//    NSString *jsonString = [[request responseString] copy];
//    NSData *jsonData = [jsonString dataUsingEncoding:NSUTF8StringEncoding];
//    id rootData = [jsonData yajl_JSON];
//    
//    if (rootData && [rootData isKindOfClass:[NSDictionary class]]) {
//        SNDebugLog(@"%@", rootData);
//        NSString *isSuccess = [rootData stringValueForKey:@"isSuccess" defaultValue:nil];
//        if ([isSuccess caseInsensitiveCompare:@"S"] == NSOrderedSame) {
//            bSuccess = YES;
//            SNDebugLog(@"success");
//            NSDictionary *response = [rootData objectForKey:@"response"];
//            if ([response isKindOfClass:[NSDictionary class]]) {
//                statusObj = [[SNLiveInviteStatusObj alloc] initWithDict:response];
//                SNDebugLog(@"statusObj %@", statusObj);
//            }
//        } else if ([isSuccess caseInsensitiveCompare:@"F"] == NSOrderedSame) {
//            bSuccess = NO;
//            errCode = [rootData stringValueForKey:@"error" defaultValue:nil];
//            SNDebugLog(@"fail %@", errCode);
//        }
//    }
//    
//    if (bSuccess) {
//        if ([_delegate respondsToSelector:@selector(sendInviteFeedbackFinished:)]) {
//            [_delegate sendInviteFeedbackFinished:statusObj];
//        }
//    } else {
//        if ([_delegate respondsToSelector:@selector(sendInviteFeedbackFailedWithError:)]) {
//            [_delegate sendInviteFeedbackFailedWithError:nil];
//        }
//    }
//}
//
//- (void)requestFailed:(ASIHTTPRequest *)request {
//    SNDebugLog(@"%d, %@", request.responseStatusCode, request);
//    if ([_delegate respondsToSelector:@selector(sendInviteFeedbackFailedWithError:)]) {
//        [_delegate sendInviteFeedbackFailedWithError:nil];
//    }
//}


@end
