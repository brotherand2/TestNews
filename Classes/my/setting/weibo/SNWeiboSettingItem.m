//
//  SNWeiboSettingItem.m
//  sohunews
//
//  Created by 李 雪 on 11-7-11.
//  Copyright 2011 Sohu.com Inc. All rights reserved.
//

#import "SNWeiboSettingItem.h"


@implementation SNWeiboSettingItem
//@synthesize weiboPlatform=_weiboPlatform;
//@synthesize platformName=_platformName;
//@synthesize bindedUserName=_bindedUserName;
//@synthesize bBinded=_bBinded;
@synthesize imgIcon = _imgIcon;
@synthesize shareListItem = _shareListItem;
@synthesize controller = _controller;

-(void)dealloc
{
//	 //(_platformName);
//	 //(_bindedUserName);
     //(_imgIcon);
     //(_shareListItem);
    _controller = nil;
}

@end
