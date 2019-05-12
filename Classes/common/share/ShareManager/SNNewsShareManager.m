//
//  SNNewsShareManager.m
//  sohunews
//
//  Created by wang shun on 2017/1/18.
//  Copyright © 2017年 Sohu.com. All rights reserved.
//

#import "SNNewsShareManager.h"

#import "SNShareMenuViewController.h"

#import "SNSharePlatformHeader.h"

#import "SNNewsShareGif.h"

#import "SNNewsShareAnalysisTitle.h"


//登录代码，仅用于狐友
#import "SNUserManager.h"
#import "SNLoginRegisterViewController.h"
#import "SNNewsLoginManager.h"

@implementation SNNewsShareManager

- (instancetype)init{
    if (self = [super init]) {
        
    }
    return self;
}

//点击 各平台分享icon 按钮
- (void)shareIconSelected:(NSString*)iconTitle ShareData:(NSDictionary *)shareData {
    SNDebugLog(@"shareIconSelectedTitle:%@",iconTitle);
    SNDebugLog(@"shareData:%@",shareData);
    
    BOOL isInstalled = YES;
    NSString* toastTitle = @"";
    SNSharePlatformBase* sharePlatform = nil;
    
    NSDictionary* dic = [SNNewsShareAnalysisTitle getIsAppClassData:iconTitle WithData:shareData];//点击数据后获取应有的配置
    if (dic == nil) {
        if (![SNUserManager isLogin]) {//仅处理狐友分享 
            if([iconTitle isEqualToString:kShareTitleMySohu] || [iconTitle isEqualToString:SNNewsShare_Icons_Sohu]) {
                NSString* ss = [shareData stringValueForKey:@"screen_share" defaultValue:nil];
                if (ss && [ss isEqualToString:@"1"]) {//如果是截屏分享
                    [SNNewsLoginManager loginData:nil Successed:nil Failed:nil];
                    return;
                }
                
                NSString* entrance = @"7";
                if ([shareData objectForKey:@"entrance"]) {
                    entrance = [shareData objectForKey:@"entrance"];
                }
                [SNNewsLoginManager halfLoginData:@{@"loginFrom":@"100036",@"halfScreenTitle":@"一键登录即可分享至狐友",@"entrance":entrance} Successed:^(NSDictionary *info) {
                    [self shareIconSelected:iconTitle ShareData:shareData];
                } Failed:^(NSDictionary *errorDic) {
                    NSString* ss = [shareData stringValueForKey:@"screen_share" defaultValue:nil];
                    if (ss && [ss isEqualToString:@"1"]) {//如果是截屏分享
                        return;
                    }
                    
                    SNShareMenuViewController* vc = [[SNShareMenuViewController alloc] initWithData:shareData];
                    vc.delegate = self;
                    self.menuVc = vc;
                    [vc showActionMenu];
                }];
            }
        }
        return;
    }
    
    BOOL r = [self executeDelegate:dic];
    if (r == NO) {
        return;
    }
    
    if (dic) {
        //判断是否安装客户端
        NSString* n = [dic stringValueForKey:@"isInstalled" defaultValue:nil];
        if (n.integerValue == 0) {//未安装
            toastTitle = [dic stringValueForKey:@"toastTitle" defaultValue:nil];
            [[SNCenterToast shareInstance] showCenterToastWithTitle:toastTitle toUrl:nil mode:SNCenterToastModeWarning];
        }
        else{//已安装 继续分享
            NSString* className = [dic stringValueForKey:@"classname" defaultValue:nil];
            NSString* n = [dic stringValueForKey:@"option" defaultValue:nil];
            if (className && className.length>0) {
                Class class = NSClassFromString(className);
                NSObject* obj = [[class alloc] initWithOption:n.integerValue];
                
                if([obj isKindOfClass:[SNSharePlatformBase class]]){
                    sharePlatform = (SNSharePlatformBase*)obj;
                }
            }
            
            if (sharePlatform) {
                self.sharePlatForm = sharePlatform;
                self.sharePlatForm.shareData = [NSMutableDictionary dictionaryWithDictionary:shareData];
                
                if ([self.sharePlatForm.shareData objectForKey:@"entrance"]) {
                    [self.sharePlatForm.shareData removeObjectForKey:@"entrance"];
                }
                
                //孙潘说暂时先把狐友加上，别的不加
                if (self.sharePlatForm.optionPlatform == SNActionMenuOptionMySOHU) {
                    if (![[SNUtility getApplicationDelegate] isNetworkReachable]) {//如果没联网
                        [[SNCenterToast shareInstance] showCenterToastWithTitle:NSLocalizedString(@"network error", @"") toUrl:nil mode:SNCenterToastModeError];
                        return ;
                    }
                }

                //刘乐 需求 不再禁止分享gif图 有挫败感 wangshun
                //暂不支持gif图
                NSString* url = [self.sharePlatForm.shareData stringValueForKey:@"url" defaultValue:nil];
                NSString* imageUrl = [self.sharePlatForm.shareData stringValueForKey:@"imageUrl" defaultValue:nil];
                if ([url isEqualToString:imageUrl]) {
                    if ([url hasSuffix:@".gif"]||[url hasSuffix:@".GIF"]) {
//                        [[SNCenterToast shareInstance] showCenterToastWithTitle:@"暂不支持分享动图操作" toUrl:nil mode:SNCenterToastModeOnlyText];
//                        return;
                        [SNNewsShareGif analyseGifData:self.sharePlatForm Method:^{
                            
                        }];
                    }
                }
                
                //分享前从shareOn.go接口拿数据
                if(self.shareOn) {
                    self.shareOn = nil;
                }
                SNShareOn* shareOn = [[SNShareOn alloc] initWithPlatForm:self.sharePlatForm];
                self.shareOn = shareOn;
                __weak SNNewsShareManager* weakSelf = self;
                
                //shareOn.go
                [_shareOn shareOnRequestWithCompletion:^(NSDictionary *responseDic) {//
                    dispatch_async(dispatch_get_main_queue(), ^{
                       [weakSelf shareToPlatFormWithData:responseDic];//share to xxx
                    });
                }];
            }
        }
    }
}

