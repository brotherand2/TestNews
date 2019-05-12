//
//  SNWXHelper.m
//  sohunews
//
//  Created by yanchen wang on 12-5-22.
//  Copyright (c) 2012年 Sohu.com Inc. All rights reserved.
//

#import "SNWXHelper.h"
#import "SNStatusBarMessageCenter.h"
#import "UIImage+MultiFormat.h"
#import "SNNotificationCenter.h"
#import "SNWeixinOauthRequest.h"
#import "SNSSOWXWrapper.h"
#import "NSJSONSerialization+String.h"
#import "SNNewsThirdLoginEnable.h"
#import "SNSLib.h"
#import "SNUserManager.h"
#import "SNNewsRecordLastLogin.h"

#import "SNNewsSSOOpenUrl.h"

#define MAX_SHARE_IMAGE_SIZE    (9 * 1024 * 1024)
#define MAX_SHARE_NEWSIMAGE_SIZE    (30 * 1024)

NSData *_imageCompressSize(NSData *sourceData, long sizeLimit) {
    CGFloat compression = 0.9f;
    CGFloat maxCompression = 0.1f;
    NSInteger maxFileSize = sizeLimit;
    
#if DEBUG_MODE
    SNDebugLog(@"======= weixin image compress before compress: source data length %d max length %ld", sourceData.length, sizeLimit);
#endif
    
    UIImage *image = [UIImage sd_imageWithData:sourceData];
    NSData *imageData = UIImageJPEGRepresentation(image, compression);
    
#if DEBUG_MODE
    SNDebugLog(@"======= weixin image compress in compress rate[%f]: source data length %d max length %ld", compression, imageData.length, sizeLimit);
#endif
    
    while ([imageData length] > maxFileSize && compression > maxCompression) {
        compression -= 0.1;
        imageData = UIImageJPEGRepresentation(image, compression);
#if DEBUG_MODE
        SNDebugLog(@"======= weixin image compress in compress rate[%f]: source data length %d max length %ld", compression, imageData.length, sizeLimit);
#endif
    }
    
    
#if DEBUG_MODE
    SNDebugLog(@"======= weixin image compress after done: source data length %d max length %ld", imageData.length, sizeLimit);
#endif
    
    return imageData;
}


// 图片压缩: type == > 0 图片分享  1 新闻图片分享
NSData *_imageCompress(NSData *sourceData, _ShareType type) {
    
    NSUInteger dataLen = [sourceData length];
    long maxSize = 0;
    if (_ShareTypeImage == type) {
        maxSize = MAX_SHARE_IMAGE_SIZE;
    }
    else if (_ShareTypeNewsImage == type || _ShareTypeImageThumb == type) {
        maxSize = MAX_SHARE_NEWSIMAGE_SIZE;
    }
    
#if DEBUG_MODE
    SNDebugLog(@"======= weixin image compress type[%d] before compress: source data length %d max length %ld", type, dataLen, maxSize);
#endif
    
    if (dataLen > maxSize) {
        
        // 第一次降质压缩
        if (dataLen > maxSize)
            sourceData = _imageCompressSize(sourceData, maxSize);
        
        dataLen = sourceData.length;
        
#if DEBUG_MODE
        SNDebugLog(@"======= weixin image compress type[%d] after first quality compress: source data length %d max length %ld", type, dataLen, maxSize);
#endif
        
        // 第二次降质压缩
        if (dataLen > maxSize)
            sourceData = _imageCompressSize(sourceData, maxSize);
        
        dataLen = sourceData.length;
        
#if DEBUG_MODE
        SNDebugLog(@"======= weixin image compress type[%d] after second quality compress: source data length %d max length %ld", type, dataLen, maxSize);
#endif
    }
    
    // 如果图像大小还是没有实质性减小  改变图片大小 
    if (dataLen > maxSize) {
        CGFloat ratio = (float)maxSize / (float)dataLen;
        
        UIImage *image = [UIImage sd_imageWithData:sourceData];
        UIImage *scaledImage = nil;
        CGSize newSize;
        
        if (_ShareTypeNewsImage == type) {
            CGFloat tmpImageMinSize = MIN(image.size.width, image.size.height);
            CGFloat iconSize = (int)(tmpImageMinSize * ratio);
            newSize = CGSizeMake(iconSize, iconSize);
        }
        else {
            newSize = CGSizeMake((int)((image.size.width * ratio)/2), (int)((image.size.height * ratio)/2));
        }
        
#if DEBUG_MODE
        SNDebugLog(@"======= weixin image compress type[%d]: compress ratio %g originSize %@ newSize %@", type, ratio, NSStringFromCGSize(image.size), NSStringFromCGSize(newSize));
#endif
        
        if (UIGraphicsBeginImageContextWithOptions != NULL) {
            UIGraphicsBeginImageContextWithOptions(newSize, YES, 1.0);
        } else {
            UIGraphicsBeginImageContext(newSize);
        }
        
        [image drawInRect:CGRectMake(0, 0, newSize.width, newSize.height)];
        scaledImage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        
        NSData * newData = UIImageJPEGRepresentation(scaledImage, 1.0);
        
#if DEBUG_MODE
        SNDebugLog(@"======= weixin image compress type[%d]: compress ratio %g newDataLengh %d", type, ratio, [newData length]);
#endif
        
        return newData;
    }
    
    return sourceData;
}

