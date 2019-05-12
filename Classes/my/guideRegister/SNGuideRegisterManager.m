
//
//  SNGuideRegisterManager.m
//  sohunews
//
//  Created by jialei on 13-8-8.
//  Copyright (c) 2013年 Sohu.com. All rights reserved.
//

#import "SNGuideRegisterManager.h"
#import "SNDBManager.h"
#import "SNGuideRegisterViewController.h"
#import "SNActionSheetLoginManager.h"
#import "SNSubscribeCenterService.h"
#import "SNUserManager.h"
#import "SNNewsLoginManager.h"
#import "SNBaseWebViewController.h"


@implementation SNGuideRegisterManager

//订阅引导登陆
+ (void)showGuideWithSubId:(NSString *)subId
{
    SCSubscribeObject *subObj = [[SNDBManager currentDataBase] getSubscribeCenterSubscribeObjectBySubId:subId];
    NSMutableDictionary *infoDic = [NSMutableDictionary dictionary];
    [infoDic setObject:@"关注" forKey:kRegisterInfoKeyTitle];
    NSString *tipText = NSLocalizedString(@"user_info_guide_register_tip", nil);
    NSString *tipName = NSLocalizedString(@"user_info_guide_register_secretary", nil);
    
    // 如果是订阅行为 之前未完成的订阅 如果需要自动完成订阅 成全之 by jojo
    if (subObj.subIcon)
        [infoDic setObject:subObj.subIcon forKey:kRegisterInfoKeyImageUrl];
    if (subObj.subName)
    {
        tipName = subObj.subName;
        tipText = [NSString stringWithFormat:@"作者已经设置为\n请先登录再订阅媒体"];
    }
    if (subId)
        [infoDic setObject:subId forKey:kRegisterInfoKeySubId];
    [infoDic setObject:tipName forKey:kRegisterInfoKeyName];
    [infoDic setObject:tipText forKey:kRegisterInfoKeyText];
    [infoDic setObject:[NSNumber numberWithInteger:SNGuideRegisterTypeSubscribe] forKey:kRegisterInfoKeyGuideType];
    
    [[SNActionSheetLoginManager sharedInstance] setNewGuideDic:infoDic];
    [self showLoginActionSheetWithDict:@{kContent:@"作者已经设置为请先登录再订阅媒体"}];
}

+ (void)guideForSubscribe:(NSString *)subId
{
    if (![SNUserManager isLogin]) {//login
        NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInteger:SNGuideRegisterTypeSubscribe], kRegisterInfoKeyGuideType, kLoginFromComment, kLoginFromKey, nil];
        //[SNUtility openLoginViewWithDict:dict];
        //wangshun login open
        [SNNewsLoginManager loginData:nil Successed:^(NSDictionary *info) {//000疑似废弃
            
        } Failed:nil];
    }
    else{
        SCSubscribeObject *object = [[SNDBManager currentDataBase] getSubscribeCenterSubscribeObjectBySubId:subId];
        if (object) {
            NSString *succMsg = [object succSubMsg];
            NSString *failMsg = [object failSubMsg];
            
            SNSubscribeCenterOperation *opt = [SNSubscribeCenterOperation operationWithType:SCServiceOperationTypeAddMySubToServer request:nil refId:object.subId];
            [opt addBackgroundListenerWithSuccMsg:succMsg failMsg:failMsg];
            [[SNSubscribeCenterService defaultService] addMySubToServerBySubObject:object];
        }
    }
}

//普通评论
+ (void)showGuideWithContentComment:(NSString *)loginFrom
{
    NSMutableDictionary *infoDic = [NSMutableDictionary dictionary];
    [infoDic setObject:@"评论" forKey:kRegisterInfoKeyTitle];
    
    NSString* tipText = NSLocalizedString(@"user_info_guide_register_tip", nil);
    [infoDic setObject:tipText forKey:kRegisterInfoKeyText];
    [infoDic setObject:[NSNumber numberWithInteger:SNGuideRegisterTypeContentComment] forKey:kRegisterInfoKeyGuideType];
    
    [[SNActionSheetLoginManager sharedInstance] setNewGuideDic:infoDic];
    [self showLoginActionSheetWithDict:@{kContent:loginFrom}];
}

