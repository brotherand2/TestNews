//
//  SNPhotoListRecommendView.h
//  sohunews
//
//  Created by 雪 李 on 11-12-29.
//  Copyright (c) 2011年 Sohu.com Inc. All rights reserved.
//

@class RecommendGallery;
@class SNWebImageView;

@interface SNPhotoListRecommendView : UIView
{
    SNWebImageView *_recommendIconView;
    UILabel     *_recommendTitle;
    NSString    *_urlPath;
    id          _delegate;
    BOOL        _isIconLoaded;
}

-(id)initWithRecommendGallery:(RecommendGallery*)recommendItem frame:(CGRect)frame delegate:(id)delegate;
-(BOOL)isRecommendIconLoaded;
- (void)setUrlPath:(NSString *)urlPath;
- (void)updateTheme;
- (void)clickToLoadImage:(NSString *)urlPath;

@end
