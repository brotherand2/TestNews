//
//  SNShareManager.m
//  sohunews
//
//  Created by yanchen wang on 12-5-28.
//  Copyright (c) 2012年 Sohu.com Inc. All rights reserved.
//

#import "SNShareManager.h"
#import "SNURLJSONResponse.h"
#import "UIDevice-Hardware.h"
#import "SNSharePostController.h"
#import "SNShareWithCommentController.h"
#import "NSDictionaryExtend.h"
#import "SNStatusBarMessageCenter.h"
#import "CacheObjects.h"
#import "SNSSOAdapter.h"
#import "SNUserinfo.h"
#import "SNAlert.h"
#import "SNEncryptManager.h"
#import "SNWeatherCenter.h"
#import "SNOauthWebViewController.h"
#import "NSObject+YAJL.h"
#import "SNTimelineTrendObjects.h"
#import "SNAnalytics.h"
#import "SNUserManager.h"
#import "SNUserConsts.h"
#import "ASIFormDataRequest.h"
#import "SNUserUtility.h"
#import "SNShareConfigs.h"
#import "SNShareV4UploadRequest.h"
#import <TencentOpenAPI/QQApiInterface.h>
#import "SNQQHelper.h"
#import "SNNewAlertView.h"
#import "SNShareCancelAuthRequest.h"
#import "SNShareSyncTokeyRequest.h"
#import <AFNetworking.h>
#import "SNQQLoginRequest.h"
#import "SNSSOSinaWrapper.h"

#define kCancelBindingTopic         @"cancleBinding"
#define kUploadToShareTopic         @"uploadToShare"
#define kSychTokenTopic             @"sychToken"
#define kOpenLinkTopic              @"openLink"
#define kSychQQTokenTopic           @"kSychQQTokenTopic"

#define kShareDicKeyType            @"sourceType"
#define kShareDicKeyId              @"id"
#define kShareDicKeyMid             @"mid"
#define kShareDicKeyLink            @"link"
#define kShareDicKeyPicUrl          @"pic"
#define kShareDicKeyComment         @"ugc"
#define kShareDicKeyMsg             @"msg"
#define kShareDicKeyTitle           @"title"

#define kShareMangerThirdPart       @"kShareMangerThirdPart"
#define kShareMangerRequestTipKey   @"requestNeedTip"

@implementation SNShareItem

- (id)init {
    if (self = [super init]) {
        self.needTip = YES;
        self.fromComment = NO;
    }
    return self;
}

- (void)dealloc {
}

@end

// private method
@interface SNShareManager() {
    SNShareList *_shareList;
}

@property (nonatomic, copy) NSString *authAppId;
@property (nonatomic, strong) SNAlert *confirmAlert;
@property (nonatomic, strong) SNURLRequest *synchTokenRequest;
@property (nonatomic, strong) SNURLRequest *qqsynchTokenRequest;

- (void)authrizeByAppId:(NSString *)appId delegate:(id<SNShareManagerDelegate>)delegate; // 绑定  -- 改为私有接口  防止再用老接口 少传参数导致各种问题
- (ShareListItem *)itemByAppId:(NSString *)appId;
- (BOOL)checkNetworkAndTell;
- (NSString *)_encodeString:(NSString *)str;

@end

@implementation SNShareManager

@synthesize delegate = _delegate;
@synthesize shareDelegate = _shareDelegate;
@synthesize shareDicInfo = _shareDicInfo;
@synthesize authAppId = _authAppId;
@synthesize confirmAlert = _confirmAlert;
@synthesize synchTokenRequest = _synchTokenRequest;
@synthesize qqsynchTokenRequest = _qqsynchTokenRequest;

- (id)init {
    self = [super init];
    if (self) {
        _shareList = [SNShareList shareInstance];
        [SNNotificationManager addObserverForName:kNotifyDidReceive
                                                          object:nil
                                                           queue:nil
                                                      usingBlock:^(NSNotification *note) {
            if (self.confirmAlert) {
                [self.confirmAlert dismissWithClickedButtonIndex:0 animated:NO];
            }
        }];
    }
    return self;
}

- (void)dealloc {
    [SNNotificationManager removeObserver:self];
    
    _delegate = nil;
    _shareDelegate = nil;
}

+ (void)startWork {
    //wangshun
//    [SNShareList shareInstance].delegate = nil;
//    [[SNShareList shareInstance] refreshShareList:YES];
}

+ (SNShareManager *)defaultManager {
    static SNShareManager *_defaultManger = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _defaultManger = [[SNShareManager alloc] init];
    });
    return _defaultManger;
}

- (NSString *)_encodeString:(NSString *)string {
    NSString *result = (NSString *)CFBridgingRelease(CFURLCreateStringByAddingPercentEscapes(NULL,
																		   (CFStringRef)string,
																		   NULL,
																		   (CFStringRef)@";/?:@&=$+{}<>,",
																		   kCFStringEncodingUTF8));
    return result;
}

- (NSArray *)shareList {
    // todo 有选择性的组织列表内容
    NSMutableArray *array = [NSMutableArray arrayWithCapacity:7];
    for (ShareListItem *item in _shareList.shareList) {
        if (item.appLevel < ShareAppLevelEnd) {
            [array addObject:item];
        }
    }
    return array;
}

- (NSArray *)itemsCouldShare {
    return [_shareList itemsCouldShare];
}

- (NSArray *)namesBinded {
    NSArray *shareItems = [_shareList itemsBinded];
    NSMutableArray *names = [NSMutableArray arrayWithCapacity:6];
    for (ShareListItem *item in shareItems) {
        [names addObject:[NSString stringWithString:item.userName]];
    }
    return names;
}

- (NSArray *)itemsBinded {
    return [_shareList itemsBinded];
}

- (void)updateShareList {
    [_shareList updateShareList];
}

