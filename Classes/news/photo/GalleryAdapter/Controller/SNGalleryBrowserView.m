//
//  SNGalleryBrowserView.m
//  SNNewGallery
//
//  Created by H.Ekko on 03/01/2017.
//  Copyright © 2017 Huang Zhen. All rights reserved.
//

#import "SNGalleryBrowserView.h"
#import "SNGalleryDelegate.h"
#import "SNGalleryDatasource.h"
#import "SNGalleryConst.h"
#import "SNGalleryBrowserFooter.h"
#import "SNDBManager.h"
#import "SNActionMenuController.h"
#import "SNMyFavouriteManager.h"
#import "SNGroupPicturesFavourite.h"
#import "SNNewsShareManager.h"
#import "UIViewAdditions.h"
#import "SNLongPressAlert.h"

#define  kDistance           (100.f)

#define  kAlphaDistance      ([UIScreen mainScreen].bounds.size.height/2.f)

@interface SNGalleryBrowserView ()<UIGestureRecognizerDelegate>{
    NSIndexPath *_zoomingIndexPath;
    CGRect _originalRect;
    BOOL _photoDidZoom;
    BOOL _browserHeaderAndFooterDidHide;
    BOOL _quitDirectionUp;
    UILongPressGestureRecognizer * longpress;
    UIPanGestureRecognizer * _panGesture;
}

@property (nonatomic, strong) SNNewsShareManager* shareManager;

@property (nonatomic, strong) UICollectionView * collectionView;

@property (nonatomic, strong) SNGalleryDelegate * collectionDelegate;

@property (nonatomic, strong) SNGalleryDatasource * collectionDatasource;

@property (nonatomic, strong) UIPageControl * pageControl;

@property (nonatomic, strong) SNGalleryBrowserFooter * footer;

@property (nonatomic, strong) SNActionMenuController * actionMenuController;

@property (nonatomic, strong) SNLongPressAlert *longPressAlert;

@end

@implementation SNGalleryBrowserView

#pragma mark - public method

- (void)setImages:(NSArray *)images {
    if (!self.collectionDatasource) {
        self.collectionDatasource = [SNGalleryDatasource new];
    }
    [self addPageControl];
    //只能有一份数据源
    self.collectionDatasource.imageUrls = nil;
    self.collectionDatasource.article = nil;
    self.collectionDatasource.galleryItem = nil;
    self.collectionDatasource.images = images;
}

- (void)setImageUrls:(NSArray *)imageUrls {
    if (!self.collectionDatasource) {
        self.collectionDatasource = [SNGalleryDatasource new];
    }
    [self addPageControl];
    self.collectionDatasource.images = nil;
    self.collectionDatasource.article = nil;
    self.collectionDatasource.galleryItem = nil;
    self.collectionDatasource.imageUrls = imageUrls;
    self.pageControl.hidden = imageUrls.count <= 1;
    self.pageControl.numberOfPages = imageUrls.count > 0 ? imageUrls.count : 0;
}

- (void)setArticle:(SNArticle *)article {
    if (article.newsImageItems.count <= 0) {
        return;
    }
    if (!self.collectionDatasource) {
        self.collectionDatasource = [SNGalleryDatasource new];
    }
    //只能有一份数据源
    self.collectionDatasource.imageUrls = nil;
    self.collectionDatasource.images = nil;
    self.collectionDatasource.galleryItem = nil;
    self.collectionDatasource.lastRecomAd = nil;
    self.collectionDatasource.lastSecondRecomAd = nil;
    self.collectionDatasource.lastBigAd = nil;

    self.collectionDatasource.article = article;
    self.pageControl.hidden = article.newsImageItems.count <= 1;
    self.pageControl.numberOfPages = article.newsImageItems.count > 0 ? article.newsImageItems.count : 0;

    [self prepareSubInfoHeaderView];
    [self prepareFooterViewWithIndex:0];
}

- (void)setGalleryItem:(GalleryItem *)galleryItem isNext:(BOOL)isNext{
    if (galleryItem.gallerySubItems.count <= 0) {
        return;
    }
    if (!self.collectionDatasource) {
        self.collectionDatasource = [SNGalleryDatasource new];
    }
    //只能有一份数据源
    self.collectionDatasource.imageUrls = nil;
    self.collectionDatasource.images = nil;
    self.collectionDatasource.article = nil;
    self.collectionDatasource.galleryItem = galleryItem;
    self.collectionDatasource.lastRecomAd = nil;
    self.collectionDatasource.lastSecondRecomAd = nil;
    self.collectionDatasource.lastBigAd = nil;

    self.galleryId = galleryItem.gId;
    self.newsId = galleryItem.newsId;
    self.pageControl.hidden = galleryItem.gallerySubItems.count <= 1;
    self.pageControl.numberOfPages = galleryItem.gallerySubItems.count > 0 ? galleryItem.gallerySubItems.count : 0;
    [self prepareSubInfoHeaderView];
    NSUInteger defaultIndex = 0;
    if (!isNext) {
        defaultIndex = galleryItem.gallerySubItems.count - 1;
    }
    [self prepareFooterViewWithIndex:defaultIndex];
}

