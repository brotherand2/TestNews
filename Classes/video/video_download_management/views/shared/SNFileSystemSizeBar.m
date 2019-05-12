//
//  SNFileSystemSizeBar.m
//  sohunews
//
//  Created by handy wang on 10/12/13.
//  Copyright (c) 2013 Sohu.com. All rights reserved.
//

#import "SNFileSystemSizeBar.h"
#import "UIColor+ColorUtils.h"

#define kProgressBarHeight                                      (4/2.0f)
#define kTextLabelFontSize                                      (20/2.0f)

@interface SNFileSystemSizeBar()
@property (nonatomic, strong)UILabel            *textLabel;
@property (nonatomic, strong)UILabel            *freeSizeLabel;
@property (nonatomic, strong)UILabel            *totalSizeLabel;
@end

@implementation SNFileSystemSizeBar

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {

        self.backgroundColor                    = [UIColor colorFromString:[[SNThemeManager sharedThemeManager] currentThemeValueForKey:kVideoDownloadFileSystemSizeBarBgColor]];
        
        self.textLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.width, self.height-kProgressBarHeight)];
        self.textLabel.textAlignment = NSTextAlignmentCenter;
        self.textLabel.textColor = [UIColor colorFromString:[[SNThemeManager sharedThemeManager] currentThemeValueForKey:kVideoDownloadFileSystemSizeBarTextColor]];
        self.textLabel.font = [UIFont systemFontOfSize:kTextLabelFontSize];
        self.textLabel.backgroundColor = [UIColor clearColor];
        [self addSubview:self.textLabel];
        
        self.totalSizeLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, self.textLabel.bottom, self.width, kProgressBarHeight)];
        self.totalSizeLabel.backgroundColor = [UIColor colorFromString:[[SNThemeManager sharedThemeManager] currentThemeValueForKey:kVideoDownloadFileSystemSizeBarTotalColor]];
        [self addSubview:self.totalSizeLabel];

        self.freeSizeLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, self.textLabel.bottom, 0, kProgressBarHeight)];
        self.freeSizeLabel.backgroundColor = [UIColor colorFromString:[[SNThemeManager sharedThemeManager] currentThemeValueForKey:kVideoDownloadFileSystemSizeBarFreeColor]];
        [self addSubview:self.freeSizeLabel];
        
        [SNNotificationManager addObserver:self selector:@selector(updateTheme) name:kThemeDidChangeNotification object:nil];
    }
    return self;
}

- (void)dealloc {
    
    [SNNotificationManager removeObserver:self];
    
}

#pragma mark - Public
- (void)update:(unsigned long long)diskFreeSizeInBytes downloadedVideosInBytes:(unsigned long long)downloadedVideosInBytes {
    NSString *diskFreeBytesText = [SNUtility formatStrForMediaSize:diskFreeSizeInBytes];
    if (diskFreeBytesText.length <= 0) {
        diskFreeBytesText = @"0B";
    }
    
    NSString *downloadedVideosBytesText = [SNUtility formatStrForMediaSize:downloadedVideosInBytes];
    if (downloadedVideosBytesText.length <= 0) {
        downloadedVideosBytesText = @"0B";
    }
    
    NSString *_text = [NSString stringWithFormat:@"已离线%@，剩余%@可用", downloadedVideosBytesText, diskFreeBytesText];
    self.textLabel.text = _text;
    
    if (diskFreeSizeInBytes > 0) {
        CGFloat _progress = downloadedVideosInBytes*1.0/diskFreeSizeInBytes*1.0;
        self.freeSizeLabel.width = self.width * _progress;
    }
}

- (void)updateTheme {
    self.backgroundColor = SNUICOLOR(kVideoDownloadFileSystemSizeBarBgColor);
    self.textLabel.textColor = SNUICOLOR(kVideoDownloadFileSystemSizeBarTextColor);
    self.totalSizeLabel.backgroundColor = SNUICOLOR(kVideoDownloadFileSystemSizeBarTotalColor);
    self.freeSizeLabel.backgroundColor = SNUICOLOR(kVideoDownloadFileSystemSizeBarFreeColor);
}

@end
