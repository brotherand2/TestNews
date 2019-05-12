//
//  SNSegmentInfo.h
//  sohunews
//
//  Created by handy wang on 9/4/13.
//  Copyright (c) 2013 Sohu.com. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SNVideoDownloadManager.h"

@interface SNSegmentInfo : NSObject
@property (nonatomic, assign)NSInteger              duration;
@property (nonatomic, copy)NSString                 *urlString;

@property (nonatomic, assign)NSInteger              segmentOrder;
@property (nonatomic, assign)SNVideoDownloadState   state;
@property (nonatomic, copy)NSString                 *vid;
@property (nonatomic, assign)CGFloat                downloadBytes;
@property (nonatomic, assign)CGFloat                totalBytes;
@property (nonatomic, copy)NSString                 *videoType;
@end