//
//  SNADVideoCellAudioSession.h
//  sohunews
//
//  Created by wang shun on 2017/6/21.
//  Copyright © 2017年 Sohu.com. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SNADVideoCellAudioSession : NSObject

@property (nonatomic,assign) BOOL isADVideo;

+(instancetype)sharedInstance;

@end
