//
//  SNHotTableDelegate.m
//  sohunews
//
//  Created by ivan on 3/7/12.
//  Copyright (c) 2012 Sohu.com Inc. All rights reserved.
//

#import "CacheObjects.h"
#import "SNPhotoTableDelegate.h"
#import "SNPhotoModel.h"
#import "SNPhotosTableController.h"

@implementation SNPhotoTableDelegate

- (BOOL)shouldReload
{
    NSString *timeKey = [NSString stringWithFormat:@"group_photo_%@_%@_refresh_time", ((SNPhotoModel *)_model).targetType, ((SNPhotoModel *)_model).typeId];
    id data = [[NSUserDefaults standardUserDefaults] objectForKey:timeKey];
    if (data && [data isKindOfClass:[NSDate class]]) {
        return [(NSDate *)[data dateByAddingTimeInterval:kChannelNewsRefreshInterval] compare:[NSDate date]] < 0;
    } else {
        return YES;
    }
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    [((SNPhotosTableController *)_controller).tabBar showShadow:YES];
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    [((SNPhotosTableController *)_controller).tabBar showShadow:NO];
    [[NSNotificationCenter defaultCenter] postNotificationName:kTipsViewRefreshNotification object:nil];
}

@end
