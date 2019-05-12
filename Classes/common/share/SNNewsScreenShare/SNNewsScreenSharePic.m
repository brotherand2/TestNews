//
//  SNNewsScreenSharePic.m
//  sohunews
//
//  Created by wang shun on 2017/8/10.
//  Copyright © 2017年 Sohu.com. All rights reserved.
//

#import "SNNewsScreenSharePic.h"

#import "SNNewsShareManager.h"
#import "SNNewsScreenShare.h"

#import "SNNewsShareDrawBoardViewController.h"

#import "SNScreenshotRequest.h"
#import "SNNewsUpLoadPicGo.h"
#import "WXApi.h"
#import "SNWeixinOauthRequest.h"
#import "SNUserManager.h"

@interface SNNewsScreenSharePic ()<SNNewsShareManagerDelegate>

@property (nonatomic,strong) SNNewsShareManager* shareManager;
@property (nonatomic,strong) NSMutableDictionary* shareOnData;

@property (nonatomic,strong) NSString* platform;

@end

@implementation SNNewsScreenSharePic

-(instancetype)init{
    if (self = [super init]) {
        
    }
    return self;
}

- (NSString*)isShowHeadFirst{
    NSString* s = [[NSUserDefaults standardUserDefaults] objectForKey:@"上次截屏分享勾选"];
    if (s && [s isEqualToString:@"1"]) {
        self.selected = s;
        NSString* headU = [[NSUserDefaults standardUserDefaults] objectForKey:@"上次截屏分享授权头像"];
        if (headU && headU.length>0) {
            self.headUrl = headU;
        }
        NSString* nick = [[NSUserDefaults standardUserDefaults] objectForKey:@"上次截屏分享授权昵称"];
        if (nick && nick.length>0) {
            self.nickName = nick;
        }
        
         return @"1";//勾选
    }
    else if (s && [s isEqualToString:@""]){
        self.selected = @"";
        return @"0";//不勾选
    }
    return @"2";//第一次进入
}

- (BOOL)isShowHead:(id)sender{
    
    if (self.selected &&[self.selected isEqualToString:@"1"]) {
        if (self.headUrl && self.headUrl.length>0 && self.nickName && self.nickName.length>0) {
            return YES;
        }
        else{
            NSString* headU = [[NSUserDefaults standardUserDefaults] objectForKey:@"上次截屏分享授权头像"];
            if (headU && headU.length>0) {
                self.headUrl = headU;
            }
            NSString* nick = [[NSUserDefaults standardUserDefaults] objectForKey:@"上次截屏分享授权昵称"];
            if (nick && nick.length>0) {
                self.nickName = nick;
            }
            if (self.headUrl && self.nickName) {
                return YES;
            }
            return NO;
        }
    }
    else{
        return NO;
    }
}

