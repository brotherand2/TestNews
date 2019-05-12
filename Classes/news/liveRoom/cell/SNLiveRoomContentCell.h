//
//  SNBroadcastContentCell.h
//  sohunews
//
//  Created by Chen Hong on 12-6-15.
//  Copyright (c) 2012年 Sohu.com Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SNLiveRoomBaseCell.h"
#import "SNHeadIconView.h"
#import "SNLiveLinkView.h"
#import "SNLiveSoundView.h"
#import "SNWebImageView.h"
#import "SNNameButton.h"
#import "SNBadgeView.h"
#import "SNSTFWebImageView.h"

@class SNLiveRoomTableViewController;
@class SNLiveRoomTapView;
@class SNLiveContentObject;
@class SNLiveCommentObject;

@interface SNLiveRoomContentCell : SNLiveRoomBaseCell<SNBadgeViewDelegate> {
    // 基础元素
    UILabel         *_timeLabel;
    SNNameButton    *_authorBtn;
    UILabel         *_tuiguang;
    SNBadgeView     *_authorBadge;
    SNLabel         *_contentLabel;
    SNNameButton        *_showAllContentBtn;
    UIImageView         *_bgnImgView;   // 气泡背景
    SNLiveHeadIconView  *_headIcon;     // 直播员icon
    UILabel             *_roleLabel;    // 角色
    
    // 链接或音频
    SNLiveLinkView      *_linkView;     // 链接
    SNLiveSoundView     *_soundView;    // 音频
    
    // 图片或视频
    SNSTFWebImageView     *_imgView;          // 图片
    UIButton        *_maskBtn;          // 用于图片点击的按钮
    UIImageView     *_gifIcon;          // gif icon
    UILabel         *_mediaLengthLabel; // 视频时长
    UILabel         *_mediaSizeLabel;   // 视频大小
    
    
    // 回复
    UIImageView     *_sepLine;          // 分隔线
    
    UILabel         *_replyTimeLabel;
    SNNameButton    *_replyAuthorBtn;
    SNBadgeView     *_replyAuthorBadge;
    SNLabel         *_replyContentLabel;
    SNNameButton    *_showAllReplyCommentBtn;
    SNLiveLinkView      *_replyLinkView;
    SNLiveSoundView  *_replySoundView;
    SNWebImageView     *_replyImgView;
    UIButton        *_replyMaskBtn;
    UIImageView     *_replyGifIcon;
    UILabel         *_replyMediaLengthLabel; // 视频时长
    UILabel         *_replyMediaSizeLabel;   // 视频大小
    
    // 点击弹出菜单
    SNLiveRoomTapView  *_topTapView;
    SNLiveRoomTapView  *_bottomTapView;
    
    SNLiveRoomTableViewController *__weak _viewController;
    
    UIColor        *authorColor;
    UIColor        *timeColor;
    
    NSString *_commentId;//分享出去的评论带id  sns需求
}

@property(nonatomic,strong) SNLabel *contentLabel;
@property(nonatomic,weak) SNLiveRoomTableViewController *viewController;
@property(nonatomic,strong) UIColor *authorColor;
@property(nonatomic,strong) UIColor *timeColor;
@property(nonatomic,strong) SNWebImageView *imgView;
@property(nonatomic,strong) SNWebImageView *replyImgView;
@property(nonatomic,strong) UIImageView *bgnImgView;

+ (CGFloat)tableView:(UITableView*)tableView rowHeightForObject:(id)object;

- (BOOL)keyboardShow;

- (void)copyContent:(SNLiveRoomTapView *)sender;
- (void)replyComment:(SNLiveRoomTapView *)sender;
- (void)shareContent:(SNLiveRoomTapView *)sender;

- (void)updateTheme:(NSNotification *)notification;

- (void)showVideoControllerWithUrl:(NSString *)urlPath poster:(NSString *)posterUrl
             videoPlaceHolderFrame:(CGRect)videoPlaceHolderFrame;

- (void)hideBottom;

- (void)setTopWithContentObj:(SNLiveContentObject *)data;

- (void)setTopWithCommentObj:(SNLiveCommentObject *)data;

- (void)setBottomWithContentObj:(SNLiveContentObject *)data;

- (void)setBottomWithCommentObj:(SNLiveCommentObject *)data;

- (CGFloat)layoutReplyComment:(SNLiveCommentObject *)data left:(CGFloat)left top:(CGFloat)top;

- (CGFloat)layoutReplyContent:(SNLiveContentObject *)data left:(CGFloat)left top:(CGFloat)top;

- (UIImage *)imgViewPlaceholderImage;

- (void)updateImageView:(SNWebImageView *)imgView withUrl:(NSString *)urlPath;

- (void)loadImageView:(SNWebImageView *)imgView withUrl:(NSString *)urlPath;

- (NSString *)topImageViewUrl;

- (NSString *)bottomImageViewUrl;

- (void)layoutTopBadgeView;

- (void)layoutBottomBadgeView;

@end