//分享至微信，qq，微博...
- (void)shareToPlatFormWithData:(NSDictionary*)shareOnRspDic{
    //share
    SNDebugLog(@"sharePlatform");
    
    //webUrl加入from
    NSString* webUrl = [self.sharePlatForm.shareData objectForKey:@"webUrl"];
    if (webUrl && webUrl.length>0) {
        NSString* webUrl_sf_a = [SNNewsShareAnalysisTitle returnWebUrl:webUrl WithOption:self.sharePlatForm.optionPlatform];
        if (webUrl_sf_a && webUrl_sf_a.length>0) {//覆盖webUrl
            [self.sharePlatForm.shareData setObject:webUrl_sf_a forKey:@"webUrl"];
        }
    }
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(shareOnFinished:)]) {
        [self.delegate shareOnFinished:self.sharePlatForm];
    }
    
    [self.sharePlatForm getShareParams:shareOnRspDic];//处理一次数据
    
    [self.sharePlatForm log];//埋点
    
    __weak SNNewsShareManager* weakSelf = self;
    
    //分享
    [self.sharePlatForm shareTo:nil Upload:^(NSDictionary *dic) {
        
        //v4 upload 同步我的分享
        [weakSelf uploadRequest:nil];
    }];
}

//同步 分享结果
- (void)uploadRequest:(NSDictionary*)dic{
    if (self.upload) {
        self.upload = nil;
    }
    
    self.upload = [[SNShareUpload alloc] initWithPlatForm:self.sharePlatForm];
    
    __weak SNNewsShareManager* weakSelf = self;
    
    [self.upload shareUploadRequestWithCompletion:^(NSDictionary *responseDic) {
        
        //同步后埋点
        NSString* snsShareonInfo = weakSelf.sharePlatForm.shareData[kSNSShareonInfo];
        NSString* shareLogType   = weakSelf.sharePlatForm.shareData[SNNewsShare_LOG_type];
        NSString* shareToThirdTag = weakSelf.sharePlatForm.shareData[@"appid"];
        if (snsShareonInfo.length>0) {
            [SNUtility reportSNSShareLogWithType:shareToThirdTag shareonInfo:snsShareonInfo originType:shareLogType];//埋点
        }
    }];
}

//=================================================================================================================================================================================================//

/*
  share 入口
 */

+ (SNNewsShareManager*)loadShareData:(NSDictionary*)dic FromView:(UIView *)fromView Delegate:(id)obj{
    
    SNNewsShareManager* m = [[SNNewsShareManager alloc] init];
    if (obj) {
        m.delegate = obj;
    }
    
    SNShareMenuViewController* vc = [[SNShareMenuViewController alloc] initWithData:dic];
    vc.delegate = m;
    m.menuVc = vc;
    
    [vc showActionMenuFromView:fromView];

    return m;
}

+ (SNNewsShareManager*)loadShareData:(NSDictionary*)dic Delegate:(id)obj{
    SNNewsShareManager* m = [[SNNewsShareManager alloc] init];
    if (obj) {
        m.delegate = obj;
    }

    SNShareMenuViewController* vc = [[SNShareMenuViewController alloc] initWithData:dic];
    vc.delegate = m;
    m.menuVc = vc;
    
    [vc showActionMenu];
    
    return m;
}
//=================================================================================================================================================================================================//


- (BOOL)executeDelegate:(NSDictionary*)dic{
    NSNumber* num = [dic objectForKey:@"option"];
    NSInteger menuOption = num.integerValue;
    
    if ([_delegate respondsToSelector:@selector(actionmenuDidSelectItemTypeCallback:)]) {
        [_delegate actionmenuDidSelectItemTypeCallback:menuOption];
    }
    
    //退出全屏模式
    NSDictionary *userInfo = @{kActionMenuViewDidTapLikeBtn:@(NO)};
    [SNNotificationManager postNotificationName:kNotifyDidHandled object:userInfo];
    
    return YES;
}

@end
