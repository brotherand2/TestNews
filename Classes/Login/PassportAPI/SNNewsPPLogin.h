//
//  SNNewsPPLogin.h
//  sohunews
//
//  Created by wang shun on 2017/10/30.
//  Copyright © 2017年 Sohu.com. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

#import "SNNewsThirdAPPKEYHeader.h"
#import "SNNewsPPLoginCookie.h"

//关于GID的使用和保存原则：GID在客户端内应该尽可能的永久保存，GID是永久有效的，客户端务必保证不要随意更新GID。
#define SNNewsLogin_PP_GID           @"SNNewsLogin_PP_GID"
#define SNNewsPPLogin_APPID          @"110607"
#define SNNewsPPLogin_APPKEY_Test    @"58n3IzFIpEWQnjBmZkT8"
#define SNNewsPPLogin_APPKEY_Online  @"WEtHkynRcXivUmNAJmntp01SI9fvLYqQAuAiOSflfl3FyTMuYd"

/**
 *   passport 接口文档 2017.11.15 wangshun
 *   http://wiki.sohu-inc.com/pages/viewpage.action?pageId=25156723
 */

@interface SNNewsPPLogin : NSObject

+ (void)mobileVcodeLogin:(NSDictionary*)params WithResult:(void (^)(NSDictionary* info))method;

+ (void)thirdLogin:(NSDictionary*)params WithResult:(void (^)(NSDictionary* info))method;

+ (void)sohuLogin:(NSDictionary*)params WithResult:(void (^)(NSDictionary* info))method;

+ (void)sendVcode:(NSDictionary*)params WithResult:(void (^)(NSDictionary* info))method;

+ (void)getPhotoVcode:(NSDictionary*)params WithSuccess:(void (^)(UIImage*))method;

+ (void)setCookie:(NSDictionary*)params WithResult:(void (^)(NSDictionary* info))method;

////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////

- (void)getGID:(void (^)(NSString*))method;
- (void)createCookie;

+ (NSString*)getUA;
+ (BOOL)isPPLoginValid;

+ (instancetype)sharedInstance;

@end
