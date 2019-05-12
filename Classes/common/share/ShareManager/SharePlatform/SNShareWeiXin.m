//
//  SNShareWeiXin.m
//  sohunews
//
//  Created by wang shun on 2017/1/23.
//  Copyright © 2017年 Sohu.com. All rights reserved.
//

#import "SNShareWeiXin.h"

@implementation SNShareWeiXin

-(instancetype)initWithOption:(NSInteger)option{
    if (self = [super initWithOption:option]) {
        
        if (option == SNActionMenuOptionWXTimeline) {//朋友圈
            self.wxType = @"WXTimeline";
            self.shareTarget = ShareTargetWeixinTimeline;
            [[SNWXHelper sharedInstance] setScene:WXSceneTimeline];
        }
        else if(option == SNActionMenuOptionWXSession){//好友
            self.wxType = @"WXSession";
            self.shareTarget = ShareTargetWeixinFriend;
            [[SNWXHelper sharedInstance] setScene:WXSceneSession];
        }
    }
    return self;
}

- (NSDictionary *)getShareParams:(NSDictionary *)dic{
    [super getShareParams:dic];
    
    NSString* content  = [self.shareData objectForKey:@"content"];
    NSString* title    = [self.shareData objectForKey:@"title"];
    NSString *imageUrl = [self.shareData objectForKey:kShareInfoKeyImageUrl];
    NSString *webUrl   = [self.shareData objectForKey:kShareInfoKeyWebUrl];
    
    //正文需要的
    NSString *thumbImage = [self.shareData objectForKey:kShareInfoKeyThumbImage];
    NSData *imageData    = nil;
    NSString *imagePath  = [self.shareData objectForKey:kShareInfoKeyImagePath defalutObj:nil];
    
    if (!imagePath) {
        imagePath = [self.shareData objectForKey:kShareInfoKeyScreenImagePath defalutObj:nil];
    }
    
    UIImage *image = nil;
    
    if (imageUrl && [imageUrl isKindOfClass:[NSString class]]) {
        if ([imageUrl hasSuffix:@".gif"]||[imageUrl hasSuffix:@".GIF"]) {
            
        }
        else{
            __block NSData* img_data = nil;
            dispatch_semaphore_t semaphore = dispatch_semaphore_create(0); //创建信号量
            NSURLSession* session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]];
            NSURLSessionDataTask* task = [session dataTaskWithURL:[NSURL URLWithString:imageUrl] completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
                img_data = data;
                dispatch_semaphore_signal(semaphore);   //发送信号
                
            }];
            [task resume];
            dispatch_semaphore_wait(semaphore,DISPATCH_TIME_FOREVER);  //等待
            
            
            image = [UIImage imageWithData:img_data];
            //image = [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:imageUrl]]];
            if (!image) {
                //双保险
                image = [[SDImageCache sharedImageCache] imageFromDiskCacheForKey:imageUrl];
            }
        }
    }
    if (image) {
        imageData = UIImageJPEGRepresentation(image, SNShare_Platform_Image_CompressionQuality);
    }
    //评论分享的逻辑存在传过来的参数是本地图片而非url的可能性
    if (image == nil) {
        image = [UIImage imageWithContentsOfFile:imagePath];
        //不再压缩本体图片 wangshun 截屏分享效果差
        if (image) {
            imageData = UIImagePNGRepresentation(image);
        }
    }
    
    if ([thumbImage length] > 0 && !imageData) {
        image = [[TTURLCache sharedCache] imageForURL:thumbImage fromDisk:YES];
        if (image) {
            imageData = UIImagePNGRepresentation(image);
        }
    }
    
    if (content.length <= 0) {
        [self.shareData setObject:@"" forKey:@"content"];
    }
    
    if (title.length <= 0) {
        [self.shareData setObject:NSLocalizedString(@"News to share", @"") forKey:@"title"];
    }
    
    
    if (webUrl.length <= 0) {//这是个问题，按理说不用这样
        [self getLinkFromString:content];
    }
    
    if ([[self.shareData objectForKey:@"contentType"] isEqualToString:@"qianfan"]) {
        if (webUrl && webUrl.length>0) {
            [self.shareData setObject:webUrl forKey:kShareInfoKeyMediaUrl];
        }
    }
    
    NSString* contentType = [self.shareData objectForKey:@"contentType"];
    if (!imageData) {
        UIImage *image = [UIImage imageNamed:@"iOS_114_normal.png"];
        if ([self isVideo]) {
            if ([contentType isEqualToString:@"qianfan"]) {
                image = [UIImage imageNamed:@"qianfan_logo_for_share.png"];
            } else {
                image = [UIImage imageNamed:@"iOS_114_video.png"];
            }
        } else if ([contentType isEqualToString:@"live"]) {
            image = [UIImage imageNamed:@"iOS_114_live.png"];
        }
        imageData = UIImagePNGRepresentation(image);
    }
    
    [self.shareData setObject:imageData?:@"" forKey:@"imageData"];
    [self.shareData setObject:content?:@"" forKey:@"shareLogContent"];
    
    return self.shareData;
}

