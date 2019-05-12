//
//  SNRollingNewsSubscribeItem.h
//  sohunews
//
//  Created by lhp on 10/13/14.
//  Copyright (c) 2014 Sohu.com. All rights reserved.
//

#import "CacheObjects.h"

@interface SNRollingNewsSubscribeItem : TTTableSubtitleItem
{
    SCSubscribeObject *subscribeObject;
}
@property(nonatomic, strong)SCSubscribeObject *subscribeObject;

@end