@implementation SNWXHelper

@synthesize delegate = _delegate;
@synthesize scene = _scene;

- (SNWXHelper *)init {
    self = [super init];
    if (self) {
        self.scene = WXSceneSession;
    }
    return self;
}

- (void)dealloc {
}

+ (SNWXHelper *)sharedInstance {
    static SNWXHelper *_instance = nil;
    @synchronized(self) {
        if (nil == _instance) {
            _instance = [[SNWXHelper alloc] init];
        }
    }
    return _instance;
}

+ (BOOL)initWXApi {
    if (isINHOUSE) {
        return [WXApi registerApp:kWX_APP_ID_Inhouse enableMTA:NO];
    }
    return [WXApi registerApp:kWX_APP_ID enableMTA:NO];
}

+ (BOOL)isWeixinReady {
    return [self weixinStatus] == SNWXStatusWeixinReady;
}

+ (SNWXStatus)weixinStatus {
    if (![WXApi isWXAppInstalled]) 
        return SNWXStatusWeixinNotInstall;
    else if (![WXApi isWXAppSupportApi])
        return SNWXStatusWeixinUnsuporedApi;
    else
        return SNWXStatusWeixinReady;
}

- (void)_callBackDelegate:(int)type errCode:(SNWXErrorCode)errCode errStr:(NSString *)errStr {
//    if ([_delegate conformsToProtocol:@protocol(SNWXHelpDelegate)] &&
//        [_delegate respondsToSelector:@selector(didReceiveWeixinResponse:errCode:errorStr:)]) {
//        [_delegate didReceiveWeixinResponse:type errCode:errCode errorStr:errStr];
//    }
    [self didReceiveWeixinResponse:type errCode:errCode errorStr:errStr];
}

#pragma mark - SNWXHelper delegates
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wundeclared-selector"
- (void)didReceiveWeixinResponse:(int)type errCode:(SNWXErrorCode)errCode errorStr:(NSString *)errorStr {
    switch (errCode) {
        case SNWXErrorSuccess:
            // report log to server
            if (self.delegate && [self.delegate respondsToSelector:@selector(shareToThirdPartSuccess:)]) {
                ShareTargetType type = ShareTargetWeixinFriend;
                if (self.scene == WXSceneTimeline) {
                    type = ShareTargetWeixinTimeline;
                }
                if ([self.delegate respondsToSelector:@selector(shareToThirdPartSuccess:)]) {
                    [self.delegate performSelector:@selector(shareToThirdPartSuccess:) withObject:@(type)];
                    [self showMessageWithDelay:NSLocalizedString(@"ShareSucceed", @"")];
                }
            }
            break;
        case SNWXErrorCommon:
            [self showMessageWithDelay:NSLocalizedString(@"Weixin error common", @"")];
            break;
        case SNWXErrorSentFail:
            [self showMessageWithDelay:NSLocalizedString(@"Weixin sent fail", @"")];
            break;
        case SNWXErrorAuthDeny:
            [self showMessageWithDelay:NSLocalizedString(@"Weixin auty deny", @"")];
            break;
        case SNWXErrorUserCancel:
            break;
        case SNWXErrorWeixinUninstall:
            [[SNCenterToast shareInstance] showCenterToastWithTitle:NSLocalizedString(@"Weixin not installed", @"") toUrl:nil mode:SNCenterToastModeWarning];
            break;
        case SNWXErrorUnsuportedApi:
            [[SNCenterToast shareInstance] showCenterToastWithTitle:NSLocalizedString(@"Weixin not suported", @"") toUrl:nil mode:SNCenterToastModeWarning];
            break;
        case SNWXErrorException:
            [[SNCenterToast shareInstance] showCenterToastWithTitle:NSLocalizedString(@"Weixin error common", @"") toUrl:nil mode:SNCenterToastModeWarning];
            break;
            
        default:
            break;
    }
}
#pragma clang diagnostic pop

