//
//  SNOAuthsActionMenuContent.m
//  sohunews
//
//  Created by Dan Cong on 12/10/13.
//  Copyright (c) 2013 Sohu.com. All rights reserved.
//

#import "SNOAuthsActionMenuContent.h"
#import "SNDBManager.h"

@implementation SNOAuthsActionMenuContent

- (void)interpretContext:(NSDictionary *)contentDic
{
    [super interpretContext:contentDic];
    
    self.shareLogContent = [contentDic objectForKey:kShareInfoKeyShareContent];
    
    self.dic = [NSMutableDictionary dictionaryWithDictionary:contentDic];
}

- (void)share
{
    [SNShareManager defaultManager].shareDelegate = self;
    
    if (self.shareSubType == ShareSubTypeQuoteCard ) {
        //为了重用ShareRead现成的字段，才能分享出来带引用模式的分享
        [self appendShareReadObjectByTimelineType:self.timelineContentType contentId:self.timelineContentId];
    } else {
        if (self.shareSubType == ShareSubTypeQuoteText) {
            [self useShareContentAsContent];
        }
    }
    self.dic[kShareInfoKeyShareType] = @(self.shareSubType);
    self.dic[@"referId"] = self.timelineContentId;
    
    //wangshun 换sso 分享
//    if ([SinaWeiBoObj isWeiboAppInstalled]) {
//        
//        [SinaWeiBoObj getObj].shareInfoObj = [SNTimelineOriginContentObject timelineOriginContentObjFromDic:self.dic];
//        [SinaWeiBoObj getObj].sourceType = self.sourceType;
//        [SinaWeiBoObj getObj].isVideoShare = self.isVideoShare;
//        [SinaWeiBoObj getObj].isQianfanShare = self.isQianfanShare;
//        
//        [SinaWeiBoObj getObj].more140size = ^(void){
//            [SNShareManager defaultManager].isVideoShare = self.isVideoShare;
//            [SNShareManager defaultManager].isQianfanShare = self.isQianfanShare;
//            [SNShareManager defaultManager].sourceType = self.sourceType;
//            [[SNShareManager defaultManager] startShareControllerWithShareInfo:self.dic];
//        };
//        
//        [[SinaWeiBoObj getObj] shareToWeiBo:self.dic];
//    }
//    else{
//        
//        [[SNCenterToast shareInstance] showCenterToastWithTitle:@"您尚未安装微博哦~试试其他分享方式吧！" toUrl:nil mode:SNCenterToastModeWarning];
//    }
    
    self.shareTarget = ShareTargetSNS;
    [self log];
}

- (void)appendShareReadObjectByTimelineType:(SNTimelineContentType)timelineType contentId:(NSString *)contentId
{
    if (self.contentType == ShareTypeLive) {
        self.dic[kShareInfoKeyScreenImagePath] = [[NSBundle mainBundle] pathForResource:@"iOS_114_live" ofType:@"png"];
    }
    NSString *imagePath = [self.dic objectForKey:kShareInfoKeyImagePath];
    if (!imagePath) {
        imagePath = [self.dic objectForKey:kShareInfoKeyScreenImagePath];
    }
    
    SNTimelineOriginContentObject *obj = [self.dic objectForKey:kShareInfoKeyShareRead];
    
    if (!obj) {
        obj = [[SNDBManager currentDataBase] getTimelineOriginObjByType:timelineType contentId:contentId];
    }
    
    //如果是本地图片把传进来的本地全路径作为SNTimelineOriginContentObject中的图片路径
    if (![SNAPI isWebURL:obj.picUrl]) {
        obj.picUrl = imagePath.length > 0 ? imagePath : obj.picUrl;
    }
    obj.picUrl = [self.dic objectForKey:kShareInfoKeyImageUrl] ? : obj.picUrl;
    if (obj) {
        [self.dic setObject:obj forKey:kShareInfoKeyInfoDic];
    }
    
}

- (void)useShareContentAsContent
{
    if (self.shareLogContent) {
        self.content = self.shareLogContent;
        [self.dic setObject:self.content forKey:kShareInfoKeyContent];
    }
}

//@Override
- (void)useShareCommentAsContent {
    
    NSString *comment = [self.dic objectForKey:kShareInfoKeyShareComment];
    
    if (!comment) {
        return;
    }
    
    NSString *content = [self.dic objectForKey:kShareInfoKeyContent];
    
    // "xxxx" [title] http://xxxx @搜狐新闻客户端
    content = [self getLinkFromString:content]; // get link
    if ([content length] == 0) {
        content = @"";
    }
    content = [content stringByAppendingString:@" @搜狐新闻客户端"]; // add @string
    
    NSString *shareTitle = [self.dic objectForKey:kShareInfoKeyTitle];
    content = [NSString stringWithFormat:@" [%@] %@", shareTitle, content];
    NSInteger tailLen = [content length];
    NSInteger headLen = [comment length];
    NSInteger volumLen = 140 - tailLen - 2;
    if (headLen > volumLen) {
        comment = [comment substringToIndex:volumLen - 3];
        comment = [comment stringByAppendingString:@"..."];
    }
    
    if(comment.length>0)
        content = [NSString stringWithFormat:@"\"%@\"%@", comment, content];
    
    self.content = content;
    if (self.content) {
        [self.dic setObject:self.content forKey:kShareInfoKeyContent];
    }
}

