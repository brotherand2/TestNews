//
//  SHH5ADApi.h
//  LiteSohuNews
//
//  Created by lijian on 16/1/6.
//  Copyright © 2016年 Sohu.com. All rights reserved.
//

#import <Foundation/Foundation.h>
//#import "JsKitFramework.h"
#import <JsKitFramework/JsKitFramework.h>

@interface SHH5ADApi : NSObject
+ (id)shareInstance;

//获取正文广告物料
- (id)jsInterface_adArticle:(JsKitClient*)client itemspaceid:(NSString *)itemspaceid;
//正文广告点击上报
- (void)jsInterface_adArticleClick:(JsKitClient*)client itemspaceid:(NSString *)itemspaceid;
//正文广告曝光上报
- (void)jsInterface_adArticleShow:(JsKitClient*)client itemspaceid:(NSString *)itemspaceid;
//正文页插入广告关闭上报
- (void)jsInterface_adArticleClose:(JsKitClient*)client itemspaceid:(NSString *)itemspaceid;

@end
