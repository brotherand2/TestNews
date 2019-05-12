//
//  SNPhotoChannelNewsRequest.m
//  sohunews
//
//  Created by Valar__Morghulis on 2017/3/21.
//  Copyright © 2017年 Sohu.com. All rights reserved.
//

#import "SNPhotoChannelNewsRequest.h"
#import "SNClientRegister.h"

@implementation SNPhotoChannelNewsRequest

#pragma mark SNRequestProtocol

- (SNRequestMethod)sn_requestMethod {
    return SNRequestMethodGet;
}

- (NSString *)sn_requestUrl {
    return SNLinks_Path_Photo_ListInChannel;
}


- (id)sn_parameters {
    
    [self.parametersDict setValue:@"json" forKey:@"rt"];
    NSString *appBuild = [[[NSBundle mainBundle] infoDictionary] objectForKey:kBundleBuild];
    [self.parametersDict setValue:appBuild forKey:@"buildCode"];
    
    return [super sn_parameters];
}
@end
