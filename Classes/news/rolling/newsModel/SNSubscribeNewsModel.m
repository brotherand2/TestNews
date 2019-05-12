//
//  SNSubscribeNewsModel.m
//  sohunews
//
//  Created by lhp on 10/13/14.
//  Copyright (c) 2014 Sohu.com. All rights reserved.
//

#import "SNSubscribeNewsModel.h"
#import "NSObject+YAJL.h"
#import "SNSubscribeCenterService.h"
#import "SNOfficialAccountsInfo.h"
#import "SNRollingNewsPublicManager.h"
#import "SNDBManager.h"
#import "SNUserManager.h"

@interface SNSubscribeNewsModel () {
    BOOL _needPullAnimation;
}

@property (nonatomic, strong) SCSubscribeObject *lastSelectedSubObject;

@end

@implementation SNSubscribeNewsModel
@synthesize channelId;
@synthesize subscribeArray;
@synthesize recomSubscribeArray;
@synthesize adArray;

- (id)initWithChannelId:(NSString *)newsChannelId {
    if (self = [super init]) {
        self.channelId = newsChannelId;
        self.subscribeArray = [NSMutableArray array];
        self.recomSubscribeArray = [NSMutableArray array];
        self.adArray = [NSMutableArray array];
        [self readCacheFromDatabase];
        _needPullAnimation = YES;
        [[SNSubscribeCenterService defaultService] addListener:self forOperation:SCServiceOperationTypeRefreshMySub];
        [[SNSubscribeCenterService defaultService] addListener:self forOperation:SCServiceOperationTypeMoreRecomSub];
        [[SNSubscribeCenterService defaultService] addListener:self forOperation:SCServiceOperationTypeAddMySubToServer];
        [[SNSubscribeCenterService defaultService] addListener:self forOperation:SCServiceOperationTypeRemoveMySubToServer];
        [[SNSubscribeCenterService defaultService] addListener:self forOperation:SCServiceOperationTypeAddOrRemoveMySubsToServer];
        
        isSubRefresh = NO;
    }
    return self;
}

- (BOOL)isEmpty {
    NSInteger mysubCount = self.subscribeArray.count;
    return mysubCount > 0 ? NO : YES;
}

- (BOOL)isSubscribeEmpty {
    return ((self.subscribeArray.count + self.recomSubscribeArray.count + self.adArray.count) == 0)? YES : NO;
}

- (NSTimeInterval)refreshIntervalWithDefault:(NSTimeInterval)interval {
    return interval;
}

- (void)readCacheFromDatabase {
    [self.subscribeArray removeAllObjects];
    [self.recomSubscribeArray removeAllObjects];
    [self.adArray removeAllObjects];
    
    NSArray *mySubs = [[SNSubscribeCenterService defaultService] loadSortedMySubFromLocalDB];
    if (mySubs.count > 0) {
        for (SCSubscribeObject *subscribeObject in mySubs) {
            if (subscribeObject.topNewsString.length > 0) {
                NSArray *topNewsList = [subscribeObject.topNewsString yajl_JSON];
                if ([topNewsList isKindOfClass:[NSArray class]]) {
                    subscribeObject.topNewsArray = [NSMutableArray arrayWithArray:topNewsList];
                }
            }
        }
        [self.subscribeArray addObjectsFromArray:mySubs];
    }
    
    NSArray *adList = [[SNSubscribeCenterService defaultService] loadAdListFromLocalDBForType:SNSubCenterAdListTypeMySub];
    if (adList.count > 0) {
        [self.adArray addObjectsFromArray:adList];
    }
    pageNum = 2;
}

- (void)refreshWithNoAnimation {
    pageNum = 1;
    isLoading = YES;
    [[SNSubscribeCenterService defaultService] loadMySubFromServerWithPage:pageNum];
}

- (void)localRefresh {
    if (self.lastSelectedSubObject) {
        [SNOfficialAccountsInfo
         checkFollowStatusWithSubId:self.lastSelectedSubObject.subId completed:^(SNFollowedStatus followedStatus) {
            if (followedStatus == SNFollowedStatusNone ||
                followedStatus == SNFollowedStatusFollower ||
                followedStatus == SNFollowedStatusSelf) {
                [self.subscribeArray removeObject:self.lastSelectedSubObject];
                self.lastSelectedSubObject = nil;
                [[SNDBManager currentDataBase] addSubscribeCenterMySubscribes:self.subscribeArray];
                [self requestDidFinishLoad];
                if ([self.followEvetnDelegate respondsToSelector:@selector(mySubscribeListUnFollowEvent)]) {
                    [self.followEvetnDelegate mySubscribeListUnFollowEvent];
                }
            }
        }];
    }
}

- (void)saveSubObject:(SCSubscribeObject *)subscribeObject {
    self.lastSelectedSubObject = subscribeObject;
}

