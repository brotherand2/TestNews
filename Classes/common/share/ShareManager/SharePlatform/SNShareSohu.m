//
//  SNShareSohu.m
//  sohunews
//
//  Created by wang shun on 2017/2/6.
//  Copyright © 2017年 Sohu.com. All rights reserved.
//

#import "SNShareSohu.h"


#import "SNUserManager.h"
#import "SNSLib.h"

#import "SNAnalytics.h"

#import "SNShareConfigs.h"
#import "SNNewsReport.h"

@interface SNShareSohu ()

@property (nonatomic, strong) NSMutableDictionary * SNSContent;

@end

@implementation SNShareSohu

-(instancetype)initWithOption:(NSInteger)option{
    if (self = [super initWithOption:option]) {
        [SNNotificationManager addObserver:self selector:@selector(userDidLogin) name:@"kUserDidLoginNotification1" object:nil];
        self.shareTarget = ShareTargetSohu;
    }
    return self;
}

- (NSDictionary *)getShareParams:(NSDictionary *)dic{
    self.SNSContent = [NSMutableDictionary dictionaryWithCapacity:15];
    
    //title
    NSString *title = self.shareData[@"title"];
    if ([self.shareData[@"contentType"] isEqualToString:@"qianfan"]) {
        title = self.shareData[@"content"];
    }

    [_SNSContent setObject:title ? : @"" forKey:@"title"];
    if ([_SNSContent[@"title"] rangeOfString:@"@新闻客户端"].location != NSNotFound) {
        [_SNSContent setObject:[[_SNSContent[@"title"] componentsSeparatedByString:@"@新闻客户端"] firstObject] forKey:@"title"];
    }else if ([_SNSContent[@"title"] rangeOfString:@"上搜狐新闻客户端"].location != NSNotFound && [self.shareData[@"url"]rangeOfString:@"previewChannel://"].location != NSNotFound) {
        [_SNSContent setObject:[[_SNSContent[@"title"] componentsSeparatedByString:@"上搜狐新闻客户端"] firstObject] forKey:@"title"];
    }
    
    if (self.shareData[@"contentType"] && [self.shareData[@"contentType"] isEqualToString:@"video"]) {
        //        [_SNSContent setObject:self.shareData[@"content"] forKey:@"title"];
    }else if (self.shareData[@"contentType"] && [self.shareData[@"contentType"] isEqualToString:@"vote"]){
        NSString *title = self.shareData[@"title"];
        title = [title stringByAppendingString:[NSString stringWithFormat:@"  %@",self.shareData[@"content"]?:@""]];
        [_SNSContent setObject:title forKey:@"title"];
    }
    else if (self.shareData[@"contentType"] && [self.shareData[@"contentType"] isEqualToString:@"live"]){
        [_SNSContent setObject:self.shareData[@"contentType"] forKey:@"contentType"];
    }
    
    //desc
    NSString *description = self.shareData[@"content"];
    if ([self.shareData[@"contentType"] isEqualToString:@"qianfan"]) {
        description = self.shareData[@"title"];
    }
    [_SNSContent setObject:description ?:@"" forKey:@"description"];
    if ([_SNSContent[@"description"] rangeOfString:@"@新闻客户端"].location != NSNotFound) {
        [_SNSContent setObject:[[_SNSContent[@"description"] componentsSeparatedByString:@"@新闻客户端"] firstObject] forKey:@"description"];
    }
    
    //image Path
    [_SNSContent setObject:self.shareData[@"screenImagePath"]?:@"" forKey:@"screenImagePath"];
    NSString *imageUrl = self.shareData[@"imageUrl"];
    if (imageUrl.length == 0) {
        //参照android传默认url，sns服务端不支持上传比特流
        imageUrl = @"http://cache.k.sohu.com/img8/wb/logo/share/share_normal.png";
    }
    [_SNSContent setObject:imageUrl forKey:@"sharePic"];
    [_SNSContent setObject:imageUrl forKey:@"imageUrl"];
    //    [_SNSContent setObject:self.shareData[@"thumbImage"]?:@"" forKey:@"picLocalPath"];
    
    //    [_SNSContent setObject:self.shareData[@"imagePath"]?:@"" forKey:@"sharePicCache"];
    [_SNSContent setObject:self.shareData[@"passport"]?:@"" forKey:@"passport"];
    [_SNSContent setObject:self.shareData[@"subId"]?:@"" forKey:@"subId"];
    
    //评论id
    [_SNSContent setObject:self.shareData[@"commentId"]?:@"" forKey:@"commentId"];
    
    //评论内容
    if ([self.shareData[@"shareComment"]?:@"" length]>0 && [self.shareData[@"commentId"] length] > 0) {
        [_SNSContent setObject:self.shareData[@"shareComment"]?:@"" forKey:@"commentContent"];
    }else if ([self.shareData[@"content"]?:@"" length]>0 && [self.shareData[@"commentId"] length] > 0) {
        [_SNSContent setObject:self.shareData[@"content"]?:@"" forKey:@"commentContent"];
    }else {
        [_SNSContent setObject:@"" forKey:@"commentContent"];
    }
    
    //引用id
    
    [_SNSContent setObject:self.shareData[@"newsId"]?:@"" forKey:@"referId"];
    
    // url
    if ([self.shareData[@"url"] length] > 0) {
        [_SNSContent setObject:self.shareData[@"url"] forKey:@"url"];
    }
    else if ([self.shareData[@"webUrl"] length] > 0) {
        [_SNSContent setObject:self.shareData[@"webUrl"] forKey:@"url"];
    }
    else {
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
    if (([referId rangeOfString:@"AdID="].location != NSNotFound) && (!self.shareData[@"newsId"])) {
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
    if (referId.length == 0 && self.shareData[@"referString"]) {
        NSString * referString = self.shareData[@"referString"];
        NSString * url = self.shareData[@"webUrl"];
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

    NSString* imagePath = [self.shareData objectForKey:@"imagePath"];
    if (imagePath) {
        NSData* data = [NSData dataWithContentsOfFile:imagePath];
        if (data) {
           [_SNSContent setObject:data forKey:@"imageData"];
            
            NSString* str = [self.shareData objectForKey:@"type"];
            if (str) {
                [_SNSContent setObject:str?:@"" forKey:@"type"];
            }
            
            //抹掉 支持分享图片
            [_SNSContent setObject:@"" forKey:@"sharePic"];
            [_SNSContent setObject:@"" forKey:@"title"];
        }
    }
    
    NSString* t = [_SNSContent objectForKey:@"title"];
    if (!t || [t isEqualToString:@""] || t.length == 0) {
        NSString* u = [_SNSContent objectForKey:@"url"];
        if (!u || [u isEqualToString:@""] || u.length == 0) {
            NSString* wu = [_SNSContent objectForKey:@"webUrl"];
            if (!wu || [wu isEqualToString:@""] || wu.length == 0) {
                if (imageUrl.length>0) {
                    //wangshun 2017.10.10
                    [_SNSContent setObject:@"3" forKey:@"type"];//图片type = 3 @jiangwenjuan
                }
            }
        }
    }
    
    return self.shareData;
}

- (void)shareTo:(NSDictionary *)dic Upload:(UploadBlock)method{
    
    if (method) {
        self.uploadMethod = method;
    }
    
    [SNNotificationManager postNotificationName:kUserLoginSplashShouldDismissNotification object:nil];
    if (![SNUserManager isLogin]) {
        [SNGuideRegisterManager login:kLoginFromShareMySohu];
        [[SNActionSheetLoginManager sharedInstance] resetNewGuideDic];
        [SNNotificationManager postNotificationName:kLoginMsgFromShareToSNSNotification object:nil];
        [SNUtility setUserDefaultSourceType:kUserActionIdForArticleComment keyString:kLoginSourceTag];
    }
    else {
        [self shareToMySNS];
    }
}

- (void)shareToMySNS {
    
    NSString* sourceType = [self.shareData objectForKey:@"sourceType"];
    NSString* isVideoShare = [self.shareData objectForKey:@"isVideoShare"];
    NSString* isQianfanShare = [self.shareData objectForKey:@"isQianfanShare"];
    
    if (_SNSContent.count > 0) {
        if ([[_SNSContent objectForKey:@"contentType"] isEqualToString:@"live"]) {
            sourceType = @"9";
        }
        [_SNSContent setObject:sourceType?:@"" forKey:@"sourceType"];
        
        if (sourceType.integerValue == SNShareSourceTypeADSpread) {
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
                
                if (self.uploadMethod) {
                    self.uploadMethod(nil);
                }
                
                if ([isVideoShare isEqualToString:@"1"] || [isQianfanShare isEqualToString:@"1"]) {
                    [[SNCenterToast shareInstance] showCenterToastWithTitle:NSLocalizedString(@"ShareSucceed", @"ShareSucceed") toUrl:nil mode:SNCenterToastModeSuccess];
                    [self performSelector:@selector(requestRedPackerAndCoupon:) withObject:[_SNSContent stringValueForKey:@"url" defaultValue:@""] afterDelay:1];
                    
                }else{
                    NSString *shareUrl = [_SNSContent stringValueForKey:@"url" defaultValue:@""];
                    [[SNCenterToast shareInstance] showCenterToastWithTitle:NSLocalizedString(@"ShareSucceed", @"ShareSucceed") toUrl:nil mode:SNCenterToastModeSuccess];
                    [self performSelector:@selector(requestRedPackerAndCoupon:) withObject:shareUrl afterDelay:1];
                }
            }
            else{
                [[SNCenterToast shareInstance] showCenterToastWithTitle:NSLocalizedString(@"ShareFailed", @"ShareFailed") toUrl:nil mode:SNCenterToastModeWarning];
            }
        }];

    }else {
        [[SNCenterToast shareInstance] showCenterToastWithTitle:NSLocalizedString(@"ShareFailed", @"ShareFailed") toUrl:nil mode:SNCenterToastModeWarning];
    }
}

- (void)userDidLogin {
    [self shareToMySNS];
}

- (void)requestRedPackerAndCoupon:(NSString *)shareUrl{
    [SNUtility requestRedPackerAndCoupon:shareUrl type:@"1"];
}

- (void)dealloc {
    [SNNotificationManager removeObserver:self];
    //(_SNSContent);
    
}

@end