- (void)showMessageWithDelay:(NSString *)msg {
    double delayInSeconds = 2.0;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        if ([msg isEqualToString:NSLocalizedString(@"ShareSucceed", @"")]) {
            NSString *urlString = [NSString stringWithFormat:@"%@corpusId=", kProtocolOpenCorpus];
//            [[SNCenterToast shareInstance] showCenterToastWithTitle:NSLocalizedString(@"ShareSucceed", @"ShareSucceed") toUrl:nil mode:SNCenterToastModeSuccess];
            NSString *shareProtocol = [SNUtility changeSohuLinkToProtocol:self.shareUrl];
            if (shareProtocol.length == 0) {
                shareProtocol = urlString;
            }
            [SNUtility requestRedPackerAndCoupon:shareProtocol type:@"1"];
        }
        else {
            [[SNCenterToast shareInstance] showCenterToastWithTitle:msg toUrl:nil mode:SNCenterToastModeWarning];
        }
    });
}

- (void)shareTextToWeixin:(NSString *)text {
    
    if (SNWXStatusWeixinNotInstall == [SNWXHelper weixinStatus]) {
        return [self _callBackDelegate:0 errCode:SNWXErrorWeixinUninstall errStr:nil];
    }
    else if (SNWXStatusWeixinUnsuporedApi == [SNWXHelper weixinStatus]) {
        return [self _callBackDelegate:0 errCode:SNWXErrorUnsuportedApi errStr:nil];
    }
    
    if (text) {
        SendMessageToWXReq* req = [[SendMessageToWXReq alloc] init];
        req.bText = YES;
        req.text = text;
        req.scene = self.scene;

        
        [self callWeiXin:req];
//        NSException *ecp = nil;
//        @try {
//            [WXApi sendReq:req];
//        }
//        @catch (NSException *exception) {
//            ecp = exception;
//            SNDebugLog(@"%@--%@ error with exception %@", NSStringFromClass([self class]), NSStringFromSelector(_cmd), exception);
//        }
//        @finally {
//            if (ecp) {
//                [self _callBackDelegate:0 errCode:SNWXErrorException errStr:[ecp reason]];
//            }
//        }
    }
    
}

- (void)shareImageToWeixin:(NSData *)imageData imageTitle:(NSString *)title {
    
    if (SNWXStatusWeixinNotInstall == [SNWXHelper weixinStatus]) {
        return [self _callBackDelegate:0 errCode:SNWXErrorWeixinUninstall errStr:nil];
    }
    else if (SNWXStatusWeixinUnsuporedApi == [SNWXHelper weixinStatus]) {
        return [self _callBackDelegate:0 errCode:SNWXErrorUnsuportedApi errStr:nil];
    }
    
    if (imageData) {
        WXMediaMessage *message = [WXMediaMessage message];
        
        NSData *tmpData = _imageCompress(imageData, _ShareTypeImageThumb);
        
        [message setThumbData:_imageCompress(tmpData, _ShareTypeImageThumb)];
        [message setTitle:title];
        
        WXImageObject *ext = [WXImageObject object];
        ext.imageData = _imageCompress(imageData, _ShareTypeImage);
        
        message.mediaObject = ext;
        
        SendMessageToWXReq* req = [[SendMessageToWXReq alloc] init];
        req.bText = NO;
        req.message = message;
        req.scene = self.scene;

        [self callWeiXin:req];
//        NSException *ecp = nil;
//        @try {
//            BOOL result = [WXApi sendReq:req];
//            if (!result) {
//                SNDebugLog(@"WXApi sendReq error");
//            }
//        }
//        @catch (NSException *exception) {
//            ecp = exception;
//            SNDebugLog(@"%@--%@ error with exception %@", NSStringFromClass([self class]), NSStringFromSelector(_cmd), exception);
//        }
//        @finally {
//            if (ecp) {
//                [self _callBackDelegate:0 errCode:SNWXErrorException errStr:[ecp reason]];
//            }
//        }
    }
    
}

