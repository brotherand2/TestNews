//
//  SNNewsGrabAuthority.m
//  sohunews
//
//  Created by TengLi on 2017/10/10.
//  Copyright © 2017年 Sohu.com. All rights reserved.
//

#import "SNNewsGrabAuthority.h"
#import "SNUserManager.h"

@implementation SNNewsGrabAuthority

+ (void)newsGrabAuthority {
    if (![SNUserManager isLogin]) return;
    NSString *p1 = [[[NSUserDefaults alloc] initWithSuiteName:kTodaynewswidgetGroup] objectForKey:kTodaynewswidgetP1];
    if (!p1 || p1.length <= 0) {
        [[[NSUserDefaults alloc] initWithSuiteName:kTodaynewswidgetGroup] setObject:[SNUserManager getP1] forKey:kTodaynewswidgetP1];
    }
    [[[self alloc] init] send:^(SNBaseRequest *request, id responseObject) {
        if (responseObject && [responseObject isKindOfClass: [NSDictionary class]]) {
            NSDictionary *dict = (NSDictionary *)responseObject;
            if ([[dict stringValueForKey:@"isSuccess" defaultValue:nil] isEqualToString:@"S"]) {
                if ([[dict stringValueForKey:@"response" defaultValue:nil] isEqualToString:@"1"]) {
                    [[[NSUserDefaults alloc] initWithSuiteName:kTodaynewswidgetGroup] setBool:YES forKey:kNewsGrabAuthority];
                }
            } else if ([[dict stringValueForKey:@"isSuccess" defaultValue:nil] isEqualToString:@"F"]) {
                if ([[dict stringValueForKey:@"error" defaultValue:nil] isEqualToString:@"0"]) {
                    [[[NSUserDefaults alloc] initWithSuiteName:kTodaynewswidgetGroup] setBool:NO forKey:kNewsGrabAuthority];
                }
            }
        }
    } failure:^(SNBaseRequest *request, NSError *error) {
        
    }];
}

#pragma mark - SNRequestProtocol

- (SNRequestMethod)sn_requestMethod {
    return SNRequestMethodGet;
}

//- (NSString *)sn_customUrl {
//    return [NSString stringWithFormat:@"http://onlinetestapi.k.sohu.com/%@",SNLinks_Path_NewsGrab_Authority];
//}

- (NSString *)sn_requestUrl {
    return SNLinks_Path_NewsGrab_Authority;
}

- (id)sn_parameters {
    if ([SNUserManager isLogin]) {
        [self.parametersDict setValue:[SNUserManager getPid] forKey:@"pid"];
    }
    [self.parametersDict setValue:[SNUserManager getP1] forKey:@"p1"];
    return self.parametersDict;
}
@end
