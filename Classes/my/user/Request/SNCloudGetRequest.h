//
//  SNCloudGetRequest.h
//  sohunews
//
//  Created by 李腾 on 2017/1/5.
//  Copyright © 2017年 Sohu.com. All rights reserved.
//

#import "SNDefaultParamsRequest.h"

typedef NS_ENUM(NSUInteger, SNCloudGetType) {
    SNCloudGetAll = 0,
    SNCloudGetFavourite,
    SNCloudGetChannels
};

@interface SNCloudGetRequest : SNDefaultParamsRequest

- (instancetype)initWithCloudGetType:(SNCloudGetType)cloudGetType;

@end
