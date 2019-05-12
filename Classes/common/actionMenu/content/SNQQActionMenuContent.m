//
//  SNQQActionMenuContent.m
//  sohunews
//
//  Created by Dan Cong on 3/13/14.
//  Copyright (c) 2014 Sohu.com. All rights reserved.
//

#import "SNQQActionMenuContent.h"
#import "SNQQHelper.h"
#import "SNShareConfigs.h"
#import "SNDBManager.h"
#import "SNStatusBarMessageCenter.h"


@implementation SNQQActionMenuContent

- (void)share
{
    [self resetShareConfig];
    
    if ([self isVideo]) {
        UIImage *image = [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:self.imageUrl]]];
        if (!image) {
            image = [UIImage imageNamed:@"iOS_114_video.png"];
        }
        NSData *imageData = UIImagePNGRepresentation(image);
        [[self shareQQ] shareMediaToQQ:self.content
                                 title:self.title
                            thumbImage:imageData
                              mediaUrl:self.mediaUrl
                             mediaType:QQApiURLTargetTypeVideo];
    }
    // 纯图片的分享 by jojo
    else if ([self isOnlyImage]) {
        [[self shareQQ] shareImageToQQ:self.imageData
                            imageTitle:self.content
                           description:self.content];
    }
    
    else if(self.contentType == ShareTypeSpecial){//专题
//        self.title = NSLocalizedString(@"Sohu share", nil);
        if ([self.content containsString:[SNAPI rootScheme]]) {
            self.content = [[self.content componentsSeparatedByString:[SNAPI rootScheme]] firstObject];
        }
        
        [[self shareQQ] shareNewsToQQ:self.content
                                title:self.title
                           thumbImage:self.imageData
                               webUrl:self.webUrl];
    }

    else {
        NSString *shareComment = [self.shareContentDic stringValueForKey:kShareInfoKeyComment defaultValue:nil];
        if (shareComment.length > 0) {
            self.content = [NSString stringWithFormat:@"%@  %@", shareComment, self.content];
        }
        [[self shareQQ] shareNewsToQQ:self.content
                                title:self.title
                           thumbImage:self.imageData
                               webUrl:self.webUrl];
    }
    
    [self log];
}

- (void)resetShareConfig {
    [[self shareQQ] setIsShareToQZone:NO];
    self.shareTarget = ShareTargetQQ_friends;
}

- (SNQQHelper *)shareQQ {
    [SNQQHelper sharedInstance].delegate = nil;
    [SNQQHelper sharedInstance].delegate = self;
    return [SNQQHelper sharedInstance];
}

- (void)shareToThirdPartSuccess:(id)target {
    NSString *appId = nil;
    ShareTargetType type = [target intValue];
    switch (type) {
        case ShareTargetQQ_friends:
            appId = SNShareToThirdPartTypeQQ;
            break;
        case ShareTargetQZone:
            appId = SNShareToThirdPartTypeQZone;
            break;
        default:
            break;
    }
    
    if (self.sourceType == SNShareSourceTypeVedio || self.sourceType == SNShareSourceTypeUGC ||
        self.sourceType == SNShareSourceTypePhoto || self.sourceType == SNShareSourceTypeNews ||
        self.sourceType == SNShareSourceTypeLive || self.sourceType == SNShareSourceTypeWeibo) {
        SNTimelineOriginContentObject *obj = [self.shareInfoDic objectForKey:kShareInfoKeyShareRead];
        
        if (!obj) {
            obj = [[SNDBManager currentDataBase] getTimelineOriginObjByType:self.timelineContentType
                                                                  contentId:self.timelineContentId];
        }
        
        SNShareItem *shareItem = [[SNShareItem alloc] init];
        shareItem.shareId = self.shareLogId;
        shareItem.shareContentType = SNShareContentTypeJson;
        shareItem.shareContent   = self.content;
        shareItem.shareImageUrl  = self.imageUrl;
        shareItem.sourceType = self.sourceType;
        shareItem.shareLink = obj.link;
        shareItem.appId = appId;
        
        [[SNShareManager defaultManager] postShareItemToServer:shareItem];
         //(shareItem);
    } else {
        // show success info
        [[SNCenterToast shareInstance] showCenterToastWithTitle:NSLocalizedString(@"ShareSucceed", @"ShareSucceed") toUrl:nil mode:SNCenterToastModeSuccess];
    }
}

- (void)dealloc {
    [SNQQHelper sharedInstance].delegate = nil;
}
            
@end
