//
//  SNVideoDownloadingCell.m
//  sohunews
//
//  Created by handy wang on 8/29/13.
//  Copyright (c) 2013 Sohu.com. All rights reserved.
//

#import "SNVideoDownloadingCell.h"
#import "SNVideoDownloadProgressBar.h"
#import "SNDBManager.h"

#define kDataSizeLabelMarginBottom                              (18.0f/2.0f)
#define kDataSizeLabelWidth                                     (100.0f)
#define kDataSizeLabelHeight                                    (13.0f)
#define kDataSizeLabelFontSize                                  (20.0f/2.0f)

#define kProgressBarHeight                                      (4.0f/2.0f)
#define kProgressBarWidth                                       (kAppScreenWidth == 320.0 ? 158.0 :(kAppScreenWidth == 375.0 ? 213: 252))
#define kProgressBarMarginTopToHeadline                         (12.0f/2.0f)
#define kProgressBarMarginBottomToDataSizeLabel                 (4.0f/2.0f)

#define kActionBtnWidth                                         (40.0f/2.0f)
#define kActionBtnHeight                                        (40.0f/2.0f)
#define KActionBtnPaddingLeftToProgressBar                      (24.0f/2.0f)
#define kActionBtnRightDistance                                 (20.0f)

@interface SNVideoDownloadingCell()
@property (nonatomic, strong)UILabel                    *dataSizeLabel;
@property (nonatomic, strong)SNVideoDownloadProgressBar *progressBar;
@property (nonatomic, strong)UIButton                   *actionBtn;
@end

@implementation SNVideoDownloadingCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        [self addNotificationHandlers];
    }
    return self;
}

- (void)dealloc {
    [self removeNotificationHandlers];
}

