//
//  SNNewsAdInfo.h
//  sohunews
//
//  Created by jojo on 13-11-14.
//  Copyright (c) 2013年 Sohu.com. All rights reserved.
//

#import <Foundation/Foundation.h>

/*
 <icon_w>400</icon_w>
 <icon_h>300</icon_h>
 */

@interface SNNewsAdInfo : NSObject

@property (nonatomic, copy) NSString *adId; // 区别每个推广位 正文中可能包含多个
@property (nonatomic, copy) NSString *adUrl; // 可能是打开app的url scheme ， 也有可能是一个网页地址
@property (nonatomic, copy) NSString *adAppId; // app apple id
@property (nonatomic, copy) NSString *downloadUrl;
@property (nonatomic, copy) NSString *iconOpenUrl;
@property (nonatomic, copy) NSString *iconDownloadUrl;
@property (nonatomic, copy) NSString *iconWidth;
@property (nonatomic, copy) NSString *iconHeight;

- (NSString *)toJsonString;
- (id)initWithJsonDic:(NSDictionary *)json;

- (NSString *)iconUrlString;

- (BOOL)isValid;

@end
