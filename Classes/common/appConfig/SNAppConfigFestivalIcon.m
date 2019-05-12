//
//  SNAppConfigFestivalIcon.m
//  sohunews
//
//  Created by H on 15/4/7.
//  Copyright (c) 2015年 Sohu.com. All rights reserved.
//
#define kFestivalIconUrl             (@"url")

#import "SNAppConfigFestivalIcon.h"

static NSString *const kFestivalIcon                    =@"smc.client.loading.festival.icon";

@implementation SNAppConfigFestivalIcon

- (void)updateWithDic:(NSDictionary *)dic {

    id url = dic[kFestivalIcon];
    if ([url isKindOfClass:[NSString class]] && [url length] > 0) {
        url = [[url componentsSeparatedByString:@"="] lastObject];
        url = [[url componentsSeparatedByString:@"}"] firstObject];
        self.hasFestivalIcon = YES;
        self.festivalIconUrl = url;
    }else {
        self.hasFestivalIcon = NO;
        self.festivalIconUrl = nil;
    }
}


@end
