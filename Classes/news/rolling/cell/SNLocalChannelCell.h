//
//  SNLocalChannelCell.h
//  sohunews
//
//  Created by lhp on 4/1/14.
//  Copyright (c) 2014 Sohu.com. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SNChannelListCell.h"

@interface SNLocalChannelCell : SNChannelListCell
- (void)localChannelWithCity:(NSString *)cityName describeInfo:describe;
@end