+ (void)showGuideWithContentCommentImage
{
    NSMutableDictionary *infoDic = [NSMutableDictionary dictionary];
    [infoDic setObject:@"评论" forKey:kRegisterInfoKeyTitle];
    
    NSString* tipText = NSLocalizedString(@"user_info_guide_register_tip", nil);
    [infoDic setObject:tipText forKey:kRegisterInfoKeyText];
    [infoDic setObject:[NSNumber numberWithInteger:SNGuideRegisterTypeContentComment] forKey:kRegisterInfoKeyGuideType];
    
    [[SNActionSheetLoginManager sharedInstance] setNewGuideDic:infoDic];
    [self showLoginActionSheetWithDict:@{kContent:@"请先登录才能添加照片，使用下列方式登录"}];
}

+ (void)showGuideWithContentCommentAudio
{
    NSMutableDictionary *infoDic = [NSMutableDictionary dictionary];
    [infoDic setObject:@"评论" forKey:kRegisterInfoKeyTitle];
    
    NSString* tipText = NSLocalizedString(@"user_info_guide_register_tip", nil);
    [infoDic setObject:tipText forKey:kRegisterInfoKeyText];
    [infoDic setObject:[NSNumber numberWithInteger:SNGuideRegisterTypeContentComment] forKey:kRegisterInfoKeyGuideType];
    
    [[SNActionSheetLoginManager sharedInstance] setNewGuideDic:infoDic];
    [self showLoginActionSheetWithDict:@{kContent:@"请先登录才能添加语音，使用下列方式登录"}];
}

+ (void)showGuideWithH5LiveInvite
{
    NSMutableDictionary *infoDic = [NSMutableDictionary dictionary];
    [infoDic setObject:@"直播邀请" forKey:kRegisterInfoKeyTitle];
    
    NSString* tipText = NSLocalizedString(@"user_info_guide_register_tip", nil);
    [infoDic setObject:tipText forKey:kRegisterInfoKeyText];
    [infoDic setObject:[NSNumber numberWithInteger:SNGuideRegisterTypeH5LiveInvite] forKey:kRegisterInfoKeyGuideType];
    
    [[SNActionSheetLoginManager sharedInstance] setNewGuideDic:infoDic];
    [self showLoginActionSheetWithDict:@{kContent:@"请先登录才能被邀请，使用下列方式登录"}];
}


+ (void)login:(NSString *)loginFrom
{
    /*
    NSMutableDictionary *infoDic = [NSMutableDictionary dictionary];
    [infoDic setObject:@"登录" forKey:kRegisterInfoKeyTitle];
    
    NSString* tipText =NSLocalizedString(@"user_info_guide_login_tip", nil);
    [infoDic setObject:tipText forKey:kRegisterInfoKeyText];
    [infoDic setObject:[NSNumber numberWithInteger:SNGuideRegisterTypeLogin] forKey:kRegisterInfoKeyGuideType];
    
    //[[SNActionSheetLoginManager sharedInstance] setNewGuideDic:infoDic];
    TTURLAction *urlAction = [[[TTURLAction actionWithURLPath:@"tt://guideRegister"] applyAnimated:YES] applyQuery:infoDic];
    [[TTNavigator navigator] openURLAction:urlAction];
    */
    
    // 这个就是进之前的用户中心
    [SNUtility shouldUseSpreadAnimation:NO];

    NSValue* method = [NSValue valueWithPointer:@selector(loginSuccess)];
    NSDictionary* dic = [NSDictionary dictionaryWithObjectsAndKeys:method,@"method" ,
                         [NSNumber numberWithInteger:SNGuideRegisterTypeLogin], kRegisterInfoKeyGuideType, loginFrom, kLoginFromKey,
                         nil];

    //[SNUtility openLoginViewWithDict:dic];
//    NSValue* method = [NSValue valueWithPointer:@selector(loginSuccess)];
//    NSDictionary* dic = [NSDictionary dictionaryWithObjectsAndKeys:method,@"method" ,
//                         [NSNumber numberWithInteger:SNGuideRegisterTypeLogin], kRegisterInfoKeyGuideType, loginFrom, kLoginFromKey,
//                         nil];
//    
//    TTURLAction *_urlAction = [[[TTURLAction actionWithURLPath:@"tt://loginRegister"] applyAnimated:YES] applyQuery:dic];
//    [[TTNavigator navigator] openURLAction:_urlAction];
    
    
    //wangshun login open
    [SNNewsLoginManager loginData:nil Successed:^(NSDictionary *info) {//000疑似废弃
        
    } Failed:nil];

}

