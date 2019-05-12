//
//  SNArticleRecomService.m
//  sohunews
//
//  Created by lhp on 12/19/13.
//  Copyright (c) 2013 Sohu.com. All rights reserved.
//

#import "SNArticleRecomService.h"
//#import "SNURLJSONResponse.h"
#import "SNRollingNewsTableItem.h"
//#import "SNRecommendParameterManager.h"
#import "SNStatisticsInfoAdaptor.h"
#import "SNUserManager.h"
#import "SNArticleRecomReuqest.h"

@interface SNArticleRecomService ()
//{
//    SNURLRequest *_request;
//}

@end

@implementation SNArticleRecomService
@synthesize newsId;
@synthesize termId;
@synthesize subId;
@synthesize channelId;
@synthesize adInfoArray;
@synthesize delegate = _delegate;
@synthesize fromPush;

- (id)init
{
    self = [super init];
    if (self) {
        adInfoArray = [[NSMutableArray alloc] init];
    }
    return self;
}

- (void)loadRecommendNews {
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithCapacity:5];
    if (self.gid.length > 1) {
        [params setValue:self.gid forKey:@"gid"];
    } else if (self.newsId.length > 0) {
        [params setValue:self.newsId forKey:@"newsId"];
    }
    if (self.termId.length > 0) {
        [params setValue:self.termId forKey:@"termId"];
    }
    if (nil != self.fromPush) {
        [params setValue:self.fromPush forKey:@"fromPush"];
    }
    [params setValue:self.channelId ? : @"" forKey:@"channelId"];
    [params setValue:[SNUserManager getPid] ? : @"-1" forKey:@"pid"];
    if (self.adType == SNAdInfoTypeArticle) {
        [params setValue:@"3" forKey:@"newsType"];
    } else if (self.adType == SNAdInfoTypePhotoListNews) {
        [params setValue:@"4" forKey:@"newsType"];
    }

    if (self.userData) {
        params = [SNUtility appendingParamsToUrl:params fromLink:self.userData].mutableCopy;
    }
    [[[SNArticleRecomReuqest alloc] initWithDictionary:params] send:^(SNBaseRequest *request, id rootData) {
        if (rootData && [rootData isKindOfClass:[NSDictionary class]]) {
            
            [self.adInfoArray removeAllObjects];
            
            // 4.0广告 解析广告定向数据 并缓存 by jojo
            NSString *cId = (self.channelId ? self.channelId : (self.termId ? self.termId : (self.subId ? self.subId : kAdInfoDefaultCategoryId)));
            
            // 先清除之前的缓存
            [[SNDBManager currentDataBase] adInfoClearAdInfosByType:SNAdInfoTypeArticle dataId:self.newsId categoryId:cId];
            
            NSMutableArray *parsedAdInfos = [NSMutableArray array];
            SNAdControllInfo *adControlInfo = [[SNAdControllInfo alloc] initWithJsonDic:rootData];
            [parsedAdInfos addObject:adControlInfo];
            self.adInfoArray = parsedAdInfos;
            // 添加到缓存
            NSString *dataId = self.gid.length > 1 ? self.gid : self.newsId;
            [[SNDBManager currentDataBase] adInfoAddOrUpdateAdInfos:parsedAdInfos
                                                           withType:self.adType
                                                             dataId:dataId
                                                         categoryId:cId];
        }
        
        if (_delegate && [_delegate respondsToSelector:@selector(getRecommendNewsSucceed)]) {
            [_delegate getRecommendNewsSucceed];
        }

    } failure:nil];
}

@end