#pragma mark - private method

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame: frame]) {
        
        self.backgroundColor = [UIColor blackColor];
        
        self.currentIndex = 0;
        
        [self configCollectionView];
        
        [self configDelegateAndDatasource];
        
        [self addCloseGesture];
        
        [self addLongpressGesture];
        
        //生成nav和footer
        [self createHeaderAndFooter];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(photoCellDidZooming:) name:kPhotoCellDidZommingNotification object:nil];
        [[NSNotificationCenter defaultCenter ] addObserver:self selector:@selector (statusBarFrameWillChange:) name : UIApplicationWillChangeStatusBarFrameNotification object:nil ];
        [[NSNotificationCenter defaultCenter ] addObserver:self selector:@selector (statusBarFrameDidChange:) name : UIApplicationDidChangeStatusBarFrameNotification object:nil];
    }
    return self;
}

- (void)addLongpressGesture {
    longpress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longGesturePress:)];
    [self addGestureRecognizer:longpress];
}
- (void)longGesturePress:(UIGestureRecognizer*)gesture{
    if ([gesture isKindOfClass:[UILongPressGestureRecognizer class]]) {
        UILongPressGestureRecognizer* press = (UILongPressGestureRecognizer*)gesture;
        BOOL hasAd = self.collectionDatasource.lastBigAd;
        NSInteger dataCount = 0;
        if (self.browserType == SNGalleryBrowserTypeImage) {
            dataCount = self.collectionDatasource.article.newsImageItems.count;
            if (_currentIndex >= (hasAd ? dataCount + 1 : dataCount)) {
                return;
            }
        }else if(self.browserType == SNGalleryBrowserTypeGroup){
            dataCount = self.collectionDatasource.galleryItem.gallerySubItems.count;
            if (_currentIndex >= (hasAd ? dataCount + 1 : dataCount)) {
                return;
            }
        }else{
        
        }
        NSString* url = self.currentImageUrl;
        if (hasAd && _currentIndex == dataCount) {
            url = self.collectionDatasource.lastBigAd.adImageUrl;
        }
        if (gesture.state == UIGestureRecognizerStateBegan) {//开始的时候弹起
            [self longPress:url];
        }
        else if (gesture.state == UIGestureRecognizerStateEnded) { //要判断状态...
            
        }
    }
}

- (void)longPress:(NSString *)url {
    
    __weak typeof(self)weakself = self;
    [self.longPressAlert showLongPressAlertWithShareBlock:^{
        if (weakself.delegate && [weakself.delegate respondsToSelector:@selector(shareLongpressPhoto:imgUrl:index:)]) {
            [weakself.delegate shareLongpressPhoto:weakself.currentPhotoView.image imgUrl:url index:weakself.currentIndex];
        }
    } andSaveBlock:^{
        NSURL* img_url = [NSURL URLWithString:url];
        NSData* data = [NSData dataWithContentsOfURL:img_url];
        UIImage* saveImage = [UIImage imageWithData:data];
        UIImageWriteToSavedPhotosAlbum(saveImage, weakself,
                                       @selector(image:didFinishSavingWithError:contextInfo:), nil);
        [SNNewsReport reportADotGif:@"_act=download&_tp=pho&from=pics"];
    }];
}

- (void)callShare:(NSDictionary*)paramsDic{
    if (self.shareManager) {
        self.shareManager = nil;
    }
    self.shareManager = [SNNewsShareManager loadShareData:paramsDic Delegate:self];
}

- (void)addPageControl {
    if (!self.pageControl) {
        self.pageControl = [[UIPageControl alloc] initWithFrame:CGRectZero];
        self.pageControl.center = CGPointMake(self.frame.size.width/2.f, self.frame.size.height - 60);
        self.pageControl.currentPage = _currentIndex;
        [self addSubview:self.pageControl];
    }
}

- (void)configCollectionView {
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
    layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    layout.minimumInteritemSpacing = 0;
    layout.minimumLineSpacing = 0;
    
    layout.itemSize = CGSizeMake(kScreenRect.size.width + 2 * kLeftOffset, kScreenRect.size.height);
    
    UICollectionView *collectionView = [[UICollectionView alloc]initWithFrame:CGRectMake(-kLeftOffset, 0, self.frame.size.width + 2 * kLeftOffset , self.frame.size.height) collectionViewLayout:layout];
    collectionView.backgroundColor = [UIColor clearColor];
    collectionView.pagingEnabled = YES;
    collectionView.showsHorizontalScrollIndicator = NO;
    
    [collectionView registerClass:[SNGalleryPhotoCell class]
       forCellWithReuseIdentifier:SNGalleryPhotoCellReuseIdentifier];
    [collectionView registerClass:[SNGalleryAdCell class]
       forCellWithReuseIdentifier:SNGalleryAdCellReuseIdentifier];
    [collectionView registerClass:[SNGalleryRecommendCell class]
       forCellWithReuseIdentifier:SNGalleryRecommendCellReuseIdentifier];
    
    self.collectionView = collectionView;
    self.collectionView.alwaysBounceHorizontal = YES;
    [self addSubview:collectionView];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    UICollectionViewFlowLayout *layout = (UICollectionViewFlowLayout *)self.collectionView.collectionViewLayout;
    layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    layout.minimumInteritemSpacing = 0;
    layout.minimumLineSpacing = 0;
    layout.itemSize = CGSizeMake(kScreenRect.size.width + 2 * kLeftOffset, kScreenRect.size.height);
    self.collectionView.frame = CGRectMake(-kLeftOffset, 0, self.frame.size.width + 2 * kLeftOffset , self.frame.size.height);
}

