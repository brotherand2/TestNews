//
//  SNLiveModel.h
//  sohunews
//
//  Created by yanchen wang on 12-6-14.
//  Copyright (c) 2012年 Sohu.com Inc. All rights reserved.
//

#import "SNNewsModel.h"
//#import "SNURLRequest.h"

@interface SNLiveModel : SNNewsModel {
    NSString *_channelID;
//    SNURLRequest *_requestToday;
//    SNURLRequest *_requestForecast;
//    
//    SNURLRequest *_requestList; // 3.7.1 今日，其他分类，预告三合一
//    SNURLRequest *_requestHistory; // 3.7.1 往期
    
    NSMutableArray *_livingGamesToday;
    NSMutableArray *_livingCategoryArr;
    NSMutableArray *_livingGamesForecast;
    
    NSMutableArray *_sectionsArray;
    
    //NSMutableDictionary *_subscribedLiveIdInfo; // 存储当前本地通知中订阅比赛id
    
    BOOL isCancelLoading; // 防止数据load成功之后回调crash
    BOOL _bHistoryLoadMore;
    BOOL loadMore;
    NSString *_todayLiveDate;

}
@property(nonatomic, copy)NSString *channelID;
@property(nonatomic, strong)NSMutableArray *livingGamesToday;
@property(nonatomic, strong)NSMutableArray *livingCategoryArr;
@property(nonatomic, strong)NSMutableArray *livingGamesForecast;
@property(nonatomic, strong)NSMutableArray *livingGamesHistory;
@property(nonatomic, strong)NSMutableArray *sectionsArray;
@property(nonatomic, assign)BOOL needRefreshOnStart;  // 每次打开新闻第一次切换直播tab时强制刷新

@property(nonatomic, copy)NSString *todayLiveDate;
@property(nonatomic, copy)NSString *lastHistoryLiveDate;

@property (nonatomic, strong) NSMutableArray *livingGameSectionTitles; // v5.2.0
@property (nonatomic, strong) NSMutableArray *livingGameSectionCounts; // v5.2.0
@property (nonatomic, strong) NSMutableArray *items; // v5.2.0


- (id)initWithChannelID:(NSString *)channelID;

// 解析todayLives
+ (LivingGameItem *)createTodayLivingGameItemByDicInfo:(NSDictionary *)dicInfo
                                               isFocus:(BOOL)isFocus
                                               isToday:(BOOL)isToday;

// 解析直播分类
+ (LiveCategoryItem *)createLivingCategoryItemByDicInfo:(NSDictionary *)dicInfo;

// 解析forecastLives
+ (NSArray *)createForeLivingGameItemArrayByDicInfo:(NSDictionary *)dicInfo;

@end
