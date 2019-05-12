//
//  SNQQHelper.m
//  sohunews
//
//  Created by wang yanchen on 13-5-14.
//  Copyright (c) 2013年 Sohu.com. All rights reserved.
//

#import "SNQQHelper.h"
#import "SNStatusBarMessageCenter.h"
#import <TencentOpenAPI/QQApiInterface.h>
#import <TencentOpenAPI/QQApiInterfaceObject.h>
#import <TencentOpenAPI/TencentOAuth.h>
#import <TencentOpenAPI/TencentApiInterface.h>


@interface SNQQHelper ()<TencentSessionDelegate, QQApiInterfaceDelegate>

- (BOOL)isQQReadyAndTell;

@end

@implementation SNQQHelper
@synthesize tencentAuth = _tencentAuth;
@synthesize loginUserInfoDic = _loginUserInfoDic;
@synthesize isShareToQZone;

- (void)dealloc {
    self.tencentAuth.sessionDelegate = nil;
     //(_tencentAuth);
     //(_loginUserInfoDic);
     //(_shareUrl);
    self.delegate = nil;
}

+ (SNQQHelper *)sharedInstance {
    static SNQQHelper *_instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _instance = [[SNQQHelper alloc] init];
    });

    return _instance;
}

+ (void)initQQApi {
    [[self sharedInstance] setUpTencentAuth];
}

+ (BOOL)isQQApiReady {
    if (![QQApiInterface isQQInstalled]
        || ![QQApiInterface isQQSupportApi]) {
        return NO;
    }
    
    if (![QQApiInterface isQQInstalled]
        || ![QQApiInterface isQQSupportApi]) {
        return NO;
    }
    
    return YES;
}

+ (BOOL)isSupportQQSSO {
    BOOL bQQ = YES, bQZone = YES;
    
//    if (![TencentOAuth iphoneQQInstalled] || ![TencentOAuth iphoneQQSupportSSOLogin]) {//去掉这个判断，否则会导致QQ web登录授权失败问题
//        bQQ = NO;
//    }
    
    if (![TencentOAuth iphoneQZoneInstalled]
        || [TencentOAuth iphoneQZoneSupportSSOLogin]) {
        bQZone = NO;
    }
    
    return bQQ || bQZone;
}

+ (BOOL)handleOpenURL:(NSURL *)url {
    
    if ([TencentOAuth CanHandleOpenURL:url]) {
        return [TencentOAuth HandleOpenURL:url];
    }
    
    return NO;
}

+ (BOOL)handleOpenURL:(NSURL *)url sourceApplication:(NSString *)source annotation:(id)annotation {
    
    if ([QQApiInterface handleOpenURL:url delegate:[self sharedInstance]]) {
        return YES;
    }
    
    if ([TencentOAuth CanHandleOpenURL:url]) {
        return [TencentOAuth HandleOpenURL:url];
    }
    
    return NO;
}

- (void)setUpTencentAuth {
    if (!self.tencentAuth) {
        self.tencentAuth = [[TencentOAuth alloc] initWithAppId:kTencentAppId andDelegate:self];
    }
}

#pragma mark - QQ SSO 登陆相关
#pragma mark - TencentLoginDelegate

- (void)loginForQQWithDelegate:(id<SNQQHelperLoginDelegate>)delegate {
    self.loginDelegate = delegate;
    [self.tencentAuth authorize:@[@"all"] inSafari:NO];
}

- (void)loginForQQWebWithDelegate:(id<SNQQHelperLoginDelegate>)delegate {
    self.loginDelegate = delegate;
    [self.tencentAuth authorize:@[@"all"] inSafari:YES];
}

/**
 * 登录成功后的回调
 */
- (void)tencentDidLogin {
    SNDebugLog(@"%@", NSStringFromSelector(_cmd));
    // 登陆成功之后 获取用户信息
    [self.tencentAuth getUserInfo];
}