- (void)configDelegateAndDatasource {
    self.collectionDelegate = [[SNGalleryDelegate alloc] init];
    self.collectionDelegate.browserView = self;
    self.collectionDelegate.m_collectionView = self.collectionView;
    self.collectionView.delegate = self.collectionDelegate;
    
    self.collectionDatasource = [[SNGalleryDatasource alloc] init];
    self.collectionView.dataSource = self.collectionDatasource;
    self.collectionDatasource.placeholderImage = [UIImage themeImageNamed:@"app_logo_gray.png"];
}

- (void)setCurrentImageRect {
    if (self.delegate && [self.delegate respondsToSelector:@selector(rectForImageUrl:)]) {
        self.currentRect = [self.delegate rectForImageUrl:self.currentImageUrl];
    }
}

- (void)setCurrentView {
    NSIndexPath * indexPath = [NSIndexPath indexPathForRow:_currentIndex inSection:0];
    UICollectionViewCell *cell = [_collectionView cellForItemAtIndexPath:indexPath];
    if (nil == cell) {
        /// nil 的原因是 collectionView 还没有加载完毕
        /// 如果一直是 nil 的话，slide 退出时动画会有问题，需要在 collectionView 加载完毕后再设置一遍
        SNDebugLog(@"SNGalleryBrowser current cell is Nil");
        return;
    }

    if ([cell isKindOfClass:[SNGalleryPhotoCell class]]) {
        SNGalleryPhotoCell * photoCell = (SNGalleryPhotoCell *)cell;
        photoCell.delegate = self.collectionDelegate;
        self.currentPhotoView = photoCell.photoView;
        self.currentCell = photoCell;
        //[self headerViewDisplay];
    }else if([cell isKindOfClass:[SNGalleryRecommendCell class]]){
        SNGalleryRecommendCell * recommendCell = (SNGalleryRecommendCell *)cell;
        recommendCell.delegate = self.collectionDelegate;
        self.currentCell = recommendCell;
        self.currentRecommendView = recommendCell.recommendView;
    }else if ([cell isKindOfClass:[SNGalleryAdCell class]]) {
        SNGalleryAdCell * adCell = (SNGalleryAdCell *)cell;
        self.currentCell = adCell;
        self.currentADView = adCell.adImageView;
        [adCell.adCarrier reportForDisplayTrack];
    }

}

- (void)setContentOffset {
    [self.collectionView setContentOffset:CGPointMake(_currentIndex * _collectionView.frame.size.width, 0)];
}

- (void)setCurrentIndex:(NSUInteger)currentIndex {
    //setIndex
    _currentIndex = currentIndex;
    //pageControl 现在没有
    self.pageControl.currentPage = _currentIndex;
    //设置当前对应的cell
    [self setCurrentView];
    if (self.browserType == SNGalleryBrowserTypeGroup) {
        if (_currentIndex < self.collectionDatasource.galleryItem.gallerySubItems.count) {
            PhotoItem * photoItem = self.collectionDatasource.galleryItem.gallerySubItems[_currentIndex];
            if (photoItem && [photoItem isKindOfClass:[PhotoItem class]]) {
                self.currentImageUrl = photoItem.url;
                if (self.delegate && [self.delegate respondsToSelector:@selector(didChangePhoto:index:)] ) {
                    [self.delegate didChangePhoto:photoItem.url index:_currentIndex];
                }
            }
        }
    }else if (self.browserType == SNGalleryBrowserTypeImage) {
        if (_currentIndex < self.collectionDatasource.article.newsImageItems.count) {
            NewsImageItem * imageItem = self.collectionDatasource.article.newsImageItems[_currentIndex];
            if (imageItem && [imageItem isKindOfClass:[NewsImageItem class]]) {
                self.currentImageUrl = imageItem.url;
                if (self.delegate && [self.delegate respondsToSelector:@selector(didChangePhoto:index:)]){
                    [self.delegate didChangePhoto:imageItem.url index:_currentIndex];
                }
            }
        }
    }
    //通知正文页滚动到相应的位置
    [self setCurrentImageRect];
    [self prepareFooterViewWithIndex:_currentIndex];
}

/**
 加载下一组图
 */
- (void)loadNextGroupPhoto:(BOOL)isNext {
//    SNDebugLog(@"******************** did load next group photo");
    //滚动到广告或者组图推荐，开始预加载下一组图
    if (self.browserType == SNGalleryBrowserTypeGroup) {
        if (isNext) {
            if (self.delegate && [self.delegate respondsToSelector:@selector(prepareForNextGalleryNews:)]) {
                [self.delegate prepareForNextGalleryNews:self.collectionDatasource.galleryItem.nextId];
            }
        }else {
            if (self.delegate && [self.delegate respondsToSelector:@selector(prepareForPreGalleryNews:)]) {
                [self.delegate prepareForPreGalleryNews:nil];
            }
        }
    }

}

