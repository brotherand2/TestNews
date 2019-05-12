//
//  SNMySohuActionMenuContent.m
//  sohunews
//
//  Created by H on 15/4/23.
//  Copyright (c) 2015年 Sohu.com. All rights reserved.
//

#import "SNMySohuActionMenuContent.h"
#import "SNUserManager.h"
#import "SNSLib.h"

#import "SNAnalytics.h"

#import "SNShareConfigs.h"
#import "SNNewsReport.h"

@interface SNMySohuActionMenuContent()

@property (nonatomic, strong) NSMutableDictionary * SNSContent;

@end

@implementation SNMySohuActionMenuContent

- (void)share {

    [SNNotificationManager postNotificationName:kUserLoginSplashShouldDismissNotification object:nil];
    if (![SNUserManager isLogin]) {
        [SNGuideRegisterManager login:kLoginFromShareMySohu];
        [[SNActionSheetLoginManager sharedInstance] resetNewGuideDic];
        [SNNotificationManager postNotificationName:kLoginMsgFromShareToSNSNotification object:nil];
        [SNUtility setUserDefaultSourceType:kUserActionIdForArticleComment keyString:kLoginSourceTag];
    }
    else {
        BOOL isOpenMobileBind = [SNUtility isOpenMobileBindSwitch:kUserActionIdForArticleComment];
        SNUserinfoEx *userInfo = [SNUserinfoEx userinfoEx];
        if (!userInfo.isRealName && isOpenMobileBind) {
            NSDictionary* dic = [NSDictionary dictionaryWithObjectsAndKeys:@"手机绑定", @"headTitle", @"立即绑定", @"buttonTitle", nil];
            TTURLAction *_urlAction = [[[TTURLAction actionWithURLPath:@"tt://mobileNumBindLogin"] applyAnimated:YES] applyQuery:dic];
            [[TTNavigator navigator] openURLAction:_urlAction];
        }
        else {
            [self shareToMySNS];
        }
    }
}

