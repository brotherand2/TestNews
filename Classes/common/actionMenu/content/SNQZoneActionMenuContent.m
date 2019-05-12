//
//  SNQZoneActionMenuContent.m
//  sohunews
//
//  Created by jojo on 14-4-24.
//  Copyright (c) 2014年 Sohu.com. All rights reserved.
//

#import "SNQZoneActionMenuContent.h"
#import "SNQQHelper.h"

@implementation SNQZoneActionMenuContent

- (void)resetShareConfig {
    [[self shareQQ] setIsShareToQZone:YES];
    self.shareTarget = ShareTargetQZone;
}

@end
