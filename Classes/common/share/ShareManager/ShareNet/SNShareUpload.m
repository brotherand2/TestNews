//
//  SNShareUpload.m
//  sohunews
//
//  Created by wang shun on 2017/2/4.
//  Copyright © 2017年 Sohu.com. All rights reserved.
//

#import "SNShareUpload.h"
#import "SNShareConfigs.h"
#import "SNDBManager.h"

@implementation SNShareUpload

- (instancetype)initWithPlatForm:(SNSharePlatformBase *)p{
    if (self = [super init]) {
        self.platForm = p;
        
        [self configData:self.platForm.shareData];
    }
    return self;
}

- (void)shareUploadRequestWithCompletion:(ShareUploadCompletionBlock)method{
    //TODO:根据sourceType区分是否调用服务器接口进阅读圈
    //更好做法应通过shareContentType让服务端做进阅读圈判断。
    NSDictionary* dic       = self.platForm.shareData;
    NSString* sourceTypeStr = [dic objectForKey:@"sourceType"];
    NSInteger sourceType    = sourceTypeStr.integerValue;
    
    if (method) {
        self.completionMethod = method;
    }
    
    if (sourceType !=0) {
        SNShareItem *shareItem = [[SNShareItem alloc] init];
        shareItem.appId = [self getAppid:self.platForm.optionPlatform];
        
        shareItem.shareId = [dic objectForKey:@"newsId"];
        
        if (shareItem.shareId.length == 0 && dic[@"referString"]) {
            NSString * referStr = dic[@"referString"];
            shareItem.shareId = [[referStr componentsSeparatedByString:@"="] lastObject];
        }
        
        NSString* shareComment = [dic objectForKey:@"shareComment"];
        if (shareComment && shareComment.length>0) {
            if ([shareComment isEqualToString:@"(null)"]) {
                shareComment = @"";
            }
            shareItem.ugc = shareComment;
        }
        
        shareItem.shareContentType = SNShareContentTypeJson;
        shareItem.shareContent     = [dic objectForKey:@"content"];
        shareItem.shareTitle       = [dic objectForKey:@"title"];
        shareItem.shareImageUrl    = [dic objectForKey:@"imageUrl"];
        shareItem.sourceType       = sourceType;
        shareItem.shareLink        = [dic objectForKey:@"url"];
        
        shareItem.isNotRealShare   = YES;
        
        [[SNShareManager defaultManager] postShareItemToServer:shareItem];
    }
    else {
        [[SNCenterToast shareInstance] showCenterToastWithTitle:NSLocalizedString(@"ShareSucceed", @"Share Succeed") toUrl:nil mode:SNCenterToastModeSuccess];
    }
}

- (void)configData:(NSDictionary*)shareData{
    
}

- (NSString*)getAppid:(NSInteger)type{
    NSString* appid = @"";
    if (type == SNActionMenuOptionWXTimeline) {//微信朋友圈
        appid = SNShareToThirdPartTypeWeiXinTimeline;
    }
    else if (type == SNActionMenuOptionWXSession) {//微信好友
        appid = SNShareToThirdPartTypeWeiXinFriend;
    }
    else if (type == SNActionMenuOptionQQ) {//QQ好友
        appid = SNShareToThirdPartTypeQQ;
    }
    else if (type == SNActionMenuOptionQZone) {//QQ空间
        appid = SNShareToThirdPartTypeWeiXinTimeline;
    }
    else if (type == SNActionMenuOptionMySOHU) {//搜狐我的
        appid = SNShareToThirdPartTypeMySohu;
    }
    else if (type == SNActionMenuOptionAliPaySession) {//支付宝
        appid = SNShareToThirdPartTypeAlipay;
    }
    else if (type == SNActionMenuOptionAliPayLifeCircle) {//生活圈
        appid = SNShareToThirdPartTypeLifeCircle;
    }
    else if (type == SNActionMenuOptionOAuths) {
        appid = SNShareToThirdPartTypeSina;
    }
    
    [self.platForm.shareData setObject:appid forKey:@"appid"];
    
    return appid;
}


@end
