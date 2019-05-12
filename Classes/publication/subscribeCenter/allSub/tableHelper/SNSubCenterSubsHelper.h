//
//  SNSubCenterSubsHelper.h
//  sohunews
//
//  Created by wang yanchen on 12-11-22.
//  Copyright (c) 2012年 Sohu.com Inc. All rights reserved.
//

#import "SNSubCenterTableHelper.h"
#import "SNSubCenterMoreCell.h"
#import "SNSubscribeHintPushAlertView.h"

#define kSubCellHeight                      (146 / 2)

@class SNSubscribeHintPushAlertView;
@interface SNSubCenterSubsHelper : SNSubCenterTableHelper {
    NSString *_typeId;
    NSMutableArray *_subsArray;
    
    NSMutableArray *_subsRunningOnAddToMySub;
    NSInteger _pageNum;
    BOOL _hasMore;
    BOOL _isLoading;
    BOOL _needForceRefresh;
    
    SNSubCenterMoreCell *_moreCell;
    SNSubscribeHintPushAlertView *_subAlertView;
}

@property(nonatomic, strong) NSMutableArray *subsArray;
@property(nonatomic, strong) NSMutableArray *subsRunningOnAddToMySub;
@property(nonatomic, copy) NSString *typeId;
@property(nonatomic, assign) BOOL needForceRefresh;

@end

@protocol SNSubCenterSubHelpDelegate <NSObject>

@optional
- (void)allSubTableDidScroll:(UIScrollView *)scrollview;
- (void)subsStartToLoad;
- (void)subsFindNoDataToLoad;
- (void)subsFindDataToLoad;
- (BOOL)isAdViewShown;
@end