/**
 * 登录失败后的回调
 * \param cancelled 代表用户是否主动退出登录
 */
- (void)tencentDidNotLogin:(BOOL)cancelled {
    SNDebugLog(@"%@", NSStringFromSelector(_cmd));
    if (self.loginDelegate && [self.loginDelegate respondsToSelector:@selector(qqDidFailLoginWithError:)]) {
        [self.loginDelegate qqDidFailLoginWithError:[NSError errorWithDomain:@"user canceled" code:-4 userInfo:nil]];
    }
}

/**
 * 登录时网络有问题的回调
 */
- (void)tencentDidNotNetWork {
    SNDebugLog(@"%@", NSStringFromSelector(_cmd));
    if (self.loginDelegate && [self.loginDelegate respondsToSelector:@selector(qqDidFailLoginWithError:)]) {
        [self.loginDelegate qqDidFailLoginWithError:[NSError errorWithDomain:@"not network" code:-500 userInfo:nil]];
    }
}

#pragma mark - TencentSessionDelegate

/**
 * \brief TencentSessionDelegate iOS Open SDK 1.3 API回调协议
 *
 * 第三方应用需要实现每条需要调用的API的回调协议
 */

/**
 * 退出登录的回调
 */
- (void)tencentDidLogout {
    
}

/**
 * 因用户未授予相应权限而需要执行增量授权。在用户调用某个api接口时，如果服务器返回操作未被授权，则触发该回调协议接口，由第三方决定是否跳转到增量授权页面，让用户重新授权。
 * \param tencentOAuth 登录授权对象。
 * \param permissions 需增量授权的权限列表。
 * \return 是否仍然回调返回原始的api请求结果。
 * \note 不实现该协议接口则默认为不开启增量授权流程。若需要增量授权请调用\ref TencentOAuth#incrAuthWithPermissions: \n注意：增量授权时用户可能会修改登录的帐号
 */
- (BOOL)tencentNeedPerformIncrAuth:(TencentOAuth *)tencentOAuth withPermissions:(NSArray *)permissions {
    return NO;
}

/**
 * [该逻辑未实现]因token失效而需要执行重新登录授权。在用户调用某个api接口时，如果服务器返回token失效，则触发该回调协议接口，由第三方决定是否跳转到登录授权页面，让用户重新授权。
 * \param tencentOAuth 登录授权对象。
 * \return 是否仍然回调返回原始的api请求结果。
 * \note 不实现该协议接口则默认为不开启重新登录授权流程。若需要重新登录授权请调用\ref TencentOAuth#reauthorizeWithPermissions: \n注意：重新登录授权时用户可能会修改登录的帐号
 */
- (BOOL)tencentNeedPerformReAuth:(TencentOAuth *)tencentOAuth {
    return YES;
}

/**
 * 用户通过增量授权流程重新授权登录，token及有效期限等信息已被更新。
 * \param tencentOAuth token及有效期限等信息更新后的授权实例对象
 * \note 第三方应用需更新已保存的token及有效期限等信息。
 */
- (void)tencentDidUpdate:(TencentOAuth *)tencentOAuth {
    
}

/**
 * 用户增量授权过程中因取消或网络问题导致授权失败
 * \param reason 授权失败原因，具体失败原因参见sdkdef.h文件中\ref UpdateFailType
 */
- (void)tencentFailedUpdate:(UpdateFailType)reason {
    
}

/**
 * 获取用户个人信息回调
 * \param response API返回结果，具体定义参见sdkdef.h文件中\ref APIResponse
 * \remarks 正确返回示例: \snippet example/getUserInfoResponse.exp success
 *          错误返回示例: \snippet example/getUserInfoResponse.exp fail
 */
