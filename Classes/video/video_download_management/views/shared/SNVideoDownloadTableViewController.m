//
//  SNVideoDownloadTableViewController.m
//  sohunews
//
//  Created by handy wang on 8/29/13.
//  Copyright (c) 2013 Sohu.com. All rights reserved.
//

#import "SNVideoDownloadTableViewController.h"
#import "UIColor+ColorUtils.h"
#import "SNVideoEmptyDownloadView.h"
#import "SNVideoDownloadTableViewCell.h"
#import "SNVideoDownloadHeaderBar.h"
#import "SNDBManager.h"
#import "SNDownloaderAlert.h"
#import "SNVideoDownloadManager.h"

#import "SNNewAlertView.h"

#define kHeaderBarHeight                                                        (44.0f)
#define kToolBarHeight                                                          (49.0f)

#define kConfirmAlertViewTagOfDeleteSelectedItems                               (1000)
#define kSelectedItemsArray                                                     (@"kSelectedItemsArray")

@interface SNVideoDownloadTableViewController ()
@property (nonatomic, strong)SNVideoDownloadHeaderBar   *headerBar;
@property (nonatomic, strong)SNVideoDownloadToolBar     *toolBar;
@property (nonatomic, assign)NSInteger                  selectedCount;
@property (nonatomic, strong)SNVideoEmptyDownloadView   *emptyView;
@end

@implementation SNVideoDownloadTableViewController

