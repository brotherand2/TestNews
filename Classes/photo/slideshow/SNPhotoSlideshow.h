//
//  SNPhotoSlideshow.h
//  sohunews
//
//  Created by Dan on 12/27/11.
//  Copyright (c) 2011 Sohu.com Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CacheObjects.h"
#import "SNPhoto.h"
#import "SNAdvertiseManager.h"
#import "SNAdDataCarrier.h"

@class  SNPhotoSlideshow;

@protocol SNPhotoSlideshowDelegate <NSObject>

@optional
- (void)didFinishPreLoad:(GalleryLoadType)glType;
- (void)didFinishPreLoad:(GalleryLoadType)glType slideshow:(SNPhotoSlideshow *)slideshowData;
- (void)didFailedPreLoad:(GalleryLoadType)glType slideshow:(SNPhotoSlideshow *)slideshowData;
@end

@interface SNPhotoSlideshow : TTURLRequestModel <TTPhotoSource> {
    
	NSString *_newsId;  //新闻id
	NSString *_termId;  //报纸id
    NSString *_channelId;
    NSString *_nextGid;//下一个推荐gid
    
    NSString *title;   //标题
	NSString *commentNum;  //评论数
	NSMutableArray* _photos;//图片
	NSString *shareContent;//分享语
	
	BOOL _isOnlineMode;//是否在线模式，反之为离线下载后的模式
    
    NSArray *moreRecommends;
    
    GalleryItem *_photoList;
    SNURLRequest *_request;
    
    NSMutableArray *allItems;
    
    NSString *type;
	NSString *typeId;
    
    GalleryLoadType    galleryLoadType;
    
    id<SNPhotoSlideshowDelegate> _slideshowDelegate;
    
    SNPhoto *firstPhotoOfNextGroup;
    SNPhoto *lastPhotoOfPrevGroup;
    NSArray *prevMoreRecommends;
    NSString*subId;
    NSString    *stpAudCmtRsn;
}

@property(nonatomic, copy)NSString *newsId;
@property(nonatomic, copy)NSString *termId;

@property(nonatomic, copy)NSString *type;
@property(nonatomic, copy)NSString *typeId;

@property(nonatomic,copy)NSString *channelId;
@property(nonatomic,copy)NSString *nextGid;
@property(nonatomic, copy)NSString *commentNum;
@property(nonatomic, retain)NSMutableArray* photos;
@property(nonatomic, copy)NSString *shareContent;
@property(nonatomic, retain)NSArray *moreRecommends;
@property(nonatomic, retain)GalleryItem *photoList;
@property(nonatomic)BOOL isOnlineMode;
@property(nonatomic,retain)NSMutableArray *allItems;
@property(nonatomic,readwrite)GalleryLoadType    galleryLoadType;
@property(nonatomic,assign)id<SNPhotoSlideshowDelegate> slideshowDelegate;
@property(nonatomic, retain)SNPhoto *firstPhotoOfNextGroup;
@property(nonatomic, retain)SNPhoto *lastPhotoOfPrevGroup;
@property(nonatomic, retain)NSArray *prevMoreRecommends;
@property(nonatomic, retain)NSString *subId;
@property(nonatomic, retain)NSString *stpAudCmtRsn;

// for ad sdk
@property (nonatomic, retain) SNAdDataCarrier *sdkAdLastPic;   
@property (nonatomic, retain) SNAdDataCarrier *sdkAdLastRecommend;

- (id)initWithGalleryItem:(GalleryItem *)galleryItem isOnlineMode:(BOOL)isOnlineMode;
- (id)initWithTermId:(NSString*)termId newsId:(NSString*)newsId channelId:(NSString*)channelId isOnlineMode:(BOOL)isOnlineMode;

- (BOOL)hasMoreRecommend;

- (BOOL)hasFirstPhotoOfNextGroup;

- (BOOL)hasPrevMoreRecommends;

- (BOOL)hasLastPhotoOfPrevGroup;

// for ad sdk
- (BOOL)hasSdkAdData;

- (void)load:(TTURLRequestCachePolicy)cachePolicy more:(BOOL)more;

@end