- (void)getUserInfoResponse:(APIResponse*) response {
    SNDebugLog(@"%@- response %@ msg %@", NSStringFromSelector(_cmd), response.jsonResponse, response.message);
    if (response.retCode == URLREQUEST_SUCCEED
        && response.jsonResponse
        && [response.jsonResponse isKindOfClass:[NSDictionary class]]) {
        self.loginUserInfoDic = [NSMutableDictionary dictionaryWithDictionary:response.jsonResponse];
        if (self.loginDelegate && [self.loginDelegate respondsToSelector:@selector(qqDidLogin)]) {
            [self.loginDelegate qqDidLogin];
        }
    }
    else {
        if (self.loginDelegate && [self.loginDelegate respondsToSelector:@selector(qqDidFailLoginWithError:)]) {
            NSString *domain = response.message;
            if (!domain) {//QQ未知错误
                domain = @"not know";
            }
            [self.loginDelegate qqDidFailLoginWithError:[NSError errorWithDomain:domain code:response.retCode userInfo:response.jsonResponse]];
        }
    }
}

/**
 * 获取用户QZone相册列表回调
 * \param response API返回结果，具体定义参见sdkdef.h文件中\ref APIResponse
 * \remarks 正确返回示例: \snippet example/getListAlbumResponse.exp success
 *          错误返回示例: \snippet example/getListAlbumResponse.exp fail
 */
- (void)getListAlbumResponse:(APIResponse*) response {
    
}

/**
 * 获取用户QZone相片列表
 * \param response API返回结果，具体定义参见sdkdef.h文件中\ref APIResponse
 * \remarks 正确返回示例: \snippet example/getListPhotoResponse.exp success
 *          错误返回示例: \snippet example/getListPhotoResponse.exp fail
 */
- (void)getListPhotoResponse:(APIResponse*) response {
    
}

/**
 * 检查是否是QZone某个用户的粉丝回调
 * \param response API返回结果，具体定义参见sdkdef.h文件中\ref APIResponse
 * \remarks 正确返回示例: \snippet example/checkPageFansResponse.exp success
 *          错误返回示例: \snippet example/checkPageFansResponse.exp fail
 */
- (void)checkPageFansResponse:(APIResponse*) response {
    
}

/**
 * 分享到QZone回调
 * \param response API返回结果，具体定义参见sdkdef.h文件中\ref APIResponse
 * \remarks 正确返回示例: \snippet example/addShareResponse.exp success
 *          错误返回示例: \snippet example/addShareResponse.exp fail
 */
- (void)addShareResponse:(APIResponse*) response {
    SNDebugLog(@"%@- error msg %@", NSStringFromSelector(_cmd), response.message);
}

/**
 * 在QZone相册中创建一个新的相册回调
 * \param response API返回结果，具体定义参见sdkdef.h文件中\ref APIResponse
 * \remarks 正确返回示例: \snippet example/addAlbumResponse.exp success
 *          错误返回示例: \snippet example/addAlbumResponse.exp fail
 */
- (void)addAlbumResponse:(APIResponse*) response {
    
}

/**
 * 上传照片到QZone指定相册回调
 * \param response API返回结果，具体定义参见sdkdef.h文件中\ref APIResponse
 * \remarks 正确返回示例: \snippet example/uploadPicResponse.exp success
 *          错误返回示例: \snippet example/uploadPicResponse.exp fail
 */
- (void)uploadPicResponse:(APIResponse*) response {
    
}


/**
 * 在QZone中发表一篇日志回调
 * \param response API返回结果，具体定义参见sdkdef.h文件中\ref APIResponse
 * \remarks 正确返回示例: \snippet example/addOneBlogResponse.exp success
 *          错误返回示例: \snippet example/addOneBlogResponse.exp fail
 */
- (void)addOneBlogResponse:(APIResponse*) response {
    
}

/**
 * 在QZone中发表一条说说回调
 * \param response API返回结果，具体定义参见sdkdef.h文件中\ref APIResponse
 * \remarks 正确返回示例: \snippet example/addTopicResponse.exp success
 *          错误返回示例: \snippet example/addTopicResponse.exp fail
 */
