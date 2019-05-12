//
//  SNInterceptConfigManager.m
//  sohunews
//
//  Created by jojo on 13-12-6.
//  Copyright (c) 2013年 Sohu.com. All rights reserved.
//

#import "SNInterceptConfigManager.h"
#import "SNURLJSONResponse.h"
#import "SNShareManager.h"
#import "SNActionSheetLoginManager.h"
#import "SNUserManager.h"
#import "SNActionInterceptRequest.h"

/** intercept config dic structure
 
 {
 
    result: {
        code: "200",
        msg: "success"
    },
 
    global:{
        switch:"1"                                              ----- 是否开启用户行为拦截的功能 全局开关
    },
 
    actionList:
    [
 
        {
 
            id: 1111
            actionType: 0,
            message: "评论前请先登录,评论前请先登录",
            actionLink: "1001,1002",
        },
 
        {
 
            id: 2222
            actionType: 1,
            message: "评论前请先登录,评论前请先登录",
            actionLink: "http://3g.k.sohu.com,sub://subId=107",
        }
 
    ]
 
 }
 
 */

/** 按钮映射表：
 
 buttonId	desc
 1101	搜索结果订阅按钮
 1102	摇一摇订阅按钮
 1103	订阅中心订阅按钮
 1104	刊物首页订阅按钮
 1105	新闻正文页订阅按钮
 1106	进入订阅广场
 1201	正文页评论
 1202	组图浏览模式评论
 1203	微闻评论
 1204	直播间边看边聊
 1205	写媒体刊物的评论
 1206	刊物info页评论按钮
 1301	一键离线按钮
 1302	刊物首页离线按钮
 1401	新闻编辑频道
 1402	视频编辑频道
 1501	使用摇一摇
 
 */

/**功能映射表：
 
 功能Id	desc
 f101	弹出半屏登录框
 f102	直接自动sso登录

 */

#define kUserActionInterceptConfigFileName                    (@"snuaic.plist")

extern SNURLRequest * configuredVideoRequest(NSString *url, id delegate, id userInfo);

@interface SNInterceptConfigManager ()<SNShareManagerDelegate>

@property (nonatomic, strong) NSMutableDictionary *configDic;
@property (nonatomic, weak) SNURLRequest *configRefreshRequest;
@property (nonatomic, strong) NSDictionary *actionIdInfoDic;
@property (nonatomic, strong) SNActionInterceptRequest *refreshConfigRequest;

@end

@implementation SNInterceptConfigManager
@synthesize configDic = _configDic;
@synthesize configRefreshRequest = _configRefreshRequest;
@synthesize actionIdInfoDic = _actionIdInfoDic;

+ (SNInterceptConfigManager *)sharedManager {
    static SNInterceptConfigManager *__sInstance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        __sInstance = [[[self class] alloc] init];
    });
    return __sInstance;
}

- (void)dealloc {
     //(_configDic);
     //(_actionIdInfoDic);
    
    if (_configRefreshRequest) {
        [_configRefreshRequest.delegates removeObject:self];
        [_configRefreshRequest cancel];
         //(_configRefreshRequest);
    }
}

// 初始化本地配置
+ (void)initConfig {
    NSString *filePath = [self configFilePath];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if ([fileManager fileExistsAtPath:filePath]) {
        [[SNInterceptConfigManager sharedManager] reloadConfig:filePath];
    }
}

// 与服务端同步最新的配置
+ (void)refreshConfig {
    [[SNInterceptConfigManager sharedManager] refreshConfig];
}

- (NSDictionary *)actionIdInfoDic {
    if (!_actionIdInfoDic) {
        // actionId -- selector
        _actionIdInfoDic = [[NSDictionary alloc] initWithObjectsAndKeys:
                            kUserActionIdForEnterSubCenterAction, @"goToSubscribeCenter",
                            nil];
    }
    return _actionIdInfoDic;
}

- (BOOL)isActionInterceptEnable {
    if (self.configDic) {
        NSDictionary *globalDic = [self.configDic dictionaryValueForKey:kUserActionInterceptInfoKeyGlobal defalutValue:nil];
        if (globalDic) {
            return [[globalDic stringValueForKey:kUserActionInterceptInfoKeySwitch defaultValue:nil] isEqualToString:@"1"];
        }
    }
    return NO;
}

