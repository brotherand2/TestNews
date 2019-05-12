//
//  SNShareWeibo.m
//  sohunews
//
//  Created by wang shun on 2017/1/23.
//  Copyright © 2017年 Sohu.com. All rights reserved.
//

#import "SNShareWeibo.h"

#import "SNWeiboHelper.h"
#import "SNNewsSSOOpenUrl.h"
#define SOHUNews_Share_SinaWeiBo_AppKey @"3651065292"
#define SOHUNews_Share_SinaWeiBo_SinaAppSecret @"4044dcec48356f896919cd5ff46d2217"
#define SOHUNews_Share_SinaWeiBo_SinaAppRedirectURI @"http://api.k.sohu.com"

@implementation SNShareWeibo

-(instancetype)initWithOption:(NSInteger)option{
    if (self = [super initWithOption:option]) {
        self.shareTarget = ShareTargetSNS;
        
        [SNWeiboHelper sharedInstance].shareWeibo = self;
        [[SNNewsSSOOpenUrl sharedInstance] setWeiboShare:self];
    }
    return self;
}

-(NSDictionary *)getShareParams:(NSDictionary *)dic{
    [super getShareParams:dic];
    
    return self.shareData;
}


- (void)shareTo:(NSDictionary*)dic Upload:(UploadBlock)method{
    NSDictionary* info = self.shareData;
    
    NSString* title   = [[NSString stringWithFormat:@"%@",[info objectForKey:@"title"]] trim];
    NSString* content = [[NSString stringWithFormat:@"%@",[info objectForKey:@"content"]] trim];
    NSString* imgUrl  = [NSString stringWithFormat:@"%@",[info objectForKey:@"imageUrl"]];
    NSString* webUrl  = [NSString stringWithFormat:@"%@",[info objectForKey:@"webUrl"]];
    NSString* shareComment = [info objectForKey:@"shareComment"];
    NSString* contentType = [NSString stringWithFormat:@"%@",[info objectForKey:@"contentType"]];
    
    NSData* imgData = nil;
    
    WBMessageObject *message = [WBMessageObject message];
    
    NSString* text = @"";
    
    NSString *imagePath = [self.shareData objectForKey:kShareInfoKeyImagePath defalutObj:nil];
    if (!imagePath) {
        imagePath = [self.shareData objectForKey:kShareInfoKeyScreenImagePath defalutObj:nil];
        if (imagePath) {
            if (![SNAPI isWebURL:imagePath]) {
                imgData = [NSData dataWithContentsOfFile:imagePath];
                WBImageObject* obj = [[WBImageObject alloc] init];
                obj.imageData = imgData;
                message.imageObject = obj;
            }
        }
    }
    else{
        if (!imgData) {
            imgData = [NSData dataWithContentsOfFile:imagePath];
            WBImageObject* obj = [[WBImageObject alloc] init];
            obj.imageData = imgData;
            message.imageObject = obj;
        }
    }
    
    if ([contentType isEqualToString:@"sns"]) {
        text = [NSString stringWithFormat:@"%@// %@ (分享自@搜狐新闻客户端) //",title,webUrl];
        
        if (imgData == nil) {//如果没有图片添加一张图
            [self insertOneImg:message ImgUrl:imgUrl];
        }
    }
    else if ([contentType isEqualToString:@"loading"]) {
        text = content;
        if (imgData == nil) {//如果没有图片添加一张图
            [self insertOneImg:message ImgUrl:imgUrl];
        }
    }
    else if ([contentType isEqualToString:@"news"]){//
        if (webUrl && webUrl.length>0) {
            text = [NSString stringWithFormat:@"【%@】 %@ (分享自@搜狐新闻客户端) //",title,webUrl];
            if (shareComment && shareComment.length>0) {
                if (![shareComment isEqualToString:@"(null)"]) {
                    text = [NSString stringWithFormat:@"%@// %@ (分享自@搜狐新闻客户端) //",shareComment,webUrl];
                }
            }
            
            //因微博去掉card 所以加张图
            if (imgData == nil) {//如果没有图片添加一张图 sunpan 说加图 wangshun
                if (imgUrl && imgUrl.length>0) {
                    [self insertOneImg:message ImgUrl:imgUrl];
                }
            }
        }
    }
    else if ([contentType isEqualToString:@"qianfan"]){
        text = [NSString stringWithFormat:@"%@ %@ (分享自@搜狐新闻客户端)",content,webUrl];
        if (imgData == nil) {//如果没有图片添加一张图
            [self insertOneImg:message ImgUrl:imgUrl];
        }
    }
    else{
        text = content;
        
        if ([contentType isEqualToString:@"web"]){
            NSString* shareContent = [self.shareData objectForKey:@"shareContent"];
            if (shareContent && shareContent.length>0 && ![shareContent isEqualToString:@"(null)"]) {
                text = shareContent;
            }
            else{
//                text = [NSString stringWithFormat:@"%@ %@ (分享自@搜狐新闻客户端)",title,webUrl];
                if ([title rangeOfString:@"分享自@搜狐新闻客户端"].length > 0) {
                    if ([title rangeOfString:@"http://"].length > 0 || [title rangeOfString:@"https://"].length > 0) {
                        text = [NSString stringWithFormat:@"%@",title];
                    } else {
                        text = [NSString stringWithFormat:@"【%@】 %@ //",title,webUrl];
                    }
                    
                } else {
                    text = [NSString stringWithFormat:@"%@ %@ (分享自@搜狐新闻客户端)",title,webUrl];
                }

                
            }
            
            if (!imgData) {
                if (!imgUrl || [imgUrl isEqualToString:@""]) {
                    NSString* normal = [[NSBundle mainBundle] pathForResource:@"iOS_114_normal" ofType:@"png"];
                    imgData = [NSData dataWithContentsOfFile:normal];
                    WBImageObject* obj = [[WBImageObject alloc] init];
                    obj.imageData = imgData;
                    message.imageObject = obj;
                }
            }
        }
        else{
            
            /*
             这得写注释 否则谁能看懂
             
             因为webUrl 加了sf_a(统计分享来源的)
             原来content中会包括webUrl(有时候有,有时候没有)
             还要判断加上sf_a了是否超过140个字，否则分享不了
             
             为了解决两个bug
             
             http://jira.sohuno.com/browse/NEWSCLIENT-18618
             http://jira.sohuno.com/browse/NEWSCLIENT-18690
             */
            NSString* temp_webUrl = [webUrl stringByReplacingOccurrencesOfString:@"&sf_a=xinlang" withString:@""];
            temp_webUrl = [temp_webUrl stringByReplacingOccurrencesOfString:@"?sf_a=xinlang" withString:@""];
            
            NSRange range = [content rangeOfString:temp_webUrl];
            
            if (range.location == NSNotFound) {
                //如果content中没有url 拼接url (还要防止url是(null)) 需求
                
                if (webUrl.length>0 && ![webUrl isEqualToString:@"(null)"]) {
                    text = [content stringByAppendingFormat:@"%@",webUrl];
                    
                    if (text.length>2000) {//超字了，去掉，看看还超不
                        NSRange range = [text rangeOfString:@"&sf_a=xinlang"];
                        if (range.location != NSNotFound) {
                            text = [text stringByReplacingOccurrencesOfString:@"&sf_a=xinlang" withString:@""];
                        }
                        else{
                            NSRange range_ = [text rangeOfString:@"?sf_a=xinlang"];
                            if (range_.location != NSNotFound) {
                                text = [text stringByReplacingOccurrencesOfString:@"?sf_a=xinlang" withString:@""];
                            }
                        }
                        
                        if (text.length>2000) {//如果还超字数，那没办法了
                           text = webUrl;
                        }
                    }
                }

            }
            else{//如果content中有url 换一下带sf_a的，如果超字了
                text = [content stringByReplacingOccurrencesOfString:temp_webUrl withString:webUrl];
                if (text.length>2000) {//如果超字了，还得去掉
                    NSRange range = [text rangeOfString:@"&sf_a=xinlang"];
                    if (range.location != NSNotFound) {
                        text = [text stringByReplacingOccurrencesOfString:@"&sf_a=xinlang" withString:@""];
                    }
                    else{
                        NSRange range_ = [text rangeOfString:@"?sf_a=xinlang"];
                        if (range_.location != NSNotFound) {
                            text = [text stringByReplacingOccurrencesOfString:@"?sf_a=xinlang" withString:@""];
                        }
                    }
                    
                    if (text.length>2000) {//如果还超字数，那没办法了
                        text = webUrl;
                    }
                }
            }
        }
        
        if (imgData == nil) {//如果没有图片添加一张图
            [self insertOneImg:message ImgUrl:imgUrl];
        }
    }
    
//    weibo 140字数限制
//    if(text.length>140){
//        if (self.more140size) {
//            self.more140size();
//        }
//        return;
//    }
    
    if (!text || [text isEqualToString:@"(null)"]) {
        text = @"";
    }
    message.text = [text trim];
    //唤起微博
    [self callWeibo:message];
    
    if (method) {
        self.uploadMethod = method;
    }
    
}