- (void)addTopicResponse:(APIResponse*) response {
    
}

/**
 * 获取QQ会员信息回调
 * \param response API返回结果，具体定义参见sdkdef.h文件中\ref APIResponse
 * \remarks 正确返回示例: \snippet example/getVipInfoResponse.exp success
 *          错误返回示例: \snippet example/getVipInfoResponse.exp fail
 */
- (void)getVipInfoResponse:(APIResponse*) response {
    
}

/**
 * 获取QQ会员详细信息回调
 * \param response API返回结果，具体定义参见sdkdef.h文件中\ref APIResponse
 */
- (void)getVipRichInfoResponse:(APIResponse*) response {
    
}

/**
 * 获取微博好友名称输入提示回调
 * \param response API返回结果，具体定义参见sdkdef.h文件中\ref APIResponse
 * \remarks 正确返回示例: \snippet example/matchNickTipsResponse.exp success
 *          错误返回示例: \snippet example/matchNickTipsResponse.exp fail
 */
- (void)matchNickTipsResponse:(APIResponse*) response {
}

/**
 * 获取最近的微博好友回调
 * \param response API返回结果，具体定义参见sdkdef.h文件中\ref APIResponse
 * \remarks 正确返回示例: \snippet example/getIntimateFriendsResponse.exp success
 *          错误返回示例: \snippet example/getIntimateFriendsResponse.exp fail
 */
- (void)getIntimateFriendsResponse:(APIResponse*) response {
    
}

/**
 * 设置QQ头像回调
 * \param response API返回结果，具体定义参见sdkdef.h文件中\ref APIResponse
 * \remarks 正确返回示例: \snippet example/setUserHeadpicResponse.exp success
 *          错误返回示例: \snippet example/setUserHeadpicResponse.exp fail
 */
- (void)setUserHeadpicResponse:(APIResponse*) response {
    
}

/**
 * sendStory分享的回调（已废弃，使用responseDidReceived:forMessage:）
 * \param response API返回结果，具体定义参见sdkdef.h文件中\ref APIResponse
 */
- (void)sendStoryResponse:(APIResponse*) response {
    
}

/**
 * 社交API统一回调接口
 * \param response API返回结果，具体定义参见sdkdef.h文件中\ref APIResponse
 * \param message 响应的消息，目前支持‘SendStory’,‘AppInvitation’，‘AppChallenge’，‘AppGiftRequest’
 */
- (void)responseDidReceived:(APIResponse*)response forMessage:(NSString *)message {
    
}

/**
 * post请求的上传进度
 * \param tencentOAuth 返回回调的tencentOAuth对象
 * \param bytesWritten 本次回调上传的数据字节数
 * \param totalBytesWritten 总共已经上传的字节数
 * \param totalBytesExpectedToWrite 总共需要上传的字节数
 * \param userData 用户自定义数据
 */
- (void)tencentOAuth:(TencentOAuth *)tencentOAuth didSendBodyData:(NSInteger)bytesWritten totalBytesWritten:(NSInteger)totalBytesWritten totalBytesExpectedToWrite:(NSInteger)totalBytesExpectedToWrite userData:(id)userData {
}


/**
 * 通知第三方界面需要被关闭
 * \param tencentOAuth 返回回调的tencentOAuth对象
 * \param viewController 需要关闭的viewController
 */
- (void)tencentOAuth:(TencentOAuth *)tencentOAuth doCloseViewController:(UIViewController *)viewController {
    
}

#pragma mark - QQ分享相关
#pragma mark - QQApiInterfaceDelegate

/**
 处理来至QQ的请求
 */
- (void)onReq:(QQBaseReq *)req {
    SNDebugLog(@"%@- req is class [%@]", NSStringFromSelector(_cmd), NSStringFromClass([req class]));
}

/**
 处理来至QQ的响应
 */
