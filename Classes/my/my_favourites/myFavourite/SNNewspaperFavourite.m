//
//  SNNewspaperFavourite.m
//  sohunews
//
//  Created by Gao Yongyue on 13-12-7.
//  Copyright (c) 2013年 Sohu.com. All rights reserved.
//

#import "SNNewspaperFavourite.h"
#import "SNDBManager.h"

@implementation SNNewspaperFavourite

- (NSString *)schemeFromProperties
{
    //MYFAVOURITE_REFER_PUB_HOME 1
    NSString *schemeString = [super schemeFromProperties];
    if (schemeString)
    {
        return schemeString;
    }
    if (_contentLevelFirstID && _contentLevelSecondID)
    {
        NSString *pubID = [_contentLevelFirstID stringByReplacingOccurrencesOfString:@"," withString:@"_"];
        NSArray *propertyArray = [_contentLevelSecondID componentsSeparatedByString:@"#"];
        if ([propertyArray count]==2)
        {
            schemeString = [NSString stringWithFormat:@"subHome://pubId=%@&subId=%@&termId=%@",pubID,propertyArray[1],propertyArray[0]];
        } else {
            schemeString = [NSString stringWithFormat:@"subHome://pubId=%@&subId=%@&termId=%@",pubID,_contentLevelSecondID,_contentLevelFirstID];
        }
    }
    return schemeString;
}

@end
