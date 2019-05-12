//
//  SNVideoDownloadedViewController.m
//  sohunews
//
//  Created by handy wang on 8/27/13.
//  Copyright (c) 2013 Sohu.com. All rights reserved.
//

#import "SNVideoDownloadedViewController.h"
#import "SNVideoDownloadedCell.h"
#import "SNDBManager.h"


@interface SNVideoDownloadedViewController()
@property (nonatomic, strong)NSMutableArray *offlinePlayVideos;
@end

@implementation SNVideoDownloadedViewController

#pragma mark - Lifecycle
- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self reloadData];
}

#pragma mark - Override
#pragma mark - Invoked by SNDownloadViewController
- (void)reloadData {
    //处于编辑模式时不刷新列表,只有当“取消”、“删除全部”时，重新从数据库刷新
    if ([self.delegate respondsToSelector:@selector(isEditMode)]) {
        if ([self.delegate isEditMode]) {
            return;
        }
    }
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSMutableArray *tempDownloadedVideos = [[[SNDBManager currentDataBase] queryAllDownloadedVideos] mutableCopy];
        self.items = tempDownloadedVideos;
         //(tempDownloadedVideos);
        
        NSMutableArray *tempOfflinePlayVideos = [[[SNDBManager currentDataBase] getAllOfflinePlayVideos] mutableCopy];
        self.offlinePlayVideos = tempOfflinePlayVideos;
         //(tempOfflinePlayVideos);
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.tableView reloadData];
            [super reloadData];
        });
    });
}

- (void)reloadDataFromMem {
    NSMutableArray *tempOfflinePlayVideos = [[[SNDBManager currentDataBase] getAllOfflinePlayVideos] mutableCopy];
    self.offlinePlayVideos = tempOfflinePlayVideos;
     //(tempOfflinePlayVideos);
    
    [self.tableView reloadData];
    [super reloadData];
}

- (void)updateTheme {
    [super updateTheme];
    //TODO:.....
    [self reloadData];
}

- (void)beginEdit {
    [super beginEdit];
    //TODO:.....
}

- (void)finishEdit {
    [super finishEdit];
    //TODO:.....
}

#pragma mark - Called by super controller
- (void)recycleContent {
    [super recycleContent];
    self.offlinePlayVideos = nil;
    //TODO:.....
}

#pragma mark - Delegates
#pragma mark - UITableViewDataSource
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *_cellIdentifier = @"CELL_INDENTIFIER";
    SNVideoDownloadedCell *_cell = [tableView dequeueReusableCellWithIdentifier:_cellIdentifier];
    if (!_cell) {
        _cell = [[SNVideoDownloadedCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:_cellIdentifier];
        _cell.tableViewController = self;
    }
    [_cell setData:[self.items objectAtIndex:indexPath.row]];
    return _cell;
}

#pragma mark - UITableViewDelegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if ([self.delegate respondsToSelector:@selector(isEditMode)]) {
        if ([self.delegate isEditMode]) {
            [super tableView:tableView didSelectRowAtIndexPath:indexPath];
            return;
        }
    }

    if (indexPath.row < self.items.count) {
        SNVideoDataDownload *downloadedVideo = [self.items objectAtIndex:indexPath.row];
        SNVideoData *offlinePlayVideo = nil;
        for (SNVideoData *video in self.offlinePlayVideos) {
            if ([video.vid isEqualToString:downloadedVideo.vid]) {
                offlinePlayVideo = video;
                NSString *localVideoRelativePath = downloadedVideo.localRelativePath;
                if (localVideoRelativePath.length > 0) {
                    NSString *localVideoAbsolutePath = [[SNVideoDownloadConfig rootDir] stringByAppendingPathComponent:localVideoRelativePath];
                    offlinePlayVideo.sources = [NSMutableArray arrayWithObject:localVideoAbsolutePath];
                }
            }
        }
        
        if (!!offlinePlayVideo) {
            NSMutableDictionary *dict = [NSMutableDictionary dictionary];
            if (!!offlinePlayVideo) {
                [dict setValue:offlinePlayVideo forKey:kDataKey_TimelineVideo];
            }
            if (!!(self.offlinePlayVideos)) {
                [dict setValue:self.offlinePlayVideos forKey:kDataKey_OfflinePlayVideos];
            }
            [dict setObject:@(WSMVVideoPlayerRefer_OfflinePlay) forKey:kWSMVVideoPlayerReferKey];
            
            if (offlinePlayVideo.link2.length) {
                [SNUtility openProtocolUrl:offlinePlayVideo.link2 context:dict];
            } else {
                TTURLAction *urlAction = [[[TTURLAction actionWithURLPath:@"tt://videoDetail"] applyAnimated:YES] applyQuery:dict];
                [[TTNavigator navigator] openURLAction:urlAction];
            }
        }
        else {
            [[SNCenterToast shareInstance] showCenterToastWithTitle:NSLocalizedString(@"failed_to_play_downloaded_video", nil) toUrl:nil mode:SNCenterToastModeWarning];
        }
    }
}

#pragma mark - SNVideoDownloadToolBarDelegate
- (void)selectAll {
    [super selectAll];
    //TODO:.....
}

- (void)deselectAll {
    [super deselectAll];
    //TODO:.....
}

- (void)deleteSelected {
    [super deleteSelected];
    //TODO:.....
}

- (void)cancelEdit {
    if ([self.delegate respondsToSelector:@selector(finishEdit)]) {
        [self.delegate finishEdit];
    }
    [self reloadData];
}

@end
