//
//  SNAPActionMenuContent.m
//  sohunews
//
//  Created by cuiliangliang on 16/3/10.
//  Copyright © 2016年 Sohu.com. All rights reserved.
//

#import "SNAPActionMenuContent.h"
#import "SNShareConfigs.h"
#import "SNDBManager.h"
#import "SNStatusBarMessageCenter.h"
#import "SNAPOpenApiHelper.h"
#import "APOpenAPIObject.h"
#import "SNCacheManager.h"

@implementation SNAPActionMenuContent
- (void)interpretContext:(NSDictionary *)contentDic {
    [super interpretContext:contentDic];
    
    NSString *imageUrl = [contentDic objectForKey:kShareInfoKeyImageUrl];
    //正文需要的
    NSString *thumbImage = [contentDic objectForKey:kShareInfoKeyThumbImage];
    NSData *imageData = nil;
    NSString *imagePath = [contentDic objectForKey:kShareInfoKeyImagePath
                                        defalutObj:nil];
    if (!imagePath) {
        imagePath = [contentDic objectForKey:kShareInfoKeyScreenImagePath
                                  defalutObj:nil];
    }
    
    UIImage *image = nil;
    
    if (imageUrl) {
        self.imageUrl = imageUrl;
        image = [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:imageUrl]]];
        if (!image) {
            //双保险
            image = [[SDImageCache sharedImageCache] imageFromDiskCacheForKey:imageUrl];
        }
    }
    if (image) {
        imageData = UIImageJPEGRepresentation(image, 0.5);
    }
    //评论分享的逻辑存在传过来的参数是本地图片而非URL的可能性
    if (image == nil) {
        image = [UIImage imageWithContentsOfFile:imagePath];
        if (image) {
            imageData = UIImageJPEGRepresentation(image, 0.5);
        }
    }
    
    if ([thumbImage length] > 0 && !imageData) {
        image = [[TTURLCache sharedCache] imageForURL:thumbImage fromDisk:YES];
        if (image) {
            imageData = UIImageJPEGRepresentation(image, 0.5);
        }
    }
    if (!imageData) {
        imageData = UIImagePNGRepresentation([UIImage imageNamed:@"iOS_114_normal.png"]);
    }
    
    NSString *strContent = [self getShareContent:self.content];
    if (strContent.length <= 0) {
        self.content = @"";
    } else {
        self.content = strContent;
    }
    
    if (self.title.length <= 0) {
        self.title = NSLocalizedString(@"News to share", @"");
    }
    
    NSString *webUrl = [contentDic objectForKey:kShareInfoKeyWebUrl];
    if (webUrl.length > 0) {
        self.webUrl = webUrl;
    } else {
        self.webUrl = [self getLinkFromString:strContent];
    }
    
    self.mediaUrl = [contentDic objectForKey:kShareInfoKeyMediaUrl];
    if ([[contentDic objectForKey:@"contentType"] isEqualToString:@"qianfan"]) {
        self.mediaUrl = [contentDic objectForKey:@"webUrl"];
    }
    self.imageData = imageData;
    
    self.shareLogContent = self.content;
}

