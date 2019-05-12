//
//  SNVideoReportRequest.m
//  sohunews
//
//  Created by qz on 2017/11/20.
//  Copyright © 2017年 Sohu.com. All rights reserved.
//

#import "SNVideoReportRequest.h"

@implementation SNVideoReportRequest

- (SNRequestMethod)sn_requestMethod {
    return SNRequestMethodGet;
}

- (NSString *)sn_requestUrl {
    return SNLinks_Report_Video_Site;
}


//playFrom    int
//播放位置,1频道流2正文页
//
//channelId    int
//频道id,频道流传
//
//channelNewsId    int//@qz 暂时先不传，因为频道流，从来就没管过这个字段
//频道新闻id,频道流传
//
//newsType    int
//新闻类型
//
//vid    int
//视频id
//
//site    int
//视频site
//
//status    int
//0不可以播1可以播
//
//newsId    int
//新闻id
//
//tvName    String
//视频标题

@end
