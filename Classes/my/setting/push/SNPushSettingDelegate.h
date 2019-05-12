//
//  SNPushSettingDelegate.h
//  sohunews
//
//  Created by 李 雪 on 11-7-1.
//  Copyright 2011 Sohu.com Inc. All rights reserved.
//

@class SNPushSettingController;
@class SNPushSettingModel;
@interface SNPushSettingDelegate : TTTableViewDelegate {
	SNPushSettingController *__weak _pushSettingController;
	SNPushSettingModel		*_model;
}

@property(nonatomic,weak)SNPushSettingController	*pushSettingController;
@property(nonatomic,strong)SNPushSettingModel		*model;

@end
