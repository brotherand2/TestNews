//
//  SNTodayWidgetNewsService.m
//  WidgetApp
//
//  Created by WongHandy on 8/4/14.
//  Copyright (c) 2014 WongHandy. All rights reserved.
//

#import "SNTodayWidgetNewsService.h"
#import "SNTodayWidgetNews.h"
#import "SNTodayWidgetConst.h"
#import "AFNetworking.h"
#import "SNDebug.h"
//#import "SNUserLocationManager.h"
#define kRollingNewsListURL @"https://api.k.sohu.com/api/channel/v4/news.go?channelId=%@&num=%d&page=%d&picScale=2&groupPic=1&supportTV=1&imgTag=1&supportSpecial=1&supportLive=1&showSdkAd=1&rt=json"
#define kRollingNewsListHttpsURL @"https://api.k.sohu.com/api/channel/v4/news.go?channelId=%@&num=%d&page=%d&picScale=2&groupPic=1&supportTV=1&imgTag=1&supportSpecial=1&supportLive=1&showSdkAd=1&rt=json"
#define kWidgetNewsListCacheFileName    (@"widget_newslist.cache")

#define kNewsGrabURL @"http://api.k.sohu.com/api/news/grab/process.go"

@interface SNTodayWidgetNewsService() {
    AFHTTPRequestOperation *_request;
}
@end

@implementation SNTodayWidgetNewsService

- (void)requestFromLocalAsynchrously {
    [self getCacheWidgetNewsList];
}

- (void)requestFromServerAsynchrously {
//    NSString *kNewsListURL = @"http://api.k.sohu.com/api/channel/v4/news.go?channelId=1&num=30&page=1&picScale=2&groupPic=1&supportTV=1&imgTag=1&supportSpecial=1&supportLive=1&showSdkAd=1&rt=json&from=channel&pull=0&cdma_lng=116.331878&cdma_lat=39.997496&net=wifi&p1=MTU2Nzc5NzI=&pid=-1&apiVersion=23&sid=10&u=1";
    
    NSString *stringUrl = kRollingNewsListURL;
    NSString *httpsSwitch = [[NSUserDefaults standardUserDefaults] valueForKey:@"kHttpsSwitchStatusKey1"];
    BOOL isSmallSwitch = NO;
    if(httpsSwitch && [httpsSwitch length] > 0){
        isSmallSwitch = [httpsSwitch boolValue];
    }
    if (isSmallSwitch) {
        stringUrl = kRollingNewsListHttpsURL;
    }
    
    NSString *kNewsListURL = [NSString stringWithFormat:stringUrl, @"1", 3, 1];
    kNewsListURL = [self addAllParametersWithUrl:kNewsListURL];
    
    __weak typeof(self) bself = self;
    AFHTTPRequestOperationManager *requestManager = [AFHTTPRequestOperationManager manager];
    _request = [requestManager GET:kNewsListURL parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
                    SNDebugLog(@"Response data is %@", responseObject);
                    NSArray *newsList = [bself parseNewsList:responseObject];
                    if (newsList.count > 0) {
                        [bself cacheWidgetNewsList:responseObject];
                        if ([_delegate respondsToSelector:@selector(didFinishWithNewsList:)]) {
                            [_delegate didFinishWithNewsList:newsList];
                        }
                    }
                } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                    if ([_delegate respondsToSelector:@selector(didFailedWithError:)]) {
                        [_delegate didFailedWithError:error];
                    }
                }];
}

- (void)cancel {
    [_request cancel];
    [_request setCompletionBlockWithSuccess:nil failure:nil];
    _request = nil;
    _delegate = nil;
}

- (void)dealloc {
    [self cancel];
}

