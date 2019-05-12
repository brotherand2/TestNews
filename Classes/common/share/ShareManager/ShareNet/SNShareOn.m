//
//  SNShareOn.m
//  sohunews
//
//  Created by wang shun on 2017/2/4.
//  Copyright © 2017年 Sohu.com. All rights reserved.
//

#import "SNShareOn.h"

@implementation SNShareOn

-(instancetype)initWithPlatForm:(SNSharePlatformBase *)p{
    if (self = [super init]) {
        self.platForm = p;
        
        [self configData:self.platForm.shareData];
        
        self.shareOnService = [[SNNewsShareOnService alloc] initWithDelegate:self];
    }
    return self;
}

- (void)configData:(NSDictionary*)shareData{
    
//这个值好像没用了
//    SNTimelineOriginContentObject *shareObj = [shareData objectForKey:kShareInfoKeyShareRead];
//    if (shareObj.isFromChannelPreview) {
//        if (_platForm.optionPlatform == SNActionMenuOptionWXSession || _platForm.optionPlatform == SNActionMenuOptionQQ || _platForm.optionPlatform == SNActionMenuOptionQZone) {//微信好友,QQ,QQ好友
//            [shareData setValue:[NSString stringWithFormat:@"%@", shareObj.description] forKey:@"content"];
//        }
//        else if (_platForm.optionPlatform == SNActionMenuOptionWXTimeline) {//微信朋友圈
//            [shareData setValue:[NSString stringWithFormat:@"%@%@", shareObj.title, shareObj.description] forKey:@"content"];
//        }
//    }
}

- (void)shareOnRequestWithCompletion:(ShareOnCompletionBlock)method{
   
    //shareOn.go
    NSString* isVideoShare = [self.platForm.shareData objectForKey:@"isVideoShare"];
    NSString* isQianfanShare = [self.platForm.shareData objectForKey:@"isQianfanShare"];
    
    if (isVideoShare && [isVideoShare isEqualToString:@"1"]) {//视频
        
        [self.shareOnService getShareType:[self shareTypeWith:@"videotab"] onType:[self onTypeWith:_platForm.optionPlatform] Params:self.platForm.shareData];
        
    }else if (isQianfanShare && [isQianfanShare isEqualToString:@"1"]){//qianfan

        [self.shareOnService getShareType:[self shareTypeWith:@"qianfan"] onType:[self onTypeWith:_platForm.optionPlatform] Params:self.platForm.shareData];
    }else{//其他
        [self.shareOnService getShareType:[self shareTypeWith:self.platForm.shareData[@"contentType"]?:@""] onType:[self onTypeWith:_platForm.optionPlatform] Params:self.platForm.shareData];
    }
    
    if (self.completionMethod) {
        self.completionMethod = nil;
    }
    self.completionMethod = method;
}

- (void)requestFromShareOnServerFinished:(NSDictionary *)responseData{
    [self updateShareOnResponseData:responseData];//shareOn.go 后更新数据
    
    if (self.completionMethod) {
        self.completionMethod(responseData);
    }
}

- (void)updateShareOnResponseData:(NSDictionary *)dictionary{
    
    if (dictionary && [dictionary isKindOfClass:[NSNull class]]) {
        return;
    }
    
    if (dictionary[@"content"] && [dictionary[@"content"] isKindOfClass:[NSString class]]) {
        NSString *content = dictionary[@"content"];
        if (content.length > 0) {
            self.platForm.shareData[@"content"] = content;
        }
    }
    
    if (dictionary[@"title"] && [dictionary[@"title"] isKindOfClass:[NSString class]]) {
        NSString *title = dictionary[@"title"];
        if (title.length > 0) {
            self.platForm.shareData[@"title"] = title;
        }
    }
    
    if (dictionary[@"pics"] && [dictionary[@"pics"] isKindOfClass:[NSArray class]]) {
        if ([dictionary[@"pics"] count] > 0) {
            NSString *imageUrl = self.platForm.shareData[@"imageUrl"];
            if (!imageUrl || imageUrl.length == 0 || [self.platForm.shareData[@"contentType"] isEqualToString:@"video"]) {
                self.platForm.shareData[@"imageUrl"] = [dictionary[@"pics"] firstObject];
            }
        }
    }
    
    if (dictionary[@"link"] && [dictionary[@"link"] isKindOfClass:[NSString class]]) {
        NSString * link = dictionary[@"link"];
        if (link &&![link isKindOfClass:[NSNull class]]&&link.length > 0) {
            
            NSString* webUrl = [self.platForm.shareData objectForKey:@"webUrl"];
            NSString* url    = [self.platForm.shareData objectForKey:@"url"];
            if ([url isEqualToString:webUrl]) {
                if ([SNUtility isProtocolV2:link]) {
                    [self.platForm.shareData setObject:link?:@"" forKey:@"url"];
                }
            }

            self.platForm.shareData[@"webUrl"] = link;
            
            NSString* h5webtype = [self.platForm.shareData objectForKey:kH5WebType];
            if ([h5webtype isEqualToString:@"1"]) {
                self.platForm.shareData[@"webUrl"] = [self.platForm.shareData objectForKey:@"h5weblink"];
            }
        }
    }
    
    //link2 用于截屏分享 图片上 二维码对应url  2017.8.25 wagnshun
    if (dictionary[@"link2"] && [dictionary[@"link2"] isKindOfClass:[NSString class]]) {
        NSString* link2 = dictionary[@"link2"];
        if (link2.length>0) {
            [self.platForm.shareData setObject:link2?:@"" forKey:@"link2"];
        }
    }
}


