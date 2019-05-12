//
//  SNGalleryRequest.m
//  sohunews
//
//  Created by HuangZhen on 22/02/2017.
//  Copyright © 2017 Sohu.com. All rights reserved.
//

#import "SNGalleryRequest.h"
#import "SNUserManager.h"

@implementation SNGalleryRequest
#pragma mark - SNRequestProtocol

- (SNRequestMethod)sn_requestMethod {
    return SNRequestMethodGet;
}

- (SNResponseType)sn_responseType {
    return SNResponseTypeJSON;
}

- (NSString *)sn_customUrl {
    return [SNAPI rootUrl:@"api/photos/gallery.go"];
    /*
     http://testapi.k.sohu.com/api/photos/gallery.go?channelId=47&apiVersion=37&from=channel&fromId=null&gid=53692&openType=&p1=NjE5MjUzMjM1NTA1Njg0MDgxOA%3D%3D&pid=-1&u=1&refer=3&rt=json&showSdkAd=1&supportTV=1&moreCount=8&articleDebug=0&_=1487236746825
     */
}

- (id)sn_parameters {
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithCapacity:20]; // 默认参数
    
    [params setValue:@"8" forKey:@"moreCount"];
    //
//    [params setValue:@"47" forKey:@"channelId"];
    [params setValue:self.channelId forKey:@"channelId"];
    [params setValue:[SNUserManager getP1] forKey:@"p1"];
    [params setValue:[NSString stringWithFormat:@"%d", APIVersion] forKey:@"apiVersion"];
    //
    [params setValue:@"channel" forKey:@"from"];
    //
    [params setValue:self.gid?:@"" forKey:@"gid"];
    [params setValue:self.newsId?:@"" forKey:@"newsId"];
    //
    [params setValue:@"3" forKey:@"refer"];
    NSString *pid = [SNUserManager getPid];
    [params setValue:pid?pid:@"-1" forKey:@"pid"];
    [params setValue:[SNAPI productId] forKey:@"u"];
    [params setValue:@"json" forKey:@"rt"];
    [params setValue:@"1" forKey:@"showSdkAd"];
    [params setValue:@"1" forKey:@"supportTV"];
    [params setValue:@"0" forKey:@"articleDebug"];

    [params setValue:[SNAPI encodedBundleID] forKey:@"bid"];
    
    return params;
}

@end
