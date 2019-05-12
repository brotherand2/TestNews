//
//  COMPCompassManager.h
//  Compass
//
//  Created by 李耀忠 on 24/09/2017.
//  Copyright © 2017 Beijing Sohu New Media Information Technology Co. Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "COMPConfiguration.h"

@interface COMPCompassManager : NSObject

+ (void)startWithCId:(NSString*)cid;

+ (void)startWithCId:(NSString*)cid configuration:(COMPConfiguration *)configuration;

@end
