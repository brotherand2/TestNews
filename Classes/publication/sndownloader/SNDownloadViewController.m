//
//  FKDownloadViewController.m
//  FK
//
//  Created by handy wang on 6/8/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "SNDownloadViewController.h"
#import "SNDownloadManager.h"
#import "CacheObjects.h"
#import "SNDownloadingTableViewCell.h"
#import "SNDBManager.h"
#import "SNAlert.h"
#import "UIColor+ColorUtils.h"
#import "SNDownloadedViewController.h"

#if kNeedDownloadRollingNews
#import "SNDownloadScheduler.h"
#import "SNDownloadUtility.h"
#endif

#define SELF_MENU_HEIGHT                                                                    (98/2.0f)

#define SELF_BAR_BUTTON_ITEM_HEIGHT                                                         (52/2.0f)
#define SELF_BAR_BUTTON_ITEM_WIDTH                                                          (108/2.0f)

@interface SNDownloadViewController ()

- (void)initUI;

//- (void)setDownloadListViewMode:(FKDownloadListViewMode)downloadListViewMode;

- (void)cancelAllDownload;

- (void)renderRightEditBtnItem;

- (void)renderRightDoneBtnItem;

- (void)editAction;

- (void)doneAction;

- (void)showBottomMenu;

- (void)changeDownloadedTableViewHeight;

- (void)recoverDownloadedTableViewHeight;

- (void)hideBottomMenu;

- (void)enableOrDisableRightBtn;

@end


@implementation SNDownloadViewController

#pragma mark - Lifecycle

- (id)initWithNavigatorURL:(NSURL *)URL query:(NSDictionary *)query {
    if (self = [super initWithNavigatorURL:URL query:query]) {
        self.hidesBottomBarWhenPushed = YES;
        _referFrom = [query objectForKey:@"referFrom"];
        [SNNotificationManager addObserver:self
                                                selector:@selector(updateTheme:)
                                                    name:kThemeDidChangeNotification
                                                  object:nil];
        //NSString *_tmpRefer = [query objectForKey:kReferOfDownloader];
        //_currentViewMode = ((_tmpRefer && ![@"" isEqualToString:_tmpRefer]) ? [_tmpRefer intValue] : FKDownloadListViewDownloadedMode);
        [SNNotificationManager addObserver:self selector:@selector(showNotification) name:kNotifyExpressShow object:nil];
    }
    return self;
}

- (SNCCPVPage)currentPage {
    return more_offline;
}

- (void)loadView {
    [super loadView];
    [self initUI];
    
    //无头模式
    [self addHeaderView];
    [self addToolbar];
    
    NSString *title = NSLocalizedString(@"downloaded_items_title",@"");
    CGSize titleSize = [title sizeWithFont:[UIFont systemFontOfSize:kThemeFontSizeE]];
    [self.headerView setSections:[NSArray arrayWithObjects:title, nil]];
    self.headerView.delegate = self;
    [self.headerView setBottomLineForHeaderView:CGRectMake(7, self.headerView.height-2, titleSize.width+6, 2)];
    
    #if kNeedDownloadRollingNews
    [SNDownloadUtility updateMySubsAndChannelsFromServer];
    #endif
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [_downloadedViewController viewWillAppear:animated];
//    [_downloadingViewController viewWillAppear:animated];
    
    [self enableOrDisableRightBtn];
    
    //_currentViewMode = FKDownloadListViewDownloadedMode;
    //[self setDownloadListViewMode:_currentViewMode];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self reportPVAnalyzeWithCurrentNavigationController:self.flipboardNavigationController];
}

#if kNeedDownloadRollingNews
- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [_downloadedViewController viewWillDisappear:animated];
//    [_downloadingViewController viewWillDisappear:animated];
}
#endif

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void)dealloc {

    [SNNotificationManager removeObserver:self];
    _downloadedViewController = nil;
    
    //[self.headerView resignOffsetListener];
//     //(_scrollViewContainer);
    
     //(_rightEditBtn);
     //(_rightDoneBtn);
    // //(_rightCancelAllDownloadingBtn);
    // //(_rightDownloadSettingBtn);
     //(_bottomMenu);
     //(_referFrom);
}

-(void)viewDidLoad
{
    [super viewDidLoad];
    [self renderRightEditBtnItem];
    [self renderRightDoneBtnItem];
    [self.toolbarView setRightButton:_rightEditBtn];
}