- (void)load:(TTURLRequestCachePolicy)cachePolicy more:(BOOL)more {
    if (isLoading) {
        return;
    }
    _hasNoMore = YES;
    if (more && _hasNoMore) {
        return;
    }
    loadMore = more;
//    self.hasNoMore = NO;

    if (TTURLRequestCachePolicyLocal == cachePolicy) {
//        if (self.recomSubscribeArray.count > 0) {
//            self.hasNoMore = NO;
//        }
        [self readCacheFromDatabase];
        if (![self isEmpty]) {
            [self requestDidFinishLoad];
        } else {
            [self request:YES];
        }
    } else {
        [self request:YES];
        NSString *slideSubscribe = [[NSUserDefaults standardUserDefaults] objectForKey:@"slideToSubscribe"];
        if ([slideSubscribe isEqualToString:@"1"]) {
            isSubRefresh = NO;
        } else {
            isSubRefresh = YES;
        }
    }
}

- (void)request:(BOOL)bASyn {
    [super didStartLoad];

    if (loadMore) {        
        isLoading = YES;
        pageNum++;
    } else {
        pageNum = 1;
        isLoading = YES;
    }
    [[SNSubscribeCenterService defaultService] loadMySubFromServerWithPage:pageNum];
}

- (void)requestDidFinishLoad {
    [super requestDidFinishLoad:nil];
    self.isRecreate = NO;
}

#pragma mark - SNSubscribeCenterServiceDelegate
- (void)didFinishLoadDataWithDataSet:(SNSubscribeCenterCallbackDataSet *)dataSet {
    if ([dataSet operation] == SCServiceOperationTypeRefreshMySub) {
        isLoading = NO;
        if (!loadMore) {
            [self setRefreshedTime];
            [self setRefreshStatusOfUpgrade];
        }
        
        NSArray *SubArray = [dataSet strongDataRef];
        [self.subscribeArray removeAllObjects];
        [self.recomSubscribeArray removeAllObjects];
        [self.subscribeArray addObjectsFromArray:SubArray];
        
        NSArray *adList = [[SNSubscribeCenterService defaultService] loadAdListFromLocalDBForType:SNSubCenterAdListTypeMySub];
        [self.adArray removeAllObjects];
        if (adList.count > 0) {
            [self.adArray addObjectsFromArray:adList];
        }
        
        [self requestDidFinishLoad];
        BOOL isRedDot = [[NSUserDefaults standardUserDefaults] boolForKey:kIsRedDot];
        if (isRedDot) {
            [[NSUserDefaults standardUserDefaults] setBool:NO forKey:kIsRedDot];
            [[NSUserDefaults standardUserDefaults] synchronize];
        }
        
        isSubRefresh = NO;

    } else if ([dataSet operation] == SCServiceOperationTypeAddOrRemoveMySubsToServer ||
               [dataSet operation] == SCServiceOperationTypeAddMySubToServer ||
               [dataSet operation] == SCServiceOperationTypeRemoveMySubToServer) {
        if (![[NSUserDefaults standardUserDefaults] boolForKey:kRecomSubClick]) {
            [self request:YES];
            [[NSUserDefaults standardUserDefaults] setObject:@"1" forKey:@"slideToSubscribe"];
            [[NSUserDefaults standardUserDefaults] synchronize];
        }
    }
}

- (void)didFailLoadDataWithDataSet:(SNSubscribeCenterCallbackDataSet *)dataSet {
    if ([dataSet operation] == SCServiceOperationTypeRefreshMySub) {
        isLoading = NO;
        [self requestDidFinishLoad];
        [[SNCenterToast shareInstance] showCenterToastWithTitle:NSLocalizedString(@"network error", @"") toUrl:nil mode:SNCenterToastModeError];
    } else if([dataSet operation] == SCServiceOperationTypeMoreRecomSub) {
        isLoading = NO;
        [self requestDidFinishLoad];
        [[SNCenterToast shareInstance] showCenterToastWithTitle:NSLocalizedString(@"network error", @"") toUrl:nil mode:SNCenterToastModeError];
    } else if ([dataSet operation] == SCServiceOperationTypeAddOrRemoveMySubsToServer ||
               [dataSet operation] == SCServiceOperationTypeAddMySubToServer || [dataSet operation] == SCServiceOperationTypeRemoveMySubToServer) {
        [[SNCenterToast shareInstance] showCenterToastWithTitle:NSLocalizedString(@"network error", @"") toUrl:nil mode:SNCenterToastModeError];
    }
}

- (void)didCancelLoadDataWithDataSet:(SNSubscribeCenterCallbackDataSet *)dataSet {
    isLoading = NO;
    [super requestDidCancelLoad:nil];
}

- (void)dealloc {
    [[SNSubscribeCenterService defaultService] removeListener:self];
}

- (BOOL)isLoadingMore {
    return loadMore;
}

@end
