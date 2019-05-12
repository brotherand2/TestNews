//
//  SNNewsPPLoginCookie.m
//  sohunews
//
//  Created by wang shun on 2017/11/21.
//  Copyright © 2017年 Sohu.com. All rights reserved.
//

#import "SNNewsPPLoginCookie.h"
#import "SNNewsPPLogin.h"

@implementation SNNewsPPLoginCookie

- (void)setCookieData:(NSDictionary*)data{
    
    NSString* passport  = [data objectForKey:@"passport"];
    NSString* ppinf     = [data objectForKey:@"ppinf"];
    NSString* pprdig    = [data objectForKey:@"pprdig"];
    NSString* ppsmu     = [data objectForKey:@"ppsmu"];
    NSString* spinfo    = [data objectForKey:@"spinfo"];
    NSString* spsession = [data objectForKey:@"spsession"];
    
    self.passsport = passport;
    self.ppinf = ppinf;
    self.pprdig = pprdig;
    self.ppsmu = ppsmu;
    self.spinfo = spinfo;
    self.spsession = spsession;
    
    [self setCookie];
}

- (void)setCookie{
    
    [self setCookieForDomain:@".sohu.com"];
    
    SNDebugLog(@"NSHTTPCookieStorage::::%@",[NSHTTPCookieStorage sharedHTTPCookieStorage].cookies);
    
    if ([NSHTTPCookieStorage sharedHTTPCookieStorage].cookies.count>0) {
        [SNNewsPPLoginCookie saveArchive:self];
    }
}

- (void)setCookieForDomain:(NSString*)domain{
    if (!domain) {
        return;
    }
    for (int i=0; i<5; i++) {
        
        NSMutableDictionary *cookieProperties = [NSMutableDictionary dictionary];
        NSString* key   = nil;
        NSString* value = nil;
        if (i == 0) {
            key   = @"ppinf";
            value = self.ppinf?:@"";
        }
        else if (i==1){
            key   = @"pprdig";
            value = self.pprdig?:@"";
        }
        else if (i==2){
            key   = @"ppsmu";
            value = self.ppsmu?:@"";
        }
        else if (i==3){
            key   = @"token";
            value = self.pp_token?:@"";
        }
        else if (i==4){
            key   = @"gid";
            value = self.pp_GID?:@"";
        }
        
        [cookieProperties setObject:key forKey:NSHTTPCookieName];
        [cookieProperties setObject:value forKey:NSHTTPCookieValue];
        [cookieProperties setObject:domain forKey:NSHTTPCookieDomain];
        [cookieProperties setObject:@"/" forKey:NSHTTPCookiePath];
        
        NSString* appVerison = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"];
        [cookieProperties setObject:appVerison forKey:NSHTTPCookieVersion];
        
        [cookieProperties setObject:[[NSDate date] dateByAddingTimeInterval:24*60*60] forKey:NSHTTPCookieExpires];
        
        NSHTTPCookie *cookieuser = [[NSHTTPCookie alloc] initWithProperties:cookieProperties];
        [[NSHTTPCookieStorage sharedHTTPCookieStorage] setCookie:cookieuser];
    }
}

//清除cookie
+ (void)deleteCookie{
    NSArray *cookiesArray = [[NSHTTPCookieStorage sharedHTTPCookieStorage] cookies];
    for (NSHTTPCookie *cookie in cookiesArray) {
        [[NSHTTPCookieStorage sharedHTTPCookieStorage] deleteCookie:cookie];
    }
    
    NSString* path = [SNNewsPPLoginCookie archivePath];
    [[NSFileManager defaultManager] removeItemAtPath:path error:nil];
}

+ (void)saveArchive:(SNNewsPPLoginCookie*)cookie{
    NSString* path = [SNNewsPPLoginCookie archivePath];
    [NSKeyedArchiver archiveRootObject:cookie toFile:path];
}

+ (void)readArchive{
    NSString* path = [SNNewsPPLoginCookie archivePath];
    
    if ([[NSFileManager defaultManager] fileExistsAtPath:path]) {
        SNNewsPPLoginCookie* u = [NSKeyedUnarchiver unarchiveObjectWithFile:path];
        [u setCookie];
    }
    else{
        SNUserinfoEx* userInfo = [SNUserinfoEx userinfoEx];
        if ([userInfo.ppLoginFlag isEqualToString:@"1"]) {//当前登录如果是新登录
            NSString* pp_gid = [[NSUserDefaults standardUserDefaults] objectForKey:SNNewsLogin_PP_GID];
            if (pp_gid) {
                [SNNewsPPLogin setCookie:@{@"PP-GID":pp_gid} WithResult:^(NSDictionary *info) {
                    
                }];
            }
        }
    }
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder{
    if (self = [super init]) {
        NSString* passport  = [aDecoder decodeObjectForKey:@"passport"];
        NSString* ppinf     = [aDecoder decodeObjectForKey:@"ppinf"];
        NSString* pprdig    = [aDecoder decodeObjectForKey:@"pprdig"];
        NSString* ppsmu     = [aDecoder decodeObjectForKey:@"ppsmu"];
        NSString* spinfo    = [aDecoder decodeObjectForKey:@"spinfo"];
        NSString* spsession = [aDecoder decodeObjectForKey:@"spsession"];
        
        self.passsport = passport;
        self.ppinf = ppinf;
        self.pprdig = pprdig;
        self.ppsmu = ppsmu;
        self.spinfo = spinfo;
        self.spsession = spsession;
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder{
    
    [aCoder encodeObject:self.passsport forKey:@"passsport"];
    [aCoder encodeObject:self.ppinf forKey:@"ppinf"];
    [aCoder encodeObject:self.pprdig forKey:@"pprdig"];
    [aCoder encodeObject:self.ppsmu forKey:@"ppsmu"];
    [aCoder encodeObject:self.spinfo forKey:@"spinfo"];
    [aCoder encodeObject:self.spsession forKey:@"spsession"];
}

+ (NSString*)archivePath{
    NSString* path = [NSHomeDirectory() stringByAppendingPathComponent:@"Library/PPLoginCookie.archiver"];
    NSLog(@"PPLoginCookie.archiver path:::%@",path);
    return path;
}

@end
