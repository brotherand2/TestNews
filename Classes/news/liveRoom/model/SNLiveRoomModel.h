//
//  SNLiveRoomModel.h
//  sohunews
//
//  Created by chenhong on 13-4-19.
//  Copyright (c) 2013年 Sohu.com. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SNLiveContentObjects.h"
#import "ASIHTTPRequestDelegate.h"
#import "ASIHTTPRequest.h"
#import "ASINetworkQueue.h"
//#import "AFNetworking.h"
@protocol SNLiveRoomModelDelegate <NSObject>

@optional
- (void)liveRoomDidFinishLoad;
- (void)liveRoomDidFailLoadWithError:(NSError *)error;
- (void)liveRoomDidCancelLoad;
- (void)receivedLiveContentPush;

- (void)liveRoomFirstToRequestAd:(NSInteger)count;
- (void)liveRoomloadMore:(NSInteger)loadNum firstContentID:(long long)contentID;
@end


@interface SNLiveRoomModel : NSObject</*TTURLRequestDelegate, */ASIHTTPRequestDelegate> {
    
    id<SNLiveRoomModelDelegate>     __weak _delegate;
    
    SNLiveContentMatchInfoObject    *_matchInfo;

    NSMutableArray                  *_contentsArray;    //直播员内容
    NSMutableArray                  *_commentsArray;    //评论内容
    NSMutableArray                  *_mergedArray;      //直播员+网友评论内容

//    SNURLRequest                    *_request;          //data.go请求
    ASIHTTPRequest                  *_asiRequest;       //push长连接请求
    ASINetworkQueue                 *_networkQueue;

    NSMutableData                   *_receivedData;     //push长连接收到的数据

    /*
     rollingType为滚动类型，分为两种
     0-向上滚动，此时contentId和commentId分别为上次获取直播内容时获取到的直播内容和直播评论的最大id，
     服务器端根据这两个id返回最新的直内容和直播评论给客户端，一次最大返回条目数不超过50个；
     1-向下滚动，此时contentId和commentId分别为上次获取直播内容时获取到的直播内容和直播评论的最小id，
     服务器根据这两个id返回下一页直播内容和直播评论给客户端，一次返回最大条目数不超过50个。
     
     type表示返回数据范围：0（默认）-直播内容和直播评论；1 – 直播内容；2 – 直播评论。
     */
    NSString        *_liveId;           //直播ID,可以唯一标识一个直播
    NSString        *_rollingType;
    NSString        *_contentId;
    NSString        *_commentId;
    NSString        *_type;

    /*
     直播内容同时支持服务端推送的方式，即客户端来订阅某个直播，一旦直播有新内容服务器端会将新产生的内容push到客户端；
     服务器端推送方式要注意如下几点：
     1）、进入某个直播时，首先需要调用data.go 初始化直播间，data.go中返回了push订阅的地址，初始化之后要向这个订阅服务器发送一个订阅；以后的直播内容都是服务器push给客户端的，无需再访问data.go；注意，订阅地址使用获取最新的订阅地址：http://live.k.sohu.com/sub/channel_${liveid} 而非获取历史数据的地址：http://live.k.sohu.com/sub/channel_${liveid}.b${n}
     2）、客户端程序从运行状态进入后台运行时，关闭订阅链接，如果从后台又返回到运行状态，则效仿第一步先访问data.go初始化直播间，然后再订阅；
     3）、初始化直播间时返回的直播内容数据与服务器push下来的直播内容可能会有重复，所以要对进行去重，最简单的办法，是将push下来的数据的contentId和commentId与data.go返回的内容集合的contentId和评论集合的commentId进行比较，比它们大的才是新push的数据，小于等于的不是最新的数据；
     4）、直播状态变化时不管此时有没有新的直播内容和直播评论，都会返回数据，如果没有直播内容和直播评论会返回直播的基本信息； 返回数据格式为json
     */
//    int             _state;                         //0：使用data.go初始化 1：向订阅服务器发送一个订阅

    NSString        *_subServer;                    //直播间内容推送的订阅服务器地址；
    NSMutableArray  *_receivedContentItems;         //获取更多时，接收到的push数据存在此数组中临时存储，上层逻辑负责将此数据插入到contentArray或commentArray中
    //NSMutableArray  *_receivedCommentItems;
    NSMutableArray  *_receivedMergeItems;

//    int             _topCursor;                     //最新数据项索引
    int             _bottomCursor;                  //最老数据项索引，用于传给接口加载更多历史数据
}

@property(nonatomic, weak) id<SNLiveRoomModelDelegate> delegate;
@property(nonatomic, strong) SNLiveContentMatchInfoObject *matchInfo;
@property(nonatomic, strong) NSMutableArray *contentsArray;
@property(nonatomic, strong) NSMutableArray *commentsArray;
@property(nonatomic, strong) NSMutableArray *mergedArray;
@property(nonatomic, copy) NSString *liveId;
@property(nonatomic, copy) NSString *rollingType;
@property(nonatomic, copy) NSString *contentId;
@property(nonatomic, copy) NSString *commentId;
@property(nonatomic, copy) NSString *type;
@property(nonatomic, assign) BOOL isIncrementalUpdate;
@property(nonatomic, copy) NSString *subServer;
@property(nonatomic, strong) NSMutableArray  *receivedContentItems;
@property(nonatomic, strong) NSMutableArray  *receivedMergeItems;

- (id)initWithLiveId:(NSString *)liveId type:(NSString *)type;

- (void)refresh;

- (void)loadMore;

- (void)cancel;

- (NSMutableArray *)getObjectsArray;
- (NSInteger)getReceivedItemsCount;

- (void)printDataCountInfo;

- (SNLiveContentObject *)extractLastReceivedItem;

- (BOOL)hasReceivedNewLiveItem;

- (void)mergeReceivedItemsWithModelArray;

- (BOOL)isLoading;

- (BOOL)hasNoMore;

- (BOOL)isSubServerConnected;

- (NSDate *)refreshedTime;

- (void)setRefreshedTime;

@end