- (void)onResp:(QQBaseResp *)resp {
    if ([resp isKindOfClass:[SendMessageToQQResp class]]) {
        [self handleSendToQQResp:(SendMessageToQQResp *)resp];
    }
}

/**
 处理QQ在线状态的回调
 */
- (void)isOnlineResponse:(NSDictionary *)response {
    SNDebugLog(@"%@- response is class [%@]", NSStringFromSelector(_cmd), NSStringFromClass([response class]));
}


#pragma mark - instance methods

- (void)shareTextToQQ:(NSString *)text {
    if (![self isQQReadyAndTell] || text.length == 0) {
        return;
    }
    
    QQApiTextObject* txt = [QQApiTextObject objectWithText:text];
    SendMessageToQQReq *req = [SendMessageToQQReq reqWithContent:txt];
    [self doSendShareRequest:req];
}

- (void)shareGifToQQ:(NSString *)gifUrl imageTitle:(NSString *)title description:(NSString *)description  {
   
    if (![self isQQReadyAndTell] && gifUrl) {
        return;
    }
    
    if (gifUrl) {
        NSURL* url = [NSURL URLWithString:gifUrl];
//        
//        NSURLRequest* request = [NSURLRequest requestWithURL:url cachePolicy:NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:5];
//        NSURLResponse* resp = [[NSURLResponse alloc] init];
//
//        NSData* data =[NSURLConnection sendSynchronousRequest:request returningResponse:&resp error:nil];
        
        
        NSURLSession* session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]];
       NSURLSessionDataTask* task = [session dataTaskWithURL:url completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
            
            dispatch_async(dispatch_get_main_queue(), ^{
                QQApiImageObject* img = [QQApiImageObject objectWithData:data previewImageData:nil title:title description:description];
                
                SendMessageToQQReq *req = [SendMessageToQQReq reqWithContent:img];
                [self doSendShareRequest:req];
            });
        }];
        [task resume];
    }
}

- (void)shareImageToQQ:(NSData *)imageData imageTitle:(NSString *)title description:(NSString *)description {
    if (![self isQQReadyAndTell] || imageData.length == 0) {
        return;
    }
    
    
    QQApiImageObject* img = [QQApiImageObject objectWithData:_imageCompress(imageData, _ShareTypeImage)
                                            previewImageData:_imageCompress(imageData, _ShareTypeImageThumb)
                                                       title:title
                                                 description:description];
    
    SendMessageToQQReq *req = [SendMessageToQQReq reqWithContent:img];
    [self doSendShareRequest:req];
}

- (void)shareNewsToQQ:(NSString *)content title:(NSString *)title thumbImage:(NSData *)imageData webUrl:(NSString *)url {
    self.shareUrl = url;
    if (![self isQQReadyAndTell]) {
        return;
    }
    
    if (url.length > 0) {
        if ([title isEqualToString:content]) {
            //关于页分享 微信那边兼容不了，qq兼容一下吧 微信要是兼容了，关于页是好了，股票又不行了
            title = @"搜狐新闻";
        }
        QQApiNewsObject* img = [QQApiNewsObject objectWithURL:[NSURL URLWithString:url]
                                                        title:title
                                                  description:content
                                             previewImageData:_imageCompress(imageData, _ShareTypeNewsImage)];
        
        SendMessageToQQReq *req = [SendMessageToQQReq reqWithContent:img];
        [self doSendShareRequest:req];
    }
    else {
        [self shareTextToQQ:content];
    }
}

