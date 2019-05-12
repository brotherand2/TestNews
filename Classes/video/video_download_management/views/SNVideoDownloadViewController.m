//
//  SNVideoDownloadViewController.m
//  sohunews
//
//  Created by handy wang on 8/27/13.
//  Copyright (c) 2013 Sohu.com. All rights reserved.
//

#import "SNVideoDownloadViewController.h"
#import "SNVideoDownloadingViewController.h"
#import "SNVideoDownloadedViewController.h"
#import "SNVideoDownloadManager.h"
#import "SNDBManager.h"
#import "SNFileSystemSizeBar.h"
#import "SNUserConsts.h"

#define kEditBtnWidth                       (108.0f/2.0f)
#define kEditBtnHeight                      (52.0f/2.0f)

@interface SNVideoDownloadViewController ()
@property (nonatomic, assign)NSInteger                          selectedHeaderIndex;
@property (nonatomic, strong)UIButton                           *editBtn;
@property (nonatomic, strong)UIScrollView                       *scrollView;
@property (nonatomic, strong)SNVideoDownloadingViewController   *downloadingViewController;
@property (nonatomic, strong)SNVideoDownloadedViewController    *downloadedViewController;
@property (nonatomic, assign)BOOL                               isEditMode;

@property (nonatomic, strong)SNFileSystemSizeBar                *fileSystemSizeBar;

@property (nonatomic, assign)SNVideoDownloadViewMode            setToViewMode;
@end

@implementation SNVideoDownloadViewController

- (id)initWithNavigatorURL:(NSURL *)URL query:(NSDictionary *)query {
    if (self = [super initWithNavigatorURL:URL query:query]) {
        self.setToViewMode = [[query objectForKey:kSNVideoDownloadViewMode defalutObj:@(SNVideoDownloadViewMode_DownloadedView)] intValue];
    }
    return self;
}

#pragma mark - Lifecycle
- (void)viewDidLoad {
    [super viewDidLoad];
    self.isEditMode = NO;

    [self addToolbar];
    [self createEditBtn];
    
    [self createChildrenViewControllers];
   
    [self addHeaderView];
    [self.headerView setSections:[NSArray arrayWithObjects:
                                  NSLocalizedString(@"downloaded_videos_title", nil),
                                  NSLocalizedString(@"downloading_videos_title", nil), nil]
     ];
    self.headerView.delegate = self;
    [self.headerView registerOffsetListener:self.scrollView];
    CGSize titleSize = [NSLocalizedString(@"downloaded_videos_title", nil) sizeWithFont:[UIFont systemFontOfSize:kThemeFontSizeE]];
    [self.headerView setBottomLineForHeaderView:CGRectMake(7, self.headerView.height-2, titleSize.width+6, 2)];

    [self addFileSystemSizeBar];
    
    [self.view bringSubviewToFront:self.toolbarView];
    
    [self addNotificationHandlers];
    
    [self handleRefreshFileSystemSizeBarNotification:nil];
    
    [self setViewMode:self.setToViewMode animated:NO];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self updateThemeIfChanged];
}

- (void)updateTheme:(NSNotification *)notifiction {
    [super updateTheme:notifiction];
    
    [self.downloadedViewController updateTheme];
    [self.downloadingViewController updateTheme];
    
    [_editBtn setImage:[UIImage imageNamed:@"edit_downloaded_items.png"] forState:UIControlStateNormal];
    [_editBtn setImage:[UIImage imageNamed:@"edit_downloaded_items-press.png"] forState:UIControlStateHighlighted];
}

- (void)dealloc {
    [self removeNotificationHandlers];
//    [self recycleContent];
    [self.headerView resignOffsetListener];
}