- (void)viewDidUnload
{
    //[self.headerView resignOffsetListener];
    
    [super viewDidUnload];
    
//    [_downloadingViewController release];
//    _downloadingViewController = nil;
    
    _downloadedViewController = nil;
    
//     //(_scrollViewContainer);
    
     //(_rightEditBtn);
     //(_rightDoneBtn);
    // //(_rightCancelAllDownloadingBtn);
    // //(_rightDownloadSettingBtn);
     //(_bottomMenu);
}

#if kNeedDownloadRollingNews
- (void)onBack:(id)sender {
    [self.flipboardNavigationController popViewControllerAnimated:YES];
//    [[SNDownloadScheduler sharedInstance] removeDelegate:_downloadingViewController];
}
#endif

#pragma mark - Public methods implementation

/*
- (void)setDownloadListViewMode:(FKDownloadListViewMode)downloadListViewMode {    
//    switch (downloadListViewMode) {
//        case FKDownloadListViewDownloadingMode: {
//            [self doneAction];
//            _currentViewMode = downloadListViewMode;
//            [self.headerView setCurrentIndex:1 animated:YES];
//            [_scrollViewContainer scrollRectToVisible:CGRectMake(self.view.bounds.size.width,
//                                                                 0,
//                                                                 self.view.bounds.size.width,
//                                                                 self.view.bounds.size.height)
//                                             animated:YES];
//            [self renderDownloadingRightBtnItem];
//            break;
//        }
//        case FKDownloadListViewDownloadedMode: {
//            [self doneAction];
//            _currentViewMode = downloadListViewMode;
//            [self.headerView setCurrentIndex:0 animated:YES];
//            [_scrollViewContainer scrollRectToVisible:CGRectMake(0,
//                                                                 0,
//                                                                 self.view.bounds.size.width,
//                                                                 self.view.bounds.size.height)
//                                             animated:YES];
//            [self renderRightEditBtnItem];
//            break;
//        }
//        default:{
//            break;
//        }
//    }
    
    _currentViewMode = downloadListViewMode;
    [self.headerView setCurrentIndex:0 animated:YES];
    [self enableOrDisableRightBtn];
}*/

- (void)refreshDownloadedList {
    if (!(_downloadedViewController.isEditMode)) {
        [_downloadedViewController loadLocalDownloadedDataFromDB];
    }
}

#pragma mark - BottomMenuDelegate methods implementation

- (void)selectAll {
    [_downloadedViewController selectAll];
}

- (void)deleteSelected {
    [_downloadedViewController deleteSelected];
}

- (void)deselectAll {

    [_downloadedViewController deselectAll];

}

#pragma mark - SNDownloadedViewController

//- (void)setReferOfDownloader:(FKDownloadListViewMode)mode {
//    _currentViewMode = mode;
//}

#pragma mark - SNHeadSelectViewDelegate

- (void)headView:(SNHeadSelectView *)headView didSelectIndex:(int)index {
//
//    if (index == 0) {
//    
//        SNDebugLog(@"INFO: Selecting had downloaded tab item......");
//        
//        [self setDownloadListViewMode:FKDownloadListViewDownloadedMode];
//        
//    } else if (index == 1) {
//        
//        SNDebugLog(@"INFO: Selecting downloading tab item......");
//        
//        [self setDownloadListViewMode:FKDownloadListViewDownloadingMode];
//        
//    }

}


#pragma mark - UIScrollViewDelegate

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {// called when scroll view grinds to a halt
//    
//    CGPoint _offset = [scrollView contentOffset];
//    
//    if (_offset.x < self.view.bounds.size.width) {
//    
//        [self setDownloadListViewMode:FKDownloadListViewDownloadedMode];
//    
//    } else {
//    
//        [self setDownloadListViewMode:FKDownloadListViewDownloadingMode];
//        
//    }
//    
}

#pragma mark - Private methods implementation