//------------------------------------------------------------------------------

- (void)insertOneImg:(WBMessageObject*)msg ImgUrl:(NSString*)img{
    NSData* imgData = nil;
    
    if (img && [img isKindOfClass:[NSString class]] && img.length>0) {
        NSURL *url = [NSURL URLWithString:img];
        if (url && [url isKindOfClass:[NSURL class]]) {
            imgData = [NSData dataWithContentsOfURL:url];
            
            if (imgData) {
                WBImageObject* obj = [[WBImageObject alloc] init];
                obj.imageData = imgData;
                msg.imageObject = obj;
            }
        }
    }
}

//同步我的分享和狐you
- (void)syncSinaWeiboShareResult{
    if (self.uploadMethod) {
        self.uploadMethod(nil);
    }
//    NSString *appId = @"1";//sina微博是@“1” 别的上别的地方去找吧
//    
//    SNTimelineOriginContentObject *obj = [self.syncInfo objectForKey:kShareInfoKeyShareRead];
//    
//    if (!obj) {
//        if (self.shareInfoObj) {
//            obj = self.shareInfoObj;
//        }
//    }
//    
//    SNShareItem *shareItem = [[SNShareItem alloc] init];
//    
//    shareItem.shareId          = self.shareLogId;
//    shareItem.shareTitle       = self.shareTitle;
//    shareItem.shareContent     = self.content;
//    shareItem.sourceType       = self.sourceType;
//    shareItem.shareLink = obj.link;
//    shareItem.appId = appId;
//    
//    shareItem.shareContentType = self.shareType;
//    shareItem.shareTitle = self.shareInfoObj.title;
//    if (self.shareInfoObj.isFromChannelPreview) {
//        shareItem.shareId = self.shareInfoObj.subId;
//        shareItem.shareContent = self.shareInfoObj.description;
//    }
//    if (self.isVideoShare) {
//        shareItem.shareLink  = self.shareInfoObj.link;
//        shareItem.shareId    = self.shareInfoObj.referId;
//    }else {
//        shareItem.shareId    = self.newsId;
//        shareItem.shareLink  = self.shareInfoObj.link;
//    }
//    shareItem.shareLink      = self.shareInfoObj.link;
//    shareItem.shareImagePath = self.imagePath;
//    shareItem.shareImageUrl  = self.imageUrl;
//    if (self.sourceType == 141) {
//        shareItem.sourceType = self.sourceType;
//    }else if (self.sourceType == 65) {
//        shareItem.sourceType = self.sourceType;
//    }else{
//        shareItem.sourceType = self.shareInfoObj.sourceType;
//    }
//    if (self.shareComment && self.shareComment.length>0) {
//        if ([self.shareComment isEqualToString:@"(null)"]) {
//            self.shareComment = @"";
//        }
//        shareItem.ugc = self.shareComment;
//    }
//    if (shareItem.shareId.length == 0) {
//        shareItem.shareId = self.shareInfoObj.referId;
//    }
//    
//    [[SNShareManager defaultManager] postShareItemToServer:shareItem];
}


