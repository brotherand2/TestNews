//
//  SNGalleryBrowserController.h
//  sohunews
//
//  Created by HuangZhen on 2017/5/4.
//  Copyright © 2017年 Sohu.com. All rights reserved.
//

#import "SNBaseViewController.h"
#import "SNGalleryConst.h"
#import "SNDBManager.h"
#import "SNArticle.h"

@protocol SNGalleryBrowserDelegate <NSObject>

@optional

/**
 图集浏览器的打开回调
 */
- (void)galleryBrowserDidShow;

/**
 图集浏览器关闭回调
 */
- (void)galleryBrowserDidClose;

/**
 图集浏览器切换图片
 
 @param url 图片的url
 @param index 图片的index
 */
- (void)galleryBrowserDidChangePhoto:(NSString *)url index:(NSUInteger)index;

/**
 根据图片url返回图片在正文的rect
 
 @param imageUrl 图片url
 @return 图片在正文页的rect
 */
- (CGRect)rectForgalleryBrowserImageUrl:(NSString *)imageUrl;

/**
 图集浏览器切换到下一新闻
 
 @param gid 下一组图新闻的gid
 */
- (void)galleryBrowserDidChangeNews:(NSString *)gid newsId:(NSString *)newsId channelId:(NSString *)channelId;

/**
 分享
 
 @param isGroupPhotos 是否是组图新闻
 @param index 当前的index
 @param image 当前要分享的image
 @param isAd 是否是广告
 */
- (void)sharePhotoWithGalleryType:(BOOL)isGroupPhotos currentIndex:(NSInteger)index photo:(UIImage *)image isAD:(BOOL)isAd;
/**
 长按图片的分享
 */
- (void)shareLongpressPhoto:(UIImage *)image imgUrl:(NSString *)url index:(NSInteger)index;

@end

@class SNAdDataCarrier;
@interface SNGalleryBrowserController : SNBaseViewController

@property (nonatomic, weak) id <SNGalleryBrowserDelegate> delegate;
@property (nonatomic, copy) NSString * newsId;
@property (nonatomic, copy) NSString * channelId;
@property (nonatomic, strong) NSArray * allNewsId;

- (void)setArticleGalleryDatasource:(SNArticle *)article;

- (void)setPhotoGalleryDatasource:(GalleryItem *)galleryItem;

- (void)showAtIndex:(NSUInteger)index dissmiss:(GalleryDismissBlock)dissmissBlock;

#pragma mark - 广告相关

/**
 设置最后一帧大图广告  itemspaceId = 12233
 
 @param adCarrier 广告的数据结构
 */
- (void)setLastBigAd:(SNAdDataCarrier *)adCarrier;

/**
 设置组图推荐最后两个小图广告
 
 @param lastAd 倒数第一个  itemspaceId = 12238
 @param lastSecondAd 倒数第二个  itemspaceId = 12716
 */
- (void)setLastRecomAd:(SNAdDataCarrier *)lastAd lastSecond:(SNAdDataCarrier *)lastSecondAd;

@end
