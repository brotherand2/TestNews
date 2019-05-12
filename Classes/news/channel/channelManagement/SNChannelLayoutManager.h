//
//  SNChannelLayoutManager.h
//  sohunews
//
//  Created by jojo on 13-10-15.
//  Copyright (c) 2013年 Sohu.com. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SNChannelManageObject.h"
#import "SNChannelView.h"

@interface SNChannelLayoutHolder : NSObject

@property (nonatomic, assign) BOOL isDull;
@property (nonatomic, assign) CGPoint guestCenter;
@property (nonatomic, strong) UIView *guestView;

- (void)letitgo;

@end

////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////

@interface SNChannelLayoutManager : NSObject

// constant
@property (nonatomic, assign) int maxColumnSize;
@property (nonatomic, assign) CGFloat sideMargin;
@property (nonatomic, assign) CGFloat topMargin;
@property (nonatomic, assign) CGFloat bottomMargin;
@property (nonatomic, assign) CGFloat spacingHorizen;
@property (nonatomic, assign) CGFloat spacingVertical;
@property (nonatomic, assign) CGSize guestViewSize;
@property (nonatomic, assign) CGSize guestExpandSize;

// variable
@property (nonatomic, weak) UIView *channelsContainer;

@property (nonatomic, assign) CGFloat startY;
@property (nonatomic, assign) CGFloat totalHeight;

@property (nonatomic, strong) NSMutableArray *guests; // array of layout holder

@property (nonatomic, assign)BOOL isReturnLine;
@property (nonatomic, strong)NSString *tempCategoryID;
@property (nonatomic, assign)CGFloat recordX;
@property (nonatomic, assign)CGFloat recordY;
@property (nonatomic, assign)CGFloat tailRecordY;
@property (nonatomic, assign)CGFloat tempRecordY;
@property (nonatomic, assign)NSInteger channelIndex;
@property (nonatomic, assign)BOOL isMyChannelManager;
@property (nonatomic, assign)NSInteger tempChannelIndex;
@property (nonatomic, assign)BOOL isChannelMoveOut;

// 创建channel view
- (SNChannelView *)buildChannelViewWithChannelObj:(SNChannelManageObject *)chObj;

// 编辑之前
- (SNChannelLayoutHolder *)appendAGuestView:(UIView *)guestView;
- (SNChannelLayoutHolder *)removeAGuestView:(UIView *)guestView;

// for 编辑完了之后
- (void)appendAGuestViewHolder:(SNChannelLayoutHolder *)hd;
- (void)insertAGuestViewHolder:(SNChannelLayoutHolder *)hd atIndex:(NSInteger)index;
- (void)clearBlankOutline;

- (CGPoint)centerPointForGuestViewIndex:(int)index;
- (void)calculateAllGuestViews;
- (void)layoutAllGuestViews;

// return hit index
- (int)receiveHitAtPoint:(CGPoint)pt;
- (void)showPositionOutLine:(BOOL)show animated:(BOOL)animated;
- (int)totalCountOfChannelView;

- (void)removeEmptyCategoryLabel;
- (void)updateTheme;

@end