#pragma mark - 唤起微博

- (void)callWeibo:(WBMessageObject*)msg{
    WBAuthorizeRequest *authRequest = [WBAuthorizeRequest request];
    authRequest.redirectURI = SOHUNews_Share_SinaWeiBo_SinaAppRedirectURI;
    authRequest.scope = @"all";
    
    WBSendMessageToWeiboRequest *request = [WBSendMessageToWeiboRequest requestWithMessage:msg authInfo:authRequest access_token:self.wbtoken];
    
    [WeiboSDK sendRequest:request];
}

#pragma mark - WeiboSDKDelegate

- (void)didReceiveWeiboRequest:(WBBaseRequest *)request{
}

- (void)didReceiveWeiboResponse:(WBBaseResponse *)response{
    if ([response isKindOfClass:WBSendMessageToWeiboResponse.class]){
        WBSendMessageToWeiboResponse* sendMessageToWeiboResponse = (WBSendMessageToWeiboResponse*)response;
        NSString* accessToken = [sendMessageToWeiboResponse.authResponse accessToken];
        if (accessToken)
        {
            self.wbtoken = accessToken;
        }
        NSString* userID = [sendMessageToWeiboResponse.authResponse userID];
        if (userID) {
            self.wbCurrentUserID = userID;
        }
        
        if (sendMessageToWeiboResponse.statusCode == WeiboSDKResponseStatusCodeSuccess) {//成功
            [[SNCenterToast shareInstance] showCenterToastWithTitle:NSLocalizedString(@"ShareSucceed", @"ShareSucceed") toUrl:nil mode:SNCenterToastModeSuccess];
            [self syncSinaWeiboShareResult];
            
            NSString* shareLink = [self.shareData objectForKey:@"webUrl"];
            [SNUtility requestRedPackerAndCoupon:shareLink type:@"1"];
        }
    }
    else if ([response isKindOfClass:WBAuthorizeResponse.class]){
        self.wbtoken = [(WBAuthorizeResponse *)response accessToken];
        self.wbCurrentUserID = [(WBAuthorizeResponse *)response userID];
        self.wbRefreshToken = [(WBAuthorizeResponse *)response refreshToken];
    }
}


- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation{
    return [WeiboSDK handleOpenURL:url delegate:self];
}

- (BOOL)application:(UIApplication *)application handleOpenURL:(NSURL *)url{
    return [WeiboSDK handleOpenURL:url delegate:self];
}

+ (BOOL)isWeiboAppInstalled{
    return [WeiboSDK isWeiboAppInstalled];
}

@end

