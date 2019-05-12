//
//  SNGalleryPhotoCell.h
//  SNNewGallery
//
//  Created by H.Ekko on 04/01/2017.
//  Copyright © 2017 Huang Zhen. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol SNGalleryPhotoCellDelegate <NSObject>
@optional
- (void)photoDidScroll:(UIScrollView *)scrollView;
- (void)photoCellDidZoom:(BOOL)big;
- (void)photoCellDidResetZoom;
- (void)photoCellDidTap;

@end

@interface SNGalleryPhotoCell : UICollectionViewCell

@property (nonatomic, strong) UIScrollView *scrollView;

@property (nonatomic, strong) UIImageView * photoView;

@property (nonatomic, strong) UIImage *placeholderImage;

@property (nonatomic, strong) NSIndexPath *indexPath;

@property (nonatomic, assign,readonly) BOOL isLoadingImage;

@property (nonatomic, weak) id <SNGalleryPhotoCellDelegate> delegate;

- (void)resetZoomingScale;

- (void)loadImageWithUrl:(NSString *)urlString;

@end