#pragma mark - Override
- (void)setData:(SNVideoDataDownload *)data {
    [super setData:data];
    
    //Datasize label
    if (!(self.dataSizeLabel)) {
        self.dataSizeLabel                  = [[UILabel alloc] initWithFrame:CGRectMake(self.headlineLabel.left,
                                                                                         [SNVideoDownloadTableViewCell heightForRow]-kDataSizeLabelHeight-kDataSizeLabelMarginBottom,
                                                                                         kDataSizeLabelWidth,
                                                                                         kDataSizeLabelHeight)];
        self.dataSizeLabel.backgroundColor  = [UIColor clearColor];
        self.dataSizeLabel.font             = [UIFont systemFontOfSize:kDataSizeLabelFontSize];
        self.dataSizeLabel.textAlignment    = NSTextAlignmentLeft;
        [self.contentView addSubview:self.dataSizeLabel];
    }
    self.dataSizeLabel.textColor                    = [UIColor colorFromString:[[SNThemeManager sharedThemeManager] currentThemeValueForKey:kVideoDownloadCell_DataSizeTextColor]];
    [self updateDataSizeLabelText];
    
    //Progress bar
    if (!(self.progressBar)) {
        self.progressBar = [[SNVideoDownloadProgressBar alloc] initWithFrame:CGRectMake(self.headlineLabel.left,
                                                                                        0,
                                                                                        kProgressBarWidth,
                                                                                        kProgressBarHeight)];
        self.progressBar.bottom = self.dataSizeLabel.top-kProgressBarMarginBottomToDataSizeLabel;
        [self.progressBar updateProgress:0];
        [self.contentView addSubview:self.progressBar];
    }
    [self.progressBar updateProgress:self.model.downloadProgress];
    SNDebugLog(@"setData: mp4 videoModel:\n %@", self.model);
    
    //Action button
    if (!(self.actionBtn)) {
        self.actionBtn          = [UIButton buttonWithType:UIButtonTypeCustom];
        self.actionBtn.frame    = CGRectMake(0,
                                             0,
                                             kActionBtnWidth,
                                             kActionBtnHeight);
        self.actionBtn.top      = self.progressBar.top-6;
//        self.actionBtn.left     = CGRectGetMaxX(self.progressBar.frame)+KActionBtnPaddingLeftToProgressBar;
        self.actionBtn.right = kAppScreenWidth - kActionBtnRightDistance;
        [self.actionBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [self.actionBtn addTarget:self action:@selector(tapActionBtn:) forControlEvents:UIControlEventTouchUpInside];
        [self.contentView addSubview:self.actionBtn];
    }
    [self hideOrShowActionBtn];
    [self updateActionBtn];
    self.contentView.alpha = themeImageAlphaValue();
}

#pragma mark -
- (void)tap {
    [self tapActionBtn:nil];
}

#pragma mark -
- (void)beginEdit {
    [super beginEdit];
    
    [self hideOrShowActionBtn];
}

- (void)finishEdit {
    [super finishEdit];
    
    [self hideOrShowActionBtn];
}

- (void)hideOrShowActionBtn {
    if (self.model.isEditing) {
        self.actionBtn.hidden = YES;
    }
    else {
        self.actionBtn.hidden = NO;
    }
}

#pragma mark - Private
- (void)addNotificationHandlers {
    [SNNotificationManager addObserver:self selector:@selector(handleWillStartDownloadIn2G3GNotification:)
                                                 name:kVideoWillStartDownloadIn2G3GNotification object:nil];
    [SNNotificationManager addObserver:self selector:@selector(handleDidStartDownloadingVideoNotification:)
                                                 name:kDidStartDownloadingVideoNotification object:nil];
    [SNNotificationManager addObserver:self selector:@selector(handleDidFailedToDownloadAVideoNotification:)
                                                 name:kDidFailedToDownloadAVideoNotification object:nil];
    [SNNotificationManager addObserver:self selector:@selector(handleVideoDownloadingProgressNotification:)
                                                 name:kVideoDownloadingProgressNotification object:nil];
}

- (void)removeNotificationHandlers {
    [SNNotificationManager removeObserver:self name:kVideoWillStartDownloadIn2G3GNotification object:nil];
    [SNNotificationManager removeObserver:self name:kDidStartDownloadingVideoNotification object:nil];
    [SNNotificationManager removeObserver:self name:kDidFailedToDownloadAVideoNotification object:nil];
    [SNNotificationManager removeObserver:self name:kVideoDownloadingProgressNotification object:nil];
}

- (void)handleWillStartDownloadIn2G3GNotification:(NSNotification *)notification {
    SNVideoDataDownload *downloadVideo = (SNVideoDataDownload *)[notification object];
    if ([downloadVideo.vid isEqualToString:self.model.vid]) {
        [self updateDataSizeLabelText];
        [self updateActionBtn];
    }
}

- (void)handleDidStartDownloadingVideoNotification:(NSNotification *)notification {
    SNVideoDataDownload *downloadVideo = (SNVideoDataDownload *)[notification object];
    if ([downloadVideo.vid isEqualToString:self.model.vid]) {
        [self updateDataSizeLabelText];
        [self updateActionBtn];
    }
}

- (void)handleDidFailedToDownloadAVideoNotification:(NSNotification *)notification {
    SNVideoDataDownload *downloadVideo = (SNVideoDataDownload *)[notification object];
    if ([downloadVideo.vid isEqualToString:self.model.vid]) {
        [self updateDataSizeLabelText];
        [self updateActionBtn];
    }
}

- (void)handleVideoDownloadingProgressNotification:(NSNotification *)notification {
    id _obj = [notification object];
    if ([_obj isKindOfClass:[NSDictionary class]]) {
        NSDictionary *_progressData = (NSDictionary *)_obj;
        
        NSString *_downloadingVideoType = [_progressData objectForKey:kDownloadingVideoType];
        if (_downloadingVideoType.length > 0) {
            //正在下载的是MP4
            if ([kDownloadVideoType_MP4 isEqualToString:_downloadingVideoType]) {
                SNVideoDataDownload *_downloadingModel = [_progressData objectForKey:kDownloadingVideoModel];
                if ([_downloadingModel.vid isEqualToString:self.model.vid]) {
                    id _obj1 = [_progressData objectForKey:kVideoDownloadedBytes];
                    id _obj2 = [_progressData objectForKey:kVideoTatalBytes];
                    
                    if ([_obj1 isKindOfClass:[NSNumber class]] && [_obj2 isKindOfClass:[NSNumber class]]) {
                        NSNumber *_downloadBytesNumber = (NSNumber *)_obj1;
                        NSNumber *_totalBytesNumber = (NSNumber *)_obj2;
                        CGFloat _progress = _downloadBytesNumber.floatValue/_totalBytesNumber.floatValue;
                        self.model.downloadProgress = _progress;
                        self.model.downloadBytes    = [_downloadBytesNumber floatValue];
                        self.model.totalBytes       = [_totalBytesNumber floatValue];
                        [self.progressBar updateProgress:_progress];
                        [self updateDataSizeLabelText];
                        
                        SNDebugLog(@"handleVideoDownloadingProgressNotification: mp4 videoModel:\n %@", self.model);
                    }
                }
            }
            //正在下载的是M3U8片断
            else if ([kDownloadVideoType_M3U8 isEqualToString:_downloadingVideoType]) {
                NSString *_vid = [_progressData objectForKey:kDownloadingM3U8VID];
                if ([_vid isEqualToString:self.model.vid]) {
                    id _obj1 = [_progressData objectForKey:kVideoDownloadedBytes];
                    id _obj2 = [_progressData objectForKey:kVideoTatalBytes];
                    if ([_obj1 isKindOfClass:[NSNumber class]] && [_obj2 isKindOfClass:[NSNumber class]]) {
                        NSNumber *_aSegmentDownloadBytesNumber = (NSNumber *)_obj1;
                        NSNumber *_aSegmentTotalBytesNumber = (NSNumber *)_obj2;
                        
                        //每个片断的总量
                        NSInteger _segmentOrder = [[_progressData objectForKey:kSegmentOrder] integerValue];
                        NSString *_key = [NSString stringWithFormat:@"%@_%ld", _vid, _segmentOrder];
                        if (!!_aSegmentTotalBytesNumber) {
                            [self.model.eachSegmentTotalBytes setObject:_aSegmentTotalBytesNumber forKey:_key];
                        }
                        
                        //每个片断已下载量
                        if (!!_aSegmentDownloadBytesNumber) {
                            [self.model.eachSegmentDownloadBytes setObject:_aSegmentDownloadBytesNumber forKey:_key];
                        }
                        
                        //每个片断总量求和
                        __block CGFloat _total = 0;
                        NSArray *_eachSegmentTotalBytes = [self.model.eachSegmentTotalBytes allValues];
                        [_eachSegmentTotalBytes enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                            NSObject *_value = [_eachSegmentTotalBytes objectAtIndex:idx];
                            if ([_value isKindOfClass:[NSNumber class]]) {
                                _total += [(NSNumber *)_value floatValue];
                            }
                        }];
                        
                        //每个片断已下载量求和
                        __block CGFloat _downloaded = 0;
                        NSArray *_eachSegmentDownloadBytes = [self.model.eachSegmentDownloadBytes allValues];
                        [_eachSegmentDownloadBytes enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                            NSObject *_value = [_eachSegmentDownloadBytes objectAtIndex:idx];
                            if ([_value isKindOfClass:[NSNumber class]]) {
                                _downloaded += [(NSNumber *)_value floatValue];
                            }
                        }];
                        
                        //计算进度
                        CGFloat _progress = 0;
                        NSInteger _segmentCount = [[_progressData objectForKey:kSegmentsCount] integerValue];
                        if (_total > 0 && _segmentCount > 0) {
                            _progress= (_downloaded/_total)*_eachSegmentTotalBytes.count/_segmentCount;
                        }
                        SNDebugLog(@"DOWNLOADING CELL: downloaded %f, total %f, segmentCount %d, progress %f, _eachSegmentDownloadBytesCount %d, eachSegmentTotalBytesCount %d",
                                   _downloaded, _total, _segmentCount, _progress, _eachSegmentDownloadBytes.count, _eachSegmentTotalBytes.count);
                        self.model.downloadProgress = _progress;
                        
                        self.model.downloadBytes    = _downloaded;
                        self.model.totalBytes       = _total;
                        [self.progressBar updateProgress:self.model.downloadProgress];
                        SNDebugLog(@"######################## Segments downloading progress %f", self.model.downloadProgress);
                        [self updateDataSizeLabelText];
                        
                        SNDebugLog(@"handleVideoDownloadingProgressNotification: m3u8 videoModel:\n %@", self.model);
                    }
                }
            }
        }
    }
}

