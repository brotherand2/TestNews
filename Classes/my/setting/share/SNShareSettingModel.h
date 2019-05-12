//
//  SNShareSettingModel.h
//  sohunews
//
//  Created by 李 雪 on 11-7-11.
//  Copyright 2011 Sohu.com Inc. All rights reserved.
//

@class SNShareSettingController;
@interface SNShareSettingModel : TTModel
@property (nonatomic, weak) SNShareSettingController *controller;
@property (nonatomic, strong) NSMutableArray *shareSettingItems;
@end
