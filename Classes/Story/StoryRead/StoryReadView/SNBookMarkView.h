//
//  SNBookMarkView.h
//  sohunews
//
//  Created by H on 2016/10/28.
//  Copyright © 2016年 Sohu.com. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SNStoryBookMarkAndNoteModel.h"

typedef NS_ENUM(NSInteger, SNBookMarkState) {
    /** 普通闲置状态 */
    SNBookMarkStateIdle = 1,
    
    /** 松开就可以进行添加/取消书签的状态 */
    SNBookMarkStatePulling,
    
    /** 正在请求添加书签接口中的状态 */
    SNBookMarkStateAdding,
    
    /** 正在请求添加书签接口中的状态 */
    SNBookMarkStateCanceling,
    
    /** 已经添加过书签了 */
    SNBookMarkStateDidAdded
};

#define IPHONEXOriginY    20.0;
@protocol SNBookMarkViewDelegate <NSObject>

- (void)bookMarkViewDidScroll:(CGFloat)offsetY;

@end

@interface SNBookMarkView : UITableView

@property (nonatomic, assign, readonly) SNBookMarkState markState;

@property (nonatomic, strong) UIImageView * bookMarkView;

/**
 当视图拖拽滚动时，可以使用代理来处理一些其他事情。
 */
@property (nonatomic, weak) id <SNBookMarkViewDelegate> bookMarkDelegate;

#pragma mark -- BookMark Info 将要添加书签的信息，每次翻页要更新信息

/**
 BookMark Info 将要添加书签的信息，每次翻页要更新信息
 */
@property (nonatomic, strong) SNStoryBookMarkAndNoteModel * model;

#pragma mark -- public Method

- (void)updateTheme;
- (void)checkBookMark;
- (void)bookMarkBackGroundColor:(UIColor *)color imageName:(NSString *)imageName;
/**
 设置是否可以执行书签动画并添加书签
 
 @param enable default  YES
 */
- (void)setBookMarkEnable:(BOOL)enable;
    
#pragma mark -- viewModel Method
- (void)contentOffsetDidChanged:(CGFloat)offsetY;

- (void)didEndDragging:(CGFloat)offsetY;

@end
