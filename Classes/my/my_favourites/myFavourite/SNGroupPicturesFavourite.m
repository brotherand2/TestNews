//
//  SNGroupPicturesFavourite.m
//  sohunews
//
//  Created by Gao Yongyue on 13-12-10.
//  Copyright (c) 2013年 Sohu.com. All rights reserved.
//

#import "SNGroupPicturesFavourite.h"

@implementation SNGroupPicturesFavourite

- (NSString *)schemeFromProperties
{
    NSString *schemeString = [super schemeFromProperties];
    if (schemeString && _type != 13)
    {
        return schemeString;
    }
    if (_contentLevelSecondID)
    {
        if (_type == 6)
        {
            //!!!!!不确定再不再用
            //MYFAVOURITE_REFER_GROUPPHOTOSLIDE_FROM_PUB_MAG_HOME
            if (_contentLevelFirstID == nil || [_contentLevelFirstID isEqualToString:@"0"])
                schemeString = [NSString stringWithFormat:@"photo://gid=%@",_contentLevelSecondID];
            else
                schemeString = [NSString stringWithFormat:@"photo://termId=%@&newsId=%@",_contentLevelFirstID,_contentLevelSecondID];
        }
        else if (_type == 7 || _type == 8 || _type == 9 || _type == 10)
        {
            //!!!!!!不确定7，8，9，10是否再用
            //刊物组图PhotoList下的SlideShow里收藏或画报下的SlideShow收藏  MYFAVOURITE_REFER_GROUPPHOTOLIST_IN_CHANNEL
            schemeString = [NSString stringWithFormat:@"photo://gid=%@",_contentLevelSecondID];
        }
        else if (_type == 5)
        {
            //滚动新闻组图PhotoList下的SlideShow里收藏  MYFAVOURITE_REFER_GROUPPHOTOLIST_IN_ROLLINGNEWS
            if(_contentLevelFirstID == nil || [_contentLevelFirstID isEqualToString:@"0"])
                schemeString = [NSString stringWithFormat:@"photo://gid=%@",_contentLevelSecondID];
            else
                schemeString = [NSString stringWithFormat:@"photo://channelId=%@&newsId=%@",_contentLevelFirstID,_contentLevelSecondID];
        }
        else if (_type == 13)
        {
            schemeString = [NSString stringWithFormat:@"photo://termId=%@&newsId=%@",_contentLevelFirstID,_contentLevelSecondID];
        }
    }
    return schemeString;
}

@end
