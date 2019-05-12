//
//  SNLocalChannelRequest.h
//  sohunews
//
//  Created by 李腾 on 2017/2/20.
//  Copyright © 2017年 Sohu.com. All rights reserved.
//

#import "SNHeaderScookieRequest.h"
#import <CoreLocation/CoreLocation.h>


@interface SNLocalChannelRequest : SNHeaderScookieRequest

- (instancetype)initWithLocationCoordinate:(CLLocationCoordinate2D )locationCoordinate;

@end