#pragma mark -
- (void)updateDataSizeLabelText {
    switch (self.model.state) {
        case SNVideoDownloadState_Waiting: {
            self.dataSizeLabel.text = @"等待离线";
            self.dataSizeLabel.textColor                    = [UIColor colorFromString:[[SNThemeManager sharedThemeManager] currentThemeValueForKey:kVideoDownloadCell_DataSizeTextColor]];
            break;
        }
        case SNVideoDownloadState_Downloading: {
            if (self.model.downloadProgress == 0) {
                self.dataSizeLabel.text = @"离线中 0%";
            }
            else {
                self.dataSizeLabel.text = [NSString stringWithFormat:@"离线中 %.2f%%", self.model.downloadProgress*100];
            }

            self.dataSizeLabel.textColor                    = [UIColor colorFromString:[[SNThemeManager sharedThemeManager] currentThemeValueForKey:kVideoDownloadCell_DataSizeTextColor]];
            break;
        }
        case SNVideoDownloadState_Pause: {
//            if (self.model.downloadProgress == 0) {
//                self.dataSizeLabel.text = @"暂停 0%";
//            }
//            else {
//                self.dataSizeLabel.text = [NSString stringWithFormat:@"暂停 %.2f%%", self.model.downloadProgress*100];
//            }
            self.dataSizeLabel.text = @"暂停";
            
            self.dataSizeLabel.textColor                    = [UIColor colorFromString:[[SNThemeManager sharedThemeManager] currentThemeValueForKey:kVideoDownloadCell_DataSizeTextColor]];
            break;
        }
        case SNVideoDownloadState_Canceled: {
            self.dataSizeLabel.textColor                    = [UIColor colorFromString:[[SNThemeManager sharedThemeManager] currentThemeValueForKey:kVideoDownloadCell_DataSizeTextColor]];
            break;
        }
        case SNVideoDownloadState_Failed: {
            self.dataSizeLabel.text = @"下载失败";
            self.dataSizeLabel.textColor                    = [UIColor colorFromString:[[SNThemeManager sharedThemeManager] currentThemeValueForKey:kVideoDownloadCell_DataSizeRedTextColor]];
            break;
        }
        case SNVideoDownloadState_Successful: {
            self.dataSizeLabel.textColor                    = [UIColor colorFromString:[[SNThemeManager sharedThemeManager] currentThemeValueForKey:kVideoDownloadCell_DataSizeTextColor]];
            break;
        }
    }
}

