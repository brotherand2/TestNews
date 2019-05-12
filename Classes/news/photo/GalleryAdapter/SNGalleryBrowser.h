//
//  SNGalleryBrowser.h
//  SNNewGallery
//
//  Created by H.Ekko on 03/01/2017.
//  Copyright © 2017 Huang Zhen. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "SNGalleryConst.h"
#import "SNGalleryBrowserController.h"

#define SNGalleryBrowserMainThreadAssert() NSAssert([NSThread isMainThread], @"SNGalleryBrowser needs to be accessed on the main thread.");


@interface SNGalleryBrowser : NSObject

/**
 开始图集浏览 
 
 @param article 文章数据源 图文新闻 传递对象为SNArticle
                         组图新闻 传递对象为GalleryItem
 @param currentImageUrl 当前点击的图片url
 @param currentIndex 当前的index，默认0
 @param fromRect 原图相对屏幕的位置，用于打开动画，默认为屏幕中心
 @param fromView 期望的父视图，如果为nil，则自动设置为UIWindow.main
 @param info 其他信息，用于订制化，可为nil
 @param dismissBlock 关闭图集浏览的回调
 @return 返回一个 SNGalleryBrowser 实例
 */
+ (SNGalleryBrowserController *)showGalleryWithArticle:(id)article
                               currentImageUrl:(NSString *)currentImageUrl
                                  currentIndex:(NSUInteger)currentIndex
                                      fromRect:(CGRect)fromRect
                                      fromView:(UIView *)fromView
                                          info:(NSDictionary *)info
                                  dismissBlock:(GalleryDismissBlock)dismissBlock;


@end
