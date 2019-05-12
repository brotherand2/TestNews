//
//  SNNewsPPLoginCookie.h
//  sohunews
//
//  Created by wang shun on 2017/11/21.
//  Copyright © 2017年 Sohu.com. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface SNNewsPPLoginCookie : NSObject

@property (nonatomic,strong) NSDictionary* data;

@property (nonatomic,strong) NSString* passsport;
@property (nonatomic,strong) NSString* ppinf;
@property (nonatomic,strong) NSString* pprdig;
@property (nonatomic,strong) NSString* ppsmu;
@property (nonatomic,strong) NSString* spinfo;
@property (nonatomic,strong) NSString* spsession;

@property (nonatomic,strong) NSString* pp_GID;
@property (nonatomic,strong) NSString* pp_token;

- (void)setCookieData:(NSDictionary*)data;


+ (void)deleteCookie;
+ (void)saveArchive:(SNNewsPPLoginCookie*)cookie;
+ (void)readArchive;

@end


/*
 *
 2017-11-21 18:46:51.134490+0800 sohunews[1400:462228] responseObject:{
 data =     {
 passport = "w1269188410@sohu.com";
 ppinf = "2|1511261211|1512470811|bG9naW5pZDowOnx1c2VyaWQ6MjA6dzEyNjkxODg0MTBAc29odS5jb218c2VydmljZXVzZTozMDowMDAwMDAwMDAwMDAwMDAwMDAwMDAwMDAwMDAwMDB8Y3J0OjEwOjIwMTctMTEtMjF8ZW10OjE6MHxhcHBpZDo2OjExMDYwN3x0cnVzdDoxOjF8cGFydG5lcmlkOjE6MHxyZWxhdGlvbjowOnx1dWlkOjA6fHVpZDowOnx1bmlxbmFtZTowOnw";
 pprdig = "knGRrV9xYrvT1SoGcbJcbHn9a0RZBVHOoQIVVq_PGUhYuDWXe3InGaDK__BcbkudX0XId3ZH23WkFZX9BM-emJcJXxettAYWTyFYmxJyEkZf2NCsJMPQpKzV7ZP0o352nJOuDYtrNk_6gnu5XNN6FUamqqyw6KCovSwMLJWrL44";
 ppsmu = "1|1511261211|1512470811|dXNlcmlkOjIwOncxMjY5MTg4NDEwQHNvaHUuY29tfHVpZDowOnx1dWlkOjA6|IHoC_EEc0FidGS5rODxnzzCqyNNFL85v4dwvTiOsmSwp911OKf3Vxt8C2AEB7sSRwoQKxXHU_J_Finw0pkZ_ig";
 spinfo = "";
 spsession = "";
 };
 message = ok;
 status = 200;
 }
 */
