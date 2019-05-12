//
//  SNPushSettingDataSource.h
//  sohunews
//
//  Created by 李 雪 on 11-7-1.
//  Copyright 2011 Sohu.com Inc. All rights reserved.
//
//  bate 2.20
//@class SNPushSettingModel;
//SNPushSettingModel *_pushSettingModel;
//@property(nonatomic,retain)SNPushSettingModel *pushSettingModel;
//=====================//
@class SNPushSettingController;
@interface SNPushSettingDataSource : TTSectionedDataSource {
    NSString *_strNewsTitle;
    
    SNPushSettingController *__weak _pushViewController;
}
@property (nonatomic, copy)NSString *strNewsTitle;
@property(nonatomic,weak)SNPushSettingController *pushViewController;

@end
