//
//  SNHotTableViewController.m
//  sohunews
//
//  Created by ivan.qi on 3/6/12.
//  Copyright (c) 2012 Sohu.com Inc. All rights reserved.
//

#import "SNPhotosTableController.h"
#import "SNPhotoDataSource.h"
#import "SNPhotoTableCell.h"
#import "SNDBManager.h"
#import "UIColor+ColorUtils.h"
#import "SNPhotosChannelDataSource.h"

#define TITLE_FONT_SIZE             (20)
#define MAX_TITLE_WHDTH             (200)
#define TITLE_HEIGHT                (40)
#define ARROW_IMAGE_W               (15)
#define ARROW_IMAGE_H               (8)
#define ARROW_TITLE_MARGIN          (7.5)
#define MOVE_TO_ORIGIN_Y            (TTApplicationFrame().size.height-49)//(480-20-49)
#define kChannelBarHeight           (66/2)
#define kTableTopMargin             (-7)
#define kTagViewHeight              (260)
#define kTagViewTopMargin           (-6)

@implementation SNPhotosTableController

@synthesize coverLayerView, isMoving, targetType, typeId, currentViewPage, currentMinTimeline, isViewReleased,currentOffSet;
@synthesize tabBar, titleString, lastIndexPath, isCreated, dragDelegate=_dragDelegate;
@synthesize isViewAppeared, needScrollToTop;
@synthesize isPhotoList;

- (id)initWithNavigatorURL:(NSURL*)URL query:(NSDictionary*)query {
    if (self = [super initWithNavigatorURL:URL query:query]) {
        
        self.targetType = [query objectForKey:kTargetType];
		self.typeId = [query objectForKey:kTypeId];
        self.titleString = [query objectForKey:kTitle];
        if (!self.titleString) {
            self.titleString = NSLocalizedString(@"photoGroupTabbarName", nil);
        }
        _isShowTag = [self.targetType isEqualToString:kGroupPhotoTag];
        if (!_isShowTag) {
            [self customTabbarStyle:@"photo1.png" activeIcon:@"photo2.png" title:NSLocalizedString(@"photoGroupTabbarName", nil)];
            
            CategoryItem *firstCategory = [[SNDBManager currentDataBase] getFirstCachedCategory];
            if (firstCategory) {
                self.targetType  = kGroupPhotoCategory;
                self.typeId      = firstCategory.categoryID;
            } else {
                self.targetType  = kGroupPhotoCategory;
                self.typeId      = kGroupPhotoDefaultId;
            }
        } else {
            self.hidesBottomBarWhenPushed = YES;
        }
    }
	
    return self;
}

- (BOOL)canShowModel {
    NSInteger count = ((SNPhotoDataSource *)self.dataSource).hotPhotoModel.allPhotos.count;
    BOOL firstAndNoCache = ((SNPhotoDataSource *)self.dataSource).hotPhotoModel.firstAndNoCache;
    if (firstAndNoCache) {
        ((SNPhotoDataSource *)self.dataSource).hotPhotoModel.firstAndNoCache = NO;
        return YES;
    } 
    return count > 0;
}
 
- (BOOL)shouldLoad {
     NSInteger count = ((SNPhotoDataSource *)self.dataSource).hotPhotoModel.allPhotos.count;
     return count == 0;
}

- (void)createModel {
     //(_dragDelegate);
    [self createDelegate];
    
	SNPhotoDataSource *ds = [[SNPhotoDataSource alloc] initWithType:self.targetType andId:self.typeId];
    ds.photosTableController = self;
    [_dragDelegate setModel:ds.hotPhotoModel];
	self.dataSource = ds;
}

-(void)reCreateModel {
     //(_dragDelegate);
    
    [self createDelegate];
    SNPhotoDataSource *ds = [[SNPhotoDataSource alloc] initWithType:self.targetType 
                                                              andId:self.typeId 
                                                         latestPage:currentViewPage
                                                    lastMinTimeline:currentMinTimeline
                                                         lastOffset:currentOffSet];
    ds.photosTableController = self;
    [_dragDelegate setModel:ds.hotPhotoModel];
	self.dataSource = ds;
    SNPhotoModel *pModel = (SNPhotoModel *)self.dataSource.model;
    pModel.isRecreate = YES;
}

