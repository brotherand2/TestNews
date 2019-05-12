//
//  SNWeiboHotFavourite.m
//  sohunews
//
//  Created by Gao Yongyue on 13-12-10.
//  Copyright (c) 2013年 Sohu.com. All rights reserved.
//

#import "SNWeiboHotFavourite.h"

@implementation SNWeiboHotFavourite

- (NSString *)schemeFromProperties
{
    //MYFAVOURITE_REFER_WEIBO_HOT  11
    NSString *schemeString = [super schemeFromProperties];
    if (schemeString)
    {
        return schemeString;
    }
    if (_contentLevelSecondID)
    {
        schemeString = [NSString stringWithFormat:@"weibo://rootId=%@",_contentLevelSecondID];
    }
    return schemeString;
}

@end
