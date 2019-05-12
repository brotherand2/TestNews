//
//  SNADVideoCellAudioSession.m
//  sohunews
//
//  Created by wang shun on 2017/6/21.
//  Copyright © 2017年 Sohu.com. All rights reserved.
//

#import "SNADVideoCellAudioSession.h"

@implementation SNADVideoCellAudioSession




+(instancetype)sharedInstance {
    static SNADVideoCellAudioSession* _instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        if (! _instance) {
            _instance = [[SNADVideoCellAudioSession alloc] init];
        }
    });
                  
    return _instance;
}

@end
