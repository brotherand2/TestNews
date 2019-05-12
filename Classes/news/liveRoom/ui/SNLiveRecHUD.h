//
//  SNLiveRecHUD.h
//  sohunews
//
//  Created by chenhong on 13-7-2.
//  Copyright (c) 2013年 Sohu.com. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SNLiveRecHUD : UIView

- (void)changeToCancelState:(BOOL)bCancel;

- (void)setTime:(NSString *)timeStr;
- (void)setLevelMeterDB:(float)lvl;

@end
