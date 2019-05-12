//
//  SNWXActionMenuContent.m
//  sohunews
//
//  Created by Dan Cong on 12/10/13.
//  Copyright (c) 2013 Sohu.com. All rights reserved.
//

#import "SNWXActionMenuContent.h"
#import "SNShareConfigs.h"
#import "SNDBManager.h"
#import "SNStatusBarMessageCenter.h"

#import "SNUnifyShareServer.h"
#import "SNCacheManager.h"

#define kCompressionQuality 0.5

@implementation SNWXActionMenuContent

- (void)interpretContext:(NSDictionary *)contentDic {
    [super interpretContext:contentDic];
    
    NSString *imageUrl = [contentDic objectForKey:kShareInfoKeyImageUrl];
    //正文需要的
    NSString *thumbImage = [contentDic objectForKey:kShareInfoKeyThumbImage];
    NSData *imageData = nil;
    NSString *imagePath = [contentDic objectForKey:kShareInfoKeyImagePath defalutObj:nil];
    if (!imagePath) {
        imagePath = [contentDic objectForKey:kShareInfoKeyScreenImagePath defalutObj:nil];
    }
    
    UIImage *image = nil;
    
    if (imageUrl && [imageUrl isKindOfClass:[NSString class]]) {
        self.imageUrl = imageUrl;
        image = [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:self.imageUrl]]];
        if (!image) {
            //双保险
            image = [[SDImageCache sharedImageCache] imageFromDiskCacheForKey:imageUrl];
        }
    }
    if (image) {
        imageData = UIImageJPEGRepresentation(image, kCompressionQuality);
    }
    //评论分享的逻辑存在传过来的参数是本地图片而非url的可能性
    if (image == nil) {
        image = [UIImage imageWithContentsOfFile:imagePath];
        if (image) {
            imageData = UIImageJPEGRepresentation(image, kCompressionQuality);
        }
    }
    
    if ([thumbImage length] > 0 && !imageData) {
        image = [[TTURLCache sharedCache] imageForURL:thumbImage fromDisk:YES];
        if (image) {
            imageData = UIImageJPEGRepresentation(image, kCompressionQuality);
        }
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
    if (!imageData) {
        UIImage *image = [UIImage imageNamed:@"iOS_114_normal.png"];
        if ([self isVideo]) {
            if (self.contentType == ShareTypeQianfan) {
                image = [UIImage imageNamed:@"qianfan_logo_for_share.png"];
            } else {
                image = [UIImage imageNamed:@"iOS_114_video.png"];
            }
        } else if (self.contentType == ShareTypeLive) {
            image = [UIImage imageNamed:@"iOS_114_live.png"];
        }
        imageData = UIImagePNGRepresentation(image);
    }
    self.imageData = imageData;
    
    self.shareLogContent = self.content;
}

- (BOOL)isVideo {
    if (self.mediaUrl && [self.mediaUrl isEqualToString:@"(null)"]) {
        return NO;
    }
    return self.mediaUrl.length > 0;
}

- (BOOL)isOnlyImage {
    return self.imageData.length > 0 && self.webUrl.length == 0;
}

