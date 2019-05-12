//
//  SNShareUpload.h
//  sohunews
//
//  Created by wang shun on 2017/2/4.
//  Copyright © 2017年 Sohu.com. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SNSharePlatformHeader.h"

typedef void (^ShareUploadCompletionBlock)(NSDictionary* responseDic);

@interface SNShareUpload : NSObject

@property (nonatomic,strong) SNSharePlatformBase* platForm;
@property (nonatomic,copy)   ShareUploadCompletionBlock completionMethod;

- (instancetype)initWithPlatForm:(SNSharePlatformBase *)p;

- (void)shareUploadRequestWithCompletion:(ShareUploadCompletionBlock)method;

@end
