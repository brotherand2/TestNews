//
//  SNCameraConfig.m
//  sohunews
//
//  Created by H on 16/5/26.
//  Copyright © 2016年 Sohu.com. All rights reserved.
//

#import "SNCameraConfig.h"
#import "SNAppConfigConst.h"

@implementation SNCameraConfig

/*
 键名：
 smc.client.camera.photo.config
 
 键值：
 {
 "defMod": "pic"
 }
 
 说明：配置拍照模式。defMod 默认模式：”pic" 扫图片，”2d" 扫二维码
*/
- (void)updateWithDic:(NSDictionary *)dic {
//    NSDictionary * subDic = dic[kCameraPhotoConfig];
    id object = [dic objectForKey:kCameraPhotoConfig];
    if (object && [object isKindOfClass:[NSDictionary class]]) {
        NSDictionary * subDic = (NSDictionary *)object;
        id obj = [subDic objectForKey:@"defMod"];
        if (obj && [obj isKindOfClass:[NSString class]]) {
            self.tabStr = (NSString *)obj;
        }
    }
}

- (void)dealloc {
}

@end