- (void)shareMediaToQQ:(NSString *)content title:(NSString *)title thumbImage:(NSData *)imageData mediaUrl:(NSString *)mediaUrl mediaType:(QQApiURLTargetType)mediaType {
    if (![self isQQReadyAndTell]) {
        return;
    }
    
    if (mediaUrl.length > 0) {
        QQApiObject* obj = nil;
        if (mediaType == QQApiURLTargetTypeNews) {
            obj = [QQApiNewsObject objectWithURL:[NSURL URLWithString:mediaUrl]
                                           title:title
                                     description:content
                                previewImageData:_imageCompress(imageData, _ShareTypeNewsImage)];
        }
        else if (mediaType == QQApiURLTargetTypeAudio) {
            obj = [QQApiAudioObject objectWithURL:[NSURL URLWithString:mediaUrl]
                                            title:title
                                      description:content
                                 previewImageData:_imageCompress(imageData, _ShareTypeNewsImage)];
        }
        else if (mediaType == QQApiURLTargetTypeVideo) {
            obj = [QQApiVideoObject objectWithURL:[NSURL URLWithString:mediaUrl]
                                            title:title
                                      description:content
                                 previewImageData:_imageCompress(imageData, _ShareTypeNewsImage)];
        }
        else {
            obj = [QQApiURLObject objectWithURL:[NSURL URLWithString:mediaUrl]
                                          title:title
                                    description:content
                               previewImageData:_imageCompress(imageData, _ShareTypeNewsImage)
                              targetContentType:mediaType];
        }
        
        if (obj) {
            SendMessageToQQReq *req = [SendMessageToQQReq reqWithContent:obj];
            [self doSendShareRequest:req];
        }
    }
    else {
        [self shareTextToQQ:content];
    }
}

#pragma mark - private

- (void)handleSendToQQResp:(SendMessageToQQResp *)resp {
    // 分享qq成功
    if ([resp.result intValue] == 0) {
        // 成功
        double delayInSeconds = 2.0;
        dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
        dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
//            [[SNStatusBarMessageCenter sharedInstance] postImmediateMessage:@"分享QQ成功"];
            @try {
                if (self.delegate && [self.delegate respondsToSelector:@selector(shareToThirdPartSuccess:)]) {
                    [self.delegate performSelector:@selector(shareToThirdPartSuccess:) withObject:@(self.isShareToQZone ? ShareTargetQZone : ShareTargetQQ_friends)];
                    NSString *shareProtocol = [SNUtility changeSohuLinkToProtocol:self.shareUrl];
                    if (shareProtocol.length == 0) {
                        shareProtocol = [NSString stringWithFormat:@"news://newIs="];
                    }
                    [SNUtility requestRedPackerAndCoupon:shareProtocol type:@"1"];
                }
            }
            @catch (NSException *exception) {
                
            }
            @finally {
                
            }
        });
    }
    // 取消分享
    else if ([resp.result intValue] == -4) {
        SNDebugLog(@"%@", resp.errorDescription);
    }
    // 分享qq失败
    else {
        double delayInSeconds = 2.0;
        dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
        dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
            [[SNCenterToast shareInstance] showCenterToastWithTitle:@"分享QQ失败" toUrl:nil mode:SNCenterToastModeWarning];
        });
    }
}

- (BOOL)isQQReadyAndTell {
    BOOL bRet = YES;
    if (![QQApiInterface isQQInstalled] || ![QQApiInterface isQQSupportApi]) {
        bRet = NO;
        
        [[SNCenterToast shareInstance] showCenterToastWithTitle:NSLocalizedString(@"QQ not installed", @"") toUrl:nil mode:SNCenterToastModeWarning];
    }
    else if (![QQApiInterface isQQSupportApi]) {
        bRet = NO;
        [[SNCenterToast shareInstance] showCenterToastWithTitle:NSLocalizedString(@"QQ not suported", @"") toUrl:nil mode:SNCenterToastModeWarning];
    }
    
    return bRet;
}

- (BOOL)doSendShareRequest:(QQBaseReq *)req {
    QQApiSendResultCode result = EQQAPISENDSUCESS;
    
    if (self.isShareToQZone) {
        result = [QQApiInterface SendReqToQZone:req];
    }
    else {
        result = [QQApiInterface sendReq:req];
    }
    
    return result == EQQAPISENDSUCESS;
}

@end