#pragma mark - Public
- (void)setViewMode:(SNVideoDownloadViewMode)mode animated:(BOOL)animated {
    SNVideoDownloadViewMode currentMode = [self currentViewMode];
    if (currentMode != mode) {
        if (mode == SNVideoDownloadViewMode_DownloadedView) {
            [self.scrollView setContentOffset:CGPointMake(self.scrollView.width * 0, self.scrollView.contentOffset.y) animated:animated];
            [self.headerView setCurrentIndex:0 animated:animated];
            self.selectedHeaderIndex = 0;
            self.headerView.bottomLineImageView.frame = CGRectMake(7 + 7, self.headerView.height-2, 75, 2);
        }
        else {
            [self.scrollView setContentOffset:CGPointMake(self.scrollView.width * 1, self.scrollView.contentOffset.y) animated:animated];
            [self.headerView setCurrentIndex:1 animated:animated];
            self.selectedHeaderIndex = 1;
            self.headerView.bottomLineImageView.frame = CGRectMake(90 + 7, self.headerView.height-2, 95, 2);
        }
        [self enableOrDisableEditBtn];
    }
}


- (SNVideoDownloadViewMode)currentViewMode {
    if (self.selectedHeaderIndex == 0) {
        return SNVideoDownloadViewMode_DownloadedView;
    } else {
        return SNVideoDownloadViewMode_DownloadingView;
    }
}

#pragma mark -
- (BOOL)recognizeSimultaneouslyWithGestureRecognizer {    
    if (_scrollView.contentOffset.x <= 0) {
        return YES;
    }
    return NO;
}

- (BOOL)isSupportPushBack {
    return ![self isEditMode];
}

#pragma mark - Private
- (void)recycleContent {
    [self.headerView resignOffsetListener];
    
    self.scrollView.delegate = nil;
    self.scrollView = nil;
    
    self.downloadingViewController.delegate = self;
    self.downloadingViewController = nil;

    self.downloadedViewController.delegate = self;
    self.downloadedViewController = nil;
    
    self.fileSystemSizeBar = nil;
}

- (void)createChildrenViewControllers {
    //Scroll view
    self.scrollView                                 = [[UIScrollView alloc] initWithFrame:self.view.bounds];
    self.scrollView.pagingEnabled                   = YES;
    self.scrollView.showsHorizontalScrollIndicator  = NO;
    self.scrollView.showsVerticalScrollIndicator    = NO;
    self.scrollView.bounces                         = NO;
    self.scrollView.delegate                        = self;
    self.scrollView.contentSize                     = CGSizeMake(self.view.width*2, self.view.height);
    [self.view addSubview:self.scrollView];
    
    //Downloaded view
    self.downloadedViewController               = [[SNVideoDownloadedViewController alloc] init];
    self.downloadedViewController.delegate      = self;
    self.downloadedViewController.view.frame    = CGRectMake(0, 0, self.view.width, self.view.height);
    [self addChildViewController:self.downloadedViewController];
    [self.scrollView addSubview:self.downloadedViewController.view];
    
    //Downloading view
    self.downloadingViewController              = [[SNVideoDownloadingViewController alloc] init];
    self.downloadingViewController.delegate     = self;
    self.downloadingViewController.view.frame   = CGRectMake(self.view.width, 0, self.view.width, self.view.height);
    [self addChildViewController:self.downloadingViewController];
    [self.scrollView addSubview:self.downloadingViewController.view];
}

- (void)createEditBtn {
    _editBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, kEditBtnWidth, kEditBtnHeight)];
    
    _editBtn.accessibilityLabel = @"编辑";
    _editBtn.enabled = NO;
    [_editBtn setImage:[UIImage imageNamed:@"edit_downloaded_items.png"] forState:UIControlStateNormal];
    [_editBtn setImage:[UIImage imageNamed:@"edit_downloaded_items-press.png"] forState:UIControlStateHighlighted];
    [_editBtn addTarget:self action:@selector(beginEdit) forControlEvents:UIControlEventTouchUpInside];
    [_editBtn setBackgroundColor:[UIColor clearColor]];
    [self.toolbarView setRightButton:_editBtn];
}

