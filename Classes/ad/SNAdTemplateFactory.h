//
//  SNAdTemplateFactory.h
//  sohunews
//
//  Created by Xiang Wei Jia on 2/26/15.
//  Copyright (c) 2015 Sohu.com. All rights reserved.
//

#import <Foundation/Foundation.h>

@class SNAdBaseController;
@protocol SNAdDelegate;

@interface SNAdTemplateFactory : NSObject

// 通过广告ID加载流内广告模板
+ (SNAdBaseController *)loadStreamTemplateWithSpaceId:(NSString *)spaceId delegate:(id<SNAdDelegate>)delegate;

// 通过广告ID加载SDK中来的广告模板
+ (SNAdBaseController *)loadSDKTemplateWithSpaceId:(NSString *)spaceId delegate:(id<SNAdDelegate>)delegate filter:(NSDictionary *)filter;

// 通过广告ID加载视频广告模板
+ (SNAdBaseController *)loadVideoTemplateWithSpaceId:(NSString *)spaceId delegate:(id<SNAdDelegate>)delegate;

@end
