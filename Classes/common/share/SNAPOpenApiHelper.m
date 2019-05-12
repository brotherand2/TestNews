//
//  SNAPOpenApiHelper.m
//  sohunews
//
//  Created by cuiliangliang on 16/3/9.
//  Copyright © 2016年 Sohu.com. All rights reserved.
//

#import "SNAPOpenApiHelper.h"


@interface SNAPOpenApiHelper ()<APOpenAPIDelegate>

@end

@implementation SNAPOpenApiHelper



+ (SNAPOpenApiHelper *)sharedInstance{
    static SNAPOpenApiHelper *_instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _instance = [[SNAPOpenApiHelper alloc] init];
    });
    return _instance;
}

-(BOOL)isAPAppInstalled{
    return [APOpenAPI isAPAppInstalled];
}


-(BOOL)shareToAPScene{
    if (![APOpenAPI isAPAppInstalled]) {
        return NO;
    }
    if (![APOpenAPI isAPAppSupportOpenApi]) {
        return NO;
    }
    
    //  创建消息载体 APMediaMessage 对象
    APMediaMessage *message = [[APMediaMessage alloc] init];
    
    message.title = self.text;
    message.desc = self.desc;
    message.thumbUrl = self.thumbUrl;
    message.thumbData = self.thumbData;
    
    
    if (self.scene == APSceneTimeLine) {
        //  创建网页类型的消息对象
        APShareWebObject *webObj = [[APShareWebObject alloc] init];
        webObj.wepageUrl = self.wepageUrl;
        //  回填 APMediaMessage 的消息对象
        message.mediaObject = webObj;
    }else{
        
        switch (self.shareType) {
            case ShareTypeText:
            {
                //  创建文本类型的消息对象
                APShareTextObject *textObj = [[APShareTextObject alloc] init];
                textObj.text = self.text;
                //  回填 APMediaMessage 的消息对象
                message.mediaObject = textObj;
                
            }
                break;
            case ShareTypeImageUrl:
            {
                //  创建图片类型的消息对象
                APShareImageObject *imgObj = [[APShareImageObject alloc] init];
                imgObj.imageUrl = self.imageUrl;
                //  回填 APMediaMessage 的消息对象
                message.mediaObject = imgObj;
            }
                break;
            case ShareTypeImageData:
            {
                //  创建图片类型的消息对象
                APShareImageObject *imgObj = [[APShareImageObject alloc] init];
                //  此处填充图片data数据,例如 UIImagePNGRepresentation(UIImage对象)
                //  此处必须填充有效的image NSData类型数据，否则无法正常分享
                imgObj.imageData = self.imageData;
                //  回填 APMediaMessage 的消息对象
                message.mediaObject = imgObj;
            }
                break;
            case ShareTypeWebByUrl:
            {
                //  创建网页类型的消息对象
                APShareWebObject *webObj = [[APShareWebObject alloc] init];
                webObj.wepageUrl = self.wepageUrl;
                //  回填 APMediaMessage 的消息对象
                message.mediaObject = webObj;
            }
                break;
            default:
                break;
        }
    }
    

    
    //  创建发送请求对象
    APSendMessageToAPReq *request = [[APSendMessageToAPReq alloc] init];
    //  填充消息载体对象
    request.message = message;
    request.scene =  self.scene;
    //  发送请求
    return  [APOpenAPI sendReq:request];
}




- (void)shareTextToAP:(NSString *)text{
    
    if (text) {
        APMediaMessage *message = [[APMediaMessage alloc] init];
        APShareTextObject *webObj = [[APShareTextObject alloc] init];
        webObj.text = text;
        message.mediaObject = webObj;
        APSendMessageToAPReq *request = [[APSendMessageToAPReq alloc] init];
        request.message = message;
        request.scene =  self.scene;
        [APOpenAPI sendReq:request];
    }

}
- (void)shareImageToAP:(NSData *)imageData imageTitle:(NSString *)title{
    
    if (![APOpenAPI isAPAppInstalled]) {
        return ;
    }
    if (![APOpenAPI isAPAppSupportOpenApi]) {
        return ;
    }
    APMediaMessage *message = [[APMediaMessage alloc] init];
    
    NSData *tmpData = _imageCompress(imageData, _ShareTypeImageThumb);
    
    [message setThumbData:_imageCompress(tmpData, _ShareTypeImageThumb)];
    [message setTitle:title];
    
    APShareImageObject *webObj = [[APShareImageObject alloc] init];
    webObj.imageData = _imageCompress(imageData, _ShareTypeImage);
    message.mediaObject = webObj;
    APSendMessageToAPReq *request = [[APSendMessageToAPReq alloc] init];
    request.message = message;
    request.scene =  self.scene;
    [APOpenAPI sendReq:request];

}

