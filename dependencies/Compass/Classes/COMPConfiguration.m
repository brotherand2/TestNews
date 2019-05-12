//
//  COMPConfiguration.m
//  Compass
//
//  Created by 李耀忠 on 28/09/2017.
//  Copyright © 2017 Beijing Sohu New Media Information Technology Co. Ltd. All rights reserved.
//

#import "COMPConfiguration.h"
#import "COMPConfiguration+Private.h"
#import "COMPConfig.h"

@implementation COMPConfiguration

+ (instancetype)defaultConfiguration {
    COMPConfiguration *configuration = [[COMPConfiguration alloc] init];
    configuration.allowsCellularAccess = YES;
    configuration.maxRecordCountPerUpload = UPLOAD_COUNT;
    configuration.timeIntervalForUpload = UPLOAD_INTERVAL;
    configuration.allowInterveneNetwork = YES;

    return configuration;

}

@end
