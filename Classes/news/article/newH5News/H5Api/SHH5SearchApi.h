//
//  SHH5SearchApi.h
//  sohunews
//
//  Created by Scarlett on 16/4/12.
//  Copyright © 2016年 Sohu.com. All rights reserved.
//

#import <Foundation/Foundation.h>
//#import "JsKitFramework.h"
#import <JsKitFramework/JsKitFramework.h>

@interface SHH5SearchApi : NSObject

@property (nonatomic, weak)id delegate;

- (id)jsInterface_getSearchHotWord:(JsKitClient*)client;
- (void)jsInterface_showLoadingView:(JsKitClient*)client;
- (void)jsInterface_setSearchWord:(JsKitClient*)client keywords:(NSString *)keywords;
- (void)jsInterface_directSearch:(JsKitClient*)client keywords:(NSString *)keywords;


@end
