//
//  SNSubscribeNewsTableViewDelegate.m
//  sohunews
//
//  Created by lhp on 10/13/14.
//  Copyright (c) 2014 Sohu.com. All rights reserved.
//

#import "SNSubscribeNewsTableViewDelegate.h"
#import "SNSubscribeNewsModel.h"
#import "SNRollingNewsMySubscribeCell.h"

@implementation SNSubscribeNewsTableViewDelegate

- (BOOL)isModelEmpty
{
    SNSubscribeNewsModel *subscribeModel = (SNSubscribeNewsModel *)_model;
    return [subscribeModel isEmpty];
}

- (NSTimeInterval)refreshIntervalWithDefault:(NSTimeInterval)interval
{
    return interval;
}

- (BOOL)shouldReloadLocalWithChannelId:(NSString *)channelId
{
    SNSubscribeNewsModel *subscribeModel = (SNSubscribeNewsModel *)_model;
    if (![subscribeModel.channelId isEqualToString:channelId]) {
        return YES;
    }
//    else if (subscribeModel.subscribeArray.count == 0){
//        return YES;
//    }
    return NO;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [super tableView:tableView didSelectRowAtIndexPath:indexPath];
    SNRollingNewsMySubscribeCell * cell = [tableView cellForRowAtIndexPath:indexPath];
    if ([cell isKindOfClass:[SNRollingNewsMySubscribeCell class]]) {
        SNSubscribeNewsModel *subscribeModel = (SNSubscribeNewsModel *)_model;
        if ([subscribeModel respondsToSelector:@selector(saveSubObject:)]) {
            [subscribeModel saveSubObject:cell.subscribeItem.subscribeObject];
        }
    }
}

@end
