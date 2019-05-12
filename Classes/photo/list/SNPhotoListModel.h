//
//  SNPhotoListModel.h
//  sohunews
//
//  Created by 雪 李 on 11-12-14.
//  Copyright (c) 2011年 Sohu.com Inc. All rights reserved.
//

#import "SNAdvertiseManager.h"
#import "SNAdDataCarrier.h"

@class GalleryItem;
@class RecommendGallery;

@protocol SNPhotoListModelDelegate <NSObject>

- (void)photoListModelDidStartLoad;
- (void)photoListModelDidFinishLoad;
- (void)photoListModelDidFailToLoadWithError:(NSError*)error;
- (void)photoListModelDidFinishLoadRecommendAds;

@end

@interface SNPhotoListModel : TTURLRequestModel <TTPhotoSource>
{
    NSString *_termId;
    NSString *_newsId;
    NSString *_channelId;
    NSString *_nextGid;//下一个推荐gid
    BOOL _isOnlineMode;
    GalleryItem *_photoList;
    NSMutableDictionary *_requestDic;
    int _preLoadNum;
    NSDictionary *_userInfo;
    
    id<SNPhotoListModelDelegate> _delegate;
}

@property(nonatomic,retain)NSString *termId;
@property(nonatomic,retain)NSString *newsId;
@property(nonatomic,retain)NSString *channelId;
@property(nonatomic,retain)NSString *nextGid;
@property(nonatomic,retain)GalleryItem *photoList;
@property(nonatomic,retain)NSDictionary *userInfo;
@property(nonatomic,retain)NSMutableArray *photoListItems;
@property(nonatomic,assign)id<SNPhotoListModelDelegate> delegate;
// ad sdk
@property (nonatomic, retain) SNAdDataCarrier *sdkAdLastPic; // 组图新闻大图最后一张
@property (nonatomic, retain) SNAdDataCarrier *sdkAdLastRecommend; // 组图相关推荐最后一格
@property (nonatomic, retain) SNAdDataCarrier *sdkAdTextPic; // 正文banner广告
@property (nonatomic, retain) SNAdDataCarrier *sdkAdNewsRecommend; // 正文相关推荐最后一条

- (SNPhotoListModel*)initWithTermId:(NSString*)termId
                             newsId:(NSString*)newsId
                          channelId:(NSString*)channelId
                       isOnlineMode:(BOOL)isOnlineMode
                       userInfo:(NSDictionary *)userInfo;

- (void)preloadImage;

@end
