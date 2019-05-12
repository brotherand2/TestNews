//
//  SNNewsType.h
//  sohunews
//
//  Created by handy wang on 1/9/13.
//  Copyright (c) 2013 Sohu.com Inc. All rights reserved.
//
//newsType：内容类型（1焦点、3图文新闻、4组图新闻、6文本新闻、 7标题新闻、 8外链新闻、 9直播、 10专题、 11报纸、12投票 ）
typedef enum {
    SNNewsType_Unknown          = -1,
    SNNewsType_FocusNews        = 1,//暂不支持
    SNNewsType_PhotoAndTextNews = 3,
    SNNewsType_GroupPhotoNews   = 4,
    SNNewsType_TextNews         = 6,
    SNNewsType_TitleNews        = 7,
    SNNewsType_OutterLinkNews   = 8,
    SNNewsType_LiveNews         = 9,
    SNNewsType_SpecialNews      = 10,
    SNNewsType_NewspaperNews    = 11,
    SNNewsType_VoteNews         = 12,
    SNNewsType_JokeNews         = 62
} SNNewsType;
