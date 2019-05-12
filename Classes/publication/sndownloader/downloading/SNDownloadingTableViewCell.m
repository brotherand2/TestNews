//
//  FKDownloadingTableViewCellCell.m
//  FK
//
//  Created by handy wang on 6/8/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "SNDownloadingTableViewCell.h"
#import "CacheObjects.h"
#import "UIColor+ColorUtils.h"
#import "SNWebImageView.h"
#import "SNDownloadingWaitingView.h"
#import "SNDownloadingStatusLabel.h"
#import "SNDownloadManager.h"

#define SELF_NAME_LABEL_TAG                             (1)
#define SELF_PROGRESS_VIEW_TAG                          (2)
#define SELF_THUMBNAIL_FRAME_TAG                        (3)
#define SELF_THUMBNAIL_TAG                              (4)
#define SELF_TIMELABEL_TAG                              (5)
#define SELF_DOWNLOADINGWAITINGVIEW_TAG                 (6)
#define SELF_STATUSLABEL_TAG                            (7)

#define SELF_THUMBNAIL_FRAME_X                          (15/2.0f)
#define SELF_THUMBNAIL_FRAME_WIDTH                      (110/2.0f)
#define SELF_THUMBNAIL_FRAME_HEIGHT                     (110/2.0f)

#define SELF_THUMBNAIL_X                                (20/2.0f)
#define SELF_THUMBNAIL_WIDTH                            (96.0/2)
#define SELF_THUMBNAIL_HEIGHT                           (96.0/2)

#define SELF_NAMELABEL_PADDING_LEFT                     (24/2.0f)
#define SELF_NAMELABEL_OFFSET_THUMBNAILFRAME_Y          (28/2.0f)
#define SELF_NAMELABEL_WIDTH                            (150.0f)
#define SELF_NAMELABEL_HEIGHT                           (30/2.0f)
#define SELF_NAMELABEL_FONTSIZE                         (28/2.0f)

#define SELF_TIMELABEL_OFFSET_NAMELABEL_Y               (23/2.0)
#define SELF_TIMELABEL_WIDTH                            (100.0f)
#define SELF_TIMELABEL_HEIGHT                           (18.0f/2.0f)
#define SELF_TIMELABEL_FONTSIZE                         (16.0f/2.0f)

#define SELF_STATUSLABEL_WIDTH                          (80.0f)
#define SELF_STATUSLABEL_HEIGHT                         (60/2.0f)

#define SELF_MARGIN_RIGHT                               (10/2.0f)

@implementation SNDownloadingTableViewCell

