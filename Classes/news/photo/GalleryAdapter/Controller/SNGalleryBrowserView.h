//
//  SNGalleryBrowserView.h
//  SNNewGallery
//
//  Created by H.Ekko on 03/01/2017.
//  Copyright © 2017 Huang Zhen. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SNGalleryBrowser.h"
#import "SNSubInfoView.h"

typedef enum : NSUInteger {
    SNGalleryBrowserTypeImage,//图文新闻
    SNGalleryBrowserTypeGroup,//组图新闻
    SNGalleryBrowserTypeOther,//其他（单纯的图片浏览）
} SNGalleryBrowserType;

@protocol SNGalleryBrowserViewDelegate <NSObject>


@optional

/**
 处理 statusBar

 @param hide YES hidden
 */
- (void)updateStatusBarHidden:(BOOL)hide;

/**
 图集浏览器关闭回调
 */
- (void)didClose;

/**
 图集浏览器切换图片
 
 @param url 图片的url
 @param index 图片的index
 */
- (void)didChangePhoto:(NSString *)url index:(NSUInteger)index;

/**
 根据图片url获取正文页上图片的rect

 @param imageUrl 图片url
 @return 图片在正文页的rect
 */
- (CGRect)rectForImageUrl:(NSString *)imageUrl;

/**
 切换下一组图
 */
- (void)changeToNextBrowserView;

/**
 切换上一组图
 */
- (void)changeToPreBrowserView ;

/**
 预加载下一篇组图

 @param nextId 组图id
 */
- (void)prepareForNextGalleryNews:(NSString *)nextId;

/**
 预加载上一篇组图

 @param preId 组图id
 */
- (void)prepareForPreGalleryNews:(NSString *)preId;

/**
 组图推荐点击事件，需要切换组图

 @param newsId 将要切换的id
 */
- (void)changeBrowserViewFromRecommend:(NSString *)newsId;

/**
 分享事件

 @param type browserType
 @param index index
 @param image 图片
 @param isAd 是否是广告
 */
- (void)sharePhotoWithGalleryType:(SNGalleryBrowserType)type currentIndex:(NSInteger)index photo:(UIImage *)image isAD:(BOOL)isAd;

/**
 长按图片的分享
 */
- (void)shareLongpressPhoto:(UIImage *)image imgUrl:(NSString *)url index:(NSInteger)index;

@end

@class SNArticle;
@class GalleryItem;
@class SNAdDataCarrier;
@interface SNGalleryBrowserView : UIView

/**
 组图唯一标识 gid
 */
@property (nonatomic, copy) NSString * galleryId;
@property (nonatomic, copy) NSString * newsId;

@property (nonatomic, weak) id <SNGalleryBrowserViewDelegate>delegate;

/**
 公众号区域
 */
@property (nonatomic, strong) SNSubInfoView * header;

/**
 图片浏览器关闭的回调
 */
@property (nonatomic, copy) GalleryDismissBlock dismissBlock;

/**
 打开图片浏览器时当前的index
 */
@property (nonatomic, assign) NSUInteger currentIndex;

/**
 当前图片url
 */
@property (nonatomic, copy) NSString * currentImageUrl;

/**
 打开图片浏览器时当前的rect
 */
@property (nonatomic, assign) CGRect currentRect;

/**
 用于其他未定义的消息传递
 */
@property (nonatomic, strong) NSDictionary * info;


/**
 当前用于关闭动画的imageView
 */
@property (nonatomic, strong) UIImageView * currentPhotoView;

/**
 当前用于关闭动画的currentRecommendView
 */
@property (nonatomic, strong) UIView * currentRecommendView;
/**
 当前用于关闭动画的currentRecommendView
 */
@property (nonatomic, strong) UIImageView * currentADView;

/**
 当前页的cell
 */
@property (nonatomic, strong) UICollectionViewCell * currentCell;

/**
 图文新闻还是组图新闻还是单纯的图片浏览
 */
@property (nonatomic, assign) SNGalleryBrowserType browserType;

/**
 设置偏移量
 */
- (void)setContentOffset;

/**
 设置当前的界面 view ； 会根据index自动判断
 */
- (void)setCurrentView;

/**
 图文新闻图片数据源

 @param article 文章数据model
 */
- (void)setArticle:(SNArticle *)article;

/**
 组图新闻图片数据源

 @param galleryItem 数据model
 */
- (void)setGalleryItem:(GalleryItem *)galleryItem isNext:(BOOL)isNext;

/**
 给图片浏览器设置网络图片数据源

 @param imageUrls 存放图片`url:NSString`的数组
 */
- (void)setImageUrls:(NSArray *)imageUrls;

/**
 给图片浏览器设置本地图片数据源

 @param images 存放`UIImage`对象的数组
 */
- (void)setImages:(NSArray *)images;

/**
 关闭图集浏览
 restore 是否需要回到当前图片的位置
 */
- (void)dismissWithRestore:(BOOL)restore;

/**
 photo zoom的代理
 */
- (void)photoDidZoom:(BOOL)big;

/**
 photo scroll的代理
 */
- (void)photoDidScroll:(UIScrollView *)scrollView;

/**
 组图推荐点击事件，需要切换组图内容

 @param newsId 待切换的newsId
 */
- (void)recommendGalleryDidClickWithNewsId:(NSString *)newsId;

/**
 更新header和footer的信息
 */
- (void)prepareSubInfoHeaderView;

/**
 控制header和footer的显示与隐藏

 */
- (void)setHeaderAndFooterHide;

#pragma mark - 广告数据
/**
 设置最后一帧大图广告  itemspaceId = 12233
 
 @param adCarrier 广告的数据结构
 */
- (void)setLastBigAd:(SNAdDataCarrier *)adCarrier;

/**
 设置组图推荐最后两个小图广告
 
 @param lastAd 倒数第一个  itemspaceId = 12238
 @param lastSecondAd 倒数第二个  itemspaceId = 12716
 */
- (void)setLastRecomAd:(SNAdDataCarrier *)lastAd lastSecond:(SNAdDataCarrier *)lastSecondAd;

#pragma mark - ScrollView
- (void)collectionViewDidScroll:(CGFloat)offsetX;
- (void)collectionViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate;
- (void)collectionViewWillBeginDragging:(UIScrollView *)scrollView;

@end
