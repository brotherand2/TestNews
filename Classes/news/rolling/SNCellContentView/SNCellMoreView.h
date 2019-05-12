//
//  SNCellMoreView.h
//  sohunews
//
//  Created by lhp on 5/16/14.
//  Copyright (c) 2014 Sohu.com. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_OPTIONS(NSUInteger, SNCellMoreViewButtonOptions) {
    SNCellMoreButtonOptionsNone             = 0,
    SNCellMoreButtonOptionsUninterested     = 1 << 0,
    SNCellMoreButtonOptionsFavorites        = 1 << 1,
    SNCellMoreButtonOptionListenNews        = 1 << 2,
    SNCellMoreButtonOptionVideoAd           = 1 << 3, //lijian 2015.1.1 增加视频广告的全屏欣赏
    SNCellMoreButtonOptionNewsVideo         = 1 << 4,  //by cuiliangliang 2016.5.5 增加流内的全屏欣赏
    SNCellMoreButtonOptionShare             = 1 << 5, // huangzhen 分享
    SNCellMoreButtonOptionReport            = 1 << 6,  //by cuiliangliang 2016.7.26 增加举报
    SNCellMoreButtonOptionAddBookShelf      = 1 << 7    // huangzhen 添加到书架
};

typedef void (^SNCellMoreUninterestBlock)(void);
//typedef void (^SNCellMoreFavoritesBlock)(void);
typedef void (^SNCellMoreFavoritesBlock)(NSDictionary *);
typedef void (^SNCellMoreListenNewsBlock)(void);
typedef void (^SNCellMoreReportBlock)(void);
typedef void (^SNCellMoreAddBookShelfBlock)(void);


@protocol SNCellMoreViewFullactionDelegate <NSObject>

- (void)fullScreenEnjoy;

@end

@protocol SNCellMoreViewShareDelegate <NSObject>

- (void)share;

@end

@interface SNCellMoreView : UIView
{
    SNCellMoreViewButtonOptions buttonOptions;
    NSString *identifier;
    BOOL newsFavorited;
    BOOL addBookShelf;
    
    SNCellMoreUninterestBlock uninterestBlock;
    SNCellMoreFavoritesBlock favoritesBlock;
    SNCellMoreListenNewsBlock listenBlock;
    SNCellMoreReportBlock   reportBlock;
    SNCellMoreAddBookShelfBlock   addBookBlock;
}
@property (nonatomic, strong) NSString *identifier;
@property (nonatomic, weak) id <SNCellMoreViewFullactionDelegate> fullActionDelegate;
@property (nonatomic, weak) id <SNCellMoreViewShareDelegate> shareActionDelegate;
@property (nonatomic, assign) id assignBaseCellDelegate;//是否加入书架
- (id)initWithFrame:(CGRect)frame
      buttonOptions:(SNCellMoreViewButtonOptions) options
      newsFavorited:(BOOL)favorited isAddBookShelf:(BOOL)isAddBookShelf;

- (void)setUninterestBlock:(void (^)(void)) uniBlock
            favoritesBlock:(SNCellMoreFavoritesBlock) favBlock
               listenBlock:(void (^)(void)) lisBlock
               reportBlock:(void (^)(void)) reBlock
         addBookShelfBlock:(void (^)(void)) addBookShelfBlock;

//@qz 隐藏毛玻璃效果
- (void)hideBlurEffort;
- (void)removeCloseButton;
@end
