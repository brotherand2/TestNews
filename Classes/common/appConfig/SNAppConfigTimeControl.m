//
//  SNAppConfigTimeControl.m
//  sohunews
//
//  Created by Scarlett on 16/8/30.
//  Copyright © 2016年 Sohu.com. All rights reserved.
//

#import "SNAppConfigTimeControl.h"
#import "SNAppConfigConst.h"

@implementation SNAppConfigTimeControl

- (void)updateWithDict:(NSDictionary *)dict {
    self.timeCtrlDict = [dict objectForKey:kHomePageTimeCtrl];
    if (self.timeCtrlDict) {
        [SNUserDefaults setObject:self.timeCtrlDict forKey:kEditRollingNewsRefreshTime];
    }
}

- (void)dealloc {
}

@end
