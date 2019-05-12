//
//  SNAppConfigHttpsSwitch.m
//  sohunews
//
//  Created by Scarlett on 16/9/6.
//  Copyright © 2016年 Sohu.com. All rights reserved.
//

#import "SNAppConfigHttpsSwitch.h"
#import "SNAppConfigConst.h"

@implementation SNAppConfigHttpsSwitch

- (id)init
{
    self = [super init];
    if (self) {
        _httpsSwitchStatus = NO;
        [[NSUserDefaults standardUserDefaults] setObject:[NSString stringWithFormat:@"%d",NO] forKey:kHttpsSwitchStatusKey];
        [[NSUserDefaults standardUserDefaults] synchronize];
        _httpsSwitchStatusAll = NO;
    }
    return self;
}

- (void)updateWithDict:(NSDictionary *)dict {
#if defined SNPublicLinks_Https_Mode
    [SNUserDefaults setObject:[NSString stringWithFormat:@"%d",YES] forKey:kHttpsSwitchStatusKey];
    [SNUserDefaults setObject:[NSString stringWithFormat:@"%d",YES] forKey:kHttpsSwitchStatusAllKey];
#else
    NSString *status = [dict objectForKey:kHttpsSwitchStatus];
    if([status isKindOfClass:[NSString class]] && status && [status length] > 0){
        self.httpsSwitchStatus = [status boolValue];
        [SNUserDefaults setValue:status forKey:kHttpsSwitchStatusKey];
    }
    
    NSString *statusAll = [dict objectForKey:kHttpsSwitchStatusAll];
    if([statusAll isKindOfClass:[NSString class]] && statusAll && [statusAll length] > 0){
        self.httpsSwitchStatusAll = [statusAll boolValue];
        
        [SNUserDefaults setObject:status forKey:kHttpsSwitchStatusAllKey];
    }
#endif
}

@end
