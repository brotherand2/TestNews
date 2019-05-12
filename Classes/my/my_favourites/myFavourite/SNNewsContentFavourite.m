//
//  SNNewsContentFavourite.m
//  sohunews
//
//  Created by Gao Yongyue on 13-12-10.
//  Copyright (c) 2013年 Sohu.com. All rights reserved.
//

#import "SNNewsContentFavourite.h"

@implementation SNNewsContentFavourite

- (NSString *)schemeFromProperties
{
    NSString *schemeString = [super schemeFromProperties];
    if (schemeString)
    {
        return schemeString;
    }
    if (_type == 2)
    {
        //来源于订阅tab下的，刊物新闻正文页  MYFAVOURITE_REFER_NEWS_IN_PUB
        if (_contentLevelFirstID && _contentLevelSecondID)
        {
            schemeString = [NSString stringWithFormat:@"news://termId=%@&newsId=%@",_contentLevelFirstID, _contentLevelSecondID];
        }
    }
    else if (_type == 3)
    {
        //来源于新闻tab下的新闻正文页  MYFAVOURITE_REFER_NEWS_IN_ROLLINGNEWS
        if (_contentLevelSecondID)
        {
            schemeString = [NSString stringWithFormat:@"news://newsId=%@",_contentLevelSecondID];
        }
    }
    else if (_type == 18) {
        if (_contentLevelSecondID) {
            schemeString = _contentLevelSecondID;
        }
    }

    return schemeString;
}


@end