- (void)interpretContext:(NSDictionary *)contentDic {
    
    self.SNSContent = [NSMutableDictionary dictionaryWithCapacity:15];
   
    //title
    [_SNSContent setObject:contentDic[@"title"]?:@"" forKey:@"title"];
    if ([_SNSContent[@"title"] rangeOfString:@"@新闻客户端"].location != NSNotFound) {
        [_SNSContent setObject:[[_SNSContent[@"title"] componentsSeparatedByString:@"@新闻客户端"] firstObject] forKey:@"title"];
    }else if ([_SNSContent[@"title"] rangeOfString:@"上搜狐新闻客户端"].location != NSNotFound && [contentDic[@"url"]rangeOfString:@"previewChannel://"].location != NSNotFound) {
        [_SNSContent setObject:[[_SNSContent[@"title"] componentsSeparatedByString:@"上搜狐新闻客户端"] firstObject] forKey:@"title"];
    }
    
    if (contentDic[@"contentType"] && [contentDic[@"contentType"] isEqualToString:@"video"]) {
//        [_SNSContent setObject:contentDic[@"content"] forKey:@"title"];
    }else if (contentDic[@"contentType"] && [contentDic[@"contentType"] isEqualToString:@"vote"]){
        NSString *title = contentDic[@"title"];
        title = [title stringByAppendingString:[NSString stringWithFormat:@"  %@",contentDic[@"content"]?:@""]];
        [_SNSContent setObject:title forKey:@"title"];
    }
    else if (contentDic[@"contentType"] && [contentDic[@"contentType"] isEqualToString:@"live"]){
        [_SNSContent setObject:contentDic[@"contentType"] forKey:@"contentType"];
    }
    
    //desc
    [_SNSContent setObject:contentDic[@"content"]?:@"" forKey:@"description"];
    if ([_SNSContent[@"description"] rangeOfString:@"@新闻客户端"].location != NSNotFound) {
        [_SNSContent setObject:[[_SNSContent[@"description"] componentsSeparatedByString:@"@新闻客户端"] firstObject] forKey:@"description"];
    }

    //image Path
    [_SNSContent setObject:contentDic[@"screenImagePath"]?:@"" forKey:@"screenImagePath"];
    [_SNSContent setObject:contentDic[@"imageUrl"]?:@"" forKey:@"sharePic"];
//    [_SNSContent setObject:contentDic[@"thumbImage"]?:@"" forKey:@"picLocalPath"];

//    [_SNSContent setObject:contentDic[@"imagePath"]?:@"" forKey:@"sharePicCache"];
    [_SNSContent setObject:contentDic[@"passport"]?:@"" forKey:@"passport"];
    [_SNSContent setObject:contentDic[@"subId"]?:@"" forKey:@"subId"];
    
    //评论id
    [_SNSContent setObject:contentDic[@"commentId"]?:@"" forKey:@"commentId"];

    //评论内容
    if ([contentDic[@"shareComment"]?:@"" length]>0 && [contentDic[@"commentId"] length] > 0) {
        [_SNSContent setObject:contentDic[@"shareComment"]?:@"" forKey:@"commentContent"];
    }else if ([contentDic[@"content"]?:@"" length]>0 && [contentDic[@"commentId"] length] > 0) {
        [_SNSContent setObject:contentDic[@"content"]?:@"" forKey:@"commentContent"];
    }else {
        [_SNSContent setObject:@"" forKey:@"commentContent"];
    }
   
    //引用id
    
    [_SNSContent setObject:contentDic[@"newsId"]?:@"" forKey:@"referId"];
   
    // url
    if ([contentDic[@"url"] length] > 0) {
        [_SNSContent setObject:contentDic[@"url"] forKey:@"url"];
        
        //lijian 2015.11.27 应李健要求把这个url改为link2字段的url，不用二代协议的
//        if ([contentDic[@"mediaUrl"] length] > 0 && nil != (contentDic[@"contentType"]) &&[(contentDic[@"contentType"]) isEqualToString:@"video"]) {
//            [_SNSContent setObject:contentDic[@"mediaUrl"] forKey:@"url"];
//        }
        if ([contentDic[@"webUrl"] length] > 0 && nil != (contentDic[@"contentType"]) &&[(contentDic[@"contentType"]) isEqualToString:@"video"]) {
            [_SNSContent setObject:contentDic[@"webUrl"] forKey:@"url"];
        }
    }
    else if ([contentDic[@"webUrl"] length] > 0) {
        [_SNSContent setObject:contentDic[@"webUrl"] forKey:@"url"];
    }else{
        [_SNSContent setObject:@"" forKey:@"url"];
    }
    
    //如果没取到subId 在这里截取
    NSString * subId = _SNSContent[@"subId"];
    NSString * url = _SNSContent[@"url"];
    if (subId.length == 0 && [url rangeOfString:@"subId"].location != NSNotFound) {
        subId = [[url componentsSeparatedByString:@"subId="] lastObject];
        subId = [[subId componentsSeparatedByString:@"&"] firstObject];
        [_SNSContent setObject:subId forKey:@"subId"];
    }
    
    //如果没取到referId 例如h5广告 在这里截取
    NSString * referId = _SNSContent[@"url"];
    if (([referId rangeOfString:@"AdID="].location != NSNotFound) && (!contentDic[@"newsId"])) {
        referId = [[referId componentsSeparatedByString:@"AdID="] lastObject];
        if ([[referId componentsSeparatedByString:@"&"] count] > 1) {
            referId = [[referId componentsSeparatedByString:@"&"] firstObject];
        }
        [_SNSContent setObject:referId forKey:@"referId"];
    }
    
    //如果仍然没有取到，设置默认为subId
    referId = _SNSContent[@"referId"];
    if (referId.length == 0) {
        referId = _SNSContent[@"subId"];
        [_SNSContent setObject:referId forKey:@"referId"];
    }
    
    //专题
    if (referId.length == 0 && contentDic[@"referString"]) {
        NSString * referString = contentDic[@"referString"];
        NSString * url = contentDic[@"webUrl"];
        if ([url containsString:@"?"]) {
            url = [url stringByAppendingFormat:@"&%@", referString];
        }
        else {
            url = [url stringByAppendingFormat:@"?%@", referString];
        }
        if (url.length > 0) {
            
            [_SNSContent setObject:url forKey:@"url"];
        }
        NSArray *array = [referString componentsSeparatedByString:@"="];
        if ([array count] > 0) {
            referString = [array lastObject];
            if (referString.length > 0) {
                [_SNSContent setObject:referString forKey:@"referId"];
            }
        }
    }
    
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        [SNNotificationManager addObserver:self selector:@selector(userDidLogin) name:@"kUserDidLoginNotification1" object:nil];
//        [SNNotificationManager addObserver:self selector:@selector(userDidLogin) name:kBackFromBindViewControllerNotification object:nil];
    }
    return self;
}