- (id)createDelegate {
    if (!_dragDelegate) {
        CGRect headViewFrame = CGRectMake(0,
                                          -self.tableView.height,
                                          self.tableView.width,
                                          self.tableView.height);
        SNTableHeaderDragRefreshView *headView = [[SNTableHeaderDragRefreshView alloc] initWithFrame:headViewFrame needTipsView:YES];
        _dragDelegate = [[SNPhotoTableDelegate alloc] initWithController:self headView:headView];
        [self resetTableDelegate:_dragDelegate];
    }

	return _dragDelegate;
}

- (void)didShowModel:(BOOL)firstTime {
    SNPhotoModel *pModel = (SNPhotoModel *)self.dataSource.model;
    if (isViewReleased) {
        isViewReleased = NO;
        if (lastIndexPath && lastIndexPath.row < pModel.allPhotos.count) {
            [self.tableView scrollToRowAtIndexPath:lastIndexPath atScrollPosition:UITableViewScrollPositionMiddle animated:NO];
        }
    }
//    else if (!pModel.more){
//        self.tableView.contentOffset = CGPointMake(0,0);
//    }

    pModel.isRecreate = NO;
    
    [super didShowModel:firstTime];
}

- (void)updateNonePicMode:(NSNotification *)notifiction {
    
    [self.tableView reloadRowsAtIndexPaths:[self.tableView indexPathsForVisibleRows] 
                     withRowAnimation:UITableViewRowAnimationNone];
    
    for (id cell in self.tableView.visibleCells) {
        if ([cell respondsToSelector:@selector(updateNonePicMode)]) {
            [cell updateNonePicMode];
        }
    }
}


#pragma mark - Public Method
-(void)reloadGroupPhotoWithType:(NSString *)aType byId:(NSString *)aId {
    [((SNPhotoModel *)self.dataSource.model) cancelAllRequest];
    SNPhotoModel *pModel = ((SNPhotoModel *)self.dataSource.model);
    pModel.targetType = aType;
    pModel.typeId = aId;
    
    [pModel load:TTURLRequestCachePolicyLocal more:NO];
    BOOL hasNoCache = pModel.allPhotos.count == 0;
    if (hasNoCache) {
        [pModel load:TTURLRequestCachePolicyNone more:NO];
    } else {
        if ([_dragDelegate shouldReload]) {
            if ([SNUtility getApplicationDelegate].isNetworkReachable) {
                self.tableView.contentOffset = CGPointMake(0,-kHeaderVisibleHeight);
                [pModel load:TTURLRequestCachePolicyNone more:NO];
            }
        }
    }
    //[self.tableView scrollToTop:YES];
    //self.tableView.contentOffset = CGPointMake(0,0);
}

-(void)changeFavoriteNum:(NSString *)newsId favNum:(int)favNum {
    [[SNDBManager currentDataBase] updateFavoriteNum:[NSString stringWithFormat:@"%d", favNum] 
                                                                                   byNewsId:newsId 
                                                                                    andType:self.targetType
                                                                                  andTypeId:self.typeId];
    SNPhotoDataSource *dataSource = (SNPhotoDataSource *)self.dataSource;
    [dataSource changeFavNum:favNum byNewsId:newsId];
    
    for (id item in self.tableView.visibleCells) {
        if ([item isKindOfClass:[SNPhotoTableCell class]]) {
            SNPhotoTableCell *cell = (SNPhotoTableCell *)item;
            if ([cell.item.hotPhotoNews.newsId isEqualToString:newsId]) {
                [cell changeFavNumLabel:[NSString stringWithFormat:@"%d", favNum]];
                break;
            }
        }
    }
}

-(void)updatePhotoNewsReadStyle:(NSString *)newsId {
    SNPhotoDataSource *dataSource = (SNPhotoDataSource *)self.dataSource;
    [dataSource changePhotoNewsReadStyle:newsId];
    
    for (id item in self.tableView.visibleCells) {
        if ([item isKindOfClass:[SNPhotoTableCell class]]) {
            SNPhotoTableCell *cell = (SNPhotoTableCell *)item;
            if ([cell.item.hotPhotoNews.newsId isEqualToString:newsId]) {
                [cell setReadStyleByMemory];
                break;
            }
        }
    }
}

-(void)cacheCellIndexPath:(UITableViewCell *)aCell {
    self.lastIndexPath = [self.tableView indexPathForCell:aCell];
}

#pragma mark- private methods