- (SNUserActionInterceptType)handleActionInterceptActionId:(NSString *)actionId {
    SNUserActionInterceptType type = SNUserActionInterceptTypeDontIntercept;
    
    if ((![SNUserManager isLogin] && [self isActionInterceptEnable]) || [self whetherBindMobileNum:actionId]) {
        
        type = [self userActionInterceptTypeWithActionId:actionId];
        
        if (type == SNUserActionInterceptTypeClientAction) {
            [[SNInterceptConfigManager sharedManager] doClientActionForActionId:actionId];
        }
        else if (type == SNUserActionInterceptTypeOpenLink) {
            [[SNInterceptConfigManager sharedManager] openActionLinkForActionId:actionId];
        }
        
        // 只要进行过登陆拦截服务端置顶的操作 把登录引导保存的成功之后的操作给清理掉
        [[SNActionSheetLoginManager sharedInstance] cleanGuideType];
    }
    
    return type;
}

- (SNUserActionInterceptType)userActionInterceptTypeWithActionId:(NSString *)actionId {
    
    NSDictionary *actInfo = [self actionInfoForActionId:actionId];
    
    if (actInfo) {
        int type = [actInfo intValueForKey:kUserActionInterCeptInfoKeyActionType defaultValue:-1];
        
        if (type == 1) {
            return SNUserActionInterceptTypeClientAction;
        }
        else if (type == 2) {
            return SNUserActionInterceptTypeOpenLink;
        }
    }
    return SNUserActionInterceptTypeDontIntercept;
}

- (BOOL)whetherBindMobileNum:(NSString *)actionID {
//    SNUserinfoEx *userInfoEx = [SNUserinfoEx userinfoEx];
//    if (userInfoEx.isRealName) {
//        return NO;
//    }
    NSDictionary *actInfo = [self actionInfoForActionId:actionID];
    
    if (actInfo) {
        NSString *actionLink = [actInfo objectForKey:kUserActionInterCeptInfoKeyActionLink];
        if ([actionLink isEqualToString:kUserActionInterceptClientActionBindMobileNum])
            return YES;
    }
    return NO;
}

// 需要打开跳转连接的拦截
- (void)openActionLinkForActionId:(NSString *)actionId {
    NSDictionary *actDic = [self actionInfoForActionId:actionId];
    if (actDic) {
        NSString *actionLink = [actDic stringValueForKey:kUserActionInterCeptInfoKeyActionLink defaultValue:nil];
        if (actionLink) {
            [SNUtility openProtocolUrl:actionLink context:nil];
        }
    }
}

// 直接进行拦截后续操作
- (void)doClientActionForActionId:(NSString *)actionId {
    NSDictionary *actDic = [self actionInfoForActionId:actionId];
    if (actDic) {
        NSString *actionLink = [actDic stringValueForKey:kUserActionInterCeptInfoKeyActionLink defaultValue:nil];
        if (actionLink) {
            NSArray *actions = [actionLink componentsSeparatedByString:@","];
            if ([actions count] > 0) {
                // 目前 只对第一个行为做响应
                NSString *actionTypeId = actions[0];
                NSString *msg = [actDic stringValueForKey:kUserActionInterCeptInfoKeyMessage defaultValue:@""];
                
                if ([actionTypeId isEqualToString:kUserActionInterceptClientActionGuideLogin]) {
                    // 弹半屏的登陆页面
                    [self showGuideLoginActionSheetWithMsg:msg];
                }
                else if ([actionTypeId isEqualToString:kUserActionInterceptClientActionDoSSO]) {
                    // 直接进行sso登陆
                }
                else if ([actionTypeId isEqualToString:kUserActionInterceptClientActionBindMobileNum]) {
                    //弹出手机号绑定框（未绑定过才会下发）
                    NSDictionary* dic = [NSDictionary dictionaryWithObjectsAndKeys:@"手机绑定", @"headTitle", @"立即绑定", @"buttonTitle", actionId, @"staticFromPage", nil];
                    TTURLAction *_urlAction = [[[TTURLAction actionWithURLPath:@"tt://mobileNumBindLogin"] applyAnimated:YES] applyQuery:dic];
                    [[TTNavigator navigator] openURLAction:_urlAction];
                    
                    //CC统计
                    SNUserTrack *userTrack= [SNUserTrack trackWithPage:[actionId intValue] link2:nil];
                    NSString *paramString = [NSString stringWithFormat:kAnalyticsUrlCC, [userTrack toFormatString], [userTrack toFormatString], f_moblie_binding];
                    [SNNewsReport reportADotGifWithTrack:paramString];
                }
            }
        }
    }
}

