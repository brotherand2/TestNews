//
//  SNTimelineTrendCell.h
//  sohunews
//
//  Created by jialei on 13-9-12.
//  Copyright (c) 2013年 Sohu.com. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SNLabel.h"
#import "SNLiveSoundView.h"
#import "SNTableViewCell.h"
#import "SNTimelineConfigs.h"
#import "SNTimelineTrendObjects.h"
#import "SNWebImageView.h"
#import "SDImageCache.h"
#import "SNTrendCommentsView.h"
#import "SNActionSheet.h"

@class SNTimelineTrendItem;
@class SNHeadIconView;
@class SNApprovalButton;
@class SNTrendCommentButton;
@class SNTrendCommentsView;
@class SNTimelineTrendCell;

@protocol SNTLTrendActionDelegate <NSObject>

- (void)timelineCellDelete:(NSDictionary *)dic;

@end

@interface SNTimelineTrendCell : SNTableViewCell<SNLabelDelegate,
SNTrendCmtsViewDelegate, SNActionSheetDelegate>
{
    CGRect _originalContentRect;
    UIView *_originalTapview;       //点击区域
    
    UILabel *_sourceLabel;
    UILabel *_userNameLabel;
    UILabel *_timeLabel;
    SNHeadIconView *_headIconView;
    UILabel *_fromTypeLabel;
    SNLabel *_contentLabel;
    SNLiveSoundView *_soundView;
    SNWebImageView *_picView;
    
    SNLabel *_abstractLabel;
    SNWebImageView *_originalImageView;
    UIImageView *_originalBgView;
    UIImageView *_videoIconView;
    UILabel *_originTitleLabel;
    UILabel *_originFromLabel;
    
    SNTrendCommentButton *_commentButton;
    SNApprovalButton *_approvalButton;
    UIButton *_deleteButton;
    UIButton *_moreButton;
    SNTrendCommentsView *_commentsView;
    
    UIImage *_subIconBgImage;
    UIImage *_originDefaultImage;
    UIImage *_originBgImage;
    UIImage *_commentBgImage;
    UIImage *_originDfClickImage;
    float   _viewOffsetY;
}

@property (nonatomic, strong)SNTimelineTrendItem *timelineTrendObj;
@property (nonatomic, assign) int indexPath;
@property (nonatomic, weak) id delegate;
@property (nonatomic, assign) BOOL needSepLine;
@property (nonatomic, assign) BOOL canEnterCenter;
@property (nonatomic, assign) int referFrom; // 区分是我tab还是用户中心的动态；
@property (nonatomic, strong)UILabel *cmtNumLabel;

+ (CGFloat)heightForTimelineTrendObj:(SNTimelineTrendItem *)obj;
+ (Class)cellClassForItem:(SNTimelineItemType)trendType;
- (void)setTrendObject:(SNTimelineTrendItem *)timelineObj;

//overwrite,子类重写来实现各自的文本，原文绘制方式;
- (void)setContent;
- (void)setOriginView;
- (void)setOriginalImageView;
- (void)setOriginTitleAndFrom;
- (void)setOriginalImageUrl:(NSString *)urlPath isRelyNetwork:(BOOL)isDownload;
- (void)updateTheme;
- (void)enterUserCenter:(NSMutableDictionary *)dic;
- (void)enterUserCenter;
- (void)openOriginalContentAction:(id)sender;
//设置评论数
- (void)setCommentNum;
@end
