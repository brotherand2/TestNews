//
//  SNGalleryBrowserController.m
//  sohunews
//
//  Created by HuangZhen on 2017/5/4.
//  Copyright © 2017年 Sohu.com. All rights reserved.
//

#import "SNGalleryBrowserController.h"
#import "SNGalleryBrowserView.h"
#import "SNGalleryDataModel.h"
#import "SNOfficialAccountsInfo.h"

@interface SNGalleryBrowserController ()<SNGalleryBrowserViewDelegate,UIScrollViewDelegate>{
    NSInteger _curGroupIndex;//当前的组图新闻在整个newsList中的index
    BOOL _isRcomStream;//是否是推荐流[从相关推荐进入]
    BOOL _isLoadingRecom;//正在加载下一相关推荐的组图slide
    //已经切换了，再弱网环境下[very bad]，
    //推荐组图请求回来时，如果此时已经切换或者关闭了组图，不应再展现推荐的组图内容
    BOOL _didChangedGroup;
    BOOL _needHideStatusBar;
}
@property (nonatomic, strong) SNGalleryDataModel * dataModel;
@property (nonatomic, copy) GalleryDismissBlock dismissBlock;

@property (nonatomic, strong) SNGalleryBrowserView * gallery;
@property (nonatomic, strong) SNGalleryBrowserView * nextGallery;
@property (nonatomic, strong) SNGalleryBrowserView * preGallery;
@property (nonatomic, copy) NSString * curGid;
@property (nonatomic, copy) NSString * nextGid;
@property (nonatomic, copy) NSString * preGid;
@property (nonatomic, strong) GalleryItem * nextGalleryItem;
@property (nonatomic, strong) GalleryItem * curGalleryItem;
@property (nonatomic, strong) GalleryItem * preGalleryItem;
/**
 用于记录相关推荐的上一篇gid
 */
@property (nonatomic, copy) NSString * recomLastGid;

@end

@implementation SNGalleryBrowserController

- (id)initWithNavigatorURL:(NSURL *)URL query:(NSDictionary *)query {
    if (self = [super initWithNavigatorURL:URL query:query]) {
        _curGroupIndex = 0;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor clearColor];
    [self.view addSubview:self.gallery];
    [self prepareForPreGalleryNews:nil];
    if (self.delegate && [self.delegate respondsToSelector:@selector(galleryBrowserDidShow)]) {
        [self.delegate galleryBrowserDidShow];
    }
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    if (self.gallery.header.subObj.subId.length > 0) {
        [SNOfficialAccountsInfo checkFollowStatusWithSubId:self.gallery.header.subObj.subId completed:^(SNFollowedStatus followedStatus) {
            [self.gallery.header updateFollowedInfo];
        }];
    }
    [SNUtility banUniversalLinkOpenInSafari];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self.gallery setCurrentView];
}

- (SNGalleryDataModel *)dataModel {
    if (!_dataModel) {
        _dataModel = [SNGalleryDataModel new];
    }
    return _dataModel;
}

- (SNGalleryBrowserView *)gallery {
    if (!_gallery) {
        _gallery = [[SNGalleryBrowserView alloc] initWithFrame:kScreenRect];
        _gallery.delegate = self;
    }
    return _gallery;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)setNewsId:(NSString *)newsId {
    _newsId = newsId;
    
    if ([self.allNewsId containsObject:newsId]) {
        _curGroupIndex = [self.allNewsId indexOfObject:_newsId];
    }else{
        self.allNewsId = nil;
    }
}

#pragma mark - public

- (void)setArticleGalleryDatasource:(SNArticle *)article {
    if (article.newsImageItems.count <= 0) return;
    [self.gallery setBrowserType:SNGalleryBrowserTypeImage];
    [self.gallery setArticle:article];
    [self preLoadingNewsImageInWIFI:article];
}

- (void)setPhotoGalleryDatasource:(GalleryItem *)galleryItem {
    if (galleryItem.gallerySubItems.count <= 0) return;
    self.curGid = galleryItem.newsId;
    self.curGalleryItem = galleryItem;
    [self.gallery setBrowserType:SNGalleryBrowserTypeGroup];
    [self.gallery setGalleryItem:galleryItem isNext:YES];
    [self preLoadingGalleryImageInWIFI:galleryItem];
}

