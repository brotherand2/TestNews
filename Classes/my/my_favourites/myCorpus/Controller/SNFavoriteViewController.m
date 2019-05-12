//
//  SNFavoriteViewController.m
//  sohunews
//
//  Created by 李腾 on 2016/11/4.
//  Copyright © 2016年 Sohu.com. All rights reserved.
//

#import "SNFavoriteViewController.h"
#import "SNFavoriteDataSource.h"
#import "SNPopOverMenu.h"
#import "SNFavoriteCollectionViewCell.h"
#import "SNUserManager.h"
#import "SNNewsReport.h"
#import "NSString+Utilities.h"
#import "SNAutoPlayVideoContentView.h"
#import "SNCorpusList.h"
#import "SNCorpusChannelTopBar.h"
#import "SNCloudSaveService.h"

#define kCorpusNameArray @"kCorpusNameArray"
#define kCorpusIDArray   @"kCorpusIDArray"

@interface SNFavoriteViewController () <SNCorpusChannelTopBarDelegate, UICollectionViewDelegate, UICollectionViewDataSource>

@property (nonatomic, strong) SNFavoriteDataSource *favoriteDataSource;
@property (nonatomic, weak  ) UICollectionView *collectionView;
@property (nonatomic, weak  ) SNCorpusChannelTopBar *channelTabBar;
@property (nonatomic, assign) BOOL loginState;
@property (nonatomic, assign) NSInteger currentCorpusCount;
@property (nonatomic, copy  ) NSString *corpusName;
@property (nonatomic, strong) NSMutableArray *channelsArray;
@property (nonatomic, strong) NSMutableArray *corpusIDArray;
@property (nonatomic, copy  ) NSString *currentSelectTitle;
@property (nonatomic, copy  ) NSString *currentSelectID;
@property (nonatomic, strong) NSMutableArray *scrollViewList;
@property (nonatomic, assign) BOOL notAutoPlay;
@property (nonatomic, assign) BOOL isReachable;
@property (nonatomic, assign) BOOL isWidgetOpen;
@end

@implementation SNFavoriteViewController

