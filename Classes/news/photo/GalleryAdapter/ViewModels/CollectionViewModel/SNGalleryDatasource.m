//
//  SNGalleryDatasource.m
//  SNNewGallery
//
//  Created by H.Ekko on 04/01/2017.
//  Copyright © 2017 Huang Zhen. All rights reserved.
//

#import "SNGalleryDatasource.h"
#import "SNGalleryConst.h"

@interface SNGalleryDatasource ()

@end

@implementation SNGalleryDatasource

#pragma mark <UICollectionViewDataSource>

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    NSInteger count = 0;
    if (self.article.newsImageItems) {//图文新闻
        count = self.article.newsImageItems.count;
        if (self.lastBigAd) {
            count += 1;
        }
    }
    else if(self.galleryItem.gallerySubItems){//组图新闻
        count = self.galleryItem.gallerySubItems.count;
        if (self.galleryItem.moreRecommends.count > 0) {//有组图推荐
            count += 1;
        }
        if (self.lastBigAd.adImageUrl.length > 0) {
            count += 1;
        }
    }
    return count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    //图文新闻
    if (self.article) {
        //图文新闻最后一帧为广告
        if (indexPath.row == self.article.newsImageItems.count && self.lastBigAd.adImageUrl.length > 0) {
            SNGalleryAdCell * adCell = [collectionView dequeueReusableCellWithReuseIdentifier:SNGalleryAdCellReuseIdentifier forIndexPath:indexPath];
            adCell.adCarrier = self.lastBigAd;
            return adCell;
        }
    }
    //组图新闻
    else if (self.galleryItem) {
        //如果有广告，需要在组图推荐和图集中间插入一帧广告
        if (self.lastBigAd.adImageUrl.length > 0) {
            //最后一帧为组图推荐
            if (indexPath.row == self.galleryItem.gallerySubItems.count + 1) {
                SNGalleryRecommendCell * recCell = [collectionView dequeueReusableCellWithReuseIdentifier:SNGalleryRecommendCellReuseIdentifier forIndexPath:indexPath];
                recCell.recommendData = self.galleryItem.moreRecommends;
                if (self.lastRecomAd.adImageUrl.length > 0 || self.lastSecondRecomAd.adImageUrl.length > 0) {
                    [recCell setLastRecomAd:self.lastRecomAd lastSecond:self.lastSecondRecomAd];
                }
                return recCell;
            }
            else if (indexPath.row == self.galleryItem.gallerySubItems.count) {
                SNGalleryAdCell * adCell = [collectionView dequeueReusableCellWithReuseIdentifier:SNGalleryAdCellReuseIdentifier forIndexPath:indexPath];
                adCell.adCarrier = self.lastBigAd;
                return adCell;
            }

        }
        //最后一帧为组图推荐
        if (indexPath.row == self.galleryItem.gallerySubItems.count) {
            SNGalleryRecommendCell * recCell = [collectionView dequeueReusableCellWithReuseIdentifier:SNGalleryRecommendCellReuseIdentifier forIndexPath:indexPath];
            if (self.lastRecomAd.adImageUrl.length > 0 || self.lastSecondRecomAd.adImageUrl.length > 0) {
                [recCell setLastRecomAd:self.lastRecomAd lastSecond:self.lastSecondRecomAd];
            }
            recCell.recommendData = self.galleryItem.moreRecommends;
            return recCell;
        }
    }
    
    SNGalleryPhotoCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:SNGalleryPhotoCellReuseIdentifier forIndexPath:indexPath];
    cell.indexPath = indexPath;
    [cell resetZoomingScale];
    if (self.article.newsImageItems && indexPath.row < self.article.newsImageItems.count) {
        NewsImageItem * imageItem = self.article.newsImageItems[indexPath.row];
        if (imageItem && [imageItem isKindOfClass:[NewsImageItem class]]) {
            [cell loadImageWithUrl:imageItem.url];
        }
    }else if (self.galleryItem.gallerySubItems && indexPath.row < self.galleryItem.gallerySubItems.count) {
        PhotoItem * photoItem = self.galleryItem.gallerySubItems[indexPath.row];
        if (photoItem && [photoItem isKindOfClass:[PhotoItem class]]) {
            [cell loadImageWithUrl:photoItem.url];
        }
    }
    return cell;
}

@end
