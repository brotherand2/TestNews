//
//  NewsImageUrlParser.h
//  sohunews
//
//  Created by Chen Hong on 13-3-12.
//  Copyright (c) 2013年 Sohu.com Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SNNewsImageUrlParser : NSObject

+ (NSArray*)getImageUrlFromNewsContent:(NSString*)newsContent;

+ (NSArray*)getThumbnailUrlFromNewsContent:(NSString*)newsContent;

@end
