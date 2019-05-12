//
//  SNDownloadingStatusLabel.h
//  sohunews
//
//  Created by handy wang on 6/25/12.
//  Copyright (c) 2012 Sohu.com Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SNDownloadConfig.h"

@protocol SNDownloadingStatusLabelDelegate

- (void)retryDownload;

- (void)cancelDownload;

@end


@interface SNDownloadingStatusLabel : UILabel {
    id __weak _delegate;
    UILabel *_msgLabel;
    UIButton *_cancelBtn;
    UIButton *_retryBtn;
}

@property(nonatomic, weak)id delegate;

- (id)initWithFrame:(CGRect)frame andDelegate:(id)delegateParam;

- (void)setDownloadStatus:(SNDownloadStatus)downloadStatus;

- (void)updateProgress:(CGFloat)progressValue animated:(BOOL)animated;

@end
