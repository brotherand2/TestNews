//
//  AppDelegate+ApplicationAssistant.m
//  iPhoneVideo
//
//  Created by FengHongen on 15/6/10.
//  Copyright (c) 2015年 SOHU. All rights reserved.
//

#import "AppDelegate+ApplicationAssistant.h"
#import "SNUserManager.h"
#import <objc/runtime.h>
#import "SNShareConfigs.h"
#import <SVVideoForNews/SVVideoForNews.h>
#import "SNRollingNewsViewController.h"
#import "SNShareWithCommentController.h"
#import "SNNewslogin.h"
#import "SNNewsLoginManager.h"

static const char *AppDelegate_ApplicationAssistant_ShareController = "AppDelegate_ApplicationAssistant_ShareController";
static const char *AppDelegate_ApplicationAssistant_actionMenuController = "AppDelegate_ApplicationAssistant_actionMenuController";
static const char *AppDelegate_ApplicationAssistant_shareManager = "AppDelegate_ApplicationAssistant_shareManager";
static const char *AppDelegate_ApplicationAssistant_ShareBlock = "AppDelegate_ApplicationAssistant_ShareBlock";
static const char *AppDelegate_ApplicationAssistant_ShareCompletionBlock = "AppDelegate_ApplicationAssistant_ShareCompletionBlock";
static const char *AppDelegate_ApplicationAssistant_LoginBlock = "AppDelegate_ApplicationAssistant_LoginBlock";

@implementation sohunewsAppDelegate (ApplicationAssistant)

#pragma mark - share

