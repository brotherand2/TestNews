//
//  SNBadgeView.h
//  sohunews
//
//  Created by Gao Yongyue on 13-9-17.
//  Copyright (c) 2013年 Sohu.com. All rights reserved.
//

#import <UIKit/UIKit.h>

@class SNBadgeView;

/*
 返回总宽度和最大高度，回调方法按需求选择
 */
@protocol SNBadgeViewDelegate <NSObject>
@optional
- (void)badgeViewWidth:(float)width height:(float)height;
/*
 以下两个回调试用于一个delegate对应多个SMBadgeView的情况
 */
- (void)badgeViewWidth:(float)width height:(float)height identifier:(NSString *)identifier;
- (void)badgeViewWidth:(float)width height:(float)height badgeView:(SNBadgeView *)badgeView;
@end

/*
 显示徽章的类,一个SNBadgeView上可以有多个徽章
 某个徽章下载失败后，自动忽略，全部下载（成功+失败）完更新UI
 */
@interface SNBadgeView : UIView
@property (nonatomic, weak)id<SNBadgeViewDelegate> delegate;
@property (nonatomic, assign)float totalWidth;     //总宽度，数据不准确（还没完成下载前为0），完成下载后到重用前有意义
@property (nonatomic, assign)float totalHeight;    //总高度，数据不准确（还没完成下载前为0），完成下载后到重用前有意义
@property (nonatomic, strong)NSString *identifier; //可以为每个SNBadgeView设置不同的identifier来做唯一标示

- (id)initWithFrame:(CGRect)frame badges:(NSArray *)badgeListArray;

/*
 加载徽章,方法一是设置一个最大高度15.f；方法二时需要手动设置最大高度（传入0的时候，表示不设置最大高度），当徽章的实际高度大于最大高度时，等比例压缩
 */
- (void)reloadBadges:(NSArray *)badgeListArray;                               //方法一
- (void)reloadBadges:(NSArray *)badgeListArray maxHeight:(float)maxHeight;    //方法二

- (void)updateTheme;
@end