- (void)showAtIndex:(NSUInteger)index dissmiss:(GalleryDismissBlock)dissmissBlock {
    [self.gallery setCurrentIndex:index];
    [self.gallery setContentOffset];
    [self.gallery setDismissBlock:dissmissBlock];
    self.dismissBlock = dissmissBlock;
}

#pragma mark - Delegate
- (void)updateStatusBarHidden:(BOOL)hide {
    if (![TTNavigator navigator].topViewController.flipboardNavigationController.previousViewController.prefersStatusBarHidden) {
        hide = NO;
    }
    _needHideStatusBar = hide;
    [self setNeedsStatusBarAppearanceUpdate];
}

- (void)didClose {
//    [self updateStatusBarHidden:YES];    
    if (self.delegate && [self.delegate respondsToSelector:@selector(galleryBrowserDidClose)]) {
        [self.delegate galleryBrowserDidClose];
    }
    if (self.flipboardNavigationController) {
        [self.flipboardNavigationController popViewController];
    }else{
        [[TTNavigator navigator].topViewController.flipboardNavigationController popViewController];
    }
}

- (void)didChangePhoto:(NSString *)url index:(NSUInteger)index {
    if (self.delegate && [self.delegate respondsToSelector:@selector(galleryBrowserDidChangePhoto:index:)]) {
        [self.delegate galleryBrowserDidChangePhoto:url index:index];
    }
}

- (CGRect)rectForImageUrl:(NSString *)imageUrl {
    if (self.delegate && [self.delegate respondsToSelector:@selector(rectForgalleryBrowserImageUrl:)]) {
        return [self.delegate rectForgalleryBrowserImageUrl:imageUrl];
    }else{
        return [UIScreen mainScreen].bounds;
    }
}

/**
 在推荐中点击切换组图
 */
- (void)changeBrowserViewFromRecommend:(NSString *)newsId {
    
    if (_isLoadingRecom) {
        return;
    }
    _isLoadingRecom = YES;
    _didChangedGroup = NO;
    [self.dataModel getJsKitStorageItemWithGroupId:newsId type:SNGalleryBrowserTypeGroup completed:^(id galleryData) {
        
        if (galleryData && [galleryData isKindOfClass:[GalleryItem class]] && !_didChangedGroup) {
            _isRcomStream = YES;
            GalleryItem * galleryItem = (GalleryItem *)galleryData;
            self.nextGalleryItem = galleryItem;
            self.nextGid = self.nextGalleryItem.nextId;
            [self createRecommendGalleryWithGalleryItem:galleryItem];
            [self changeToRecommendBrowserView];
        }
    }];
}

//分享
- (void)sharePhotoWithGalleryType:(SNGalleryBrowserType)type currentIndex:(NSInteger)index photo:(UIImage *)image isAD:(BOOL)isAd {
    if (self.delegate && [self.delegate respondsToSelector:@selector(sharePhotoWithGalleryType:currentIndex:photo:isAD:)]) {
        [self.delegate sharePhotoWithGalleryType:type == SNGalleryBrowserTypeGroup currentIndex:index photo:image isAD:isAd];
    }
}
/**
 长按图片的分享
 */
- (void)shareLongpressPhoto:(UIImage *)image imgUrl:(NSString *)url index:(NSInteger)index {
    if (self.delegate && [self.delegate respondsToSelector:@selector(shareLongpressPhoto:imgUrl:index:)]) {
        [self.delegate shareLongpressPhoto:image imgUrl:url index:index];
    }
}

#pragma mark - 广告
/**
 设置最后一帧大图广告  itemspaceId = 12233
 
 @param adCarrier 广告的数据结构
 */
- (void)setLastBigAd:(SNAdDataCarrier *)adCarrier{
    [self.gallery setLastBigAd:adCarrier];
}

/**
 设置组图推荐最后两个小图广告
 
 @param lastAd 倒数第一个  itemspaceId = 12238
 @param lastSecondAd 倒数第二个  itemspaceId = 12716
 */
- (void)setLastRecomAd:(SNAdDataCarrier *)lastAd lastSecond:(SNAdDataCarrier *)lastSecondAd{
    [self.gallery setLastRecomAd:lastAd lastSecond:lastSecondAd];
}