- (SNNewsShareManager *)shareManager {
    return objc_getAssociatedObject(self, &AppDelegate_ApplicationAssistant_shareManager);
}
- (void)setShareManager:(SNNewsShareManager *)shareManager {
    [self willChangeValueForKey:@"shareManager"];
    objc_setAssociatedObject(self,
                             &AppDelegate_ApplicationAssistant_shareManager,
                             shareManager,
                             OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    [self didChangeValueForKey:@"shareManager"];
}

- (SNActionMenuController *)actionMenuController {
    return objc_getAssociatedObject(self, &AppDelegate_ApplicationAssistant_actionMenuController);
}

- (void)setActionMenuController:(SNActionMenuController *)actionMenuController {
    [self willChangeValueForKey:@"actionMenuController"];
    objc_setAssociatedObject(self,
                             &AppDelegate_ApplicationAssistant_actionMenuController,
                             actionMenuController,
                             OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    [self didChangeValueForKey:@"actionMenuController"];
}

- (ShareController *)shareController {
    return objc_getAssociatedObject(self, &AppDelegate_ApplicationAssistant_ShareController);
}

- (void)setShareController:(ShareController *)shareController {
    [self willChangeValueForKey:@"shareController"];
    objc_setAssociatedObject(self,
                             &AppDelegate_ApplicationAssistant_ShareController,
                             shareController,
                             OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    [self didChangeValueForKey:@"shareController"];
}

- (ShareBlock)shareBlock {
    return objc_getAssociatedObject(self, &AppDelegate_ApplicationAssistant_ShareBlock);
}

- (void)setShareBlock:(ShareBlock)shareBlock {
    [self willChangeValueForKey:@"shareBlock"];
    objc_setAssociatedObject(self,
                             &AppDelegate_ApplicationAssistant_ShareBlock,
                             shareBlock,
                             OBJC_ASSOCIATION_COPY);
    [self didChangeValueForKey:@"shareBlock"];
}

- (LoginCallback)loginCallback{
    return objc_getAssociatedObject(self, &AppDelegate_ApplicationAssistant_LoginBlock);
}

- (void)setLoginCallback:(LoginCallback)loginCallback {
    [self willChangeValueForKey:@"loginCallback"];
    objc_setAssociatedObject(self,
                             &AppDelegate_ApplicationAssistant_LoginBlock,
                             loginCallback,
                             OBJC_ASSOCIATION_COPY);
    [self didChangeValueForKey:@"loginCallback"];
}

- (ShareCompletionBlock)shareCompletionBlock {
    return objc_getAssociatedObject(self, &AppDelegate_ApplicationAssistant_ShareCompletionBlock);
}

- (void)setShareCompletionBlock:(ShareCompletionBlock)shareCompletionBlock {
    [self willChangeValueForKey:@"shareCompletionBlock"];
    objc_setAssociatedObject(self,
                             &AppDelegate_ApplicationAssistant_ShareCompletionBlock,
                             shareCompletionBlock,
                             OBJC_ASSOCIATION_COPY);
    [self didChangeValueForKey:@"shareCompletionBlock"];
}

- (SNLoginRegisterViewController*)registerViewController {
    return objc_getAssociatedObject(self, &"LoginRegisterViewController");
}

- (void)setRegisterViewController:(SNLoginRegisterViewController*)registerViewController {
    [self willChangeValueForKey:@"loginRegisterViewController"];
    objc_setAssociatedObject(self,
                             &"LoginRegisterViewController",
                             registerViewController,
                             OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    [self didChangeValueForKey:@"loginRegisterViewController"];
}
/*params
 channelId = 71010000;
 shareImageUrl = "http://photocdn.sohu.com/tvmobile/20160104/14518684495811443.jpg";
 shareText = "\U5c0f\U4f19\U4f34\U4eec\Uff0c\U4f60\U4eec\U77e5\U9053\U5982\U4f55\U5dee\U5206\U7f8e\U4eba\U9c7c\U4e0e\U9c7c\U5996\U5417\Uff1f\U5176\U5b9e\U5f88\U7b80\U5355\Uff0c\U80f8\U5927\U4e3a\U7f8e\U4eba\U9c7c\Uff0c\U80f8\U5c0f\U6210\U9c7c\U5996\U3002\U6b32\U77e5\U8be6\U60c5\U8bf7\U770b\U672c\U671f\U5c0f\U9ec4\U4eba\U5410\U69fd\U3002\U559c\U6b22\U7684\U5c0f\U4f19\U4f34\U8bf7\U6dfb\U52a0\U5fae\U4fe1\U53f7\Uff1axd2299\Uff0c\U6bcf\U59298\U7bc7\U597d\U73a9\U5185\U5bb9\U63a8\U9001\U3002";
 shareTitle = "\U5c0f\U9ec4\U4eba\U5410\U69fd\U300a\U9a71\U9b54\U730e\U4eba\U300b\Uff1a\U80f8\U5927\U4e3a\U7f8e\U4eba\U9c7c";
 shareUrl = "http://m.tv.sohu.com/u/vw/82646960.shtml";
 vid = 82646960;

 */
- (void)showShareViewRootViewController:(UIViewController *)rootViewController
                                 params:(NSDictionary *)params
                             shareBlock:(ShareBlock)shareBlock
                   shareCompletionBlock:(ShareCompletionBlock)shareCompletionBlock{
    

    if (params && [params isKindOfClass:[NSDictionary class]]) {
        
        
        BOOL isqianfan = NO;
        if (nil == rootViewController) {
            isqianfan = YES;
        }
        [SNNotificationManager addObserver:self selector:@selector(statusBarOrientationChange:) name:UIApplicationDidChangeStatusBarOrientationNotification object:nil];
        self.shareBlock = shareBlock;
        self.shareCompletionBlock = shareCompletionBlock;
        
        //NEWSCLIENT-20852 【分享视频】ios：进入视频页面（视频加载中），点击分享进入分享编辑框
        //http://jira.sohuno.com/browse/NEWSCLIENT-20852?filter=-1
        NSNumber* vid = [params objectForKey:@"vid"];//没数据不能点击
        if (vid && [vid isKindOfClass:[NSNumber class]]) {
            if(vid.integerValue<=0){
                [[SNCenterToast shareInstance] showCenterToastWithTitle:@"数据获取异常，请稍后再试" toUrl:nil mode:SNCenterToastModeOnlyText];
                return;
            }
        }
        
 
        //wangshun share test
        NSMutableDictionary* dic = [NSMutableDictionary dictionaryWithDictionary:params];
        if (isqianfan) {
            if (![[SNUtility getApplicationDelegate] isNetworkReachable]) {
                [[SNCenterToast shareInstance] showCenterToastWithTitle:NSLocalizedString(@"network error", @"") toUrl:nil mode:SNCenterToastModeError];
                
                return ;
            }
            [dic setObject:@"1" forKey:SNNewsShare_isQianfan];
        }
        
        NSMutableDictionary* mdic = [self createShareData:dic];
        [self callShare:mdic Delegate:rootViewController];
    }
}

- (NSMutableDictionary*)createShareData:(NSDictionary*)params{
    NSMutableDictionary* mDic = [[NSMutableDictionary alloc] initWithCapacity:0];
    
    NSString *imageUrl =[NSString stringWithFormat:@"%@",params[@"shareImageUrl"]];
    NSString *content =[NSString stringWithFormat:@"%@",params[@"shareText"]];
    NSString *title =[NSString stringWithFormat:@"%@",params[@"shareTitle"]];
    NSString *mediaUrl =[NSString stringWithFormat:@"%@",params[@"shareUrl"]];
    NSString *vid =[NSString stringWithFormat:@"%@",params[@"vid"]];
    NSString *site =[NSString stringWithFormat:@"%@",params[@"site"]];
    
    NSString * protocolUrl = [NSString stringWithFormat:@"%@vid=%@&from=channel&channelId=%@&site=%@",kProtocolVideoV2,vid,[NSString stringWithFormat:@"%@",params[@"channelId"]],site];
    
    if (imageUrl && imageUrl.length > 0) {
        if ([SNAPI isWebURL:imageUrl]) {
            [mDic setObject:imageUrl forKey:kShareInfoKeyImageUrl];
        }
    }

    [mDic setObject:title?title:@"" forKey:SNNewsShare_title];
    [mDic setObject:content?content:@"" forKey:SNNewsShare_content];
    [mDic setObject:content?content:@"" forKey:SNNewsShare_shareContent];
    [mDic setObject:vid?vid:@"" forKey:@"vid"];
    [mDic setObject:mediaUrl?mediaUrl:@"" forKey:kShareInfoKeyMediaUrl];
    [mDic setObject:mediaUrl?mediaUrl:@"" forKey:kShareInfoKeyWebUrl];
    [mDic setObject:vid?vid:@"" forKey:@"vid"];
    [mDic setObject:protocolUrl?protocolUrl:@"" forKey:SNNewsShare_Url];
    [mDic setObject:@"video" forKey:SNNewsShare_ShareOn_contentType];
    [mDic setObject:@"video" forKey:SNNewsShare_LOG_type];
    [mDic setObject:@"141" forKey:SNNewsShare_V4Upload_sourceType];
    
    if ([params[@"isQianfanShare"] isEqualToString:@"1"]) {//qianfan
        [mDic setObject:title?title:@"" forKey:SNNewsShare_content];
        [mDic setObject:title?title:@"" forKey:SNNewsShare_shareContent];
        [mDic setObject:@"qianfan" forKey:SNNewsShare_ShareOn_contentType];
        [mDic setObject:@"qianfan" forKey:SNNewsShare_LOG_type];
        [mDic setObject:@"65" forKey:SNNewsShare_V4Upload_sourceType]; //65 qianfan视频
        [mDic setObject:@"1" forKey:SNNewsShare_isQianfan];
    }
    else{//视频
        [mDic setObject:@"1" forKey:SNNewsShare_isVideo];
    }
    
    return [mDic autorelease];
}

- (void)callShare:(NSDictionary*)dic Delegate:(id)del{
    
    if (self.shareManager && self.shareManager.menuVc && self.shareManager.menuVc.didDisAppearShareView ==NO) {//上一个浮层不隐藏 不能打开第二次分享
        return;
    }
    
    if (self.shareManager != nil) {
        self.shareManager = nil;
    }
 
    self.shareManager = [SNNewsShareManager loadShareData:dic Delegate:del];
    
    
    __block sohunewsAppDelegate* weakSelf = self;
    //视频登录和share内登录不一样 仅狐友用
    self.shareManager.shareToLogin =^(id objc){
        
        NSValue* method = [NSValue valueWithPointer:@selector(loginSuccess)];
        NSValue* onBackMethod = [NSValue valueWithPointer:@selector(onBack)];
        
        NSDictionary *dic = [[NSDictionary alloc] initWithObjectsAndKeys:method,@"method",onBackMethod,@"onBackMethod", nil];
        weakSelf.registerViewController = [[[SNLoginRegisterViewController alloc] initWithNavigatorURL:[NSURL URLWithString:@"tt://loginRegister"] query:dic] autorelease];
        weakSelf.registerViewController._delegate = weakSelf;
        weakSelf.registerViewController.isFromVideo = YES;
        [[[TTNavigator navigator] topViewController] presentViewController:weakSelf.registerViewController animated:YES completion:nil];
        [dic release];
    };

}


- (void)statusBarOrientationChange:(NSNotification *)notification
{
    
    UIInterfaceOrientation orientation = [[UIApplication sharedApplication] statusBarOrientation];
    if (orientation == UIInterfaceOrientationLandscapeRight) // home键靠右
    {
        if (self.actionMenuController) {
            [self.actionMenuController dismissActionMenu];
        }
    }
    
    if (
        orientation ==UIInterfaceOrientationLandscapeLeft) // home键靠左
    {
        if (self.actionMenuController) {
            [self.actionMenuController dismissActionMenu];
        }
    }
    
    if (orientation == UIInterfaceOrientationPortrait)
    {
        //
    }
    
    if (orientation == UIInterfaceOrientationPortraitUpsideDown)
    {
        //
    }
}

#pragma mark - alert

- (UIViewController *)alertPresentingViewController {
    return [SHVideoForNewsSDK appDelegateAlertPresentingViewController];
}

#pragma mark - login
/**
 *  跳出登录页面
 *
 *  @param parentViewController 点击登录按钮的Viewcontroller页面，可以在这里显示
 *  @param entrance             entrance description
 *  @param loginCallback        登录成功失败回调
 */
- (void)presentLoginViewControllerInViewController:(UIViewController *)parentViewController
                                     loginEntrance:(NSInteger)entrance
                                     loginCallback:(void (^)())loginCallback {
    self.loginCallback = loginCallback;
    //onBackMethod
    [[UIApplication sharedApplication].keyWindow endEditing:YES];
    
    [SNNewsLoginManager loginData:@{@"loginFrom":@"100032"} Successed:^(NSDictionary *info) {//111视频评论
        if (self.loginCallback) {
            self.loginCallback();
        }
    } Failed:^(NSDictionary *errorDic) {
        if (self.loginCallback) {
            self.loginCallback();
        }
    }];
    
    
//     NSValue* method = [NSValue valueWithPointer:@selector(loginSuccess)];
//    NSValue* onBackMethod = [NSValue valueWithPointer:@selector(onBack)];
//    
//    NSDictionary *dic = [[NSDictionary alloc] initWithObjectsAndKeys:method,@"method",onBackMethod,@"onBackMethod", nil];
//    self.registerViewController = [[[SNLoginRegisterViewController alloc] initWithNavigatorURL:[NSURL URLWithString:@"tt://loginRegister"] query:dic] autorelease];
//    self.registerViewController.sourceID = @"100032";
//    self.registerViewController._delegate = self;
//    self.registerViewController.isFromVideo = YES;
//    [[[TTNavigator navigator] topViewController] presentViewController:self.registerViewController animated:YES completion:nil];
//    [dic release];
}
-(void)loginSuccess{
    [self.registerViewController dismissViewControllerAnimated:YES completion:^{
        if (self.loginCallback) {
            self.loginCallback();
        }
        self.registerViewController = nil;
    }];
}
-(void)onBack{
    [self.registerViewController dismissViewControllerAnimated:YES completion:^{
        if (self.loginCallback) {
            self.loginCallback();
        }
        self.registerViewController = nil;
    }];
}

#pragma mark --  protocal method

/**
 *  监查当前用户是否为有效用户
 *
 *  @return YES or NO
 */
- (BOOL)currentUserIsValid{
    return [SNUserManager isLogin];
}

/**
 *  获取用户登录信息gid,token,passport
 *
 *  @return 字典
 */
- (NSDictionary *)getLoginUserInfo {
    return [NSDictionary dictionaryWithObjectsAndKeys:
            [SNUserManager getToken], @"token",
            [SNUserManager getUserId], @"passport",
            [SNUserManager getGid], @"gid",
            [SNUserManager getNickName], @"nickName",
            [SNUserManager getHeadImageUrl], @"headImageUrl",
            nil];
}

#pragma mark - login
/**
 *  显示新闻tab
 *
 */
- (void)showNewsTab{
    if ([[[TTNavigator navigator] topViewController] isKindOfClass:[SNShareWithCommentController class]]) {
        return;
    }
    if ([[[TTNavigator navigator] topViewController] isKindOfClass:[SNLoginRegisterViewController class]]) {
        return;
    }
    if ([[[TTNavigator navigator] topViewController] isKindOfClass:NSClassFromString(@"ShareToMyViewController")]) {
        return;
    }
    if ([[[TTNavigator navigator] topViewController] isKindOfClass:[SNRollingNewsViewController class]]) {
        SNRollingNewsViewController *newsViewController = (SNRollingNewsViewController*)[[TTNavigator navigator] topViewController];
        SNRollingNewsTableController *newsTableController = (SNRollingNewsTableController*)[newsViewController getCurrentTableController];
        if (newsTableController && newsTableController.searchVc) {
            return;
        }
    }
    [SNNotificationManager postNotificationName:kSNSShowTabBarNotification object:nil];
}

/**
 *  隐藏新闻tab
 *
 */
- (void)hiddenNewsTab{
    [SNNotificationManager postNotificationName:kSNSHideTabBarNotification object:nil];
}
/**
 *  是否显示全屏分享
 *
 *  @return YES显示 or NO隐藏，默认 NO
 */
- (BOOL)showFullScreenButton{
    return NO;
}

// 举报
- (void)pushVideoReportWithParams:(NSDictionary *)params{
    if (params[@"vid"]) {
        
        if(![SNUserManager isLogin])
        {
            NSMutableDictionary *infoDic = [NSMutableDictionary dictionary];
            [infoDic setObject:@"举报" forKey:kRegisterInfoKeyTitle];
            NSString* tipText = NSLocalizedString(@"user_info_guide_register_tip", nil);
            [infoDic setObject:tipText forKey:kRegisterInfoKeyText];
            infoDic[kRegisterInfoKeyName] = @"举报";
            [infoDic setObject:[NSNumber numberWithInteger:SNGuideRegisterTypeReport] forKey:kRegisterInfoKeyGuideType];
            [infoDic setObject:params[@"vid"] forKey:kRegisterInfoKeyNewsId];
             [infoDic setObject:@"2" forKey:@"type"];
             [infoDic setObject:params[@"vid"] forKey:@"vid"];
            NSValue* method = [NSValue valueWithPointer:@selector(loginSuccess)];
            [infoDic setObject:method forKey:@"method"];
            [infoDic setObject:@"video_report" forKey:@"fromType"];
            [infoDic setObject:kLoginFromReport forKey:kLoginFromKey];
            TTURLAction *_urlAction = [[[TTURLAction actionWithURLPath:@"tt://loginRegister"] applyAnimated:YES] applyQuery:infoDic];
            [[TTNavigator navigator] openURLAction:_urlAction];

            [[SNActionSheetLoginManager sharedInstance] setNewGuideDic:infoDic];
            return;
        }
        
        NSMutableDictionary* dic = [NSMutableDictionary dictionaryWithObjectsAndKeys:params[@"vid"],@"newsId", nil];
        NSString *urlString = [NSString stringWithFormat:kUrlReport,@"2"];
        urlString = [SNUtility addParamP1ToURL:urlString];
        urlString = [NSString stringWithFormat:@"%@&newsId=%@", urlString, params[@"vid"]];
        urlString = [NSString stringWithFormat:@"%@&vid=%@", urlString, params[@"vid"]];
        [dic setObject:urlString forKey:kLink];
        [dic setObject:[NSNumber numberWithInt:ReportWebViewType] forKey:kUniversalWebViewType];
        [SNUtility openUniversalWebView:dic];
    }
}

// 无图模式
- (BOOL)getNonePictureMode{
    NSInteger nonePictureMode = [[[NSUserDefaults standardUserDefaults] objectForKey:kNonePictureModeKey] intValue];
    if (nonePictureMode == kPicModeWiFi && [SNUtility getApplicationDelegate].isWWANNetworkReachable) {
        return YES;
    }
    return NO;
}

@end
