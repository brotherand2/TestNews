//
//  SNPhotoGalleryRequest.m
//  sohunews
//
//  Created by 李腾 on 2017/2/16.
//  Copyright © 2017年 Sohu.com. All rights reserved.
//

#import "SNPhotoGalleryRequest.h"

@implementation SNPhotoGalleryRequest

#pragma mark - SNRequestProtocol

- (SNRequestMethod)sn_requestMethod {
    return SNRequestMethodGet;
}

- (NSString *)sn_requestUrl {
    return SNLinks_Path_Photo_Gallery;
}

- (id)sn_parameters {
    
    [self.parametersDict setValue:@"json" forKey:@"rt"];
    [self.parametersDict setValue:@"1" forKey:@"showSdkAd"];
    
    return [super sn_parameters];
}

@end
