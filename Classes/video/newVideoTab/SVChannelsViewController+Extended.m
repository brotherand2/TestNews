//
//  SVChannelsViewController+Extended.m
//  sohunews
//
//  Created by tt on 15/12/17.
//  Copyright © 2015年 Sohu.com. All rights reserved.
//

#import "SVChannelsViewController+Extended.h"

@implementation SVChannelsViewController(Extended)
#pragma mark - tabbar icon
- (NSArray *)iconNames {
    return [NSArray arrayWithObjects:@"icotab_video_v5.png", @"icotab_videopress_v5.png", nil];
}

- (NSString *)tabItemText {
    if ([SNUtility getTabBarName:1]) {
        return [SNUtility getTabBarName:1];
    }
    return NSLocalizedString(@"videoTabbarName", nil);
}


@end
