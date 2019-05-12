//
//  SNPushSettingItem.h
//  sohunews
//
//  Created by 李 雪 on 11-7-3.
//  Copyright 2011 Sohu.com Inc. All rights reserved.
//
@interface SNPushSettingItem : NSObject {
	NSString *subId;
	NSString *pubId;
	NSString *pubName;
	NSString *pubIcon;
	NSString *pubPush;
}

@property (nonatomic, strong)NSString *subId;
@property (nonatomic, strong)NSString *pubId;
@property (nonatomic, strong)NSString *pubName;
@property (nonatomic, strong)NSString *pubIcon;
@property (nonatomic, strong)NSString *pubPush;
@property (nonatomic, assign)BOOL isNovelPushSetting;
@property (nonatomic, assign)BOOL isSNSPushSetting;//SNS push设置

@end
