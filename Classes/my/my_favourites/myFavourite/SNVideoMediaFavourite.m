//
//  SNVideoMediaFavourite.m
//  sohunews
//
//  Created by Gao Yongyue on 13-12-25.
//  Copyright (c) 2013年 Sohu.com. All rights reserved.
//

#import "SNVideoMediaFavourite.h"

@implementation SNVideoMediaFavourite
- (NSString *)schemeFromProperties
{
    NSString *schemeString = [super schemeFromProperties];
    if (schemeString)
    {
        return schemeString;
    }
    if (_contentLevelFirstID && _contentLevelSecondID)
    {
        schemeString = [NSString stringWithFormat:@"videoMedia://columnId=%@&subId=%@",_contentLevelFirstID,_contentLevelSecondID];
    }
    return schemeString;
}
@end
