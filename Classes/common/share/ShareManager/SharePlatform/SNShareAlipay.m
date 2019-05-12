//
//  SNShareAlipay.m
//  sohunews
//
//  Created by wang shun on 2017/2/6.
//  Copyright © 2017年 Sohu.com. All rights reserved.
//

#import "SNShareAlipay.h"

#import "SNShareConfigs.h"
#import "SNDBManager.h"
#import "SNStatusBarMessageCenter.h"
#import "SNAPOpenApiHelper.h"
#import "APOpenAPIObject.h"
#import "SNCacheManager.h"

@implementation SNShareAlipay

-(instancetype)initWithOption:(NSInteger)option{
    
    if (self = [super initWithOption:option]) {
        
        SNAPOpenApiHelper *openApiHelper = [SNAPOpenApiHelper sharedInstance];
        openApiHelper.delegate = self;
        
        if (self.optionPlatform == SNActionMenuOptionAliPaySession) {
            self.alipayType = @"session";
            openApiHelper.scene = APSceneSession;
            self.shareTarget =  ShareTargetAPSession;
        }
        else if (self.optionPlatform == SNActionMenuOptionAliPayLifeCircle){
            self.alipayType = @"lifecircle";
            openApiHelper.scene = APSceneTimeLine;
            self.shareTarget =  ShareTargetAPTimeLine;
        }
    }
         
    return self;
}

-(NSDictionary *)getShareParams:(NSDictionary *)dic{
    [super getShareParams:dic];
    
    UIImage *image = nil;
    NSString* imageUrl = [self.shareData objectForKey:@"imageUrl"];
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
    NSData* imageData = nil;
    NSString *imagePath = [self.shareData objectForKey:kShareInfoKeyImagePath defalutObj:nil];
    if (!imagePath) {
        imagePath = [self.shareData objectForKey:kShareInfoKeyScreenImagePath defalutObj:nil];
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
    
    [self.shareData setObject:imageData?:@"" forKey:@"imageData"];
    
    return self.shareData;
}

-(void)shareTo:(NSDictionary *)dic Upload:(UploadBlock)method{
    SNAPOpenApiHelper *openApiHelper = [SNAPOpenApiHelper sharedInstance];
    
    NSString* content = [self.shareData objectForKey:@"content"];
    NSString* title   = [self.shareData objectForKey:@"title"];
    NSString* webUrl  = [self.shareData objectForKey:@"webUrl"];
    NSString* contentType = [self.shareData objectForKey:@"contentType"];
    NSString* imageUrl  = [self.shareData objectForKey:@"imageUrl"];
    NSData*   imageData = [self.shareData objectForKey:@"imageData"];
    NSString* mediaUrl  = [self.shareData objectForKey:@"mediaUrl"];
    
    if (method) {
        self.uploadMethod = method;
    }
    
    //視頻分享
    if ([self isVideo]) {
        UIImage *image = [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:imageUrl]]];
        if (!image) {
            image = [UIImage imageNamed:@"iOS_114_video.png"];
        }
        NSData *imageData = UIImagePNGRepresentation(image);
        
        NSString* isQianfanShare = [self.shareData objectForKey:@"isQianfanShare"];
        
        
        if ([isQianfanShare isEqualToString:@"1"]) {
            NSString *tempStr = content;
            content = title;
            title = tempStr;
            if (tempStr.length == 0) {
                title = NSLocalizedString(@"Sohu share", @"");
            }
        }
        
        [openApiHelper shareNewsToAP:content
                               title:title
                          thumbImage:imageData
                              webUrl:mediaUrl];
    }
    // 纯图片的分享 by jojo
    else if ([self isOnlyImage]) {
        [openApiHelper shareImageToAP:imageData
                           imageTitle:content];
    }
    //圖文格式的分享
    else {
        NSString *shareComment = [self.shareData stringValueForKey:kShareInfoKeyComment defaultValue:nil];
        if (shareComment.length > 0) {
            content = [NSString stringWithFormat:@"%@  %@", shareComment, content];
        }
        
        if ([contentType isEqualToString:@"live"]) {
            //直播分享
            NSData *imageData = [NSData dataWithContentsOfURL:[NSURL URLWithString:imageUrl]];
            if (!imageData) {
                imageData = UIImagePNGRepresentation([UIImage imageNamed:@"iOS_114_live.png"]);
            }
            if (title.length == 0) {
                title = NSLocalizedString(@"Sohu share", nil);
            }
            [openApiHelper shareNewsToAP:content
                                   title:title
                              thumbImage:imageData
                                  webUrl:webUrl];
        } else if ([contentType isEqualToString:@"web"]) {
            //Web
            [openApiHelper shareNewsToAP:content
                                   title:title
                              thumbImage:imageData
                                  webUrl:webUrl];
        } else if ([contentType isEqualToString:@"special"]) {
            //专题
            NSData *imageData = [NSData dataWithContentsOfURL:[NSURL URLWithString:imageUrl]];
            if (!imageData) {
                imageData = UIImagePNGRepresentation([UIImage imageNamed:@"iOS_114_normal.png"]);
            }
            if ([SNAPI isWebURL:content]) {
                content = [[content componentsSeparatedByString:[SNAPI rootScheme]] firstObject];
            }
            
            [openApiHelper shareNewsToAP:content
                                   title:title
                              thumbImage:imageData
                                  webUrl:webUrl];
        } else if ([contentType isEqualToString:@"group"]) {
            //组图
            imageData = [NSData dataWithContentsOfURL:[NSURL URLWithString:imageUrl]];
            [openApiHelper shareNewsToAP:content
                                   title:title
                              thumbImage:imageData
                                  webUrl:webUrl];
        } else {
            if ([contentType isEqualToString:@"qianfan"]) {
                [openApiHelper shareNewsToAP:content
                                       title:content
                                  thumbImage:imageData
                                      webUrl:webUrl];
            }
            else {

                [openApiHelper shareNewsToAP:content
                                       title:title
                                  thumbImage:imageData
                                      webUrl:webUrl];
            }
        }
    }

    
}

- (void)shareToThirdPartSuccess:(id)target{
    if (self.uploadMethod) {
        self.uploadMethod(nil);
    }
}

+(BOOL)isAliPayAppInstalled{
    if (![APOpenAPI isAPAppInstalled]) {
        return NO;
    }
    if (![APOpenAPI isAPAppSupportOpenApi]) {
        return NO;
    }
    
    return YES;
}

@end
