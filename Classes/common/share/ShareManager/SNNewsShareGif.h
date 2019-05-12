//
//  SNNewsShareGif.h
//  sohunews
//
//  Created by wang shun on 2017/3/15.
//  Copyright © 2017年 Sohu.com. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SNSharePlatformBase.h"

@interface SNNewsShareGif : NSObject

+ (void)analyseGifData:(SNSharePlatformBase*) sharePlatForm Method:(void(^)(void))method;

@end