- (void)updateActionBtn {
    switch (self.model.state) {
        case SNVideoDownloadState_Waiting: {
            [self.actionBtn setBackgroundImage:[UIImage imageNamed:@"video_download_pause_normal.png"] forState:UIControlStateNormal];
            [self.actionBtn setBackgroundImage:[UIImage imageNamed:@"video_download_pause_press.png"] forState:UIControlStateHighlighted];
            break;
        }
        case SNVideoDownloadState_Downloading: {
            [self.actionBtn setBackgroundImage:[UIImage imageNamed:@"video_download_pause_normal.png"] forState:UIControlStateNormal];
            [self.actionBtn setBackgroundImage:[UIImage imageNamed:@"video_download_pause_press.png"] forState:UIControlStateHighlighted];
            break;
        }
        case SNVideoDownloadState_Pause: {
            [self.actionBtn setBackgroundImage:[UIImage imageNamed:@"video_download_resume_normal.png"] forState:UIControlStateNormal];
            [self.actionBtn setBackgroundImage:[UIImage imageNamed:@"video_download_resume_press.png"] forState:UIControlStateHighlighted];
            break;
        }
        case SNVideoDownloadState_Canceled: {
            //Do nothing
            break;
        }
        case SNVideoDownloadState_Failed: {
            [self.actionBtn setBackgroundImage:[UIImage imageNamed:@"video_download_retry_normal.png"] forState:UIControlStateNormal];
            [self.actionBtn setBackgroundImage:[UIImage imageNamed:@"video_download_retry_press.png"] forState:UIControlStateHighlighted];
            break;
        }
        case SNVideoDownloadState_Successful: {
            //Do nothing
            break;
        }
    }
}

- (void)tapActionBtn:(UIButton *)btn {
    SNDebugLog(@"Tap.......");
    switch (self.model.state) {
        case SNVideoDownloadState_Waiting: {
            //Pause downloading item
            [[SNVideoDownloadManager sharedInstance] pauseDownloadingVideo:self.model];
            [self updateActionBtn];
            [self updateDataSizeLabelText];
            break;
        }
        case SNVideoDownloadState_Downloading: {
            //Pause downloading item
            [[SNVideoDownloadManager sharedInstance] pauseDownloadingVideo:self.model];
            [self updateActionBtn];
            [self updateDataSizeLabelText];
            break;
        }
        case SNVideoDownloadState_Pause: {
            //Resume downloading item
            [[SNVideoDownloadManager sharedInstance] resumeDownloadingVideo:self.model];
            [self updateActionBtn];
            [self updateDataSizeLabelText];
            break;
        }
        case SNVideoDownloadState_Canceled: {
            //Do nothing
            break;
        }
        case SNVideoDownloadState_Failed: {
            //Retry item
            [[SNVideoDownloadManager sharedInstance] retryDownloadingVideo:self.model];
            [self updateActionBtn];
            [self updateDataSizeLabelText];
            break;
        }
        case SNVideoDownloadState_Successful: {
            //Do nothing
            break;
        }
    }
}

@end
