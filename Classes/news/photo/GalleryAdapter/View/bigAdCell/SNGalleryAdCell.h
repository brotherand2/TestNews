//
//  SNGalleryAdCell.h
//  SNNewGallery
//
//  Created by H.Ekko on 04/01/2017.
//  Copyright © 2017 Huang Zhen. All rights reserved.
//

#import <UIKit/UIKit.h>

@class SNAdDataCarrier;

@interface SNGalleryAdCell : UICollectionViewCell

@property (nonatomic, strong) SNAdDataCarrier * adCarrier;

@property (nonatomic, strong) UIImageView * adImageView;

@property (nonatomic, assign,readonly) BOOL isLoadingImage;

@end
