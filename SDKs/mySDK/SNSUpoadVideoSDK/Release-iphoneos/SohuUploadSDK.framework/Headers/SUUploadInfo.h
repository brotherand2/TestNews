//
//  SUUploadInfo.h
//  SohuUploadSDK
//
//  Created by wangfeng on 2017/8/10.
//  Copyright © 2017年 搜狐. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SUUploadInfo : NSObject

@property (nonatomic, assign) NSInteger videoStatus;
@property (nonatomic, assign) BOOL isExist;

@property (nonatomic, copy) NSString *vto;

@end
