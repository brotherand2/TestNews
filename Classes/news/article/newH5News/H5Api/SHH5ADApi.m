//
//  SHH5ADApi.m
//  LiteSohuNews
//
//  Created by lijian on 16/1/6.
//  Copyright © 2016年 Sohu.com. All rights reserved.
//

#import "SHH5ADApi.h"
#import "SHADManager.h"

@implementation SHH5ADApi
+ (id)shareInstance
{
    static id instance = nil;
    static dispatch_once_t pred;
    
    dispatch_once(&pred, ^{
        instance = [[[self class] alloc] init];
    });
    
    return instance;
}

- (id)jsInterface_adArticle:(JsKitClient*)client itemspaceid:(NSString *)itemspaceid
{
    if (itemspaceid && [itemspaceid isKindOfClass:[NSString class]] && itemspaceid.length > 0) {
        if ([itemspaceid isEqualToString:@"12434"] || [itemspaceid isEqualToString:@"12791"]) { //5.9.0屏蔽正文页冠名相关请求
            return nil;
        }
        if ([SHADManager sharedManager].articleAdDic[itemspaceid]) {
            return [SHADManager sharedManager].articleAdDic[itemspaceid];
        } else {
            [[SHADManager sharedManager]setAdJsClient:client];
            [[SHADManager sharedManager].itemspaceidArr addObject:itemspaceid];
        }
    }
    return nil;
}

- (void)jsInterface_adArticleClick:(JsKitClient*)client itemspaceid:(NSString *)itemspaceid
{
    if (itemspaceid && [itemspaceid isKindOfClass:[NSString class]]) {
        [[SHADManager sharedManager] reportForAdClickTrackingWithItemSpaceID:itemspaceid];
    }
}

- (void)jsInterface_adArticleShow:(JsKitClient*)client itemspaceid:(NSString *)itemspaceid
{
    if (itemspaceid && [itemspaceid isKindOfClass:[NSString class]]) {
        [[SHADManager sharedManager] reportForAdImpTrackingWithItemSpaceID:itemspaceid];
    }
}

- (void)jsInterface_adArticleClose:(JsKitClient*)client itemspaceid:(NSString *)itemspaceid
{
    if (itemspaceid && [itemspaceid isKindOfClass:[NSString class]]) {
        [[SHADManager sharedManager] reportForAdCloseTrackingWithItemSpaceID:itemspaceid];
    }
}

@end