- (void)initUI {
    //已下载列表
    CGRect _tableViewCGRect = CGRectMake(0, 0, kAppScreenWidth, self.view.frame.size.height);
    _downloadedViewController = [[SNDownloadedViewController alloc] initWithIDelegate:self];
    _downloadedViewController.view.frame = _tableViewCGRect;
    _downloadedViewController.referFrom = _referFrom;

    //正在下载列表
//    #if kNeedDownloadRollingNews
//    _downloadingViewController = [[SNDownloadingVController alloc] initWithIDelegate:self];
//    #else
//    _downloadingViewController = [[SNDownloadingViewController alloc] initWithIDelegate:self];
//    #endif
    
    _tableViewCGRect.origin.x = self.view.bounds.size.width;
//    _downloadingViewController.view.frame = _tableViewCGRect;
//    [[SNDownloadManager sharedInstance] setDelegate:_downloadingViewController];
    
//     //(_scrollViewContainer);
//    _scrollViewContainer = [[UIScrollView alloc] initWithFrame:self.view.bounds];
//    _scrollViewContainer.backgroundColor = [UIColor colorWithRed:248/255.0f green:248/255.0f blue:248/255.0f alpha:1];
//    _scrollViewContainer.delegate = self;
//    _scrollViewContainer.pagingEnabled = YES;
//    _scrollViewContainer.bounces = NO;
//    _scrollViewContainer.contentSize = CGSizeMake(self.view.bounds.size.width*2, self.view.bounds.size.height);
//    [_scrollViewContainer addSubview:_downloadedViewController.view];
//    [_scrollViewContainer addSubview:_downloadingViewController.view];
//    [self.view addSubview:_scrollViewContainer];
    
    [self.view addSubview:_downloadedViewController.view];
    
    //Bottom menu
    CGRect _frame = CGRectMake(0, self.view.frame.size.height, self.view.frame.size.width, SELF_MENU_HEIGHT);
    _bottomMenu = [[SNEditDownloadedBottomMenu alloc] initWithFrame:_frame andDelgate:self];
    
    _downloadedViewController.bottomMenu = _bottomMenu;
    [self.view addSubview:_bottomMenu];
    
    //适配无头模式
    CGRect screenFrame = TTApplicationFrame();
    
    #if kNeedDownloadRollingNews
    #else
    UIImage *bg = [UIImage imageNamed:@"postTab0.png"];
    _downloadingViewController.tableView.contentInset = UIEdgeInsetsMake(10, 0, 0, 0);
    _downloadingViewController.tableView.scrollIndicatorInsets = UIEdgeInsetsMake(10, 0, 0, 0);
    _downloadingViewController.tableView.frame = CGRectMake(self.view.bounds.size.width,
                                                            kHeaderTotalHeight-kHeadBottomHeight,
                                                            screenFrame.size.width,
                                                            screenFrame.size.height - kHeaderTotalHeight - bg.size.height + 15);
    #endif
    
    float top = SYSTEM_VERSION_LESS_THAN(@"7.0") ? 10.f : (kHeaderHeightWithoutBottom);
    _downloadedViewController.tableView.contentInset = UIEdgeInsetsMake(top, 0, (110.0/2), 0);
    _downloadedViewController.tableView.scrollIndicatorInsets = UIEdgeInsetsMake(top, 0, (110.0/2), 0);
    _downloadedViewController.tableView.frame = CGRectMake(0,
                                                           kHeadSelectViewBottom,
                                                           screenFrame.size.width,
                                                           kAppScreenHeight -kHeadSelectViewBottom + 8);
    if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"7.0")) {
        _downloadedViewController.tableView.contentOffset = CGPointMake(0.f, -kHeaderHeightWithoutBottom);
    }
}

#pragma mark - Private methods about downloading

//#if kNeedDownloadRollingNews
//- (void)updateRightDownloadingBtnItem {
//    if (_currentViewMode == FKDownloadListViewDownloadingMode) {
//        [self renderDownloadingRightBtnItem];
//    }
//}
//#endif

- (void)renderDownloadingRightBtnItem {
    #if kNeedDownloadRollingNews
    if ([[SNDownloadScheduler sharedInstance] isAllDownloadFinishedAndNoFail]) {
        [self renderRightDownloadSettingBtnItem];
    } else {
        [self renderRightCancelAllDownloadBtnItem];
    }
    #else
    [self renderRightCancelAllDownloadBtnItem];
    #endif
}

- (void)renderRightDownloadSettingBtnItem {
    UIButton *_downloadSettingButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, SELF_BAR_BUTTON_ITEM_WIDTH, SELF_BAR_BUTTON_ITEM_HEIGHT)];
    NSString *_setting = @"download_settingbtn_normal.png";
    NSString *_setting_hl = @"download_settingbtn_press.png";
	[_downloadSettingButton setImage:[UIImage imageNamed:_setting] forState:UIControlStateNormal];
	[_downloadSettingButton setImage:[UIImage imageNamed:_setting_hl] forState:UIControlStateHighlighted];
	[_downloadSettingButton addTarget:self action:@selector(toDownloadSetting) forControlEvents:UIControlEventTouchUpInside];
	[_downloadSettingButton setBackgroundColor:[UIColor clearColor]];
