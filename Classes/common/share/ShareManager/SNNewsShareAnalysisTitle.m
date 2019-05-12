//
//  SNNewsShareAnalysisTitle.m
//  sohunews
//
//  Created by wang shun on 2017/5/16.
//  Copyright © 2017年 Sohu.com. All rights reserved.
//

#import "SNNewsShareAnalysisTitle.h"

#import "SNSharePlatformHeader.h"

#import "SNUserManager.h"

#import "SNShareScreenshotClick.h"

#import "SNNewsLogin.h"
#import "SNNewsLoginManager.h"

@implementation SNNewsShareAnalysisTitle

+ (NSDictionary*)getIsAppClassData:(NSString*)iconTitle WithData:(NSDictionary*)data{
    
    BOOL isInstalled = YES;//默认安装了
    
    NSString* toastTitle = @"";
    NSString* classname = @"";
    
    /*
     #define SNNewsShare_Icons_Timeline @"moments" //微信朋友圈
     #define SNNewsShare_Icons_WeChat @"weChat" //微信好友
     #define SNNewsShare_Icons_Sohu @"sohu" //狐友
     #define SNNewsShare_Icons_Sina @"sina" //新浪微博
     #define SNNewsShare_Icons_QQ @"qq" //QQ
     #define SNNewsShare_Icons_QQZone @"qqZone" //QQ空间
     #define SNNewsShare_Icons_Alipay @"alipay" //支付宝好友
     #define SNNewsShare_Icons_LifeCircle @"lifeCircle" //生活圈
     #define SNNewsShare_Icons_CopyLink @"copyLink" //复制链接
     */
    
    NSInteger option = -1;//随便给一个
    if ([iconTitle isEqualToString:kShareTitleWechat] || [iconTitle isEqualToString:SNNewsShare_Icons_Timeline]) {//微信朋友圈
        option = SNActionMenuOptionWXTimeline;
        classname = @"SNShareWeiXin";
        if (![SNShareWeiXin isInstalledWeiXin]) {
            isInstalled = NO;//未安装
            toastTitle = NSLocalizedString(@"Weixin not installed", @"");
        }
    }
    else if([iconTitle isEqualToString:kShareTitleWechatSession] || [iconTitle isEqualToString:SNNewsShare_Icons_WeChat]){//微信好友
        option = SNActionMenuOptionWXSession;
        classname = @"SNShareWeiXin";
        
        if (![SNShareWeiXin isInstalledWeiXin]) {
            isInstalled = NO;//未安装
            toastTitle = NSLocalizedString(@"Weixin not installed", @"");
        }
    }
    else if([iconTitle isEqualToString:kShareTitleMySohu] || [iconTitle isEqualToString:SNNewsShare_Icons_Sohu]){//狐友
        option = SNActionMenuOptionMySOHU;
        classname = @"SNShareSohu";
        
        if (![SNUserManager isLogin]) {
            [SNNotificationManager postNotificationName:kUserLoginSplashShouldDismissNotification object:nil];
//            [SNGuideRegisterManager login:kLoginFromShareMySohu];
            //wangshun 埋点 halfLoginData:@{@"halfScreenTitle":str}

            [[SNActionSheetLoginManager sharedInstance] resetNewGuideDic];
            [SNNotificationManager postNotificationName:kLoginMsgFromShareToSNSNotification object:nil];
            [SNUtility setUserDefaultSourceType:kUserActionIdForArticleComment keyString:kLoginSourceTag];
            return nil;
        }
    }
    else if([iconTitle isEqualToString:kShareTitleSina] || [iconTitle isEqualToString:SNNewsShare_Icons_Sina]){//新浪微博
        if (![SNShareWeibo isWeiboAppInstalled]) {
            isInstalled = NO;//未安装
            toastTitle = @"您尚未安装微博哦~试试其他分享方式吧！";
        }
        else{
            classname = @"SNShareWeibo";
        }
        option = SNActionMenuOptionOAuths;
    }
    else if([iconTitle isEqualToString:kShareTitleQQZone] || [iconTitle isEqualToString:SNNewsShare_Icons_QQZone]){//qq空间
        option = SNActionMenuOptionQZone;
        
        classname = @"SNShareQQ";
        
        if (![SNShareQQ isSupportQQSSO]) {
            isInstalled = NO;
            toastTitle = NSLocalizedString(@"QQ not installed", @"");
        }
    }
    else if([iconTitle isEqualToString:kShareTitleQQ] || [iconTitle isEqualToString:SNNewsShare_Icons_QQ]){//qq
        option = SNActionMenuOptionQQ;
        
        classname = @"SNShareQQ";
        if (![SNShareQQ isSupportQQSSO]) {
            isInstalled = NO;
            toastTitle = NSLocalizedString(@"QQ not installed", @"");
        }
    }
    else if([iconTitle isEqualToString:kShareTitleAliPaySession] || [iconTitle isEqualToString:SNNewsShare_Icons_Alipay]){//支付宝
        option = SNActionMenuOptionAliPaySession;
        
        if (![SNShareAlipay isAliPayAppInstalled]) {
            isInstalled = NO;//未安装
            toastTitle = NSLocalizedString(@"AP not installed", @"");
        }
        else{
            classname = @"SNShareAlipay";
        }
    }
    else if([iconTitle isEqualToString:kShareTitleAliPayLifeCircle] || [iconTitle isEqualToString:SNNewsShare_Icons_LifeCircle]){//生活圈
        option = SNActionMenuOptionScreenshotShare;
        
        if (![SNShareAlipay isAliPayAppInstalled]) {
            isInstalled = NO;//未安装
            toastTitle = NSLocalizedString(@"AP not installed", @"");
        }
        else{
            classname = @"SNShareAlipay";
        }
    }
    else if ([iconTitle isEqualToString:kShareTitleScreenshot] || [iconTitle isEqualToString:SNNewsShare_Icons_ScreenShot]){
        [SNShareScreenshotClick getScreenShare:data];
        return nil;
    }
    else if([iconTitle isEqualToString:kShareTitleWebLink] || [iconTitle isEqualToString:SNNewsShare_Icons_CopyLink]){//复制链接
        classname = @"SNShareCopyWebLink";
        option = SNActionMenuOptionWebLink;
    }
    
    if (option == -1) {
        return nil;
    }
    
    NSNumber* num = [NSNumber numberWithBool:isInstalled];
    return @{@"isInstalled":num,@"toastTitle":toastTitle,@"classname":classname,@"option":[NSNumber numberWithInteger:option]};
}