+ (void)guideForContentComment
{
//    [SNNotificationManagerpostNotificationName:kGuideRegisterSuccessNotification object:nil];
    [SNNotificationManager postNotificationName:kLoginFromArticleCommentNotification object:nil];
}

+ (void)guideForReplyComment
{
    [SNNotificationManager postNotificationName:kLoginFromArticleReplayCommentNotification object:nil];
}

//自媒体评论
+ (void)showGuideWithMediaComment:(NSString *)subId
{
    SCSubscribeObject *subObj = [[SNDBManager currentDataBase] getSubscribeCenterSubscribeObjectBySubId:subId];
    NSMutableDictionary *infoDic = [NSMutableDictionary dictionary];
    [infoDic setObject:@"评论" forKey:kRegisterInfoKeyTitle];
    NSString* tipText = NSLocalizedString(@"user_info_guide_register_tip", nil);
    if (subObj.subIcon)
        [infoDic setObject:subObj.subIcon forKey:kRegisterInfoKeyImageUrl];
    if (subObj.subName)
    {
        [infoDic setObject:subObj.subName forKey:kRegisterInfoKeyName];
        tipText = [NSString stringWithFormat:@"作者已经设置为\n请先登录再参与评论"];
    }
    if (subId.length)
        [infoDic setObject:subId forKey:kRegisterInfoKeySubId];
    
    [infoDic setObject:tipText forKey:kRegisterInfoKeyText];
    [infoDic setObject:[NSNumber numberWithInteger:SNGuideRegisterTypeMediaComment] forKey:kRegisterInfoKeyGuideType];
    
    [[SNActionSheetLoginManager sharedInstance] setNewGuideDic:infoDic];
    [self showLoginActionSheetWithDict:@{kContent:@"请先登录才能进行评论,使用下列方式登录"}];
}

+ (void)guideForMediaComment
{
}

//摇一摇
+ (void)showGuideWithShake:(NSString*)subId
{
    SCSubscribeObject *subObj = [[SNDBManager currentDataBase] getSubscribeCenterSubscribeObjectBySubId:subId];
    NSMutableDictionary *infoDic = [NSMutableDictionary dictionary];
    [infoDic setObject:@"摇一摇" forKey:kRegisterInfoKeyTitle];
    
    if (subObj.subIcon)
        [infoDic setObject:subObj.subIcon forKey:kRegisterInfoKeyImageUrl];
    if (subObj.subName)
    {
        [infoDic setObject:subObj.subName forKey:kRegisterInfoKeyName];
    }
    if (subId.length)
        [infoDic setObject:subId forKey:kRegisterInfoKeySubId];
    
    NSString* tipText = NSLocalizedString(@"user_info_guide_register_tip", nil);
    [infoDic setObject:tipText forKey:kRegisterInfoKeyText];
    [infoDic setObject:[NSNumber numberWithInteger:SNGuideRegisterTypeShake] forKey:kRegisterInfoKeyGuideType];
    
    [[SNActionSheetLoginManager sharedInstance] setNewGuideDic:infoDic];
    [self showLoginActionSheetWithDict:@{kContent:@"请先登录再使用此功能"}];
}