//     //(_rightDownloadSettingBtn);
//    _rightDownloadSettingBtn = [_downloadSettingButton retain];
//    [self.toolbarView setRightButton:_rightDownloadSettingBtn];
    _downloadSettingButton = nil;
}

- (void)renderRightCancelAllDownloadBtnItem {
    UIButton *_cancelAllDownloadButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, SELF_BAR_BUTTON_ITEM_WIDTH, SELF_BAR_BUTTON_ITEM_HEIGHT)];
    NSString *_cancel = @"cancel_all_download.png";
    NSString *_cancel_hl = @"cancel_all_download-press.png";
	[_cancelAllDownloadButton setImage:[UIImage imageNamed:_cancel] forState:UIControlStateNormal];
	[_cancelAllDownloadButton setImage:[UIImage imageNamed:_cancel_hl] forState:UIControlStateHighlighted];
	[_cancelAllDownloadButton addTarget:self action:@selector(cancelAllDownload) forControlEvents:UIControlEventTouchUpInside];
	[_cancelAllDownloadButton setBackgroundColor:[UIColor clearColor]];
//     //(_rightCancelAllDownloadingBtn);
//    _rightCancelAllDownloadingBtn = [_cancelAllDownloadButton retain];
//    [self.toolbarView setRightButton:_rightCancelAllDownloadingBtn];
    _cancelAllDownloadButton = nil;
}

- (void)toDownloadSetting {
    TTURLAction *_urlAction = [[TTURLAction actionWithURLPath:@"tt://downloadSettingViewController"] applyAnimated:YES];
    [[TTNavigator navigator] openURLAction:_urlAction];
}

- (void)cancelAllDownload {
    #if kNeedDownloadRollingNews
        [[SNDownloadScheduler sharedInstance] cancelAll];
    #else
        [[SNDownloadManager sharedInstance] cancelAllDownloadItems];
    #endif
}

#pragma mark - Private methods about downloaded

- (void)renderRightEditBtnItem {
    UIButton *_btn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, SELF_BAR_BUTTON_ITEM_WIDTH, SELF_BAR_BUTTON_ITEM_HEIGHT)];
    _btn.accessibilityLabel = @"编辑";
	[_btn setImage:[UIImage themeImageNamed:@"edit_downloaded_items.png"] forState:UIControlStateNormal];
	[_btn setImage:[UIImage themeImageNamed:@"edit_downloaded_items-press.png"] forState:UIControlStateHighlighted];
	[_btn addTarget:self action:@selector(editAction) forControlEvents:UIControlEventTouchUpInside];
	[_btn setBackgroundColor:[UIColor clearColor]];
     //(_rightEditBtn);
    _rightEditBtn = _btn;
    //[self.toolbarView setRightButton:_rightEditBtn];
    _btn = nil;
    
    //[self enableOrDisableRightBtn];

}

- (void)renderRightDoneBtnItem {
    UIButton *_btn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, SELF_BAR_BUTTON_ITEM_WIDTH, SELF_BAR_BUTTON_ITEM_HEIGHT)];
    NSString *_btnImgName = @"submitNomal.png";
    NSString *_btnImgNameHl = @"submitPress.png";
	[_btn setImage:[UIImage imageNamed:_btnImgName] forState:UIControlStateNormal];
	[_btn setImage:[UIImage imageNamed:_btnImgNameHl]forState:UIControlStateHighlighted];
	[_btn addTarget:self action:@selector(doneAction) forControlEvents:UIControlEventTouchUpInside];
	[_btn setBackgroundColor:[UIColor clearColor]];
     //(_rightDoneBtn);
    _rightDoneBtn = _btn;
    //[self.toolbarView setRightButton:_rightDoneBtn];
    _btn = nil;
}

- (void)editAction {
    if (_downloadedViewController.isEditMode == NO) {
        
        //change btn to done
        [self renderRightDoneBtnItem];
        
        //disable table cell select
        _downloadedViewController.isEditMode = YES;
        
        //show bottom menu
        [self showBottomMenu];
        
    }
}