#pragma mark - Private
- (NSString *)addAllParametersWithUrl:(NSString *) url {
    //来源
    NSString *fromString = @"todaywidget";
    url = [url stringByAppendingFormat:@"&from=%@", fromString];
    //加载编辑流
    url = [url stringByAppendingFormat:@"&pull=0"];
    //Location
    
    // comment by Cae.
    // widget这里获取地理位置的方法是有问题的。应该从UserLocationManager里获取，而不是读取存储的数据。 现在这里就没存数据，获取了也没用，等效于就是nil
    // 根据现有的代码，修改获取方式
    // 这里改了之后编译不过了，回头再来处理编译问题，先注释掉
    NSString *locationString = nil;//[SNUserLocationManager sharedInstance].getLocationString;//[[NSUserDefaults standardUserDefaults] objectForKey:@"kNewsChannelLocation"];
    if (locationString) {
        url = [url stringByAppendingFormat:@"&%@",locationString];
    }
    
    //网络
    NSString *reachStatus = nil;
	TodayNewsNetworkStatus netStatus = [[TodayNewsReachability reachabilityForInternetConnection] currentReachabilityStatus];
    if (TodayNewsNetworkStatus_ReachableViaWiFi == netStatus) {
        reachStatus = @"wifi";
    }
    else if (TodayNewsNetworkStatus_ReachableViaWWAN == netStatus) {
        reachStatus = @"WWAN";
    }
    if (reachStatus.length > 0) {
        url = [url stringByAppendingFormat:@"&net=%@",reachStatus];
    }
    
    return url;
}

- (NSArray *)parseNewsList:(NSDictionary *)rootData {
    NSMutableArray *newsList = [NSMutableArray array];
    if ([rootData isKindOfClass:[NSDictionary class]]) {
        NSDictionary *rootDic = (NSDictionary *)rootData;
        id articlesData = rootDic[@"articles"];
        if ([articlesData isKindOfClass:[NSArray class]]) {
            NSArray *articlesArray = (NSArray *)articlesData;
            for (id articleData in articlesArray) {
                if (newsList.count >= kSNTodayWidgetContentTableCellMaxCount) {
                    break;
                }
                SNTodayWidgetNews *news = [[SNTodayWidgetNews alloc] initWithData:articleData];
                if (!!news) {
                    [newsList addObject:news];
                }
            }
        }
    }
    return newsList;
}

- (void)cacheWidgetNewsList:(id)responseObject {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        if ([responseObject isKindOfClass:[NSDictionary class]]) {
            NSString *savePath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask, YES) objectAtIndex:0];
            NSString *saveFile = [savePath stringByAppendingPathComponent:kWidgetNewsListCacheFileName];
            SNDebugLog(@"Cache widget newslist to path %@", saveFile);
            [NSKeyedArchiver archiveRootObject:responseObject toFile:saveFile];
        }
    });
}

- (void)getCacheWidgetNewsList {
    __weak typeof(self) bself = self;
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSString *savePath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask, YES) objectAtIndex:0];
        NSString *saveFile = [savePath stringByAppendingPathComponent:kWidgetNewsListCacheFileName];
        SNDebugLog(@"Get cached widget newslist from path %@", saveFile);
        id cachedResponseObject = [NSKeyedUnarchiver unarchiveObjectWithFile:saveFile];
        NSArray *newsList = [bself parseNewsList:cachedResponseObject];
        if ([_delegate respondsToSelector:@selector(didFinishWithNewsList:)]) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [_delegate didFinishWithNewsList:newsList];
            });
        }
    });
}

+ (void)uploadPasteBoardToServer:(NSString *)boardString pid:(NSString *)pid success:(void(^)())success failure:(void(^)())failure {
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithCapacity:3];
    [params setValue:[boardString stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding] forKey:@"url"];
    [params setValue:pid forKey:@"pid"];
    NSString *p1 = [[[NSUserDefaults alloc] initWithSuiteName:kTodaynewswidgetGroup] objectForKey:kTodaynewswidgetP1];
    if (p1.length > 0) {
        [params setValue:p1 forKey:@"p1"];
    }
    [[AFHTTPSessionManager manager] POST:kNewsGrabURL parameters:params
                                success:^(NSURLSessionDataTask *task, id responseObject) {
                                    if (success) {
                                        success();
                                    }
                                } failure:^(NSURLSessionDataTask *task, NSError *error) {
                                    if (failure) {
                                        failure();
                                    }
                                }];
}

@end