@synthesize downloadingItem = _downloadingItem;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self setSelectionStyle:UITableViewCellSelectionStyleNone];
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    SubscribeHomeMySubscribePO *_tmpPO = nil;
    if ([_downloadingItem isKindOfClass:[SubscribeHomeMySubscribePO class]]) {
        _tmpPO = _downloadingItem;
    }
    
    //Thumbnail frame
    UIImageView *_thumbNailFrame = (UIImageView *)[self viewWithTag:SELF_THUMBNAIL_FRAME_TAG];
    if (!_thumbNailFrame) {
        _thumbNailFrame = [[UIImageView alloc] initWithFrame:CGRectMake(SELF_THUMBNAIL_FRAME_X, 
                                                                        (self.frame.size.height-SELF_THUMBNAIL_FRAME_HEIGHT)/2.0f, 
                                                                        SELF_THUMBNAIL_FRAME_WIDTH, 
                                                                        SELF_THUMBNAIL_FRAME_HEIGHT)];
        _thumbNailFrame.backgroundColor = [UIColor clearColor];
        _thumbNailFrame.image = [UIImage imageNamed:@"subcenter_allsub_sub_bgn.png"];
        _thumbNailFrame.tag = SELF_THUMBNAIL_FRAME_TAG;
        [self addSubview:_thumbNailFrame];
    }
    
    //Thumbnail
    SNWebImageView *_thumbNail = (SNWebImageView *)[_thumbNailFrame viewWithTag:SELF_THUMBNAIL_TAG];
    if (!_thumbNail) {
        _thumbNail = [[SNWebImageView alloc] initWithFrame:CGRectMake((_thumbNailFrame.frame.size.width-SELF_THUMBNAIL_WIDTH)/2.0f,
                                                                            (_thumbNailFrame.frame.size.height - SELF_THUMBNAIL_HEIGHT) / 2.0f, 
                                                                            SELF_THUMBNAIL_WIDTH, 
                                                                            SELF_THUMBNAIL_HEIGHT)];
        _thumbNail.backgroundColor = [UIColor clearColor];
        _thumbNail.defaultImage = [UIImage imageNamed:@"defaulticon.png"];
        _thumbNail.tag = SELF_THUMBNAIL_TAG;
        _thumbNail.alpha = themeImageAlphaValue();
        [_thumbNailFrame addSubview:_thumbNail];
    }
    if (_tmpPO) {
        [_thumbNail unsetImage];
        _thumbNail.urlPath = _tmpPO.subIcon;
    }
    
    //Downloading waiting view
    SNDownloadingWaitingView *_downloadingWaitingView = (SNDownloadingWaitingView *)[self viewWithTag:SELF_DOWNLOADINGWAITINGVIEW_TAG];
    if (!_downloadingWaitingView) {
        _downloadingWaitingView = [[SNDownloadingWaitingView alloc] initWithFrame:CGRectMake(3, 
                                                                                             3,
                                                                                             _thumbNailFrame.bounds.size.width-6,
                                                                                             _thumbNailFrame.bounds.size.height-6)];
        _downloadingWaitingView.layer.cornerRadius = 3.0f;
        _downloadingWaitingView.tag = SELF_DOWNLOADINGWAITINGVIEW_TAG;
        [_thumbNailFrame addSubview:_downloadingWaitingView];
    }
    if (_tmpPO) {
//        SNDebugLog(SN_String("INFO: ++++++++++++++++++++++++++++++%@, %d"), _tmpPO, _tmpPO.downloadStatus);
        [_downloadingWaitingView setDownloadStatus:_tmpPO.downloadStatus];
        if (_tmpPO.downloadStatus == SNDownloadRunning || _tmpPO.downloadStatus == SNDownloadFail) {
            [_downloadingWaitingView updateProgress:[_tmpPO.tmpProgress floatValue] animated:NO];
        }
    }
    
    //Name label
    UILabel *_nameLabel = (UILabel *)[self viewWithTag:SELF_NAME_LABEL_TAG];
    if (!_nameLabel) {
        CGRect _nameLabelFrame = CGRectMake(_thumbNailFrame.frame.origin.x+_thumbNailFrame.frame.size.width+SELF_NAMELABEL_PADDING_LEFT,
                                            _thumbNailFrame.frame.origin.y+SELF_NAMELABEL_OFFSET_THUMBNAILFRAME_Y, 
                                            SELF_NAMELABEL_WIDTH, 
                                            SELF_NAMELABEL_HEIGHT);
        _nameLabel = [[UILabel alloc] initWithFrame:_nameLabelFrame];
        _nameLabel.backgroundColor = [UIColor clearColor];
        _nameLabel.tag = SELF_NAME_LABEL_TAG;
        [_nameLabel setFont:[UIFont systemFontOfSize:SELF_NAMELABEL_FONTSIZE]];
        [_nameLabel setLineBreakMode:NSLineBreakByTruncatingTail];
        [_nameLabel setNumberOfLines:1];
        UIColor *_nameLabelTextColor = [UIColor colorFromString:
                                                       [[SNThemeManager sharedThemeManager] currentThemeValueForKey:kDownloadingCellTitleColor]];
        [_nameLabel setTextColor:_nameLabelTextColor];
        [self addSubview:_nameLabel];
    }
    if (_tmpPO) {
//        SNDebugLog(SN_String("INFO: %@--%@, \\\\\\ termName %@, subName %@, _nameLabel %@"), 
//                   NSStringFromClass(self.class), NSStringFromSelector(_cmd), _tmpPO.termName, _tmpPO.subName, _nameLabel);
        _nameLabel.hidden = NO;
        if (_tmpPO.termName && ![@"" isEqualToString:_tmpPO.termName]) {
            [_nameLabel setText:_tmpPO.termName];
        } else {
            [_nameLabel setText:_tmpPO.subName];
        }
    }
    
    //Term time
    UILabel *_timeLabel = (UILabel *)[self viewWithTag:SELF_TIMELABEL_TAG];
    if (!_timeLabel) {
        _timeLabel = [[UILabel alloc] initWithFrame:CGRectMake(_nameLabel.frame.origin.x,
                                                               _nameLabel.frame.origin.y+_nameLabel.frame.size.height+SELF_TIMELABEL_OFFSET_NAMELABEL_Y, 
                                                               SELF_TIMELABEL_WIDTH, 
                                                               SELF_TIMELABEL_HEIGHT)];
        _timeLabel.font = [UIFont systemFontOfSize:SELF_TIMELABEL_FONTSIZE];
        UIColor *_timeLabelTextColor = [UIColor colorFromString:
                                        [[SNThemeManager sharedThemeManager] currentThemeValueForKey:kDownloadingCellDatetimeColor]];
        _timeLabel.textColor = _timeLabelTextColor;
        _timeLabel.backgroundColor = [UIColor clearColor];
        _timeLabel.tag = SELF_TIMELABEL_TAG;
        [self addSubview:_timeLabel];
    }
    if (_tmpPO) {
        _timeLabel.text = _tmpPO.termTime;
    }
    
    //Status label
    SNDownloadingStatusLabel *_statusLabel = (SNDownloadingStatusLabel *)[self viewWithTag:SELF_STATUSLABEL_TAG];
    if (!_statusLabel) {
        _statusLabel = [[SNDownloadingStatusLabel alloc] initWithFrame:CGRectMake(self.frame.size.width-SELF_STATUSLABEL_WIDTH-SELF_MARGIN_RIGHT, 
                                                                                  (self.frame.size.height-SELF_STATUSLABEL_HEIGHT)/2.0f, 
                                                                                  SELF_STATUSLABEL_WIDTH, 
                                                                                  SELF_STATUSLABEL_HEIGHT) 
                                                           andDelegate:self];
        _statusLabel.tag = SELF_STATUSLABEL_TAG;
        _statusLabel.backgroundColor = [UIColor clearColor];
        [self addSubview:_statusLabel];
    }
    if (_tmpPO) {
        [_statusLabel setDownloadStatus:_tmpPO.downloadStatus];
        [_statusLabel setDelegate:self];
    }
}