- (void)shareGifToWeixin:(NSString*)gifUrl ImageData:(NSData*)imgData{
    if (gifUrl) {
        NSURL* url = [NSURL URLWithString:gifUrl];
        NSURLSession* session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]];
        NSURLSessionDataTask* task = [session dataTaskWithURL:url completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
            
            dispatch_async(dispatch_get_main_queue(), ^{
                
//                WXMediaMessage* message = [WXMediaMessage message];
//                WXImageObject* img_obj = [WXImageObject object];
//                img_obj.imageData = data;
//                message.mediaObject = img_obj;
//                [message setThumbImage:[UIImage imageWithData:data]];
                
                WXMediaMessage *message = [WXMediaMessage message];
                [message setThumbImage:[UIImage imageWithData:data]];
                
                WXEmoticonObject *ext = [WXEmoticonObject object];
                ext.emoticonData = data;
                
                message.mediaObject = ext;
                
                SendMessageToWXReq* req = [[SendMessageToWXReq alloc] init];
                req.bText = NO;
                req.message = message;
                req.scene = self.scene;
                
                [self callWeiXin:req];
//                NSException *ecp = nil;
//                @try {
//                    BOOL result = [WXApi sendReq:req];
//                    if (!result) {
//                        SNDebugLog(@"WXApi sendReq error");
//                    }
//                }
//                @catch (NSException *exception) {
//                    ecp = exception;
//                    SNDebugLog(@"%@--%@ error with exception %@", NSStringFromClass([self class]), NSStringFromSelector(_cmd), exception);
//                }
//                @finally {
//                    if (ecp) {
//                        [self _callBackDelegate:0 errCode:SNWXErrorException errStr:[ecp reason]];
//                    }
//                }
                
            });
        }];
        [task resume];
        
    }
}

- (void)shareNewsToWeixin:(NSString *)content title:(NSString *)title thumbImage:(NSData *)imageData webUrl:(NSString *)url {
    self.shareUrl = url;
    if (SNWXStatusWeixinNotInstall == [SNWXHelper weixinStatus]) {
        return [self _callBackDelegate:0 errCode:SNWXErrorWeixinUninstall errStr:nil];
    }
    else if (SNWXStatusWeixinUnsuporedApi == [SNWXHelper weixinStatus]) {
        return [self _callBackDelegate:0 errCode:SNWXErrorUnsuportedApi errStr:nil];
    }
    
    if (!content) {
        return;
    }
    if (url) {
        WXMediaMessage *message = [WXMediaMessage message];
        NSString *tempTitle = (title && [title length]) ? title : NSLocalizedString(@"Sohu share", @"");
        if (self.scene == WXSceneSession) {
            message.title = tempTitle;
        }
        else if (self.scene == WXSceneTimeline) { // 朋友圈 只显示title太没有吸引力，故title也显示摘要
            //股票必须显示title wangshun 没吸引力就没吸引力吧
            message.title = tempTitle;
        }
        message.description = content;
        
        if (imageData) {
            // 压缩两遍 安全一点点： 因为按照大小比例压出来的 大小不是完全按照这个比例的 所以 有可能压完还是超过限制
            imageData = _imageCompress(imageData, _ShareTypeNewsImage);
            message.thumbData = _imageCompress(imageData, _ShareTypeNewsImage);
        }
        
        WXWebpageObject *ext = [WXWebpageObject object];
        ext.webpageUrl = url;
        
        message.mediaObject = ext;
        
        SendMessageToWXReq* req = [[SendMessageToWXReq alloc] init];
        req.bText = NO;
        req.message = message;
        req.scene = self.scene;
        
        [self callWeiXin:req];
        
//        NSException *ecp = nil;
//        @try {
//           BOOL send =  [WXApi sendReq:req];
//            if (!send) {
//                SNDebugLog(@"WXApi sendReq error！");
//            }
//        }
//        @catch (NSException *exception) {
//            ecp = exception;
//            SNDebugLog(@"%@--%@ error with exception %@", NSStringFromClass([self class]), NSStringFromSelector(_cmd), exception);
//        }
//        @finally {
//            if (ecp) {
//                [self _callBackDelegate:0 errCode:SNWXErrorException errStr:[ecp reason]];
//            }
//        }
    }
    else {
        [self shareTextToWeixin:content];
    }
}

