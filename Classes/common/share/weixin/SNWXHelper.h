//
//  SNWXHelper.h
//  sohunews
//
//  Created by yanchen wang on 12-5-22.
//  Copyright (c) 2012年 Sohu.com Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "WXApi.h"
#import "WXApiObject.h"
#import "SNLoginLaterBingPhone.h"
#import "SNThirdLoginSuccess.h"

//#define kWX_APP_ID      @"wx6c6138cb32ca916d" // to replace
//#define kWX_APP_KEY     @"f8162d1dc0315002a78bc338497f96bf" // to replace

typedef enum {
    _ShareTypeImage = 0, // 保持原来的图片比例
    _ShareTypeImageThumb, // 保持原来图片比例缩放
    _ShareTypeNewsImage, // 114 * 114
}_ShareType;

typedef enum {
    SNWXErrorSuccess            = WXSuccess,
    SNWXErrorCommon             = WXErrCodeCommon, 
    SNWXErrorUserCancel         = WXErrCodeUserCancel,
    SNWXErrorSentFail           = WXErrCodeSentFail,
    SNWXErrorAuthDeny           = WXErrCodeAuthDeny,
    SNWXErrorUnsuportedApi      = -5,
    SNWXErrorWeixinUninstall    = -6,
    SNWXErrorException          = -7
}SNWXErrorCode;

typedef enum {
    SNWXStatusWeixinUnsuporedApi    = -2,
    SNWXStatusWeixinNotInstall      = -1,
    SNWXStatusWeixinReady           = 1,
}SNWXStatus;

typedef enum {
    SNWXMediaMessageTypeVideo, // 暂且先支持一个视频 以后按需添加即可
}SNWXMediaMessageType;
@protocol SNWXHelpDelegate;
@interface SNWXHelper : NSObject<WXApiDelegate,SNLoginLaterBingPhoneDelegate/*, ASIHTTPRequestDelegate,SNLoginLaterBingPhoneDelegate*/> {
    id __weak _delegate; // weak
    int _scene; //     WXSceneSession   = 0, WXSceneTimeline = 1,
}

@property(nonatomic, weak)id delegate;
@property(nonatomic, assign)int scene;
@property(nonatomic, strong)NSString *newsId;
@property (nonatomic, strong)NSString *shareUrl;

@property (nonatomic, weak) id <SNWXHelpDelegate> screenShare_WeiXinDel;

@property (nonatomic,strong) SNLoginLaterBingPhone* bingPhone;
@property (nonatomic,strong) SNThirdLoginSuccess* thirdLoginSuccess;
@property (nonatomic,strong) NSDictionary* userInfoDic;//绑定之前已经拿到的userinfo
@property (nonatomic,strong) NSDictionary* resp_weixin;
+ (SNWXHelper *)sharedInstance;
+ (BOOL)initWXApi;
+ (BOOL)isWeixinReady;
+ (SNWXStatus)weixinStatus;

- (void)shareTextToWeixin:(NSString *)text;
- (void)shareImageToWeixin:(NSData *)imageData imageTitle:(NSString *)title; // image最大10m
- (void)shareNewsToWeixin:(NSString *)content title:(NSString *)title thumbImage:(NSData *)imageData webUrl:(NSString *)url; // image最大32k
- (void)shareGifToWeixin:(NSString*)gifUrl ImageData:(NSData*)imgData;//share gif

// media object : /** 多媒体数据对象，可以为WXImageObject，WXMusicObject，WXVideoObject，WXWebpageObject等。 */
- (void)shareMediaMessageToWeixin:(NSString *)content title:(NSString *)title thumbImage:(NSData *)imageData mediaUrl:(NSString *)mediaUrl mediaType:(SNWXMediaMessageType)mediaType;

- (void)onResp:(BaseResp*)resp;

@end

@protocol SNWXHelpDelegate <NSObject>
@optional
- (void)didReceiveWeixinResponse:(int)type errCode:(SNWXErrorCode)errCode errorStr:(NSString *)errorStr;

- (void)setWeiXinURLWithCode:(NSString*)code;
@end

extern NSData *_imageCompress(NSData *sourceData, _ShareType type);
