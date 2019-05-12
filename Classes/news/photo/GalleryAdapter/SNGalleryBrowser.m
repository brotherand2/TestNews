//
//  SNGalleryBrowser.m
//  SNNewGallery
//
//  Created by H.Ekko on 03/01/2017.
//  Copyright © 2017 Huang Zhen. All rights reserved.
//

#import "SNGalleryBrowser.h"
#import "SDImageCache.h"
#import "UIImage+MultiFormat.h"
#import "UIImageView+WebCache.h"

@implementation SNGalleryBrowser

#pragma mark - static

+ (SNGalleryBrowserController *)showGalleryWithArticle:(id)article
                             currentImageUrl:(NSString *)currentImageUrl
                                currentIndex:(NSUInteger)currentIndex
                                    fromRect:(CGRect)fromRect
                                    fromView:(UIView *)fromView
                                        info:(NSDictionary *)info
                                dismissBlock:(GalleryDismissBlock)dismissBlock
{
    NSUInteger p_currentIndex = 0;
    
    if (article && [article isKindOfClass:[SNArticle class]]) {
        SNArticle * particle = (SNArticle *)article;
        if (particle.newsImageItems.count <= 0) return nil;
        //default value
        p_currentIndex = currentIndex >= particle.newsImageItems.count ? 0 : currentIndex;
    }else if (article && [article isKindOfClass:[GalleryItem class]]) {
        GalleryItem * galleryItem = (GalleryItem *)article;
        if (galleryItem.gallerySubItems.count <= 0) return nil;
        //default value
        p_currentIndex = currentIndex >= galleryItem.gallerySubItems.count ? 0 : currentIndex;
    }else{
        return nil;
    }

    
//    UIView * p_fromView = fromView ? fromView : [UIApplication sharedApplication].keyWindow;
    UIView * p_fromView = [UIApplication sharedApplication].keyWindow;

    CGRect p_rect = fromRect;
    if (CGRectIsNull(fromRect)
        || CGRectIsEmpty(fromRect)
        || CGRectIsInfinite(fromRect)) {
        p_rect = CGRectMake(kScreenWidth/2.f,
                            kScreenHeight/2.f,
                            0,
                            0);
    }
    
    return [self p_showGalleryWithArticle:article currentImageUrl:currentImageUrl currentIndex:p_currentIndex fromRect:p_rect fromView:p_fromView info:info dismissBlock:dismissBlock];
}

+ (SNGalleryBrowserController *)p_showGalleryWithArticle:(id)p_article
                               currentImageUrl:(NSString *)p_currentImageUrl
                                  currentIndex:(NSUInteger)p_currentIndex
                                      fromRect:(CGRect)p_fromRect
                                      fromView:(UIView *)p_fromView
                                          info:(NSDictionary *)p_info
                                  dismissBlock:(GalleryDismissBlock)p_dismissBlock
{
    SNGalleryBrowserMainThreadAssert();
    SNGalleryBrowserController * controller = [[SNGalleryBrowserController alloc] initWithNavigatorURL:nil query:p_info];
    if (p_article && [p_article isKindOfClass:[SNArticle class]]) {
        SNArticle * article = (SNArticle *)p_article;
        [controller setArticleGalleryDatasource:article];
    }else if (p_article && [p_article isKindOfClass:[GalleryItem class]]) {
        GalleryItem * galleryItem = (GalleryItem *)p_article;
        [controller setPhotoGalleryDatasource:galleryItem];
    }else{
        return nil;
    }
    [controller showAtIndex:p_currentIndex dissmiss:p_dismissBlock];
    //animation
    [self animatedShowfrom:p_fromView fromRect:p_fromRect tapImageUrl:p_currentImageUrl controller:controller];
    
    return controller;
}