#pragma mark - do actions
- (void)showGuideLoginActionSheetWithMsg:(NSString *)msg {
    
    SNActionSheet *actionSheet = [[SNActionSheet alloc] initWithTitle:@"登录"
                                                             delegate: nil
                                                            iconImage:[SNUtility chooseActDefaultIconImage]
                                                              content:msg
                                                           actionType:SNActionSheetTypeLogin
                                                    cancelButtonTitle:@"取消"
                                               destructiveButtonTitle:nil
                                                    otherButtonTitles:nil];
    [[TTNavigator navigator].window addSubview:actionSheet];
    [actionSheet showActionViewAnimation];
    
}

// if do sso , return YES
- (BOOL)doSSOLoginWithMsg:(NSString *)msg {
    // 优先用新浪微博 appId = 1 其次qq appId = 80  再者腾讯微博 appId = 2
    NSString *appId = @"1";
    if ([self trySSOLoginWithAppId:appId]) {
        return YES;
    }
    
    appId = kQQSSOLoginAppId;
    if ([self trySSOLoginWithAppId:appId]) {
        return YES;
    }
    
    appId = @"2";
    if ([self trySSOLoginWithAppId:appId]) {
        return YES;
    }
    
    [self showGuideLoginActionSheetWithMsg:msg];
    return NO;
}

#pragma mark - TTURLRequestDelegate
- (void)requestDidFinishLoad:(TTURLRequest*)request {
    if (request == self.configRefreshRequest) {
        SNURLJSONResponse *jsonResp = request.response;
        NSDictionary *jsonObj = [jsonResp rootObject];
        SNDebugLog(@"%@ - url %@ \n jsonData %@", NSStringFromClass([self class]), request.urlPath, jsonObj);
        BOOL bRetSuccess = NO;
        NSString *retMsg = @"";
        
        if (jsonObj && [jsonObj isKindOfClass:[NSDictionary class]]) {
            NSDictionary *resultInfo = [jsonObj dictionaryValueForKey:@"result" defalutValue:nil];
            if ([resultInfo longlongValueForKey:@"code" defaultValue:-1] == 200) {
                // 不用解析 直接把整个json 缓存
                self.configDic = [NSMutableDictionary dictionaryWithDictionary:jsonObj];
                
                // 缓存到文件
                [self saveConfigToLocalFile];
                
                bRetSuccess = YES;
            }
        }
        
        // error
        if (!bRetSuccess) {
            SNDebugLog(@"%@- refresh config failed with msg %@", NSStringFromClass([self class]), retMsg);
        }
        
        //clean request
        if (_configRefreshRequest) {
            [_configRefreshRequest.delegates removeObject:self];
            [_configRefreshRequest cancel];
             //(_configRefreshRequest);
        }
    }
}

- (void)request:(TTURLRequest*)request didFailLoadWithError:(NSError*)error {
    if (request == self.configRefreshRequest) {
        SNDebugLog(@"%@- refresh config failed with error %@", NSStringFromClass([self class]), [error localizedDescription]);
    }
}

- (void)requestDidCancelLoad:(TTURLRequest*)request {
    if (request == self.configRefreshRequest) {
        SNDebugLog(@"%@- refresh config canceled", NSStringFromClass([self class]));
    }
}

#pragma mark - SNShareManagerDelegate

- (void)shareManager:(SNShareManager *)manager wantToShowAuthView:(UIViewController *)authNaviController {
    // do nothing
}


- (void)shareManagerDidAuthAndLoginSuccess:(SNShareManager *)manager {
    [[SNCenterToast shareInstance] showCenterToastWithTitle:@"登录成功" toUrl:nil mode:SNCenterToastModeSuccess];
}

- (void)shareManagerDidCancelAuth:(SNShareManager *)manager {
    
}

- (void)shareManager:(SNShareManager *)manager didAuthFailedWithError:(NSError *) error {
    [[SNCenterToast shareInstance] showCenterToastWithTitle:@"登录失败" toUrl:nil mode:SNCenterToastModeError];
    
}

#pragma mark - private