- (instancetype)initWithNavigatorURL:(NSURL *)URL query:(NSDictionary *)query
{
    self = [super initWithNavigatorURL:URL query:query];
    if (self) {
        if (query.count > 0 ) {
            if ([query objectForKey:kCorpusFolderName]) {
                _corpusName = [query objectForKey:kCorpusFolderName];
            }
            if ([query objectForKey:kIsWidgetOpen]) {
                _isWidgetOpen = [query objectForKey:kIsWidgetOpen];
            }
        }
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.isReachable = [Reachability reachabilityForInternetConnection].currentReachabilityStatus;
    self.view.backgroundColor = SNUICOLOR(kBackgroundColor);
    [self initTopTabBar];
    [self createCollectionView];
    [self addToolbar];
    self.loginState = [SNUserManager isLogin];
    [SNNotificationManager addObserver:self
                              selector:@selector(reloadCorpusList:)
                                  name:kReloadCorpus object:nil];
    [SNNotificationManager addObserver:self
                              selector:@selector(reachabilityChanged:)
                                  name:kReachabilityChangedNotification object:nil];
    [SNNotificationManager addObserver:self
                              selector:@selector(corpusVideoPlay)
                                  name:kCorpusVideoPlay object:nil];
     [SNNotificationManager addObserver:self
                               selector:@selector(resetToolBarOrigin)
                                   name:UIApplicationWillChangeStatusBarFrameNotification
                                 object:nil];
    [SNNotificationManager addObserver:self selector:@selector(updateFontTheme) name:kFontModeChangeNotification object:nil];

    __weak typeof(self)weakself = self;
    [self getCorpusChannelsListWithCallBack:^{
        [weakself.channelTabBar reloadChannels:self.isWidgetOpen ? 2 : 0];
    }];

}

- (void)updateTheme:(NSNotification *)notifiction {
    [super updateTheme:notifiction];
    self.view.backgroundColor = SNUICOLOR(kBackgroundColor);
    self.collectionView.backgroundColor = SNUICOLOR(kBackgroundColor);
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    if (self.collectionView && self.channelsArray.count > 0) {
        [SNNotificationManager postNotificationName:kVideoAutoPlay object:self.currentSelectTitle];
    }
    self.editEnabled = YES;
    BOOL cancelCorpus = [[[NSUserDefaults standardUserDefaults] objectForKey:kIsCancelCollectTag] boolValue];
    if ([self.currentSelectTitle isEqualToString:kCorpusMyShare]) {
        [SNCorpusNewsViewController clearData];
        if (self.corpusIDArray.count > 2) {
            NSString *corpusID = self.corpusIDArray[2];
            __weak typeof(self)weakself = self;
            [self loadCorpusListFromServiceSuccess:^(NSArray *corpusArray) {
                if (corpusArray.count > 0) {
                    NSString *newCorpusID = [corpusArray[0] stringValueForKey:kCorpusID defaultValue:nil];
                    if (![newCorpusID isEqualToString:corpusID]) {
                        [weakself reloadCorpusList:nil];
                    }
                }
            }];
        }
    } else if (self.loginState != [SNUserManager isLogin] || cancelCorpus) {
        [self reloadCorpusList:nil];
        self.loginState = [SNUserManager isLogin];
    }
    
    [self setAllScrollViewDisableScrollToTop];
    SNFavoriteCollectionViewCell *cell = (SNFavoriteCollectionViewCell *)[self.collectionView cellForItemAtIndexPath:[NSIndexPath indexPathForItem:self.channelTabBar.selectedTabIndex inSection:0]];
    if (cell) {
        cell.corpusVC.corpusNewsTableView.scrollsToTop = YES;
    }
}

- (void)setAllScrollViewDisableScrollToTop {
    [_scrollViewList removeAllObjects];
    [self wayToFindScrollViewIn:[UIApplication sharedApplication].keyWindow];
    for (UIScrollView *scrollView in _scrollViewList) {
        scrollView.scrollsToTop = NO;
    }
}

/**find all scrollView*/
- (void)wayToFindScrollViewIn:(UIView *)baseView {
    for (UIView *view in baseView.subviews) {
        if ([view isKindOfClass:[UIScrollView class]]) {
            [_scrollViewList addObject:view];
        }
        if (view.subviews.count > 0) {
            [self wayToFindScrollViewIn:view];
        }
    }
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    if (![[SNUtility getApplicationDelegate] isNetworkReachable]) {
        [[SNCenterToast shareInstance] showCenterToastWithTitle:NSLocalizedString(@"network error", @"") toUrl:nil mode:SNCenterToastModeError];
    }
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [SNPopOverMenu dismiss];
    [SNAutoPlaySharedVideoPlayer forceStopVideo];
}

#pragma mark - Create Subviews

- (void)initTopTabBar {
    __weak typeof(self)weakself = self;
    SNCorpusChannelTopBar *tabBar = [[SNCorpusChannelTopBar alloc] initWithEditHandle:^(UIButton *editBtn) {
        [weakself editBtnClick:editBtn];
    }];

    tabBar.delegate = self;
    self.channelTabBar = tabBar;
    [self.view addSubview:tabBar];
    
    self.favoriteDataSource = [[SNFavoriteDataSource alloc] init];
    self.favoriteDataSource.tabBar = tabBar;
    self.favoriteDataSource.channelsArrayM = self.channelsArray;

    [self.channelTabBar reloadChannels:self.isWidgetOpen?2:0];
}


- (void)createCollectionView {
    CGFloat collectionY = CGRectGetMaxY(self.channelTabBar.frame)+1;
    CGRect frame = CGRectMake(0, collectionY, kAppScreenWidth, [UIScreen mainScreen].bounds.size.height - collectionY - [SNToolbar toolbarHeight]);
    
    UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc] init];
    flowLayout.itemSize = frame.size;
    flowLayout.minimumLineSpacing = 0;
    flowLayout.minimumInteritemSpacing = 0;
    flowLayout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    UICollectionView *collectionView = [[UICollectionView alloc] initWithFrame:frame collectionViewLayout:flowLayout];
    collectionView.backgroundColor = SNUICOLOR(kBackgroundColor);
    collectionView.showsVerticalScrollIndicator = NO;
    collectionView.showsHorizontalScrollIndicator = NO;
    collectionView.bounces = NO;
    collectionView.delegate = self;
    collectionView.dataSource = self;
    collectionView.pagingEnabled = YES;
    collectionView.scrollsToTop = NO;
    [collectionView registerClass:[SNFavoriteCollectionViewCell class] forCellWithReuseIdentifier:NSStringFromClass([SNFavoriteCollectionViewCell class])];
    self.collectionView = collectionView;
    [self.view addSubview:collectionView];
    
}