#pragma mark - private
- (void)preLoadingGalleryImageInWIFI:(GalleryItem *)item {
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        @autoreleasepool {
            if ([[SNUtility getApplicationDelegate] currentNetworkStatus] == ReachableViaWiFi) {
                for (PhotoItem * photo in item.gallerySubItems) {
                    @autoreleasepool {
                        if ([photo isKindOfClass:[PhotoItem class]] && photo.url.trim.length > 0) {
                            [[SDWebImageDownloader sharedDownloader] downloadImageWithURL:[NSURL URLWithString:photo.url.trim] options:0 progress:^(NSInteger receivedSize, NSInteger expectedSize) {
                            } completed:^(UIImage *image, NSData *data, NSError *error, BOOL finished) {
                            }];
                        }
                    }
                }
            }
        }
    });
}

- (void)preLoadingNewsImageInWIFI:(SNArticle *)item {
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        @autoreleasepool {
            if ([[SNUtility getApplicationDelegate] currentNetworkStatus] == ReachableViaWiFi) {
                for (NewsImageItem * newsPhoto in item.newsImageItems) {
                    @autoreleasepool {
                        if ([newsPhoto isKindOfClass:[NewsImageItem class]] && newsPhoto.url.trim.length > 0) {
                            [[SDWebImageDownloader sharedDownloader] downloadImageWithURL:[NSURL URLWithString:newsPhoto.url.trim] options:0 progress:^(NSInteger receivedSize, NSInteger expectedSize) {
                            } completed:^(UIImage *image, NSData *data, NSError *error, BOOL finished) {
                            }];
                        }
                    }
                }
            }
        }
    });
}

#pragma mark - 连续浏览
/**
 准备切换另一组图
 */
- (void)changeToNextBrowserView {
    
    //已经到最后一篇了
    if (_curGroupIndex == self.allNewsId.count - 1 || !self.nextGallery || self.nextGalleryItem.gallerySubItems.count == 0) {
        [[SNCenterToast shareInstance] showCenterToastWithTitle:@"没有更多内容了" toUrl:nil mode:SNCenterToastModeOnlyText];
        self.nextGalleryItem = nil;
        self.nextGid = nil;
        return;
    }
    _didChangedGroup = YES;
    [UIView animateWithDuration:0.25 animations:^{
        self.gallery.frame = CGRectMake(-kAppScreenWidth, 0, kAppScreenWidth, kAppScreenHeight);
        self.nextGallery.frame = CGRectMake(0, 0, kAppScreenWidth, kAppScreenHeight);
    } completion:^(BOOL finished) {
        [self.gallery removeFromSuperview];
        
        if (_isRcomStream) {
            self.recomLastGid = self.curGalleryItem.gId;
        }else{
            self.recomLastGid = nil;
        }
        
        self.curGalleryItem = self.nextGalleryItem;
        self.preGid = nil;
        self.preGallery = nil;
        self.preGalleryItem = nil;
        NSString * gid = [self.curGalleryItem.newsId isEqualToString:@"0"] ? self.curGalleryItem.gId : self.curGalleryItem.newsId;
        //切换后，配置前、中的gid
        self.curGid = gid;
        
        self.gallery = self.nextGallery;
        self.newsId = gid;
        self.gallery.delegate = self;
        [self.gallery setCurrentIndex:0];
        [self.gallery setContentOffset];
        [self.gallery setCurrentView];
        [self.gallery setDismissBlock:self.dismissBlock];
        if ([self.delegate respondsToSelector:@selector(galleryBrowserDidChangeNews:newsId:channelId:)]) {
            [self.delegate galleryBrowserDidChangeNews:self.curGalleryItem.gId newsId:self.curGalleryItem.newsId channelId:self.channelId];
        }
    }];
}

