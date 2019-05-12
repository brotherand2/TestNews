//
//  SNDownloadingSubCell.m
//  sohunews
//
//  Created by handy wang on 1/17/13.
//  Copyright (c) 2013 Sohu.com Inc. All rights reserved.
//

#import "SNDownloadingSubCell.h"
#import "CacheObjects.h"

@implementation SNDownloadingSubCell

#pragma mark - Override

- (void)layoutSubviews {
    [super layoutSubviews];
    
    if ([self.data isKindOfClass:[SCSubscribeObject class]]) {
        SCSubscribeObject *_scSub = (SCSubscribeObject *)(self.data);
        
        //Title
        self.titleLabel.text = (!!(_scSub.termName) && ![@"" isEqualToString:_scSub.termName]) ? _scSub.termName : _scSub.subName;
        
        //Downloading indicator
        if (_scSub.downloadStatus == SNDownloadRunning) {
            [self.downloadingIndicator startAnimation];
            self.finishMark.hidden = YES;
            self.cancelBtn.hidden = NO;
            self.retryBtn.hidden = YES;
        }
        else {
            [self.downloadingIndicator stopAnimation];
            
            if (_scSub.downloadStatus == SNDownloadWait) {
                self.finishMark.hidden = YES;
                self.cancelBtn.hidden = NO;
                self.retryBtn.hidden = YES;
            }
            else if (_scSub.downloadStatus == SNDownloadSuccess) {
                self.finishMark.hidden = NO;
                self.cancelBtn.hidden = YES;
                self.retryBtn.hidden = YES;
            }
            else if (_scSub.downloadStatus == SNDownloadFail) {
                self.finishMark.hidden = YES;
                self.cancelBtn.hidden = NO;
                self.retryBtn.hidden = NO;
            }
        }
    }
}

@end