+ (UIImage *)getCurrentPhotoImage:(NSString *)url
{
    if (url.length <= 0) {
        return nil;
    }
    NSString *urlPath = url;
    //if cached image, load from filesystem directly
    
    UIImage* cache = nil;
    //修改 _4.3.2_组图：清除缓存后，组图新闻图片不能进入组图大图
    if ([SNAPI isWebURL:urlPath] && [[TTURLCache sharedCache] imageForURL:urlPath]) {
        cache = [[TTURLCache sharedCache] imageForURL:urlPath];
    }
    else if ([[SDImageCache sharedImageCache] imageFromDiskCacheForKey:urlPath]) {
        cache = [[SDImageCache sharedImageCache] imageFromDiskCacheForKey:urlPath];
    }
    else {
        cache = [UIImage sd_imageWithData:[NSData dataWithContentsOfFile:urlPath]];
    }
    
    if (cache.imageOrientation!=UIImageOrientationUp) {
        cache=[cache transformWidth:cache.size.height height:cache.size.width rotate:NO];
    }
    return cache;
}

#pragma mark - animated show

/**
 browser 展开动画

 @param fromView 父视图
 @param rect 起始rect
 @param tapImage 点击的image，或者image的url，可兼容。
 */
+ (void)animatedShowfrom:(UIView *)fromView fromRect:(CGRect)rect tapImageUrl:(NSString *)imageUrl controller:(SNGalleryBrowserController *)controller
{
    if (imageUrl.length <= 0) {
        return;
    }
    UIImageView * tmpImageView = [[UIImageView alloc] initWithFrame:rect];
    tmpImageView.contentMode = UIViewContentModeScaleAspectFit;
    tmpImageView.clipsToBounds = YES;
    
    id cacheImg = [self getCurrentPhotoImage:imageUrl] ;
    if (cacheImg) {
        tmpImageView.image = cacheImg;
        CGRect endRect = [self getImageRect:cacheImg];
        [self animatedfrom:fromView rect:rect image:tmpImageView endFrame:endRect controller:controller];
    }else{
//        [UIImage themeImageNamed:@"app_logo_gray.png"]
        [tmpImageView sd_setImageWithURL:[NSURL URLWithString:imageUrl] placeholderImage:nil completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
            CGRect endRect = [self getImageRect:image];
            [self animatedfrom:fromView rect:rect image:tmpImageView endFrame:endRect controller:controller];
        }];
    }
}

+ (CGRect)renderImageRect:(CGSize)imageSize imageViewRect:(CGRect)imageViewRect {
    CGRect screenRect = [UIScreen mainScreen].bounds;
    CGRect pictureRect = imageViewRect;
    pictureRect.size = imageSize;
    
    if (imageSize.height <= screenRect.size.height && imageSize.width <= screenRect.size.width)
    {
//        imageView.frame = pictureRect;
//        imageView.center = CGPointMake(screenRect.size.width/2.f, screenRect.size.height/2.f);
    }
    else if (imageSize.height > screenRect.size.height && imageSize.width <= screenRect.size.width)
    {
        int image_x = (screenRect.size.width -imageSize.width)/2.f;
        pictureRect.origin.x = 0.f + image_x;
        pictureRect.origin.y = 0.f;
//        imageView.frame = pictureRect;
    }
    else if (imageSize.height <= screenRect.size.height && imageSize.width > screenRect.size.width)
    {
        pictureRect.size.width = screenRect.size.width;
        pictureRect.size.height = pictureRect.size.width * imageSize.height / imageSize.width;
//        imageView.frame = pictureRect;
//        imageView.center = CGPointMake(screenRect.size.width/2.f, screenRect.size.height/2.f);
    }
    else
    {
        pictureRect.origin.x = 0.f;
        pictureRect.origin.y = 0.f;
        pictureRect.size.width = screenRect.size.width ;
        pictureRect.size.height = pictureRect.size.width * imageSize.height / imageSize.width;
//        imageView.frame = pictureRect;
        
//        if (pictureRect.size.height < screenRect.size.height)
//        {
//            imageView.center = CGPointMake(screenRect.size.width/2.f, screenRect.size.height/2.f);
//        }
    }
    return pictureRect;
}

