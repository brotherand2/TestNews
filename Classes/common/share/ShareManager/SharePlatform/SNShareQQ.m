//
//  SNShareQQ.m
//  sohunews
//
//  Created by wang shun on 2017/2/4.
//  Copyright © 2017年 Sohu.com. All rights reserved.
//

#import "SNShareQQ.h"

@implementation SNShareQQ

- (instancetype)initWithOption:(NSInteger)option{
    if (self = [super initWithOption:option]) {
        if (self.optionPlatform == SNActionMenuOptionQQ) {
            self.isQZone = @"qq";
            [[SNQQHelper sharedInstance] setIsShareToQZone:NO];
            self.shareTarget = ShareTargetQQ_friends;
        }
        else if (self.optionPlatform == SNActionMenuOptionQZone){
            self.isQZone = @"qzone";
            [[SNQQHelper sharedInstance] setIsShareToQZone:YES];
            self.shareTarget = ShareTargetQZone;
        }
        [SNQQHelper sharedInstance].delegate = self;
    }
    return self;
}

- (NSDictionary *)getShareParams:(NSDictionary *)dic{
    [super getShareParams:dic];
    
    NSString* content = [self.shareData objectForKey:@"content"];
    NSString* title = [self.shareData objectForKey:@"title"];
    NSString *imageUrl = [self.shareData objectForKey:kShareInfoKeyImageUrl];
    NSString *webUrl = [self.shareData objectForKey:kShareInfoKeyWebUrl];
    
    //正文需要的
    NSString *thumbImage = [self.shareData objectForKey:kShareInfoKeyThumbImage];
    NSData *imageData = nil;
    NSString *imagePath = [self.shareData objectForKey:kShareInfoKeyImagePath defalutObj:nil];
    if (!imagePath) {
        imagePath = [self.shareData objectForKey:kShareInfoKeyScreenImagePath defalutObj:nil];
    }
    
    UIImage *image = nil;
    
    if (imageUrl && [imageUrl isKindOfClass:[NSString class]]) {
        if ([imageUrl hasSuffix:@".gif"]||[imageUrl hasSuffix:@".GIF"]) {//gif 还是别下了，太大了
            
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
        if (image) {
            imageData = UIImageJPEGRepresentation(image, SNShare_Platform_Image_CompressionQuality);
        }
    }
    
    if ([thumbImage length] > 0 && !imageData) {
        image = [[TTURLCache sharedCache] imageForURL:thumbImage fromDisk:YES];
        if (image) {
            imageData = UIImageJPEGRepresentation(image, SNShare_Platform_Image_CompressionQuality);
        }
    }
    
    if (content.length <= 0) {
        [self.shareData setObject:@"" forKey:@"content"];
    }
    
    if (title.length <= 0) {
        [self.shareData setObject:NSLocalizedString(@"News to share", @"") forKey:@"title"];
    }
    

    if (webUrl.length <= 0) {
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

    NSString* content = [self.shareData objectForKey:@"content"];
    NSString* title   = [self.shareData objectForKey:@"title"];
    NSString* webUrl  = [self.shareData objectForKey:@"webUrl"];
    NSString* contentType = [self.shareData objectForKey:@"contentType"];
    NSString* imageUrl = [self.shareData objectForKey:@"imageUrl"];
    
    if (method) {
        self.uploadMethod = method;
    }
    
    if ([self isVideo]) {
        UIImage *image = [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:imageUrl]]];
        if (!image) {
            image = [UIImage imageNamed:@"iOS_114_video.png"];
        }
        NSData *imageData = UIImagePNGRepresentation(image);
        NSString* mediaUrl = [self.shareData objectForKey:@"mediaUrl"];
        [[self shareQQ] shareMediaToQQ:content
                                 title:title
                            thumbImage:imageData
                              mediaUrl:mediaUrl
                             mediaType:QQApiURLTargetTypeVideo];
    }
    // 纯图片的分享 by jojo
    else if ([self isOnlyImage]) {
        
        if ([imageUrl hasSuffix:@".gif"]||[imageUrl hasSuffix:@".GIF"]) {
            [[self shareQQ] shareGifToQQ:imageUrl imageTitle:content description:content];
        }
        else{
        
            NSData* imageData = [self.shareData objectForKey:@"imageData"];
            [[self shareQQ] shareImageToQQ:imageData
                            imageTitle:content
                           description:content];
        }
    }
    
    else if([contentType isEqualToString:@"special"]){//专题
        //        title = NSLocalizedString(@"Sohu share", nil);
        if ([content containsString:[SNAPI rootScheme]]) {
            content = [[content componentsSeparatedByString:[SNAPI rootScheme]] firstObject];
        }
        
        NSData* imageData = [self.shareData objectForKey:@"imageData"];
        [[self shareQQ] shareNewsToQQ:content
                                title:title
                           thumbImage:imageData
                               webUrl:webUrl];
    }
    
    else {
        NSString *shareComment = [self.shareData stringValueForKey:kShareInfoKeyComment defaultValue:nil];
        if (shareComment.length > 0) {
            content = [NSString stringWithFormat:@"%@  %@", shareComment, content];
        }
        NSData* imageData = [self.shareData objectForKey:@"imageData"];
        [[self shareQQ] shareNewsToQQ:content
                                title:title
                           thumbImage:imageData
                               webUrl:webUrl];
    }
}

- (void)shareToThirdPartSuccess:(id)target{
    if (self.uploadMethod) {
        self.uploadMethod(nil);
    }
}

- (SNQQHelper *)shareQQ {
    [SNQQHelper sharedInstance].delegate = nil;
    [SNQQHelper sharedInstance].delegate = self;
    return [SNQQHelper sharedInstance];
}

+ (BOOL)isSupportQQSSO{
   return [SNQQHelper isSupportQQSSO];
}

@end
