//
//  SNDownloadingNewsCell.m
//  sohunews
//
//  Created by handy wang on 1/17/13.
//  Copyright (c) 2013 Sohu.com Inc. All rights reserved.
//

#import "SNDownloadingNewsCell.h"
#import "CacheObjects.h"

@implementation SNDownloadingNewsCell

#pragma mark - Override

- (void)layoutSubviews {
    [super layoutSubviews];
    
    if ([self.data isKindOfClass:[NewsChannelItem class]]) {
        NewsChannelItem *_newsChannelItem = (NewsChannelItem *)(self.data);
        
        //Title
        self.titleLabel.text = _newsChannelItem.channelName;
        
        //Downloading indicator
        if (_newsChannelItem.downloadStatus == SNDownloadRunning) {
            [self.downloadingIndicator startAnimation];
            self.finishMark.hidden = YES;
            self.cancelBtn.hidden = NO;
            self.retryBtn.hidden = YES;
        }
        else {
            [self.downloadingIndicator stopAnimation];
            
            if (_newsChannelItem.downloadStatus == SNDownloadWait) {
                self.finishMark.hidden = YES;
                self.cancelBtn.hidden = NO;
                self.retryBtn.hidden = YES;
            }
            else if (_newsChannelItem.downloadStatus == SNDownloadSuccess) {
                self.finishMark.hidden = NO;
                self.cancelBtn.hidden = YES;
                self.retryBtn.hidden = YES;
            }
            else if (_newsChannelItem.downloadStatus == SNDownloadFail) {
                self.finishMark.hidden = YES;
                self.cancelBtn.hidden = NO;
                self.retryBtn.hidden = NO;
            }
        }
    }
}

@end