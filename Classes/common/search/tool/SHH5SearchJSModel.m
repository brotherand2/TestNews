
//
//  SHH5SearchJSModel.m
//  sohunews
//
//  Created by wangyy on 16/7/5.
//  Copyright © 2016年 Sohu.com. All rights reserved.
//

#import "SHH5SearchJSModel.h"

@implementation SHH5SearchJSModel

- (id)init {
    self = [super init];
    if (self) {
    }
    
    return self;
}

- (id)jsInterface_getSearchHotWord:(JsKitClient*)client {
    return [self.searchWebViewController jsGetSearchHotWord];
}

- (void)jsInterface_showLoadingView:(JsKitClient*)client {
}

- (void)jsInterface_setSearchWord:(JsKitClient*)client keywords:(NSString *)keywords {
    if ([NSThread isMainThread]) {
        [self.searchWebViewController jsSetSearchWord:keywords];
    } else {
        dispatch_async(dispatch_get_main_queue(), ^{
           [self.searchWebViewController jsSetSearchWord:keywords];
        });
    }
}
- (void)jsInterface_directSearch:(JsKitClient*)client key:(NSString *)key words:(NSString *)words{
    if ([NSThread isMainThread]) {
        [self.searchWebViewController directSearch:words];
    } else {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.searchWebViewController directSearch:words];
        });
    }
    
}

@end