- (void)authrizeByAppId:(NSString *)appId delegate:(id<SNShareManagerDelegate>)delegate {
    self.authAppId = appId;
    self.delegate = delegate;
    
    if ([[SNSSOAdapter shareAdapter] isSupportForAppId:appId] || [appId isEqualToString:@"1"]) {//判断是否为1，是为了使用sina新的sdk，均为SSO登录
        
        [[NSUserDefaults standardUserDefaults] setObject:[NSDate date] forKey:kShareListLastRefreshTimeKey];
        [[NSUserDefaults standardUserDefaults] synchronize];
        
        [[SNSSOAdapter shareAdapter] loginForAppId:appId];
        [SNSSOSinaWrapper sharedInstance].isCommentBindWeibo = YES;
        return;
    }
    
    if (![self checkNetworkAndTell]) {
        return;
    }
    
        if ([self isAppAuthrized:appId]) {
        
        NSString *loginType = [[NSUserDefaults standardUserDefaults] stringForKey:kSSOLoginTypeKey];
        if ([loginType isEqualToString:kSSOLoginTypeLoginWithBind] || [loginType isEqualToString:kSSOLoginTypeLogin]) {
            if ([_delegate respondsToSelector:@selector(shareManagerDidAuthAndLoginSuccess:)]) {
                [_delegate shareManagerDidAuthAndLoginSuccess:self];
            }
        }
        else if ([loginType isEqualToString:kSSOLoginTypeBind]) {
            if ([_delegate respondsToSelector:@selector(shareManagerDidAuthSuccess:)]) {
                [_delegate shareManagerDidAuthSuccess:self];
            }
        }
    }
    else {
        self.delegate = delegate;
        BOOL needModalAuth = NO;
        if ([_delegate respondsToSelector:@selector(shareManagerShouldModalAuthViewController:)]) {
            needModalAuth = [_delegate shareManagerShouldModalAuthViewController:self];
        }
        
        if (needModalAuth) {
            [self submidMoadlOpenLogin:[[self itemByAppId:appId] requestUrl]];
        }
        else {
            [self submitOpenLogin:[[self itemByAppId:appId] requestUrl]];
        }
    }
}

- (void)cancelAuthrizeByAppId:(NSString *)appId delegate:(id<SNShareManagerDelegate>)delegate {
    if (![self checkNetworkAndTell]) {
        return;
    }
    if ([self isAppAuthrized:appId]) {
        
        if ([self isAppIdLoginForUserCenter:appId]) {
            double delayInSeconds = 0.5;
            dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
            dispatch_after(popTime, dispatch_get_main_queue(), ^(void){

                SNNewAlertView *alert = [[SNNewAlertView alloc] initWithTitle:nil message:@"这是您用来登录的账号,如需解绑请退出登录" cancelButtonTitle:@"取消" otherButtonTitle:@"知道了"];
                [alert show];
            });
            return;
        }
        self.delegate = delegate;
        
        [[[SNShareCancelAuthRequest alloc] initWithDictionary:@{@"appid":appId}] send:^(SNBaseRequest *request, id responseObject) {
            BOOL bCancelSuc = NO;

            if ([responseObject isKindOfClass:[NSDictionary class]]) {
                NSDictionary *dicInfo = responseObject;
                
                int status = [dicInfo intValueForKey:@"status" defaultValue:-1100];
                int errorCode = [dicInfo intValueForKey:@"errorCode" defaultValue:-1100];
                if (status == 0 || errorCode == -1) {
                    // 更新状态
                    if ([appId isKindOfClass:[NSString class]]) {
                        ShareListItem *item = [_shareList itemByAppId:appId];
                        item.status = @"1";
                        // 注销之后 要把平台开关 设置为打开状态
                        [SNShareList saveItemStatusToUserDefaults:item enable:YES];
                        [self updateShareList];
                        [SNNotificationManager postNotificationName:kSharelistDidChangedNotification object:nil];
                        bCancelSuc = YES;
                    }
                }
            }
            if (bCancelSuc) {
                if ([_delegate respondsToSelector:@selector(shareManagerDidCancelBindingSuccess:)]) {
                    [_delegate shareManagerDidCancelBindingSuccess:self];
                }
            }
            else {
                if ([_delegate respondsToSelector:@selector(shareManagerDidCancelBindingFail:)]) {
                    [_delegate shareManagerDidCancelBindingFail:self];
                }
            }

        } failure:^(SNBaseRequest *request, NSError *error) {
            SNDebugLog(@"share failed with error=%@", error.localizedDescription);
            [SNNotificationCenter hideLoadingAndBlock];
        }];
    }
}

- (void)changedUserByAppId:(NSString *)appId delegate:(id<SNShareManagerDelegate>)delegate {
    
}

- (BOOL)isAppAuthrized:(NSString *)appId {
    ShareListItem *item = [self itemByAppId:appId];
    if (item) {
        return ([item.status intValue] == 0);
    }
    return NO;
}

- (BOOL)isAppIdLoginForUserCenter:(NSString *)appId {
    NSString *loginAppid = [[NSUserDefaults standardUserDefaults] stringForKey:kUserCenterLoginAppId];
    if ([loginAppid length] > 0) {
        return [loginAppid isEqualToString:appId];
    }
    // 如果是老版本升级过来的 没有保存当前主账号的appId 这里需要判断用户passport userId是不是符合要解绑的appId
    else {
        SNUserinfo *userInfo = [SNUserinfo userinfo];
        NSString *userPassport = [userInfo getUsername];
        NSString *appIdForUser = @"";
        if (userPassport.length > 0) {
            if ([userPassport rangeOfString:@"sina.sohu.com" options:NSCaseInsensitiveSearch].location != NSNotFound) {
                appIdForUser = @"1";
            }
            else if ([userPassport rangeOfString:@"t.qq.sohu.com" options:NSCaseInsensitiveSearch].location != NSNotFound) {
                appIdForUser = @"2";
            }
            else if ([userPassport rangeOfString:@"renren.sohu.com" options:NSCaseInsensitiveSearch].location != NSNotFound) {
                appIdForUser = @"4";
            }
            else if ([userPassport rangeOfString:@"kaixin.sohu.com" options:NSCaseInsensitiveSearch].location != NSNotFound) {
                appIdForUser = @"5";
            }
            else if ([userPassport rangeOfString:@"qq.sohu.com" options:NSCaseInsensitiveSearch].location != NSNotFound) {
                appIdForUser = @"6";
            }
            // 剩余的一律认为是搜狐账号登陆的
            else {
                appIdForUser = @"3";
            }
        }
        
        SNDebugLog(@"%@ :appIdForCancel %@ userId %@ userName %@ appIdForUser %@",
                   NSStringFromSelector(_cmd),
                   appId,
                   userInfo.uid,
                   userInfo.userName,
                   appIdForUser);
        
        return [appIdForUser isEqualToString:appId];
    }
    return NO;
}