+ (void)guideForShake:(NSString *)subId
{
    SCSubscribeObject *obj = [[SNDBManager currentDataBase] getSubscribeCenterSubscribeObjectBySubId:subId];
    NSMutableDictionary *userInfo = [SNUtility parseURLParam:obj.link schema:kProtocolPlugin];
    NSString *plugin = [userInfo objectForKey:@"id"];
    TTURLAction *urlAction = [SNUtility actionWithPluginName:plugin userInfo:userInfo];
    
    [[TTNavigator navigator] openURLAction:urlAction];
}

//用户中心
+ (void)showGuideWithUserCenter:(NSString *)pid userSpace:(NSString *)link subUser:(SCSubscribeObject *)subObj
{
    NSMutableDictionary *infoDic = [NSMutableDictionary dictionary];
    [infoDic setObject:@"用户中心" forKey:kRegisterInfoKeyTitle];
    NSString *tipText = NSLocalizedString(@"user_info_guide_register_tip", nil);
    NSString *tipName = NSLocalizedString(@"user_info_guide_register_secretary", nil);
    if (subObj.subIcon)
        [infoDic setObject:subObj.subIcon forKey:kRegisterInfoKeyImageUrl];
    
    if (subObj.subName)
        tipName = subObj.subName;
    
    if (pid.length) 
        [infoDic setObject:pid forKey:kRegisterInfoKeyUserPid];
    
    if (link.length) 
        [infoDic setObject:link forKey:kRegisterInfoKeyUserLink];
    
    [infoDic setObject:tipName forKey:kRegisterInfoKeyName];
    
    [infoDic setObject:tipText forKey:kRegisterInfoKeyText];
    [infoDic setObject:[NSNumber numberWithInteger:SNGuideRegisterTypeUsercenter] forKey:kRegisterInfoKeyGuideType];
    
    [[SNActionSheetLoginManager sharedInstance] setNewGuideDic:infoDic];
    [self showLoginActionSheetWithDict:@{kContent:@"请先登录再关注我"}];
}

+ (void)showUserCenter
{
    TTURLAction* urlAction = [[TTURLAction actionWithURLPath:@"tt://recommendUser"] applyAnimated:YES];
    [[TTNavigator navigator] openURLAction:urlAction];
}

+ (BOOL)showAddFriend
{
#pragma mark - huangjing  //新闻端在登录后会跳转到原始的推荐好友页 我的SDK不需要
    return NO;
#pragma mark - end
    
    NSNumber* showAddFriend = [[NSUserDefaults standardUserDefaults] objectForKey:kShowAddFriend];
    if(![showAddFriend boolValue])
    {
        TTURLAction *action = [[TTURLAction actionWithURLPath:@"tt://recommendUser"] applyAnimated:YES];
        [[TTNavigator navigator] openURLAction:action];
        [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithBool:YES] forKey:kShowAddFriend];
        [[NSUserDefaults standardUserDefaults] synchronize];
        return YES;
    }
    return NO;
}

+ (void)guideForUserCenter:(NSString *)pid userSpace:(NSString *)link
{
    if (pid.length > 0)
    {
        TTURLAction* urlAction = [[[TTURLAction actionWithURLPath:@"tt://userCenter"] applyQuery:@{@"pid" : pid}] applyAnimated:YES];
        [[TTNavigator navigator] openURLAction:urlAction];
    }
    else if (link.length > 0)
    {
        NSMutableDictionary *dic = [NSMutableDictionary dictionaryWithObjectsAndKeys:link, @"url",nil];
        TTURLAction* urlAction = [[[TTURLAction actionWithURLPath:@"tt://oauthWebView"] applyQuery:dic] applyAnimated:YES];
        [[TTNavigator navigator] openURLAction:urlAction];
    }
}