- (void)addFileSystemSizeBar {
    self.fileSystemSizeBar = [[SNFileSystemSizeBar alloc] initWithFrame:CGRectMake(0,
                                                                                    self.toolbarView.top-kFileSystemSizeBarHeight+kToolBarShadowHeight,
                                                                                    self.view.width,
                                                                                    kFileSystemSizeBarHeight)];
    [self.view addSubview:self.fileSystemSizeBar];
}

#pragma mark -
- (void)beginEdit {
    self.isEditMode = YES;
    self.scrollView.scrollEnabled = NO;
    [self dismissHeaderAndToolBar];
}

- (void)finishEdit {
    self.isEditMode = NO;
    SNVideoDownloadViewMode _mode = [self currentViewMode];
    if (_mode == SNVideoDownloadViewMode_DownloadedView) {
        [self.downloadedViewController finishEdit];
    }
    else if (_mode == SNVideoDownloadViewMode_DownloadingView) {
        [self.downloadingViewController finishEdit];
    }
}

- (void)didFinishEdit {
    [self showHeaderAndToolBar];
    self.scrollView.scrollEnabled = YES;
    [self enableOrDisableEditBtn];
}

- (void)dismissHeaderAndToolBar {
    [UIView animateWithDuration:0.2 animations:^{
        self.headerView.top = -self.headerView.height;
        self.toolbarView.top = self.view.height;
        self.fileSystemSizeBar.top = self.view.height;
    } completion:^(BOOL finished) {
        SNVideoDownloadViewMode _mode = [self currentViewMode];
        if (_mode == SNVideoDownloadViewMode_DownloadedView) {
            [self.downloadedViewController beginEdit];
        }
        else if (_mode == SNVideoDownloadViewMode_DownloadingView) {
            [self.downloadingViewController beginEdit];
        }
    }];
}

- (void)showHeaderAndToolBar {
    [UIView animateWithDuration:0.2 animations:^{
        self.headerView.top = 0;
        self.toolbarView.top = self.view.height-self.toolbarView.height;
        self.fileSystemSizeBar.top = self.toolbarView.top-kFileSystemSizeBarHeight+kToolBarShadowHeight;
    }];
}

#pragma mark -
- (void)enableOrDisableEditBtn {
    if ([self currentViewMode] == SNVideoDownloadViewMode_DownloadedView) {
        if (self.downloadedViewController.items.count <= 0) {
            self.editBtn.enabled = NO;
        } else {
            self.editBtn.enabled = YES;
        }
    } else {
        if (self.downloadingViewController.items.count <= 0) {
            self.editBtn.enabled = NO;
        } else {
            self.editBtn.enabled = YES;
        }
    }
}

#pragma mark - About SNVideoDownloadManager
- (void)addNotificationHandlers {
    [SNNotificationManager addObserver:self selector:@selector(handleDidAddANewsDownloadItemNotification:)
                                                 name:kDidAddANewsDownloadItemNotification object:nil];
    [SNNotificationManager addObserver:self selector:@selector(handleDidSucceedToDownloadAVideoNotification:)
                                                 name:kDidSucceedToDownloadAVideoNotification object:nil];
    [SNNotificationManager addObserver:self selector:@selector(handleDidFinishedToDownloadAllVideosNotification:)
                                                 name:kDidFinishedToDownloadAllVideosNotification object:nil];
    [SNNotificationManager addObserver:self selector:@selector(handleRefreshFileSystemSizeBarNotification:)
                                                 name:kRefreshFileSystemSizeBarNotification object:nil];

}

- (void)removeNotificationHandlers {
    [SNNotificationManager removeObserver:self name:kDidAddANewsDownloadItemNotification object:nil];
    [SNNotificationManager removeObserver:self name:kDidSucceedToDownloadAVideoNotification object:nil];
    [SNNotificationManager removeObserver:self name:kDidFinishedToDownloadAllVideosNotification object:nil];
    [SNNotificationManager removeObserver:self name:kRefreshFileSystemSizeBarNotification object:nil];
}

