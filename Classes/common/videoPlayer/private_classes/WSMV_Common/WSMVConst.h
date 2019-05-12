//
//  WSMVConst.h
//  WeSee
//
//  Created by handy wang on 9/12/13.
//  Copyright (c) 2013 handy. All rights reserved.
//

#import <Foundation/Foundation.h>

#define WSMV_DEBUG_MODE 0

//===XcodeColors
#define XCODE_COLORS_ESCAPE_MAC @"\033["
#define XCODE_COLORS_ESCAPE_IOS @"\xC2\xA0["

//#if TARGET_OS_IPHONE
#if 0
#define XCODE_COLORS_ESCAPE  XCODE_COLORS_ESCAPE_IOS
#else
#define XCODE_COLORS_ESCAPE  XCODE_COLORS_ESCAPE_MAC
#endif

#define XCODE_COLORS_RESET_FG  XCODE_COLORS_ESCAPE @"fg;" // Clear any foreground color
#define XCODE_COLORS_RESET_BG  XCODE_COLORS_ESCAPE @"bg;" // Clear any background color
#define XCODE_COLORS_RESET     XCODE_COLORS_ESCAPE @";"   // Clear any foreground or background color
//==========================================

#if DEBUG_MODE
    #define NSLogInfo(s, ...) NSLog(@"%@Info: <%p %@:(%d)> %@ %@",XCODE_COLORS_ESCAPE @"fg0,255,0;" XCODE_COLORS_ESCAPE @"bg0,0,0;", self, [[NSString stringWithUTF8String:__FILE__] lastPathComponent], __LINE__, [NSString stringWithFormat:(s), ##__VA_ARGS__], XCODE_COLORS_RESET)
    #define NSLogWarning(s, ...) NSLog(@"%@Warning: <%p %@:(%d)> %@ %@",XCODE_COLORS_ESCAPE @"fg247,250,7;" XCODE_COLORS_ESCAPE @"bg0,0,0;", self, [[NSString stringWithUTF8String:__FILE__] lastPathComponent], __LINE__, [NSString stringWithFormat:(s), ##__VA_ARGS__], XCODE_COLORS_RESET)
    #define NSLogError(s, ...) NSLog(@"%@Error: <%p %@:(%d)> %@ %@",XCODE_COLORS_ESCAPE @"fg255,0,0;" XCODE_COLORS_ESCAPE @"bg0,0,0;", self, [[NSString stringWithUTF8String:__FILE__] lastPathComponent], __LINE__, [NSString stringWithFormat:(s), ##__VA_ARGS__], XCODE_COLORS_RESET)
    #define NSLogFatal(s, ...) NSLog(@"%@Fatal: <%p %@:(%d)> %@ %@",XCODE_COLORS_ESCAPE @"fg0,255,255;" XCODE_COLORS_ESCAPE @"bg0,0,0;", self, [[NSString stringWithUTF8String:__FILE__] lastPathComponent], __LINE__, [NSString stringWithFormat:(s), ##__VA_ARGS__], XCODE_COLORS_RESET)
#else
    #define NSLogInfo(s, ...) ((void)0)
    #define NSLogError(s, ...) ((void)0)
    #define NSLogWarning(s, ...) ((void)0)
    #define NSLogFatal(s, ...) ((void)0)
#endif

@interface WSMVConst : NSObject
@end