- (void)shareMediaMessageToWeixin:(NSString *)content title:(NSString *)title thumbImage:(NSData *)imageData mediaUrl:(NSString *)mediaUrl mediaType:(SNWXMediaMessageType)mediaType {
    if (SNWXStatusWeixinNotInstall == [SNWXHelper weixinStatus]) {
        return [self _callBackDelegate:0 errCode:SNWXErrorWeixinUninstall errStr:nil];
    }
    else if (SNWXStatusWeixinUnsuporedApi == [SNWXHelper weixinStatus]) {
        return [self _callBackDelegate:0 errCode:SNWXErrorUnsuportedApi errStr:nil];
    }
    
    if (mediaUrl.length > 0) {
        id mediaObject = nil;
        
        if (mediaType == SNWXMediaMessageTypeVideo) {
            mediaObject = [WXVideoObject object];
            [(WXVideoObject *)mediaObject setVideoUrl:mediaUrl];
        }
        
        if (mediaObject) {
            WXMediaMessage *message = [WXMediaMessage message];
            NSString *tempTitle = @"搜狐新闻客户端";//(title && [title length]) ? title : NSLocalizedString(@"Sohu share", @"");
            if (self.scene == WXSceneSession) {
                message.title = tempTitle;
            }
            else if (self.scene == WXSceneTimeline) { // 朋友圈 只显示title太没有吸引力，故title也显示摘要
                message.title = content;//[NSString stringWithFormat:@"%@ : %@", tempTitle, content];
            }
            message.description = content;
            
            if (imageData) {
                // 压缩两遍 安全一点点： 因为按照大小比例压出来的 大小不是完全按照这个比例的 所以 有可能压完还是超过限制
                imageData = _imageCompress(imageData, _ShareTypeNewsImage);
                message.thumbData = _imageCompress(imageData, _ShareTypeNewsImage);
            }
            
            message.mediaObject = mediaObject;
            
            SendMessageToWXReq* req = [[SendMessageToWXReq alloc] init];
            req.bText = NO;
            req.message = message;
            req.scene = self.scene;

            [self callWeiXin:req];
//            NSException *ecp = nil;
//            @try {
//                BOOL send =  [WXApi sendReq:req];
//                if (!send) {
//                    SNDebugLog(@"WXApi sendReq error！");
//                }
//            }
//            @catch (NSException *exception) {
//                ecp = exception;
//                SNDebugLog(@"%@--%@ error with exception %@", NSStringFromClass([self class]), NSStringFromSelector(_cmd), exception);
//            }
//            @finally {
//                if (ecp) {
//                    [self _callBackDelegate:0 errCode:SNWXErrorException errStr:[ecp reason]];
//                }
//            }
        }
        
    }
    else {
        [self shareTextToWeixin:content];
    }
}

