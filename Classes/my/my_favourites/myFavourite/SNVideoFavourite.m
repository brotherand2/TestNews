//
//  SNVideoFavourite.m
//  sohunews
//
//  Created by Gao Yongyue on 13-12-11.
//  Copyright (c) 2013年 Sohu.com. All rights reserved.
//

#import "SNVideoFavourite.h"

@implementation SNVideoFavourite

- (NSString *)schemeFromProperties
{
    NSString *schemeString = [super schemeFromProperties];
    if (schemeString)
    {
        return schemeString;
    }
    if (_contentLevelFirstID)
    {
        schemeString = [NSString stringWithFormat:@"video://mid=%@",_contentLevelSecondID];
    }
    return schemeString;
}

@end
