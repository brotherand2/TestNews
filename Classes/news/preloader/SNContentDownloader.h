//
//  SNContentDownloader.h
//  sohunews
//
//  Created by jojo on 13-11-13.
//  Copyright (c) 2013年 Sohu.com. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SNNewsPreloader.h"

@interface SNContentDownloader : NSOperation

+ (id)downloader;

// 加入到wifi自动离线的队列中 (不一定会执行)
- (void)startWorkInWifiPriority;

// 加入到后台自动离线队列中 (在所有网络情况中都会执行，被执行的概率要大)
- (void)startWorkInImmediatelyPriority;

@end
