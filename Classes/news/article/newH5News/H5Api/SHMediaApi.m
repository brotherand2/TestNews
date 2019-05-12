//
//  SHMediaApi.m
//  sohunews
//
//  Created by 赵青 on 16/6/22.
//  Copyright © 2016年 Sohu.com. All rights reserved.
//

#import "SHMediaApi.h"

@implementation SHMediaApi

- (void)jsInterface_jsCallAudioPlay:(JsKitClient *)client audioUrl:(NSString *)audioUrl position:(NSString *)position
{
    if (audioUrl && position) {
        if ([NSThread isMainThread]) {
            [self.newsH5WebViewController soundPlay:audioUrl commentId:position];
        } else {
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.newsH5WebViewController soundPlay:audioUrl commentId:position];
            });
        }
    }
}

- (void)jsInterface_playVideo:(JsKitClient *)client posInfo:(id)posInfo videoInfo:(id)videoInfo
{
    if ([NSThread isMainThread]) {
        [self playVideoPosInfo:posInfo videoInfo:videoInfo];
    } else {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self playVideoPosInfo:posInfo videoInfo:videoInfo];
        });
    }
}

- (void)playVideoPosInfo:(id)posInfo videoInfo:(id)videoInfo
{
    if (posInfo && [posInfo isKindOfClass:[NSDictionary class]] && videoInfo && [videoInfo isKindOfClass:[NSDictionary class]]) {
        NSString *x = [NSString stringWithFormat:@"%@", [posInfo objectForKey:@"x"]];
        NSString *y = [NSString stringWithFormat:@"%@", [posInfo objectForKey:@"y"]];
        NSString *width = [NSString stringWithFormat:@"%@", [posInfo objectForKey:@"width"]];
        NSString *height = [NSString stringWithFormat:@"%@", [posInfo objectForKey:@"height"]];
        CGRect rect = CGRectMake(x.floatValue, y.floatValue, width.floatValue, height.floatValue);
        [self.newsH5WebViewController playVideo:rect tvInfo:videoInfo];
    }
}

@end