- (BOOL)loginByAppId:(NSString *)appId loginType:(SNShareManagerAuthLoginType)loginType delegate:(id<SNShareManagerDelegate>)delegate loginFrom:(NSString *)loginFrom {
    if ([[SNSSOAdapter shareAdapter] isSupportForAppId:appId] || [appId isEqualToString:@"1"]) {
        
        self.delegate = delegate;
        NSString *type = nil;
        if ([appId isEqualToString:@"1"]) {
            type = kLoginTypeSina;
        }
        else if ([appId isEqualToString:@"2"]) {
            type = kLoginTypeQQ;
        }
        else if ([appId isEqualToString:@"8"]) {
            type = kLoginTypeWeChat;
        }
        self.loginFrom = loginFrom;
        self.loginType = type;
        
        NSString *loginTypeStr = nil;
        
        if (loginType == SNShareManagerAuthLoginTypeLogin) {
            loginTypeStr = kSSOLoginTypeLogin;
        }
        else if (loginType == SNShareManagerAuthLoginTypeBind) {
            loginTypeStr = kSSOLoginTypeBind;
        }
        else if (loginType == SNShareManagerAuthLoginTypeLoginWithBind) {
            loginTypeStr = kSSOLoginTypeLoginWithBind;
        }
        
        [[NSUserDefaults standardUserDefaults] setObject:loginTypeStr forKey:kSSOLoginTypeKey];
        [[NSUserDefaults standardUserDefaults] synchronize];
        
        [[SNSSOAdapter shareAdapter] loginForAppId:appId];
        return YES;
    }
    else if (![QQApiInterface isQQInstalled]) {
        self.delegate = delegate;
        [[SNSSOAdapter shareAdapter] loginForAppId:@"80"];
        return [[SNQQHelper sharedInstance].tencentAuth authorize:@[@"all"] inSafari:YES];
    }
    return NO;
}

- (void)authrizeByAppId:(NSString *)appId loginType:(SNShareManagerAuthLoginType)loginType delegate:(id<SNShareManagerDelegate>)delegate {
    NSString *loginTypeStr = nil;
    
    if (loginType == SNShareManagerAuthLoginTypeLogin) {
        loginTypeStr = kSSOLoginTypeLogin;
    }
    else if (loginType == SNShareManagerAuthLoginTypeBind) {
        loginTypeStr = kSSOLoginTypeBind;
    }
    else if (loginType == SNShareManagerAuthLoginTypeLoginWithBind) {
        loginTypeStr = kSSOLoginTypeLoginWithBind;
    }
    
    [[NSUserDefaults standardUserDefaults] setObject:loginTypeStr forKey:kSSOLoginTypeKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    [self authrizeByAppId:appId delegate:delegate];
}


- (BOOL)qqSyncTokenWithAppId:(NSString *)appId openId:(NSString *)openId userInfo:(NSDictionary *)userInfo {
    if ([appId length] == 0 || [openId length] == 0 || [userInfo count] == 0) {
        SNDebugLog(@"%@-->%@ : error with invalidate arguments",
                   NSStringFromClass([self class]),
                   NSStringFromSelector(_cmd));
        return NO;
    }
    
    self.authAppId = kQQSSOLoginAppId;
    
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithCapacity:10];
    [params setValue:appId forKey:@"appId"];
    [params setValue:openId forKey:@"openId"];
    
    if ([appId isEqualToString:@"6"]) {
        self.loginType = kLoginTypeQQ;
    }
    [params setValue:self.loginFrom forKey:@"loginfrom"];
    [params setValue:self.loginType forKey:@"logintype"];
    
    NSString *loginType = [[NSUserDefaults standardUserDefaults] stringForKey:kSSOLoginTypeKey];
    if ([loginType isEqualToString:kSSOLoginTypeLoginWithBind] || [loginType isEqualToString:kSSOLoginTypeLogin]) {
        // 登陆来源统计 by jojo
        [params setValuesForKeysWithDictionary:[[SNAnalytics sharedInstance] addConfigureLoginReferParams]];
        
        [SNNotificationCenter showLoadingAndBlockOtherActions:@"正在登录..."];
    }
    
    // user name
    NSString *userName = [userInfo stringValueForKey:@"nick" defaultValue:nil];
    if ([userName length] > 0) {
        [params setValue:userName forKey:@"nickName"];
    }
    // gender
    NSString *genderString = [userInfo stringValueForKey:@"gender" defaultValue:nil];
    if ([genderString length] > 0) {
        [params setValue:genderString forKey:@"gender"];
    }
    // head url
    NSString *headUrl = [userInfo stringValueForKey:@"headUrl" defaultValue:nil];
    if ([headUrl length] > 0) {
        [params setValue:headUrl forKey:@"headUrl"];
    }
    //5.2 add accessToken
    NSString *accessToken = [userInfo stringValueForKey:@"accessToken" defaultValue:nil];
    if (accessToken.length > 0) {
        [params setValue:accessToken forKey:@"accessToken"];
    }
    
    [[[SNQQLoginRequest alloc] initWithDictionary:params] send:^(SNBaseRequest *request, id responseObject) {
        
        [self handleSychTokenRequestFinishResultWithRequest:request andResponse:responseObject];
        
    } failure:^(SNBaseRequest *request, NSError *error) {
        
        SNDebugLog(@"share failed with error=%@", error.localizedDescription);
        [SNNotificationCenter hideLoadingAndBlock];
    }];
    
    return YES;
}

- (BOOL)syncToken:(NSString *)token refreshToken:(NSString *)refreshToken expire:(NSDate *)expireDate userName:(NSString *)userName userId:(NSString *)userId appId:(NSString *)appId {
    if ([token length] == 0 || expireDate == nil || [appId length] == 0 || [userId length] == 0) {
        SNDebugLog(@"%@-->%@ : error with invalidate arguments",
                   NSStringFromClass([self class]),
                   NSStringFromSelector(_cmd));
        return NO;
    }
    self.authAppId = appId;
    
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithCapacity:10];
    [params setValue:token forKey:@"token"];
    [params setValue:[NSString stringWithFormat:@"%zd",(long long)[expireDate timeIntervalSince1970]] forKey:@"expire"];
    [params setValue:appId forKey:@"appId"];
    
    // userId
    if ([userId length] > 0) {
        [params setValue:userId forKey:@"openId"];
    }
    // refresh token
    if ([refreshToken length] > 0) {
        [params setValue:refreshToken forKey:@"refreshToken"];
    }
    // user name
    if ([userName length] > 0) {
        [params setValue:userName forKey:@"nickName"];
    }

    [params setValue:self.loginFrom forKey:@"loginfrom"];
    [params setValue:self.loginType forKey:@"logintype"];
    
    NSString *loginType = [[NSUserDefaults standardUserDefaults] stringForKey:kSSOLoginTypeKey];
    if ([loginType isEqualToString:kSSOLoginTypeLoginWithBind] || [loginType isEqualToString:kSSOLoginTypeLogin]) {
        // 登陆来源统计 by jojo
        [params setValuesForKeysWithDictionary:[[SNAnalytics sharedInstance] addConfigureLoginReferParams]];
        
        [SNNotificationCenter showLoadingAndBlockOtherActions:@"正在登录..."];
    }
    
    [[[SNShareSyncTokeyRequest alloc] initWithDictionary:params] send:^(SNBaseRequest *request, id responseObject) {
        
        [self handleSychTokenRequestFinishResultWithRequest:request andResponse:responseObject];
        
    } failure:^(SNBaseRequest *request, NSError *error) {
        
        SNDebugLog(@"share failed with error=%@", error);
        [SNNotificationCenter hideLoadingAndBlock];
    }];
    
    return YES;
}

