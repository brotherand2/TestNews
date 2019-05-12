//
//  SNNewsShareGif.m
//  sohunews
//
//  Created by wang shun on 2017/3/15.
//  Copyright © 2017年 Sohu.com. All rights reserved.
//

#import "SNNewsShareGif.h"

@implementation SNNewsShareGif

+(void)analyseGifData:(SNSharePlatformBase *)sharePlatForm Method:(void (^)(void))method{
    SNActionMenuOption option = sharePlatForm.optionPlatform;
    
    /*
      (刘乐需求) 2017.3.15 wangshun
     
      只做两个gif分享 qq好友 微信好友
     
      微信朋友圈 新浪微博 支付宝好友 和其余都走 h5 正文连接
     
     */
   
    if (   option == SNActionMenuOptionWXTimeline
//        || option == SNActionMenuOptionWXSession
//        || option == SNActionMenuOptionQQ
        || option == SNActionMenuOptionMySOHU
        || option == SNActionMenuOptionAliPaySession
        || option == SNActionMenuOptionOAuths) {
        
        
        NSMutableDictionary* mdic = [sharePlatForm.shareData objectForKey:@"isNoGif"];
        if (mdic) {//h5连接数据
            sharePlatForm.shareData = mdic;
        }
    }
}



@end