- (void)handleDidAddANewsDownloadItemNotification:(NSNotification *)notification  {
    [self.downloadingViewController reloadData];
}

- (void)handleDidSucceedToDownloadAVideoNotification:(NSNotification *)notification {
    [self.downloadingViewController reloadData];
    [self.downloadedViewController reloadData];
}

- (void)handleDidFinishedToDownloadAllVideosNotification:(NSNotification *)notification {
    [self.downloadingViewController reloadData];
    [self.downloadedViewController reloadData];
    
    [self enableOrDisableEditBtn];
}

- (void)handleRefreshFileSystemSizeBarNotification:(NSNotification *)notification {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        //计算剩余存储空间
        SNFileSystemSize *_fileSystemSize = [SNUtility getCachedFileSystemSize];
        
        //计算已离线的视频所占空间
        CGFloat downloadedBytes = 0;
        NSArray *downloadedVideos = [[SNDBManager currentDataBase] queryAllDownloadedVideos];
        for (SNVideoDataDownload *downloadedVideo in downloadedVideos) {
            downloadedBytes += downloadedVideo.totalBytes;
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.fileSystemSizeBar update:_fileSystemSize.freeFileSystemSizeInBytes downloadedVideosInBytes:downloadedBytes];
        });
    });
}

#pragma mark - Deletates
#pragma mark - UIScrollViewDelegate
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    if (_scrollView == self.scrollView) {
        int _currentIndex = self.scrollView.contentOffset.x / self.scrollView.width;
        [self.headerView setCurrentIndex:_currentIndex animated:YES];
        self.selectedHeaderIndex = _currentIndex;
        
        [self enableOrDisableEditBtn];
        if (_currentIndex == 0) {
            CGSize titleSize = [NSLocalizedString(@"downloaded_videos_title", nil) sizeWithFont:[UIFont systemFontOfSize:kThemeFontSizeE]];
            self.headerView.bottomLineImageView.frame = CGRectMake(7 + 7, self.headerView.height-2, titleSize.width+6, 2);
        }
        else {
            CGSize titleSize = [NSLocalizedString(@"downloading_videos_title", nil) sizeWithFont:[UIFont systemFontOfSize:kThemeFontSizeE]];
            self.headerView.bottomLineImageView.frame = CGRectMake(90 + 7, self.headerView.height-2, titleSize.width+6, 2);
        }
    }
}

#pragma mark - SNHeadSelectViewDelegate
- (void)headView:(SNHeadSelectView *)headView didSelectIndex:(int)index {
    [self.scrollView setContentOffset:CGPointMake(self.scrollView.width * index, self.scrollView.contentOffset.y) animated:YES];
    self.selectedHeaderIndex = index;
    
    [self enableOrDisableEditBtn];
    
    if (index == 0) {
        CGSize titleSize = [NSLocalizedString(@"downloaded_videos_title", nil) sizeWithFont:[UIFont systemFontOfSize:kThemeFontSizeE]];
        self.headerView.bottomLineImageView.frame = CGRectMake(7 + 7, self.headerView.height-2, titleSize.width+6, 2);
    }
    else {
        CGSize titleSize = [NSLocalizedString(@"downloading_videos_title", nil) sizeWithFont:[UIFont systemFontOfSize:kThemeFontSizeE]];
        self.headerView.bottomLineImageView.frame = CGRectMake(90 + 7, self.headerView.height-2, titleSize.width+6, 2);
    }
}

#pragma mark -
- (void)onBack:(id)sender {
    [super onBack:sender];
    
    [SNNotificationManager postNotificationName:kCleanTipOfFinishingDownloadANewVideoNotification object:nil userInfo:nil];
}

@end
