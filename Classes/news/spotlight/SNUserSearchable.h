//
//  SNUserSearchable.h
//  LiteSohuNews
//
//  Created by iEvil on 9/14/15.
//  Copyright © 2015 Sohu.com. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <CoreSpotlight/CoreSpotlight.h>
#import "SNAPI.h"

static NSString * const SearchActivityType = @"com.sohu.newspaper.searchable";
static NSString * const SearchActivityAction = @"openURL";

//判断是否需要获取新的内容
static NSString * const SpotlightRefreshdate = @"SpotlightRefreshDate";

static NSString * const kSpotlightData = @"data";
static NSString * const kSpotlightContents = @"contents";
static NSString * const kSpotlightTitle = @"title";
static NSString * const kSpotlightContent = @"content";
static NSString * const kSpotlightLink = @"link2";
static NSString * const kSpotlightContentExpireTime = @"expire";


@interface SNUserSearchable : NSObject

+ (instancetype)sharedInstance;

/**
 *  添加Spotlight搜索支持, 并发送请求数据
 */
- (void)requestSpotlightData;

@end