//用户中心关注
+ (void)showGuideForAttention:(NSString *)iconUrl userName:(NSString *)name
{
    NSMutableDictionary *infoDic = [NSMutableDictionary dictionary];
    [infoDic setObject:@"关注" forKey:kRegisterInfoKeyTitle];
    NSString *tipText = NSLocalizedString(@"user_info_guide_register_attention", nil);
    NSString *tipName = NSLocalizedString(@"user_info_guide_register_secretary", nil);
    if (iconUrl.length > 0)
        [infoDic setObject:iconUrl forKey:kRegisterInfoKeyImageUrl];
    
    if (name.length > 0)
    {
        tipName = name;
    }
    
    [infoDic setObject:tipName forKey:kRegisterInfoKeyName];
    [infoDic setObject:tipText forKey:kRegisterInfoKeyText];
    [infoDic setObject:[NSNumber numberWithInteger:SNGuideRegisterTypeUserAttention] forKey:kRegisterInfoKeyGuideType];
    
    [[SNActionSheetLoginManager sharedInstance] setNewGuideDic:infoDic];
    [self showLoginActionSheetWithDict:@{kContent:@"请先登录再关注我"}];
}

+ (void)guideForAttention
{
    [SNNotificationManager postNotificationName:kGuideRegisterSuccessNotification object:nil];
}

//退出
+ (BOOL)popGuideRegisterController:(NSArray*)conntrollerArray popController:(UIViewController *)controller
{
    for (UIViewController *vc in conntrollerArray) {
        if([vc isKindOfClass:[SNGuideRegisterViewController class]]) {
            NSInteger index = [conntrollerArray indexOfObject:vc] - 1;
            if (index >= 0) {
                UIViewController* baseView = (UIViewController*)[conntrollerArray objectAtIndex:index];
                [controller.flipboardNavigationController popToViewController:baseView animated:YES];
                return YES;
            }
        }
    }
    return NO;
}

+ (void)showMyFav
{
    NSNumber* showAddFriend = [[NSUserDefaults standardUserDefaults] objectForKey:kShowAddFriend];
    if(![showAddFriend boolValue])
    {
        TTURLAction *action = [[TTURLAction actionWithURLPath:@"tt://recommendUser"] applyAnimated:YES];
        [[TTNavigator navigator] openURLAction:action];
        [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithBool:YES] forKey:kShowAddFriend];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
    else
    {
        TTURLAction *_urlAction = [[TTURLAction actionWithURLPath:@"tt://myFavourites"] applyAnimated:YES];
        [[TTNavigator navigator] openURLAction:_urlAction];
    }
}

+ (void)showMyFavByFloat {
    TTURLAction *_urlAction = [[TTURLAction actionWithURLPath:@"tt://myFavourites"] applyAnimated:YES];
    [[TTNavigator navigator] openURLAction:_urlAction];
}

+ (void)myMessage
{

    NSValue* method = [NSValue valueWithPointer:@selector(loginSuccess)];
    NSDictionary* dic = [NSDictionary dictionaryWithObjectsAndKeys:method,@"method" ,
                         [NSNumber numberWithInteger:SNGuideRegisterTypeMessage], kRegisterInfoKeyGuideType,
                         nil];
    //[SNUtility openLoginViewWithDict:dic];

//    NSValue* method = [NSValue valueWithPointer:@selector(loginSuccess)];
//    NSDictionary* dic = [NSDictionary dictionaryWithObjectsAndKeys:method,@"method" ,
//                         [NSNumber numberWithInteger:SNGuideRegisterTypeMessage], kRegisterInfoKeyGuideType,
//                         nil];
//    
//    TTURLAction *_urlAction = [[[TTURLAction actionWithURLPath:@"tt://loginRegister"] applyAnimated:YES] applyQuery:dic];
//    [[TTNavigator navigator] openURLAction:_urlAction];
    
    
    //wangshun login open
    [SNNewsLoginManager loginData:nil Successed:^(NSDictionary *info) {//000疑似废弃
        [SNGuideRegisterManager showMyMessageByFloat];
    } Failed:nil];
}

