//
//  SNLiveListModel.h
//  sohunews
//
//  Created by wang yanchen on 13-4-18.
//  Copyright (c) 2013年 Sohu.com. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SNLiveDayObj : NSObject

@property(nonatomic, copy) NSString *liveDay;
@property(nonatomic, copy) NSString *liveDate;
@property(nonatomic, copy) NSString *liveDateString; // xx月xx日
@property(nonatomic, strong) NSMutableArray *lives; // LivingGameItem

@end

///////////////////////////////////////////////////////////////

@interface SNLiveListModel : NSObject {
    NSString *_subId;
}

@property(nonatomic, copy) NSString *subId;

// array of LivingGameItem
@property(weak, nonatomic, readonly) NSArray *focusLives; // LivingGameItem
@property(weak, nonatomic, readonly) NSArray *forecastLives; // SNLiveDayObj
@property(weak, nonatomic, readonly) NSArray *todayLives; // LivingGameItem

@property(weak, nonatomic, readonly) NSArray *historyLives; // SNLiveDayObj

@property(weak, nonatomic, readonly) NSString *liveDate; // 时间戳
@property(weak, nonatomic, readonly) NSString *liveDay; // 星期x

- (id)initWithLiveSubId:(NSString *)subId;

- (void)refreshLiveListWithSuccess:(void (^)(SNLiveListModel *liveModel))success failure:(void (^)(NSError *error))failure;
- (void)refreshHistoryListWithSuccess:(void (^)(SNLiveListModel *liveModel))success failure:(void (^)(NSError *error))failure;

- (void)cancelAllRequests;

@end