- (void)photoDidZoom:(BOOL)big {
    _photoDidZoom = big;
}
- (void)photoDidScroll:(UIScrollView *)scrollView {
}
- (void)recommendGalleryDidClickWithNewsId:(NSString *)newsId {
    if ([self.delegate respondsToSelector:@selector(changeBrowserViewFromRecommend:)]) {
        [self.delegate changeBrowserViewFromRecommend:newsId];
    }
}

/**
 拖拽关闭图片浏览器
 */
- (void)addCloseGesture {
    _panGesture = [[UIPanGestureRecognizer alloc]
                            initWithTarget:self
                            action:@selector(handlePan:)];
    _panGesture.maximumNumberOfTouches = 1;
    _panGesture.delegate = self;
    [self addGestureRecognizer:_panGesture];
}

- (void)handlePan:(UIPanGestureRecognizer *)pan {
    //如果没有当前的imageView
    if (!self.currentPhotoView) {
        SNDebugLog(@"SNGalleryBrowserView Error : current imageView is nil, can't pan to close.");
        return;
    }
    if (_photoDidZoom) {
        return;
    }
    CGPoint translation = [pan translationInView:pan.view];

    if (pan.state == UIGestureRecognizerStateBegan) {

        _originalRect = self.currentPhotoView.frame;
        if ([self.delegate respondsToSelector:@selector(updateStatusBarHidden:)]) {
            [self.delegate updateStatusBarHidden:YES];
        }
        [UIView animateWithDuration:0.25 animations:^{
            self.header.alpha = 0;
            self.footer.alpha = 0;
        }];
    }
    else if (pan.state == UIGestureRecognizerStateEnded ||
        pan.state == UIGestureRecognizerStateCancelled) {
        
        //达到拖拽的最大限度 执行消失动画 关闭图集浏览器
        if (fabsf(translation.y) > kDistance) {
            [self dismissWithRestore:NO];
            return;
        }
        if ([self.delegate respondsToSelector:@selector(updateStatusBarHidden:)]) {
            [self.delegate updateStatusBarHidden:NO];
        }
        [UIView animateWithDuration:0.25 animations:^{
            self.currentPhotoView.transform = CGAffineTransformIdentity;
            self.currentPhotoView.frame = _originalRect;
            self.currentRecommendView.transform = CGAffineTransformIdentity;
            self.currentRecommendView.frame = CGRectMake(kLeftOffset, 0, TTScreenBounds().size.width, TTScreenBounds().size.height);
            self.currentADView.transform = CGAffineTransformIdentity;
            self.currentADView.frame = CGRectMake(kLeftOffset, 0, TTScreenBounds().size.width, TTScreenBounds().size.height);
            self.backgroundColor = [UIColor colorWithWhite:0 alpha:1];
            if (!_browserHeaderAndFooterDidHide) {
                if (self.currentIndex == 0) {
                    self.header.alpha = 1;
                }
            }
            self.footer.alpha = 1;
        }];
        return;
    }
    
    //向上拖拽
    if (translation.y <= 0) {
        _quitDirectionUp = YES;
        CGFloat alpha = (kAlphaDistance + translation.y * 0.5)/kAlphaDistance;
        self.backgroundColor = [UIColor colorWithWhite:0 alpha:alpha];
//        self.currentPhotoView.transform = CGAffineTransformMakeTranslation(translation.x * 0.4, translation.y * 0.8);
        self.currentPhotoView.transform = CGAffineTransformMakeTranslation(0 , translation.y);
        self.currentRecommendView.transform = CGAffineTransformMakeTranslation(0 , translation.y);
        self.currentADView.transform = CGAffineTransformMakeTranslation(0 , translation.y);
//        CGFloat scale = (kDistance + translation.y * 0.2)/kDistance;
//        self.currentPhotoView.transform = CGAffineTransformScale(self.currentPhotoView.transform,scale,scale);
    }
    //向下拖拽
    else{
        _quitDirectionUp = NO;
        CGFloat alpha = (kAlphaDistance - translation.y * 0.5)/kAlphaDistance;
        self.backgroundColor = [UIColor colorWithWhite:0 alpha:alpha];
//        self.currentPhotoView.transform = CGAffineTransformMakeTranslation(translation.x * 0.4, translation.y * 0.8);
        self.currentPhotoView.transform = CGAffineTransformMakeTranslation(0 , translation.y);
        self.currentRecommendView.transform = CGAffineTransformMakeTranslation(0 , translation.y);
        self.currentADView.transform = CGAffineTransformMakeTranslation(0 , translation.y);
//        CGFloat scale = (kDistance - translation.y * 0.2)/kDistance;
//        self.currentPhotoView.transform = CGAffineTransformScale(self.currentPhotoView.transform,scale,scale);
//        self.currentRecommendView.transform = CGAffineTransformScale(self.currentRecommendView.transform,scale,scale);
    }
}