- (void)share {
    SNAPOpenApiHelper *openApiHelper = [SNAPOpenApiHelper sharedInstance];
    openApiHelper.delegate = self;
    
    if (self.type == SNActionMenuOptionAliPaySession) {
        openApiHelper.scene = APSceneSession;
        self.shareTarget = ShareTargetSNS;
    }
    if (self.type == SNActionMenuOptionAliPayLifeCircle) {
        openApiHelper.scene = APSceneTimeLine;
        self.shareTarget = ShareTargetSNS;
    }
    
    //視頻分享
    if ([self isVideo]) {
        UIImage *image = [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:self.imageUrl]]];
        if (!image) {
            image = [UIImage imageNamed:@"iOS_114_video.png"];
        }
        NSData *imageData = UIImagePNGRepresentation(image);
        if (self.isQianfanShare) {
            NSString *tempStr = self.content;
            self.content = self.title;
            self.title = tempStr;
            if (tempStr.length == 0) {
                self.title = NSLocalizedString(@"Sohu share", @"");
            }
        }
        [openApiHelper shareNewsToAP:self.content
                                        title:self.title
                                   thumbImage:imageData
                                       webUrl:self.mediaUrl];
    }
    // 纯图片的分享 by jojo
    else if ([self isOnlyImage]) {
        [openApiHelper shareImageToAP:self.imageData
                                    imageTitle:self.content];
    }
    //圖文格式的分享
    else {
        NSString *shareComment = [self.shareContentDic stringValueForKey:kShareInfoKeyComment defaultValue:nil];
        if (shareComment.length > 0) {
            self.content = [NSString stringWithFormat:@"%@  %@", shareComment, self.content];
        }
        
        if (self.contentType == ShareTypeLive) {
            //直播分享
            NSData *imageData = [NSData dataWithContentsOfURL:[NSURL URLWithString:self.imageUrl]];
            if (!imageData) {
                imageData = UIImagePNGRepresentation([UIImage imageNamed:@"iOS_114_live.png"]);
            }
            if (self.title.length == 0) {
                self.title = NSLocalizedString(@"Sohu share", nil);
            }
            [openApiHelper shareNewsToAP:self.content
                                            title:self.title
                                       thumbImage:imageData
                                           webUrl:self.webUrl];
        } else if (self.contentType == ShareTypeWeb) {
            //Web
            [openApiHelper shareNewsToAP:self.content
                                            title:self.title
                                       thumbImage:self.imageData
                                           webUrl:self.webUrl];
        } else if (self.contentType == ShareTypeSpecial) {
            //专题
            NSData *imageData = [NSData dataWithContentsOfURL:[NSURL URLWithString:self.imageUrl]];
            if (!imageData) {
                imageData = UIImagePNGRepresentation([UIImage imageNamed:@"iOS_114_normal.png"]);
            }
            if ([SNAPI isWebURL:self.content]) {
                self.content = [[self.content componentsSeparatedByString:[SNAPI rootScheme]] firstObject];
            }
            
            [openApiHelper shareNewsToAP:self.content
                                            title:self.title
                                       thumbImage:imageData
                                           webUrl:self.webUrl];
        } else if (self.contentType == ShareTypeGroup) {
            //组图
            self.imageData = [NSData dataWithContentsOfURL:[NSURL URLWithString:self.imageUrl]];
            [openApiHelper shareNewsToAP:self.content
                                            title:self.title
                                       thumbImage:self.imageData
                                           webUrl:self.webUrl];
        } else {
            [openApiHelper shareNewsToAP:self.content
                                            title:self.title
                                       thumbImage:self.imageData
                                           webUrl:self.webUrl];
        }
    }
    [self log];
}

- (void)shareToThirdPartSuccess:(id)target {
    NSString *appId = nil;
    ShareTargetType type = [target intValue];
    switch (type) {
        case ShareTargetWeixinFriend:
            //微信好友
            appId = SNShareToThirdPartTypeWeiXinFriend;
            break;
        case ShareTargetWeixinTimeline:
            //微信朋友圈
            appId = SNShareToThirdPartTypeWeiXinTimeline;
            break;
        default:
            break;
    }
    //TODO:根据sourceType区分是否调用服务器接口进阅读圈，更好做法应通过shareContentType让服务端做进阅读圈判断。
    if (self.sourceType == SNShareSourceTypeVedio ||
        self.sourceType == SNShareSourceTypeUGC ||
        self.sourceType == SNShareSourceTypePhoto ||
        self.sourceType == SNShareSourceTypeNews ||
        self.sourceType == SNShareSourceTypeLive ||
        self.sourceType == SNShareSourceTypeWeibo) {
        SNTimelineOriginContentObject *obj = [self.shareInfoDic objectForKey:kShareInfoKeyShareRead];
        
        if (!obj) {
            obj = [[SNDBManager currentDataBase] getTimelineOriginObjByType:self.timelineContentType contentId:self.timelineContentId];
        }
        
        SNShareItem *shareItem = [[SNShareItem alloc] init];
        shareItem.shareId = self.shareLogId;
        shareItem.shareContentType = SNShareContentTypeJson;
        shareItem.shareContent = self.content;
        shareItem.shareImageUrl = self.imageUrl;
        shareItem.sourceType = self.sourceType;
        shareItem.shareLink = obj.link;
        shareItem.appId = appId;
        [[SNShareManager defaultManager] postShareItemToServer:shareItem];
    } else {
        [[SNCenterToast shareInstance]
         showCenterToastWithTitle:NSLocalizedString(@"ShareSucceed",
                                                    @"Share Succeed")
         toUrl:nil mode:SNCenterToastModeSuccess];
    }
}

@end