- (void)reachabilityChanged:(NSNotification *)noti {
    Reachability *conn = [Reachability reachabilityForInternetConnection];
    if ([conn currentReachabilityStatus] != NotReachable && !self.isReachable) {
        self.isReachable = YES;
        __weak typeof(self)weakself = self;
        [self getCorpusChannelsListWithCallBack:^{
            for (NSInteger i = 0; i < weakself.corpusIDArray.count; i++) {
                if ([weakself.currentSelectID isEqualToString:weakself.corpusIDArray[i]]) {
                    [weakself.channelTabBar reloadChannels:i];
                    break;
                }
            }
        }];
    }
}

#pragma mark - Get Corpus List
- (void)getCorpusChannelsListWithCallBack:(void(^)())callBack  {
    [SNCloudSaveService corpusDataCloudSync:^{
        __weak typeof(self)weakself = self;
        [self loadCorpusListFromServiceSuccess:^(NSArray *corpusArray) {
            [weakself.channelsArray removeAllObjects];
            [weakself.corpusIDArray removeAllObjects];
            weakself.channelsArray = [NSMutableArray arrayWithObjects:kCorpusMyFavourite, kCorpusMyShare, nil];
            weakself.corpusIDArray = [NSMutableArray arrayWithObjects:@"0", @"0", nil];
            if ([self newsGrabAuthority]) {
                [weakself.channelsArray addObject:kCorpusMyInclude];
                [weakself.corpusIDArray addObject:@"0"];
            }
            [SNCorpusList saveCorpusListWithCorpusListArray:corpusArray];
            NSDictionary *dictCorpus = nil;
            NSString *corpusID = nil;
            if (corpusArray.count > 0) {
                for (int i = 0; i < [corpusArray count]; i++) {
                    dictCorpus = [corpusArray objectAtIndex:i];
                    NSString *corpusName = [dictCorpus objectForKey:kCorpusFolderName];
                    [weakself.channelsArray addObject:corpusName];
                    
                    corpusID = [dictCorpus stringValueForKey:kCorpusID defaultValue:nil];
                    [weakself.corpusIDArray addObject:corpusID];

                }
            }
            _currentCorpusCount = _channelsArray.count;
            [weakself.collectionView reloadData];
            weakself.favoriteDataSource.channelsArrayM = self.channelsArray;
            if (callBack) callBack();
        }];
    }];
}

- (void)loadCorpusListFromServiceSuccess:(void(^)(NSArray *corpusList))success {
    
    [SNCorpusList loadCorpusListFromServerWithSuccessHandler:^(NSArray *corpusList) {
        if (success) {
            success(corpusList);
        }
    } failure:^{
        [self.channelTabBar reloadChannels:0];
    }];

}

- (void)reloadCorpusList:(NSNotification *)noti {
    [SNCorpusNewsViewController clearData];
    NSDictionary *userInfo = noti.userInfo;
    if ([[userInfo objectForKey:kNotAutoPlay] boolValue]) {
        self.notAutoPlay = YES;
    }
    NSString *corpusID = userInfo?[userInfo objectForKey:kCorpusID]:self.currentSelectID;
    if ([corpusID isEqualToString:@"0"]) {
        NSInteger index = 0;
        if (![userInfo objectForKey:kCorpusFolderName]) {
            index = [self.currentSelectTitle isEqualToString:kCorpusMyFavourite]?0:1;
        }
        __weak typeof(self)weakself = self;
        [self getCorpusChannelsListWithCallBack:^{
            [weakself.channelTabBar reloadChannels:index];
        }];
    } else {
        __weak typeof(self)weakself = self;
        [self getCorpusChannelsListWithCallBack:^{
            for (NSInteger i = 0; i < self.corpusIDArray.count; i++) {
                if ([corpusID isEqualToString:self.corpusIDArray[i]]) {
                    [weakself.channelTabBar reloadChannels:i];
                }
            }
        }];
    }
    
}


