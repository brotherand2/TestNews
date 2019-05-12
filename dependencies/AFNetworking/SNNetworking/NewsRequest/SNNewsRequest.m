//
//  SNNewsRequest.m
//  TT_AllInOne
//
//  Created by tt on 15/6/2.
//  Copyright (c) 2015年 tt. All rights reserved.
//

#import "SNNewsRequest.h"
#import "SNNetworkConfiguration.h"
#import "SHAPI.h"
#import "SNUserManager.h"

@implementation SNNewsRequest

- (instancetype)init {
    if (self = [super init]) {
        NSAssert([self conformsToProtocol:@protocol(SNNewsRequestProtocol)], @"SNNewsRequestProtocol");
        _newsDelegate = (id<SNNewsRequestProtocol>)self;
    }
    return self;
}

#pragma mark SNRequestProtocol
- (NSString *)sn_baseUrl {
    return [SHAPI getBaseURL];
}

- (id)sn_buildInParameters {
    //TODO:改为真实参数
    //与sohu news相关的 所有URL都统一添加的一些参数
    /*NSMutableDictionary *buildInParameters = [@{} mutableCopy];
    buildInParameters[@"bid"] = [BundleInfo encodedBundleID];
    //@"Y29tLnNvaHUubmV3c3BhcGVyLmluaG91c2U=";
    buildInParameters[@"buildCode"] = [BundleInfo bundleBuild];
    buildInParameters[@"gid"] = [SNUserManager getGid];
    //@"010101110600018e198bc47712987763462220b00358b2";
    buildInParameters[@"u"] = [StorageUserDefault sharedInstance].productID;
    buildInParameters[@"pid"] = [SNUserManager getPid];
    buildInParameters[@"apiVersion"] = APIVersion;
    
    //不判断 respondsToSelector 子类不实现就会直接报错
    if ([self.newsDelegate sn_needP1]) {
        buildInParameters[@"p1"] = [StorageUserDefault sharedInstance].uid;
        //@"NTc3MjU3MjQxNjg0NDc2MzE2OQ==";
        //buildInParameters[@"pid"] = @"5971480099466686529";
        buildInParameters[@"sid"] = [StorageUserDefault sharedInstance].sid;
        //注掉是因为与第三方平台鉴权有冲突，该参数应该不是必要参数传递，如果需要传递可在自己的子类里实现。
        //buildInParameters[@"token"] = [StorageUserDefault sharedInstance].deviceToken;//@"c65f4b3a95792fc893786df2720f4283";
    }
    return buildInParameters;*/
    return nil;
}

- (BOOL)sn_checkResponse:(SNBaseRequest *)request
          responseObject:(id)responseObject {
    //不需要检查返回值
    if (![self.newsDelegate sn_needCheckResponse]) {
        return YES;
    }
    
    //需要返回值
    //TODO:统一业务判断
    if (responseObject) {
        return YES;
    } else {
        return NO;
    }
}

@end