- (void)share {
    if (self.type == SNActionMenuOptionWXSession) {
        //分享到到微信我的好友
        self.shareTarget = ShareTargetWeixinFriend;
        
        //視頻分享
        if ([self isVideo]) {
            if(self.contentType == ShareTypeQianfan){
                [[self shareWeixin] shareNewsToWeixin:self.content
                                                title:self.title
                                           thumbImage:self.imageData
                                               webUrl:self.webUrl];
            } else {
                NSString *shareUrl = self.webUrl;
                if (!shareUrl) {
                    shareUrl = self.mediaUrl;
                }
                [[self shareWeixin] shareNewsToWeixin:self.content
                                                title:self.title
                                           thumbImage:self.imageData
                                               webUrl:shareUrl];
            }
        }
        // 纯图片的分享 by jojo
        else if ([self isOnlyImage]) {
            [[self shareWeixin] shareImageToWeixin:self.imageData
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
                [[self shareWeixin] shareNewsToWeixin:self.content
                                                title:self.title
                                           thumbImage:self.imageData
                                               webUrl:self.webUrl];
            } else if (self.contentType == ShareTypeWeb) {
                //Web
                [[self shareWeixin] shareNewsToWeixin:self.content
                                                title:self.title
                                           thumbImage:self.imageData
                                               webUrl:self.webUrl];

            }
            else if(self.contentType == ShareTypeSpecial){//专题
                if ([self.content containsString:[SNAPI rootScheme]]) {
                    self.content = [[self.content componentsSeparatedByString:[SNAPI rootScheme]] firstObject];

                }
                
                [[self shareWeixin] shareNewsToWeixin:self.content
                                                title:self.title
                                           thumbImage:self.imageData
                                               webUrl:self.webUrl];
            } else if (self.contentType == ShareTypeGroup) {
                //组图
                self.imageData = [NSData dataWithContentsOfURL:[NSURL URLWithString:self.imageUrl]];
                [[self shareWeixin] shareNewsToWeixin:self.content
                                                title:self.title
                                           thumbImage:self.imageData
                                               webUrl:self.webUrl];
            } else {
                [[self shareWeixin] shareNewsToWeixin:self.content
                                                title:self.title
                                           thumbImage:self.imageData
                                               webUrl:self.webUrl];
            }
        }
    } else if (self.type == SNActionMenuOptionWXTimeline) {
        //分享到微信朋友圈
        self.shareTarget = ShareTargetWeixinTimeline;
        
        //視頻分享
        if ([self isVideo]) {
            if(self.contentType == ShareTypeQianfan) {
                self.content = self.title;
            }
            [[self shareWeixin] shareNewsToWeixin:self.content
                                            title:self.title
                                       thumbImage:self.imageData
                                           webUrl:self.mediaUrl];

        }
        // 纯图片的分享 by jojo
        else if ([self isOnlyImage]) {
            [[self shareWeixin] shareImageToWeixin:self.imageData
                                        imageTitle:self.content];
        }
        //圖文格式的分享
        else {
            NSString *shareComment = [self.shareContentDic stringValueForKey:kShareInfoKeyComment defaultValue:nil];
            if (shareComment.length > 0) {
                self.content = [NSString stringWithFormat:@"%@  %@", shareComment, self.content];
            }
            if (self.contentType == ShareTypeLive) {//直播分享
                [[self shareWeixin] shareNewsToWeixin:self.content
                                                title:self.title
                                           thumbImage:self.imageData
                                               webUrl:self.webUrl];
            }
            
            else if(self.contentType == ShareTypeSpecial){//专题
                if ([self.content containsString:[SNAPI rootScheme]]) {
                    self.content = [[self.content componentsSeparatedByString:[SNAPI rootScheme]] firstObject];

                }
                [[self shareWeixin] shareNewsToWeixin:self.content ? : self.title
                                                title:self.title
                                           thumbImage:self.imageData
                                               webUrl:self.webUrl];

            }

            else if(self.contentType == ShareTypeWeb){//web
                if ([self.content containsString:[SNAPI rootScheme]]) {
                    self.content = [[self.content componentsSeparatedByString:[SNAPI rootScheme]] firstObject];

                }

                [[self shareWeixin] shareNewsToWeixin:self.title
                                                title:self.title
                                           thumbImage:self.imageData
                                               webUrl:self.webUrl];
            } else if (self.contentType == ShareTypeQianfan) {
                [[self shareWeixin] shareNewsToWeixin:self.content
                                                title:self.title
                                           thumbImage:self.imageData
                                               webUrl:self.webUrl];
             } else {
                 [[self shareWeixin] shareNewsToWeixin:self.content
                                                 title:self.title
                                            thumbImage:self.imageData
                                                webUrl:self.webUrl];
             }
        }
    }
    [self log];
}

- (SNWXHelper *)shareWeixin {
    [SNWXHelper sharedInstance].delegate = self;
    return [SNWXHelper sharedInstance];
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
    //TODO:根据sourceType区分是否调用服务器接口进阅读圈
    //更好做法应通过shareContentType让服务端做进阅读圈判断。
    if (self.sourceType == SNShareSourceTypeVedio || self.sourceType == SNShareSourceTypeUGC ||
        self.sourceType == SNShareSourceTypePhoto || self.sourceType == SNShareSourceTypeNews ||
        self.sourceType == SNShareSourceTypeLive || self.sourceType == SNShareSourceTypeWeibo) {
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
        [[SNCenterToast shareInstance] showCenterToastWithTitle:NSLocalizedString(@"ShareSucceed", @"Share Succeed") toUrl:nil mode:SNCenterToastModeSuccess];
    }
}

@end