- (void)dismissWithRestore:(BOOL)restore {
    //避免rect为零的问题，退出时检查一下当前图片位置
//    if (CGRectEqualToRect(self.currentRect, CGRectZero)) {
        if ([self.delegate respondsToSelector:@selector(rectForImageUrl:)]) {
            self.currentRect = [self.delegate rectForImageUrl:self.currentImageUrl];
        }
//    }
    if ([self.delegate respondsToSelector:@selector(updateStatusBarHidden:)]) {
        [self.delegate updateStatusBarHidden:YES];
    }

    [self.header removeFromSuperview];
    [self.footer removeFromSuperview];
    self.header = nil;
    self.footer = nil;
    
    CGRect dissMissRect = _quitDirectionUp ? CGRectMake(kLeftOffset, -kAppScreenHeight, kAppScreenWidth, kAppScreenHeight) : CGRectMake(kLeftOffset, kAppScreenHeight, kAppScreenWidth, kAppScreenHeight);
    
    CGRect photoDissMissRect = _quitDirectionUp ? CGRectMake(self.currentPhotoView.frame.origin.x, -kAppScreenHeight, self.currentPhotoView.frame.size.width, self.currentPhotoView.frame.size.height) : CGRectMake(self.currentPhotoView.frame.origin.x, kAppScreenHeight, self.currentPhotoView.frame.size.width, self.currentPhotoView.frame.size.height);
    
    BOOL isLoading = NO;
    if ([self.currentCell isKindOfClass:[SNGalleryPhotoCell class]]) {
        isLoading = ((SNGalleryPhotoCell *)_currentCell).isLoadingImage;
    }else if ([self.currentCell isKindOfClass:[SNGalleryAdCell class]]) {
        isLoading = ((SNGalleryAdCell *)_currentCell).isLoadingImage;
    }

    [UIView animateWithDuration:0.25 animations:^{
        if (isLoading) {
            self.alpha = 0;
        }else{
            self.backgroundColor = [UIColor colorWithWhite:0 alpha:0];
            if (_photoDidZoom) {
                self.currentPhotoView.alpha = 0;
            }else{
                self.currentPhotoView.frame = restore ? self.currentRect : photoDissMissRect;
            }
            if (restore) {
                self.currentRecommendView.alpha = 0;
                self.currentADView.alpha = 0;
            }else{
                self.currentRecommendView.frame = dissMissRect;
                self.currentADView.frame = dissMissRect;
            }
        }
    } completion:^(BOOL finished) {
        [self removeFromSuperview];
        if (self.dismissBlock) {
            self.dismissBlock(self.currentPhotoView.image,self.currentIndex);
        }
        if (self.delegate && [self.delegate respondsToSelector:@selector(didClose)]) {
            [self.delegate didClose];
        }
    }];
}

- (void)photoCellDidZooming:(NSNotification *)nofit {
    NSIndexPath *indexPath = nofit.object;
    _zoomingIndexPath = indexPath;
}

#pragma mark - UIGestureRecognizerDelegate
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
    SNDebugLog(@"gallery should recognize");
    if ([self.currentCell isKindOfClass:[SNGalleryPhotoCell class]]) {
        UIScrollView * scrollView = ((SNGalleryPhotoCell *)_currentCell).scrollView;
        if ([otherGestureRecognizer isKindOfClass:NSClassFromString(@"UIScrollViewPanGestureRecognizer")]
            && otherGestureRecognizer.view == ((SNGalleryPhotoCell *)_currentCell).scrollView) {
            CGPoint point = [(UIPanGestureRecognizer *)gestureRecognizer translationInView:self];
            int offsetY = scrollView.contentOffset.y;
            int diffsetY = scrollView.contentSize.height - scrollView.height;
            if (offsetY == 0 && point.y>0) {///offsetY等于0  并且手指继续向下滑动
                return YES;
            }
            if (offsetY == diffsetY && point.y<0) {///划到底部了，并且手指继续向上滑动
                return YES;
            }
        }
    }
    return NO;
}

#pragma mark - Header and Footer
- (void)createHeaderAndFooter {
    [self prepareSubInfoHeaderView];
    self.footer = [[SNGalleryBrowserFooter alloc] initWithFrame:CGRectMake(0, 0, kAppScreenWidth, 113.0f)];
    CGRect statusBarRect = [[UIApplication sharedApplication] statusBarFrame];
    if (statusBarRect.size.height == 40) {
        //开启了热点
        self.footer.bottom = self.height - 20;
    }else{
        self.footer.bottom = self.height;
    }
    
    if([[UIDevice currentDevice] platformTypeForSohuNews] == UIDeviceiPhoneX){
        self.footer.bottom = self.height-34;
    }
    
    __weak __typeof(self)weakSelf = self;
    [self.footer setBackButtonActionBlock:^{
        if ([weakSelf.delegate respondsToSelector:@selector(updateStatusBarHidden:)]) {
            [weakSelf.delegate updateStatusBarHidden:YES];
        }
        [weakSelf dismissWithRestore:YES];
    } downloadButtonActionBlock:^{
        [weakSelf downloadAction];
    } shareButtonActionBlock:^{
        [weakSelf shareAction];
    }];
    [self addSubview:self.footer];
    [self prepareFooterViewWithIndex:_currentIndex];
}