- (NSString*)getAppId{
    NSString* appId = @"";
    if (_platForm.optionPlatform == SNActionMenuOptionWXTimeline) {//微信朋友圈
        appId = SNShareToThirdPartTypeWeiXinTimeline;
    }
    else if (_platForm.optionPlatform == SNActionMenuOptionWXSession) {//微信好友
        appId = SNShareToThirdPartTypeWeiXinFriend;
    }
    else if (_platForm.optionPlatform == SNActionMenuOptionQQ) {//QQ好友
        appId = SNShareToThirdPartTypeQQ;
    }
    else if (_platForm.optionPlatform == SNActionMenuOptionQZone) {//QQ空间
        appId = SNShareToThirdPartTypeQZone;
    }
    else if (_platForm.optionPlatform == SNActionMenuOptionMySOHU) {//搜狐我的
        appId = SNShareToThirdPartTypeMySohu;
    }
    else if (_platForm.optionPlatform == SNActionMenuOptionAliPaySession) {//支付宝
        appId = SNShareToThirdPartTypeAlipay;
    }
    else if (_platForm.optionPlatform == SNActionMenuOptionAliPayLifeCircle) {//生活圈
        appId = SNShareToThirdPartTypeLifeCircle;
    }
    return appId;
}

- (ShareType)shareTypeWith:(NSString *)typeString{
    if ([typeString isEqualToString:@"news"]) {
        return ShareTypeNews;
    }
    else if ([typeString isEqualToString:@"vote"]) {
        return ShareTypeVote;
    }
    else if ([typeString isEqualToString:@"video"]) {
        return ShareTypeVideo;
    }
    else if ([typeString isEqualToString:@"videotab"]) {
        return ShareTypeVideoTab;
    }
    else if ([typeString isEqualToString:@"qianfan"]) {
        return ShareTypeQianfan;
    }
    else if ([typeString isEqualToString:@"live"]) {
        return ShareTypeLive;
    }
    else if ([typeString isEqualToString:@"group"]) {
        return ShareTypeGroup;
    }
    else if ([typeString isEqualToString:@"channel"]) {
        return ShareTypeChannel;
    }
    else if ([typeString isEqualToString:@"activityPage"]) {
        return ShareTypeActivityPage;
    }else if ([typeString isEqualToString:@"web"]) {
        return ShareTypeWeb;
    }else if ([typeString isEqualToString:@"special"]) {
        return ShareTypeSpecial;
    }
    else if ([typeString isEqualToString:@"pack"]) {
        return ShareTypeRedPacket;
    }
    else if ([typeString isEqualToString:@"redPackPage"]) {
        return ShareTypePicTextRedPacket;
    }
    else if ([typeString isEqualToString:@"joke"]) {
        return ShareTypeJoke;
    }
    else{
        return ShareTypeUnknown;
    }
}

- (ShareOnType)onTypeWith:(SNActionMenuOption)onType{
    switch (onType) {
        case SNActionMenuOptionUnknown:
            return OnTypeUnknown;
            break;
        case SNActionMenuOptionOAuths:
            return OnTypeWeibo;
            break;
        case SNActionMenuOptionWXSession:
            return OnTypeWXSession;
            break;
        case SNActionMenuOptionWXTimeline:
            return OnTypeWXTimeline;
            break;
        case SNActionMenuOptionMail:
            return OnTypeDefault;
            break;
        case SNActionMenuOptionSMS:
            return OnTypeDefault;
            break;
        case SNActionMenuOptionQQ:
            return OnTypeQQChat;
            break;
        case SNActionMenuOptionQZone:
            return OnTypeQQZone;
            break;
        case SNActionMenuOptionEvernote:
            return OnTypeDefault;
            break;
        case SNActionMenuOptionWebLink:
            return OnTypeWeibo;
            break;
        case SNActionMenuOptionDownload:
            return OnTypeDefault;
            break;
        case SNActionMenuOptionMySOHU:
            return OnTypeDefault;
            break;
        case SNActionMenuOptionAliPayLifeCircle:
            return OnTypeTaoBaoMoments;
        case SNActionMenuOptionAliPaySession:
            return OnTypeTaoBao;
        default:
            return OnTypeAll;
            break;
    }
}




@end