//2017.5.23 wangshun webUrl 加入from(From这个参数太常用了，容易与一些业务参数冲突，用sf_a吧，例如sf_a=weixin)
+ (NSString*)returnWebUrl:(NSString*)webUrl WithOption:(SNActionMenuOption)option{
    NSString* str = @"";
    
    /*
     微信朋友圈   from=weixin_friend
     微信好友     from=weixin
     新浪微博     from=xinlang
     qq           from=qq
     qq空间      from=qq_qzone
     支付宝       from=zhifubao
     */
    
    switch (option) {
        case SNActionMenuOptionWXTimeline:
            str = @"sf_a=weixin_friend";
            break;
        case SNActionMenuOptionWXSession:
            str = @"sf_a=weixin";
            break;
        case SNActionMenuOptionOAuths://微博
            str = @"sf_a=xinlang";
            break;
        case SNActionMenuOptionQZone://QQ空间
            str = @"sf_a=qq_qzone";
            break;
        case SNActionMenuOptionQQ:
            str = @"sf_a=qq";
            break;
        case SNActionMenuOptionMySOHU:
            str = @"sf_a=sns";
            break;
        case SNActionMenuOptionAliPaySession://支付宝
            str = @"sf_a=zhifubao";
            break;
        case SNActionMenuOptionAliPayLifeCircle:
            str = @"sf_a=zhifubao_circle";
            break;
        default:
            break;
    }
    
    if (str && str.length>0) {
        if ([SNUtility isProtocolV2:webUrl]) {
            return [NSString stringWithFormat:@"%@&%@",webUrl,str];
        }
        else {
            if([webUrl rangeOfString:@"?"].location == NSNotFound){
                return [NSString stringWithFormat:@"%@?%@",webUrl,str];
            }
            else{
                return [NSString stringWithFormat:@"%@&%@",webUrl,str];
            }
        }
    }

    return @"";
    
}

@end
