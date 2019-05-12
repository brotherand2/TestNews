//
//  SNChannelView.h
//  sohunews
//
//  Created by jojo on 13-10-15.
//  Copyright (c) 2013年 Sohu.com. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SNChannelManageContants.h"
#import "SNChannelManageObject.h"

#define kHomePageChannelTop @"2"////是否置顶  {0:常规 ，1: 置顶可排序，  2:置顶不可排序}
#define kBanChannelMoveToUnSub @"3"//频道不允许移动到待选区
@protocol SNChannelViewDelegate;

@interface SNChannelView : UIView

@property (nonatomic, weak) id<SNChannelViewDelegate> delegate;
@property (nonatomic, strong) SNChannelManageObject *chObj;
@property (nonatomic, assign, getter = isEditMode) BOOL editMode;
@property (nonatomic, assign) BOOL isSubed;
@property (nonatomic, assign) BOOL isDull;
@property (nonatomic, assign, getter = isAddNew) BOOL addNew;
@property (nonatomic, assign) BOOL isSelected;
@property (nonatomic, assign) BOOL isMoveOut;

// for subClass
@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UIButton *deleteButton;
@property (nonatomic, strong) UIImageView *titleMarkImageView;

- (void)showExpanding:(BOOL)show;
- (void)showEditMode:(BOOL)show;
- (void)moveToMoreChannelAnimationWithCenter:(CGPoint) center;
- (void)showShadow:(BOOL) isShow;

@end

@protocol SNChannelViewDelegate <NSObject>

@required

// long press event
- (BOOL)channelViewShouldActiveEditModeAfterLongPressed:(SNChannelView *)channelView;

// handle channel view move events
- (void)channelViewDidStartMove:(SNChannelView *)channelView;
- (void)channelViewDidMoved:(SNChannelView *)channelView;
- (void)channelViewDidEndMove:(SNChannelView *)channelView;

// action events
- (void)channelViewDidExpading:(SNChannelView *)channelView;
- (void)channelViewDidTapped:(SNChannelView *)channelView;
- (void)channelViewDidSelectDelete:(SNChannelView *)channelView;

//处理长按与点击时间间隔短问题
- (void)resetChannelMoveOut;

@end
