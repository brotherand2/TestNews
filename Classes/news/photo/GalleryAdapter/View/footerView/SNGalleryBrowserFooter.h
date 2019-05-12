//
//  SNGalleryBrowserFooter.h
//  sohunews
//
//  Created by Huang Zhen on 06/02/2017.
//  Copyright © 2017 Sohu.com. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SNAbstractTextView.h"

typedef void (^SNPictureFooterActionBlock)();

@class NewsImageItem;
@class PhotoItem;
@interface SNGalleryBrowserFooter : UIView
@property (nonatomic, strong) UILabel * titleLabel;
@property (nonatomic, strong) UILabel * indexLabel;
@property (nonatomic, strong) SNAbstractTextView * abstractContentView;
@property (nonatomic, strong) UIImageView * maskImageView;
@property (nonatomic, strong) UIButton * backButton;
@property (nonatomic, strong) UIButton * downloadButton;
@property (nonatomic, strong) UIButton * shareButton;

/**
 刷新footer摘要和页码

 @param abstract 摘要信息
 @param newsTitle 新闻标题
 @param index 页码
 @param count 总页码
 */
- (void)updateAbstract:(NSString *)abstract title:(NSString *)newsTitle currentIndex:(NSUInteger)index total:(NSUInteger)count;
- (void)updateIndex:(NSUInteger)index count:(NSUInteger)count;

//给外部提供设置具体返回、下载、分享的接口
- (void)setBackButtonActionBlock:(SNPictureFooterActionBlock)backButtonActionBlock
       downloadButtonActionBlock:(SNPictureFooterActionBlock)downloadButtonActionBlock
          shareButtonActionBlock:(SNPictureFooterActionBlock)shareButtonActionBlock;

- (void)hideSomeButtons;

@end
