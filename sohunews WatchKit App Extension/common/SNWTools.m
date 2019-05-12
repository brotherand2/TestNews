//
//  SNWTools.m
//  sohunews
//
//  Created by H on 15/12/8.
//  Copyright © 2015年 Sohu.com. All rights reserved.
//

#import "SNWTools.h"
#import "SNWCache.h"
#import "WatchSessionManager.h"

static NSString *p1 = nil;
static NSString *rootUrl = nil;
static NSInteger pageNum = 1;

@implementation SNWTools

+ (void)updateAppInfoWith:(NSDictionary *)appInfo {
    p1      = appInfo[@"p1"] ? : @"";
    rootUrl = appInfo[@"rootUrl"] ? : @"";
    [[SNWCache sharedInstance] cachedAppInfo:appInfo];
}


/**
 *  拼接URL
 *
 *  @param url 传入参数URL
 *
 *  @return 拼接好host的URL
 */
+ (NSString *)rootUrl:(NSString *)url{
    if (rootUrl == nil) {
        NSString *hostString = @"http://api.k.sohu.com";
        
        NSString *httpsSwitch = [[NSUserDefaults standardUserDefaults] valueForKey:@"kHttpsSwitchStatusKey1"];
        BOOL isSmallSwitch = NO;
        if(httpsSwitch && [httpsSwitch length] > 0){
            isSmallSwitch = [httpsSwitch boolValue];
        }
        if (isSmallSwitch) {
            hostString = @"https://api.k.sohu.com";
        }
        
        NSDictionary * appInfo = [[SNWCache sharedInstance] getAppInfoFromCache];
        rootUrl = appInfo[@"rootUrl"] ? : hostString;//默认使用正式服务器
    }
    return [rootUrl stringByAppendingString:url];
}

/**
 *  watch 从服务器请求数据
 */
+ (void)getDataFromServerWithType:(RequestType)requestType Url:(NSString *)url Reply:(void(^)(NSDictionary *replyInfo, NSError *error))reply {

    switch(requestType){
        case RequestType_getList:
        {
            [SNWTools getNewsList:^(NSDictionary *replyInfo, NSError *error) {
                reply(replyInfo,error);
            }];
        }
        break;
        case RequestType_getImage:
        {
            [SNWTools getImageWithUrl:url Reply:^(NSDictionary *replyInfo, NSError *error) {
                reply(replyInfo,error);
            }];
        }
            break;
        case RequestType_loadMore:
        {
            [SNWTools loadMore:^(NSDictionary *replyInfo, NSError *error) {
                reply(replyInfo,error);
            }];
        }
            break;

    
    }
}

/**
 *  获取新闻列表
 *
 *  @param reply 返回数据
 *
 *  @return 是否成功
 */
+ (void)getNewsList:(void(^)(NSDictionary *replyInfo, NSError *error))reply {
    
    /**
     *  @param @"1" 第一页
     *  @param @"5" 5条数据
     *  @param @"1" from
     *  @param @"1" 图片scale
     *  @param @""  p1
     *  @"http://api.k.sohu.com/api/channel/push.go?page=1&num=5&from=1&picScale=1&p1=";
     */
    NSString *requestUrl = snw_push_list_url_extension(@"1", @"5", @"1", @"1", p1);
    
    pageNum = 2;
    
    NSURLSession * urlSession = [NSURLSession sharedSession];
    NSURLRequest * request = [NSURLRequest requestWithURL:[NSURL URLWithString:requestUrl]];
    [[urlSession dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        NSDictionary * replyDic = nil;
        if (data) {
            replyDic = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:&error];
        }
        reply(replyDic,error);
    }] resume];

}

/**
 *  加载更更多
 *
 *  @param reply 返回数据
 *
 *  @return 是否成功
 */
+ (void)loadMore:(void(^)(NSDictionary *replyInfo, NSError *error))reply {
    
    
    NSString *page = [NSString stringWithFormat:@"%d",pageNum];
    
    /**
     *  @param @"1" 第几页
     *  @param @"5" 5条数据
     *  @param @"1" from
     *  @param @"1" 图片scale
     *  @param @"p1"  p1
     */
    NSString *requestUrl = snw_push_list_url_extension(page, @"5", @"1", @"1", p1);
    pageNum ++;

    NSURLSession * urlSession = [NSURLSession sharedSession];
    NSURLRequest * request = [NSURLRequest requestWithURL:[NSURL URLWithString:requestUrl]];
    [[urlSession dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        NSDictionary * replyDic = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:&error];
        if (replyDic) {
        }
        reply(replyDic,error);
    }] resume];
}

/**
 *  下载图片
 *
 *  @param url   图片链接
 *  @param reply 返回数据
 *
 *  @return 是否成功
 */
+ (void)getImageWithUrl:(NSString *)url Reply:(void(^)(NSDictionary *replyInfo,NSError *error))reply {
    if (url.length == 0) {
        return;
    }
    NSURLSession * urlSession = [NSURLSession sharedSession];
    NSMutableURLRequest * request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:url] cachePolicy:NSURLRequestReturnCacheDataElseLoad timeoutInterval:5];
    request.HTTPShouldHandleCookies = YES;
    request.HTTPShouldUsePipelining = YES;

    [[urlSession dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        if (data) {
            reply(@{@"data":data},error);
        }
        
    }] resume];
    
}

+ (NSString *)getP1 {

    if (nil == p1) {
       NSDictionary *appInfo = [[SNWCache sharedInstance] getAppInfoFromCache];
        p1 = appInfo[@"p1"] ? : @"";
    }
    
    return p1;
}

+(void)getTopNews:(void (^)(NSDictionary *))reply {
   
    NSString *requestUrl = snw_push_list_url_extension(@"1", @"1", @"1", @"1", p1);
    
    NSURLSession * urlSession = [NSURLSession sharedSession];
    NSURLRequest * request = [NSURLRequest requestWithURL:[NSURL URLWithString:requestUrl]];
    [[urlSession dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        NSDictionary * replyDic = nil;
        if (data) {
            replyDic = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:&error];
        }
        reply(replyDic);
    }] resume];
}

@end
