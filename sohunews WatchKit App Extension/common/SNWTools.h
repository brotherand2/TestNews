//
//  SNWTools.h
//  sohunews
//
//  Created by H on 15/12/8.
//  Copyright © 2015年 Sohu.com. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SNWDefine.h"


@interface SNWTools : NSObject

/**
 *  更新app信息，p1，rootUrl（测试服 or 正式服）等
 *
 *  @param appInfo : 从 WCSession 获得的appInfo
 */
+ (void)updateAppInfoWith:(NSDictionary *)appInfo;

/**
 *  拼接URL
 *
 *  @param url 传入参数URL
 *
 *  @return 拼接好host的URL
 */
+ (NSString *)rootUrl:(NSString *)url;

/**
 *  获取p1
 *
 *  @return p1字符串
 */
+ (NSString *)getP1;

/**
 *  watch 从服务器请求数据
 *
 *  @param requestType 请求类型（获取列表，获取图片，加载更多）
 *  @param reply       服务端返回的response data
 *  @param url         url
 *
 *  @return 获取数据是否成功
 */
+ (void)getDataFromServerWithType:(RequestType)requestType Url:(NSString *)url Reply:(void(^)(NSDictionary *replyInfo, NSError *error))reply;

/**
 *  获取glance 首页第一条新闻
 *
 *  @return
 */
+ (void )getTopNews:(void(^)(NSDictionary *topNews))reply;



@end