+ (void)showLoginActionSheetWithDict:(NSDictionary *)dict {
    NSString *urlString = [dict stringValueForKey:kContent defaultValue:@""];
    if ([SNUserManager isLogin]) {
        if ([SNAPI isWebURL:urlString]) {
            urlString = [SNUtility addParamSuccessToURL:urlString];
        }
        
        [SNUtility openProtocolUrl:urlString context:dict];
    }
    else {
        [SNUtility shouldUseSpreadAnimation:NO];

//NSValue* method = [NSValue valueWithPointer:@selector(loginSuccess)];
//        NSDictionary *dictInfo = [NSDictionary dictionaryWithObjectsAndKeys:method, @"method", urlString, kLoginFromKey,[NSNumber numberWithInt:SNGuideRegisterTypeBackToUrl],kRegisterInfoKeyGuideType, [dict stringValueForKey:kUniversalWebViewType defaultValue:@""], kUniversalWebViewType,nil];
 
        //[SNUtility openLoginViewWithDict:dictInfo];

//        NSValue* method = [NSValue valueWithPointer:@selector(loginSuccess)];
//
//        NSDictionary *dictInfo = [NSDictionary dictionaryWithObjectsAndKeys:method, @"method", urlString, kLoginFromKey,[NSNumber numberWithInt:SNGuideRegisterTypeBackToUrl],kRegisterInfoKeyGuideType, [dict stringValueForKey:kUniversalWebViewType defaultValue:@""], kUniversalWebViewType,nil];
//        
//        
//        TTURLAction *_urlAction = [[[TTURLAction actionWithURLPath:@"tt://loginRegister"] applyAnimated:YES] applyQuery:dictInfo];
//        [[TTNavigator navigator] openURLAction:_urlAction];

//        NSValue* method = [NSValue valueWithPointer:@selector(loginSuccess)];
//        NSDictionary *dictInfo = [NSDictionary dictionaryWithObjectsAndKeys:method, @"method", urlString, kLoginFromKey,[NSNumber numberWithInt:SNGuideRegisterTypeBackToUrl],kRegisterInfoKeyGuideType, [dict stringValueForKey:kUniversalWebViewType defaultValue:@""], kUniversalWebViewType,nil];
//        TTURLAction *_urlAction = [[[TTURLAction actionWithURLPath:@"tt://loginRegister"] applyAnimated:YES] applyQuery:dictInfo];
//        [[TTNavigator navigator] openURLAction:_urlAction];
        
        //wangshun login open
        [SNNewsLoginManager loginData:nil Successed:^(NSDictionary *info) {//111活动／直播间评论／千帆直播
            
            [SNGuideRegisterManager gotoLoginSuccessBackUrl];
        } Failed:nil];

    }
}

+ (void)gotoLoginSuccessBackUrl{
    NSString *backUrl = [[SNActionSheetLoginManager sharedInstance] backUrl];
    if (backUrl.length > 0) {
        NSArray *viewsArray = [TTNavigator navigator].topViewController.flipboardNavigationController.viewControllers;
        NSInteger index = [viewsArray count] - 1;
        if ([[viewsArray objectAtIndex:index] isKindOfClass:[SNBaseWebViewController class]] && index > 1) {
            if ([[viewsArray objectAtIndex:index - 1] isKindOfClass:[SNBaseWebViewController class]]) {
                [[TTNavigator navigator].topViewController.flipboardNavigationController popToViewController:[viewsArray objectAtIndex:index - 1] animated:YES];
            }
        }
        if ([SNUtility isProtocolV2:backUrl] || [backUrl hasPrefix:@"http"]) {
            NSString *urlString = [SNUtility addParamSuccessToURL:backUrl];
            [SNUtility openProtocolUrl:urlString];
        }
    }

}