- (void)doneAction {
    if (_downloadedViewController.isEditMode == YES) {
        
        //change btn to edit
        [self renderRightEditBtnItem];
        [self enableOrDisableRightBtn];
        [self.toolbarView setRightButton:_rightEditBtn];
        
        //enable table cell select
        _downloadedViewController.isEditMode = NO;
        
        //hide bottom menu
        [self recoverDownloadedTableViewHeight];
        
        //重置已下载列表数据全为未选中状态
        [_bottomMenu deselectAll];

        //refresh已下载列表
        [self refreshDownloadedList];
    }
}

- (void)showBottomMenu {
    
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:0.2];
    [UIView setAnimationDelegate:self];
    [UIView setAnimationDidStopSelector:@selector(dismissToolbarView)];
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    [UIView commitAnimations];

}

- (void)dismissToolbarView {
    
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:0.2];
    [UIView setAnimationDelegate:self];
    [UIView setAnimationDidStopSelector:@selector(didShowBottomMenu)];
    
    CGRect _toolbarViewFrame = self.toolbarView.frame;
    _toolbarViewFrame.origin.y = self.view.frame.size.height;
    self.toolbarView.frame = _toolbarViewFrame;
    
    [UIView commitAnimations];
    
}

- (void)didShowBottomMenu {
    
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:0.2];
    [UIView setAnimationDelegate:self];
    [UIView setAnimationDidStopSelector:@selector(changeDownloadedTableViewHeight)];
    
    CGRect _bottomMenuFrame = _bottomMenu.frame;
    _bottomMenuFrame.origin.y = self.view.frame.size.height-SELF_MENU_HEIGHT;
    _bottomMenu.frame = _bottomMenuFrame;
    
    [UIView commitAnimations];

}

- (void)changeDownloadedTableViewHeight {
//    CGRect _tmpFrame = _downloadedViewController.view.frame;
//    _tmpFrame.size.height -= SELF_MENU_HEIGHT;
//    _downloadedViewController.view.frame = _tmpFrame;
}


- (void)recoverDownloadedTableViewHeight {
    
//    CGRect _tmpFrame = _downloadedViewController.view.frame;
//    _tmpFrame.size.height += SELF_MENU_HEIGHT;
//    _downloadedViewController.view.frame = _tmpFrame;
    
    [self hideBottomMenu];

}

- (void)hideBottomMenu {
    
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:0.2];
    [UIView setAnimationDelegate:self];
    [UIView setAnimationDidStopSelector:@selector(showToolbarView)];
    
    CGRect _bottomMenuFrame = _bottomMenu.frame;
    _bottomMenuFrame.origin.y = self.view.frame.size.height;
    _bottomMenu.frame = _bottomMenuFrame;
    
    [UIView commitAnimations];
    
}

- (void)showToolbarView {
    
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:0.2];
    
    CGRect _toolbarViewFrame = self.toolbarView.frame;
    _toolbarViewFrame.origin.y = self.view.frame.size.height-_toolbarViewFrame.size.height;
    self.toolbarView.frame = _toolbarViewFrame;
    
    [UIView commitAnimations];
    
}

- (void)enableOrDisableRightBtn {
    [_downloadedViewController enableOrDisableRightBtn];
//    switch (_currentViewMode) {
//        case FKDownloadListViewDownloadedMode: {
//            [_downloadedViewController enableOrDisableRightBtn];
//            break;
//        }
//        case FKDownloadListViewDownloadingMode: {
//            [_downloadingViewController enableOrDisableRightBtn];
//            break;
//        }
//    }
}

- (void)enableRightBtn {
    
    _rightEditBtn.enabled = YES;
//    switch (_currentViewMode) {
//        case FKDownloadListViewDownloadedMode: {
//            _rightEditBtn.enabled = YES;
//            break;
//        }
//        case FKDownloadListViewDownloadingMode: {
//            _rightCancelAllDownloadingBtn.enabled = YES;
//            break;
//        }
//    }
}

- (void)disableRightBtn {
    _rightEditBtn.enabled = NO;
//    switch (_currentViewMode) {
//        case FKDownloadListViewDownloadedMode: {
//            _rightEditBtn.enabled = NO;
//            break;
//        }
//        case FKDownloadListViewDownloadingMode: {
//            _rightCancelAllDownloadingBtn.enabled = NO;
//            break;
//        }
//    }
}

-(void)updateTheme:(NSNotification*)notification
{
    [super updateTheme:notification];
    [_bottomMenu updateTheme];
    [self renderRightDoneBtnItem];
    [self renderRightEditBtnItem];
    [self.toolbarView setRightButton:_rightEditBtn];
}

- (void)showNotification {
    [self doneAction];
}

@end
