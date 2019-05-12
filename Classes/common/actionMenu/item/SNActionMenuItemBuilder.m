//
//  SNActionMenuItemBuilder.m
//  sohunews
//
//  Created by Dan Cong on 3/27/14.
//  Copyright (c) 2014 Sohu.com. All rights reserved.
//

#import "SNActionMenuItemBuilder.h"

@implementation SNActionMenuItemBuilder

+ (NSArray *)buildActionMenuItemsWithOptions:(SNActionMenuOptions)options {
    NSMutableArray *items = [NSMutableArray array];
    SNActionMenuItem *obj = nil;
    
    if (options & SNActionMenuOptionWXTimeline) {
        obj = [SNActionMenuItem itemWithTitle:@"微信朋友圈"
                                        image:[UIImage themeImageNamed:@"icofloat_friendcircle_v5.png"]
                                         type:SNActionMenuOptionWXTimeline];
        
        //lijian 2014.12.16 增加按下效果
        [obj addHightlightImage:[UIImage themeImageNamed:@"icofloat_friendcirclepress_v5.png"]];
        [items addObject:obj];
    }
    if (options & SNActionMenuOptionWXSession) {
        obj = [SNActionMenuItem itemWithTitle:@"微信好友" image:[UIImage themeImageNamed:@"icofloat_wechat_v5.png"] type:SNActionMenuOptionWXSession];
        //lijian 2014.12.16 增加按下效果
        [obj addHightlightImage:[UIImage themeImageNamed:@"icofloat_wechatpress_v5.png"]];
        [items addObject:obj];
    }
    
    //5.2.0 增加分享到搜狐我的
    if (options & SNActionMenuOptionMySOHU) {
        obj = [SNActionMenuItem itemWithTitle:NSLocalizedString(@"Me", nil)
                                        image:[UIImage themeImageNamed:@"icofloat_sohu_v5.png"]
                                         type:SNActionMenuOptionMySOHU];
        //lijian 2014.12.16 增加按下效果
        [obj addHightlightImage:[UIImage themeImageNamed:@"icofloat_sohu_v5.png"]];
        [items addObject:obj];
    }

    
    if (options & SNActionMenuOptionOAuths) {
        obj = [SNActionMenuItem itemWithTitle:@"新浪微博"
                                        image:[UIImage themeImageNamed:@"icofloat_weibo_v5.png"]
                                         type:SNActionMenuOptionOAuths];
        //lijian 2014.12.16 增加按下效果
        [obj addHightlightImage:[UIImage themeImageNamed:@"icofloat_weibopress_v5.png"]];
        [items addObject:obj];
    }
    
    if (options & SNActionMenuOptionQZone) {
        obj = [SNActionMenuItem itemWithTitle:@"QQ空间"
                                                   image:[UIImage themeImageNamed:@"icofloat_qzone_v5.png"]
                                                    type:SNActionMenuOptionQZone];
        
        //lijian 2014.12.16 增加按下效果
        [obj addHightlightImage:[UIImage themeImageNamed:@"icofloat_qzonepress_v5.png"]];
        [items addObject:obj];
    }
    
    if (options & SNActionMenuOptionQQ) {
        obj = [SNActionMenuItem itemWithTitle:@"QQ"
                                        image:[UIImage themeImageNamed:@"icofloat_qq_v5.png"]
                                         type:SNActionMenuOptionQQ];
        
        //lijian 2014.12.16 增加按下效果
        [obj addHightlightImage:[UIImage themeImageNamed:@"icofloat_qqpress_v5.png"]];
        [items addObject:obj];
    }

    if (options & SNActionMenuOptionSMS) {
        BOOL canSendSms = [SmsSupport canCurrentDeviceSendSms];
        
        obj = [SNActionMenuItem itemWithTitle:@"短信"
                                                   image:[UIImage themeImageNamed:canSendSms ? @"share_sms.png" : @"share_sms_disable.png"]
                                                    type:SNActionMenuOptionSMS
                                                 disable:!canSendSms];
        
        //lijian 2014.12.16 增加按下效果
        //[obj addHightlightImage:[UIImage themeImageNamed:@"icofloat_quick_v5.png"]];
        [items addObject:obj];
    }
    if (options & SNActionMenuOptionMail) {
        obj = [SNActionMenuItem itemWithTitle:@"邮件"
                                                   image:[UIImage themeImageNamed:@"share_email.png"]
                                                    type:SNActionMenuOptionMail];
        
        //lijian 2014.12.16 增加按下效果
        //[obj addHightlightImage:[UIImage themeImageNamed:@"icofloat_quick_v5.png"]];
        [items addObject:obj];
    }

    if (options & SNActionMenuOptionDownload) {
        obj = [SNActionMenuItem itemWithTitle:@"下载"
                                                   image:[UIImage themeImageNamed:@"share_download.png"]
                                                    type:SNActionMenuOptionDownload];
        
        //lijian 2014.12.16 增加按下效果
        //[obj addHightlightImage:[UIImage themeImageNamed:@"icofloat_quick_v5.png"]];
        [items addObject:obj];
    }
    
    if (options & SNActionMenuOptionAliPaySession) {
        obj = [SNActionMenuItem itemWithTitle:kShareTitleAliPaySession
                                        image:[UIImage themeImageNamed:@"icofloat_session_v5.png"]
                                         type:SNActionMenuOptionAliPaySession];
        //lijian 2014.12.16 增加按下效果
        [obj addHightlightImage:[UIImage themeImageNamed:@"icofloat_sessionpress_v5.png"]];
        [items addObject:obj];
    }
    
    if (options & SNActionMenuOptionAliPayLifeCircle) {
        obj = [SNActionMenuItem itemWithTitle:kShareTitleAliPayLifeCircle
                                        image:[UIImage themeImageNamed:@"icofloat_lifecircle_v5.png"]
                                         type:SNActionMenuOptionAliPayLifeCircle];
        //lijian 2014.12.16 增加按下效果
        [obj addHightlightImage:[UIImage themeImageNamed:@"icofloat_lifecirclepress_v5.png"]];
        [items addObject:obj];
    }
    
    if (options & SNActionMenuOptionWebLink) {
        obj = [SNActionMenuItem itemWithTitle:@"复制链接"
                                                   image:[UIImage imageNamed:@"icofloat_link_v5.png"]
                                                    type:SNActionMenuOptionWebLink];
        
        //lijian 2014.12.16 增加按下效果
        [obj addHightlightImage:[UIImage themeImageNamed:@"icofloat_linkpress_v5.png"]];
        [items addObject:obj];
    }
    
    return [NSArray arrayWithArray:items];
}

@end
