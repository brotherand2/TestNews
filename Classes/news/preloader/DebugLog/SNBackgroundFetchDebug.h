//
//  SNBackgroundFetchDebug.h
//  sohunews
//
//  Created by jojo on 13-11-12.
//  Copyright (c) 2013年 Sohu.com. All rights reserved.
//

#import <Foundation/Foundation.h>

#if DEBUG_MODE
#define SNBFLog(format, ...) snbf_debug([NSString stringWithFormat:format,## __VA_ARGS__])
#else
#define SNBFLog(format, ...) do{}while(0)
#endif

void snbf_debug(NSString *logMsg);