- (void)editBtnClick:(UIButton *)sender {
    
    SNFavoriteCollectionViewCell *cell = [self.collectionView.visibleCells objectAtIndexWithRangeCheck:0];
    BOOL haveUnabled = NO;
    if (cell.corpusVC.emptyView != nil || cell.corpusVC.loadingView.hidden == NO || !self.editEnabled) {
        haveUnabled = YES;
    }
    __weak typeof(self)weakself = self;
    [SNPopOverMenu showForSender:sender
                     haveUnabled:haveUnabled
                    unabledIndex:haveUnabled?2:0
                     senderFrame:sender.frame
                        withMenu:@[@"新建收藏夹", @"收藏夹管理", @"编辑当前内容"]
                  imageNameArray:@[@"icocollection_new folder_v5.png", @"icocollection_favorites_v5.png", haveUnabled?@"icocollection_compilepress_v5.png":@"icocollection_compile_v5.png"]
                       doneBlock:^(NSInteger selectedIndex) {
        switch (selectedIndex) {
            case 0:
            {
                [SNNewsReport reportADotGif:@"act=cc&fun=50&page=3&topage="];
                NSDictionary *dict = [NSDictionary dictionaryWithObject:[NSNumber numberWithBool:YES] forKey:kIsFromCorpusListCreat];
                TTURLAction *_urlAction = [[[TTURLAction actionWithURLPath:@"tt://creatCorpus"] applyAnimated:YES] applyQuery:dict];
                [[TTNavigator navigator] openURLAction:_urlAction];
            }
                break;
            case 1:
            {
                [SNNewsReport reportADotGif:@"act=cc&fun=50&page=4&topage="];
                TTURLAction *action = [[TTURLAction actionWithURLPath:@"tt://myCorpus" ] applyAnimated:YES];
                [[TTNavigator navigator] openURLAction:action];
            }
                break;
            case 2:
            {
                [SNNewsReport reportADotGif:@"act=cc&fun=50&page=5&topage="];
                NSMutableDictionary *dict = [NSMutableDictionary dictionary];
                [dict setObject:[NSNumber numberWithBool:YES] forKey:kEditeFavorite];
                [dict setObject:weakself.channelsArray[weakself.channelTabBar.selectedTabIndex] forKey:kCorpusFolderName];
                [dict setObject:weakself.corpusIDArray[weakself.channelTabBar.selectedTabIndex] forKey:kCorpusID];
                TTURLAction *_urlAction = [[[TTURLAction actionWithURLPath:@"tt://corpusList"] applyAnimated:YES] applyQuery:dict];
                [[TTNavigator navigator] openURLAction:_urlAction];
            }
                break;
                
            default:
                break;
        }
    } dismissBlock:nil];
}

#pragma mark - UICollectionViewDataSource

- (NSInteger)collectionView:(UICollectionView *)collectionView
     numberOfItemsInSection:(NSInteger)section
{
    return self.channelsArray.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView
                  cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    SNFavoriteCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:NSStringFromClass([SNFavoriteCollectionViewCell class]) forIndexPath:indexPath];
    if ([UIDevice currentDevice].systemVersion.floatValue < 8.0) {
        
        [cell setFavoriteWithCorpusName:self.channelsArray[indexPath.item] andCorpusId:self.corpusIDArray[indexPath.item]];
    }
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView willDisplayCell:(SNFavoriteCollectionViewCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath {
    [cell setFavoriteWithCorpusName:self.channelsArray[indexPath.item] andCorpusId:self.corpusIDArray[indexPath.item]];
}

- (BOOL)collectionView:(UICollectionView *)collectionView shouldHighlightItemAtIndexPath:(NSIndexPath *)indexPath {
    return NO;
}

#pragma mark - UIScrollViewDelegate

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    NSInteger index = scrollView.contentOffset.x / scrollView.width;
    [self.channelTabBar reloadChannels:index];
}


