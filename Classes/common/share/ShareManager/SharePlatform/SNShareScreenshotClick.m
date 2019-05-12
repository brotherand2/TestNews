//
//  SNShareScreenshotClick.m
//  sohunews
//
//  Created by wang shun on 2017/7/11.
//  Copyright © 2017年 Sohu.com. All rights reserved.
//

#import "SNShareScreenshotClick.h"

#import "SNScreenshotRequest.h"

#import <AudioToolbox/AudioToolbox.h>

@implementation SNShareScreenshotClick

+ (void)getScreenShare:(NSDictionary*)data{
    
    dispatch_async(dispatch_get_main_queue(), ^{
        
        [SNShareScreenshotClick startAnimation:^(UIImage *img) {
            [SNScreenshotRequest getScreenShotToShareWithAnimation:img WithData:data];
        }];
    });
    
    //去掉new icon上的
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setBool:YES forKey:kFirstShowScreenShareKey1];
    [userDefaults synchronize];
    
    //埋点
    NSString* url  = [[data objectForKey:@"url"] URLEncodedString];
    NSString* stid = [data objectForKey:@"newsId"];
    NSString* s    = @"screen_capture";
    
    NSString* str = [NSString stringWithFormat:@"stat=s&s=%@&st=&url=%@&stid=%@&newstype=&channelid=&subid=&termid=&flow=",s,url,stid];
    
    [SNNewsReport reportADotGif:str];
}

+ (void)startAnimation:(void(^)(UIImage* img))method{
    UIView * view = [[UIView alloc]initWithFrame:[UIScreen mainScreen].bounds];
    view.backgroundColor = [UIColor whiteColor];
    UIWindow * window = [UIApplication sharedApplication].keyWindow;
    [window addSubview:view];
//    AudioServicesPlaySystemSound (1108);//咔 一声
    
    [ UIView animateWithDuration:0.5 animations:^{
        view.alpha = 0.05;
    } completion:^(BOOL finished) {
        [view removeFromSuperview];
        
        UIImage *image = [UIImage imageWithScreenshot];
        UIImageView * imageView = [[UIImageView alloc]initWithFrame:[UIScreen mainScreen].bounds];
        imageView.image = image;
        imageView.backgroundColor = [UIColor redColor];
        [window addSubview:imageView];
        
        if (method) {
            method(image);
        }
        
        CGFloat f = [UIScreen mainScreen].bounds.size.height-20-44;
        CGFloat b1 = ([UIScreen mainScreen].bounds.size.width/f);//裁图比例
        
        CGFloat h = [UIScreen mainScreen].bounds.size.height-47-61-10-10;
        CGFloat w = b1*h;
        CGFloat x = ([UIScreen mainScreen].bounds.size.width-w)/2.0;
        
        CGFloat b = (w/[UIScreen mainScreen].bounds.size.width);
        CGFloat i_h = b*[UIScreen mainScreen].bounds.size.height;
        
        CGFloat y = (20/64.0)* (i_h - h);
        CGRect rect = CGRectMake(x, 47+10-y, w, i_h);
        
        
        [UIView animateWithDuration:0.5 animations:^{
            imageView.frame = rect;
            
        } completion:^(BOOL finished) {
            [UIView animateWithDuration:0.1 animations:^{
                imageView.alpha = 0.3;
            } completion:^(BOOL finished) {
                [imageView removeFromSuperview];
            }];
        }];
        

    }];

}

@end
