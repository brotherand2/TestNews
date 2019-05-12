//
//  SNNewsScreenWeiXin.h
//  sohunews
//
//  Created by wang shun on 2017/8/6.
//  Copyright © 2017年 Sohu.com. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol SNNewsScreenWeiXinDelegate;
@interface SNNewsScreenWeiXin : NSObject

@property (nonatomic,weak) id <SNNewsScreenWeiXinDelegate> delegate;

@property (nonatomic,strong) NSString* isWeiXinAuth;
@property (nonatomic,assign) BOOL isCheckBoxSelected;

@property (nonatomic,strong) NSString* weixin_nickName;
@property (nonatomic,strong) NSString* weixin_headImage_Url;

@property (nonatomic,strong) NSString* huyou_nickName;
@property (nonatomic,strong) NSString* huyou_headImage_Url;

@property (nonatomic,strong) NSString* tips;
@property (nonatomic,strong) NSString* link2;
@property (nonatomic,strong) NSString* backgroundUrl;

@property (nonatomic,strong) NSString* openID;
@property (nonatomic,strong) NSString* access_Token;
@property (nonatomic,strong) NSString* refresh_Token;

//微信授权
- (void)weiXinAuth:(void (^)(NSDictionary* info))method;

- (void)didload:(NSDictionary*)dic;

- (BOOL)isInstallWeiXin;

- (BOOL)isCanShare:(NSString*)iconTitle;//是否能分享

- (BOOL)isShowWeixin;
- (BOOL)isShowSohu;

-(void)setWeiXinURLWithCode:(NSString *)code;

@end

@protocol SNNewsScreenWeiXinDelegate <NSObject>

- (void)getAuthUserInfo:(id)sender;
- (void)share:(NSString*)sender;

//调这俩方法主要是为了刷头像 等头像刷完立刻分享出去
- (void)weixinShareCallBack:(id)sender;
- (void)sohuShareCallBack:(id)sender;

- (void)updateLink2:(UIImage*)link2_img Background:(NSString*)back_imgUrl;


//立即分享
- (void)shareLater:(NSString*) sender;

- (void)weixinAuthFailed;

@end