#pragma mark - Public methods implementation

- (void)drawRect:(CGRect)rect {
	[super drawRect:rect];
	[UIView drawCellSeperateLine:rect];
	
}

- (void)updateProgress:(NSNumber *)progress {
    if (!progress) {
        return;
    }
    
    SNDownloadingWaitingView *_downloadingWaitingView = (SNDownloadingWaitingView *)[self viewWithTag:SELF_DOWNLOADINGWAITINGVIEW_TAG];
    if (!_downloadingWaitingView) {
        return;
    }
    _downloadingWaitingView.hidden = NO;
    [_downloadingWaitingView updateProgress:[progress floatValue] animated:YES];
    
    SNDownloadingStatusLabel *_statusLabel = (SNDownloadingStatusLabel *)[self viewWithTag:SELF_STATUSLABEL_TAG];
    if (_statusLabel) {
        [_statusLabel setDownloadStatus:SNDownloadRunning];
        [_statusLabel updateProgress:[progress floatValue] animated:YES];
    }
}

- (void)requestFailed {
    SNDownloadingWaitingView *_downloadingWaitingView = (SNDownloadingWaitingView *)[self viewWithTag:SELF_DOWNLOADINGWAITINGVIEW_TAG];
    if (_downloadingWaitingView) {
        [_downloadingWaitingView setDownloadStatus:SNDownloadFail];
    }
    
    SNDownloadingStatusLabel *_statusLabel = (SNDownloadingStatusLabel *)[self viewWithTag:SELF_STATUSLABEL_TAG];
    if (_statusLabel) {
        [_statusLabel setDownloadStatus:SNDownloadFail];
    }
}

- (void)requestFinished {
    SNDownloadingWaitingView *_downloadingWaitingView = (SNDownloadingWaitingView *)[self viewWithTag:SELF_DOWNLOADINGWAITINGVIEW_TAG];
    if (_downloadingWaitingView) {
        [_downloadingWaitingView setDownloadStatus:SNDownloadSuccess];
    }
    
    SNDownloadingStatusLabel *_statusLabel = (SNDownloadingStatusLabel *)[self viewWithTag:SELF_STATUSLABEL_TAG];
    if (_statusLabel) {
        [_statusLabel setDownloadStatus:SNDownloadSuccess];
    }
}

- (void)resetProgessBar {
    SNDownloadingWaitingView *_downloadingWaitingView = (SNDownloadingWaitingView *)[self viewWithTag:SELF_DOWNLOADINGWAITINGVIEW_TAG];
    if (_downloadingWaitingView) {
        [_downloadingWaitingView setDownloadStatus:SNDownloadWait];
    }
    
    SNDownloadingStatusLabel *_statusLabel = (SNDownloadingStatusLabel *)[self viewWithTag:SELF_STATUSLABEL_TAG];
    if (_statusLabel) {
        [_statusLabel setDownloadStatus:SNDownloadWait];
    }
}

#pragma mark - SNDownloadingStatusLabelDelegate

- (void)retryDownload {
    [[SNDownloadManager sharedInstance] retryDownloadWithItem:_downloadingItem];
}

- (void)cancelDownload {
    [[SNDownloadManager sharedInstance] cancelDownloadItem:_downloadingItem];
}

@end