- (void)dealloc
{
     //(_dic);
    
     //(_targetName);
     //(_userName);
     //(_shareUGCComment);
    
    [SNShareManager defaultManager].shareDelegate = nil; // 防止低内存被释放，分享成功之后delegate 野指针crash
    
}


#pragma mark - SNShareMangerDelegate
- (void)shareManager:(SNShareManager *)manager wantToShowAuthView:(UIViewController *)authNaviController
{
    
}

- (void)shareManager:(SNShareManager *)manager willShareComment:(NSString *)comment {
    self.shareUGCComment = comment;
}

- (void)shareManagerShareSuccess:(SNShareManager *)manager {

    NSArray *shareList = [[SNShareManager defaultManager] itemsCouldShare];
    NSMutableString *mutStrTarget = [NSMutableString string];
    NSMutableString *mutStrUserName = [NSMutableString string];
    for (ShareListItem *item in shareList) {
        NSString *encodeUserName = @"";
        if ([item.userName length] > 0) {
            encodeUserName = [item.userName stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        }
        if ([item.appName rangeOfString:@"新浪"].location != NSNotFound) {
            [mutStrTarget appendString:@"/sinaweibo"];
            [mutStrUserName appendFormat:@"sinaweibo=%@", encodeUserName];
        }
        else if ([item.appName rangeOfString:@"腾讯"].location != NSNotFound) {
            [mutStrTarget appendString:@"/qqweibo"];
            [mutStrUserName appendFormat:@"qqweibo=%@", encodeUserName];
        }
        else if ([item.appName rangeOfString:@"搜狐"].location != NSNotFound) {
            [mutStrTarget appendString:@"/sohuweibo"];
            [mutStrUserName appendFormat:@"sohuweibo=%@", encodeUserName];
        }
        else if ([item.appName rangeOfString:@"开心"].location != NSNotFound) {
            [mutStrTarget appendString:@"/kaixin"];
            [mutStrUserName appendFormat:@"kaixin=%@", encodeUserName];
        }
        else if ([item.appName rangeOfString:@"人人"].location != NSNotFound) {
            [mutStrTarget appendString:@"/renren"];
            [mutStrUserName appendFormat:@"renren=%@", encodeUserName];
        }
        else if ([item.appName rangeOfString:@"QQ空间"].location != NSNotFound) {
            [mutStrTarget appendString:@"/qq"];
            [mutStrUserName appendFormat:@"qq=%@", encodeUserName];
        }
    }
    if ([mutStrTarget length] > 0) {
        self.targetName = [mutStrTarget stringByReplacingCharactersInRange:NSMakeRange(0, 1) withString:@""];
    }
    if ([mutStrUserName length] > 0) {
        self.userName = mutStrUserName;
    }
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    [dict setValue:[NSNumber numberWithInteger:ShareTargetSNS] forKey:kShareTargetKey];
    [dict setValue:self.userName forKey:kShareInfoKeyUserName];
    [dict setValue:self.targetName forKey:kShareTargetNameKey];
    [dict setValue:self.shareLogType forKey:kShareInfoKeyShareType];
    [dict setValue:self.shareLogId forKey:kShareInfoKeyNewsId];
    [dict setValue:self.shareLogContent forKey:kShareContentKey];
    [dict setValue:self.shareUGCComment forKey:kShareInfoKeyShareComment];
    [dict setValue:self.shareLogSubId forKey:kShareInfoLogKeySubId];
    [SNNewsReport reportShareWithInfo:dict];
    
    if ([self.delegate respondsToSelector:@selector(actionMenuControllerShareSuccess:)]) {
        [self.delegate performSelector:@selector(actionMenuControllerShareSuccess:) withObject:NSLocalizedString(@"ShareSucceed", @"ShareSucceed")];
        [SNUtility requestRedPackerAndCoupon:[self.dic objectForKey:kShareInfoKeyShareLink] type:@"1"];
    }
}

- (void)shareManagerShareFailed:(SNShareManager *)manager {
    if ([self.delegate respondsToSelector:@selector(actionMenuControllerShareFailed:)]) {
        [self.delegate performSelector:@selector(actionMenuControllerShareFailed:) withObject:NSLocalizedString(@"ShareFailed", @"Share Failed")];
    }
}

@end