#pragma mark - Lifecycle
- (id)init {
    if (self = [super init]) {
        self.items = [NSMutableArray array];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    //TableView
    self.tableView                                  = [[SNVideoDownloadTableView alloc] initWithFrame:self.view.bounds style:UITableViewStylePlain];
    self.tableView.dataSource                       = self;
    self.tableView.delegate                         = self;
    self.tableView.contentInset                     = UIEdgeInsetsMake(kHeaderBarHeight+kSystemBarHeight,
                                                                       0,
                                                                       kHeaderBarHeight+(kFileSystemSizeBarHeight-kToolBarShadowHeight+3), 0);
    self.tableView.scrollIndicatorInsets            = UIEdgeInsetsMake(kHeaderBarHeight+kSystemBarHeight,
                                                                       0,
                                                                       kHeaderBarHeight+(kFileSystemSizeBarHeight-kToolBarShadowHeight+3), 0);
    self.tableView.showsHorizontalScrollIndicator   = NO;
    self.tableView.showsVerticalScrollIndicator     = YES;
    self.tableView.separatorStyle                   = UITableViewCellSeparatorStyleNone;
    self.tableView.backgroundColor                  = [UIColor clearColor];
    self.tableView.backgroundView                   = nil;
    [self.view addSubview:self.tableView];
    
    //Headerbar
    CGFloat headerBarHeight = kHeaderBarHeight+kSystemBarHeight;
    self.headerBar          = [[SNVideoDownloadHeaderBar alloc] initWithFrame:CGRectMake(0,
                                                                                          -headerBarHeight,
                                                                                          self.view.width,
                                                                                          headerBarHeight)];
    [self.view addSubview:self.headerBar];
    
    //Toolbar
    CGRect _toolBarFrame    = CGRectMake(0, self.view.height, self.view.width, kToolBarHeight);
    self.toolBar            = [[SNVideoDownloadToolBar alloc] initWithFrame:_toolBarFrame];
    self.toolBar.delegate   = self;
    [self.view addSubview:self.toolBar];
    self.selectedCount      = 0;
    
    //Emtpy view
    self.emptyView          = [[SNVideoEmptyDownloadView alloc] initWithFrame:self.view.bounds];
    self.emptyView.height   = self.emptyView.height - kToolBarHeight;
    self.emptyView.hidden   = YES;
    [self.view addSubview:self.emptyView];
}

- (void)viewDidUnload {
    [super viewDidUnload];
    [self recycleContent];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)dealloc {
    [self recycleContent];
}

#pragma mark - Public
- (void)didEndDisplayingCell:(UITableViewCell *)cell {
    if ([self respondsToSelector:@selector(tableView:didEndDisplayingCell:forRowAtIndexPath:)]) {
        [self tableView:self.tableView didEndDisplayingCell:cell forRowAtIndexPath:[self.tableView indexPathForCell:cell]];
    }
}

#pragma mark - Invoked by SNDownloadViewController
- (void)reloadData {
    if (self.items.count <= 0) {
        [self thereIsNoDataToRender];
    }
    else {
        [self thereAreMuchDataToRender];
    }
}

- (void)reloadDataFromMem {
    if (self.items.count <= 0) {
        [self thereIsNoDataToRender];
    }
    else {
        [self thereAreMuchDataToRender];
    }
}

- (void)updateTheme {
    self.view.backgroundColor = [UIColor colorFromString:[[SNThemeManager sharedThemeManager] currentThemeValueForKey:kBackgroundColor]];
}

- (void)beginEdit {
    //Show toolbar
    [UIView animateWithDuration:0.2 animations:^{
        [self.tableView beginEdit];
        self.headerBar.top  = 0;
        [self.toolBar setSelectAllButtonState:NO];
        self.toolBar.top    = self.view.frame.size.height-kToolBarHeight;
    } completion:^(BOOL finished) {
    }];
}

- (void)finishEdit {
    //Hide toolbar
    [UIView animateWithDuration:0.2 animations:^{
        [self.tableView finishEdit];
        CGFloat headerBarHeight = kHeaderBarHeight+kSystemBarHeight;
        self.headerBar.top  = -headerBarHeight;
        self.toolBar.top    = self.view.frame.size.height;
    } completion:^(BOOL finished) {
        if ([_delegate respondsToSelector:@selector(didFinishEdit)]) {
            [_delegate didFinishEdit];
        }
        self.selectedCount = 0;
    }];
}

- (void)didTapCheckBoxInCell:(SNVideoDownloadTableViewCell *)cell {
    if(cell.model.isSelected) {
        self.selectedCount++ ;
        
    } else {
        self.selectedCount--;
    }
    
    NSInteger tmpSelectedCount = self.selectedCount;
    NSInteger tmpItmesCount = self.items.count;
    if (tmpSelectedCount >= tmpItmesCount) {
        self.selectedCount  = self.items.count;
        [self.toolBar setSelectAllButtonState:YES];
    } else {
        if (self.selectedCount < 0) {
            self.selectedCount = 0;
        }
        [self.toolBar setSelectAllButtonState:NO];
    }
}

#pragma mark - Private
- (void)recycleContent {
    self.tableView.dataSource = nil;
    self.tableView.delegate = nil;
    self.tableView = nil;

    self.headerBar = nil;
    
    self.toolBar.delegate = nil;
    self.toolBar = nil;
    
    self.emptyView = nil;
    
    self.items = nil;
}

- (void)thereIsNoDataToRender {
    self.emptyView.hidden = NO;
    
    SNVideoDownloadViewMode _mode = SNVideoDownloadViewMode_DownloadedView;
    if ([_delegate respondsToSelector:@selector(currentViewMode)]) {
        _mode = [_delegate currentViewMode];
    }
    
    if ([_delegate respondsToSelector:@selector(enableOrDisableEditBtn)] && _mode == SNVideoDownloadViewMode_DownloadedView) {
        [_delegate enableOrDisableEditBtn];
    }
}

- (void)thereAreMuchDataToRender {
    self.emptyView.hidden = YES;
    
    SNVideoDownloadViewMode _mode = SNVideoDownloadViewMode_DownloadedView;
    if ([_delegate respondsToSelector:@selector(currentViewMode)]) {
        _mode = [_delegate currentViewMode];
    }
    if ([_delegate respondsToSelector:@selector(enableOrDisableEditBtn)] && _mode == SNVideoDownloadViewMode_DownloadedView) {
        [_delegate enableOrDisableEditBtn];
    }
}

#pragma mark - Delegates
#pragma mark - UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.items.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *_cellIdentifier = @"CELL_INDENTIFIER";
    UITableViewCell *_cell = [tableView dequeueReusableCellWithIdentifier:_cellIdentifier];
    if (!_cell) {
        _cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:_cellIdentifier];
    }
    _cell.textLabel.text = [NSString stringWithFormat:@"%ld_Cell", (long)indexPath.row];
    return _cell;
}

#pragma mark - UITableViewDelegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return [SNVideoDownloadTableViewCell heightForRow];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    SNVideoDownloadTableViewCell *_cell = (SNVideoDownloadTableViewCell *)[tableView cellForRowAtIndexPath:indexPath];
    if (!!_cell) {
        [_cell tapCheckBox:_cell.checkBox];
    }
}

#pragma mark - SNVideoDownloadToolBarDelegate
- (void)selectAll {
    [self.tableView selectAll];
    self.selectedCount = self.items.count;
}

