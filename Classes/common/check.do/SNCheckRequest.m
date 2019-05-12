//
//  SNCheckRequest.m
//  sohunews
//
//  Created by 李腾 on 2017/1/20.
//  Copyright © 2017年 Sohu.com. All rights reserved.
//

#import "SNCheckRequest.h"
#import "SNUserManager.h"
#import "SNClientRegister.h"
#import "SNNotifyService.h"
#import "SNSubscribeCenterDefines.h"

@implementation SNCheckRequest

#pragma mark - SNRequestProtocol

- (SNRequestMethod)sn_requestMethod {
    return SNRequestMethodGet;
}

- (SNResponseType)sn_responseType {
    return SNResponseTypeHTTP;
}

- (NSString *)sn_requestWithNewManager {
    return SNNet_Request_ResponseHttpManager;
}

- (NSString *)sn_requestUrl {
    return SNLinks_Path_Check;
}

- (NSArray *)sn_excessResponseSerializerAcceptableContentTypes {
    return @[@"text/plain"];
}

- (id)sn_parameters {
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithCapacity:20]; // 默认参数
  
    [params setValue:@"8" forKey:@"v"];
    [params setValue:[SNClientRegister sharedInstance].uid forKey:@"b"];
   
    int maxMsgid = [SNNotifyService getMaxMsgId];
    if (maxMsgid > -1) {
        [params setValue:[NSString stringWithFormat:@"%zd",maxMsgid] forKey:@"maxMsgId"];
    }
    //请求回复我的评论数
    SNUserinfoEx *userinfo = [SNUserinfoEx userinfoEx];
    NSString *toMeCommentId = nil;
    if ([SNUserManager getUserId]) {
        NSString *keyName = [NSString stringWithFormat:@"%@_%@", kADToMeCommentId,[userinfo getUsername]];
        if (userinfo.lastCommentId && [userinfo.lastCommentId length] > 0) {
            toMeCommentId = userinfo.lastCommentId;
        }
        
        if (!toMeCommentId && [userinfo getUsername]) {
            toMeCommentId = [[NSUserDefaults standardUserDefaults] valueForKey:keyName];
        }
        
        if (!toMeCommentId) {
            toMeCommentId = @"1";
            [[NSUserDefaults standardUserDefaults] setObject:toMeCommentId forKey:keyName];
            [[NSUserDefaults standardUserDefaults] synchronize];
        }
    } 
    [params setValue:(toMeCommentId != nil) ? toMeCommentId:@"1" forKey:@"commentId"];
    [params setValue:kCheckDoType forKey:@"checkType"];
    
    // "我的订阅" MySubscribe.go上次刷新返回的timestamp
    NSString *mysubTimestamp = [[NSUserDefaults standardUserDefaults] objectForKey:kSubMySubLastTimestampKey];
    if (mysubTimestamp.length) {
        [params setValue:mysubTimestamp forKey:@"subtabtime"];
    }
    
    // 表示接口不查询
    [params setValue:@"0" forKey:@"subtabstatus"];
    
    // 视频timeline precursor
    NSString *vcursor = [[NSUserDefaults standardUserDefaults] objectForKey:kVideoTimelinePrecursor];
    if (vcursor.length) {
        [params setValue:vcursor forKey:@"vcursor"];
    }
    
    //5.2 Add buildCode
    NSString *appBuild = [[[NSBundle mainBundle] infoDictionary] objectForKey:kBundleBuild];
    if (appBuild) {
        [params setValue:appBuild forKey:@"buildCode"];
    }
    [params setValue:[SNAPI productId] forKey:@"pl"]; // 这是什么鬼?
    
    [self.parametersDict setValuesForKeysWithDictionary:params];
    
    return [super sn_parameters];
}

@end
