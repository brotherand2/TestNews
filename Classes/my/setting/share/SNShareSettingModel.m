//
//  SNShareSettingModel.m
//  sohunews
//
//  Created by 李 雪 on 11-7-11.
//  Copyright 2011 Sohu.com Inc. All rights reserved.
//

#import "SNShareSettingModel.h"
#import "SNShareSettingItem.h"
#import "SNShareManager.h"
#import "SNUserManager.h"

@interface SNShareSettingModel(Private)
- (void)loadWeiboSettingInfo;
@end


@implementation SNShareSettingModel

- (NSMutableArray *)shareSettingItems {
	if (_shareSettingItems == nil) {
		_shareSettingItems = [[NSMutableArray alloc] init];
	}
	return _shareSettingItems;
}

- (BOOL)isLoaded {
	return !![self.shareSettingItems count];
}

- (void)load:(TTURLRequestCachePolicy)cachePolicy more:(BOOL)more {
    if (!self.isLoading) {
		[self.shareSettingItems removeAllObjects];
		[self loadWeiboSettingInfo];
    }
}

- (void)loadWeiboSettingInfo {
    if ([SNUserManager isLogin]) {
        for (ShareListItem *shareItem in
            [[SNShareManager defaultManager] shareList]) {
            SNShareSettingItem *item = [[SNShareSettingItem alloc] init];
            item.shareListItem = shareItem;
            item.controller = self.controller;
            NSString *iconName = [SNShareList iconNameByItem:shareItem];
            item.imgIcon = [UIImage imageNamed:iconName];
            [self.shareSettingItems addObject:item];
        }
    }
    [self didFinishLoad];
}

@end