- (void)changeToPreBrowserView {
    /// 如果是相关推荐流 则返回刚刚浏览过的上一篇组图
    if (_isRcomStream && self.preGallery && self.recomLastGid) {
        self.recomLastGid = nil;
    }else{
        /// 否则直接判断没有上一篇则关闭组图浏览
        if (_curGroupIndex == 0 || !self.preGallery || self.preGalleryItem.gallerySubItems.count == 0) {
            [self.gallery dismissWithRestore:YES];
            self.preGalleryItem = nil;
            self.preGid = nil;
            return;
        }
    }
    
    self.preGallery.frame = CGRectMake(-kAppScreenWidth, 0, kAppScreenWidth, kAppScreenHeight);
    NSInteger lastIndex = self.preGalleryItem.gallerySubItems.count;
    if (self.preGalleryItem.moreRecommends.count == 0) {
        lastIndex = self.preGalleryItem.gallerySubItems.count - 1;
    }
    
    [self.preGallery setCurrentIndex:lastIndex];
    [self.preGallery setContentOffset];
    [self.preGallery setCurrentView];
    _didChangedGroup = YES;
    [UIView animateWithDuration:0.25 animations:^{
        self.gallery.frame = CGRectMake(kAppScreenWidth, 0, kAppScreenWidth, kAppScreenHeight);
        self.preGallery.frame = CGRectMake(0, 0, kAppScreenWidth, kAppScreenHeight);
    } completion:^(BOOL finished) {
        [self.gallery removeFromSuperview];
        
        self.nextGid = nil;
        self.nextGallery = nil;
        self.nextGalleryItem = nil;
        self.curGalleryItem = self.preGalleryItem;
        //切换后，配置前、中的gid
        NSString * gid = [self.curGalleryItem.newsId isEqualToString:@"0"] ? self.curGalleryItem.gId : self.curGalleryItem.newsId;
        self.curGid = gid;
        self.gallery = self.preGallery;
        self.newsId = gid;
        self.gallery.delegate = self;
        [self.gallery setCurrentView];
        [self.gallery setDismissBlock:self.dismissBlock];
        if ([self.delegate respondsToSelector:@selector(galleryBrowserDidChangeNews:newsId:channelId:)]) {
            [self.delegate galleryBrowserDidChangeNews:self.curGalleryItem.gId newsId:self.curGalleryItem.newsId channelId:self.channelId];
        }
    }];
}

- (void)changeToRecommendBrowserView {
    
    if (!self.nextGallery || self.nextGalleryItem.gallerySubItems.count == 0) {
        return;
    }
    /// 从相关推荐进入 slide 页，channelid 一定是47
    self.channelId = @"47";
    _didChangedGroup = YES;
    [UIView animateWithDuration:0.25 animations:^{
        self.gallery.frame = CGRectMake(-kAppScreenWidth, 0, kAppScreenWidth, kAppScreenHeight);
        self.nextGallery.frame = CGRectMake(0, 0, kAppScreenWidth, kAppScreenHeight);
    } completion:^(BOOL finished) {
        [self.gallery removeFromSuperview];
        
        self.curGalleryItem = self.nextGalleryItem;
        NSString * gid = [self.curGalleryItem.newsId isEqualToString:@"0"] ? self.curGalleryItem.gId : self.curGalleryItem.newsId;
        //切换后，配置前、中的gid
        self.curGid = gid;
        
        self.gallery = self.nextGallery;
        self.newsId = gid;
        self.gallery.delegate = self;
        [self.gallery setCurrentIndex:0];
        [self.gallery setContentOffset];
        [self.gallery setCurrentView];
        [self.gallery setDismissBlock:self.dismissBlock];
        if ([self.delegate respondsToSelector:@selector(galleryBrowserDidChangeNews:newsId:channelId:)]) {
            [self.delegate galleryBrowserDidChangeNews:self.curGalleryItem.gId newsId:self.curGalleryItem.newsId channelId:self.channelId];
        }
        _isLoadingRecom = NO;
    }];
}


/**
 预加载下一篇组图
 
 @param nextId 组图id
 */
