//
//  SNClientSpecialSkinRequest.m
//  sohunews
//
//  Created by 李腾 on 2017/1/23.
//  Copyright © 2017年 Sohu.com. All rights reserved.
//

#import "SNClientSpecialSkinRequest.h"
#import "SNUserManager.h"

@implementation SNClientSpecialSkinRequest

- (instancetype)initWithImageSize:(NSString *)imageSize
{
    self = [super init];
    if (self) {
        [self.parametersDict setValue:imageSize forKey:@"imgSize"];
    }
    return self;
}

#pragma mark - SNRequestProtocol

- (SNRequestMethod)sn_requestMethod {
    return SNRequestMethodPost;
}

- (NSString *)sn_requestUrl {
    return SNLinks_Path_Client_SpecialSkin;
}

- (id)sn_parameters {
    [self.parametersDict setValue:[SNUserManager getP1] forKey:@"p1"];
    return self.parametersDict;
}


@end
