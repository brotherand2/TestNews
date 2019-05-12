//
//  SNDatabase_LivingGame.h
//  sohunews
//
//  Created by yanchen wang on 12-6-15.
//  Copyright (c) 2012年 Sohu.com Inc. All rights reserved.
//

#import "SNDatabase.h"
#import "SNDatabase_Private.h"
@interface SNDatabase(LivingGame)

- (BOOL)updateTodayLivingGames:(NSArray *)gamesArray;
- (BOOL)updateLivingCategoryItems:(NSArray *)livingCategoryArr;
- (BOOL)updateForecastLivingGames:(NSArray *)gamesArray;
- (BOOL)updateLivingGame:(LivingGameItem *)game;

- (LivingGameItem *)getLiveItemByLiveId:(NSString *)liveId;

- (NSArray *)livingGamesToday;
- (NSArray *)livingCategoryItems;
- (NSArray *)livingGamesForecast;

- (BOOL)clearLivingGames;

@end
