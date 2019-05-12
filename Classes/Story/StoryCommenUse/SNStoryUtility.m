//
//  SNStoryUtility.m
//  FacebookThree20
//
//  Created by chuanwenwang on 16/10/10.
//  Copyright © 2016年 chuanwenwang. All rights reserved.
//

#import "SNStoryUtility.h"
#import "AFNetworkReachabilityManager.h"

#import "SNUserManager.h"
#import "SNClientRegister.h"
#import "UIColor+StoryColor.h"
#import "SNNewsReport.h"
#import "SNStoryPage.h"
#import "StoryBookAnchor.h"

@implementation SNStoryUtility

+(sohunewsAppDelegate *)getAppDelegate
{
    sohunewsAppDelegate *appDelegate = (sohunewsAppDelegate*)[[UIApplication sharedApplication]delegate];
    
    return appDelegate;
}

+(StoryNetworkReachabilityStatus)currentReachabilityStatusForStory
{
    AFNetworkReachabilityManager *AFReachability = [AFNetworkReachabilityManager sharedManager];
    AFNetworkReachabilityStatus status = AFReachability.networkReachabilityStatus;
    return status;
}

#pragma marl 小说请求url
+(NSString *)getStoryRequestUrlWithStr:(NSString *)url
{
    NSString *urlStr = nil;
    
    if (url && url.length > 0) {
        urlStr = [SNAPI rootUrl:url];
        return urlStr;
    }
    
    return urlStr;
}

+(NSMutableDictionary *)getDefaultParam
{
    NSMutableDictionary *muDic = [NSMutableDictionary dictionary];
    
    NSString *p1Str = [SNUserManager getP1];
    [muDic setObject:p1Str?p1Str:@"" forKey:@"p1"];
    
    if([SNUserManager isLogin])
    {
        NSString *pid = [SNUserManager getPid];
        [muDic setObject:pid?pid:@"-1" forKey:@"pid"];
        NSString *token = [SNUserManager getToken];
        [muDic setObject:token?token:@"" forKey:@"token"];
        NSString *gid = [SNUserManager getGid];
        [muDic setObject:gid?gid:@"" forKey:@"gid"];
    }
    else
    {
        [muDic setObject:@"-1" forKey:@"pid"];
        
    }
    
    NSString *apiVersion = [NSString stringWithFormat:@"%ld",APIVersion];
    [muDic setObject:apiVersion forKey:@"apiVersion"];
    
    //sid
    NSString *sid = [SNClientRegister sharedInstance].sid;
    [muDic setObject:sid?sid:@"" forKey:@"sid"];
    
    NSString *u = [SNAPI productId];
    [muDic setObject:u?u:@"" forKey:@"u"];
    return muDic;
}

//正文分享
+(void)shareActionWith:(NSMutableDictionary *)shareDic {
    
    NSString *title = [shareDic objectForKey:@"shareTitle"];
    NSString *content = [shareDic objectForKey:@"shareDescription"];
    
    if (content.length == 0) {
        
        content = kFromSohuNewsClient;
    }
    
    NSString *shareUrl = [shareDic objectForKey:@"shareUrl"];
    
    NSString *shareLink = @"%@title=%@&content=%@&icon=%@&pics=%@&shareon=%@&link=%@&contentType=%@&sourceType=50";
    
    NSString *string = [NSString stringWithFormat: shareLink, kProtocolShare, [title URLEncodedString], [content URLEncodedString],[shareDic objectForKey:@"shareImage"],[shareDic objectForKey:@"shareImage"],[shareUrl URLEncodedString], [shareDic objectForKey:@"link"], [shareDic objectForKey:@"contentType"]];
    
    [SNStoryUtility openProtocolUrl:string context:nil];
}

+(BOOL)loginTipCloseState
{
    NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
    BOOL state = [userDefault boolForKey:@"loginTipCloseState"];
    return state;
}

+(void)loginTipCloseStateWithState:(BOOL)state
{
    NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
    [userDefault setBool:state forKey:@"loginTipCloseState"];
    [userDefault synchronize];
}

+(void)pushViewController:(UIViewController *)viewController animated:(BOOL)animated
{
    [SNUtility shouldUseSpreadAnimation:NO];
    [SNUtility shouldAddAnimationOnSpread:NO];
    SNNavigationController *navigationController = [TTNavigator navigator].topViewController.flipboardNavigationController;
    [navigationController pushViewController:viewController animated:animated];
}

+(void)popViewControllerAnimated:(BOOL)animated
{
    SNNavigationController *navigationController = [TTNavigator navigator].topViewController.flipboardNavigationController;
    [navigationController popViewControllerAnimated:animated];
}

+(void)openProtocolUrl:(NSString *)pushURLStr context:(NSDictionary *)context
{
    [SNUtility openProtocolUrl:pushURLStr context:context];
}

+(void)setPanGestureWithState:(BOOL)state
{
    SNNavigationController *navigationController = [TTNavigator navigator].topViewController.flipboardNavigationController;//解决手势冲突
    navigationController.banPanGesture = state;
}

+(BOOL)isLogin
{
    return [SNUserManager isLogin];
}

+(NSString *)getCookie
{
    return [SNUserManager getCookie];
}

+(NSString *)getUserId
{
    return [SNUserManager getUserId];
}

+(NSString *)getP1
{
    return [SNUserManager getP1];
}

+(NSString *)getPid
{
    return [SNUserManager getPid];
}

+(NSString *)getToken {
    return [SNUserManager getToken];
}

+(NSString *)getGid {
    return [SNUserManager getGid];
}

+(NSString *)getU {
    return [SNAPI productId];
}

+(void)openUrlPath:(NSString *)urlPath applyQuery:(NSDictionary *)query applyAnimated:(BOOL)animated
{
    [SNUtility shouldUseSpreadAnimation:NO];
    TTURLAction *_urlAction = [[[TTURLAction actionWithURLPath:urlPath] applyAnimated:animated] applyQuery:query];
    [[TTNavigator navigator] openURLAction:_urlAction];
}

#pragma mark 小说埋点
+ (void)storyReportADotGif:(NSString *)string
{
    [SNNewsReport reportADotGif:string];
}

#pragma mark 小说操作栏属性
+(NSDictionary *)getReadPropertyWithStr:(NSString *)string
{
    NSString *path = [[NSBundle mainBundle]pathForResource:@"ReadSetting" ofType:@"plist"];
    NSDictionary *plistDic = [NSDictionary dictionaryWithContentsOfFile:path];
    NSDictionary *dic = [plistDic objectForKey:string];
    return dic;
}

#pragma mark 小说操作栏颜色
+(UIColor *)getReadColor
{
    NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
    NSString *storyColorTheme = [userDefault objectForKey:@"storyColorTheme"];
    NSString *path = [[NSBundle mainBundle]pathForResource:@"ReadSetting" ofType:@"plist"];
    NSDictionary *plistDic = [NSDictionary dictionaryWithContentsOfFile:path];
    NSDictionary *dic = [plistDic objectForKey:storyColorTheme];
    return [UIColor colorFromKey:[dic objectForKey:@"bgColor"]];
}

#pragma mark -获取小说锚点
+(void)getNovelAchor
{
    NSArray *anchorArray = [StoryBookAnchor fetchAllBookAnchor];
    if (!anchorArray || anchorArray.count <= 0) {
        [SNStoryPage novelGet_AnchorDic:@{@"platform":@"5"} completeBlock:nil];
    }
}

@end