- (void)shareAction {
    if (self.delegate && [self.delegate respondsToSelector:@selector(sharePhotoWithGalleryType:currentIndex:photo:isAD:)]) {
        BOOL isAd = NO;
        UIImage * image = nil;
        if (self.browserType == SNGalleryBrowserTypeGroup) {
            if (_currentIndex == self.collectionDatasource.galleryItem.gallerySubItems.count && self.collectionDatasource.lastBigAd) {
                isAd = YES;
                image = self.currentADView.image;
            }else{
                isAd = NO;
                image = self.currentPhotoView.image;
            }
        }else if (self.browserType == SNGalleryBrowserTypeImage){
            if (_currentIndex == self.collectionDatasource.article.newsImageItems.count && self.collectionDatasource.lastBigAd) {
                isAd = YES;
                image = self.currentADView.image;
            }else{
                isAd = NO;
                image = self.currentPhotoView.image;
            }

        }
        [self.delegate sharePhotoWithGalleryType:self.browserType currentIndex:_currentIndex photo:image isAD:isAd];
    }
}

- (void)downloadAction
{
    UIImage *saveImage = self.currentPhotoView.image;
    if (saveImage)
    {
        UIImageWriteToSavedPhotosAlbum(saveImage, self, @selector(image:didFinishSavingWithError:contextInfo:), nil);
        [SNNewsReport reportADotGif:@"_act=download&_tp=pho&from=article_pics"];
    }
}

- (void)image:(UIImage *)image didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo
{
    SNDebugLog(@"照片失败%@", [error localizedDescription]);
    [[SNUtility getApplicationDelegate] image:image didFinishSavingWithError:error contextInfo:contextInfo];
}

- (void)prepareSubInfoHeaderView
{
    //所属刊物
    SCSubscribeObject *subObj = nil;
    if (self.browserType == SNGalleryBrowserTypeImage) {
        subObj = [[SNDBManager currentDataBase] getSubscribeCenterSubscribeObjectBySubId:self.collectionDatasource.article.subId];
    }else if (self.browserType == SNGalleryBrowserTypeGroup){
        subObj = [[SNDBManager currentDataBase] getSubscribeCenterSubscribeObjectBySubId:self.collectionDatasource.galleryItem.subId];
    }
    
    if (subObj && self.header && subObj.subName.length > 0)
    {
        self.header.subObj = subObj;
    }
    else if (subObj && subObj.subName.length > 0)
    {
        self.header = [[SNSubInfoView alloc] initWithSubInfoViewType:SNSubInfoViewTypeGallery];
        self.header.newsId = self.collectionDatasource.article.newsId ? : @"0";
        self.header.refer = REFER_GROUPPHOTOLIST;
        self.header.top = 5 + kSystemBarHeight;
        self.header.centerX = self.width/2.f;
        
        self.header.subObj = subObj;
        [self addSubview:self.header];
    }
    else if (self.header)
    {
        [self.header removeFromSuperview];
        self.header = nil;
    }
}

- (void)prepareFooterViewWithIndex:(NSInteger)index {
    if (self.browserType == SNGalleryBrowserTypeImage) {
        if (index >= self.collectionDatasource.article.newsImageItems.count) {
            return;
        }
        [self.footer updateAbstract:@""
                              title:self.collectionDatasource.article.title
                       currentIndex:index
                              total:self.collectionDatasource.article.newsImageItems.count];
        
    }else if (self.browserType == SNGalleryBrowserTypeGroup) {
        if (index >= self.collectionDatasource.galleryItem.gallerySubItems.count) {
            return;
        }
        PhotoItem * photoItem = self.collectionDatasource.galleryItem.gallerySubItems[index];
        
        if (photoItem && [photoItem isKindOfClass:[PhotoItem class]]) {
            
            [self.footer updateAbstract:photoItem.abstract
                                  title:self.collectionDatasource.galleryItem.title
                           currentIndex:index
                                  total:self.collectionDatasource.galleryItem.gallerySubItems.count];
        }
    }
}

- (void)updateFooterIndex:(NSUInteger)index{
    if (self.browserType == SNGalleryBrowserTypeImage) {
        if (index >= self.collectionDatasource.article.newsImageItems.count) {
            return;
        }
        [self.footer updateIndex:index count:self.collectionDatasource.article.newsImageItems.count];
        
    }else if (self.browserType == SNGalleryBrowserTypeGroup) {
        if (index >= self.collectionDatasource.galleryItem.gallerySubItems.count) {
            return;
        }
        PhotoItem * photoItem = self.collectionDatasource.galleryItem.gallerySubItems[index];
        if (photoItem && [photoItem isKindOfClass:[PhotoItem class]]) {
            [self.footer updateIndex:index count:self.collectionDatasource.galleryItem.gallerySubItems.count];
        }
    }

}

- (void)setHeaderAndFooterHide{
    _browserHeaderAndFooterDidHide = !_browserHeaderAndFooterDidHide;
    [UIView animateWithDuration:0.25 animations:^{
        if (_currentIndex == 0) {
            self.header.alpha = !_browserHeaderAndFooterDidHide;
        }
        self.footer.titleLabel.alpha            = !_browserHeaderAndFooterDidHide;
        self.footer.indexLabel.alpha            = !_browserHeaderAndFooterDidHide;
        self.footer.downloadButton.alpha        = !_browserHeaderAndFooterDidHide;
        self.footer.abstractContentView.alpha   = !_browserHeaderAndFooterDidHide;
        self.footer.shareButton.alpha           = !_browserHeaderAndFooterDidHide;
        self.footer.backButton.alpha            = !_browserHeaderAndFooterDidHide;
        self.footer.maskImageView.alpha         = !_browserHeaderAndFooterDidHide;
    }];
}

