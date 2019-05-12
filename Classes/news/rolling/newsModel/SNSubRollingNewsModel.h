//
//  SNSubRollingNewsModel.h
//  sohunews
//
//  Created by wangyy on 2017/10/25.
//  Copyright © 2017年 Sohu.com. All rights reserved.
//

#import "SNRollingNewsModel.h"

typedef void(^SNTrainNetworkSuccessBlock)(id responseObject);
typedef void(^SNTrainNetworkFailureBlock)(NSError *error);

@interface SNSubRollingNewsModel : SNRollingNewsModel

@property (nonatomic, strong) NSString *contentToken;
@property (nonatomic, assign) BOOL showHistoryLine;
@property (nonatomic, strong) NSString *curTrainCardId;//当前正在加载的火车ID
@property (nonatomic, assign) BOOL todayHistoryFinish;
@property (nonatomic, assign) BOOL hasHistoryData;//是否提示历史数据看完

@property (copy, nonatomic) SNTrainNetworkSuccessBlock successBlock;
@property (copy, nonatomic) SNTrainNetworkFailureBlock failureBlock;


- (void)updateFocusToTrainCard;//动画后焦点图变火车数据
- (BOOL)loadMoreTrainNews:(NSString *)trainId
                 trainPos:(NSString *)trainPos
                  success:(SNTrainNetworkSuccessBlock)success
                  failure:(SNTrainNetworkFailureBlock)failure;//右滑加载更多火车数据
- (void)updateRollingNews:(NSArray *)newsList; //根据业务，刷新显示数据

@end
