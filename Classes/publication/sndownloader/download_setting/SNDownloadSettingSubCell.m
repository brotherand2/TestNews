//
//  SNDownloadSettingSubCell.m
//  sohunews
//
//  Created by handy wang on 1/17/13.
//  Copyright (c) 2013 Sohu.com Inc. All rights reserved.
//

#import "CacheObjects.h"
#import "SNDownloadSettingSubCell.h"
#import "SNDatabase_NewsChannel.h"
#import "SNSubDownloadManager.h"

@implementation SNDownloadSettingSubCell

-(NSString*)reverseItem:(SCSubscribeObject*)_scSub
{
    NSString *_isSelectedString = nil;
    if ([_scSub.isSelected isEqualToString:kDownloadSettingItemSelected]) {
        _isSelectedString = kDownloadSettingItemUnselected;
    } else {
        _isSelectedString = kDownloadSettingItemSelected;
    }
    _scSub.isSelected = _isSelectedString;
    if ([_scSub.isSelected isEqualToString:kDownloadSettingItemSelected]) {
        [self.checkMarkBtn setHidden:NO];
    } else {
        [self.checkMarkBtn setHidden:YES];
    }
    return _isSelectedString;
}

-(void)reverseSelectedState
{
    //先改内存数据和UI, 再更新数据库，如果更新数据库失败则恢复到反面状态
    if ([self.data isKindOfClass:[SCSubscribeObject class]])
    {    
        SCSubscribeObject *_scSub = (SCSubscribeObject *)(self.data);
        NSString *_isSelectedString = [self reverseItem:_scSub];
        
        //如果是订阅的频道,则既要更新订阅数据库，又要更新频道数据库
        if(_scSub!=nil && _scSub.link!=nil)
        {
            NSString* channelId = [SNSubDownloadManager channelFromProtocol:_scSub.link type:nil];
            if(channelId!=nil && [channelId length]>0)
            {
                [self reverseSelectedStateNews:_scSub isSelectedString:_isSelectedString channelId:channelId];
            }
        }

        //默认是订阅
        [self reverseSelectedStateSub:_scSub isSelectedString:_isSelectedString];
    }
}

- (void)reverseSelectedStateSub:(SCSubscribeObject*)_scSub isSelectedString:(NSString*)isSelectedString
{
    //先改内存数据和UI, 再更新数据库，如果更新数据库失败则恢复到反面状态
    if ([self.data isKindOfClass:[SCSubscribeObject class]]) {
        __weak NSString *_isSelectedString = isSelectedString;

        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            BOOL _rst = [[SNDBManager currentDataBase] updateSubscribeCenterSubscribeObjectBySubId:_scSub.subId
                         withValuePairs:[NSDictionary dictionaryWithObject:_isSelectedString forKey:TB_SUB_CENTER_ALL_SUB_ISSELECTED]];
            
            dispatch_async(dispatch_get_main_queue(), ^{
                if(!_rst)
                    [self reverseItem:_scSub];
            });
        });
    }
}

- (void)reverseSelectedStateNews:(SCSubscribeObject*)_scSub isSelectedString:(NSString*)isSelectedString channelId:(NSString*)aChannelId
{
    if ([self.data isKindOfClass:[SCSubscribeObject class]]) {
        __weak NSString *_isSelectedString = isSelectedString;
        
        NewsChannelItem* _newChannelItem = [[SNDBManager currentDataBase] getChannelById:aChannelId];
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            BOOL _rst = [[SNDBManager currentDataBase] updateNewsChannelIsSelected:_isSelectedString channelID:_newChannelItem.channelId];
            dispatch_async(dispatch_get_main_queue(), ^{
                if(!_rst)
                    [self reverseItem:_scSub];
            });
        });
    }
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    if ([self.data isKindOfClass:[SCSubscribeObject class]]) {
        SCSubscribeObject *_scSub = (SCSubscribeObject *)(self.data);
        self.titleLabel.text = _scSub.subName;

        if ([_scSub.isSelected isEqualToString:@"1"]) {
            [self.checkMarkBtn setHidden:NO];
        } else {
            [self.checkMarkBtn setHidden:YES];
        }
    }
}

@end
