//
//  SNGalleryRecommendCell.m
//  SNNewGallery
//
//  Created by H.Ekko on 04/01/2017.
//  Copyright © 2017 Huang Zhen. All rights reserved.
//

#import "SNGalleryRecommendCell.h"
#import "SNGalleryConst.h"

@interface SNGalleryRecommendCell ()<SNPhotoSlideshowRecommendViewDelegate>


@end

@implementation SNGalleryRecommendCell

#pragma mark - private

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        self.backgroundColor = [UIColor clearColor];
        [self initContent];
    }
    return self;
}

- (void)initContent {
    self.recommendView = [[SNPhotoSlideshowRecommendView alloc] initWithRecommends:self.recommendData delegate:self hasNextGroup:YES adDataCarrier:nil ad13371:nil];
    self.recommendView.frame = CGRectMake(kLeftOffset, 0, TTScreenBounds().size.width, TTScreenBounds().size.height);
    [self addSubview:self.recommendView];
}

- (void)setRecommendData:(NSArray *)recommendData {
    if (_recommendData == recommendData) {
        return;
    }
    _recommendData = recommendData;
    self.recommendView.moreRecommends = recommendData;
    [self.recommendView loadImageWithAdDataCarrier:nil ad13371:nil];
}

- (void)photoDidRecommendAtNewsId:(NSString *)newsId {
    if (self.delegate && [self.delegate respondsToSelector:@selector(photoDidRecommendAtNewsId:)]) {
        [self.delegate photoDidRecommendAtNewsId:newsId];
    }
}

- (void)closeGalleryBroswer {
    if (self.delegate && [self.delegate respondsToSelector:@selector(closeGalleryBroswer)]) {
        [self.delegate closeGalleryBroswer];
    }
}

- (void)setLastRecomAd:(SNAdDataCarrier *)lastRecomAd lastSecond:(SNAdDataCarrier *)lastSecondAd {
    [self.recommendView loadImageWithAdDataCarrier:lastRecomAd ad13371:lastSecondAd];
}

- (void)recommendViewDidDispaly {
    [self.recommendView reportAdDisplay];
}

@end