- (void)save{
    
    if (self.headUrl) {
        [[NSUserDefaults standardUserDefaults] setObject:self.headUrl forKey:@"上次截屏分享授权头像"];
    }
    if (self.nickName) {
        [[NSUserDefaults standardUserDefaults] setObject:self.nickName forKey:@"上次截屏分享授权昵称"];
    }
    
    if ([self.selected isEqualToString:@"1"]) {
        [[NSUserDefaults standardUserDefaults] setObject:self.selected forKey:@"上次截屏分享勾选"];
    }
    else{
        [[NSUserDefaults standardUserDefaults] setObject:@"" forKey:@"上次截屏分享勾选"];
    }
    
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (void)callShare:(NSMutableDictionary *)dic Title:(NSString *)title WithFinalView:(UIView *)final_view{
    
    //passport 不支持俩appkey wangshun
    if (isINHOUSE) {//等重构吧 inhouse 和 appstore 不是一个bundleid passport不想兼容俩
        [WXApi registerApp:kWX_APP_ID_Inhouse enableMTA:NO];
    }
    
    [self save];
    
    if (dic) {
        self.shareOnData = dic;
    }
    
    self.platform = title;
    
    if (final_view) {
        self.final_share_View = final_view;
    }
    
    [self writPic];

    if (self.isSHH5News == YES && dic) {
        [self callShare:dic Title:title];
    }
    else{
        NSMutableDictionary* m = [self createScreenShareData:title];
        [self callShare:m Title:title];
    }
}

- (void)callShare:(NSMutableDictionary*)dic Title:(NSString*)title{
    
    if (self.shareManager != nil) {
        self.shareManager = nil;
    }
    
    self.shareManager = [[SNNewsShareManager alloc] init];
    self.shareManager.delegate = self;
    [dic setObject:@"1" forKey:@"screen_share"];
    [self.shareManager shareIconSelected:title ShareData:dic];
    
    if (self.isSHH5News == NO) {//关闭
        if ([SNUserManager isLogin]) {
            [self finishedShareClose:nil];
        }
    }

}

#pragma mark - shareOnUrl

- (void)shareOnFinished:(SNSharePlatformBase *)platform{
    //如果是正文页重新生成二维码
    if (self.isSHH5News == YES) {
        NSString* webUrl = [platform.shareData objectForKey:@"webUrl"];
        NSString* link2 = [platform.shareData objectForKey:@"link2"];
        if (link2) {
            webUrl = link2;
        }
        
        NSString* title = nil;
        if (platform.optionPlatform == SNActionMenuOptionMySOHU) {
            title = kShareTitleMySohu;
        }
        NSMutableDictionary* mDic = [self createScreenShareData:title];
        if (platform.optionPlatform != SNActionMenuOptionMySOHU) {
            [mDic setObject:webUrl?:@"" forKey:SNNewsShare_Url];
        }
        
        if (platform.optionPlatform == SNActionMenuOptionOAuths){
            [platform.shareData setObject:webUrl?:@"" forKey:SNNewsShare_Url];
            
            NSString* path = [mDic objectForKey:kShareInfoKeyImagePath];
            [platform.shareData setObject:path?:@"" forKey:kShareInfoKeyImagePath];
        }
        else{
            platform.shareData = mDic;
        }
        
        if (webUrl) {
//            self.qr_code_imageView.image = [SNNewsScreenShare createQRcodeImage:webUrl];
//            self.final_qr_code_imageView.image = self.qr_code_imageView.image;
            if (self.delegate && [self.delegate respondsToSelector:@selector(changeQRImage:)]) {
                [self.delegate changeQRImage:[SNNewsScreenShare createQRcodeImage:webUrl]];
            }
        }
        
        //把数据源改为图片数据 (需要用正文页数据访问shareon)
        
        [self writPic];
        
        [self finishedShareClose:nil];
    }
    
    [self uploadSharePic];
}


- (NSMutableDictionary*)createScreenShareData:(NSString*)title{
    NSMutableDictionary* mDic = [[NSMutableDictionary alloc] initWithCapacity:0];
    NSString* path = [NSHomeDirectory() stringByAppendingPathComponent:@"Library/screenshare.png"];
    
    [mDic setObject:@"搜狐新闻" forKey:kShareInfoKeyTitle];
    [mDic setObject:path forKey:kShareInfoKeyImagePath];
    [mDic setObject:@"" forKey:kShareInfoKeyContent];
    [mDic setObject:SNNews_SHARE_ScreenShare_QRCode_Default_URL forKey:SNNewsShare_Url];
    if (title && [title isEqualToString:kShareTitleMySohu]) {
        [mDic setObject:@"3" forKey:@"type"];
        [mDic setObject:@"" forKey:@"url"];
    }
    
    return mDic;
}

#pragma mark -

- (void)finishedShareClose:(id)sender{
    SNNavigationController* flipboardNavigationController = [TTNavigator navigator].topViewController.flipboardNavigationController;
    
    if (self.isSHH5News == NO) {//关闭
        if ([SNUserManager isLogin]) {
            [self pop:flipboardNavigationController];
        }
    }
    else{
        [self pop:flipboardNavigationController];
    }
}

- (void)pop:(SNNavigationController*)flipboardNavigationController{
    if (flipboardNavigationController.viewControllers) {
        if (flipboardNavigationController.viewControllers.count>=3) {
            NSInteger n = flipboardNavigationController.viewControllers.count-1;
            if (n>=0) {
                NSInteger m = n-1;
                
                SNNewsShareDrawBoardViewController* dvc = [flipboardNavigationController.viewControllers objectAtIndex:m];
                if (dvc && [dvc isKindOfClass:[SNNewsShareDrawBoardViewController class]]) {
                    [dvc clean];//清除tmp 中图片
                }
                
                if (self.delegate && [self.delegate respondsToSelector:@selector(removeSelf)]) {
                    [self.delegate removeSelf];
                }
                
                //关闭
                [SNScreenshotRequest closeScreenShotToShare];
                
                SNBaseViewController* vc = [flipboardNavigationController.viewControllers objectAtIndex:m-1];
                [flipboardNavigationController popToViewController:vc animated:YES];
            }
        }
    }
}

#pragma mark - writ to path 图片

- (void)writPic{
    NSString* path = [NSHomeDirectory() stringByAppendingPathComponent:@"Library/screenshare.png"];
    UIImage* share_image = [SNNewsScreenShare getImageFromView:self.final_share_View];
    NSData* imageData = UIImagePNGRepresentation(share_image);
    [imageData writeToFile:path atomically:YES];
    SNDebugLog(@"%@",path);
}



- (void)uploadSharePic{
    NSString* path = [NSHomeDirectory() stringByAppendingPathComponent:@"Library/screenshare.png"];
    
    NSData* data = [NSData dataWithContentsOfFile:path];
    
    NSString* picHash = [data md5Hash]?:@"";
    NSNumber* dataLength = [NSNumber numberWithInteger:data.length];
    
    NSString* newsID = [self.shareOnData objectForKey:@"newsId"]?:@"";
    
    NSString* shareOn = @"WeiXinChat";
    NSString* thirdId = @"";
    if ([self.platform isEqualToString:kShareTitleMySohu] || [self.platform isEqualToString:SNNewsShare_Icons_Sohu]) {
        shareOn = @"Default";
    }
    else{
        thirdId = self.weixin_openid?:@"";
        if ([self.platform isEqualToString:kShareTitleWechatSession] || [self.platform isEqualToString:SNNewsShare_Icons_WeChat]) {//好友
            shareOn = @"WeiXinChat";
        }
        else if ([self.platform isEqualToString:kShareTitleWechat] || [self.platform isEqualToString:SNNewsShare_Icons_Timeline]){//朋友圈
            shareOn = @"WeiXinMoments";
        }
    }
    
    [[[SNNewsUpLoadPicGo alloc] initWithDictionary:@{@"newsId":newsID,@"shareOn":shareOn,@"thirdId":thirdId,@"picHash":picHash,@"picLength":dataLength} WithFile:data] send:^(SNBaseRequest *request, id responseObject) {
        SNDebugLog(@"UpLoadPicGo:::%@",responseObject);
    } failure:^(SNBaseRequest *request, NSError *error) {
        [[SNCenterToast shareInstance] showCenterToastWithTitle:NSLocalizedString(@"network error", @"") toUrl:nil mode:SNCenterToastModeError];
    }];
}

@end