- (void)shareTo:(NSDictionary *)dic Upload:(UploadBlock)method{
    SNDebugLog(@"%@",self);
    
    NSString* content  = [self.shareData objectForKey:@"content"];
    NSString* title    = [self.shareData objectForKey:@"title"];
    NSString* webUrl   = [self.shareData objectForKey:@"webUrl"];
    NSString* mediaUrl = [self.shareData objectForKey:@"mediaUrl"];
    NSString* imageUrl = [self.shareData objectForKey:@"imageUrl"];
    NSString* contentType = [self.shareData objectForKey:@"contentType"];
    NSData*   imageData = [self.shareData objectForKey:@"imageData"];
    
    if (method) {
        self.uploadMethod = method;
    }
    
    if ([self.wxType isEqualToString:@"WXSession"]) {
        //分享到到微信我的好友
        
        //視頻分享
        if ([self isVideo]) {
            if([contentType isEqualToString:@"qianfan"]){
                title = content;
                [[self shareWeixin] shareNewsToWeixin:content
                                                title:title
                                           thumbImage:imageData
                                               webUrl:webUrl];
            }
            else{
                NSString *shareUrl = webUrl;
                if (!shareUrl) {
                    shareUrl = mediaUrl;
                }
                [[self shareWeixin] shareNewsToWeixin:content
                                                title:title
                                           thumbImage:imageData
                                               webUrl:shareUrl];
            }
        }
        // 纯图片的分享 by wangshun
        else if ([self isOnlyImage]) {
            if ([imageUrl hasSuffix:@".gif"]||[imageUrl hasSuffix:@".GIF"]) {
                [[self shareWeixin] shareGifToWeixin:imageUrl ImageData:imageData];
            }
            else{
                [[self shareWeixin] shareImageToWeixin:imageData
                                        imageTitle:content];
            }
        }
        //圖文格式的分享
        else {
            NSString *shareComment = [self.shareData stringValueForKey:kShareInfoKeyComment defaultValue:nil];
            if (shareComment.length > 0) {
                content = [NSString stringWithFormat:@"%@  %@", shareComment, content];
            }
            
            if ([contentType isEqualToString:@"live"]) {//直播分享
                [[self shareWeixin] shareNewsToWeixin:content
                                                title:title
                                           thumbImage:imageData
                                               webUrl:webUrl];
            } else if ([contentType isEqualToString:@"web"]) {
                //Web
                [[self shareWeixin] shareNewsToWeixin:content
                                                title:title
                                           thumbImage:imageData
                                               webUrl:webUrl];
            }
            else if([contentType isEqualToString:@"special"]){//专题
                if ([content containsString:[SNAPI rootScheme]]) {
                    content = [[content componentsSeparatedByString:[SNAPI rootScheme]] firstObject];
                    
                }
                
                [[self shareWeixin] shareNewsToWeixin:content
                                                title:title
                                           thumbImage:imageData
                                               webUrl:webUrl];
            } else if ([contentType isEqualToString:@"group"]) {
                //组图
                NSData* imageData = [NSData dataWithContentsOfURL:[NSURL URLWithString:imageUrl]];
                [[self shareWeixin] shareNewsToWeixin:content
                                                title:title
                                           thumbImage:imageData
                                               webUrl:webUrl];
            } else {
                [[self shareWeixin] shareNewsToWeixin:content
                                                title:title
                                           thumbImage:imageData
                                               webUrl:webUrl];
            }
        }
    } else if ([self.wxType isEqualToString:@"WXTimeline"]) {
        //分享到微信朋友圈
//        self.shareTarget = ShareTargetWeixinTimeline;
        
        //視頻分享
        if ([self isVideo]) {
            if([contentType isEqualToString:@"qianfan"]) {
                title = content;
            }
            [[self shareWeixin] shareNewsToWeixin:content
                                            title:title
                                       thumbImage:imageData
                                           webUrl:mediaUrl];
            
        }
        // 纯图片的分享 by jojo
        else if ([self isOnlyImage]) {
            [[self shareWeixin] shareImageToWeixin:imageData
                                        imageTitle:content];
        }
        //圖文格式的分享
        else {
            NSString *shareComment = [self.shareData stringValueForKey:kShareInfoKeyComment defaultValue:nil];
            if (shareComment.length > 0) {
                content = [NSString stringWithFormat:@"%@  %@", shareComment,content];
            }
            if ([contentType isEqualToString:@"live"]) {//直播分享
                [[self shareWeixin] shareNewsToWeixin:content
                                                title:title
                                           thumbImage:imageData
                                               webUrl:webUrl];
            }
            else if([contentType isEqualToString:@"special"]){//专题
                if ([content containsString:[SNAPI rootScheme]]) {
                    content = [[content componentsSeparatedByString:[SNAPI rootScheme]] firstObject];
                    
                }
                [[self shareWeixin] shareNewsToWeixin:content ? : title
                                                title:title
                                           thumbImage:imageData
                                               webUrl:webUrl];
                
            }
            
            else if([contentType isEqualToString:@"web"]){//web
                [[self shareWeixin] shareNewsToWeixin:title
                                                title:title
                                           thumbImage:imageData
                                               webUrl:webUrl];
            } else if ([contentType isEqualToString:@"qianfan"]) {
                [[self shareWeixin] shareNewsToWeixin:content
                                                title:title
                                           thumbImage:imageData
                                               webUrl:webUrl];
            }
            else if ([contentType isEqualToString:@"channel"]){
                //v5.9_0601_频道预览：分享到微博和微信朋友圈分享语有误
                //http://jira.sohuno.com/browse/NEWSCLIENT-18618
                [[self shareWeixin] shareNewsToWeixin:content
                                                title:content
                                           thumbImage:imageData
                                               webUrl:webUrl];
            }
            else {
                [[self shareWeixin] shareNewsToWeixin:content
                                                title:title
                                           thumbImage:imageData
                                               webUrl:webUrl];
            }
        }
    }
}


- (void)shareToThirdPartSuccess:(BOOL)isShareToQZone{
    if (self.uploadMethod) {
        self.uploadMethod(nil);
    }
}

- (SNWXHelper *)shareWeixin {
    [SNWXHelper sharedInstance].delegate = self;
    return [SNWXHelper sharedInstance];
}

+(BOOL)isInstalledWeiXin{
    
    return [SNWXHelper isWeixinReady];
}



@end
