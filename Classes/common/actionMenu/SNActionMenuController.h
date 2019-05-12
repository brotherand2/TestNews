//
//  SNActionMenuController.h
//  sohunews
//
//  Created by wangxiang on 3/19/12.
//  Copyright (c) 2012 Sohu.com Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SNWXHelper.h"
#import "SmsSupport.h"
#import "SNActionMenu.h"
#import "SNActionMenuContent.h"
#import "SNDatabase_ReadCircle.h"

typedef void(^VideoShareToLogin)(id objc);

@interface SNActionMenuController : NSObject <SNActionMenuDelegate>

@property (nonatomic, strong) SNActionMenuContent *content;
@property (nonatomic, assign) ShareSubType shareSubType;
@property (nonatomic, strong) NSMutableDictionary *contextDic;
@property (nonatomic, weak) id delegate;

// 以下属性用于分享成功之后进行统计
@property (nonatomic, copy) NSString *shareLogType;
@property (nonatomic, copy) NSString *shareLogContent;
@property (nonatomic, copy) NSString *shareLogSubId;//todo 不知道从哪传进来的

@property (nonatomic, assign) BOOL isLiked;
@property (nonatomic, assign) BOOL disableLikeBtn;
@property (nonatomic, assign) BOOL disableSMSBtn;
@property (nonatomic, assign) BOOL disableCopyLinkBtn;
@property (nonatomic, assign) BOOL disableQZoneBtn;
@property (nonatomic, assign) BOOL disableMySNSBtn;
@property (nonatomic, assign) BOOL isLoadingShare;
@property (nonatomic, assign) BOOL isVideoShare;
@property (nonatomic, assign) BOOL isQianfanShare;
@property (nonatomic, assign) BOOL isOnlyImage;//仅正文长按大图
@property (nonatomic, copy) NSString *hideShareIcons;
@property (nonatomic, copy) NSString *floatTitle;

@property (nonatomic, strong) SNActionMenu *actionMenu;

@property (nonatomic, assign) SNTimelineContentType timelineContentType;
@property (nonatomic, copy)   NSString *timelineContentId;
@property (nonatomic, copy) NSString *newsLink;//todo
@property (nonatomic, assign) int sourceType;

@property (nonatomic, assign) SNActionMenuButtonType lastButtonType;

@property (nonatomic, copy) VideoShareToLogin shareToLogin;

- (void)showActionMenu;
- (void)showActionMenuFromView:(UIView *)fromView;
- (void)showActionMenuFromLandscapeView:(UIView *)fromView;
- (void)showActionNewMenuFromLandscapeView:(UIView *)fromView;
- (void)dismissActionMenu;

- (void)halfFloatViewActionMenu:(SNActionMenuOption)menuOption;

- (void)showAlipyActionMenu:(NSString *)title alipayName:(NSString *)alipayName;

@end


///**
// *  -----------------------SNShareCollectionViewCell-----------------------
// */
//@interface SNShareCollectionViewCell : UICollectionViewCell
//
//- (void)setDataWithDict:(NSDictionary *)dict;
//- (void)setImageViewStateWithHightlighted:(BOOL)hightlight andDict:(NSDictionary *)dict;
//
//@end

/**
 *  -----------------------SNShareCollectionViewLayout-----------------------
 */
//@interface SNShareCollectionViewLayout : UICollectionViewLayout
//
//@property (nonatomic) CGFloat minimumLineSpacing;              // 最小 Item 行间距
//
//@property (nonatomic) CGFloat minimumInteritemSpacing;         // 最小 Item 列间距
//
//@property (nonatomic) CGSize  itemSize;                        // Item 尺寸
//
//@property (nonatomic) UIEdgeInsets sectionInset;               // Item 内边距
//
//- (instancetype)init;
//
//@end

@protocol SNActionMenuControllerDelegate <NSObject>

@optional
- (void)actionMenuControllerShareSuccess:(NSString *)message;
- (void)actionMenuControllerShareFailed:(NSString *)message;

- (void)actionmenuDidSelectLikeBtn;
- (void)actionmenuDidSelectDownloadBtn;
- (void)actionmenuWillSelectItemType:(SNActionMenuOption)type;


- (void)actionmenuDidSelectItemTypeCallback:(SNActionMenuOption)type;

@end