- (void)callWeiXin:(BaseReq*)req{
    
    if (isINHOUSE) {//wangshun inhouse 和 appstore 不是一个bundleid passport不想兼容俩
        [WXApi registerApp:kWX_APP_ID_Inhouse];
    }
    
    NSException *ecp = nil;
    @try {
        BOOL result = [WXApi sendReq:req];
        if (!result) {
            SNDebugLog(@"WXApi sendReq error");
        }
    }
    @catch (NSException *exception) {
        ecp = exception;
        SNDebugLog(@"%@--%@ error with exception %@", NSStringFromClass([self class]), NSStringFromSelector(_cmd), exception);
    }
    @finally {
        if (ecp) {
            [self _callBackDelegate:0 errCode:SNWXErrorException errStr:[ecp reason]];
        }
    }

}

#pragma mark - WXApiDelegate

/*! @brief 收到一个来自微信的请求，处理完后调用sendResp
 *
 * 收到一个来自微信的请求，异步处理完成后必须调用sendResp发送处理结果给微信。
 * 可能收到的请求有GetMessageFromWXReq、ShowMessageFromWXReq等。
 * @param req 具体请求内容，是自动释放的
 */
- (void)onReq:(BaseReq*)req {
    
}

/*! @brief 发送一个sendReq后，收到微信的回应
 *
 * 收到一个来自微信的处理结果。调用一次sendReq后会收到onResp。
 * 可能收到的处理结果有SendMessageToWXResp、SendAuthResp等。
 * @param resp具体的回应内容，是自动释放的
 */
- (void)onResp:(BaseResp*)resp {
    if ([resp isKindOfClass:[SendMessageToWXResp class]]) {
        [self _callBackDelegate:resp.type errCode:resp.errCode errStr:resp.errStr];
    }
    else if ([resp isKindOfClass:[SendAuthResp class]]) {
        SendAuthResp *authResp = (SendAuthResp *)resp;
        if (authResp.code) {
            [self setURLWithCode:authResp.code];
        }
    }
}

#pragma mark get weixin token
- (void)setURLWithCode:(NSString *)code {
    
    //截屏分享
    if (self.screenShare_WeiXinDel && [self.screenShare_WeiXinDel respondsToSelector:@selector(setWeiXinURLWithCode:)]) {
        [self.screenShare_WeiXinDel setWeiXinURLWithCode:code];
        return;
    }
    
    [SNNewsThirdLoginEnable sharedInstance].isLanding = YES;
    [[SNCenterToast shareInstance] showWithTitle:@"正在登录.."];
    
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithCapacity:1];
    [params setValue:code forKey:@"code"];
    
    if (isINHOUSE) {//等重构吧 inhouse 和 appstore 不是一个bundleid passport不想兼容俩
        [WXApi registerApp:kWX_APP_ID_Inhouse enableMTA:NO];
    }
    
    [[[SNWeixinOauthRequest alloc] initWithDictionary:params] send:^(SNBaseRequest *request, id requestDict) {
        NSString *access_token = [requestDict objectForKey:@"access_token"];
        NSString *expires_in = [requestDict objectForKey:@"expires_in"];//获取的是秒，需要转为NSDate类型
        NSDate *expireDate = [NSString getDateFromSecond:expires_in];
        NSString *refresh_token = [requestDict objectForKey:@"refresh_token"];
        NSString *openid = [requestDict objectForKey:@"openid"];
        NSString* expire =[NSString stringWithFormat:@"%zd",(long long)[expireDate timeIntervalSince1970]];
        
        if (self.resp_weixin != nil) {
            self.resp_weixin = nil;
        }
        self.resp_weixin = requestDict;
        
        //wangshun
        //原来直接同步信息
        //现在加入绑定流程 wangshun 2017.3.6
        
        if (self.bingPhone != nil) {
            self.bingPhone = nil;
        }
        
        NSDictionary* params = @{@"openId":openid,@"refresh_token":refresh_token,@"token":access_token,@"expire":expire,@"appId":@"wechat",@"from":@"login"};
        self.bingPhone = [[SNLoginLaterBingPhone alloc] initWithDelegate:self];
        [self.bingPhone bindThirdPartyLogin:params];
        
//      [[SNShareManager defaultManager] syncToken:access_token refreshToken:refresh_token expire:expireDate userName:nil userId:openid appId:@"8"];
        
    } failure:^(SNBaseRequest *request, NSError *error) {
        [[SNCenterToast shareInstance] hideToast];
        [[SNCenterToast shareInstance] showCenterToastWithTitle:NSLocalizedString(@"network error", @"") toUrl:nil mode:SNCenterToastModeError];
        [SNNewsThirdLoginEnable sharedInstance].isLanding = NO;
    }];
}


