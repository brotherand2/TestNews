//
//  SNGroupPhotoNewsTableViewDelegate.m
//  sohunews
//
//  Created by chenhong on 14-3-11.
//  Copyright (c) 2014年 Sohu.com. All rights reserved.
//

#import "SNGroupPhotoNewsTableViewDelegate.h"
#import "SNRollingGroupPhotoModel.h"

@implementation SNGroupPhotoNewsTableViewDelegate

#pragma mark - override super methods
- (BOOL)isModelEmpty {
    SNRollingGroupPhotoModel *model = (SNRollingGroupPhotoModel *)_model;
    BOOL hasNoCache = model.allPhotos.count == 0;
    return hasNoCache;
}

- (BOOL)shouldReloadLocalWithChannelId:(NSString *)channelId {
    SNRollingGroupPhotoModel *model = (SNRollingGroupPhotoModel *)_model;
    if (![model.typeId isEqualToString:channelId]) {
        return YES;
    }
    else if (model.allPhotos.count == 0) {
        return YES;
    }
    return NO;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 0;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    return [super tableView:tableView viewForHeaderInSection:section];
}

#pragma mark -

@end
