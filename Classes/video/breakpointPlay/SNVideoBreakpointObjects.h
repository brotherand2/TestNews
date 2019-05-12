//
//  SNVideoBreakpointObjects.h
//  sohunews
//
//  Created by Gao Yongyue on 13-11-28.
//  Copyright (c) 2013年 Sohu.com. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum {
    VideoBreakpointContextTypeNone            = 0,    //不分来源
    VideoBreakpointContextTypeTimeline        = 1,    //来源于视频流
    VideoBreakpointContextTypeRecommend       = 2,    //来源于推荐流
    VideoBreakpointContextTypeDetail          = 3,    //来源于新闻详情页
    VideoBreakpointContextTypeOther           = 4     //来源于其它
} VideoBreakpointContextType;


@interface SNVideoBreakpointObjects : NSObject

@property (nonatomic, copy) NSString *vid;
@property (nonatomic, assign) double breakpoint;
@property (nonatomic, assign) double createAt;
@property (nonatomic, assign) VideoBreakpointContextType context;

- (id)initWithDict:(NSDictionary *)dict;
- (void)updateWithDict:(NSDictionary *)dict;

@end