//@qz
-(void)abtestHeaderUpdate:(NSInteger)index offset:(CGFloat)offsetX{
    return;
    
    NSInteger numbers = [_collectionView numberOfItemsInSection:0];
    if (index+1 < numbers) {
        UICollectionViewCell *cell = [_collectionView cellForItemAtIndexPath:[NSIndexPath indexPathForRow:(index+1) inSection:0]];
        if([cell isKindOfClass:[SNGalleryRecommendCell class]] || [cell isKindOfClass:[SNGalleryAdCell class]])
        {
            self.header.alpha = 1;
            self.header.iconView.alpha = (100 - offsetX)/100;
            self.header.addFollowButton.alpha = (100 - offsetX)/100;
            self.header.subTitleLabel.alpha = (100 - offsetX)/100;
            self.header.arrowImage.alpha = (100 - offsetX)/100;
        }
    }else if(index+1 == numbers){
        //这里的判断不是十分的严谨 后续优化
        self.header.alpha = 1;
        self.header.iconView.alpha = 0;
        self.header.addFollowButton.alpha = 0;
        self.header.subTitleLabel.alpha = 0;
        self.header.arrowImage.alpha = 0;
    }
}

- (void)headerFooterHideWithScrollOffset:(CGFloat)offsetX {
    NSInteger index = offsetX/kAppScreenWidth;
    if (self.browserType == SNGalleryBrowserTypeImage) {
        CGFloat headerDiff = offsetX;
        if (_browserHeaderAndFooterDidHide) {
            [self abtestHeaderUpdate:index offset:offsetX];
        }else{
            if (headerDiff > 0) {
                self.header.alpha = (100 - headerDiff)/100;
            }
        }
        
        if (!self.collectionDatasource.lastBigAd) {
            return;//图文新闻没有大图广告的话则不需要处理这里的逻辑
        }
        CGFloat diff = offsetX - (self.collectionDatasource.article.newsImageItems.count - 1) * (kAppScreenWidth + 2 * kLeftOffset);
        if (_browserHeaderAndFooterDidHide) {//如果之前是隐藏状态
            if (diff > 0) {
                if (self.collectionDatasource.lastBigAd) {
                    self.footer.shareButton.alpha = diff/100;
                }
                self.footer.backButton.alpha = diff/100;
            }
        }else{//如果之前是显示状态
            if (diff > 0) {
                self.footer.titleLabel.alpha = (100 - diff)/100;
                self.footer.indexLabel.alpha = (100 - diff)/100;
                self.footer.downloadButton.alpha = (100 - diff)/100;
                self.footer.abstractContentView.alpha = (100 - diff)/100;
                self.footer.maskImageView.alpha = (100 - diff)/100;
                if (!self.collectionDatasource.lastBigAd) {
                    self.footer.shareButton.alpha = (100 - diff)/100;
                }
            }
        }
        
    }else if (self.browserType == SNGalleryBrowserTypeGroup) {
        CGFloat diff = offsetX - (self.collectionDatasource.galleryItem.gallerySubItems.count - 1) * (kAppScreenWidth + 2 * kLeftOffset);
        CGFloat headerDiff = offsetX;
        if (_browserHeaderAndFooterDidHide) {//如果之前是隐藏状态
            if (diff > 0) {
                if (self.collectionDatasource.lastBigAd) {
                    self.footer.shareButton.alpha = diff/100;
                }
                self.footer.backButton.alpha = diff/100;
            }
            [self abtestHeaderUpdate:index offset:offsetX];
        }else{//如果之前是显示状态
            if (diff > 0) {
                self.footer.titleLabel.alpha = (100 - diff)/100;
                self.footer.indexLabel.alpha = (100 - diff)/100;
                self.footer.downloadButton.alpha = (100 - diff)/100;
                self.footer.abstractContentView.alpha = (100 - diff)/100;
                self.footer.maskImageView.alpha = (100 - diff)/100;
                if (!self.collectionDatasource.lastBigAd) {
                    self.footer.shareButton.alpha = (100 - diff)/100;
                }
            }
            if (headerDiff > 0) {
                self.header.alpha = (100 - headerDiff)/100;
            }
        }
        //有大图广告的情况下 分享按钮的处理
        diff = offsetX - (self.collectionDatasource.galleryItem.gallerySubItems.count) * (kAppScreenWidth + 2 * kLeftOffset);
        if (diff > 0 && self.collectionDatasource.lastBigAd) {
            self.footer.shareButton.alpha = (100 - diff)/100;
        }
    }
}

#pragma mark - 广告数据
/**
 设置最后一帧大图广告  itemspaceId = 12233
 
 @param adCarrier 广告的数据结构
 */
