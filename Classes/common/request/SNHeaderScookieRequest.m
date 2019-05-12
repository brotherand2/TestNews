//
//  SNHeaderScookieRequest.m
//  sohunews
//
//  Created by Valar__Morghulis on 11/05/2017.
//  Copyright © 2017 Sohu.com. All rights reserved.
//

#import "SNHeaderScookieRequest.h"
#import "SNClientRegister.h"

@implementation SNHeaderScookieRequest

#pragma mark - SNRequestProtocol

- (NSDictionary *)sn_requestHTTPHeader {
    NSString *scookie = [SNClientRegister sharedInstance].s_cookie;
    if (scookie && scookie.length > 0) {
        return @{@"SCOOKIE":scookie};
    } else {
        return nil;
    }
}

- (NSString *)sn_requestWithNewManager {
    return SNNet_Request_SCookieManager;
}



@end
