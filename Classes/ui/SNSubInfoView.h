//
//  SNSubInfoView.h
//  sohunews
//
//  Created by wang yanchen on 13-6-4.
//  Copyright (c) 2013年 Sohu.com. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SNWaitingActivityView.h"

#define kViewWidth_Article              (kAppScreenWidth - 28)//(584 / 2)
#define kViewHeight_Article             (98 / 2)
#define kIconSize_Article               (60 / 2)
#define kIconLeftMargin_Article         (18 / 2)
#define kIconBottomMargin_Article       (18 / 2)
#define kBtnTopMargin_Article           (0 / 2)
#define kBtnRightMargin_Article         (20 / 2)

#define kViewWidth_Gallery              (620 / 2)
#define kViewHeight_Gallery             (72 / 2)
#define kIconLeftMargin_Gallery         (28 / 2)
#define kIconTopMargin_Gallery          (5 / 2)
#define kIconSize_Gallery               (kViewHeight_Gallery - 2 * kIconTopMargin_Gallery)
#define kBtnTopMargin_Gallery           (6 / 2)
#define kBtnRightMargin_Gallery         (28 / 2)

typedef void (^SNSubInfoViewBackActionBlock)();
// 正文 、 组图 出现的所属刊物信息 点击去往刊物详细页  点击按钮“添加订阅”
// 在没有订阅该刊物的时候  显示

typedef enum {
    SNSubInfoViewTypeArticle = 1,   // 出现在正文中
    SNSubInfoViewTypeGallery    // 组图大图模式
}SNSubInfoViewType;

@protocol SNSubInfoViewDelegate <NSObject>
@optional
- (void)subInfoViewDetailDidShow;
@end

@interface SNSubInfoView : UIView {
    SNSubInfoViewType _type;
    SNWaitingActivityView *_loadingView;
}

@property(nonatomic, strong) SCSubscribeObject *subObj;
@property(nonatomic, assign) SNReferFrom refer;
@property(nonatomic, weak) id<SNSubInfoViewDelegate> delegate;
@property (nonatomic, copy) NSString * newsId;
@property(nonatomic, strong) UIImageView *arrowImage;
@property(nonatomic, strong) SNWebImageView *iconView;
@property(nonatomic, strong) UIButton *addFollowButton;
@property(nonatomic, strong) UIButton *maskButton;
@property(nonatomic, strong) UILabel *subTitleLabel;

- (void)updateFollowedInfo;
- (id)initWithSubInfoViewType:(SNSubInfoViewType)type;
@end
