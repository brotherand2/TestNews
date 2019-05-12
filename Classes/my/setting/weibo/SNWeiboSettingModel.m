//
//  SNWeiboSettingModel.m
//  sohunews
//
//  Created by 李 雪 on 11-7-11.
//  Copyright 2011 Sohu.com Inc. All rights reserved.
//

#import "SNWeiboSettingModel.h"
#import "SNWeiboSettingItem.h"
#import "SNShareManager.h"

@interface SNWeiboSettingModel(Private)
-(void)loadWeiboSettingInfo;
@end


@implementation SNWeiboSettingModel
@synthesize controller=_controller;
@synthesize weiboSettingItems=_weiboSettingItems;

-(NSMutableArray*)weiboSettingItems
{
	if (_weiboSettingItems == nil) {
		_weiboSettingItems = [[NSMutableArray alloc] init];
	}
	
	return _weiboSettingItems;
}

-(BOOL)isLoaded
{
	return !![self.weiboSettingItems count];
}

- (void)load:(TTURLRequestCachePolicy)cachePolicy more:(BOOL)more {
    if (!self.isLoading) {
		[self.weiboSettingItems removeAllObjects];
		[self loadWeiboSettingInfo];
    }
}

-(void)loadWeiboSettingInfo
{

    
    for (ShareListItem *shareItem in [[SNShareManager defaultManager] shareList]) {
        SNWeiboSettingItem *item = [[SNWeiboSettingItem alloc] init];
        item.shareListItem = shareItem;
        item.controller = self.controller;
        NSString *iconName = [SNShareList iconNameByItem:shareItem];
        item.imgIcon = [UIImage imageNamed:iconName];
        [self.weiboSettingItems addObject:item];
    }
	
	[self didFinishLoad];
}


@end
