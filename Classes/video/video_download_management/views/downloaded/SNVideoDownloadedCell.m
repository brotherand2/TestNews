//
//  SNVideoDownloadedCell.m
//  sohunews
//
//  Created by handy wang on 8/29/13.
//  Copyright (c) 2013 Sohu.com. All rights reserved.
//

#import "SNVideoDownloadedCell.h"

#define kDataSizeLabelMarginBottom                              (18.0f/2.0f)
#define kDataSizeLabelWidth                                     (100.0f)
#define kDataSizeLabelHeight                                    (13.0f)
#define kDataSizeLabelFontSize                                  (20.0f/2.0f)

#define kVideoIconSize                                          (20.0f)

@interface SNVideoDownloadedCell()
@property (nonatomic, strong)UILabel        *dataSizeLabel;
@property (nonatomic, strong)UIImageView    *videoIcon;
@end

@implementation SNVideoDownloadedCell


#pragma mark - Override
- (void)setData:(SNVideoDataDownload *)data {
    [super setData:data];
    
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
    self.dataSizeLabel.text                         = [[self class] formatStrForMediaSize:self.model.totalBytes];
    
    if (!(self.videoIcon)) {
        self.videoIcon = [[UIImageView alloc] initWithFrame:CGRectMake(self.thumnailImageView.right-kVideoIconSize,
                                                                        self.thumnailImageView.bottom-kVideoIconSize,
                                                                        kVideoIconSize,
                                                                        kVideoIconSize)];
        _videoIcon.image = [UIImage imageNamed:@"icohome_videosmall_v5.png"];
        [self.contentView addSubview:_videoIcon];
    }
    self.videoIcon.left = self.thumnailImageView.right-kVideoIconSize;
    self.contentView.alpha = themeImageAlphaValue();
}

- (void)beginEdit {
    [super beginEdit];
    self.videoIcon.left = self.thumnailImageView.right-kVideoIconSize;
    self.videoIcon.hidden = YES;
}

- (void)finishEdit {
    [super finishEdit];
    self.videoIcon.left = self.thumnailImageView.right-kVideoIconSize;
    self.videoIcon.hidden = NO;
}

#pragma mark - Utility method
+ (NSString *)formatStrForMediaSize:(unsigned long long)mediaSize {
    NSString *str = nil;
    if (mediaSize >= 1024 * 1024 * 1024) {
        str = [NSString stringWithFormat:@"%.1fGB", mediaSize/(1024.0f*1024.0f*1024.0f)];
    } else if (mediaSize >= 1024 * 1024) {
        str = [NSString stringWithFormat:@"%.1fMB", mediaSize/(1024.0f*1024.0f)];
    } else if (mediaSize >= 1024) {
        str = [NSString stringWithFormat:@"%.1fKB", mediaSize/1024.0f];
    } else if (mediaSize > 0) {
        str = [NSString stringWithFormat:@"%lluB", mediaSize];
    }
    return str;
}

@end
