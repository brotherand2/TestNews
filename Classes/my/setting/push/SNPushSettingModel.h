//
//  SNPushSettingModel.h
//  sohunews
//
//  Created by 李 雪 on 11-7-1.
//  update by sampanli
//  Copyright 2011 Sohu.com Inc. All rights reserved.
//
#import "SNPushSwitcher.h"
#import "SNNovelPushSettingController.h"

@class SNPushSettingController;
@class PushSettingChangeItem;
@class PushSettingChangeRequestItem;
//@class SNURLRequest;
@class SNPushSettingItem;
@interface SNPushSettingModel : TTURLRequestModel {
	SNPushSettingController *__weak _controller;
	NSMutableArray	*_settingSections;
	NSMutableArray	*_requestAryForChangePushSetting;
//	SNURLRequest	*_requestForGetSrvPushSettings;
//    SNURLRequest    *_requestForNewsSetting;
    NSMutableDictionary *_dicSavePushData;
    BOOL _isSucessfull;
    BOOL        isAllOperation;
}

@property(nonatomic,weak)SNPushSettingController *controller;
@property(nonatomic,strong)NSMutableArray	*settingSections;
@property(nonatomic,strong)NSMutableArray	*requestAryForChangePushSetting;
@property(nonatomic,strong)NSMutableDictionary *_dicSavePushData;
@property(nonatomic,assign) BOOL isSucessfull;
@property(nonatomic,assign)BOOL isAllOperation;
@property(nonatomic,assign)SNNovelPushSettingController *novelSettingController;
@property(nonatomic,retain)NSMutableArray	*settingNovels;
- (void)changePushSetting:(BOOL)bASync data:(NSArray*)changeItems;
+ (SNPushSettingModel *)instance;
- (BOOL)loadPushSettingFromCache;

@end

/*
	//更改推送设置时用到的对象
 */
//
@interface PushSettingChangeItem : NSObject
{
	int			_nPushStatus;
	//UISwitch	*_switchCtl;
    SNPushSwitcher *_switcher;
    SNPushSettingItem *_settingItem;
}

//@property(nonatomic,retain)UISwitch	*switchCtl;
@property(nonatomic,strong)SNPushSwitcher *switcher;
@property(nonatomic,strong) SNPushSettingItem *settingItem;
@property(nonatomic,assign)int nPushStatus;


@end

//
@interface PushSettingChangeRequestItem : NSObject
{
	NSMutableArray	*_changeItems;
//	SNURLRequest	*_requestForChangePushSetting;
}

@property(nonatomic,strong)NSMutableArray	*changeItems;
@property(nonatomic,strong)TTURLRequest *requestForChangePushSetting;

@end
