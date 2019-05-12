//
//  SNListenNewsDownloaderDelegate.h
//  sohunews
//
//  Created by weibin cheng on 14-6-17.
//  Copyright (c) 2014年 Sohu.com. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol SNListenNewsDownloaderDelegate <NSObject>

@optional
- (void)listenNewsDidFinishedWithContent:(NSString*)content;
@end