- (void)setLastBigAd:(SNAdDataCarrier *)adCarrier{
    if (adCarrier.adImageUrl.length > 0) {
        self.collectionDatasource.lastBigAd = adCarrier;
        [self.collectionView reloadData];
        if (_browserType == SNGalleryBrowserTypeGroup && _currentIndex == self.collectionDatasource.galleryItem.gallerySubItems.count) {
            [self setCurrentIndex:_currentIndex + 1];
            [self setContentOffset];
            [self setCurrentView];
        }
    }
}

/**
 设置组图推荐最后两个小图广告
 
 @param lastAd 倒数第一个  itemspaceId = 12238
 @param lastSecondAd 倒数第二个  itemspaceId = 12716
 */
- (void)setLastRecomAd:(SNAdDataCarrier *)lastAd lastSecond:(SNAdDataCarrier *)lastSecondAd{
    if (lastAd.adImageUrl.length > 0 || lastSecondAd.adImageUrl.length > 0) {
        self.collectionDatasource.lastRecomAd = lastAd;
        self.collectionDatasource.lastSecondRecomAd = lastSecondAd;
        [self.collectionView reloadData];
        CGFloat offsetX = self.collectionView.contentOffset.x;
        NSInteger index = offsetX/kAppScreenWidth;
        if (index > 0 && self.collectionDatasource.galleryItem.gallerySubItems.count > 0) {
            NSInteger recomIndex = self.collectionDatasource.galleryItem.gallerySubItems.count;
            if (self.collectionDatasource.lastRecomAd && index >= recomIndex) {
                [self.collectionDatasource.lastRecomAd reportForDisplayTrack];
            }
            if (self.collectionDatasource.lastSecondRecomAd && index >= recomIndex) {
                [self.collectionDatasource.lastSecondRecomAd reportForDisplayTrack];
            }
        }
    }
}

#pragma mark - ScrollViewDelegate
- (void)collectionViewDidScroll:(CGFloat)offsetX {

    [self headerFooterHideWithScrollOffset:offsetX];
    NSInteger index = offsetX/kAppScreenWidth;
    [self updateFooterIndex:index];
    if (index > 0 && self.collectionDatasource.galleryItem.gallerySubItems.count > 0) {
        NSInteger recomIndex = self.collectionDatasource.galleryItem.gallerySubItems.count;
        if (self.collectionDatasource.lastBigAd && index == recomIndex) {
            recomIndex += 1;
            [self.collectionDatasource.lastBigAd reportForDisplayTrack];
        }
        if (self.collectionDatasource.lastRecomAd && index >= recomIndex) {
            [self.collectionDatasource.lastRecomAd reportForDisplayTrack];
        }
        if (self.collectionDatasource.lastSecondRecomAd && index >= recomIndex) {
            [self.collectionDatasource.lastSecondRecomAd reportForDisplayTrack];
        }
    }
}

- (void)collectionViewWillBeginDragging:(UIScrollView *)scrollView {
    CGFloat offsetX = scrollView.contentOffset.x;
    if (self.browserType == SNGalleryBrowserTypeGroup) {
        CGFloat diff = offsetX - (self.collectionDatasource.galleryItem.gallerySubItems.count/2) * (kAppScreenWidth + 2 * kLeftOffset);
        //加载下一篇组图数据
//        dispatch_async(dispatch_get_global_queue(0, 0), ^{
            [self loadNextGroupPhoto:diff > 0];
//        });
    }

}

- (void)collectionViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    CGFloat offsetX = scrollView.contentOffset.x;
    if (self.browserType == SNGalleryBrowserTypeGroup) {
        if (offsetX >= self.collectionView.contentSize.width - (kAppScreenWidth + 2 * kLeftOffset) + 30) {
            if (self.delegate && [self.delegate respondsToSelector:@selector(changeToNextBrowserView)]) {
                [self.delegate changeToNextBrowserView];
            }
        }
        else if (offsetX <= -30){
            if (self.delegate && [self.delegate respondsToSelector:@selector(changeToPreBrowserView)]) {
                [self.delegate changeToPreBrowserView];
            }
        }
    }else if (self.browserType == SNGalleryBrowserTypeImage){
        if (offsetX >= self.collectionView.contentSize.width - (kAppScreenWidth + 2 * kLeftOffset) + 30) {
            [self dismissWithRestore:YES];
        }
        else if (offsetX <= -30){
            [self dismissWithRestore:YES];
        }
    }
}

#pragma mark - statusBar变化通知
- (void)statusBarFrameWillChange:(NSNotification *)notification {
    
}
- (void)statusBarFrameDidChange:(NSNotification *)notification {
    CGRect statusBarRect = [[UIApplication sharedApplication] statusBarFrame];
    if (statusBarRect.size.height == 40) {
        //开启了热点
        self.footer.bottom = self.height - 20;
    }else{
        self.footer.bottom = self.height;
    }
}


- (SNLongPressAlert *)longPressAlert {
    if (_longPressAlert == nil) {
        _longPressAlert = [[SNLongPressAlert alloc] init];
    }
    return _longPressAlert;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    if (self.delegate) {
        self.delegate = nil;
    }
    if (self.dismissBlock) {
        self.dismissBlock = nil;
    }
    if (self.collectionView.delegate) {
        self.collectionView.delegate = nil;
        self.collectionView = nil;
    }
}

@end
