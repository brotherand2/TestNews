//
//  SNGroupPicturesContentFavourite.m
//  sohunews
//
//  Created by Gao Yongyue on 13-12-10.
//  Copyright (c) 2013年 Sohu.com. All rights reserved.
//

#import "SNGroupPicturesContentFavourite.h"

@implementation SNGroupPicturesContentFavourite

- (NSString *)schemeFromProperties
{
    NSString *schemeString = [super schemeFromProperties];
    if (schemeString)
    {
        return schemeString;
    }
    if (_contentLevelSecondID)
    {
        if (_type == 4)
        {
            //!!!!!!不知道是否再用
            ////打开收藏的刊物组图列表 MYFAVOURITE_REFER_GROUPPHOTOLIST_IN_PUB
            if (_contentLevelFirstID && _contentLevelSecondID)
            {
                schemeString = [NSString stringWithFormat:@"photo://termId=%@&newsId=%@",_contentLevelFirstID, _contentLevelSecondID];
            }
        }
        else if (_type == 5)
        {
            //滚动新闻进入组图PhotoList MYFAVOURITE_REFER_GROUPPHOTOLIST_IN_ROLLINGNEWS
            //也包括推荐来的组图，现在是把推荐来的内容当普通的内容来看待
            if(_contentLevelFirstID == nil || [_contentLevelFirstID isEqualToString:kCorpusNewsGidExist])
                schemeString = [NSString stringWithFormat:@"photo://gid=%@",_contentLevelSecondID];
            else
                schemeString = [NSString stringWithFormat:@"photo://channelId=%@&newsId=%@",_contentLevelFirstID,_contentLevelSecondID];
        }
    }
    return schemeString;
}

@end