- (void)deselectAll {
    [self.tableView deselectAll];
    self.selectedCount = 0;
}

- (void)deleteSelected {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSMutableArray *_selectedItems = [NSMutableArray array];
        for (SNVideoDataDownload *_model in self.items) {
            if (_model.isSelected && _model.vid.length > 0) {
                [_selectedItems addObject:_model];
            }
        }
        
        if ([_selectedItems count] == 0) {
            [[SNCenterToast shareInstance] showCenterToastWithTitle:NSLocalizedString(@"pls_select_atleast_one_downloadedvideo", nil) toUrl:nil mode:SNCenterToastModeWarning];
            return ;
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            
            SNNewAlertView *alertView = [[SNNewAlertView alloc] initWithTitle:nil message:NSLocalizedString(@"confirm_delete_selected_downloadedvideos", nil) cancelButtonTitle:NSLocalizedString(@"videoDownloadActionBtnTitle_CancelAction", @"") otherButtonTitle:NSLocalizedString(@"Confirm", @"")];
            [alertView show];
            [alertView actionWithBlocksCancelButtonHandler:nil otherButtonHandler:^{
                [self deleteSelectedItems:_selectedItems];
            }];
        });
    });
}

- (void)deleteSelectedItems:(NSMutableArray*)items
{
//    [SNNotificationCenter showLoadingAndBlockOtherActions:NSLocalizedString(@"Please wait",@"")];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        if (1) {
            BOOL _deleteSuccess = NO;
            if (items.count > 0) {
                _deleteSuccess = [[SNDBManager currentDataBase] deleteDownloadedVideosIn:items];
                
                //删除对应的数据库数据和文件
                NSFileManager *_fileManager = [[NSFileManager alloc] init];
                for (SNVideoDataDownload *__model in items) {
                    //重置timeline数据的offlineplay为NO
                    NSNumber *offlinePlay = @(NO);
                    if (!!offlinePlay) {
                        NSDictionary *dic = [NSDictionary dictionaryWithObject:offlinePlay forKey:TB_VIDEO_TIMELINE_OFFLINE_PLAY];
                        [[SNDBManager currentDataBase] updateATimelineVideo:dic byVid:__model.vid];
                    }
                    
                    [[SNDBManager currentDataBase] deleteSegmentsByVid:__model.vid];
                    
                    //删除已下载的项
                    if (__model.state == SNVideoDownloadState_Successful) {
                        NSError *__error = nil;
                        NSString *__path = [[SNVideoDownloadConfig rootDir] stringByAppendingPathComponent:__model.localRelativePath];
                        if ([_fileManager fileExistsAtPath:__path]) {
                            [_fileManager removeItemAtPath:__path error:&__error];
                            SNDebugLog(@"DELETE VIDEO FILE WITH PATH: %@", __path);
                        }
                        else {
                            SNDebugLog(@"NOT EXISTED WHEN DELETE VIDEO FILE WITH PATH: %@", __path);
                        }
                    }
                    //删除正在离线页面中的项
                    else {
                        //正在下载的先暂停
                        if (__model.state == SNVideoDownloadState_Downloading) {
                            [[SNVideoDownloadManager sharedInstance] pauseDownloadingVideo:__model];
                        }
                        
                        //从下载管理器的内存中删除
                        [[SNVideoDownloadManager sharedInstance] removeSelectedItem:__model];
                        
                        //针对有临时文件的要删除临时文件，如果是m3u8还要删除对应的已下载的m3u8片断
                        //MP4
                        if ([__model.videoType isEqualToString:kDownloadVideoType_MP4]) {
                            //删除临时文件
                            NSString *_tmpMP4FilePath = [[SNVideoDownloadConfig normalVideoTmpDir] stringByAppendingPathComponent:__model.vid];
                            if ([_fileManager fileExistsAtPath:_tmpMP4FilePath]) {
                                [_fileManager removeItemAtPath:_tmpMP4FilePath error:nil];
                            }
                        }
                        //M3U8
                        else if ([__model.videoType isEqualToString:kDownloadVideoType_M3U8]) {
                            //删除m3u8片断临时文件
                            NSArray *_m3u8TmpFileNames = [_fileManager contentsOfDirectoryAtPath:[SNVideoDownloadConfig m3u8VideoTmpDir] error:nil];
                            for (NSString *_m3u8TmpFileName in _m3u8TmpFileNames) {
                                for (SNVideoDataDownload *_selectedModel in items) {
                                    if ([_m3u8TmpFileName startWith:_selectedModel.vid]) {
                                        NSString *_m3u8TmpFilePath = [[SNVideoDownloadConfig m3u8VideoTmpDir] stringByAppendingPathComponent:_m3u8TmpFileName];
                                        if ([_fileManager fileExistsAtPath:_m3u8TmpFilePath]) {
                                            [_fileManager removeItemAtPath:_m3u8TmpFilePath error:nil];
                                        }
                                    }
                                }
                            }
                            //删除对应的已下载的m3u8片断文件
                            NSString *_downloadedM3U8SegmentsRootDir = [SNVideoDownloadConfig m3u8VideoDir:__model.vid];
                            if ([_fileManager fileExistsAtPath:_downloadedM3U8SegmentsRootDir]) {
                                [_fileManager removeItemAtPath:_downloadedM3U8SegmentsRootDir error:nil];
                            }
                        }
                    }
                }
                 //(_fileManager);
            }
            
            if (_deleteSuccess) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [SNNotificationManager postNotificationName:kRefreshFileSystemSizeBarNotification object:nil];
                    
                    [self.items removeObjectsInArray:items];
                    [items removeAllObjects];
                    [self reloadDataFromMem];
                    
                    if ([_delegate respondsToSelector:@selector(finishEdit)]) {
                        [_delegate finishEdit];
                    }
                    
                    if (self.items.count <= 0) {//内存中数据已经空了，所以需要从数据库reload数据
                        [self reloadData];
                    }
                    
                    [SNNotificationCenter hideLoadingAndBlock];
                    [[SNCenterToast shareInstance] showCenterToastWithTitle:NSLocalizedString(@"Finish clear up", nil) toUrl:nil mode:SNCenterToastModeSuccess];
                });
            }
            else {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [SNNotificationManager postNotificationName:kRefreshFileSystemSizeBarNotification object:nil];
                    
                    [SNNotificationCenter hideLoadingAndBlock];
                    [[SNCenterToast shareInstance] showCenterToastWithTitle:@"暂无法删除!" toUrl:nil mode:SNCenterToastModeWarning];
                });
            }
        }
        else {
            dispatch_async(dispatch_get_main_queue(), ^{
                [SNNotificationCenter hideLoadingAndBlock];
                [[SNCenterToast shareInstance] showCenterToastWithTitle:@"暂无法删除!" toUrl:nil mode:SNCenterToastModeWarning];
            });
        }
    });
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    //Alert view for deleting selected items.
    if (alertView.tag == kConfirmAlertViewTagOfDeleteSelectedItems) {
        if (buttonIndex == 1)
        {
            [SNNotificationCenter showLoadingAndBlockOtherActions:NSLocalizedString(@"Please wait",@"")];
            
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                SNDownloaderAlert *_alertVIew = (SNDownloaderAlert *)alertView;
                NSDictionary *_userInfo = _alertVIew.userInfo;
                if (_userInfo && _userInfo.count > 0) {
                    NSMutableArray *_selectedItems = [_userInfo objectForKey:kSelectedItemsArray];
                    BOOL _deleteSuccess = NO;
                    if (_selectedItems.count > 0) {
                        _deleteSuccess = [[SNDBManager currentDataBase] deleteDownloadedVideosIn:_selectedItems];
                        
                        //删除对应的数据库数据和文件
                        NSFileManager *_fileManager = [[NSFileManager alloc] init];
                        for (SNVideoDataDownload *__model in _selectedItems) {
                            //重置timeline数据的offlineplay为NO
                            NSNumber *offlinePlay = @(NO);
                            if (!!offlinePlay) {
                                NSDictionary *dic = [NSDictionary dictionaryWithObject:offlinePlay forKey:TB_VIDEO_TIMELINE_OFFLINE_PLAY];
                                [[SNDBManager currentDataBase] updateATimelineVideo:dic byVid:__model.vid];
                            }
                            
                            [[SNDBManager currentDataBase] deleteSegmentsByVid:__model.vid];
                            
                            //删除已下载的项
                            if (__model.state == SNVideoDownloadState_Successful) {
                                NSError *__error = nil;
                                NSString *__path = [[SNVideoDownloadConfig rootDir] stringByAppendingPathComponent:__model.localRelativePath];
                                if ([_fileManager fileExistsAtPath:__path]) {
                                    [_fileManager removeItemAtPath:__path error:&__error];
                                    SNDebugLog(@"DELETE VIDEO FILE WITH PATH: %@", __path);
                                }
                                else {
                                    SNDebugLog(@"NOT EXISTED WHEN DELETE VIDEO FILE WITH PATH: %@", __path);
                                }
                            }
                            //删除正在离线页面中的项
                            else {
                                //正在下载的先暂停
                                if (__model.state == SNVideoDownloadState_Downloading) {
                                    [[SNVideoDownloadManager sharedInstance] pauseDownloadingVideo:__model];
                                }
                                
                                //从下载管理器的内存中删除
                                [[SNVideoDownloadManager sharedInstance] removeSelectedItem:__model];
                                
                                //针对有临时文件的要删除临时文件，如果是m3u8还要删除对应的已下载的m3u8片断
                                //MP4
                                if ([__model.videoType isEqualToString:kDownloadVideoType_MP4]) {
                                    //删除临时文件
                                    NSString *_tmpMP4FilePath = [[SNVideoDownloadConfig normalVideoTmpDir] stringByAppendingPathComponent:__model.vid];
                                    if ([_fileManager fileExistsAtPath:_tmpMP4FilePath]) {
                                        [_fileManager removeItemAtPath:_tmpMP4FilePath error:nil];
                                    }
                                }
                                //M3U8
                                else if ([__model.videoType isEqualToString:kDownloadVideoType_M3U8]) {
                                    //删除m3u8片断临时文件
                                    NSArray *_m3u8TmpFileNames = [_fileManager contentsOfDirectoryAtPath:[SNVideoDownloadConfig m3u8VideoTmpDir] error:nil];
                                    for (NSString *_m3u8TmpFileName in _m3u8TmpFileNames) {
                                        for (SNVideoDataDownload *_selectedModel in _selectedItems) {
                                            if ([_m3u8TmpFileName startWith:_selectedModel.vid]) {
                                                NSString *_m3u8TmpFilePath = [[SNVideoDownloadConfig m3u8VideoTmpDir] stringByAppendingPathComponent:_m3u8TmpFileName];
                                                if ([_fileManager fileExistsAtPath:_m3u8TmpFilePath]) {
                                                    [_fileManager removeItemAtPath:_m3u8TmpFilePath error:nil];
                                                }
                                            }
                                        }
                                    }
                                    //删除对应的已下载的m3u8片断文件
                                    NSString *_downloadedM3U8SegmentsRootDir = [SNVideoDownloadConfig m3u8VideoDir:__model.vid];
                                    if ([_fileManager fileExistsAtPath:_downloadedM3U8SegmentsRootDir]) {
                                        [_fileManager removeItemAtPath:_downloadedM3U8SegmentsRootDir error:nil];
                                    }
                                }
                            }
                        }
                         //(_fileManager);
                    }
                    
                    if (_deleteSuccess) {
                        dispatch_async(dispatch_get_main_queue(), ^{
                            [SNNotificationManager postNotificationName:kRefreshFileSystemSizeBarNotification object:nil];
                            
                            [self.items removeObjectsInArray:_selectedItems];
                            [_selectedItems removeAllObjects];
                            [self reloadDataFromMem];
                            
                            if ([_delegate respondsToSelector:@selector(finishEdit)]) {
                                [_delegate finishEdit];
                            }
                            
                            if (self.items.count <= 0) {//内存中数据已经空了，所以需要从数据库reload数据
                                [self reloadData];
                            }
                            
                            [SNNotificationCenter hideLoadingAndBlock];
                            [[SNCenterToast shareInstance] showCenterToastWithTitle:NSLocalizedString(@"Finish clear up", nil) toUrl:nil mode:SNCenterToastModeSuccess];
                        });
                    }
                    else {
                        dispatch_async(dispatch_get_main_queue(), ^{
                            [SNNotificationManager postNotificationName:kRefreshFileSystemSizeBarNotification object:nil];
                            
                            [SNNotificationCenter hideLoadingAndBlock];
                            [[SNCenterToast shareInstance] showCenterToastWithTitle:@"暂无法删除!" toUrl:nil mode:SNCenterToastModeWarning];
                        });
                    }
                }
                else {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [SNNotificationCenter hideLoadingAndBlock];
                        [[SNCenterToast shareInstance] showCenterToastWithTitle:@"暂无法删除!" toUrl:nil mode:SNCenterToastModeWarning];
                    });
                }
            });
        }
    }
}

- (void)cancelEdit {
    if ([_delegate respondsToSelector:@selector(finishEdit)]) {
        [_delegate finishEdit];
    }
}

@end