#pragma mark - SNCorpusChannelTopBarDelegate

- (void)tabBar:(SNCorpusChannelTopBar*)tabBar tabSelected:(NSInteger)selectedIndex {
    self.currentSelectTitle = tabBar.selectedCorpusTabItem.title;
    self.currentSelectID = self.corpusIDArray[selectedIndex];
    [self.collectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForItem:selectedIndex inSection:0] atScrollPosition:UICollectionViewScrollPositionLeft animated:NO];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.35 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        
        SNFavoriteCollectionViewCell *cell = (SNFavoriteCollectionViewCell *)[self.collectionView cellForItemAtIndexPath:[NSIndexPath indexPathForItem:selectedIndex inSection:0]];
        cell.corpusVC.notAutoPlay = self.notAutoPlay;
        [cell.corpusVC getCorpusNewsList];
    });
    if ([self.currentSelectTitle isEqualToString:kCorpusMyInclude]) {
        [self.channelTabBar editButtonEnabled:NO];
    } else {
        [self.channelTabBar editButtonEnabled:YES];
    }
}

- (void)corpusVideoPlay {
    self.toolbarView.userInteractionEnabled = NO;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.8 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        self.toolbarView.userInteractionEnabled = YES;
    });
}

- (NSMutableArray *)channelsArray {
    if (!_channelsArray) {
        _channelsArray = [NSMutableArray arrayWithObjects:kCorpusMyFavourite, kCorpusMyShare, nil];
        if ([self newsGrabAuthority]) [_channelsArray addObject:kCorpusMyInclude];
        NSMutableArray *corpusNameArray = [NSKeyedUnarchiver unarchiveObjectWithFile:[NSString writeToFileWithName:kCorpusNameArray]];
        if (corpusNameArray) {
            _channelsArray = corpusNameArray;
        }
        _currentCorpusCount = _channelsArray.count;
    }
    return _channelsArray;
}

- (NSMutableArray *)corpusIDArray {
    if (!_corpusIDArray) {
        _corpusIDArray = [NSMutableArray arrayWithObjects:@"0", @"0", nil];
        if ([self newsGrabAuthority]) [_corpusIDArray addObject:@"0"];
        NSMutableArray *corpusIDArray = [NSKeyedUnarchiver unarchiveObjectWithFile:[NSString writeToFileWithName:kCorpusIDArray]];
        if (corpusIDArray) {
            _corpusIDArray = corpusIDArray;
        }
    }
    return _corpusIDArray;
}


- (void)onBack:(id)sender {
    [SNCorpusNewsViewController clearData];
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        [NSKeyedArchiver archiveRootObject:self.channelsArray toFile:[NSString writeToFileWithName:kCorpusNameArray]];
        [NSKeyedArchiver archiveRootObject:self.corpusIDArray toFile:[NSString writeToFileWithName:kCorpusIDArray]];
    });
    [super onBack:sender];
}

- (BOOL)recognizeSimultaneouslyWithGestureRecognizer
{
    
    if (self.collectionView.contentOffset.x <= 0 && self.collectionView.isTracking) {
        return YES;
    }
    return NO;
}

- (void)updateFontTheme {
    SNFavoriteCollectionViewCell *cell = (SNFavoriteCollectionViewCell *)[self.collectionView cellForItemAtIndexPath:[NSIndexPath indexPathForItem:self.channelTabBar.selectedTabIndex inSection:0]];
    if (cell) {
        [cell.corpusVC.corpusNewsTableView reloadData];
    }
}

- (void)dealloc {
    [SNNotificationManager removeObserver:self];
}

- (BOOL)newsGrabAuthority {
    if (SYSTEM_VERSION_LESS_THAN(@"10.0")) {
        return NO;
    }
    if ([SNUserManager isLogin] && [[[NSUserDefaults alloc] initWithSuiteName:kTodaynewswidgetGroup] boolForKey:kNewsGrabAuthority]) {
        return YES;
    }
    return NO;
}

@end
