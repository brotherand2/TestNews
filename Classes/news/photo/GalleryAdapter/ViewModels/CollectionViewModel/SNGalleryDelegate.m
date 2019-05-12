//
//  SNGalleryCollectionViewDelegate.m
//  SNNewGallery
//
//  Created by H.Ekko on 04/01/2017.
//  Copyright © 2017 Huang Zhen. All rights reserved.
//

#import "SNGalleryDelegate.h"
#import "SNGalleryConst.h"
#import "SNGalleryBrowserView.h"

@interface SNGalleryDelegate(){
    
}

@end

@implementation SNGalleryDelegate

#pragma mark <UICollectionViewDelegate>

- (void)collectionView:(UICollectionView *)collectionView willDisplayCell:(UICollectionViewCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath
{
}

- (void)collectionView:(UICollectionView *)collectionView didEndDisplayingCell:(UICollectionViewCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath
{
}

- (void)collectionView:(UICollectionView *)collectionView didEndDisplayingSupplementaryView:(UICollectionReusableView *)view forElementOfKind:(NSString *)elementKind atIndexPath:(NSIndexPath *)indexPath
{
}

#pragma mark <UIScrollViewDelegate>
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    CGFloat offset = scrollView.contentOffset.x;
    NSInteger index = offset/kScreenWidth;
    
    [self.browserView setCurrentIndex:index];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    [self.browserView collectionViewDidScroll:scrollView.contentOffset.x];
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    [self.browserView collectionViewDidEndDragging:scrollView willDecelerate:decelerate];
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    [self.browserView collectionViewWillBeginDragging:scrollView];
}

#pragma mark <SNGalleryPhotoCellDelegate>
- (void)photoDidScroll:(UIScrollView *)scrollView {
    [self.browserView photoDidScroll:scrollView];
}
- (void)photoCellDidResetZoom {
    
}
- (void)photoCellDidZoom:(BOOL)big {
    [self.browserView photoDidZoom:big];
}

- (void)photoCellDidTap {
    //设置导航条隐藏还是显示
    [self.browserView setHeaderAndFooterHide];
}

#pragma mark SNGalleryRecommendCellDelegate
- (void)photoDidRecommendAtNewsId:(NSString *)newsId{
    [self.browserView recommendGalleryDidClickWithNewsId:newsId];
}

- (void)closeGalleryBroswer{
    [self.browserView dismissWithRestore:YES];
}


@end