-(void)addModalCoverLayer {
    self.coverLayerView = [[UIView alloc] init];
    coverLayerView.userInteractionEnabled = YES;
    coverLayerView.exclusiveTouch = YES;
    coverLayerView.frame = CGRectMake(0, 64, 320, TTApplicationFrame().size.height);
    coverLayerView.alpha = 0.8;
    coverLayerView.hidden=YES;
    [self.flipboardNavigationController.view.window addSubview:coverLayerView];
//    UITapGestureRecognizer *tapGesturer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapGestureHandler:)];
//    [coverLayerView addGestureRecognizer:tapGesturer];
    
    NSString *cTheme = [[SNThemeManager sharedThemeManager] currentTheme];
    if ([cTheme isEqualToString:kThemeNight]) {
        coverLayerView.backgroundColor = [UIColor colorWithWhite:0.5 alpha:0.3];
    } else {
        coverLayerView.backgroundColor = [UIColor colorWithWhite:1 alpha:0.8];
    }
}

- (void)foldTagsView {
    if (isMoveUp) {
//        [self performSelector:@selector(showOrHideTagView)];
    }
}

#pragma mark - View lifecycle
- (void)loadView {
    [super loadView];
    
//    [SNNotificationManager addObserver:self selector:@selector(closePhotoAD) name:kClosePhotoADNotify object:nil];
    
	self.tableView.bounces = YES;
	//self.tableView.scrollsToTop = YES;
    if (!_isShowTag) {
        isCreated = YES;
        
        //推送来时，如果当前是tag view则先合起tag view；
        //[SNNotificationManager addObserver:self selector:@selector(foldTagsView) name:kNotifyDidHandled object:nil];
        //[SNNotificationManager addObserver:self selector:@selector(foldTagsView) name:kWeatherWillOpenNotify object:nil];
        //[self createTagView];
        //[self createChannelView];
        //[self addModalCoverLayer];
    }
    if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"7.0"))
    {
        UIView *bottomView  = [[UIView alloc] initWithFrame:CGRectMake(0.f, 0.f, kAppScreenWidth, kToolbarViewHeight + 20)];
        bottomView.backgroundColor = [UIColor clearColor];
        _tableView.tableFooterView = bottomView;
    }
}

-(void)viewDidLoad {
    [super viewDidLoad];
    
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    CGRect applicationFrame = [[UIScreen mainScreen] applicationFrame];
    //self.view.frame = CGRectMake(0, 0, applicationFrame.size.width, applicationFrame.size.height);
    
    if (!_isShowTag) {
        int tableViewChange = [[[UIDevice currentDevice] systemVersion] floatValue] < 7.0 ? 0:(-kHeaderTotalHeight+30);
        int tableViewHeight = [[[UIDevice currentDevice] systemVersion] floatValue] < 7.0 ? (2*kHeaderTotalHeight +30) : 0;
        self.tableView.frame = CGRectMake(0, tableViewChange, applicationFrame.size.width, applicationFrame.size.height - tableViewHeight);
        self.tableView.scrollIndicatorInsets = UIEdgeInsetsMake(6,0,0,0);
    } else {
        int tableViewChange = [[[UIDevice currentDevice] systemVersion] floatValue] < 7.0 ? kHeaderHeightWithoutBottom:0;
        int tableViewHeight = [[[UIDevice currentDevice] systemVersion] floatValue] < 7.0 ? (kHeaderTotalHeight+30) : 0;
        self.tableView.frame = CGRectMake(0, tableViewChange, applicationFrame.size.width, applicationFrame.size.height - kHeaderHeight +kHeaderTotalHeight - tableViewHeight);
        self.tableView.scrollIndicatorInsets = UIEdgeInsetsMake(7,0,0,0);
        [self addHeaderView];
        [self addToolbar];
        [self.headerView setSections:[NSArray arrayWithObject:self.titleString]];
    }
    
    [self customTheme];
}

-(void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [((SNPhotoModel *)self.dataSource.model) cancelAllRequest];
    [[TTURLCache sharedCache] removeAll:NO];
    isViewAppeared = NO;
}