- (void)handleSychTokenRequestFinishResultWithRequest:(SNBaseRequest *)request andResponse:(id)responseObject {
    [SNNotificationCenter hideLoadingAndBlock];
}

- (void)cancelSyncTokenRequest {
    if (self.synchTokenRequest) {
        [self.synchTokenRequest.delegates removeObject:self];
        [self.synchTokenRequest cancel];
        self.synchTokenRequest = nil;
    }
    
    if (self.qqsynchTokenRequest) {
        [self.qqsynchTokenRequest.delegates removeObject:self];
        [self.qqsynchTokenRequest cancel];
        self.qqsynchTokenRequest = nil;
    }
}

- (void)startShareControllerWithShareInfo:(NSDictionary *)shareInfoDic {
    SNSharePostController *controller = [SNSharePostController sharePostControllerWithShareInfo:shareInfoDic];
    controller.isVideoShare = self.isVideoShare;
    controller.isQianfanShare = self.isQianfanShare;
    if (self.isQianfanShare) {
        controller.newsId = shareInfoDic[@"vid"];
    }
    controller.sourceType = self.sourceType;
    if (controller) {
        //want view top begin under statusbar, so wrap it with navigation controller
        SNNavigationController *_sharePostNC = [[SNNavigationController alloc] initWithRootViewController:controller];
        NSString *presentFromWindowDelegate = [shareInfoDic objectForKey:kPresentFromWindowDelegate];
        
        if (presentFromWindowDelegate) {//splash window
            id delegate = [SNUtility getApplicationDelegate].splashViewController;
            if ([delegate respondsToSelector:@selector(enterApp)]) {
                [delegate performSelector:@selector(enterApp) withObject:nil];
                [[SNUtility getApplicationDelegate].appTabbarController presentViewController:_sharePostNC animated:YES completion:^{
                    
                }];
            }
        } else {
            [[UIApplication sharedApplication] setStatusBarOrientation:UIInterfaceOrientationPortrait];
            [UIApplication sharedApplication].statusBarHidden = NO;
            //present-style push
            if (self.isVideoShare||self.isQianfanShare) {
                [[TTNavigator navigator].topViewController presentViewController:controller animated:YES completion:^{
                    
                }];
            }else{
                [[TTNavigator navigator].topViewController.flipboardNavigationController presentModalViewController:controller needAnimated:YES];
            }
        }
    }
}

- (void)postShareItemToServer:(SNShareItem *)shareItem {
    if (![self checkNetworkAndTell]) {
        return;
    }
    
    NSTimeInterval now = [NSDate date].timeIntervalSince1970;
    if(now - self.lastShareTime < 1) {
        return;
    }
    self.lastShareTime = now;
    
    self.shareLink = shareItem.shareLink;
    
    NSArray *appIds = [_shareList itemsCouldShare];
    NSMutableString *appIdStr = [NSMutableString string];
    if (shareItem.appId.length > 0) {
        [appIdStr appendString:shareItem.appId];
    }
    else if (appIds.count > 0){
        int index = 0;
        for (ShareListItem *item in appIds) {
            [appIdStr appendFormat:@"%@", item.appID];
            if (index != appIds.count - 1) {
                [appIdStr appendFormat:@","];
            }
            index++;
        }
    }
    
    SNShareContentType shareType = shareItem.shareContentType;
    BOOL fromComment = shareItem.fromComment;
    NSString *shareContent   = shareItem.shareContent;
    NSString *shareImagePath = shareItem.shareImagePath;
    NSString *shareImageUrl  = shareItem.shareImageUrl;
    
    if (shareItem.sourceType == SNShareSourceTypeVedioTab) {
        self.isVideo = YES;
    }else{
        self.isVideo = NO;
    }

    _isNotRealShare = shareItem.isNotRealShare;

    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithCapacity:10];

    [params setValue:@(shareType) forKey:@"ctype"];
    [params setValue:@(fromComment) forKey:@"commentShow"];
    
    //shareContent type 0： json格式提交内容 1：string格式提交内容
    if (shareType == SNShareContentTypeString) {
        if (shareItem.ugc) {
            shareContent = [shareItem.ugc stringByAppendingString:[NSString stringWithFormat:@"  %@",shareContent]];
        }
        if (shareItem.shareTitle.length > 0) {
            [params setValue:shareItem.shareTitle forKey:kShareDicKeyTitle];
        }
        [params setValue:shareContent forKey:@"content"];

        NSString *ecodeContent = [self _encodeString:shareContent];
        SNDebugLog(@"content = %@", ecodeContent);
    }
    else {
        //提交到服务器的content，json格式
        NSMutableDictionary *contentInfoDic = [NSMutableDictionary dictionary];
        // 视频tab 分享
        if (shareItem.shareContent && (shareItem.sourceType == SNShareSourceTypeVedioTab
                                       || shareItem.sourceType == 65
                                       || shareItem.sourceType == SNShareSourceTypeVedio
                                       || shareItem.sourceType == SNShareSourceTypeUGC
                                       || shareItem.sourceType == SNShareSourceTypeActivityNoUgc
                                       || shareItem.sourceType == SNShareSourceTypeChannel
                                       || shareItem.sourceType == SNShareSourceTypeADSpread
                                       || shareItem.sourceType == SNShareSourceTypeSpecial)) {
            
            [contentInfoDic setObject:shareItem.shareContent forKey:kShareDicKeyMsg];
            
        }
        
        NSString *typeStr = [NSString stringWithFormat:@"%d", shareItem.sourceType];
        if (typeStr.length > 0) {
            [contentInfoDic setObject:typeStr forKey:kShareDicKeyType];
        }
        if (shareItem.shareLink.length > 0) {
            [contentInfoDic setObject:shareItem.shareLink forKey:kShareDicKeyLink];
        }
        if (shareItem.shareId.length > 0) {
            //视频分享传mid
            [contentInfoDic setObject:shareItem.shareId forKey:kShareDicKeyId];
        }
        if (shareItem.ugc.length > 0) {
            [contentInfoDic setObject:shareItem.ugc forKey:kShareDicKeyComment];
            if (_shareDelegate && [_shareDelegate respondsToSelector:@selector(shareManager:willShareComment:)]) {
                [_shareDelegate shareManager:self willShareComment:shareItem.ugc];
            }
        }
        NSString *contentJson = [contentInfoDic yajl_JSONString];
        
        [params setValue:contentJson forKey:@"content"];
        
        SNDebugLog(@"contentJson = %@", contentJson);
        if (shareItem.shareTitle.length > 0) {
            [params setValue:shareItem.shareTitle forKey:kShareDicKeyTitle];
        }
    }
    
    //appIds
    if (appIdStr.length > 0) {
        [params setValue:appIdStr forKey:@"appids"];
        SNDebugLog(@"appids = %@", appIdStr);
    }
    
    //shareImage
    NSString *imgPath = nil;
    if (shareImageUrl.length > 0) {
        [params setValue:shareImageUrl forKey:@"img_url"];
        SNDebugLog(@"img_url = %@", shareImageUrl);
    } else if (shareImagePath.length > 0) {
        imgPath = shareImagePath;
    }
    
    //shareUrl
    NSString *shareLink = [SNUtility getLinkFromShareContent:shareContent];
    if ([shareLink length] > 0) {
        [params setValue:shareLink forKey:@"shareUrl"];
    } else if (shareItem.shareLink.length > 0 && [SNAPI isWebURL:shareItem.shareLink]) {
        [params setValue:shareItem.shareLink forKey:@"shareUrl"];
    }
    else {
        
        [params setValue:SNLinks_FixedUrl_3gk forKey:@"shareUrl"];
    }
    self.needTip = shareItem.needTip;
    
    [[[SNShareV4UploadRequest alloc] initWithDictionary:params isNotRealShare:_isNotRealShare andShareImagePath:imgPath] send:^(SNBaseRequest *request, id rootData) {
        if (rootData && [rootData isKindOfClass:[NSDictionary class]]  && self.needTip) {
            SNDebugLog(@"%@", rootData);
            int errCode = [rootData intValueForKey:@"errorCode" defaultValue:@""];
            NSString * errMsg  = [rootData stringValueForKey:@"errorMessage" defaultValue:nil];
            
            if (errCode != kSNShareManagerNoError && errMsg.length > 0) {
                if (errCode == kSNShareManagerErrorCode) {
                    [[SNCenterToast shareInstance] showCenterToastWithTitle:errMsg toUrl:nil mode:SNCenterToastModeWarning];
                }
            }
            else if (errCode == kSNShareManagerNoError) {
                [[SNCenterToast shareInstance] showCenterToastWithTitle:NSLocalizedString(@"ShareSucceed", @"ShareSucceed") toUrl:nil mode:SNCenterToastModeSuccess];
                [self performSelector:@selector(requestRedPackerAndCoupon:) withObject:self.shareLink afterDelay:1];
            }
        }
 
    } failure:^(SNBaseRequest *request, NSError *error) {
        SNDebugLog(@"%@",error.localizedDescription);
    }];
    
}

