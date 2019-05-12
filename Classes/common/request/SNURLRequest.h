//
//  SNURLRequest.h
//  sohunews
//
//  Created by kuanxi zhu on 8/9/11.
//  Copyright 2011 Sohu.com Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SNNotificationCenter.h"

@class SNURLRequest;
typedef void(^SNURLRequestSuccessAction)(SNURLRequest *request);
typedef void(^SNURLRequestFailureAction)(SNURLRequest *request, NSError *error);

//所有接口请求的基类，负责添加p1参数，scookie，默认缓存查询结果60秒。
//p1:用户id的一个编码串
//scookie:本机的基本信息，见 http://10.11.29.82/wiki/Wiki.jsp?page=V2.1#section-V2.1-_E4_BA_8CSCOOKIE

@interface SNURLRequest : TTURLRequest<TTURLRequestDelegate> {
	BOOL _isShowNoNetWorkMessage;
    BOOL _isCancelled;
    BOOL _isParamP;
    NSOutputStream *_outputStream;
    NSString *_baseUrl;
}

@property (nonatomic, assign) BOOL isShowNoNetWorkMessage;
@property (nonatomic, assign) BOOL isCancelled;
@property (nonatomic, copy) NSString *baseUrl;

- (id)initWithURL:(NSString*)URL baseUrl:(NSString *)baseUrl delegate:(id)delegate isParamP:(BOOL)paramP;
- (id)initWithURL:(NSString*)URL baseUrl:(NSString *)baseUrl delegate:(id)delegate isParamP:(BOOL)paramP scookie:(BOOL)bCookie;

+ (SNURLRequest *)requestWithURL:(NSString*)URL delegate:(id)delegate;
+ (SNURLRequest *)requestWithURL:(NSString*)URL delegate:(id)delegate isParamP:(BOOL)paramP;
+ (SNURLRequest *)requestWithURL:(NSString*)URL delegate:(id)delegate isParamP:(BOOL)paramP scookie:(BOOL)bCookie;
+ (SNURLRequest *)requestWithURL:(NSString*)URL delegate:(id)delegate isParamP:(BOOL)paramP scookie:(BOOL)bCookie defaultP1:(BOOL)defaultP1;
+ (SNURLRequest *)requestWithURL:(NSString*)URL delegate:(id)delegate isParamP:(BOOL)paramP scookie:(BOOL)bCookie isV6:(BOOL)isV6;

// 便利方法
- (BOOL)sendWithScuccessAction:(SNURLRequestSuccessAction)successAction failAction:(SNURLRequestFailureAction)failAction;

- (void)setUrlPath:(NSString *)urlPath isV6:(BOOL)isV6;

@end
