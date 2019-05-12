//
//  SNAppConfigVoiceCloud.m
//  sohunews
//
//  Created by jialei on 14-6-25.
//  Copyright (c) 2014年 Sohu.com. All rights reserved.
//

#import "SNAppConfigVoiceCloud.h"

static NSString *const keyIsOpenOfVoiceCloud = @"smc.client.voicecloud.isOpen";
static NSString *const keyUrlOfVoiceCloud = @"smc.client.voicecloud.url";
static NSString *const keyCopyWritingOfVoiceCloud = @"smc.client.voicecloud.copyWriting";

@implementation SNAppConfigVoiceCloud

- (void)updateWithDic:(NSDictionary *)dic
{
    self.dictInfo = [dic copy];
    self.isOpen = [self.dictInfo intValueForKey:keyIsOpenOfVoiceCloud defaultValue:0];
    self.url = [self.dictInfo stringValueForKey:keyUrlOfVoiceCloud defaultValue:nil];
    self.theCopyWriting = [self.dictInfo stringValueForKey:keyCopyWritingOfVoiceCloud defaultValue:nil];
}

- (void)dealloc
{
    
}

@end