#pragma mark -private methods
- (ShareListItem *)itemByAppId:(NSString *)appId {
    if (_shareList) {
        return [_shareList itemByAppId:appId];
    }
    return nil;
}

- (BOOL)checkNetworkAndTell {
    BOOL isNetworkReachable = [[SNUtility getApplicationDelegate] isNetworkReachable];
    if (!isNetworkReachable) {
        [SNNotificationCenter showExclamation:NSLocalizedString(@"network error", @"")];
    }
    return isNetworkReachable;
}

#pragma mark - TTURLRequestDelegate
// todo 分享成功或者失败之后  要不要提醒一下?
- (void)requestDidFinishLoad:(TTURLRequest*)request {
    TTUserInfo *userInfo = [request userInfo];
    // 分享
    if ([[userInfo topic] compare:kUploadToShareTopic options:NSCaseInsensitiveSearch] == NSOrderedSame) {
        SNURLJSONResponse *json = request.response;
        SNDebugLog(@"share json ret=%@ ret class=%@", json.rootObject, [json.rootObject class]);
        if (json && [json.rootObject isKindOfClass:[NSDictionary class]]) {
            NSDictionary *dicInfo = json.rootObject;
            int status = [dicInfo intValueForKey:@"status" defaultValue:-1110];
            int errorCode = [dicInfo intValueForKey:@"errorCode" defaultValue:-1110];
            
            if (status == 0 || errorCode == -1) {
                if (_shareDelegate && [_shareDelegate respondsToSelector:@selector(shareManagerShareSuccess:)]) {
                    [_shareDelegate shareManagerShareSuccess:self];
                }
                // show success info
                if (!_isNotRealShare) {
                    [[SNCenterToast shareInstance] showCenterToastWithTitle:NSLocalizedString(@"ShareSucceed", @"ShareSucceed") toUrl:nil mode:SNCenterToastModeSuccess];
                    [self performSelector:@selector(requestRedPackerAndCoupon:) withObject:self.shareLink afterDelay:1];
                }
            }
            else {
                if ([_shareDelegate respondsToSelector:@selector(shareManagerShareFailed:)]) {
                    [_shareDelegate shareManagerShareFailed:self];
                }
                
                if (!_isNotRealShare) {
                    [[SNCenterToast shareInstance] showCenterToastWithTitle:NSLocalizedString(@"ShareFailed", @"ShareFailed") toUrl:nil mode:SNCenterToastModeWarning];
                }
                
                return;
            }
            
        }
    } // 取消绑定
    else if ([[userInfo topic] compare:kCancelBindingTopic options:NSCaseInsensitiveSearch] == NSOrderedSame) {
        BOOL bCancelSuc = NO;
        SNURLJSONResponse *json = request.response;
        SNDebugLog(@"cancel binding ret info=%@", json.rootObject);
        if (json && [json.rootObject isKindOfClass:[NSDictionary class]]) {
            NSDictionary *dicInfo = json.rootObject;
            
            int status = [dicInfo intValueForKey:@"status" defaultValue:-1100];
            int errorCode = [dicInfo intValueForKey:@"errorCode" defaultValue:-1100];
            if (status == 0 || errorCode == -1) {
                // 更新状态
                if ([userInfo.strongRef isKindOfClass:[NSString class]]) {
                    ShareListItem *item = [_shareList itemByAppId:userInfo.strongRef];
                    item.status = @"1";
                    // 注销之后 要把平台开关 设置为打开状态
                    [SNShareList saveItemStatusToUserDefaults:item enable:YES];
                    [self updateShareList];
                    [SNNotificationManager postNotificationName:kSharelistDidChangedNotification object:nil];
                    bCancelSuc = YES;
                }
            }
        }
        
        if (bCancelSuc) {
            if ([_delegate respondsToSelector:@selector(shareManagerDidCancelBindingSuccess:)]) {
                [_delegate shareManagerDidCancelBindingSuccess:self];
            }
        }
        else {
            if ([_delegate respondsToSelector:@selector(shareManagerDidCancelBindingFail:)]) {
                [_delegate shareManagerDidCancelBindingFail:self];
            }
        }
    }
    else if ([[userInfo topic] isEqualToString:kSychTokenTopic]
             || [[userInfo topic] isEqualToString:kSychQQTokenTopic]) {
        SNURLJSONResponse *json = request.response;
        SNDebugLog(@"sych token receive data :%@", json.rootObject);
        NSDictionary *retDicInfo = (NSDictionary *)json.rootObject;
        
        [SNNotificationCenter hideLoadingAndBlock];
        
        BOOL bRetSuccess = NO;
        if ([retDicInfo isKindOfClass:[NSDictionary class]]) {
            SNDebugLog(@"status %@ errorCode %@", [[retDicInfo objectForKey:@"status"] class], [[retDicInfo objectForKey:@"errorCode"] class]);
            int status = [retDicInfo intValueForKey:@"status" defaultValue:-1100];
            int errorCode = [retDicInfo intValueForKey:@"errorCode" defaultValue:-1100];
            if (status == 0 || errorCode == -1) {
                // check if need restore passport
                
                NSString *loginType = [[NSUserDefaults standardUserDefaults] stringForKey:kSSOLoginTypeKey];
                if ([loginType isEqualToString:kSSOLoginTypeLoginWithBind]) {
                    // restore share list
                    NSArray *shareList = [retDicInfo objectForKey:@"bindList"];
                    if (shareList && [shareList isKindOfClass:[NSArray class]]) {
                        [_shareList restoreShareListData:shareList];
                    }
                    
                    // 服务器返回的主账号信息 可能不会带nick name回来 如果分享列表能带回来 就先用分享列表的
                    ShareListItem *shareItem = [_shareList itemByAppId:self.authAppId];
                    SNUserinfoEx* currentUser = [SNUserinfoEx userinfoEx];
                    currentUser.userName = [retDicInfo stringValueForKey:@"userId" defaultValue:nil];
                    currentUser.pid = [retDicInfo stringValueForKey:@"pid" defaultValue:nil];
                    currentUser.token = [retDicInfo stringValueForKey:@"token" defaultValue:nil];
                    if(currentUser.token.length==0)
                    {
                        //从连接里解析token
                        NSDictionary* dictionary = [SNEncryptManager dictionaryFromQuery:request.urlPath usingEncoding:NSASCIIStringEncoding];
                        currentUser.token = [dictionary objectForKey:@"token"];
                    }
                    NSDictionary* newUserDic = [retDicInfo dictionaryValueForKey:@"newUserInfo" defalutValue:nil];
                    if (newUserDic != nil)
                    {
                        [currentUser parseUserinfoFromDictionary:newUserDic];
                        
                        currentUser.nickName = [newUserDic stringValueForKey:@"nick" defaultValue:shareItem.userName];
                        
                        
                        //3.5.1扩展cookie
                        SNURLJSONResponse* data = (SNURLJSONResponse*)request.response;
                        NSString* setCookie   = [data.responceHeader objectForKey:@"set-Cookie"];
                        if(setCookie.length > 0)
                        {
                            if(currentUser.cookieValue )
                            {
                                if([currentUser.cookieValue rangeOfString:setCookie options:NSCaseInsensitiveSearch].location==NSNotFound)
                                {
                                    currentUser.cookieValue = [NSString stringWithFormat:@"%@; %@", currentUser.cookieValue, setCookie];
                                }
                            }
                            else
                            {
                                currentUser.cookieValue = setCookie;
                                currentUser.cookieName = kSetCookie;
                            }
                        }
                        
                        [[NSUserDefaults standardUserDefaults] setObject:self.authAppId forKey:kUserCenterLoginAppId];
                        [[NSUserDefaults standardUserDefaults] synchronize];
                        
                        [currentUser saveUserinfoToUserDefault];
                        
                        [SNUserUtility handleUserLogin];
                        if ([_delegate respondsToSelector:@selector(shareManagerDidAuthAndLoginSuccess:)]) {
                            [_delegate shareManagerDidAuthAndLoginSuccess:self];
                        }
                        bRetSuccess = YES;
                    }
                    
                }
                else if ([loginType isEqualToString:kSSOLoginTypeLogin])
                {
                    SNUserinfoEx *aUserInfo = [SNUserinfoEx userinfoEx];
                    [aUserInfo parseUserinfoFromDictionary:retDicInfo];
                    NSDictionary* newUserinfo = [retDicInfo objectForKey:@"newUserInfo"];
                    if (newUserinfo != nil && [newUserinfo isKindOfClass:[NSDictionary class]])
                    {
                        [aUserInfo parseUserinfoFromDictionary:newUserinfo];
                    }
                    
                    aUserInfo.token = [retDicInfo stringValueForKey:@"token" defaultValue:nil];
                    if(aUserInfo.token.length==0)
                    {
                        //从连接里解析token
                        NSDictionary* dictionary = [SNEncryptManager dictionaryFromQuery:request.urlPath usingEncoding:NSASCIIStringEncoding];
                        aUserInfo.token = [dictionary objectForKey:@"token"];
                    }
                    
                    //3.5.1扩展cookie
                    SNURLJSONResponse* data = (SNURLJSONResponse*)request.response;
                    NSString* setCookie   = [data.responceHeader objectForKey:@"set-Cookie"];
                    if(setCookie.length > 0)
                    {
                        if(aUserInfo.cookieValue )
                        {
                            if([aUserInfo.cookieValue rangeOfString:setCookie options:NSCaseInsensitiveSearch].location==NSNotFound)
                            {
                                aUserInfo.cookieValue = [NSString stringWithFormat:@"%@; %@", aUserInfo.cookieValue, setCookie];
                            }
                        }
                        else
                        {
                            aUserInfo.cookieValue = setCookie;
                            aUserInfo.cookieName = kSetCookie;
                        }
                    }
                    [aUserInfo saveUserinfoToUserDefault];
                    
                    [SNNotificationCenter hideLoadingAndBlock];
                    
                    if ([_delegate respondsToSelector:@selector(shareManagerDidAuthAndLoginSuccess:)]) {
                        [_delegate shareManagerDidAuthAndLoginSuccess:self];
                    }
                    
                    [SNUserUtility handleUserLogin];
                    [[NSUserDefaults standardUserDefaults] setObject:self.authAppId forKey:kUserCenterLoginAppId];
                    [[NSUserDefaults standardUserDefaults] synchronize];
                    
                    bRetSuccess = YES;
                    
                }
                else if ([loginType isEqualToString:kSSOLoginTypeBind]) {
                    // 更新状态
                    if ([userInfo.strongRef isKindOfClass:[NSString class]]) {
                        [_shareList itemByAppId:userInfo.strongRef].status = @"0";
                        [_shareList itemByAppId:userInfo.strongRef].userName = [retDicInfo stringValueForKey:@"nick" defaultValue:nil];
                        NSString *userIdString = [retDicInfo stringValueForKey:@"userId" defaultValue:@""];
                        if (userIdString.length > 0) {
                            NSRange range = [userIdString rangeOfString:@"@"];
                            [_shareList itemByAppId:userInfo.strongRef].openId = [userIdString substringToIndex:range.location];
                        }
                        [self updateShareList];
                        [SNNotificationManager postNotificationName:kSharelistDidChangedNotification object:nil];
                        
                        if ([_delegate respondsToSelector:@selector(shareManagerDidAuthSuccess:)]) {
                            [_delegate shareManagerDidAuthSuccess:self];
                        }
                        bRetSuccess = YES;
                    }
                }
            }
        }
        
        if (!bRetSuccess) {
            // 失败
            if ([_delegate respondsToSelector:@selector(shareManager:didAuthFailedWithError:)]) {
                int errorCode = [retDicInfo intValueForKey:@"errorCode" defaultValue:404];
                
                if (errorCode == 0)
                    errorCode = 404;
                NSString *errorMsg = [retDicInfo stringValueForKey:@"errorMessage" defaultValue:@"未知错误"];
                if (errorMsg.length == 0)
                    errorMsg = @"未知错误";
                
                [_delegate shareManager:self didAuthFailedWithError:[NSError errorWithDomain:errorMsg
                                                                                        code:errorCode
                                                                                    userInfo:nil]];
            }
        }
    }
    else if ([userInfo.topic isEqualToString:kOpenLinkTopic]) {
        SNURLJSONResponse *json = request.response;
        SNDebugLog(@"open link receive data :%@", json.rootObject);
        NSDictionary *retDicInfo = json.rootObject;
        BOOL bRetSuccess = NO;
        if ([retDicInfo isKindOfClass:[NSDictionary class]]) {
            int status = [retDicInfo intValueForKey:@"status" defaultValue:-1100];
            if (status == 0) {
                // 成功
                // todo 区分loginType 进行不通的处理
                NSString *loginType = [[NSUserDefaults standardUserDefaults] stringForKey:kSSOLoginTypeKey];
                if ([loginType isEqualToString:kSSOLoginTypeLoginWithBind] || [loginType isEqualToString:kSSOLoginTypeLogin])
                {
                    NSString *passport = [retDicInfo stringValueForKey:@"userId" defaultValue:nil];
                    if(passport.length==0)
                        passport = [retDicInfo stringValueForKey:@"userid" defaultValue:nil];
                    if ([passport length] > 0)
                    {
                        SNUserinfoEx *aUserInfo = [SNUserinfoEx userinfoEx];
                        aUserInfo.userName = passport;
                        aUserInfo.nickName = [retDicInfo stringValueForKey:@"nick" defaultValue:nil];
                        aUserInfo.pid = [retDicInfo stringValueForKey:@"pid" defaultValue:nil];
                        aUserInfo.token = [retDicInfo stringValueForKey:@"token" defaultValue:nil];
                        if(!aUserInfo.token)
                        {
                            //从连接里解析token
                            NSDictionary* dictionary = [SNEncryptManager dictionaryFromQuery:request.urlPath usingEncoding:NSASCIIStringEncoding];
                            aUserInfo.token = [dictionary objectForKey:@"token"];
                        }

                        //3.5版本 特殊处理 搜狐微博绑定且登录的逻辑 直接按照另一种个详细的字段格式解释 diao
                        if([loginType isEqualToString:kSSOLoginTypeLoginWithBind] && [@"3" isEqualToString:self.authAppId])
                        {
                            NSDictionary* userinfo = [retDicInfo objectForKey:@"userInfo"];
                            [aUserInfo parseUserinfoFromDictionary:userinfo];
                        }
                        
                        SNURLJSONResponse* data = (SNURLJSONResponse*)request.response;
                        NSString* setCookie   = [data.responceHeader objectForKey:@"set-Cookie"];
                        if(setCookie.length > 0)
                        {
                            if(aUserInfo.cookieValue )
                            {
                                if([aUserInfo.cookieValue rangeOfString:setCookie options:NSCaseInsensitiveSearch].location==NSNotFound)
                                {
                                    aUserInfo.cookieValue = [NSString stringWithFormat:@"%@; %@", aUserInfo.cookieValue, setCookie];
                                }
                            }
                            else
                            {
                                aUserInfo.cookieValue = setCookie;
                                aUserInfo.cookieName = kSetCookie;
                            }
                        }
                        [aUserInfo saveUserinfoToUserDefault];
                        
                        if ([_delegate respondsToSelector:@selector(shareManagerDidAuthAndLoginSuccess:)]) {
                            [_delegate shareManagerDidAuthAndLoginSuccess:self];
                        }
                        
                        
                        [_shareList itemByAppId:self.authAppId].status = @"0";
                        //[self updateShareList];
                        [SNNotificationManager postNotificationName:kSharelistDidChangedNotification object:nil];
                        
                        bRetSuccess = YES;
                        
                        [[NSUserDefaults standardUserDefaults] setObject:self.authAppId forKey:kUserCenterLoginAppId];
                        [[NSUserDefaults standardUserDefaults] synchronize];
                        
                        [SNUserUtility handleUserLogin];
                    }
                }
                else if ([loginType isEqualToString:kSSOLoginTypeBind]) {
                    [_shareList itemByAppId:self.authAppId].status = @"0";
                    [_shareList itemByAppId:self.authAppId].userName = [retDicInfo stringValueForKey:@"nick" defaultValue:nil];
                    [self updateShareList];
                    
                    if ([_delegate respondsToSelector:@selector(shareManagerDidAuthSuccess:)]) {
                        [_delegate shareManagerDidAuthSuccess:self];
                    }
                    
                    [SNNotificationManager postNotificationName:kSharelistDidChangedNotification object:nil];
                    bRetSuccess = YES;
                }
            }
        }
        
        if (!bRetSuccess) {
            // todo 失败了
            NSString *loginType = [[NSUserDefaults standardUserDefaults] stringForKey:kSSOLoginTypeKey];
            if ([loginType isEqualToString:kSSOLoginTypeLoginWithBind]) {
            }
            else if ([loginType isEqualToString:kSSOLoginTypeLogin]) {
            }
            else if ([loginType isEqualToString:kSSOLoginTypeBind]) {
            }
            // 失败
            if ([_delegate respondsToSelector:@selector(shareManager:didAuthFailedWithError:)]) {
                int errorCode = [retDicInfo intValueForKey:@"errorCode" defaultValue:404];
                if (errorCode == 0)
                    errorCode = 404;
                
                NSString *errorMsg = [retDicInfo stringValueForKey:@"errorMessage" defaultValue:@"未知错误"];
                if (errorMsg.length == 0)
                    errorMsg = @"未知错误";
                
                [_delegate shareManager:self didAuthFailedWithError:[NSError errorWithDomain:errorMsg
                                                                                        code:errorCode
                                                                                    userInfo:nil]];
            }
        }
    }
}