- (void)userDidLogin {
    
    [self shareToMySNS];

}

- (void)shareToMySNS {

    if (_SNSContent.count > 0) {
        NSString * sourceType = [NSString stringWithFormat:@"%d",self.sourceType];
        if ([[_SNSContent objectForKey:@"contentType"] isEqualToString:@"live"]) {
            sourceType = @"9";
        }
        [_SNSContent setObject:sourceType?:@"" forKey:@"sourceType"];
        
        if (self.sourceType == SNShareSourceTypeADSpread) {
            [_SNSContent setObject:@"" forKey:@"description"];//如果是非活动页的H5外链，清掉自带分享文案。 add by huang
        }
    //调SNS的分享接口
        [SNSLib shareToSns:_SNSContent callback:^(BOOL isStatusOk, NSDictionary *resultInfo) {
            if (isStatusOk) {
                NSMutableDictionary *dict = [NSMutableDictionary dictionary];
                [dict setValue:[NSNumber numberWithInteger:ShareTargetSohu] forKey:kShareTargetKey];
                [dict setValue:@"me" forKey:kShareTargetNameKey];
                [dict setValue:_SNSContent[@"referId"] forKey:kShareInfoKeyNewsId];
                [dict setValue:_SNSContent[@"description"] forKey:kShareContentKey];
                [dict setValue:_SNSContent[@"subId"] forKey:kShareInfoLogKeySubId];
                [SNNewsReport reportShareWithInfo:dict];
                
                if (self.isVideoShare || self.isQianfanShare) {
                    [[SNCenterToast shareInstance] showCenterToastWithTitle:NSLocalizedString(@"ShareSucceed", @"ShareSucceed") toUrl:nil mode:SNCenterToastModeSuccess];
                       [self performSelector:@selector(requestRedPackerAndCoupon:) withObject:[_SNSContent stringValueForKey:@"url" defaultValue:@""] afterDelay:1];
                    
                }else{
                    NSString *shareUrl = [_SNSContent stringValueForKey:@"url" defaultValue:@""];
                    [[SNCenterToast shareInstance] showCenterToastWithTitle:NSLocalizedString(@"ShareSucceed", @"ShareSucceed") toUrl:nil mode:SNCenterToastModeSuccess];
                    [self performSelector:@selector(requestRedPackerAndCoupon:) withObject:shareUrl afterDelay:1];
                }
            }else {
                [[SNCenterToast shareInstance] showCenterToastWithTitle:NSLocalizedString(@"ShareFailed", @"ShareFailed") toUrl:nil mode:SNCenterToastModeWarning];
       
            }
   
        }];
    }else {
        [[SNCenterToast shareInstance] showCenterToastWithTitle:NSLocalizedString(@"ShareFailed", @"ShareFailed") toUrl:nil mode:SNCenterToastModeWarning];
    }
}

- (void)dealloc {
    [SNNotificationManager removeObserver:self];
     //(_SNSContent);
    
}

- (void)requestRedPackerAndCoupon:(NSString *)shareUrl{
    [SNUtility requestRedPackerAndCoupon:shareUrl type:@"1"];
}

@end
