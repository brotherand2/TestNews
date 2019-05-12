//
//  SNLiveStatisticModel.h
//  sohunews
//
//  Created by wang yanchen on 13-4-24.
//  Copyright (c) 2013年 Sohu.com. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol SNLiveStatisticModelDelegate <NSObject>

@optional
- (void)didFinishLoadStatistic;
- (void)didFailToLoadStatisticWithError:(NSError *)error;

@end

@interface SNLiveStatisticModel : NSObject {
//    SNURLRequest *_request;
}

@property(nonatomic, copy) NSString *liveId;
@property(weak) id delegate; // atomic

// public methods
- (id)initWithLiveId:(NSString *)liveId;
- (void)refreshLiveStatisticFromServer;
- (void)cancelAndCleanDelegate;

// 球队信息
@property(weak, nonatomic, readonly) NSString *hostTeamName;
@property(weak, nonatomic, readonly) NSString *visitTeamName;
@property(weak, nonatomic, readonly) NSString *hostTeamScore;
@property(weak, nonatomic, readonly) NSString *visitTeamScore;
@property(strong) NSMutableArray *hostTeamScores;
@property(strong) NSMutableArray *visitTeamScores;

- (NSArray *)columnsTitleForTeam;

// 球员信息
@property(nonatomic, copy) NSString *hostName;
@property(nonatomic, copy) NSString *visitName;
@property(strong) NSMutableArray *sectionArray; // atomic

- (NSArray *)columnsTitleForHost;
- (NSArray *)columnsTitleForVisit;

@end
