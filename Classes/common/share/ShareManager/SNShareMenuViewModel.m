//
//  SNShareMenuViewModel.m
//  sohunews
//
//  Created by wang shun on 2017/1/20.
//  Copyright © 2017年 Sohu.com. All rights reserved.
//

#import "SNShareMenuViewModel.h"

#import "SNNewsShareParamsHeader.h"

@implementation SNShareMenuViewModel

- (instancetype)initWithData:(NSDictionary*)dic{
    if (self = [super init]) {
        //初始化icon
        self.shareIconsArr = [self createShareIcon:dic];
    }
    return self;
}


- (NSArray*)createShareIcon:(NSDictionary*)dic{
    
    //控制icon是否显示
    NSString* disableIcons = [dic objectForKey:SNNewsShare_disableIcons];
    NSString* addIcons = [dic objectForKey:SNNewsShare_addIcons];
    //disableIcons = @"moments,weChat,sohu,sina,qqZone,qq,alipay,lifeCircle,copyLink";
    
    NSMutableArray* _shareArray = [[NSMutableArray alloc] initWithCapacity:0];
    
    if (![self rangeWithString:@"moments" WithDisableIcons:disableIcons]) {//1
        //wexinTimeline 朋友圈
        [_shareArray addObject:@{kShareIconImage:@"icofloat_pyq_v5.png",kShareIconTitle:kShareTitleWechat}];
    }
    
    if (![self rangeWithString:@"weChat" WithDisableIcons:disableIcons]) {//2
        //weixinSession
        [_shareArray addObject:@{kShareIconImage:@"icofloat_wxhy_v5.png",kShareIconTitle:kShareTitleWechatSession}];
    }
    
    if (![self rangeWithString:@"sohu" WithDisableIcons:disableIcons]) {//3
        //sohu
        [_shareArray addObject:@{kShareIconImage:@"icofloat_hy_v5.png",kShareIconTitle:kShareTitleMySohu}];
    }
    
    NSString* local_webview = [dic objectForKey:@"local_webview"];
    if (local_webview && [local_webview isEqualToString:@"1"]) {//外链 加入截屏分享
        [_shareArray addObject:@{kShareIconImage:@"icofloat_hzd_v5.png",kShareIconTitle:kShareTitleScreenshot}];
    }
    else{
        if ([self rangeWithString:@"screenshot" WithDisableIcons:addIcons]) {
            [_shareArray addObject:@{kShareIconImage:@"icofloat_hzd_v5.png",kShareIconTitle:kShareTitleScreenshot}];
        }
    }
    
    if (![self rangeWithString:@"qqZone" WithDisableIcons:disableIcons]) {//5
        //qqZone
        [_shareArray addObject:@{kShareIconImage:@"icofloat_qqkj_v5.png",kShareIconTitle:kShareTitleQQZone}];
    }
    
    if (![self rangeWithString:@"qq," WithDisableIcons:disableIcons]) {//6 注意啊 qq和qqZone 都包含qq
        //qq
        
        if (![self rangeWithString:@"qqZone" WithDisableIcons:disableIcons]) {//如果没有qqZone 只有qq
            if (![self rangeWithString:@"qq" WithDisableIcons:disableIcons]) {
                [_shareArray addObject:@{kShareIconImage:@"icofloat_qq_v5.png",kShareIconTitle:kShareTitleQQ}];
            }
        }
        else{
            [_shareArray addObject:@{kShareIconImage:@"icofloat_qq_v5.png",kShareIconTitle:kShareTitleQQ}];
        }
    }
    
    if (![self rangeWithString:@"alipay" WithDisableIcons:disableIcons]) {//7
        //alipaySession
        [_shareArray addObject:@{kShareIconImage:@"icofloat_zfb_v5.png",kShareIconTitle:kShareTitleAliPaySession}];
    }
    
    if (![self rangeWithString:@"sina" WithDisableIcons:disableIcons]) {//4
        //weibo
        [_shareArray addObject:@{kShareIconImage:@"icofloat_xlwb_v5.png",kShareIconTitle:kShareTitleSina}];
    }
    
//    if (![self rangeWithString:@"lifeCircle" WithDisableIcons:disableIcons]) {//8
//        //alipayLifeCircle
//        [_shareArray addObject:@{kShareIconImage:@"icofloat_shq_v5.png",kShareIconTitle:kShareTitleAliPayLifeCircle}];
//    }
    
    if (![self rangeWithString:@"copyLink" WithDisableIcons:disableIcons]) {//9
        //webLink
        [_shareArray addObject:@{kShareIconImage:@"icofloat_lj_v5.png",kShareIconTitle:kShareTitleWebLink}];
    }
    
    return _shareArray;
}

- (BOOL)rangeWithString:(NSString*)iconName WithDisableIcons:(NSString*)disableIcons{
    if (disableIcons == nil) {
        return NO;//不隐藏
    }
    
    NSRange range = [disableIcons rangeOfString:iconName];
    if (range.location != NSNotFound) {//如果存在 隐藏
        return YES;//隐藏
    }
    else{
        return NO;
    }
}

@end
