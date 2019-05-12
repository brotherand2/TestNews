//
//  SNArticleRecomReuqest.m
//  sohunews
//
//  Created by ___TENG LI___ on 2017/2/28.
//  Copyright © 2017年 Sohu.com. All rights reserved.
//

#import "SNArticleRecomReuqest.h"

@implementation SNArticleRecomReuqest

#pragma mark - SNRequestProtocol

- (SNRequestMethod)sn_requestMethod {
    return SNRequestMethodGet;
}

- (NSString *)sn_requestUrl {
    return SNLinks_Path_News_RecomNews;
}

- (id)sn_parameters {
    // galleryDo=channel ,showSdkAd=1
    [self.parametersDict setValue:@"channel" forKey:@"galleryDo"];
    [self.parametersDict setValue:@"1" forKey:@"showSdkAd"];
    self.needCurrentNetStatusParam = YES;
    
    return [super sn_parameters];
}


@end
