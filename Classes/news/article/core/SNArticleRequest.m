//
//  SNRollingArticleRequest.m
//  sohunews
//
//  Created by 李腾 on 2017/2/7.
//  Copyright © 2017年 Sohu.com. All rights reserved.
//

#import "SNArticleRequest.h"

#define kImgSize				(3)//大图
#define kRecommendNewsCount     (3)

@interface SNArticleRequest ()

@property (nonatomic, copy) NSString *newsId;
@property (nonatomic, copy) NSString *termId;
@property (nonatomic, copy) NSString *channelId;
@property (nonatomic, strong) NSDictionary *CDNParams;
@property (nonatomic, strong) NSDictionary *articleParams;
@property (nonatomic, assign) BOOL isCDNUrl;

@end

@implementation SNArticleRequest

/**
 初始化方法

 @param newsId    newsId
 @param channelId ChannelId
 @param param     CDNLinkParams
 @return request
 */
- (instancetype)initWithNewsId:(NSString *)newsId
                     channelId:(NSString *)channelId
                  andCDNParams:(NSDictionary *)CDNParams
{
    self = [super init];
    if (self) {
        _newsId = newsId;
        _channelId = channelId;
        _CDNParams = CDNParams;
    }
    return self;
}

/**
 初始化方法

 @param newsId newsId
 @param termId termId
 @param CDNParams CDNParams
 @param articleParams articleParams(acticle.go 需传的参数)
 @return request
 */
- (instancetype)initWithNewsId:(NSString *)newsId
                        termId:(NSString *)termId
                     CDNParams:(NSDictionary *)CDNParams
              andArticleParams:(NSDictionary *)articleParams
{
    self = [super init];
    if (self) {
        _newsId = newsId;
        _termId = termId;
        _CDNParams = CDNParams;
        _articleParams = articleParams;
    }
    return self;
}


#pragma mark - SNRequestProtocol

- (SNRequestMethod)sn_requestMethod {
    return SNRequestMethodGet;
}


- (NSString *)sn_customUrl {
    NSString *url = nil;
    if (self.CDNParams.count > 0 && (url = [self.CDNParams stringValueForKey:kCDNUrl defaultValue:nil]) && url.length > 0) {
        self.isCDNUrl = YES;
        url = [url URLDecodedString];
    } else {
        self.isCDNUrl = NO;
        url = [NSString stringWithFormat:@"%@%@",[SNAPI baseUrlWithDomain:SNLinks_Domain_BaseApiK],SNLinks_Path_News_Article];
    }
    return url;
}


//?rt=xml&newsId=%@&channelId=%@&supportTV=1&imgTag=1&recommendNum=%d&showSdkAd=1
- (id)sn_parameters {
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithCapacity:10]; // 默认参数
    if (!self.isCDNUrl) {
        
//        [params setValue:@"json" forKey:@"rt"]; // 之前传入的是XML，请求回来的数据解析出错，文章并未缓存。
        [params setValue:self.newsId forKey:@"newsId"];
        if (self.channelId.length > 0) {
            [params setValue:self.channelId forKey:@"channelId"];
        }
        if (self.termId.length > 0) {
            [params setValue:self.termId forKey:@"termId"];
        }
        [params setValue:@"1" forKey:@"supportTV"];
        [params setValue:@"1" forKey:@"imgTag"];
        [params setValue:[NSString stringWithFormat:@"%zd",kRecommendNewsCount] forKey:@"recommendNum"];
        [params setValue:@"1" forKey:@"showSdkAd"];
        [params setValue:@"5" forKey:@"platformId"];
        if (self.CDNParams.count > 0) {
            [self.CDNParams enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
                if ([key isKindOfClass:[NSString class]] && ![params objectForKey:key] && ![key isEqualToString:kOpenProtocolOriginalLink2]) {
                    [params setValue:obj forKey:key];
                }
            }];
        }
        if (self.articleParams.count > 0) {
            [params setValuesForKeysWithDictionary:self.articleParams];
        }
    } 
    NSString *appBuild = [[[NSBundle mainBundle] infoDictionary] objectForKey:kBundleBuild];
    [params setValue:appBuild forKey:@"buildCode"];
   
    [self.parametersDict setValuesForKeysWithDictionary:params];
    
    return [super sn_parameters];
}
@end
