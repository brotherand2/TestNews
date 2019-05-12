//
//  SNSubscribeNewsModel.h
//  sohunews
//
//  Created by lhp on 10/13/14.
//  Copyright (c) 2014 Sohu.com. All rights reserved.
//

#import "SNNewsModel.h"

@protocol SNFollowEventDelegate <NSObject>
- (void)mySubscribeListUnFollowEvent;
@end

@interface SNSubscribeNewsModel : SNNewsModel {
    BOOL isLoading;
    BOOL loadMore;
    NSString *channelId;
    
    NSInteger pageNum;
    
    NSMutableArray *subscribeArray;
    NSMutableArray *recomSubscribeArray;
    NSMutableArray *adArray;
    
    BOOL isSubRefresh;
}

@property (nonatomic) BOOL isPullRefresh;
@property (nonatomic, strong) NSString *channelId;
@property (nonatomic, strong) NSMutableArray *subscribeArray;
@property (nonatomic, strong) NSMutableArray *recomSubscribeArray;
@property (nonatomic, strong) NSMutableArray *adArray;
@property (nonatomic, weak) id <SNFollowEventDelegate> followEvetnDelegate;

- (id)initWithChannelId:(NSString *)channelId;
- (BOOL)isEmpty;
- (BOOL)isSubscribeEmpty;
- (void)refreshWithNoAnimation;
- (void)localRefresh;
- (void)saveSubObject:(SCSubscribeObject *)subscribeObject;

@end