//同步用户信息
- (void)syncTokenLoginInfo:(NSDictionary *)responseDic{

    NSDictionary* requestDict = responseDic;
    
    NSString *access_token = [requestDict objectForKey:@"access_token"];
    NSString *expires_in = [requestDict objectForKey:@"expires_in"];//获取的是秒，需要转为NSDate类型
    NSDate *expireDate = [NSString getDateFromSecond:expires_in];
    NSString *refresh_token = [requestDict objectForKey:@"refresh_token"];
    NSString *openid = [requestDict objectForKey:@"openid"];
    
    [[SNShareManager defaultManager] syncToken:access_token refreshToken:refresh_token expire:expireDate userName:nil userId:openid appId:@"8"];
}

#pragma mark -  sns 埋点

- (void)burySuccess:(NSString*)sender{
    NSString* loginType = @"wechat";
    NSString* sourceChannelID = [SNShareManager defaultManager].loginFrom;
    NSDictionary* dic = @{@"loginSuccess":sender?:@"",@"loginType":loginType,@"cid":[SNUserManager getP1]};
    if ([sender isEqualToString:@"-1"]) {
        dic = @{@"loginSuccess":sender?:@"",@"loginType":loginType,@"errType":@"0",@"cid":[SNUserManager getP1]};
    }
    
    SNDebugLog(@"第三方 sourceChannelID ::::%@ dic:%@",sourceChannelID,dic);
    
    if (sourceChannelID && ![sourceChannelID isEqualToString:@"-1"]) {
        [SNSLib addCountForSohuNewsLoginEventWithKey:sourceChannelID bodyDic:dic];
    }
}


#pragma mark - SNLoginLaterBingPhoneDelegate

-(void)loginSuccessed:(NSDictionary*)data{
    //[self syncTokenLoginInfo:self.resp_weixin];
    [[SNCenterToast shareInstance] hideToast];
    [[SNCenterToast shareInstance] showWithTitle:@"登录成功"];
    [self burySuccess:@"1"];
    if (self.thirdLoginSuccess) {
        self.thirdLoginSuccess = nil;
    }
    if (data == nil) {
        data = self.userInfoDic;
    }
    self.thirdLoginSuccess = [[SNThirdLoginSuccess alloc] init];
    self.thirdLoginSuccess.appId = @"8";//微信
    [self.thirdLoginSuccess loginSuccessed:data WithThirdData:self.resp_weixin];
    
    [SNNewsRecordLastLogin saveLogin:@{@"key":@"weixin",@"value":@"1"}];
}

- (void)openBingPhoneViewControllerData:(NSDictionary*)dic{
    [[SNCenterToast shareInstance] hideToast];
    NSDictionary* query = [NSDictionary dictionaryWithObjectsAndKeys:@"绑定手机", @"headTitle", @"立即绑定", @"buttonTitle", dic,@"data",self,@"third",nil];
    TTURLAction *_urlAction = [[[TTURLAction actionWithURLPath:@"tt://mobileNumBindLogin"] applyAnimated:YES] applyQuery:query];
    [[TTNavigator navigator] openURLAction:_urlAction];
}

-(void)openBindPhoneViewControllerData:(NSDictionary *)dic WithUserInfo:(NSDictionary *)userinfo{
    [[SNCenterToast shareInstance] hideToast];
    
    self.userInfoDic = userinfo;
    
    NSDictionary* query = [NSDictionary dictionaryWithObjectsAndKeys:@"绑定手机", @"headTitle", @"立即绑定", @"buttonTitle", dic,@"data",self,@"third",nil];
    TTURLAction *_urlAction = [[[TTURLAction actionWithURLPath:@"tt://mobileNumBindLogin"] applyAnimated:YES] applyQuery:query];
    [[TTNavigator navigator] openURLAction:_urlAction];
}

////////////////////////////////////////////////////////////////////////////////////

@end

