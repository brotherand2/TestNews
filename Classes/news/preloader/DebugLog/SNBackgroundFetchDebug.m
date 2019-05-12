//
//  SNBackgroundFetchDebug.m
//  sohunews
//
//  Created by jojo on 13-11-12.
//  Copyright (c) 2013年 Sohu.com. All rights reserved.
//

#import "SNBackgroundFetchDebug.h"
#import "NSDateHelper.h"

void snbf_debug(NSString *logMsg) {
#if DEBUG_MODE
    if (logMsg && [logMsg isKindOfClass:[NSString class]] && logMsg.length > 0) {
        NSArray *dirs = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
        NSString *cachePath = [dirs objectAtIndex:0];
        NSString *cacheDirPath = [cachePath stringByAppendingPathComponent:@"bfDebug"];
        
        NSFileManager *fileMgr = [[NSFileManager alloc] init];
        if (![fileMgr fileExistsAtPath:cacheDirPath]) {
            NSError *error = nil;
            if (![fileMgr createDirectoryAtPath:cacheDirPath withIntermediateDirectories:YES attributes:nil error:&error]) {
                NSLog(@"create cache dir error = %@", [error localizedDescription]);
            }
        }
        
        NSString *filePath = [cacheDirPath stringByAppendingPathComponent:@"bf.log"];
        if (![fileMgr fileExistsAtPath:filePath]) {
            [fileMgr createFileAtPath:filePath contents:nil attributes:nil];
        }
        
        [fileMgr release];
        
        NSFileHandle *fileHandle = [NSFileHandle fileHandleForWritingAtPath:filePath];
        if (fileHandle) {
            [fileHandle seekToEndOfFile];
            
            logMsg = [NSString stringWithFormat:@"%@\t%@\r\n", [NSDate stringFromDate:[NSDate date]], logMsg];
            [fileHandle writeData:[logMsg dataUsingEncoding:NSASCIIStringEncoding]];
            
            [fileHandle closeFile];
        }
    }
#endif
}