+ (void)animatedfrom:(UIView *)baseView rect:(CGRect)rect image:(UIImageView *)imageView endFrame:(CGRect)endRect controller:(SNGalleryBrowserController *)controller{
    
    UIView * tmpBackground = [[UIView alloc] initWithFrame:kScreenRect];

    tmpBackground.backgroundColor = [UIColor blackColor];
    [tmpBackground addSubview:imageView];
    [baseView addSubview:tmpBackground];
    
    BOOL night = [[SNThemeManager sharedThemeManager] isNightTheme];
    if (night) {
        UIView * maskView = [[UIView alloc] initWithFrame:kScreenRect];
        maskView.backgroundColor = [UIColor colorWithWhite:0 alpha:0.5];
        [tmpBackground addSubview:maskView];
    }
    
    CGRect lastRect = [self renderImageRect:imageView.image.size imageViewRect:imageView.frame];
    
    [UIView animateWithDuration:0.25 animations:^{
        imageView.frame = CGRectMake((baseView.width - lastRect.size.width)/2.f, (baseView.height - lastRect.size.height)/2.f, lastRect.size.width, lastRect.size.height);
    } completion:^(BOOL finished) {
        [[[[TTNavigator navigator] topViewController] flipboardNavigationController] pushViewNoMaskController:controller animated:NO];
        [tmpBackground removeFromSuperview];
        
        //首次进入图集下滑提示
        NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
        if (![userDefault objectForKey:@"gallerySlidePicsCount"] || [[userDefault objectForKey:@"gallerySlidePicsCount"] isEqualToString:@"0"]) {
            [self addTipView];
            [userDefault setObject:@"1" forKey:@"gallerySlidePicsCount"];
        }
    }];
}

+ (CGRect)getImageRect:(UIImage *)image {
    CGFloat ratio = 0;
    CGRect endFrame = kScreenRect;
    ratio = image.size.width / image.size.height;
    if (ratio > kScreenRatio) {
        endFrame.size.height = kScreenWidth / ratio;
    }
    else if (ratio < kScreenRatio) {
        endFrame.size.height = kScreenHeight * ratio;
    }
    else {
        
    }
    endFrame.origin.x = (kScreenWidth - endFrame.size.width) / 2;
    endFrame.origin.y = (kScreenHeight - endFrame.size.height) / 2;
    
    return endFrame;
}

#pragma mark - LoaingView TipView

+(void)addTipView
{
    UIImageView *tipImageView = [[UIImageView alloc]initWithFrame:[[UIScreen mainScreen] bounds]];
    tipImageView.image = [[UIImage imageNamed:@"icoprompt_bg_v5.9.png"]resizableImageWithCapInsets:UIEdgeInsetsMake(1, 4, 1, 2) resizingMode:UIImageResizingModeStretch];
    tipImageView.userInteractionEnabled = YES;
    [SNUtility getApplicationDelegate].window.windowLevel = UIWindowLevelStatusBar;
    [[SNUtility getApplicationDelegate].window addSubview:tipImageView];
    
    UIImage *picsImage = [UIImage imageNamed:@"icoprompt_arrows_v5.png"];
    UIButton *button = [[UIButton alloc] initWithFrame:CGRectMake((tipImageView.width - picsImage.size.width - 16)/2.0, -(picsImage.size.height), picsImage.size.width+16, picsImage.size.height)];
    button.titleLabel.font = [UIFont systemFontOfSize:16];
    [button setTitle:@"下滑退出图集" forState:UIControlStateNormal];
    [button setTitleColor:SNUICOLOR(kThemeText5Color) forState:UIControlStateNormal];
    button.titleLabel.lineBreakMode = UILineBreakModeWordWrap;//换行模式自动换行
    button.titleLabel.numberOfLines = 0;
    [button setImage:picsImage forState:UIControlStateNormal];
    [button setImageEdgeInsets:UIEdgeInsetsMake(0, 0, 0, 16)];
    [tipImageView addSubview:button];
    [UIView animateWithDuration:0.6 animations:^{
        button.frame = CGRectMake((tipImageView.width - picsImage.size.width - 16)/2.0, 0, picsImage.size.width+16, picsImage.size.height);
    } completion:^(BOOL finished) {
        
        [UIView animateWithDuration:2 animations:^{
            button.frame = CGRectMake((tipImageView.width - picsImage.size.width - 16)/2.0, -(picsImage.size.height), picsImage.size.width+16, picsImage.size.height);
            tipImageView.alpha = 0;
        } completion:^(BOOL finished) {
            [SNUtility getApplicationDelegate].window.windowLevel = 0;
            [tipImageView removeFromSuperview];
        }];
    }];
    
}

@end
