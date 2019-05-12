//
//  SNGalleryDatasource.h
//  SNNewGallery
//
//  Created by H.Ekko on 04/01/2017.
//  Copyright © 2017 Huang Zhen. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "SNArticle.h"
#import "SNAdDataCarrier.h"

@interface SNGalleryDatasource : NSObject<UICollectionViewDataSource>

/**
 默认图
 */
@property (nonatomic, strong) UIImage * placeholderImage;

/**
 网络图片的urls
 */
@property (nonatomic, strong) NSArray * imageUrls;

/**
 本地图片的images
 */
@property (nonatomic, strong) NSArray * images;

/**
 图文新闻文章数据源
 */
@property (nonatomic, strong) SNArticle * article;

/**
 组图新闻文章数据源
 */
@property (nonatomic, strong) GalleryItem * galleryItem;

#pragma mark - 广告数据
/**
 设置最后一帧大图广告  itemspaceId = 12233
 
广告的数据结构
 */
@property (nonatomic, strong) SNAdDataCarrier * lastBigAd;

/**
 倒数第一个组图推荐广告  itemspaceId = 12238
 */
@property (nonatomic, strong) SNAdDataCarrier * lastRecomAd;

/**
 倒数第二个组图推荐广告  itemspaceId = 12716
 */
@property (nonatomic, strong) SNAdDataCarrier * lastSecondRecomAd;

@end
