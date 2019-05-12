//
//  SNDownloadSettingNewsCell.m
//  sohunews
//
//  Created by handy wang on 1/17/13.
//  Copyright (c) 2013 Sohu.com Inc. All rights reserved.
//

#import "SNDownloadSettingNewsCell.h"
#import "CacheObjects.h"

@implementation SNDownloadSettingNewsCell

- (void)reverseSelectedState {
    if ([self.data isKindOfClass:[NewsChannelItem class]]) {
        __block NSString *_isSelectedString = nil;
        NewsChannelItem *_newChannelItem = (NewsChannelItem *)(self.data);
        if ([_newChannelItem.isSelected isEqualToString:kDownloadSettingItemSelected]) {
            _isSelectedString = kDownloadSettingItemUnselected;
        } else {
            _isSelectedString = kDownloadSettingItemSelected;
        }
        _newChannelItem.isSelected = _isSelectedString;
        if ([_newChannelItem.isSelected isEqualToString:kDownloadSettingItemSelected]) {
            [self.checkMarkBtn setHidden:NO];
        } else {
            [self.checkMarkBtn setHidden:YES];
        }
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            BOOL _rst = [[SNDBManager currentDataBase] updateNewsChannelIsSelected:_isSelectedString channelID:_newChannelItem.channelId];
            dispatch_async(dispatch_get_main_queue(), ^{
                if (!_rst) {
                    if ([_newChannelItem.isSelected isEqualToString:kDownloadSettingItemSelected]) {
                        _isSelectedString = kDownloadSettingItemUnselected;
                    } else {
                        _isSelectedString = kDownloadSettingItemSelected;
                    }
                    _newChannelItem.isSelected = _isSelectedString;
                    if ([_newChannelItem.isSelected isEqualToString:kDownloadSettingItemSelected]) {
                        [self.checkMarkBtn setHidden:NO];
                    } else {
                        [self.checkMarkBtn setHidden:YES];
                    }
                }
            });
        });
    }
}


- (void)layoutSubviews {
    [super layoutSubviews];
    
    if ([self.data isKindOfClass:[NewsChannelItem class]]) {
        NewsChannelItem *_newsChannelItem = (NewsChannelItem *)(self.data);
        self.titleLabel.text = _newsChannelItem.channelName;
        
        if ([_newsChannelItem.isSelected isEqualToString:@"1"]) {
            [self.checkMarkBtn setHidden:NO];
        } else {
            [self.checkMarkBtn setHidden:YES];
        }
    }
}

@end
