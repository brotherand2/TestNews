//
//  SNSohuHaoModel.m
//  sohunews
//
//  Created by HuangZhen on 13/06/2017.
//  Copyright © 2017 Sohu.com. All rights reserved.
//

#import "SNSohuHaoModel.h"
#import "SNSohuHaoChannelListRequest.h"
#import "SNSohuHaoChannelContentRequest.h"
#import "TMCache.h"

@implementation SNSohuHaoChannel

@end

@implementation SNSohuHao

@end

@implementation SNSohuHaoModel

+ (void)getSohuHaoChannelList:(SNSohuHaoChannelListDataBlock)sohuHaoChannelListDataBlock {
    
    if (![[SNUtility getApplicationDelegate] isNetworkReachable]) {
        sohuHaoChannelListDataBlock([[self class] getChannelListFromCache]);
        return;
    }
    SNSohuHaoChannelListRequest * req = [[SNSohuHaoChannelListRequest alloc] init];
    [req send:^(SNBaseRequest *request, id responseObject) {
        if ([responseObject isKindOfClass:[NSDictionary class]]) {
            NSArray * subscribeIndexArr = [(NSDictionary *)responseObject arrayValueForKey:@"subscribeIndex" defaultValue:nil];
            NSMutableArray * retArr = [NSMutableArray array];
            if (subscribeIndexArr) {
                for (NSDictionary * dic in subscribeIndexArr) {
                    if (dic && [dic isKindOfClass:[NSDictionary class]]) {
                        [retArr addObject:[[self class] sohuHaoChannelFromDic:dic]];
                    }
                }
                sohuHaoChannelListDataBlock(retArr);
                [[self class] storeChannelList:subscribeIndexArr];
            }else{
                sohuHaoChannelListDataBlock([[self class] getChannelListFromCache]);
            }
        }else{
            sohuHaoChannelListDataBlock([[self class] getChannelListFromCache]);
        }
    } failure:^(SNBaseRequest *request, NSError *error) {
        sohuHaoChannelListDataBlock([[self class] getChannelListFromCache]);
    }];

}

+ (void)getSohuHaoListWithChannelId:(NSString *)channelId page:(NSInteger)page completed:(SNSohuHaoListDataBlock)sohuHaoListDataBlock {
    NSString * cacheKey = [NSString stringWithFormat:@"%@%@%d",SNLinks_Path_Subscribe_GetChannelcontent,channelId,page];
    if (![[SNUtility getApplicationDelegate] isNetworkReachable]) {
        sohuHaoListDataBlock([[self class] getSohuHaoListFromCacheForKey:cacheKey channelId:channelId]);
        return;
    }
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        SNSohuHaoChannelContentRequest * _contentRequest = [[SNSohuHaoChannelContentRequest alloc] init];
        _contentRequest.channelId = channelId;
        _contentRequest.page = [NSString stringWithFormat:@"%d",page];
        [_contentRequest send:^(SNBaseRequest *request, id responseObject) {
            if ([responseObject isKindOfClass:[NSDictionary class]]) {
                NSArray * subscribeIndexArr = [(NSDictionary *)responseObject arrayValueForKey:@"subscribeIndex" defaultValue:nil];
                NSMutableArray * retArr = [NSMutableArray array];
                if (subscribeIndexArr) {
                    for (NSDictionary * dic in subscribeIndexArr) {
                        if (dic && [dic isKindOfClass:[NSDictionary class]]) {
                            [retArr addObject:[[self class] sohuHaoFromDic:dic channelId:channelId]];
                        }
                    }
                    dispatch_async(dispatch_get_main_queue(), ^{
                        sohuHaoListDataBlock(retArr);
                    });
                    [self storeSohuHaoList:subscribeIndexArr withKey:cacheKey];
                }else{
                    dispatch_async(dispatch_get_main_queue(), ^{
                        sohuHaoListDataBlock([[self class] getSohuHaoListFromCacheForKey:cacheKey channelId:channelId]);
                        
                    });
                }
            }else{
                dispatch_async(dispatch_get_main_queue(), ^{
                    sohuHaoListDataBlock([[self class] getSohuHaoListFromCacheForKey:cacheKey channelId:channelId]);
                    
                });
            }
        } failure:^(SNBaseRequest *request, NSError *error) {
            dispatch_async(dispatch_get_main_queue(), ^{
                sohuHaoListDataBlock([[self class] getSohuHaoListFromCacheForKey:cacheKey channelId:channelId]);

            });
        }];
    });
}

#pragma mark - private

+ (void)storeChannelList:(NSArray *)array {
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        TMCache * cache = [TMCache sharedCache];
        [cache setObject:array forKey:SNLinks_Path_Subscribe_GetChannelList];
    });
}

+ (void)storeSohuHaoList:(NSArray *)array withKey:(NSString *)key{
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        TMCache * cache = [TMCache sharedCache];
        [cache setObject:array forKey:key];
    });
}

+ (NSArray *)getChannelListFromCache {
    TMCache * cache = [TMCache sharedCache];
    NSArray * subscribeIndexArr = [cache objectForKey:SNLinks_Path_Subscribe_GetChannelList];
    if (subscribeIndexArr) {
        NSMutableArray * retArr = [NSMutableArray array];
        for (NSDictionary * dic in subscribeIndexArr) {
            if (dic && [dic isKindOfClass:[NSDictionary class]]) {
                [retArr addObject:[[self class] sohuHaoChannelFromDic:dic]];
            }
        }
        return retArr;
    }
    return nil;
}

+ (NSArray *)getSohuHaoListFromCacheForKey:(NSString *)key channelId:(NSString *)channelId{
    TMCache * cache = [TMCache sharedCache];
    NSArray * subscribeIndexArr = [cache objectForKey:key];
    if (subscribeIndexArr) {
        NSMutableArray * retArr = [NSMutableArray array];
        for (NSDictionary * dic in subscribeIndexArr) {
            if (dic && [dic isKindOfClass:[NSDictionary class]]) {
                [retArr addObject:[[self class] sohuHaoFromDic:dic channelId:channelId]];
            }
        }
        return retArr;
    }
    return nil;
}

+ (SNSohuHaoChannel *)sohuHaoChannelFromDic:(NSDictionary *)dic {
    SNSohuHaoChannel * channel = [[SNSohuHaoChannel alloc] init];
    channel.name = [dic stringValueForKey:@"name" defaultValue:@""];
    channel.channelId = [dic stringValueForKey:@"id" defaultValue:@""];
    return channel;
}

+ (SNSohuHao *)sohuHaoFromDic:(NSDictionary *)dic channelId:(NSString *)channelId{
    SNSohuHao * sohuHao = [[SNSohuHao alloc] init];
    sohuHao.subId = [dic stringValueForKey:@"subId" defaultValue:@""];
    sohuHao.nickname = [dic stringValueForKey:@"nickname" defaultValue:@""];
    sohuHao.pv = [dic intValueForKey:@"pv" defaultValue:0];
    sohuHao.passport = [dic stringValueForKey:@"passport" defaultValue:@""];
    sohuHao.avatar = [dic stringValueForKey:@"avatar" defaultValue:@""];
    sohuHao.mpId = [dic stringValueForKey:@"mpId" defaultValue:@""];
    sohuHao.channelid = channelId;
    return sohuHao;
}

@end