- (void)viewWillAppear:(BOOL)animated 
{
    if (isViewReleased) {
        //isViewReleased = NO;
        [self reCreateModel];
    } else {
        [super viewWillAppear:animated];
    }
    isViewAppeared = YES;
    
    if (_isShowTag) {
        CGRect applicationFrame = [[UIScreen mainScreen] applicationFrame];
        int tableViewChange = [[[UIDevice currentDevice] systemVersion] floatValue] < 7.0 ? kHeaderHeightWithoutBottom:0;
        int tableViewHeight = [[[UIDevice currentDevice] systemVersion] floatValue] < 7.0 ? (kHeaderTotalHeight+30) : 0;
        self.tableView.frame = CGRectMake(0, tableViewChange, applicationFrame.size.width, applicationFrame.size.height - kHeaderHeight +kHeaderTotalHeight -tableViewHeight);
    }
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    //里层组图table不提示”看图会消耗较大的流量“
//    if (!_isShowTag) {
//        [SNUtility showNoWifiTipForPhotosWithKey:@"photoNoWifiInfo"];
//    }
}

- (void)createChannelView {
    CGRect applicationFrame = [[UIScreen mainScreen] applicationFrame];
    self.tableView.frame = CGRectMake(0, 0, applicationFrame.size.width, applicationFrame.size.height - TTToolbarHeight() - (44 - 8));
//    tabBar = [[SNCategoryScrollTabBar alloc] initWithCategoryId:self.typeId andDelegate:self];
//    self.tabBar.layer.shadowOffset = CGSizeMake(0, -1.3);
//    self.tabBar.layer.shadowOpacity = 0;//不能一直带着阴影，会导致下拉动画卡
//    self.tabBar.layer.shadowColor = [UIColor colorWithWhite:0.7 alpha:1].CGColor;
//    self.tabBar.layer.shadowRadius = 1.3;
    
    if (isViewReleased) {
        tabBar.isReleased = YES;
    }
    [self.view addSubview:tabBar];
}

#pragma mark -
#pragma mark Tab select 
- (void)tabBar:(SNChannelScrollTabBar *)tabBar tabSelected:(NSInteger)selectedIndex {
    if (selectedIndex < 0 || selectedIndex > [[[(SNPhotosChannelDataSource *)self.tabBar.dataSource model] subedCategories] count]) {
        return;
    }
    //_selectedIndex = selectedIndex;
    CategoryItem *category = [[[(SNPhotosChannelDataSource *)self.tabBar.dataSource model] subedCategories] objectAtIndex:selectedIndex];
    if (category) {
        [self selectedCategoryByChannelBar:category];
    }
}

-(void)selectedCategoryByChannelBar:(CategoryItem *)aCategory {
    if (aCategory) {
        //if ([self.targetType isEqualToString:kGroupPhotoCategory]
        //    && ![self.typeId isEqualToString:aCategory.categoryID]) {
        if (needScrollToTop) {
            [self.tableView scrollToTop:NO];
            needScrollToTop = NO;
        }
            self.typeId = aCategory.categoryID;
            [self reloadGroupPhotoWithType:self.targetType byId:self.typeId];
        //}
    }
}

#pragma mark -

- (void)didReceiveMemoryWarning {
    [[TTURLCache sharedCache] removeAll:NO];
    [super didReceiveMemoryWarning];
}

-(void)updateTheme/*:(NSNotification*)notification*/ {
    [self customTheme];
    
    if (!_isShowTag) {
        [_tagBtn setTitleColor:[UIColor colorFromString:[[SNThemeManager sharedThemeManager] currentThemeValueForKey:kGroupPhotoTitleColor]] forState:UIControlStateNormal];

        [_tagBtn setImage:[UIImage imageNamed:@"arrow_icon.png"] forState:UIControlStateNormal];
        [_tagBtn setImage:[UIImage imageNamed:@"arrow_icon_hl.png"] forState:UIControlStateHighlighted];
    }
}

-(void)customTheme {
    [self customerTableBg];
//    if (!_isShowTag) {
//        [self customTitleView];
//    }
}

-(void)dealloc {
    [SNNotificationManager removeObserver:self];
    
     //(titleString);
     //(_dragDelegate);
     //(targetType);
     //(typeId);
     //(coverLayerView);
     //(currentMinTimeline);
     //(currentOffSet);
    //self.tabBar.delegate = nil;
     //(tabBar);
    
    if (_tagItem) {
         //(_tagItem);
    }
    
     //(lastIndexPath);
}

- (void)onBack:(id)sender {
    [self.flipboardNavigationController popViewControllerAnimated:YES];
}
@end
