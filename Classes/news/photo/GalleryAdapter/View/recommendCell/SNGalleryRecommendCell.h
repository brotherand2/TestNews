//
//  SNGalleryRecommendCell.h
//  SNNewGallery
//
//  Created by H.Ekko on 04/01/2017.
//  Copyright © 2017 Huang Zhen. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SNPhotoSlideshowRecommendView.h"

@protocol SNGalleryRecommendCellDelegate <NSObject>

- (void)photoDidRecommendAtNewsId:(NSString *)newsId;

- (void)closeGalleryBroswer;

@end

@interface SNGalleryRecommendCell : UICollectionViewCell

@property (nonatomic, strong) SNPhotoSlideshowRecommendView * recommendView;

@property (nonatomic, strong) NSArray * recommendData;

@property (nonatomic, weak) id <SNGalleryRecommendCellDelegate>delegate;

- (void)setLastRecomAd:(SNAdDataCarrier *)lastRecomAd lastSecond:(SNAdDataCarrier *)lastSecondAd;

- (void)recommendViewDidDispaly;

@end
