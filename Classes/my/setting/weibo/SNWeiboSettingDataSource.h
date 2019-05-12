//
//  SNWeiboSettingDataSource.h
//  sohunews
//
//  Created by 李 雪 on 11-7-11.
//  Copyright 2011 Sohu.com Inc. All rights reserved.
//
@class SNWeiboSettingModel;
@interface SNWeiboSettingDataSource : TTListDataSource {
	SNWeiboSettingModel *_weiboSettingModel;
}

@property(nonatomic,strong)SNWeiboSettingModel *weiboSettingModel;


@end
