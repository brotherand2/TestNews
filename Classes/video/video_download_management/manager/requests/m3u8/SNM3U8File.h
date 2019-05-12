//
//  SNM3U8File.h
//  sohunews
//
//  Created by handy wang on 9/27/13.
//  Copyright (c) 2013 Sohu.com. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SNM3U8Playlist.h"

@interface SNM3U8File : NSObject
@property (nonatomic, copy)NSString         *vid;
@property (nonatomic, assign)NSInteger      segmentsActualCount;

@property (nonatomic, copy)NSString         *EXTM3U;
@property (nonatomic, copy)NSString         *EXT_X_ENDLIST;
@property (nonatomic, assign)NSInteger      EXT_X_TARGETDURATION;
@property (nonatomic, strong)SNM3U8Playlist *playlist;

@property (nonatomic, assign)NSInteger      nestM3u8BANDWIDTH;
@property (nonatomic, copy)NSString         *nestM3U8URL;
@end
