//
//  SNRollingSubscribeRecomItem.h
//  sohunews
//
//  Created by 赵青 on 15/12/2.
//  Copyright © 2015年 Sohu.com. All rights reserved.
//

//#import <Three20UI/Three20UI.h>
#import "Three20UI.h"

@interface SNRollingSubscribeRecomItem : TTTableSubtitleItem
{
    SCSubscribeObject *subscribeObject;
}
@property(nonatomic, strong)SCSubscribeObject *subscribeObject;

@end
