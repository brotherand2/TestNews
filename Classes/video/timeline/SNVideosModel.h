//
//  SNVideosModel.h
//  sohunews
//
//  Created by chenhong on 13-9-2.
//  Copyright (c) 2013年 Sohu.com. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol SNVideosModelDelegate <NSObject>

@optional
- (void)videosDidFinishLoad;
- (void)videosDidFailLoadWithError:(NSError *)error;
- (void)videosDidCancelLoad;

@end

@class SNVideoListInfo;

@interface SNVideosModel : NSObject<TTURLRequestDelegate> {

    id<SNVideosModelDelegate>       __weak _delegate;
    
    SNURLRequest                    *_request;
    
    NSString                        *_channelId;
    
    NSMutableArray                  *_dataArray;
    
    SNVideoListInfo                 *_listInfo;
}

@property(nonatomic, weak) id<SNVideosModelDelegate> delegate;
@property(nonatomic, weak) id<SNVideosModelDelegate> delegateForDetail;

@property(nonatomic, copy) NSString *channelId;

@property(nonatomic, strong) NSMutableArray *dataArray;
@property(nonatomic, strong) NSMutableArray *moreDataArray;

@property(nonatomic, strong) SNVideoListInfo *listInfo;

- (id)initWithChannelId:(NSString *)channelId;

- (void)refresh;

- (void)loadCache;

- (void)loadMore;

- (void)cancel;

- (BOOL)shouldReload;

- (BOOL)isLoading;

- (BOOL)hasNoMore;

- (NSDate *)refreshedTime;

- (void)setRefreshedTime;

+ (void)setNeedRefresh:(BOOL)bRefresh channelId:(NSString *)channelId;

@end
