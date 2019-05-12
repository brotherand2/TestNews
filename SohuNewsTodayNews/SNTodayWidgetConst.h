//
//  SNTodayWidgetConst.h
//  WidgetApp
//
//  Created by WongHandy on 8/5/14.
//  Copyright (c) 2014 WongHandy. All rights reserved.
//

#import <Foundation/Foundation.h>

static const int kSNTodayWidgetContentTableCellMaxCount = 3;
static const CGFloat kSNTodayWidgetContentTableCellHeight = 73.0f;
static const CGFloat kSNTodayWidgetContentTableGroupPhotoCellHeight = 115.0f;

static const CGFloat kSNTodayWidgetContentWidth = 320.0f;
static const CGFloat kSNTodayWidgetContentHeight = kSNTodayWidgetContentTableCellHeight*kSNTodayWidgetContentTableCellMaxCount;

static const CGFloat kSNTodayWidgetContentTableCellTitleFontSize = 15.0f;
static const CGFloat kSNTodayWidgetContentTableCellTitleFontSizeIOS10 = 17.0f;
static const CGFloat kSNTodayWidgetContentTableCellCommentCountHPaddingCountIcon = 6.0f;
static const CGFloat kSNTodayWidgetContentTableCellCommentCountLabelFontSize = 11.0f;
static const CGFloat kSNTodayWidgetContentTableCellCommentCountLabelFontSizeIOS10 = 11.0f;
//#define kSNTodayWidgetContentTableCellIconLabelTextColor [UIColor colorWithRed:77.0f/255.0f green:133.0f/255.0f blue:161.0f/255.0f alpha:0.6]
#define kSNTodayWidgetContentTableCellIconLabelTextColor [UIColor whiteColor]

static const CGFloat kMoreNewsSectionHeight = 57.0f;//(20+17)


#define kSNTodayWidgetContentTableTextCellCommentCountIconWidth 12.0f
#define kSNTodayWidgetContentTableTextCellCommentCountIconHeight 11.0f

#define CELL_LEFT                                               0
#define CELL_TOP                                                10
#define CELL_IMAGE_WIDTH                                        ([[SNDevice sharedInstance] isPlus]?(338/3):(194/2))
#define CELL_IMAGE_HEIGHT                                       ([[SNDevice sharedInstance] isPlus]?(219/3):(126/2))
#define kSNTodayWidgetContentTableImgTextCellNormalNewsImgTop  10.0f

#define SYSTEM_VERSION_LESS_THAN(v)                 ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedAscending)
#define kAppScreenWidth  [UIScreen mainScreen].bounds.size.width

