//
//  SNHotTableViewController.h
//  sohunews
//
//  Created by ivan.qi on 3/6/12.
//  Copyright (c) 2012 Sohu.com Inc. All rights reserved.
//

#import "SNDragRefreshTableViewController.h"
#import "SNPhotoTableDelegate.h"
#import "SNGuideMaskController.h"
#import "SNChannelScrollTabBar.h"

@class CategoryItem;

@interface SNPhotosTableController : SNDragRefreshTableViewController {
    NSString *targetType;
    NSString *typeId;
    
    BOOL isMoveUp;
    
    UIView *coverLayer;
    SNPhotoTableDelegate *_dragDelegate;
    BOOL isMoving;
    
    UIView *coverLayerView;
    BOOL isViewReleased;
    int currentViewPage;
    NSString *currentOffSet;
    NSString *currentMinTimeline;
    
    BOOL isAnimating;
    
    SNChannelScrollTabBar *tabBar;
    
    UIButton *_tagBtn;
    
    NSString *titleString;
    
    BOOL _isShowTag;
    BOOL isTagAnimating;
    SNTagItem *_tagItem;
    BOOL _needLoadTagPhoto;
    NSIndexPath *lastIndexPath;
    
    BOOL isCreated;

    BOOL isViewAppeared;
    
    BOOL needScrollToTop;
    
    int _selectedIndex;
    
    UIView *_maskView;
    
    BOOL isPhotoList;
}

@property(nonatomic, readwrite)BOOL isMoving;
@property(nonatomic, readwrite)BOOL isViewReleased;
@property(nonatomic, strong)UIView *coverLayerView;
@property(nonatomic, copy)NSString *currentMinTimeline;
@property(nonatomic, copy)NSString *currentOffSet;
@property(nonatomic, copy)NSString *targetType;
@property(nonatomic, copy)NSString *typeId;
@property(nonatomic, readwrite)int currentViewPage;
@property(nonatomic, strong)SNChannelScrollTabBar *tabBar;
@property(nonatomic, copy)NSString *titleString;
@property(nonatomic, strong)NSIndexPath *lastIndexPath;
@property(nonatomic, readonly)BOOL isCreated;
@property(nonatomic, strong)SNPhotoTableDelegate *dragDelegate;
@property(nonatomic, assign)BOOL isViewAppeared;
@property(nonatomic, assign)BOOL needScrollToTop;
@property(nonatomic, assign)BOOL isPhotoList;

- (void)tabBar:(SNChannelScrollTabBar *)tabBar tabSelected:(NSInteger)selectedIndex;
-(void)changeFavoriteNum:(NSString *)newsId favNum:(int)favNum;
-(void)updatePhotoNewsReadStyle:(NSString *)newsId;
-(void)cacheCellIndexPath:(UITableViewCell *)aCell;
-(void)selectedCategoryByChannelBar:(CategoryItem *)aCategory;
-(void)updateTheme;

@end
