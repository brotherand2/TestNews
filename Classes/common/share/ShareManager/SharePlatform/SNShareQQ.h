//
//  SNShareQQ.h
//  sohunews
//
//  Created by wang shun on 2017/2/4.
//  Copyright © 2017年 Sohu.com. All rights reserved.
//

#import "SNSharePlatformBase.h"
#import "SNQQHelper.h"

@interface SNShareQQ : SNSharePlatformBase

@property (nonatomic,strong) NSString* isQZone;

-(instancetype)initWithOption:(NSInteger)option;

-(void)shareTo:(NSDictionary *)dic Upload:(UploadBlock)method;

+ (BOOL)isSupportQQSSO;

@end
