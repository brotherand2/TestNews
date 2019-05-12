//
//  SNPushSettingSectionInfo.h
//  sohunews
//
//  Created by 李 雪 on 11-7-5.
//  Copyright 2011 Sohu.com Inc. All rights reserved.
//

@interface SNPushSettingSectionInfo : NSObject {
	NSString *_name;
	NSMutableArray	*_settingItems;
}

@property(nonatomic,strong)NSString *name;
@property(nonatomic,strong)NSMutableArray *settingItems;

@end