- (void)prepareForNextGalleryNews:(NSString *)nextId {
    
    if(_isRcomStream){
        ///如果是从相关推荐进入的连续阅读流
        self.dataModel.channelId = self.channelId;
        [self.dataModel getJsKitStorageItemWithGroupId:nextId type:SNGalleryBrowserTypeGroup completed:^(id galleryData) {
            if (galleryData && [galleryData isKindOfClass:[GalleryItem class]]) {
                GalleryItem * galleryItem = (GalleryItem *)galleryData;
                self.nextGalleryItem = galleryItem;
                self.nextGid = self.nextGalleryItem.nextId;
                [self createNextGalleryWithGalleryItem:galleryItem];
            }
        }];
        return;
    }
    
    /// 正常的组图连续阅读
    if (self.allNewsId.count > 0 && _curGroupIndex + 1 < self.allNewsId.count) {
        //如果有newsId数组，则数据源从这里面来拿
        nextId = _allNewsId[_curGroupIndex + 1];
        
        self.dataModel.channelId = self.channelId;
        //美图奇趣频道、相关推荐流，使用的都是gid
        if ([self.channelId isEqualToString:@"47"] || [self.channelId isEqualToString:@"54"] || _isRcomStream) {
            [self.dataModel getJsKitStorageItemWithGroupId:nextId type:SNGalleryBrowserTypeGroup completed:^(id galleryData) {
                if (galleryData && [galleryData isKindOfClass:[GalleryItem class]]) {
                    GalleryItem * galleryItem = (GalleryItem *)galleryData;
                    self.nextGalleryItem = galleryItem;
                    self.nextGid = self.nextGalleryItem.newsId;
                    [self createNextGalleryWithGalleryItem:galleryItem];
                }
            }];
        }else{
            //首页流使用的都是newsId
            [self.dataModel getJsKitStorageItemWithNewsId:nextId type:SNGalleryBrowserTypeGroup completed:^(id galleryData) {
                if (galleryData && [galleryData isKindOfClass:[GalleryItem class]]) {
                    GalleryItem * galleryItem = (GalleryItem *)galleryData;
                    self.nextGalleryItem = galleryItem;
                    self.nextGid = self.nextGalleryItem.newsId;
                    [self createNextGalleryWithGalleryItem:galleryItem];
                }
            }];
        }
    }
}

/**
 预加载上一篇组图
 
 @param preId 组图id
 */
- (void)prepareForPreGalleryNews:(NSString *)preId {
    /// 是从相关推荐进入的连续阅读
    if(_isRcomStream){
        /// 没有缓存的上一篇gid则重置
        if (self.recomLastGid.length <= 0) {
            self.preGid = nil;
            self.preGalleryItem = nil;
            self.preGallery = nil;
            return;
        }
        /// 缓存了上一篇的gid，则开始请求数据
        self.dataModel.channelId = self.channelId;
        [self.dataModel getJsKitStorageItemWithGroupId:self.recomLastGid type:SNGalleryBrowserTypeGroup completed:^(id galleryData) {
            if (galleryData && [galleryData isKindOfClass:[GalleryItem class]]) {
                GalleryItem * galleryItem = (GalleryItem *)galleryData;
                self.preGalleryItem = galleryItem;
                self.preGid = self.preGalleryItem.newsId;
                [self createPreGalleryWithGalleryItem:galleryItem];
            }
        }];
        return;
    }
    
    /// 正常的组图连续阅读
    if (self.allNewsId.count > 0 && _curGroupIndex - 1 >= 0) {
        //如果有newsId数组，则数据源从这里面来拿
        preId = self.allNewsId[_curGroupIndex - 1];
        self.dataModel.channelId = self.channelId;
        //美图奇趣频道、相关推荐流，使用的都是gid
        if ([self.channelId isEqualToString:@"47"] || [self.channelId isEqualToString:@"54"] || _isRcomStream) {
            [self.dataModel getJsKitStorageItemWithGroupId:preId type:SNGalleryBrowserTypeGroup completed:^(id galleryData) {
                if (galleryData && [galleryData isKindOfClass:[GalleryItem class]]) {
                    GalleryItem * galleryItem = (GalleryItem *)galleryData;
                    self.preGalleryItem = galleryItem;
                    self.preGid = self.preGalleryItem.newsId;
                    [self createPreGalleryWithGalleryItem:galleryItem];
                }
            }];
        }else{
            //首页流组图使用的都是newsId
            [self.dataModel getJsKitStorageItemWithNewsId:preId type:SNGalleryBrowserTypeGroup completed:^(id galleryData) {
                if (galleryData && [galleryData isKindOfClass:[GalleryItem class]]) {
                    GalleryItem * galleryItem = (GalleryItem *)galleryData;
                    self.preGalleryItem = galleryItem;
                    self.preGid = self.preGalleryItem.newsId;
                    [self createPreGalleryWithGalleryItem:galleryItem];
                }
            }];
        }
    }else{
        self.nextGalleryItem = nil;
        self.nextGid = nil;
    }
}

