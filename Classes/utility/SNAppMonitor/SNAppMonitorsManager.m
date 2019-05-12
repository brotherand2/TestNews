//
//  SNAppMonitorsManager.m
//  sohunews
//
//  Created by WongHandy on 8/13/14.
//  Copyright (c) 2014 Sohu.com. All rights reserved.
//

#import "SNAppMonitorsManager.h"
#import "SNGetRequestMonitor.h"
#import "SNGetRequestMonitor.h"

@implementation SNAppMonitorsManager

+ (void)detachARequestMonitorURL:(NSURL *)url method:(SNRequestMonitor_RequestMethod)method {
    if (method == SNRequestMonitor_RequestMethod_GET) {
        SNGetRequestMonitor *getRequestMonitor = [[SNGetRequestMonitor alloc] initWithURL:url];
        [getRequestMonitor start];
    } else if (method == SNRequestMonitor_RequestMethod_POST) {
        //Not support currently.
    }
}

@end