+ (void)showMyMessage
{
    NSNumber* showAddFriend = [[NSUserDefaults standardUserDefaults] objectForKey:kShowAddFriend];
    if(![showAddFriend boolValue])
    {
        TTURLAction *action = [[TTURLAction actionWithURLPath:@"tt://recommendUser"] applyAnimated:YES];
        [[TTNavigator navigator] openURLAction:action];
        [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithBool:YES] forKey:kShowAddFriend];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
    else
    {
        TTURLAction *_urlAction = [[TTURLAction actionWithURLPath:@"tt://myMessage"] applyAnimated:YES];
        [[TTNavigator navigator] openURLAction:_urlAction];
    }
}

+ (void)showMyMessageByFloat {
    TTURLAction *_urlAction = [[TTURLAction actionWithURLPath:@"tt://myMessage"] applyAnimated:YES];
    [[TTNavigator navigator] openURLAction:_urlAction];
}

+ (void)protocolLogin:(NSString*)backUrl dictInfo:(NSDictionary *)dictInfo
{
    NSMutableDictionary* infoDic = [NSMutableDictionary dictionaryWithCapacity:3];
    NSString* tipText = NSLocalizedString(@"user_info_guide_register_tip", nil);
    [infoDic setObject:tipText forKey:kRegisterInfoKeyText];
    [infoDic setObject:[NSNumber numberWithInteger:SNGuideRegisterTypeProtocolLogin] forKey:kRegisterInfoKeyGuideType];
    if ([dictInfo objectForKey:kWebViewForceBackKey]) {
        [infoDic setObject:[dictInfo objectForKey:kWebViewForceBackKey] forKey:kWebViewForceBackKey];
    }
    
    if (backUrl)
        [infoDic setObject:backUrl forKey:kRegisterInfoKeyBackUrl];
       [[SNActionSheetLoginManager sharedInstance] setNewGuideDic:infoDic];
    
    if ([dictInfo stringValueForKey:kUniversalWebViewType defaultValue:@""] && backUrl.length > 0) {
        dictInfo = @{kContent:backUrl, kUniversalWebViewType:[dictInfo stringValueForKey:kUniversalWebViewType defaultValue:@""]};
    }
    
    if ([backUrl rangeOfString:@"screen=1"].location != NSNotFound) {
        NSString* loginlink = [NSString stringWithFormat:@"login://%@",backUrl];
        NSDictionary* params = [SNUtility parseURLParam:backUrl schema:kProtocolLogin];
        NSString* halfScreenTitle = [params objectForKey:@"title"];
        [SNNewsLoginManager halfLoginData:@{@"halfScreenTitle":halfScreenTitle} Successed:^(NSDictionary *info) {
            
            [SNGuideRegisterManager gotoLoginSuccessBackUrl];
        } Failed:nil];
        return;
    }
    
    [self showLoginActionSheetWithDict:dictInfo];
}

+ (void)showGuideWithApproval:(NSString *)actId pid:(NSString *)pid approvalType:(int)type
{
    NSMutableDictionary *infoDic = [NSMutableDictionary dictionary];
//    [infoDic setObject:@"评论" forKey:kRegisterInfoKeyTitle];
    
//    NSString* tipText = NSLocalizedString(@"user_info_guide_register_tip", nil);
//    [infoDic setObject:tipText forKey:kRegisterInfoKeyText];
    [infoDic setObject:[NSNumber numberWithInteger:SNGuideRegisterTypeTrendApproval] forKey:kRegisterInfoKeyGuideType];
    if (actId.length > 0) {
        [infoDic setObject:actId forKey:kRegisterInfoKeyActId];
    }
    if (pid.length > 0) {
        [infoDic setObject:pid forKey:kRegisterInfoKeyUserPid];
    }
    [infoDic setObject:[NSString stringWithFormat:@"%d", type] forKey:kRegisterInfoKeyApprovalType];
    
    [[SNActionSheetLoginManager sharedInstance] setNewGuideDic:infoDic];
    [self showLoginActionSheetWithDict:@{kContent:@"请先登录才再使用次功能，使用下列方式登录"}];
}

@end
