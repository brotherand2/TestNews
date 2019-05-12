//
//  SNLiveRoomContentCellVideoCache.h
//  sohunews
//
//  Created by handy wang on 7/11/13.
//  Copyright (c) 2013 Sohu.com. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SNLiveContentObjects.h"

@interface SNLiveRoomContentCellVideoCache : NSObject

+ (SNLiveRoomContentCellVideoCache *)sharedInstance;

- (NSString *)playingVideoKey;
- (void)setPlayingVideoKey:(NSString *)key;

- (NSString *)createPlayingVideoKey:(SNLiveRoomBaseObject *)obj;

@end