- (BOOL)trySSOLoginWithAppId:(NSString *)appId {
    return [[SNShareManager defaultManager] loginByAppId:appId loginType:SNShareManagerAuthLoginTypeLogin delegate:self loginFrom:@""];
}

//- (void)refreshConfig {
//    if (self.configRefreshRequest && self.configRefreshRequest.isLoading) {
//        SNDebugLog(@"%@-%@ already requesting ", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
//        return;
//    }
//    
//    /*
//     version	字符串	接口版本号，当前为1.0
//     */
//    NSString *reqUrl = [SNUtility addProductIDIntoURL:SNLinks_Path_ActionIntercept];
//    reqUrl = [SNUtility addBundleIDIntoURL:reqUrl];
//    reqUrl = [self configRequestUrl:reqUrl];
//    
//    self.configRefreshRequest = configuredVideoRequest(reqUrl, self, nil);
//    [self.configRefreshRequest send];
//}

- (void)refreshConfig {
    if (self.refreshConfigRequest) {
        return;
    }
    self.refreshConfigRequest = [[SNActionInterceptRequest alloc] init];
    __weak typeof(self)weakself = self;
    [self.refreshConfigRequest send:^(SNBaseRequest *request, id jsonObj) {
        weakself.refreshConfigRequest = nil;
        
        if (jsonObj && [jsonObj isKindOfClass:[NSDictionary class]]) {
            NSDictionary *resultInfo = [jsonObj dictionaryValueForKey:@"result" defalutValue:nil];
            if ([resultInfo longlongValueForKey:@"code" defaultValue:-1] == 200) {
                // 不用解析 直接把整个json 缓存
                weakself.configDic = [NSMutableDictionary dictionaryWithDictionary:jsonObj];
                
                // 缓存到文件
                [weakself saveConfigToLocalFile];
            }
        }

    } failure:^(SNBaseRequest *request, NSError *error) {
        weakself.refreshConfigRequest = nil;
        SNDebugLog(@"%@",error.localizedDescription);
    }];
}

- (void)reloadConfig:(NSString *)configFilePath {
    self.configDic = nil;
    if (configFilePath.length > 0) {
        self.configDic = [NSMutableDictionary dictionaryWithContentsOfFile:configFilePath];
    }
}

+ (NSString *)configFilePath {
    NSArray *dirArr = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    if ([dirArr count] > 0) {
        return [(NSString *)dirArr[0] stringByAppendingPathComponent:kUserActionInterceptConfigFileName];
    }
    return nil;
}

- (NSDictionary *)actionInfoForActionId:(NSString *)actionId {
    NSDictionary *actionInfoFound = nil;
    if (self.configDic) {
        NSArray *actionList = [self.configDic arrayValueForKey:kUserActionInterceptInfoKeyActionList defaultValue:nil];
        for (NSDictionary *actDic in actionList) {
            if ([actDic isKindOfClass:[NSDictionary class]] &&
                [[actDic stringValueForKey:kUserActionInterCeptInfoKeyId defaultValue:nil] isEqualToString:actionId]) {
                actionInfoFound = [NSDictionary dictionaryWithDictionary:actDic];
                break;
            }
        }
    }
    return actionInfoFound;
}

- (NSString *)configRequestUrl:(NSString *)url {
    if (url.length > 0) {
        NSMutableString* mUrl = [NSMutableString stringWithString:url];
        
        if(![SNUserManager isLogin]) {
            [mUrl appendFormat:@"&token=%@", @"-1"];
        }
        else {
            if([SNUserManager getToken].length>0) {
                [mUrl appendFormat:@"&token=%@", [SNUserManager getToken]];
            }
        }
        
        // version
        [mUrl appendString:@"&version=1.0"];
        
        [mUrl appendFormat:@"&gid=%@",[SNUserManager getGid]];
        
        return mUrl;
    }
    
    return url;
}

- (void)saveConfigToLocalFile {
    if (self.configDic) {
        NSString *filePath = [[self class] configFilePath];
        
        if ([[NSFileManager defaultManager] fileExistsAtPath:filePath]) {
            NSError *error = nil;
            [[NSFileManager defaultManager] removeItemAtPath:filePath error:&error];
            if (error) {
                SNDebugLog(@"%@-delete old file fail with error = %@", NSStringFromSelector(_cmd), error);
                return;
            }
        }
        
        [self.configDic writeToFile:[[self class] configFilePath] atomically:YES];
    }
}

@end
