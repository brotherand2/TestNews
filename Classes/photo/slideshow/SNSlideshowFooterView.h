//
//  SNSlideshowFooterView.h
//  sohunews
//
//  Created by Gao Yongyue on 13-8-14.
//  Copyright (c) 2013年 Sohu.com. All rights reserved.
//

#import <UIKit/UIKit.h>

@class SNPhoto;

typedef void (^SNPictureFooterActionBlock)();
/*
 SNSlideshowFooterView是大图幻灯片下面简介和按钮的View
 */
@interface SNSlideshowFooterView : UIView

- (id)initWithFrame:(CGRect)frame pictureInfo:(SNPhoto *)picture;
- (void)updateAbstract:(SNPhoto *)picture;
//给外部提供设置具体返回、查看评论列表、发评论、下载、分享的接口
- (void)setBackButtonActionBlock:(SNPictureFooterActionBlock)backButtonActionBlock commentListButtonActionBlock:(SNPictureFooterActionBlock)commentListButtonActionBlock commentButtonActionBlock:(SNPictureFooterActionBlock)commentButtonActionBlock downloadButtonActionBlock:(SNPictureFooterActionBlock)downloadButtonActionBlock shareButtonActionBlock:(SNPictureFooterActionBlock)shareButtonActionBlock commentCount:(NSString *)commentCount;
- (void)showAllButtons;
- (void)showAdButtons;
- (void)hideAllButtons;
- (void)updateCommentCount:(NSString *)commentCount;
@end
