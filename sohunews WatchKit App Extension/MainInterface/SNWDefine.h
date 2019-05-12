//
//  SNWDefine.h
//  sohunews
//
//  Created by tt on 15-4-1.
//  Copyright (c) 2015年 Sohu.com. All rights reserved.
//

#ifndef sohunews_SNWDefine_h
#define sohunews_SNWDefine_h
//#import "SNWTool.h"

#define snw_list_row_type                       @"watch.row"
#define snw_push_detail_identifier              @"watch.detail"

static NSString * const snw_host_userLog = @"watch_userLog";
static NSString * const snw_host_logParams = @"watch_logParams";

#define snw_app_group_filename                  @"watchData.plist"
#define snw_handoff_news_url                    @"watch_news_url"
#define snw_handoff_news_log_params             @"watch_news_log_params"
#define snw_handoff_version                     @"watch_version"
#define snw_handoff_view_detail_identifier      @"com.sohu.newspaper.inhouse.watch.handoff.view-detail"
#define snw_handoff_current_version             @"1"

#define snw_list_pushs                          @"pushes"
#define snw_list_title                          @"title"
#define snw_list_image_url                      @"pics"
#define snw_list_link                           @"link"
#define snw_list_time                           @"time"
#define snw_list_updateTime                     @"updateTime"
#define snw_list_newsId                         @"newsId"
#define snw_list_newsType                       @"newsType"

#pragma mark - WCSession 会话请求
#define snw_sessionType                         @"sessionType"
#define snw_sessionType_getAppInfo              @"sessionType_getAppInfo"

#define snw_app_group_filename                  @"watchData.plist"
#define snw_app_info_filename                   @"watchAppInfo.plist"

#define snw_push_list_url_extension(page, num, from, picScale, p1)                       [SNWTools rootUrl:[NSString stringWithFormat:@"/api/channel/push.go?page=%@&num=%@&from=%@&picScale=%@&p1=%@", page, num, from, picScale, p1]]

#define snw_home_directory                      [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject]
#define snw_data_filepath                       [snw_home_directory stringByAppendingPathComponent:snw_app_group_filename]

typedef enum : NSUInteger {
    RequestType_getList,
    RequestType_getImage,
    RequestType_loadMore,
} RequestType;

#endif
