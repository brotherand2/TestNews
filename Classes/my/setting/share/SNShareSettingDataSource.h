//
//  SNShareSettingDataSource.h
//  sohunews
//
//  Created by 李 雪 on 11-7-11.
//  Copyright 2011 Sohu.com Inc. All rights reserved.
//
@class SNShareSettingModel;
@interface SNShareSettingDataSource : TTListDataSource {
	SNShareSettingModel *_weiboSettingModel;
}

@property(nonatomic,strong)SNShareSettingModel *weiboSettingModel;


@end