- (void)request:(TTURLRequest*)request didFailLoadWithError:(NSError*)error {
    SNDebugLog(@"share failed with error=%@", error);
    [SNNotificationCenter hideLoadingAndBlock];
}

- (void)requestDidCancelLoad:(TTURLRequest*)request {
    [SNNotificationCenter hideLoadingAndBlock];
}

#pragma mark -
- (void)submitOpenLogin:(NSString *)loginUrl {
    NSDictionary* dic;
    dic = [NSDictionary dictionaryWithObjectsAndKeys:
           [NSString stringWithFormat:@"%@&gid=%@&version=1.0", [SNUtility addParamP1ToURL:loginUrl], [SNUserManager getGid]], @"url",
           self, @"openDelegate", NSStringFromSelector(@selector(didGetLoginRequestUrl:)), @"openSelector",
           nil];
    
    TTURLAction* urlAction = [[TTURLAction actionWithURLPath:@"tt://oauthWebView"] applyQuery:dic];
    urlAction.animated = YES;
    [[TTNavigator navigator] openURLAction:urlAction];
}

- (void)submidMoadlOpenLogin:(NSString *)loginUrl {
    
    if ([_delegate respondsToSelector:@selector(shareManager:wantToShowAuthView:)]) {
        NSDictionary* dic;
        dic = [NSDictionary dictionaryWithObjectsAndKeys:
               [NSString stringWithFormat:@"%@&gid=%@&version=1.0", [SNUtility addParamP1ToURL:loginUrl], [SNUserManager getGid]], @"url",
               self, @"openDelegate", NSStringFromSelector(@selector(didGetLoginRequestUrl:)), @"openSelector",
               @"", @"isModal",
               nil];
        
        SNOauthWebViewController *authController = [[SNOauthWebViewController alloc] initWithNavigatorURL:nil query:dic];
        SNNavigationController *_shareAuthNC = [[SNNavigationController alloc] initWithRootViewController:authController];
        [_delegate shareManager:self wantToShowAuthView:_shareAuthNC];
    }
}

