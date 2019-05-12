//
//  COMPConfiguration+Private.h
//  Compass
//
//  Created by 李耀忠 on 06/11/2017.
//  Copyright © 2017 Beijing Sohu New Media Information Technology Co. Ltd. All rights reserved.
//

@interface COMPConfiguration ()

@property (nonatomic) BOOL allowsCellularAccess;

//一次上传最多包含的record数
@property (nonatomic) NSInteger maxRecordCountPerUpload;

//两次上传之间的时间间隔，单位秒，如果为0则不开启定时器
@property (nonatomic) NSTimeInterval timeIntervalForUpload;

+ (instancetype)defaultConfiguration;

@end
