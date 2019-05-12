//
//  SNDebug.h
//  sohunews
//
//  Created by Chen Hong on 13-2-4.
//  Copyright (c) 2013年 Sohu.com Inc. All rights reserved.
//

#ifndef SOHUNEWS_SNDEBUG_H
#define SOHUNEWS_SNDEBUG_H

#import "SNConsts.h"

#if DEBUG_MODE
    #define SNDebugLog(format, ...)   NSLog(format, ##__VA_ARGS__)
#else
    #define SNDebugLog(format, ...)
#endif

#define SN_String(str) [NSString stringWithCString:(str) encoding:NSUTF8StringEncoding]

#endif //SOHUNEWS_SNDEBUG_H