- (void)shareNewsToAP:(NSString *)content title:(NSString *)title thumbImage:(NSData *)imageData webUrl:(NSString *)url{
    self.shareUrl = url;
    if (![APOpenAPI isAPAppInstalled]) {
        return ;
    }
    if (![APOpenAPI isAPAppSupportOpenApi]) {
        return ;
    }
    if (!content) {
        return;
    }
    if (url) {
        //  创建消息载体 APMediaMessage 对象
        APMediaMessage *message = [[APMediaMessage alloc] init];
        if (imageData) {
            // 压缩两遍 安全一点点： 因为按照大小比例压出来的 大小不是完全按照这个比例的 所以 有可能压完还是超过限制
            imageData = _imageCompress(imageData, _ShareTypeNewsImage);
            message.thumbData = _imageCompress(imageData, _ShareTypeNewsImage);
        }
        
        NSString *tempTitle = (title && [title length]) ? title : NSLocalizedString(@"Sohu share", @"");
        message.title = title;
        message.desc = content;
        
//        if (self.scene == APSceneSession) {
//            message.title = title;
//        }
//        else if (self.scene == APSceneTimeLine) {
//            message.title = title;
//        }
        
        if ([title isEqualToString:NSLocalizedString(@"Sohu share", @"")]) {//如果这种情况，给默认分享语
            //NSLocalizedString(@"SMS share to friends",@"")
            if ([content isEqualToString:NSLocalizedString(@"SMS share to friends",@"")]) {
                message.title = NSLocalizedString(@"SMS share to friends",@"");
            }
        }
        
        if ([url containsString:@"qf.56.com"]) {
            message.desc = tempTitle;
            message.title = content;
        }

        APShareWebObject *webObj = [[APShareWebObject alloc] init];
        webObj.wepageUrl = url;
        message.mediaObject = webObj;
        
        APSendMessageToAPReq *request = [[APSendMessageToAPReq alloc] init];

        request.message = message;
        request.scene =  self.scene;

        [APOpenAPI sendReq:request];
    }
    else {
        [self shareTextToAP:content];
    }
}


#pragma mark - APOpenAPIDelegate
/*! @brief 收到一个来自支付宝的请求，第三方应用程序处理完后调用sendResp向支付宝发送结果
 *
 * 收到一个来自支付宝的请求，异步处理完成后必须调用sendResp发送处理结果给支付宝。
 * @param req 具体请求内容
 */
-(void) onReq:(APBaseReq*)req{
    
}



/*! @brief 发送一个sendReq后，收到支付宝的回应
 *
 * 收到一个来自支付宝的处理结果。调用一次sendReq后会收到onResp。
 * @param resp具体的回应内容
 */
-(void) onResp:(APBaseResp*)resp{
    [self didReceiveWeixinResponse:resp.type errCode:resp.errCode errorStr:resp.errStr];
}


- (void)didReceiveWeixinResponse:(int)type errCode:(APErrorCode)errCode errorStr:(NSString *)errorStr {
    switch (errCode) {
        case APSuccess:
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wundeclared-selector"
            if (self.delegate && [self.delegate respondsToSelector:@selector(shareToThirdPartSuccess:)]) {
                ShareTargetType type = ShareTargetAPSession;
                if (self.scene == APSceneTimeLine) {
                    type = ShareTargetAPTimeLine;
                }
                if ([self.delegate respondsToSelector:@selector(shareToThirdPartSuccess:)]) {
                    [self.delegate performSelector:@selector(shareToThirdPartSuccess:) withObject:@(type)];
//                    [self showMessageWithDelay:NSLocalizedString(@"ShareSucceed", @"")];
                }
            }
#pragma clang diagnostic pop

            break;
        case APErrCodeCommon:
            [self showMessageWithDelay:NSLocalizedString(@"AP error common", @"")];
            break;
        case APErrCodeSentFail:
            [self showMessageWithDelay:NSLocalizedString(@"AP sent fail", @"")];
            break;
        case APErrCodeAuthDeny:
            [self showMessageWithDelay:NSLocalizedString(@"AP auty deny", @"")];
            break;
        case APErrCodeUserCancel:
            break;

        case APErrCodeUnsupport:
            [[SNCenterToast shareInstance] showCenterToastWithTitle:NSLocalizedString(@"AP not suported", @"") toUrl:nil mode:SNCenterToastModeWarning];
            break;
        default:
            break;
    }
}

- (void)showMessageWithDelay:(NSString *)msg {
    double delayInSeconds = 2.0;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        if ([msg isEqualToString:NSLocalizedString(@"ShareSucceed", @"")]) {
            NSString *urlString = [NSString stringWithFormat:@"%@corpusId=", kProtocolOpenCorpus];
            [[SNCenterToast shareInstance] showCenterToastWithTitle:NSLocalizedString(@"ShareSucceed", @"ShareSucceed") toUrl:nil mode:SNCenterToastModeSuccess];
            NSString *shareProtocol = [SNUtility changeSohuLinkToProtocol:self.shareUrl];
            if (shareProtocol.length == 0) {
                shareProtocol = urlString;
            }
            [SNUtility requestRedPackerAndCoupon:shareProtocol type:@"1"];
        }
        else {
            [[SNCenterToast shareInstance] showCenterToastWithTitle:msg toUrl:nil mode:SNCenterToastModeOnlyText];
        }
    });
}

@end
