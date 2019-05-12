//
//  SNPullAdData.h
//  sohunews
//
//  Created by H on 15/4/2.
//  Copyright (c) 2015年 Sohu.com. All rights reserved.
//

#import "SNAdData.h"
#import "SNStatInfo.h"

@interface SNPullAdData : SNAdData

@property (nonatomic, copy) NSString * clickmonitor;
@property (nonatomic, copy) NSString * impressionid;
@property (nonatomic, copy) NSString * monitorkey;
@property (nonatomic, copy) NSString * offline;
@property (nonatomic, copy) NSString * onform;
@property (nonatomic, copy) NSString * online;
@property (nonatomic, copy) NSString * position;
@property (nonatomic, copy) NSString * size;
@property (nonatomic, copy) NSString * tag;
@property (nonatomic, copy) NSString * viewmonitor;
@property (nonatomic, copy) NSString * weight;
@property (nonatomic, copy) NSString * newsChannel;
@property (nonatomic, copy) NSString * gbcode;
@property (nonatomic, strong) NSDictionary * resource;
@property (nonatomic, copy) NSString * spaceId;
@property (nonatomic, copy) NSString * appchn;
@property (nonatomic, copy) NSString * adp_type;
@property (nonatomic, copy) NSDictionary *jsonData;

- (SNStatInfo *)createUploadStatInfo:(STADDisplayTrackType)reportType;
- (SNStatInfo *)createAdReportInfo:(STADDisplayTrackType)reportType;

+ (SNPullAdData *) pullAdDataWithAdDictionary:(NSDictionary *)adData;

@end