- (void)didGetLoginRequestUrl:(NSString *)url {
    if ([url length] > 0)
    {
        NSString *loginType = [[NSUserDefaults standardUserDefaults] stringForKey:kSSOLoginTypeKey];
        if ([loginType isEqualToString:kSSOLoginTypeLoginWithBind] && [self.authAppId intValue] != 3)
        {
            if([self parseGetLoginRequestUrl:url])
            {
                _userinfoModel = [[SNUserinfoService alloc] init];
                _userinfoModel.userinfoDelegate = self;
                [_userinfoModel circle_userinfoRequest:nil loginFrom:nil];
                
            }
            else
            {
                if ([_delegate respondsToSelector:@selector(shareManager:didAuthFailedWithError:)])
                {
                    
                    [_delegate shareManager:self didAuthFailedWithError:[NSError errorWithDomain:@"解析错误"
                                                                                            code:404
                                                                                        userInfo:nil]];
                }
            }
        }
        else
        {
            SNURLRequest *request = [SNURLRequest requestWithURL:url delegate:self isParamP:YES];
            request.response = [[SNURLJSONResponse alloc] init];
            request.userInfo = [TTUserInfo topic:kOpenLinkTopic];
            request.cachePolicy = TTURLRequestCachePolicyNoCache;
            request.timeOut = 30;
            [request send];
        }
    }
}

