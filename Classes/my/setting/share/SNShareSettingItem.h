//
//  SNShareSettingItem.h
//  sohunews
//
//  Created by 李 雪 on 11-7-11.
//  Copyright 2011 Sohu.com Inc. All rights reserved.
//

#import "SNShareSettingController.h"
@interface SNShareSettingItem : NSObject {
//	WeiboPlatform _weiboPlatform;
//	NSString *_platformName;
//	NSString *_bindedUserName;
//	bool	_bBinded;
    UIImage *_imgIcon;
    ShareListItem *_shareListItem;
	SNShareSettingController *__weak _controller;
}

//@property(nonatomic,assign)WeiboPlatform weiboPlatform;
//@property(nonatomic,retain)NSString *platformName;
//@property(nonatomic,retain)NSString *bindedUserName;
//@property(nonatomic,assign)bool	bBinded;
//
@property (nonatomic,strong)UIImage *imgIcon;
@property(nonatomic, strong)ShareListItem *shareListItem;
@property(nonatomic, weak)SNShareSettingController *controller;
@end
