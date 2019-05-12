//
//  SNLiveDataSource.h
//  sohunews
//
//  Created by yanchen wang on 12-6-14.
//  Copyright (c) 2012年 Sohu.com Inc. All rights reserved.
//

#import "SNLiveModel.h"
#import "SNNewsDataSource.h"

@interface SNLiveDataSource : SNNewsDataSource {

}

@property(nonatomic, strong)SNLiveModel *livingModel;
@property(nonatomic, strong)NSMutableArray *focusGames;
@property(nonatomic, strong)NSMutableArray *todayGames;
@property(nonatomic, strong)NSMutableArray *categoryItems;
@property(nonatomic, strong)NSMutableArray *forecastGames;
@property(nonatomic, strong)NSMutableArray *historyGames;
//@property (nonatomic, strong) SNRollingNewsTableController *controller;

- (id)initWithChannelID:(NSString *)channelID;

@end
