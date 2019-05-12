//
//  SNAppMonitorsManager.h
//  sohunews
//
//  Created by WongHandy on 8/13/14.
//  Copyright (c) 2014 Sohu.com. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SNAppMonitorsManagerConst.h"

@interface SNAppMonitorsManager : NSObject

+ (void)detachARequestMonitorURL:(NSURL *)url method:(SNRequestMonitor_RequestMethod)method;

@end