- (BOOL)parseGetLoginRequestUrl:(NSString*)url
{
    NSRange range = [url rangeOfString:@"?"];
    if(range.length > 0)
    {
        NSString* subStr = [url substringFromIndex:range.location+1];
        NSArray* subArray = [subStr componentsSeparatedByString:@"&"];
        if(subArray.count > 0)
        {
            NSString* userName = nil;
            NSString* token = nil;
            for(NSString* str in subArray)
            {
                subArray = [str componentsSeparatedByString:@"="];
                if(subArray.count == 2)
                {
                    NSString* key = [subArray objectAtIndex:0];
                    NSString* value = [subArray objectAtIndex:1];
                    if([key isEqualToString:@"token"])
                        token = value;
                    if([key isEqualToString:@"userid"])
                        userName = value;
                }
            }
            if(userName.length > 0 && token.length > 0)
            {
                SNUserinfoEx* userinfo = [SNUserinfoEx userinfoEx];
                userinfo.userName = userName;
                userinfo.token = token;
                [userinfo saveUserinfoToUserDefault];
                return YES;
            }
        }
    }
    return NO;
}

#pragma -mark SNUserinfoGetUserinfoDelegate
-(void)notifyGetUserinfoSuccess:(NSArray*)mediaArray
{
    [_shareList itemByAppId:self.authAppId].status = @"0";
    [SNNotificationManager postNotificationName:kSharelistDidChangedNotification object:nil];
    
    [[NSUserDefaults standardUserDefaults] setObject:self.authAppId forKey:kUserCenterLoginAppId];
    [[NSUserDefaults standardUserDefaults] synchronize];
    [SNUserUtility handleUserLogin];
    
    if ([_delegate respondsToSelector:@selector(shareManagerDidAuthAndLoginSuccess:)]) {
        [_delegate shareManagerDidAuthAndLoginSuccess:self];
    }
}
-(void)notifyGetUserinfoFailure:(NSInteger)aStatus msg:(NSString*)aMsg
{
    if ([_delegate respondsToSelector:@selector(shareManager:didAuthFailedWithError:)])
    {
        
        [_delegate shareManager:self didAuthFailedWithError:[NSError errorWithDomain:@"用户信息失败"
                                                                                code:404
                                                                            userInfo:nil]];
    }
}

-(void)notifyGetUserinfoFailure:(TTURLRequest*)request didFailLoadWithError:(NSError*)error
{
    if ([_delegate respondsToSelector:@selector(shareManager:didAuthFailedWithError:)])
    {
        
        [_delegate shareManager:self didAuthFailedWithError:[NSError errorWithDomain:@"用户信息失败"
                                                                                code:404
                                                                            userInfo:nil]];
    }
}

- (void)requestRedPackerAndCoupon:(NSString *)shareUrl{
    [SNUtility requestRedPackerAndCoupon:shareUrl type:@"1"];
}

@end
