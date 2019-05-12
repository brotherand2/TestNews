//
//  SNWeiboSettingItem.h
//  sohunews
//
//  Created by 李 雪 on 11-7-11.
//  Copyright 2011 Sohu.com Inc. All rights reserved.
//

#import "SNWeiboSettingController.h"
@interface SNWeiboSettingItem : NSObject {
//	WeiboPlatform _weiboPlatform;
//	NSString *_platformName;
//	NSString *_bindedUserName;
//	bool	_bBinded;
    UIImage *_imgIcon;
    ShareListItem *_shareListItem;
	SNWeiboSettingController *__weak _controller;
}

//@property(nonatomic,assign)WeiboPlatform weiboPlatform;
//@property(nonatomic,retain)NSString *platformName;
//@property(nonatomic,retain)NSString *bindedUserName;
//@property(nonatomic,assign)bool	bBinded;
//
@property (nonatomic,strong)UIImage *imgIcon;
@property(nonatomic, strong)ShareListItem *shareListItem;
@property(nonatomic, weak)SNWeiboSettingController *controller;
@end