- (void)createNextGalleryWithGalleryItem:(GalleryItem *)galleryItem{
    /// 为避免缓存请求不及时，这里会调用多次，
    /// 为避免多次创建SNGalleryBrowserView，这里做了这个判断
    if (([self.channelId isEqualToString:@"47"] || [self.channelId isEqualToString:@"54"] || _isRcomStream)) {
        if ([self.nextGallery.galleryId isEqualToString:galleryItem.gId]) {
            return;
        }
    }
    else {
        /// newsid的组图新闻 避免重复创建browserView实例
        if ([self.nextGallery.newsId isEqualToString:galleryItem.newsId]) {
            return;
        }
    }
    [self preLoadingGalleryImageInWIFI:galleryItem];
    SNGalleryBrowserView * gallery = [[SNGalleryBrowserView alloc]
                                      initWithFrame:CGRectMake(kScreenWidth, 0, kScreenWidth, kScreenHeight)];
    if (galleryItem.gallerySubItems.count <= 0) return;
    [gallery setBrowserType:SNGalleryBrowserTypeGroup];
    [gallery setGalleryItem:galleryItem isNext:YES];
    [self.view addSubview:gallery];
    self.nextGallery = gallery;
    self.nextGalleryItem = galleryItem;
}

- (void)createRecommendGalleryWithGalleryItem:(GalleryItem *)galleryItem{
    /// 为避免缓存请求不及时，这里会调用多次，
    /// 为避免多次创建SNGalleryBrowserView，这里做了这个判断
    if (([self.channelId isEqualToString:@"47"] || [self.channelId isEqualToString:@"54"] || _isRcomStream)) {
        if ([self.nextGallery.galleryId isEqualToString:galleryItem.gId]) {
            return;
        }
    }
    else {
        /// newsid的组图新闻 避免重复创建browserView实例
        if ([self.nextGallery.newsId isEqualToString:galleryItem.newsId]) {
            return;
        }
    }
    [self preLoadingGalleryImageInWIFI:galleryItem];
    SNGalleryBrowserView * gallery = [[SNGalleryBrowserView alloc]
                                      initWithFrame:CGRectMake(kScreenWidth, 0, kScreenWidth, kScreenHeight)];
    if (galleryItem.gallerySubItems.count <= 0) return;
    [gallery setBrowserType:SNGalleryBrowserTypeGroup];
    [gallery setGalleryItem:galleryItem isNext:YES];
    [self.view addSubview:gallery];
    self.nextGallery = gallery;
    self.nextGalleryItem = galleryItem;
    
}

- (void)createPreGalleryWithGalleryItem:(GalleryItem *)galleryItem{
    //
    /// 为避免缓存请求不及时，这里会调用多次，
    /// 为避免多次创建SNGalleryBrowserView，这里做了这个判断
    if (([self.channelId isEqualToString:@"47"] || [self.channelId isEqualToString:@"54"] || _isRcomStream)) {
        if ([self.preGallery.galleryId isEqualToString:galleryItem.gId]) {
            return;
        }
    }
    else{
        /// newsid的组图新闻 避免重复创建browserView实例
        if ([self.preGallery.newsId isEqualToString:galleryItem.newsId]) {
            return;
        }
    }
    [self preLoadingGalleryImageInWIFI:galleryItem];
    SNGalleryBrowserView * gallery = [[SNGalleryBrowserView alloc]
                                      initWithFrame:CGRectMake(kScreenWidth, 0, kScreenWidth, kScreenHeight)];
    if (galleryItem.gallerySubItems.count <= 0) return;
    [gallery setBrowserType:SNGalleryBrowserTypeGroup];
    [gallery setGalleryItem:galleryItem isNext:NO];
    [self.view addSubview:gallery];
    self.preGallery = gallery;
    self.preGalleryItem = galleryItem;
}

#pragma mark set status bar
- (UIViewController *)subChildViewControllerForStatusBarStyle {
    return self;
}

- (UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
}

- (UIStatusBarAnimation)preferredStatusBarUpdateAnimation {
    return UIStatusBarAnimationSlide;
}

- (BOOL)prefersStatusBarHidden {
    return _needHideStatusBar;
}

- (void)dealloc {
    if (self.delegate) {
        self.delegate = nil;
    }
    if (self.dismissBlock) {
        self.dismissBlock = nil;
    }
    if (self.gallery) {
        self.gallery.delegate = nil;
        self.gallery = nil;
    }
}

@end
